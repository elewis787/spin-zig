const std = @import("std");
//const h = @import("handler.zig");
pub const http = @import("./http/http.zig");
pub const WriteError = http.WriteError;
pub const Request = http.Request;
pub const ResponseWriter = http.ResponseWriter;
pub const Headers = http.Headers;
const ArrayList = std.ArrayList;

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

    const body = std.mem.span(req.body.val.ptr);

    const m = method(req.method);

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
        res.status = 300;
        return;
    };
    defer rw.deinit();

 
    Http.call(&request, &rw);

    res.status = @enumToInt(rw.response.status);

    var headermap = Headers.init(allocator);
    headermap.add("Accept", "Application/json") catch {
        res.status = 506;
        return;
    };

    // Manually create key/value headers to hard code response ( testing only )
    var key = [_]u8{ 'A', 'c', 'c', 'e', 'p', 't' };
    var value = [_]u8{ 'A', 'p', 'p', 'l', 'i', 'c', 'a', 't', 'i', 'o', 'n', '/', 'j', 's', 'o', 'n' };

    var key2 = [_]u8{ 'a', 'u', 't', 'h' };
    var value2 = [_]u8{ 'A', 'p', 'p', 'l', 'i', 'c', 'a', 't', 'i', 'o', 'n', '/', 'x', 'm', 'l' };


    const headers = allocator.alloc(c.spin_http_tuple2_string_string_t,2) catch unreachable;
    headers[0] = c.spin_http_tuple2_string_string_t{ .f0 = c.spin_http_string_t{
        .ptr = &key[0],
        .len = key.len,
    }, .f1 = c.spin_http_string_t{
        .ptr = &value[0],
        .len = value.len,
    } };

    headers[1] = c.spin_http_tuple2_string_string_t{ .f0 = c.spin_http_string_t{
        .ptr = &key2[0],
        .len = key2.len,
    }, .f1 = c.spin_http_string_t{
        .ptr = &value2[0],
        .len = value2.len,
    } };

    std.debug.print("{s}\n", .{key});
    std.debug.print("{s}\n", .{value});
    std.debug.print("{s}\n", .{&key[0]});
    std.debug.print("{s}\n", .{&value[0]});
    std.debug.print("{s}\n", .{headers});


    std.debug.print("{d}\n", .{headers.len});
    std.debug.print("size of string_t {}\n",.{@sizeOf(c.spin_http_string_t)});
    std.debug.print("size of tuple_t {}\n", .{@sizeOf(c.spin_http_tuple2_string_string_t)});
    std.debug.print("size of headers {}\n", .{@sizeOf([2]c.spin_http_tuple2_string_string_t)});
    std.debug.print("pointer int {}\n", .{@ptrToInt(headers.ptr)});
    res.headers = c.spin_http_option_headers_t{ .is_some = true, .val = c.spin_http_headers_t{
        .ptr = headers.ptr,
        .len = headers.len,
    } };

    const slice = rw.response.body.toOwnedSlice();
    res.body = c.spin_http_option_body_t{ .is_some = true, .val = c.spin_http_body_t{
        .ptr = slice.ptr,
        .len = slice.len,
    } };
}
