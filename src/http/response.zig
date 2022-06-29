const Status = @import("status.zig");
const Headers = @import("headers.zig");
const Version = @import("version.zig");


pub const Response = struct {
    status: Status,
    version: Version,
    headers: Headers,
    body: []const u8,

    pub fn deinit(self: *Response) void {
        self.headers.deinit();
    }
};
