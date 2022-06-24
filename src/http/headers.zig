const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;
const Allocator = mem.Allocator;
const test_allocator = std.testing.allocator;

pub const Headers = struct {
    const HeaderMap = StringHashMap(ArrayList([]const u8));
    header_map: HeaderMap,
    allocator: Allocator,
    found: bool,

    pub fn init(allocator: Allocator) Headers {
        return Headers{
            .allocator = allocator,
            .found = false,
            .header_map = HeaderMap.init(allocator),
        };
    }

    pub fn deinit(self: *Headers) void {
        var iterator = self.header_map.iterator();
        while (iterator.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.header_map.deinit();
    }

    pub fn add(self: *Headers, key: []const u8, value: []const u8) !void {
        var v = try self.header_map.getOrPut(key);
        //new key
        if (!v.found_existing) {
            var list = ArrayList([]const u8).init(self.allocator);
            try list.append(value);
            v.value_ptr.* = list;
        } else {
            try v.value_ptr.*.append(value);
            self.found = true;
        }
    }

    pub fn get(self: Headers, key: []const u8) [][]const u8 {
        var list = self.header_map.get(key).?;
        return list.items;
    }

    //   pub fn values(self: Headers) [][]const u8 {}
};

test "basic headers operations" {
    var headers = Headers.init(test_allocator);
    defer headers.deinit();

    try headers.add("Accept", "Application/json");
    try headers.add("Accept", "Application/xml");
    try std.testing.expect(headers.header_map.count() == 1);
    try std.testing.expect(headers.found == true);
    try std.testing.expect(headers.header_map.contains("Accept"));
  
    var values = headers.get("Accept");
    try std.testing.expect(values.len == 2);
    var arStr: [2][]const u8 = [_][]const u8{ "Application/json", "Application/xml" };
    var test_slice = arStr[0..];
    try std.testing.expect(std.mem.eql(u8, values[0], test_slice[0]));
    try std.testing.expect(std.mem.eql(u8, values[1], test_slice[1]));
}
