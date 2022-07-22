const std = @import("std");
const spin = @import("spin");

fn hello(req: *spin.Request, rw: *spin.ResponseWriter) void {
    _ = req;
    rw.status(std.http.Status.ok);
    const n = rw.write("{\"foo\":\"bar\", \"baz\":\"boo\"}");
    if (@TypeOf(n) == spin.WriteError ) {
        rw.status(std.http.Status.non_authoritative_info);
    }
}

pub fn main() void {
    spin.Http.handle(hello);
}
