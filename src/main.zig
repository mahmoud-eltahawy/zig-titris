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
    // rl.drawText("hello world", WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 26, .white);

    draw_coordientants();
    draw_shape(.{ .x = 0, .y = 0 }, .OBlock);
    draw_shape(.{ .x = 2, .y = 2 }, .OBlock);

    draw_shape(.{ .x = 4, .y = 4 }, .HIBlock);
    draw_shape(.{ .x = 8, .y = 5 }, .HIBlock);

    draw_shape(.{ .x = 12, .y = 6 }, .VIBlock);
    draw_shape(.{ .x = 13, .y = 10 }, .VIBlock);
}

const Shape = enum {
    OBlock,
    HIBlock,
    VIBlock,
};

fn draw_shape(grid_pos: rl.Vector2, shape: Shape) void {
    const pos = grid_pos.add(.{ .x = 1, .y = 1 }).scale(SINGLE_BOX_SIZE);
    const cx = pos.x - SINGLE_BOX_SIZE;
    const cy = pos.y - SINGLE_BOX_SIZE;
    const x: i32 = @trunc(cx);
    const y: i32 = @trunc(cy);

    switch (shape) {
        .OBlock => {
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
        },
        .HIBlock => {
            const top_left: rl.Vector2 = .{ .x = cx, .y = cy };
            const top_right: rl.Vector2 = .{ .x = cx + SINGLE_BOX_SIZE * 4, .y = cy };
            const bottom_right: rl.Vector2 = .{ .x = cx + SINGLE_BOX_SIZE * 4, .y = cy + SINGLE_BOX_SIZE };
            const bottom_left: rl.Vector2 = .{ .x = cx, .y = cy + SINGLE_BOX_SIZE };

            rl.drawRectangle(x, y, BLOCK_SIZE * 2, SINGLE_BOX_SIZE, .white);
            const rect = rl.Rectangle.init(cx, cy, BLOCK_SIZE * 2, SINGLE_BOX_SIZE);
            rl.drawRectangleLinesEx(rect, LINES_THICKNESS, .red);

            const top_center = top_left.add(top_right).scale(0.5);
            const bottom_center = bottom_left.add(bottom_right).scale(0.5);

            const top_left_center = top_left.add(top_center).scale(0.5);
            const bottom_left_center = bottom_left.add(bottom_center).scale(0.5);

            const top_right_center = top_right.add(top_center).scale(0.5);
            const bottom_right_center = bottom_right.add(bottom_center).scale(0.5);

            rl.drawLineEx(top_center, bottom_center, LINES_THICKNESS, .red);
            rl.drawLineEx(top_left_center, bottom_left_center, LINES_THICKNESS, .red);
            rl.drawLineEx(top_right_center, bottom_right_center, LINES_THICKNESS, .red);
        },
        .VIBlock => {
            const top_left: rl.Vector2 = .{ .x = cx, .y = cy };
            const top_right: rl.Vector2 = .{ .x = cx + SINGLE_BOX_SIZE, .y = cy };
            const bottom_right: rl.Vector2 = .{ .x = cx + SINGLE_BOX_SIZE, .y = cy + BLOCK_SIZE * 2 };
            const bottom_left: rl.Vector2 = .{ .x = cx, .y = cy + BLOCK_SIZE * 2 };

            rl.drawRectangle(x, y, SINGLE_BOX_SIZE, BLOCK_SIZE * 2, .white);
            const rect = rl.Rectangle.init(cx, cy, SINGLE_BOX_SIZE, BLOCK_SIZE * 2);
            rl.drawRectangleLinesEx(rect, LINES_THICKNESS, .red);

            const left_center = top_left.add(bottom_left).scale(0.5);
            const right_center = top_right.add(bottom_right).scale(0.5);

            const left_top_center = top_left.add(left_center).scale(0.5);
            const right_top_center = top_right.add(right_center).scale(0.5);

            const left_bottom_center = bottom_left.add(left_center).scale(0.5);
            const right_bottom_center = bottom_right.add(right_center).scale(0.5);

            rl.drawLineEx(left_center, right_center, LINES_THICKNESS, .red);
            rl.drawLineEx(left_top_center, right_top_center, LINES_THICKNESS, .red);
            rl.drawLineEx(left_bottom_center, right_bottom_center, LINES_THICKNESS, .red);
        },
    }
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
