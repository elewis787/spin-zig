const std = @import("std");
const Status = std.Status;
const Headers = @import("headers.zig");

pub const Reponse = struct {
    status: Status,
    version: Version,
    headers: Headers,
    body: []const u8,

    pub fn deinit(self: *Response) void {
        self.headers.deinit();
    }
};
