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

    draw_coordientants();

    draw_shape(.{ .x = 0, .y = 0 }, .O);
    draw_shape(.{ .x = 2, .y = 2 }, .O);

    draw_shape(.{ .x = 4, .y = 4 }, .{ .I = .Horizontal });
    draw_shape(.{ .x = 8, .y = 5 }, .{ .I = .Horizontal });

    draw_shape(.{ .x = 12, .y = 6 }, .{ .I = .Vertical });
    draw_shape(.{ .x = 13, .y = 10 }, .{ .I = .Vertical });

    draw_shape(.{ .x = 14, .y = 14 }, .{ .L = .Up });
    draw_shape(.{ .x = 16, .y = 17 }, .{ .L = .Up });

    draw_shape(.{ .x = 14, .y = 20 }, .{ .J = .Up });
    draw_shape(.{ .x = 12, .y = 23 }, .{ .J = .Up });

    draw_shape(.{ .x = 9, .y = 26 }, .{ .T = .Up });

    draw_shape(.{ .x = 6, .y = 29 }, .{ .Z = .Horizontal });
}

const Orientation = enum {
    Vertical,
    Horizontal,
};

const Direction = enum {
    Up,
    Down,
    Right,
    Left,
};

const Tetrominoes = union(enum) { O, I: Orientation, Z: Orientation, L: Direction, J: Direction, T: Direction };

fn block(grid_pos: rl.Vector2) void {
    const pos = grid_pos.scale(SINGLE_BOX_SIZE);
    rl.drawRectangleV(pos, .{ .x = SINGLE_BOX_SIZE, .y = SINGLE_BOX_SIZE }, .white);
    const rect = rl.Rectangle.init(pos.x, pos.y, SINGLE_BOX_SIZE, SINGLE_BOX_SIZE);
    rl.drawRectangleLinesEx(rect, LINES_THICKNESS, .red);
}

fn draw_shape(grid_pos: rl.Vector2, shape: Tetrominoes) void {
    switch (shape) {
        .O => {
            block(grid_pos);
            block(grid_pos.add(.{ .x = 1, .y = 0 }));
            block(grid_pos.add(.{ .x = 0, .y = 1 }));
            block(grid_pos.add(.{ .x = 1, .y = 1 }));
        },
        .I => |orientation| {
            block(grid_pos);
            switch (orientation) {
                .Vertical => {
                    block(grid_pos.add(.{ .x = 0, .y = 1 }));
                    block(grid_pos.add(.{ .x = 0, .y = 2 }));
                    block(grid_pos.add(.{ .x = 0, .y = 3 }));
                },
                .Horizontal => {
                    block(grid_pos.add(.{ .x = 1, .y = 0 }));
                    block(grid_pos.add(.{ .x = 2, .y = 0 }));
                    block(grid_pos.add(.{ .x = 3, .y = 0 }));
                },
            }
        },
        .L => {
            block(grid_pos);
            block(grid_pos.add(.{ .x = 0, .y = 1 }));
            block(grid_pos.add(.{ .x = 0, .y = 2 }));
            block(grid_pos.add(.{ .x = 1, .y = 2 }));
        },
        .J => {
            block(grid_pos.add(.{ .x = 1, .y = 0 }));
            block(grid_pos.add(.{ .x = 1, .y = 1 }));
            block(grid_pos.add(.{ .x = 1, .y = 2 }));
            block(grid_pos.add(.{ .x = 0, .y = 2 }));
        },
        .T => {
            block(grid_pos);
            block(grid_pos.add(.{ .x = 1, .y = 0 }));
            block(grid_pos.add(.{ .x = 2, .y = 0 }));
            block(grid_pos.add(.{ .x = 1, .y = 1 }));
        },
        .Z => {
            block(grid_pos);
            block(grid_pos.add(.{ .x = 1, .y = 0 }));
            block(grid_pos.add(.{ .x = 1, .y = 1 }));
            block(grid_pos.add(.{ .x = 2, .y = 1 }));
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
