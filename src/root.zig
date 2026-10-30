const std = @import("std");
const Io = std.Io;

pub fn printAnotherMessage(writer: *Io.Writer) Io.Writer.Error!void {
    try writer.print("hello from io function", .{});
}
