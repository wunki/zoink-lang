const std = @import("std");
const testing = std.testing;

/// TokenType is a set of distinct values that represent the different types of tokens
pub const TokenTypes = enum {
    const Self = @This();

    illegal,
    eof,
    ident,
    int,
    assign,
    plus,
    comma,
    semicolon,
    lparen,
    rparen,
    lbrace,
    rbrace,
    function,
    let,

    /// Determines the token type for a given identifier literal.
    /// If the identifier matches a reserved keyword, the corresponding token type is returned.
    /// Otherwise, it defaults to the 'ident' (identifier) token type.
    pub fn lookup_ident(literal: []const u8) Self {
        // Zig doesn't allow switch statements on runtime string literals, so we are using an
        // if else chain.
        if (std.mem.eql(u8, "fn", literal)) {
            return TokenTypes.function;
        } else if (std.mem.eql(u8, "let", literal)) {
            return TokenTypes.let;
        } else {
            return TokenTypes.ident;
        }
    }
};

/// Token is a struct representing a single lexical token with a specific type and value.
/// It provides functions to initialize new tokens and to determine the token type
/// based on an identifier's literal value.
pub const Token = struct {
    const Self = @This();

    kind: TokenTypes,
    literal: []const u8 = "",

    /// Initializes a new token with the specified type and literal value.
    pub fn init(kind: TokenTypes, literal: []const u8) Self {
        return Self{
            .kind = kind,
            .literal = literal,
        };
    }
};

test "initialize a new literal" {
    const token = Token.init(TokenTypes.plus, "");
    try testing.expectEqual(token.kind, TokenTypes.plus);
}

test "initialize a new identifier" {
    const token = Token.init(TokenTypes.ident, "foo");
    try testing.expectEqual(token.kind, TokenTypes.ident);
    try testing.expectEqual(token.literal, "foo");
}

test "lookup keywords" {
    const typ = TokenTypes.lookup_ident("fn");
    try testing.expectEqual(TokenTypes.function, typ);
}
