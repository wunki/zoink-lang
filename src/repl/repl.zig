const std = @import("std");

const Lexer = @import("../lexer/lexer.zig").Lexer;

pub fn init(allocator: std.mem.Allocator) !void {
    const input = try std.io.getStdIn().reader().readUntilDelimiterAlloc(allocator, '\n', 1024);
    defer allocator.free(input);

    var lexer = try Lexer.init(input);
    var token = lexer.next_token();

    while (true) : (token = lexer.next_token()) {
        if (token.kind == .eof) break;
        std.debug.print("token: {}\n", .{token});
    }
}
