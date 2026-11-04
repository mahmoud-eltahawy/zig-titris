const rl = @import("raylib");
const ziz = @import("main.zig");
const std = @import("std");
const tetr = @import("tetrominoe.zig");
const builtin = @import("builtin");

const VecedTetris = ziz.VecedTetris;
const X = ziz.X;
const Y = ziz.Y;

user_closed_the_window: bool = false,
time_instant_in_seconds: f64 = 0,
moving_tetris: ziz.VecedTetris = .{},
static_tetris: [ziz.WIDTH_BOXES_CAPACITY][ziz.HEIGHT_BOXES_CAPACITY]bool = @splat(@splat(false)),
random: std.Random,

fn is_position_acceptable(self: *const @This()) bool {
    // Right of the left wall.
    if (self.moving_tetris.position[X] < 0) return false;

    // Left of the right wall.
    if (self.moving_tetris.position[X] >
        ziz.WIDTH_BOXES_CAPACITY - self.moving_tetris.tetrominoes.width() - 1)
    {
        return false;
    }

    const floor: f32 = @floatFromInt(ziz.HEIGHT_BOXES_CAPACITY);

    for (self.moving_tetris.tetrominoes.get_choosed_varient_at(self.moving_tetris.position)) |v| {
        if (v[Y] >= floor) return false;

        const x: usize = @intFromFloat(v[X]);
        const y: usize = @intFromFloat(v[Y]);
        if (self.static_tetris[x][y]) return false;
    }

    return true;
}

pub fn handle_events(self: *@This()) void {
    const ctrl_down = rl.isKeyDown(.left_control) or rl.isKeyDown(.right_control);
    if (ctrl_down and (rl.isKeyPressed(.w) or rl.isKeyPressed(.c))) {
        self.user_closed_the_window = true;
    }
    if (rl.isKeyPressed(.left)) {
        self.moving_tetris.position[X] -= 1;
        if (!self.is_position_acceptable()) {
            self.moving_tetris.position[X] += 1;
        }
    }
    if (rl.isKeyPressed(.right) and
        self.moving_tetris.position[X] <
            ziz.WIDTH_BOXES_CAPACITY - self.moving_tetris.tetrominoes.width() - 1)
    {
        self.moving_tetris.position[X] += 1;
        if (!self.is_position_acceptable()) {
            self.moving_tetris.position[X] -= 1;
        }
    }

    const d = self.get_lower_block_distance();
    if (builtin.mode == .debug) {
        ziz.outline_block(.{ self.moving_tetris.position[X], d }, .yellow);
    }
    if (rl.isKeyPressed(.down)) {
        self.moving_tetris.position[Y] = d;
    }

    if (rl.isKeyPressed(.space)) {
        self.moving_tetris.tetrominoes.varient_index +%= 1;
        if (!self.is_position_acceptable()) {
            self.moving_tetris.tetrominoes.varient_index -%= 1;
        }
    }
}

const DestroyableLevels = struct {
    index: usize,
    len: usize,
};

fn all(arr: []const bool) bool {
    for (arr) |it| {
        if (!it) return false;
    }
    return true;
}

fn get_destroyable_levels(self: *const @This()) ?DestroyableLevels {
    var y: usize = 0;
    while (y < ziz.HEIGHT_BOXES_CAPACITY) : (y += 1) {
        var full = true;
        for (0..ziz.WIDTH_BOXES_CAPACITY) |x| {
            if (!self.static_tetris[x][y]) {
                full = false;
                break;
            }
        }
        if (!full) continue;

        var len: usize = 1;
        while (y + len < ziz.HEIGHT_BOXES_CAPACITY) : (len += 1) {
            var next_full = true;
            for (0..ziz.WIDTH_BOXES_CAPACITY) |x| {
                if (!self.static_tetris[x][y + len]) {
                    next_full = false;
                    break;
                }
            }
            if (!next_full) break;
        }
        return .{ .index = y, .len = len };
    }
    return null;
}

