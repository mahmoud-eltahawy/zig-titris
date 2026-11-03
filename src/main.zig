const std = @import("std");
const buildin = @import("builtin");

const rl = @import("raylib");
const zizris = @import("zizris");

const tetr = @import("tetrominoe.zig");
pub const Tetrominoes = tetr.Tetrominoes;

pub const WIDTH_BOXES_CAPACITY = 20;
pub const HEIGHT_BOXES_CAPACITY = WIDTH_BOXES_CAPACITY * 2;
pub const WINDOW_WIDTH = 400;
pub const WINDOW_HEIGHT = WINDOW_WIDTH * 2;
pub const SINGLE_BOX_SIZE = WINDOW_WIDTH / WIDTH_BOXES_CAPACITY;
pub const BLOCK_SIZE = SINGLE_BOX_SIZE * 2;
pub const LINES_THICKNESS = 3;

pub const X = 0;
pub const Y = 1;

pub const Vector = @Vector(2, f32);

pub const VecedTetris = struct {
    position: Vector = .{ WIDTH_BOXES_CAPACITY / 2 - 1, -1 },
    tetrominoes: Tetrominoes = .{},
};

const State = @import("state.zig");

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
        state.handle_events();
        state.update();

        rl.beginDrawing();
        defer rl.endDrawing();
        draw(&state);
    }
}

fn draw(state: *const State) void {
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
