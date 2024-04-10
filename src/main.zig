const std = @import("std");
const repl = @import("repl/repl.zig");

pub fn main() !void {
    std.debug.print("welcome to zoink lang!\n", .{});

    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gp.allocator();

    while (true) {
        try repl.init(gpa);
    }
}
