const int = @import("internals.zig");
const spin = @import("spin-http.zig");

pub fn main() void {
    int.spin_http_handle_http_request();
}