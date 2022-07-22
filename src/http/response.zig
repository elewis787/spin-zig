const std = @import("std");
const Allocator = std.mem.Allocator;
const Status = @import("std").http.Status;
const http = @import("http.zig");
const Headers = http.Headers;
const Version = http.Version;

const Bytes = std.ArrayList(u8); // []u8 slice
                                    // [_]u8 

pub const WriteError = error{OutOfMemory};

pub const Response = struct {
    status: Status = Status.ok,
    version: Version,
    headers: Headers,
    body: Bytes,
    content_length: i64,

    /// arena allocator that frees everything when response has been sent
    allocator: Allocator,

    pub fn initCapacity(allocator: Allocator, buffer_size: usize, max_headers: usize) !Response {
        //TODO use max_headers in Headers init 
        _ = max_headers;
        return Response{
            .allocator = allocator,
            .version = undefined,
            .headers = Headers.init(allocator),
            .body = try Bytes.initCapacity(allocator, buffer_size),
            .content_length = undefined,
        };
    }

    pub fn deinit(self: *Response) void {
        self.headers.deinit();
        self.body.deinit();
    }
};

pub const ResponseWriter = struct {
    response: Response,

    pub fn initCapacity(allocator: Allocator, buffer_size: usize, max_headers: usize) !ResponseWriter {
        //TODO use max_headers in Headers init 
        _ = max_headers;
        return ResponseWriter{
            .response = try Response.initCapacity(allocator,buffer_size,max_headers)
        };
    }

    pub fn deinit(self: *ResponseWriter) void {
        self.response.deinit();
    }

    pub fn status(self: *ResponseWriter, s: Status) void {
        self.response.status = s;
    }

    pub fn write(self: *ResponseWriter, bytes: []const u8) WriteError!usize {
        try self.response.body.appendSlice(bytes);
        return bytes.len;
    }
};
