const std = @import("std");
const img = @import("zigimg");

const Allocator = std.mem.Allocator;

const File = std.fs.File;
const Image = img.Image;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    try convert_1bpp(try Files.init(allocator, "wall_tiles.png", "wall_tiles.dat"));
}

// pub fn convert(allocator: Allocator, in_name: []const u8, out_name: []const u8) !void {
//     var image = try img.Image.fromFilePath(allocator, in_name);
//     defer image.deinit();
//     std.log.info("format: {s}", .{@tagName(image.pixelFormat())});
//     var out_file = try std.fs.cwd().createFile(out_name, .{});
//     defer out_file.close();
//     const out = out_file.writer();
//     try out.writeByte(0xB0);
//     try out.writeByte(0x0B);
//     var iter = image.iterator();
//     while (iter.next()) |color| {
//         try out.writeByte(color.toRgba(u8).r);
//     }
// }

const Files = struct {
    image: img.Image,
    out_file: File,
    writer: File.Writer,

    fn init(allocator: Allocator, in_name: []const u8, out_name: []const u8) !Files {
        var image = try img.Image.fromFilePath(allocator, in_name);
        errdefer image.deinit();
        const out_file = try std.fs.cwd().createFile(out_name, .{});
        return Files{
            .image = image,
            .out_file = out_file,
            .writer = out_file.writer(),
        };
    }

    fn deinit(self: *Files) void {
        self.image.deinit();
        self.out_file.close();
    }
};

fn convert_1bpp(files: Files) !void {
    const size = (files.image.width * files.image.height) & (~@as(usize, 0b111));

    const pixels = files.image.pixels.rgba32;
    var i: usize = 0;
    while (i < size) {
        var byte: u8 = 0;
        for (0..8) |_| {
            byte <<= 1;
            defer i += 1;
            if (pixels[i].r != 0) {
                byte += 1;
            }
        }
        try files.writer.writeByte(byte);
    }
}
