const http = @import("http");
const Request = http.Request;
const Response = http.Response;
const std = @import("std");

pub const HandlerFn = fn handle(*Request,*Response) void;

pub var handler = defaultHandler;

pub fn defaultHandler(req: *Request,res: *Response) void {
    _ = req;
    _ = res;
    std.debug.print("http handler undefined\n", .{});
}

pub fn handle(comptime h: HandlerFn) void {
    comptime {
        handler = h;
    }
}
