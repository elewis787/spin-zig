const std = @import("std");
//const c = @cImport({
//   @cInclude("spin-http.h");
//});
const http = @import("http");
const request = http.Request;
const method = http.Method;
const spin = @import("spin-http.zig");

const methods = [_][]const u8{
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "PATCH",
    "HEAD",
    "OPTIONS",
};

pub fn spin_http_handle_http_request(req: *spin.spin_http_request_t, _: *spin.spin_http_response_t) void {
    defer spin.spin_http_request_free(req);
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const m = method.from_bytes(methods[req.method]);
    if(@TypeOf(m) != method ){
        return;}

    var r = try request.builder(gpa.allocator())
        .method(m)
        .uri(req.uri.prt, req.uri.len)
        .body(req.body.val);

    defer r.deinit();
}
