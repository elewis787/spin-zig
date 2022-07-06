const int = @import("internals.zig");
const spin = @import("spin-http.zig");
const http = @import("http");
const Request = http.Request;
const Reponse = http.Response;
const std = @import("std");


pub const HandlerFn = fn handle([]const u8) void;

pub var handler = defaultHandler;

pub fn defaultHandler(v: []const u8) void {
    _ = v;
    std.debug.print("http handler undefined\n", .{});
}

pub fn handle(h: HandlerFn) void {
    handler = h;
    h("yolo");
}

fn testFn(v: []const u8) void {
    std.debug.print("Hello, {s}!\n", .{v});
}

pub fn main() void {
    handle(testFn);
}