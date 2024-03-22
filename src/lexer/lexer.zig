const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const token = @import("../token/token.zig");
const Token = token.Token;
const TokenTypes = token.TokenTypes;

pub const Lexer = struct {
    const Self = @This();

    /// The raw input.
    input: []const u8,
    /// Current position in input (points to the current char).
    position: u8,
    /// Current reading position in input (after the current char).
    read_position: u8,
    /// Current char under examination.
    current_char: u8,

    /// Initialize a new Lexer.
    pub fn init(input: []const u8) !Self {
        var lexer = Self{
            .input = input,
            .position = 0,
            .read_position = 0,
            .current_char = undefined,
        };
        // Read in the first character.
        lexer.read_char();
        return lexer;
    }

    /// Advances the current character (`ch`) to the next character in the input
    /// while updating the `position` and `read_position` accordingly.
    /// If the end of the input is reached, `ch` is set to the null character (0).
    fn read_char(self: *Self) void {
        if (self.read_position >= self.input.len) {
            self.current_char = 0;
        } else {
            self.current_char = self.input[self.read_position];
            self.position = self.read_position;
            self.read_position += 1;
        }
    }

    /// Returns the next token from the input.
    pub fn next_token(self: *Self) token.Token {
        self.skip_whitespace();

        std.log.warn("evaluating character: {c}", .{self.current_char});

        const t: token.Token = switch (self.current_char) {
            '=' => Token.init(TokenTypes.assign, "="),
            ';' => Token.init(TokenTypes.semicolon, ";"),
            '(' => Token.init(TokenTypes.lparen, "("),
            ')' => Token.init(TokenTypes.rparen, ")"),
            ',' => Token.init(TokenTypes.comma, ","),
            '+' => Token.init(TokenTypes.plus, "+"),
            '{' => Token.init(TokenTypes.lbrace, "{"),
            '}' => Token.init(TokenTypes.rbrace, "}"),
            0 => Token.init(TokenTypes.eof, ""),
            else => if (is_letter(self.current_char)) {
                const identifier = self.read_identifier();
                return Token.init(TokenTypes.lookup_ident(identifier), identifier);
            } else if (is_digit(self.current_char)) {
                const literal = self.read_number();
                return Token.init(TokenTypes.int, literal);
            } else {
                return Token.init(TokenTypes.illegal, "");
            },
        };
        self.read_char();
        return t;
    }

    /// Skips all whitespace characters.
    fn skip_whitespace(self: *Self) void {
        while (self.current_char == ' ' or self.current_char == '\t' or self.current_char == '\r' or self.current_char == '\n') {
            self.read_char();
        }
    }

    /// Returns the entire identifier by reading a char at a time.
    fn read_identifier(self: *Self) []const u8 {
        const position = self.position;

        while (is_letter(self.current_char)) {
            self.read_char();
        }
        return self.input[position..self.position];
    }

    /// Reads the entire number a char at a time.
    fn read_number(self: *Self) []const u8 {
        const position = self.position;
        while (is_digit(self.current_char)) {
            self.read_char();
        }
        return self.input[position..self.position];
    }
};

/// Determines if a given character is a letter.
/// This function checks if the character falls within the range of
/// alphabetic ASCII characters, i.e., 'a' to 'z' or 'A' to 'Z'.
fn is_letter(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z');
}

/// Determines if the given character is a digit.
fn is_digit(c: u8) bool {
    return (c <= '0') or (c <= '9');
}

test "initializing a new lexer" {
    const lexer = try Lexer.init("a");
    try testing.expectEqual(lexer.input, "a");
}

test "lexer returns the next token" {
    const input =
        \\ let five = 5;
        \\ let ten = 10;
        \\
        \\ let add = fn(x, y) {
        \\   x + y;
        \\ }
        \\
        \\ let result = add(five, ten);
    ;

    const expected_tokens = [_]token.Token{
        Token.init(TokenTypes.let, "let"),
        Token.init(TokenTypes.ident, "five"),
        Token.init(TokenTypes.assign, "="),
        Token.init(TokenTypes.int, "5"),
        Token.init(TokenTypes.semicolon, ";"),
        Token.init(TokenTypes.let, "let"),
        Token.init(TokenTypes.ident, "ten"),
        Token.init(TokenTypes.assign, "="),
        Token.init(TokenTypes.int, "10"),
        Token.init(TokenTypes.semicolon, ";"),
        Token.init(TokenTypes.let, "let"),
        Token.init(TokenTypes.ident, "add"),
        Token.init(TokenTypes.assign, "="),
        Token.init(TokenTypes.function, "fn"),
        Token.init(TokenTypes.lparen, "("),
        Token.init(TokenTypes.ident, "x"),
        Token.init(TokenTypes.comma, ","),
        Token.init(TokenTypes.ident, "y"),
        Token.init(TokenTypes.rparen, ")"),
        Token.init(TokenTypes.lbrace, "{"),
        Token.init(TokenTypes.ident, "x"),
        Token.init(TokenTypes.plus, "+"),
        Token.init(TokenTypes.ident, "y"),
        Token.init(TokenTypes.semicolon, ";"),
        Token.init(TokenTypes.rbrace, "}"),
        Token.init(TokenTypes.let, "let"),
        Token.init(TokenTypes.ident, "result"),
        Token.init(TokenTypes.assign, "="),
        Token.init(TokenTypes.ident, "add"),
        Token.init(TokenTypes.lparen, "("),
        Token.init(TokenTypes.ident, "five"),
        Token.init(TokenTypes.comma, ","),
        Token.init(TokenTypes.ident, "ten"),
        Token.init(TokenTypes.rparen, ")"),
        Token.init(TokenTypes.semicolon, ";"),
        Token.init(TokenTypes.eof, ""),
    };

    // Check that each char returns the right token.
    var lexer = try Lexer.init(input);
    for (expected_tokens) |e_t| {
        const t = lexer.next_token();

        try testing.expectEqual(e_t.kind, t.kind);
        try testing.expectEqualSlices(u8, e_t.literal, t.literal);
    }
}
