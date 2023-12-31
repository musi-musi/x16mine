const std = @import("std");

const data =
    "########################################" ++
    "###############           #    #########" ++
    "#########                       ########" ++
    "#########                        #######" ++
    "#######                ##       ########" ++
    "#######                 #          #####" ++
    "########                 #              " ++
    "######                                  " ++
    "############ #               ###########" ++
    "############ #######   #################" ++
    "####################   #################" ++
    "####  ##############   ##############  #" ++
    "#### ###### ########   #######        ##" ++
    "                                  #   ##" ++
    "           ##                  #    ####" ++
    "######  ############   ##########  #####" ++
    "###### #############   #################" ++
    "####################   #################" ++
    "                             ###########" ++
    "                         #   ###########" ++
    "                          #  ###########" ++
    "                             ###########" ++
    "########################################" ++
    "########################################" ++
    "########################################";

pub fn main() !void {
    const file = try std.fs.cwd().createFile("level.dat", .{});
    defer file.close();
    const out = file.writer();
    try out.writeAll(&.{ 0xb0, 0x0b });
    for (data) |c| {
        switch (c) {
            ' ' => try out.writeByte(0),
            else => try out.writeByte(1),
        }
    }
}
