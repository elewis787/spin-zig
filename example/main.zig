const std = @import("std");
const spin = @import("spin");

fn hello(req: *spin.Request, res: *spin.Response) void {
    _ = req;
    res.status = std.http.Status.non_authoritative_info;
    if (@enumToInt(req.method) == 0) {
        res.body = "GET";
    }
    std.debug.print("Hello, {s}!\n", .{"v"});
}

pub fn main() void {
    spin.Http.handle(hello);
}
