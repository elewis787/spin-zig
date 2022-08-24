const std = @import("std");
const spin = @import("spin");

fn hello(req: *spin.Request, rw: *spin.ResponseWriter) void {
    std.debug.print("in handler fun\n", .{});

    _ = req;
    rw.status(std.http.Status.ok);
    const n = rw.write("{\"foo\":\"bar\", \"baz\":\"boo\"}");
    if (@TypeOf(n) == spin.WriteError) {
        rw.status(std.http.Status.non_authoritative_info);
    }
}

pub fn main() void {
    std.debug.print("in with main\n", .{});
    spin.Http.handle(hello);
    std.debug.print("done with main\n", .{});
}
