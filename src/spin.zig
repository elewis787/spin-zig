const std = @import("std");

const h = @import("handler.zig");
pub const Handle = h.handle;
const http = @import("http");
const Request = http.Request;
const Response = http.Response;
const Method = http.Method;
const StatusCode = http.StatusCode;
const c = @cImport({
    @cInclude("spin-http.h");
});

const methods = [_][]const u8{
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "PATCH",
    "HEAD",
    "OPTIONS",
};

export fn spin_http_handle_http_request(req: *c.spin_http_request_t, res: *c.spin_http_response_t) void {
    defer c.spin_http_request_free(req);
    //const body = std.mem.asBytes(req.body.val.ptr);
    const m = Method.from_bytes(methods[req.method]);
    if (@TypeOf(m) != Method) {
        return;
    }

    var request = try Request.builder(std.testing.allocator)
        .method(Method.Get)
        .body("body");

    var response = try Response.builder(std.testing.allocator)
        .version(.Http11)
        .status(StatusCode.Forbidden)
        .header("GOTTA-GO", "FAST")
        .body("ᕕ( ᐛ )ᕗ");

    h.handler(request,response);

    res.status = response.status;
}
