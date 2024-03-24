const std = @import("std");
const testing = std.testing;

const CompTimeStringMap = std.ComptimeStringMap;

const keywords_map = CompTimeStringMap(TokenType, .{
    .{ "fn", .function },
    .{ "let", .let },
});

/// TokenType represents different classifications of lexical tokens within the language.
/// It includes both language keywords and syntax tokens. Additional utility is provided
/// by the `lookup_ident` function, which resolves identifiers to their appropriate token types,
/// defaulting to `ident` for user-defined names.
pub const TokenType = enum {
    // Special tokens
    illegal,
    eof,

    // Identifiers and literals
    ident,
    int,

    // Operators
    assign,
    plus,
    minus,
    bang,
    asterisk,
    slash,
    lt,
    gt,

    // Delimiters
    comma,
    semicolon,
    lparen,
    rparen,
    lbrace,
    rbrace,

    // Keywords
    function,
    let,

    /// Determines the token type for a given identifier literal.
    /// If the identifier matches a reserved keyword, the corresponding token type is returned.
    /// Otherwise, it defaults to the 'ident' (identifier) token type.
    /// This function is necessary because Zig does not allow switch statements on runtime string literals.
    /// Instead, an if-else chain is used to compare the provided literal with known keywords.
    pub fn lookup_ident(literal: []const u8) TokenType {
        if (keywords_map.get(literal)) |typ| {
            return typ;
        } else {
            return .ident;
        }
    }
};

/// A Token represents a single lexical token with an associated TokenType and literal value.
/// It encapsulates the details of a token, allowing for easy creation and type determination.
/// The Token struct includes methods to initialize new tokens and to identify the token type
/// for given identifier literals, leveraging the lookup_ident function defined in TokenTypes.
pub const Token = struct {
    const Self = @This();

    kind: TokenType,
    literal: []const u8 = "",

    /// Creates a new Token with a specified TokenType and literal value.
    pub fn init(kind: TokenType, literal: []const u8) Self {
        return Self{
            .kind = kind,
            .literal = literal,
        };
    }
};

test "initialize a token with plus TokenType" {
    const token = Token.init(TokenType.plus, "+");
    try testing.expectEqual(token.kind, TokenType.plus);
    try testing.expectEqualSlices(u8, token.literal, "+");
}

test "initialize an identifier token with literal value" {
    const token = Token.init(TokenType.ident, "foo");
    try testing.expectEqual(token.kind, TokenType.ident);
    try testing.expectEqual(token.literal, "foo");
}

test "lookup_ident returns function TokenType for 'fn' keyword" {
    const typ = TokenType.lookup_ident("fn");
    try testing.expectEqual(TokenType.function, typ);
}
