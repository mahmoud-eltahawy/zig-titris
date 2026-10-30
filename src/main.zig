const std = @import("std");
const Io = std.Io;

const zizris = @import("zizris");
const rl = @import("raylib");

const WINDOW_WIDTH = 400;
const WINDOW_HEIGHT = WINDOW_WIDTH * 2;
const SINGLE_BOX_SIZE = WINDOW_WIDTH / 20;
const BLOCK_SIZE = SINGLE_BOX_SIZE * 2;
const LINES_THICKNESS = 3;

const State = struct {
    user_closed_the_window: bool = false,
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
        draw(&state);
    }
}

fn handle_events(state: *State) void {
    if (rl.isKeyDown(.left_control) and rl.isKeyReleased(.q)) {
        state.user_closed_the_window = true;
    }
}

fn draw(_: *State) void {
    rl.clearBackground(.black);
    rl.drawText("hello world", WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 26, .white);

    draw_coordientants();
    draw_tetris_block(.{ .x = 1, .y = 1 });
    draw_tetris_block(.{ .x = 3, .y = 3 });
    draw_tetris_block(.{ .x = 5, .y = 5 });
}

fn draw_tetris_block(grid_pos: rl.Vector2) void {
    const pos = grid_pos.scale(SINGLE_BOX_SIZE);
    const HBS = BLOCK_SIZE / 2;
    const cx = pos.x - HBS;
    const cy = pos.y - HBS;
    const x: i32 = @trunc(cx);
    const y: i32 = @trunc(cy);

    const top_left: rl.Vector2 = .{ .x = cx, .y = cy };
    const top_right: rl.Vector2 = .{ .x = cx + BLOCK_SIZE, .y = cy };
    const bottom_right: rl.Vector2 = .{ .x = cx + BLOCK_SIZE, .y = cy + BLOCK_SIZE };
    const bottom_left: rl.Vector2 = .{ .x = cx, .y = cy + BLOCK_SIZE };

    rl.drawRectangle(x, y, BLOCK_SIZE, BLOCK_SIZE, .white);
    const rect = rl.Rectangle.init(cx, cy, BLOCK_SIZE, BLOCK_SIZE);
    rl.drawRectangleLinesEx(rect, LINES_THICKNESS, .red);

    const corners = [5]rl.Vector2{ top_left, top_right, bottom_right, bottom_left, top_left };

    var centers: [4]rl.Vector2 = @splat(rl.Vector2.zero());
    for (0..corners.len - 1) |i| {
        centers[i] = corners[i].add(corners[i + 1]).scale(0.5);
    }
    rl.drawLineEx(centers[0], centers[2], LINES_THICKNESS, .red);
    rl.drawLineEx(centers[1], centers[3], LINES_THICKNESS, .red);
}

fn draw_coordientants() void {
    rl.drawLineV(.{ .x = WINDOW_WIDTH / 2, .y = 0 }, .{ .x = WINDOW_WIDTH / 2, .y = WINDOW_HEIGHT }, .white);
    rl.drawLineV(.{ .x = 0, .y = WINDOW_HEIGHT / 2 }, .{ .x = WINDOW_WIDTH, .y = WINDOW_HEIGHT / 2 }, .white);
}

// const io = init.io;
// var stdout_buffer: [1024]u8 = undefined;
// var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
// const stdout_writer = &stdout_file_writer.interface;
// defer stdout_writer.flush() catch |e| std.debug.print("{any}", .{e});
// const arena = init.arena.allocator();

// try zizris.printAnotherMessage(stdout_writer);
