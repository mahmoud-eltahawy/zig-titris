const rl = @import("raylib");
const ziz = @import("main.zig");
const std = @import("std");
const tetr = @import("tetrominoe.zig");

const VecedTetris = ziz.VecedTetris;
const X = ziz.X;
const Y = ziz.Y;

user_closed_the_window: bool = false,
time_instant_in_seconds: f64 = 0,
moving_tetris: ziz.VecedTetris = .{},
static_tetris: [ziz.WIDTH_BOXES_CAPACITY][ziz.HEIGHT_BOXES_CAPACITY]bool = @splat(@splat(false)),
random: std.Random,

fn is_position_acceptable(self: *const @This()) bool {
    //be at the right of left wall
    if (self.moving_tetris.position[X] < 0) {
        return false;
    }

    //be at the left of right wall
    if (self.moving_tetris.position[X] >
        ziz.WIDTH_BOXES_CAPACITY - self.moving_tetris.tetrominoes.width() - 1)
    {
        return false;
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
    if (rl.isKeyPressed(.space)) {
        self.moving_tetris.tetrominoes.varient_index +%= 1;
        if (!self.is_position_acceptable()) {
            self.moving_tetris.tetrominoes.varient_index -%= 1;
        }
    }
}

fn moving_tetris_reached(self: *@This()) bool {
    //got to the bottom
    if (self.moving_tetris.position[Y] ==
        ziz.HEIGHT_BOXES_CAPACITY - self.moving_tetris.tetrominoes.height() - 1)
    {
        return true;
    }

    //got to lower block
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

pub fn tetris_closest_blocks(self: *const @This()) [4]?ziz.Vector {
    var lowest = self.moving_tetris.tetrominoes
        .get_lowest_blocks_at(self.moving_tetris.position);

    for (lowest, 0..) |optinal_v, i| {
        if (optinal_v) |v| {
            const column = &self.static_tetris[@trunc(v[X])];

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

    const tetrominoes: ziz.Tetrominoes = .{
        .kind = kinds[self.random.intRangeLessThan(u3, 0, kinds.len)],
        .varient_index = self.random.int(u2),
    };

    const width: usize = @intFromFloat(tetrominoes.width());
    const random_x = self.random.intRangeAtMost(usize, 0, ziz.WIDTH_BOXES_CAPACITY - width - 1);

    return .{ .position = .{ @floatFromInt(random_x), -1 }, .tetrominoes = tetrominoes };
}

pub fn update(self: *@This()) void {
    if (self.moving_tetris_reached()) {
        const choosed = self
            .moving_tetris
            .tetrominoes
            .get_choosed_varient_at(self.moving_tetris.position);
        for (choosed) |v| {
            self.static_tetris[@trunc(v[X])][@trunc(v[Y])] = true;
        }

        self.moving_tetris = self.random_veced_tetris();
    } else if (rl.getTime() - self.time_instant_in_seconds > 0.5) {
        self.moving_tetris.position[Y] += 1;
        self.time_instant_in_seconds = rl.getTime();
    }
}
