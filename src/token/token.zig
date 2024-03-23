const std = @import("std");
const testing = std.testing;

/// TokenType represents different classifications of lexical tokens within the language.
/// It includes both language keywords and syntax tokens. Additional utility is provided
/// by the `lookup_ident` function, which resolves identifiers to their appropriate token types,
/// defaulting to `ident` for user-defined names.
pub const TokenTypes = enum {
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
    /// This function is necessary because Zig does not allow switch statements on runtime string literals.
    /// Instead, an if-else chain is used to compare the provided literal with known keywords.
    pub fn lookup_ident(literal: []const u8) TokenTypes {
        if (std.mem.eql(u8, "fn", literal)) {
            return TokenTypes.function;
        } else if (std.mem.eql(u8, "let", literal)) {
            return TokenTypes.let;
        } else {
            return TokenTypes.ident;
        }
    }
};

/// A Token represents a single lexical token with an associated TokenType and literal value.
/// It encapsulates the details of a token, allowing for easy creation and type determination.
/// The Token struct includes methods to initialize new tokens and to identify the token type
/// for given identifier literals, leveraging the lookup_ident function defined in TokenTypes.
pub const Token = struct {
    const Self = @This();

    kind: TokenTypes,
    literal: []const u8 = "",

    /// Creates a new Token with a specified TokenType and literal value.
    pub fn init(kind: TokenTypes, literal: []const u8) Self {
        return Self{
            .kind = kind,
            .literal = literal,
        };
    }
};

test "initialize a token with plus TokenType" {
    const token = Token.init(TokenTypes.plus, "+");
    try testing.expectEqual(token.kind, TokenTypes.plus);
    try testing.expectEqualSlices(u8, token.literal, "+");
}

test "initialize an identifier token with literal value" {
    const token = Token.init(TokenTypes.ident, "foo");
    try testing.expectEqual(token.kind, TokenTypes.ident);
    try testing.expectEqual(token.literal, "foo");
}

test "lookup_ident returns function TokenType for 'fn' keyword" {
    const typ = TokenTypes.lookup_ident("fn");
    try testing.expectEqual(TokenTypes.function, typ);
}
