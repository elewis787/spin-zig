const http = @import("./http/http.zig");
const Request = http.Request;
const Response = http.Response;
const std = @import("std");

pub const HandlerFn = fn handle(*Request, *Response) void;

comptime var handler = defaultHandler;

pub fn defaultHandler(req: *Request, res: *Response) void {
    _ = req;
    _ = res;
    res.status = std.http.Status.service_unavailable;
    std.debug.print("http handler undefined\n", .{});
}

pub fn handle(comptime h: HandlerFn) void {
    comptime {
        handler = h;
    }
}
