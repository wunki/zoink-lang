const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const token = @import("../token/token.zig");

pub const Lexer = struct {
    const Self = @This();

    // The raw input.
    input: []const u8,
    // Current position in input (points to the current char).
    position: u8,
    // Current reading position in input (after the current char).
    read_position: u8,
    // Current char under examination.
    ch: u8,

    // Initialize a new Lexer.
    pub fn init(input: []const u8) !Self {
        var lexer = Lexer{
            .input = input,
            .position = 0,
            .read_position = 0,
            .ch = undefined,
        };
        // Read in the first character.
        lexer.read_char();
        return lexer;
    }

    // Give us the next char and advance the position in the
    // input string.
    fn read_char(self: *Self) void {
        if (self.read_position >= self.input.len) {
            self.ch = undefined;
        } else {
            self.ch = self.input[self.read_position];
            self.read_position += 1;
        }
    }

    pub fn next_token(self: *Self) token.Token {
        const t: token.Token = switch (self.ch) {
            '=' => .{ .typ = token.TokenType.assign },
            ';' => .{ .typ = token.TokenType.semicolon },
            '(' => .{ .typ = token.TokenType.lparen },
            ')' => .{ .typ = token.TokenType.rparen },
            ',' => .{ .typ = token.TokenType.comma },
            '+' => .{ .typ = token.TokenType.plus },
            '{' => .{ .typ = token.TokenType.lbrace },
            '}' => .{ .typ = token.TokenType.rbrace },
            else => .{ .typ = token.TokenType.illegal },
        };
        self.read_char();
        return t;
    }
};

test "initializing a new lexer" {
    const lexer = try Lexer.init("a");
    try testing.expectEqual(lexer.input, "a");
}

test "lexer returns the next token" {
    const input = "=+(){},;";
    const output = [_]token.Token{
        .{ .typ = token.TokenType.assign },
        .{ .typ = token.TokenType.plus },
        .{ .typ = token.TokenType.lparen },
        .{ .typ = token.TokenType.rparen },
        .{ .typ = token.TokenType.lbrace },
        .{ .typ = token.TokenType.rbrace },
        .{ .typ = token.TokenType.comma },
        .{ .typ = token.TokenType.semicolon },
    };

    // Don't even try to run the tests if the output is not equal to the input.
    assert(input.len == output.len);

    // Check that each char returns the right token.
    var lexer = try Lexer.init(input);
    for (input, 0..) |_, index| {
        const t = lexer.next_token();

        const expected: token.Token = output[index];
        try testing.expectEqual(t.typ, expected.typ);
    }
}
