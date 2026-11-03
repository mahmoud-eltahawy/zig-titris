const std = @import("std");
const buildin = @import("builtin");

const rl = @import("raylib");
const zizris = @import("zizris");

const tetr = @import("tetrominoe.zig");
const Tetrominoes = tetr.Tetrominoes;

const WIDTH_BOXES_CAPACITY = 20;
const HEIGHT_BOXES_CAPACITY = WIDTH_BOXES_CAPACITY * 2;
const WINDOW_WIDTH = 400;
const WINDOW_HEIGHT = WINDOW_WIDTH * 2;
const SINGLE_BOX_SIZE = WINDOW_WIDTH / WIDTH_BOXES_CAPACITY;
const BLOCK_SIZE = SINGLE_BOX_SIZE * 2;
const LINES_THICKNESS = 3;

pub const X = 0;
pub const Y = 1;

pub const Vector = @Vector(2, f32);

const VecedTetris = struct {
    position: Vector = .{ WIDTH_BOXES_CAPACITY / 2 - 1, -1 },
    tetrominoes: Tetrominoes = .{},
};

const State = struct {
    user_closed_the_window: bool = false,
    time_instant_in_seconds: f64 = 0,
    moving_tetris: VecedTetris = .{},
    static_tetris: [WIDTH_BOXES_CAPACITY][HEIGHT_BOXES_CAPACITY]bool = @splat(@splat(false)),
    random: std.Random,

    fn moving_tetris_reached(self: *State) bool {
        //got to the bottom
        if (self.moving_tetris.position[Y] ==
            HEIGHT_BOXES_CAPACITY - self.moving_tetris.tetrominoes.height() - 1)
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

    fn tetris_closest_blocks(self: *const State) [4]?Vector {
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

    fn random_veced_tetris(self: *const State) VecedTetris {
        const kinds = std.enums.values(tetr.TetrominoesKind);

        const tetrominoes: Tetrominoes = .{
            .kind = kinds[self.random.intRangeLessThan(u3, 0, kinds.len)],
            .varient_index = self.random.int(u2),
        };

        const width: usize = @intFromFloat(tetrominoes.width());
        const random_x = self.random.intRangeAtMost(usize, 0, WIDTH_BOXES_CAPACITY - width - 1);

        return .{ .position = .{ @floatFromInt(random_x), -1 }, .tetrominoes = tetrominoes };
    }

    fn update(self: *State) void {
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
};

pub fn main(_: std.process.Init) !void {
    const random = blk: {
        var prng = std.Random.DefaultPrng.init(7720);
        const random = prng.random();
        break :blk random;
    };
    var state: State = .{ .random = random };

    rl.setTargetFPS(60);
    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Zizris (a tetris game in zig)");
    defer rl.closeWindow();

    while (!rl.windowShouldClose() and !state.user_closed_the_window) {
        handle_events(&state);
        state.update();

        rl.beginDrawing();
        defer rl.endDrawing();

        try draw(&state);
    }
}

fn handle_events(state: *State) void {
    const ctrl_down = rl.isKeyDown(.left_control) or rl.isKeyDown(.right_control);
    if (ctrl_down and (rl.isKeyPressed(.w) or rl.isKeyPressed(.c))) {
        state.user_closed_the_window = true;
    }
    if (rl.isKeyPressed(.left) and state.moving_tetris.position[X] > 0) {
        state.moving_tetris.position[X] -= 1;
    }
    if (rl.isKeyPressed(.right) and
        state.moving_tetris.position[X] <
            WIDTH_BOXES_CAPACITY - state.moving_tetris.tetrominoes.width() - 1)
    {
        state.moving_tetris.position[X] += 1;
    }
    if (rl.isKeyPressed(.space)) {
        state.moving_tetris.tetrominoes.varient_index +%= 1;
        if (state.moving_tetris.tetrominoes.width_at(state.moving_tetris.position) >= state.static_tetris.len) {
            state.moving_tetris.tetrominoes.varient_index -%= 1;
        }
    }
}

fn draw(state: *const State) !void {
    rl.clearBackground(.black);

    if (buildin.mode == .debug) {
        draw_coordientants();
    }

    draw_moving_tetris(state);
    draw_static_tetris(state);
}

fn draw_block(grid_pos: Vector, color: rl.Color) void {
    const scaler: @Vector(2, f32) = @splat(SINGLE_BOX_SIZE);
    const pos = scaler * grid_pos;
    rl.drawRectangleV(.initVec(pos), .initVec(@splat(SINGLE_BOX_SIZE)), .white);
    const rect = rl.Rectangle.init(pos[X], pos[Y], SINGLE_BOX_SIZE, SINGLE_BOX_SIZE);
    rl.drawRectangleLinesEx(rect, LINES_THICKNESS, color);
}

fn draw_moving_tetris(state: *const State) void {
    const grid_pos: Vector = state.moving_tetris.position;
    const shape: Tetrominoes = state.moving_tetris.tetrominoes;

    for (shape.get_choosed_varient()) |x| {
        draw_block(x + grid_pos, .red);
    }
    if (buildin.mode == .debug) {
        const lowest = state.moving_tetris.tetrominoes.get_lowest_blocks_at(state.moving_tetris.position);
        for (lowest) |optinal_b| {
            if (optinal_b) |b| {
                draw_block(b, .blue);
            }
        }
    }
}

fn draw_static_tetris(state: *const State) void {
    for (state.static_tetris, 0..) |xs, x| {
        for (xs, 0..) |v, y| {
            if (v) {
                draw_block(.{ @floatFromInt(x), @floatFromInt(y) }, .red);
            }
        }
    }

    if (buildin.mode == .debug) {
        for (state.tetris_closest_blocks()) |optinal_b| {
            if (optinal_b) |b| {
                draw_block(b, .blue);
            }
        }
    }
}

fn draw_coordientants() void {
    rl.drawLineV(.{ .x = WINDOW_WIDTH / 2, .y = 0 }, .{ .x = WINDOW_WIDTH / 2, .y = WINDOW_HEIGHT }, .white);
    rl.drawLineV(.{ .x = 0, .y = WINDOW_HEIGHT / 2 }, .{ .x = WINDOW_WIDTH, .y = WINDOW_HEIGHT / 2 }, .white);
}
