const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const token = @import("../token/token.zig");
const Token = token.Token;
const TokenType = token.TokenType;

/// The `Lexer` struct is used for tokenizing a given input string into a sequence of `Token`s.
/// It holds the state necessary for scanning through the input and extracting tokens one by one.
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

    /// Initialize a new Lexer with the given input.
    /// Reads the first character from the input to start the tokenization process.
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

    /// Advances the current character (`current_char`) to the next character in the input
    /// while updating the `position` and `read_position` accordingly.
    /// If the end of the input is reached, `current_char` is set to the null character (0).
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
    /// It skips any whitespace before determining the correct token type based on the current character.
    pub fn next_token(self: *Self) token.Token {
        self.skip_whitespace();

        std.log.warn("current character: {u}", .{self.current_char});

        const t: token.Token = switch (self.current_char) {
            '=' => Token.init(.assign, "="),
            '+' => Token.init(.plus, "+"),
            '-' => Token.init(.minus, "-"),
            '!' => Token.init(.bang, "!"),
            '/' => Token.init(.slash, "/"),
            '*' => Token.init(.asterisk, "*"),
            '<' => Token.init(.lt, "<"),
            '>' => Token.init(.gt, ">"),
            ';' => Token.init(.semicolon, ";"),
            ',' => Token.init(.comma, ","),
            '(' => Token.init(.lparen, "("),
            ')' => Token.init(.rparen, ")"),
            '{' => Token.init(.lbrace, "{"),
            '}' => Token.init(.rbrace, "}"),
            0 => Token.init(.eof, ""),
            else => if (is_letter(self.current_char)) {
                const identifier = self.read_identifier();
                return Token.init(TokenType.lookup_ident(identifier), identifier);
            } else if (is_digit(self.current_char)) {
                const literal = self.read_number();
                return Token.init(.int, literal);
            } else {
                return Token.init(.illegal, "");
            },
        };
        self.read_char();
        return t;
    }

    /// Skips all whitespace characters in the input until a non-whitespace character is reached.
    /// This includes spaces, tabs, carriage returns, and newlines.
    fn skip_whitespace(self: *Self) void {
        while (self.current_char == ' ' or self.current_char == '\t' or self.current_char == '\r' or self.current_char == '\n') {
            self.read_char();
        }
    }

    /// Reads and returns an identifier from the input by advancing the `current_char` until a non-letter character is encountered.
    fn read_identifier(self: *Self) []const u8 {
        const position = self.position;

        while (is_letter(self.current_char)) {
            self.read_char();
        }
        return self.input[position..self.position];
    }

    /// Reads and returns a number from the input by advancing the `current_char` until a non-digit character is encountered.
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

fn is_digit(c: u8) bool {
    return (c >= '0' and c <= '9');
}

test "lexer initialization with single character input" {
    const lexer = try Lexer.init("a");
    try testing.expectEqual(lexer.input, "a");
}

test "is_digit function correctly identifies digits and non-digits" {
    try testing.expect(is_digit('0'));
    try testing.expect(is_digit('5'));
    try testing.expect(is_digit('9'));
    try testing.expect(!is_digit('/')); // Character before '0'
    try testing.expect(!is_digit(':')); // Character after '9'
    try testing.expect(!is_digit('a'));
    try testing.expect(!is_digit(' '));
}

test "lexer correctly tokenizes a sequence of source code" {
    const input =
        \\ let five = 5;
        \\ let ten = 10;
        \\
        \\ let add = fn(x, y) {
        \\   x + y;
        \\ }
        \\
        \\ let result = add(five, ten);
        \\ !-/*5;
        \\ 5 < 10 > 5;
        \\
        \\ if (5 < 10) {
        \\   return true;
        \\ } else {
        \\   return false;
        \\ }
    ;

    const expected_tokens = [_]token.Token{
        Token.init(.let, "let"),
        Token.init(.ident, "five"),
        Token.init(.assign, "="),
        Token.init(.int, "5"),
        Token.init(.semicolon, ";"),
        Token.init(.let, "let"),
        Token.init(.ident, "ten"),
        Token.init(.assign, "="),
        Token.init(.int, "10"),
        Token.init(.semicolon, ";"),
        Token.init(.let, "let"),
        Token.init(.ident, "add"),
        Token.init(.assign, "="),
        Token.init(.function, "fn"),
        Token.init(.lparen, "("),
        Token.init(.ident, "x"),
        Token.init(.comma, ","),
        Token.init(.ident, "y"),
        Token.init(.rparen, ")"),
        Token.init(.lbrace, "{"),
        Token.init(.ident, "x"),
        Token.init(.plus, "+"),
        Token.init(.ident, "y"),
        Token.init(.semicolon, ";"),
        Token.init(.rbrace, "}"),
        Token.init(.let, "let"),
        Token.init(.ident, "result"),
        Token.init(.assign, "="),
        Token.init(.ident, "add"),
        Token.init(.lparen, "("),
        Token.init(.ident, "five"),
        Token.init(.comma, ","),
        Token.init(.ident, "ten"),
        Token.init(.rparen, ")"),
        Token.init(.semicolon, ";"),
        Token.init(.bang, "!"),
        Token.init(.minus, "-"),
        Token.init(.slash, "/"),
        Token.init(.asterisk, "*"),
        Token.init(.int, "5"),
        Token.init(.semicolon, ";"),
        Token.init(.int, "5"),
        Token.init(.lt, "<"),
        Token.init(.int, "10"),
        Token.init(.gt, ">"),
        Token.init(.int, "5"),
        Token.init(.semicolon, ";"),
        Token.init(.eof, ""),
    };

    // Check that each char returns the right token.
    var lexer = try Lexer.init(input);
    for (expected_tokens) |e_t| {
        const t = lexer.next_token();

        try testing.expectEqual(e_t.kind, t.kind);
        try testing.expectEqualSlices(u8, e_t.literal, t.literal);
    }
}
