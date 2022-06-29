const std = @import("std");
const Request = @import("http").Request;
const Response = @import("http").Response;
const Method = @import("http").Method;

var hanlderFn = defaulthandler;

pub const HandlerFn = fn handle(Request, Response) anyerror!void;

pub fn Handler(comptime handler: anytype) !void {
    if (@TypeOf(handler) == HandlerFn) {
        hanlderFn = handler;
    } else {
        hanlderFn = defaulthandler;
    }
}

pub fn Execute() !void {
    var request = try Request.builder(std.testing.allocator)
        .method(Method.Get)
        .uri("https://ziglang.org/")
        .body("");
    defer request.deinit();

  //  var response = Response{body: _body,_version,_status,_headers};

  //  try hanlderFn(request,response);
}

fn defaulthandler(_: Request, _: Response) !void {
    std.log.info("All your codebase are belong to us. boom", .{});
}
