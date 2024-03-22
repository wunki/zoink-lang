const std = @import("std");

test "run the lexer tests" {
    _ = @import("lexer/lexer.zig");
    _ = @import("token/token.zig");
}
