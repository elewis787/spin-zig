const std = @import("std");
//const h = @import("handler.zig");
pub const http = @import("./http/http.zig");
pub const WriteError = http.WriteError;
pub const Request = http.Request;
pub const ResponseWriter = http.ResponseWriter;

//pub const Response = @import("zhp").Response;
const Method = @import("std").http.Method;

const c = @cImport({
    @cInclude("spin-http.h");
});

pub const HandlerFn = fn handle(*Request, *ResponseWriter) void;

// defaultHandler is the default function used by spin if the user fails to set a handler
pub fn defaultHandler(req: *Request, rw: *ResponseWriter) void {
    _ = req;
    _ = rw;
    //  res.status = std.http.Status.service_unavailable;
    std.debug.print("http handler undefined\n", .{});
}

// Http is a global comptime stuct used to set the user defined handler
pub const Http = handle: {
    comptime var self: HandlerFn = defaultHandler;

    const result = struct {
        pub fn handle(comptime h: HandlerFn) void {
            self = h;
        }
        fn call(req: *Request, rw: *ResponseWriter) void {
            self(req, rw);
        }
    };
    break :handle result;
};

const methods = [_][]const u8{
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "PATCH",
    "HEAD",
    "OPTIONS",
};

fn method(index: u8) Method {
    const m = switch (index) {
        0 => Method.GET,
        else => Method.OPTIONS,
    };
    return m;
}

export fn spin_http_handle_http_request(req: *c.spin_http_request_t, res: *c.spin_http_response_t) void {
    defer {
        c.spin_http_request_free(req);
    }
    _ = req;
    _ = res;

    const body = std.mem.span(req.body.val.ptr);

    const m = method(req.method);

    //  var request = try Request.builder(std.testing.allocator)
    //      .method(Method.Get)
    //      .body(body);
    // var response = try Response.builder(std.testing.allocator)
    //     .version(.Http11)
    //     .status(StatusCode.Forbidden)
    //     .header("GOTTA-GO", "FAST")
    //     .body("ᕕ( ᐛ )ᕗ");
    //  var request = Request.initCapacity(allocator, 1000, 100, 10) catch |err| {
    //     std.debug.print("{s}!\n", .{err});
    //     return;
    //  };
    // var response = Response.initCapacity(allocator, 1000, 100) catch |err| {
    //     std.debug.print("{s}!\n", .{err});
    //     return;
    // };

    var request = Request{
        .method = m,
        .headers = undefined,
        .path = undefined,
        .query = undefined,
        .body = body,
        .version = undefined,
    };
    const allocator = std.testing.allocator;
    var rw = ResponseWriter.initCapacity(allocator, 4096, 1096) catch {
        res.status = 200;
        return;
    };
    defer rw.deinit();
    // var key = [_]u8{ 'C', 'o', 'n', 't', 'e', 'n', 't', '-', 'T', 'y', 'p', 'e' };
    // var value = [_]u8{ 'a', 'p', 'p', 'l', 'i', 'c', 'a', 't', 'i', 'o', 'n', '/', 'j', 's', 'o', 'n' };
    Http.call(&request, &rw);
    res.status = @enumToInt(rw.response.status);
    // std.mem.copy(u8, b[0..response.body.len], "test");
    //res.headers = c.spin_http_option_headers_t{ .tag = true, .val = c.spin_http_headers_t{
    // .ptr = &c.spin_http_tuple2_string_string_t{
    //.f0 = c.spin_http_string_t{
    //      .ptr = &key,
    //        .len = key.len,
    //      },
    //        .f1 = c.spin_http_string_t{
    //            .ptr = &value,
    //            .len = value.len,
    //       }
    //    },
    //    .len = 1,
    //}};
    //var b = [_]u8{ 'h', 'i' };
    const slice = rw.response.body.toOwnedSlice();
    res.body = c.spin_http_option_body_t{ .tag = true, .val = c.spin_http_body_t{
        .ptr = slice.ptr,
        .len = slice.len,
    } };
}
