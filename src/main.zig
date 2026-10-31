const std = @import("std");
const buildin = @import("builtin");
const Io = std.Io;

const zizris = @import("zizris");
const rl = @import("raylib");

const WIDTH_BOXES_CAPACITY = 20;
const HEIGHT_BOXES_CAPACITY = WIDTH_BOXES_CAPACITY * 2;
const WINDOW_WIDTH = 400;
const WINDOW_HEIGHT = WINDOW_WIDTH * 2;
const SINGLE_BOX_SIZE = WINDOW_WIDTH / WIDTH_BOXES_CAPACITY;
const BLOCK_SIZE = SINGLE_BOX_SIZE * 2;
const LINES_THICKNESS = 3;

const Orientation = enum {
    Vertical,
    Horizontal,

    fn next(self: Orientation) Orientation {
        switch (self) {
            .Vertical => {
                return .Horizontal;
            },
            .Horizontal => {
                return .Vertical;
            },
        }
    }
};

const Direction = enum {
    Up,
    Down,
    Right,
    Left,

    fn next(self: Direction) Direction {
        switch (self) {
            .Up => {
                return .Left;
            },
            .Left => {
                return .Down;
            },
            .Down => {
                return .Right;
            },
            .Right => {
                return .Up;
            },
        }
    }
};

const Tetrominoes = union(enum) {
    O,
    I: Orientation,
    Z: Orientation,
    L: Direction,
    T: Direction,
    fn next(self: *Tetrominoes) void {
        switch (self.*) {
            .I => |orien| {
                self.* = orien.next();
            },
            .Z => |orien| {
                self.* = orien.next();
            },
            .L => |dir| {
                self.* = dir.next();
            },
            .T => |dir| {
                self.* = dir.next();
            },
            .O => {},
        }
    }

    fn height(self: Tetrominoes) u8 {
        switch (self) {
            .O => {
                return 2;
            },
            .Z => |orien| {
                return switch (orien) {
                    .Vertical => 3,
                    .Horizontal => 2,
                };
            },
            .I => |orien| {
                return switch (orien) {
                    .Vertical => 3,
                    .Horizontal => 2,
                };
            },
            .L => |dir| {
                return switch (dir) {
                    .Up, .Down => 3,
                    .Right, .Left => 2,
                };
            },
            .T => |dir| {
                return switch (dir) {
                    .Up, .Down => 3,
                    .Right, .Left => 2,
                };
            },
        }
    }
};

const VecedTetris = struct {
    position: rl.Vector2 = .init((WINDOW_WIDTH / WIDTH_BOXES_CAPACITY) / 2, -1),
    tetrominoes: Tetrominoes = .O,
};

const State = struct {
    user_closed_the_window: bool = false,
    time_instant_in_seconds: f64 = 0,
    moving_tetris: VecedTetris = .{},
    static_tetris: std.ArrayList(VecedTetris),
};

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();

    rl.initWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "Zizris (a tetris game in zig)");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var state: State = .{ .static_tetris = try .initCapacity(arena, 100) };

    while (!rl.windowShouldClose() and !state.user_closed_the_window) {
        handle_events(&state);

        rl.beginDrawing();
        defer rl.endDrawing();

        try draw(&state, arena);
    }
}

fn handle_events(state: *State) void {
    if (rl.isKeyDown(.left_control) and rl.isKeyPressed(.q)) {
        state.user_closed_the_window = true;
    }
    if (rl.isKeyPressed(.left)) {
        state.moving_tetris.position.x -= 1;
    }
    if (rl.isKeyPressed(.right)) {
        state.moving_tetris.position.x += 1;
    }
}

fn draw(state: *State, allocator: std.mem.Allocator) !void {
    rl.clearBackground(.black);

    if (buildin.mode == .debug) {
        draw_coordientants();
    }

    draw_shape(state.moving_tetris.position, state.moving_tetris.tetrominoes);
    if (state.moving_tetris.position.y == HEIGHT_BOXES_CAPACITY - state.moving_tetris.tetrominoes.height()) {
        try state.static_tetris.append(allocator, state.moving_tetris);
        state.moving_tetris = .{};
    } else if (rl.getTime() - state.time_instant_in_seconds > 0.5) {
        state.moving_tetris.position.y += 1;
        state.time_instant_in_seconds = rl.getTime();
    }
}

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
        .L => |dir| {
            switch (dir) {
                .Up => {
                    block(grid_pos);
                    block(grid_pos.add(.{ .x = 0, .y = 1 }));
                    block(grid_pos.add(.{ .x = 0, .y = 2 }));
                    block(grid_pos.add(.{ .x = 1, .y = 2 }));
                },
                .Down => {
                    block(grid_pos);
                    block(grid_pos.add(.{ .x = 1, .y = 0 }));
                    block(grid_pos.add(.{ .x = 1, .y = 1 }));
                    block(grid_pos.add(.{ .x = 1, .y = 2 }));
                },
                .Left => {
                    block(grid_pos);
                    block(grid_pos.add(.{ .x = 1, .y = 0 }));
                    block(grid_pos.add(.{ .x = 2, .y = 0 }));

                    block(grid_pos.add(.{ .x = 0, .y = 1 }));
                },
                .Right => {
                    block(grid_pos);
                    block(grid_pos.add(.{ .x = 0, .y = 1 }));

                    block(grid_pos.add(.{ .x = -1, .y = 1 }));
                    block(grid_pos.add(.{ .x = -2, .y = 1 }));
                },
            }
        },
        .T => |dir| {
            block(grid_pos);
            switch (dir) {
                .Left => {
                    block(grid_pos.add(.{ .x = 0, .y = 1 }));
                    block(grid_pos.add(.{ .x = 0, .y = 2 }));
                    block(grid_pos.add(.{ .x = -1, .y = 1 }));
                },
                .Right => {
                    block(grid_pos.add(.{ .x = 0, .y = 1 }));
                    block(grid_pos.add(.{ .x = 0, .y = 2 }));
                    block(grid_pos.add(.{ .x = 1, .y = 1 }));
                },
                .Up => {
                    block(grid_pos.add(.{ .x = 1, .y = 0 }));
                    block(grid_pos.add(.{ .x = 2, .y = 0 }));
                    block(grid_pos.add(.{ .x = 1, .y = -1 }));
                },
                .Down => {
                    block(grid_pos.add(.{ .x = 1, .y = 0 }));
                    block(grid_pos.add(.{ .x = 2, .y = 0 }));
                    block(grid_pos.add(.{ .x = 1, .y = 1 }));
                },
            }
        },
        .Z => |orientation| {
            switch (orientation) {
                .Vertical => {
                    block(grid_pos);
                    block(grid_pos.add(.{ .x = 0, .y = 1 }));
                    block(grid_pos.add(.{ .x = 1, .y = 1 }));
                    block(grid_pos.add(.{ .x = 1, .y = 2 }));
                },
                .Horizontal => {
                    block(grid_pos);
                    block(grid_pos.add(.{ .x = 1, .y = 0 }));
                    block(grid_pos.add(.{ .x = 1, .y = 1 }));
                    block(grid_pos.add(.{ .x = 2, .y = 1 }));
                },
            }
        },
    }
}

fn draw_coordientants() void {
    rl.drawLineV(.{ .x = WINDOW_WIDTH / 2, .y = 0 }, .{ .x = WINDOW_WIDTH / 2, .y = WINDOW_HEIGHT }, .white);
    rl.drawLineV(.{ .x = 0, .y = WINDOW_HEIGHT / 2 }, .{ .x = WINDOW_WIDTH, .y = WINDOW_HEIGHT / 2 }, .white);
}
