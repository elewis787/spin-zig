const Headers = @import("headers.zig");
const Method = @import("method.zig");
const Version = @import("version.zig");

pub const Request = struct {
    method: Method,
    headers: Headers,
    path: []const u8,
    query: []const u8,
    body: []const u8,
    version: Version,

    pub fn deinit(self: *Request) void {
        self.headers.deinit();
    }
};
