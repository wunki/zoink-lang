// TokenType is a set of distinct values that represent the different types of tokens
pub const TokenType = enum {
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
};

// Token is a struct that represents a token in the input
pub const Token = union {
    typ: TokenType,
    data: union {
        int_literal: i64,
        identifier: []const u8,
    },
};
