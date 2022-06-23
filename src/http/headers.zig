const std = @import("std");
const mem = std.mem;
const StringHashMap = std.StringHashMap;
const Allocator = mem.Allocator;
const test_allocator = std.testing.allocator;

pub const Headers = struct {

    const HeaderMap = StringHashMap([]const u8);
    header_map: HeaderMap,
    allocator: Allocator,

    pub fn init(allocator: Allocator) Headers{
        return Headers{
            .allocator = allocator, 
            .header_map = HeaderMap.init(allocator),
        };
    }

    pub fn deinit(self: *Headers) void {
        self.header_map.deinit();
    }

    pub fn add(self: *Headers, key: []const u8, value: []const u8 )  !void {
        try self.header_map.put(key,value); 
    }

    pub fn get(self: Headers, key: []const u8) ?[]const u8 {
        return self.header_map.get(key);
    }

    pub fn values(self: Headers) [][]const u8{

    }

};

test "basic headers operations" {
    var headers = Headers.init(test_allocator);
    defer headers.deinit();

    try headers.add("test","value");
    try std.testing.expect(headers.header_map.contains("test"));
    try std.testing.expect(std.mem.eql(u8,headers.get("test").?,"value"));
}
