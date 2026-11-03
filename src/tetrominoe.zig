const rl = @import("raylib");
const std = @import("std");
const ziz = @import("main.zig");

pub const Tetrominoe = [4]ziz.Vector;
pub const TetrominoesVarients = [4]Tetrominoe;
/// X
/// X
/// X X
const L_Tetrominoe1: Tetrominoe = .{
    .{ 0, 0 },
    .{ 0, 1 },
    .{ 0, 2 },
    .{ 1, 2 },
};
/// X X X
/// X
const L_Tetrominoe2: Tetrominoe = .{
    .{ 0, 0 },
    .{ 0, 1 },
    .{ 1, 0 },
    .{ 2, 0 },
};
/// X X
///   X
///   X
const L_Tetrominoe3: Tetrominoe = .{
    .{ 0, 0 },
    .{ 1, 0 },
    .{ 1, 1 },
    .{ 1, 2 },
};
///    X
///X X X
const L_Tetrominoe4: Tetrominoe = .{
    .{ 2, 0 },
    .{ 2, 1 },
    .{ 1, 1 },
    .{ 0, 1 },
};
pub const L_Tetrominoe: TetrominoesVarients = .{
    L_Tetrominoe1,
    L_Tetrominoe2,
    L_Tetrominoe3,
    L_Tetrominoe4,
};

/// . X
/// . X
/// X X
const J_Tetrominoe1: Tetrominoe = .{
    .{ 1, 0 },
    .{ 1, 1 },
    .{ 0, 2 },
    .{ 1, 2 },
};
/// X . .
/// X X X
const J_Tetrominoe2: Tetrominoe = .{
    .{ 0, 0 },
    .{ 0, 1 },
    .{ 1, 1 },
    .{ 2, 1 },
};
/// X X
/// X .
/// X .
const J_Tetrominoe3: Tetrominoe = .{
    .{ 0, 0 },
    .{ 0, 1 },
    .{ 0, 2 },
    .{ 1, 0 },
};
/// X X X
/// . . X
const J_Tetrominoe4: Tetrominoe = .{
    .{ 0, 0 },
    .{ 1, 0 },
    .{ 2, 0 },
    .{ 2, 1 },
};
pub const J_Tetrominoe: TetrominoesVarients = .{
    J_Tetrominoe1,
    J_Tetrominoe2,
    J_Tetrominoe3,
    J_Tetrominoe4,
};

/// X X X
/// . X .
const T_Tetrominoe1: Tetrominoe = .{
    .{ 0, 0 },
    .{ 1, 0 },
    .{ 2, 0 },
    .{ 1, 1 },
};
/// . X
/// X X
/// . X
const T_Tetrominoe2: Tetrominoe = .{
    .{ 1, 0 },
    .{ 0, 1 },
    .{ 1, 1 },
    .{ 1, 2 },
};
/// . X .
/// X X X
const T_Tetrominoe3: Tetrominoe = .{
    .{ 1, 0 },
    .{ 0, 1 },
    .{ 1, 1 },
    .{ 2, 1 },
};
/// X .
/// X X
/// X .
const T_Tetrominoe4: Tetrominoe = .{
    .{ 0, 0 },
    .{ 0, 1 },
    .{ 1, 1 },
    .{ 0, 2 },
};
pub const T_Tetrominoe: TetrominoesVarients = .{
    T_Tetrominoe1,
    T_Tetrominoe2,
    T_Tetrominoe3,
    T_Tetrominoe4,
};

/// X X .
/// . X X
const Z_Tetrominoe13: Tetrominoe = .{
    .{ 0, 0 },
    .{ 1, 0 },
    .{ 1, 1 },
    .{ 2, 1 },
};
/// . X
/// X X
/// X .
const Z_Tetrominoe24: Tetrominoe = .{
    .{ 1, 0 },
    .{ 0, 1 },
    .{ 1, 1 },
    .{ 0, 2 },
};
pub const Z_Tetrominoe: TetrominoesVarients = .{
    Z_Tetrominoe13,
    Z_Tetrominoe24,
    Z_Tetrominoe13,
    Z_Tetrominoe24,
};