fn destroy_destroyable_levels(self: *@This()) void {
    while (self.get_destroyable_levels()) |dest| {
        var y: usize = dest.index;
        while (y > 0) {
            y -= 1;
            for (0..ziz.WIDTH_BOXES_CAPACITY) |x| {
                self.static_tetris[x][y + dest.len] = self.static_tetris[x][y];
            }
        }
        for (0..dest.len) |iy| {
            for (0..ziz.WIDTH_BOXES_CAPACITY) |x| {
                self.static_tetris[x][iy] = false;
            }
        }
    }
}

pub fn update(self: *@This()) void {
    if (self.moving_tetris_reached()) {
        const choosed = self
            .moving_tetris
            .tetrominoes
            .get_choosed_varient_at(self.moving_tetris.position);
        for (choosed) |v| {
            const x: usize = @intFromFloat(v[X]);
            const y: usize = @intFromFloat(v[Y]);
            self.static_tetris[x][y] = true;
            self.destroy_destroyable_levels();
        }

        self.moving_tetris = self.random_veced_tetris();
    } else if (rl.getTime() - self.time_instant_in_seconds > 0.5) {
        self.moving_tetris.position[Y] += 1;
        self.time_instant_in_seconds = rl.getTime();
    }
}

fn reached_the_bottom(self: *const @This()) bool {
    return self.moving_tetris.position[Y] ==
        ziz.HEIGHT_BOXES_CAPACITY - self.moving_tetris.tetrominoes.height() - 1;
}

fn get_lower_block_distance(self: *const @This()) f32 {
    const tetrominoes = self.moving_tetris.tetrominoes;
    const position = self.moving_tetris.position;
    const lowest = tetrominoes.get_lowest_blocks_at(position);
    const floor: f32 = @floatFromInt(ziz.HEIGHT_BOXES_CAPACITY);

    var min_drop: f32 = (floor - 1.0) - (position[Y] + tetrominoes.height());

    for (lowest) |opt_v| {
        const v = opt_v orelse continue;
        const column: usize = @intFromFloat(v[X]);

        var limit: f32 = floor;
        for (self.static_tetris[column], 0..) |occupied, j| {
            const j_f32: f32 = @floatFromInt(j);
            if (occupied and j_f32 > v[Y]) {
                limit = j_f32;
                break;
            }
        }

        const drop = limit - v[Y] - 1.0;
        if (drop < min_drop) min_drop = drop;
    }

    return position[Y] + min_drop;
}

fn reached_lower_block(self: *const @This()) bool {
    for (self.moving_tetris.tetrominoes.get_lowest_blocks_at(self.moving_tetris.position), self.tetris_closest_blocks()) |optinal_v1, optinal_v2| {
        if (optinal_v1) |v1| {
            if (optinal_v2) |v2| {
                if (@abs(v1[Y] - v2[Y]) == 1) {
                    return true;
                }
            }
        }
    }
    return false;
}

fn moving_tetris_reached(self: *const @This()) bool {
    return self.reached_the_bottom() or self.reached_lower_block();
}

pub fn tetris_closest_blocks(self: *const @This()) [4]?ziz.Vector {
    var lowest = self.moving_tetris.tetrominoes
        .get_lowest_blocks_at(self.moving_tetris.position);

    for (lowest, 0..) |optinal_v, i| {
        if (optinal_v) |v| {
            const column = &self.static_tetris[@intFromFloat(v[X])];

            for (column, 0..) |occupied, j| {
                const j_f32: f32 = @floatFromInt(j);
                if (occupied and j_f32 > v[Y]) {
                    lowest[i] = .{ v[X], j_f32 };
                    break;
                }
            }
        }
    }
    return lowest;
}

fn random_veced_tetris(self: *const @This()) VecedTetris {
    const kinds = std.enums.values(tetr.TetrominoesKind);

    const tetrominoes: tetr.Tetrominoes = .{
        .kind = kinds[self.random.intRangeLessThan(u3, 0, kinds.len)],
        .varient_index = self.random.int(u2),
    };

    const width: usize = @intFromFloat(tetrominoes.width());
    const random_x = self.random.intRangeAtMost(usize, 0, ziz.WIDTH_BOXES_CAPACITY - width - 1);

    return .{ .position = .{ @floatFromInt(random_x), -1 }, .tetrominoes = tetrominoes };
}
