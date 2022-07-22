const std = @import("std");
const spin = @import("spin");

fn hello(req: *spin.Request, rw: *spin.ResponseWriter) void {
    _ = req;
    _ = rw;
    rw.status(std.http.Status.non_authoritative_info);
    const n = rw.write("{\"foo\":\"bar\", \"baz\":\"boo\"}");
    if (@TypeOf(n) != usize ) {
        rw.status(std.http.Status.internal_server_error);
    }
}

pub fn main() void {
    spin.Http.handle(hello);
}