/// . X X
/// X X .
const S_Tetrominoe13: Tetrominoe = .{
    .{ 1, 0 },
    .{ 2, 0 },
    .{ 0, 1 },
    .{ 1, 1 },
};
/// X .
/// X X
/// . X
const S_Tetrominoe24: Tetrominoe = .{
    .{ 0, 0 },
    .{ 0, 1 },
    .{ 1, 1 },
    .{ 1, 2 },
};
pub const S_Tetrominoe: TetrominoesVarients = .{
    S_Tetrominoe13,
    S_Tetrominoe24,
    S_Tetrominoe13,
    S_Tetrominoe24,
};
/// X X
/// X X
const O_Tetrominoe1234: Tetrominoe = .{
    .{ 0, 0 },
    .{ 0, 1 },
    .{ 1, 0 },
    .{ 1, 1 },
};
pub const O_Tetrominoe: TetrominoesVarients = .{
    O_Tetrominoe1234,
    O_Tetrominoe1234,
    O_Tetrominoe1234,
    O_Tetrominoe1234,
};
const I_Tetrominoe13: Tetrominoe = .{
    .{ 0, 0 },
    .{ 0, 1 },
    .{ 0, 2 },
    .{ 0, 3 },
};
const I_Tetrominoe24: Tetrominoe = .{
    .{ 0, 0 },
    .{ 1, 0 },
    .{ 2, 0 },
    .{ 3, 0 },
};
pub const I_Tetrominoe: TetrominoesVarients = .{
    I_Tetrominoe13,
    I_Tetrominoe24,
    I_Tetrominoe13,
    I_Tetrominoe24,
};

pub const TetrominoesKind = enum {
    O,
    I,
    Z,
    L,
    T,
    S,
    J,
};

fn array_max(comptime T: type, array: [4]T) T {
    var result: T = 0;
    for (array) |x| {
        result = @max(x, result);
    }
    return result;
}

pub const Tetrominoes = struct {
    kind: TetrominoesKind = .O,
    varient_index: u2 = 0,

    fn get_all_varients(self: *const Tetrominoes) *const TetrominoesVarients {
        return switch (self.kind) {
            .O => &O_Tetrominoe,
            .I => &I_Tetrominoe,
            .Z => &Z_Tetrominoe,
            .L => &L_Tetrominoe,
            .T => &T_Tetrominoe,
            .S => &S_Tetrominoe,
            .J => &J_Tetrominoe,
        };
    }
    pub fn get_choosed_varient(self: *const Tetrominoes) *const Tetrominoe {
        return &self.get_all_varients()[self.varient_index];
    }
    pub fn get_choosed_varient_at(self: *const Tetrominoes, position: ziz.Vector) Tetrominoe {
        var result: Tetrominoe = @splat(.{ 0, 0 });
        for (self.get_choosed_varient(), 0..) |x, i| {
            result[i] = x + position;
        }
        return result;
    }

    pub fn get_lowest_blocks_at(
        self: *const Tetrominoes,
        position: ziz.Vector,
    ) [4]?ziz.Vector {
        var grid: [4]struct { touched: bool, column: [4]f32 } = @splat(.{ .touched = false, .column = @splat(0) });
        var grid_y_tracker: [4]usize = @splat(0);
        for (self.get_choosed_varient()) |varient_block| {
            const i: usize = @trunc(varient_block[ziz.X]);
            grid[i].column[grid_y_tracker[i]] = varient_block[ziz.Y];
            grid[i].touched = true;
            grid_y_tracker[i] += 1;
        }

        var result: [4]?ziz.Vector = @splat(null);
        for (grid, 0..) |val, i| {
            const max = array_max(f32, val.column);
            if (val.touched) {
                result[i] = ziz.Vector{
                    @floatFromInt(i),
                    max,
                } + position;
            }
        }
        return result;
    }

    pub fn height(self: Tetrominoes) f32 {
        const xs = self.get_choosed_varient();
        return @max(
            xs[0][ziz.Y],
            xs[1][ziz.Y],
            xs[2][ziz.Y],
            xs[3][ziz.Y],
        );
    }

    pub fn width(self: Tetrominoes) f32 {
        const xs = self.get_choosed_varient();
        return @max(
            xs[0][ziz.X],
            xs[1][ziz.X],
            xs[2][ziz.X],
            xs[3][ziz.X],
        );
    }
    pub fn width_at(self: Tetrominoes, position: ziz.Vector) f32 {
        const xs = self.get_choosed_varient_at(position);
        return @max(
            xs[0][ziz.X],
            xs[1][ziz.X],
            xs[2][ziz.X],
            xs[3][ziz.X],
        );
    }
};
