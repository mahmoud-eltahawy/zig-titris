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

const VecedTetris = struct {
    position: rl.Vector2 = .init(WIDTH_BOXES_CAPACITY / 2 - 1, -1),
    tetrominoes: Tetrominoes = .{},
};

const State = struct {
    user_closed_the_window: bool = false,
    time_instant_in_seconds: f64 = 0,
    moving_tetris: VecedTetris = .{},
    static_tetris: [WIDTH_BOXES_CAPACITY][HEIGHT_BOXES_CAPACITY]?u0 = @splat(@splat(null)),
};

pub fn main(_: std.process.Init) !void {
    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Zizris (a tetris game in zig)");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var state: State = .{};

    while (!rl.windowShouldClose() and !state.user_closed_the_window) {
        handle_events(&state);

        rl.beginDrawing();
        defer rl.endDrawing();

        try draw(&state);
    }
}

fn handle_events(state: *State) void {
    const ctrl_down = rl.isKeyDown(.left_control) or rl.isKeyDown(.right_control);
    if (ctrl_down and rl.isKeyPressed(.w)) {
        state.user_closed_the_window = true;
    }
    if (rl.isKeyPressed(.left) and state.moving_tetris.position.x > 0) {
        state.moving_tetris.position.x -= 1;
    }
    // zig fmt: off
    if (
        rl.isKeyPressed(.right) and
        state.moving_tetris.position.x
            <
        WIDTH_BOXES_CAPACITY - state.moving_tetris.tetrominoes.width() - 1
    ) {
        state.moving_tetris.position.x += 1;
    }
    // zig fmt: on
}

fn draw(state: *State) !void {
    rl.clearBackground(.black);

    if (buildin.mode == .debug) {
        draw_coordientants();
    }

    draw_moving_tetris(state);

    for (state.static_tetris, 0..) |xs, x| {
        for (xs, 0..) |v, y| {
            if (v) |_| {
                block(rl.Vector2.init(@floatFromInt(x), @floatFromInt(y)));
            }
        }
    }

    // zig fmt: off
    if (
        state.moving_tetris.position.y
            ==
        HEIGHT_BOXES_CAPACITY - state.moving_tetris.tetrominoes.height() - 1
    ) {

        const choosed = state
            .moving_tetris
            .tetrominoes
            .get_choosed_varient_at(state.moving_tetris.position);            
        for (choosed) |v| {
            state.static_tetris[@trunc(v.x)][@trunc(v.y)] = 0;
        }
        // try state.static_tetris.appendSlice(
        //     allocator,
        //     &state
        //         .moving_tetris
        //         .tetrominoes
        //         .get_choosed_varient_at(state.moving_tetris.position));
        state.moving_tetris = .{};
    } else if (rl.getTime() - state.time_instant_in_seconds > 0.5) {
        state.moving_tetris.position.y += 1;
        state.time_instant_in_seconds = rl.getTime();
    }
    // zig fmt: on
}

fn block(grid_pos: rl.Vector2) void {
    const pos = grid_pos.scale(SINGLE_BOX_SIZE);
    rl.drawRectangleV(pos, .{ .x = SINGLE_BOX_SIZE, .y = SINGLE_BOX_SIZE }, .white);
    const rect = rl.Rectangle.init(pos.x, pos.y, SINGLE_BOX_SIZE, SINGLE_BOX_SIZE);
    rl.drawRectangleLinesEx(rect, LINES_THICKNESS, .red);
}

fn draw_moving_tetris(state: *const State) void {
    const grid_pos: rl.Vector2 = state.moving_tetris.position;
    const shape: Tetrominoes = state.moving_tetris.tetrominoes;

    for (shape.get_choosed_varient()) |x| {
        block(x.add(grid_pos));
    }
}

fn draw_coordientants() void {
    rl.drawLineV(.{ .x = WINDOW_WIDTH / 2, .y = 0 }, .{ .x = WINDOW_WIDTH / 2, .y = WINDOW_HEIGHT }, .white);
    rl.drawLineV(.{ .x = 0, .y = WINDOW_HEIGHT / 2 }, .{ .x = WINDOW_WIDTH, .y = WINDOW_HEIGHT / 2 }, .white);
}
