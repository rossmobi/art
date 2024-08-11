// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const rl = @import("raylib");

const Boid = struct {
    x: f32,
    y: f32,
    z: f32,
    l: f32,
    b: f32,
    h: f32,
    color: rl.Color,
    fn get_position_vector3(self: *Boid) rl.Vector3 {
        return rl.Vector3.init(self.x, self.y, self.z);
    }
    // fn draw(self: *Boid) void {
    //     rl.drawCylinder(rl.Vector3.init(1.0, 0.0, -4.0), 0.0, 1.5, 3.0, 8, rl.Color.gold);
    //     rl.drawCylinder(
    //         rl.Vector3.init(self.x, self.y, self.z),
    //         self.l,
    //         self.b,
    //         self.h,
    //         8,
    //         rl.Color.gold,
    //     );
    // }
};

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1024;
    const screenHeight = 800;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // ross - create Camera
    var camera = rl.Camera{
        .position = rl.Vector3.init(0, 10, 10),
        .target = rl.Vector3.init(0, 0, 0),
        .up = rl.Vector3.init(0, 1, 0),
        .fovy = 45,
        .projection = rl.CameraProjection.camera_perspective,
    };

    // rl.hideCursor();

    var myBoid = Boid{
        .x = 2,
        .y = 2,
        .z = 2,
        .l = 0.0,
        .b = 1.5,
        .h = 3.0,
        .color = rl.Color.pink,
    };

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        camera.update(rl.CameraMode.camera_first_person);
        myBoid.x -= 0.01;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        // Apparently I need the following lines, but things seem to work without them...
        // camera.begin();
        // defer camera.end();

        rl.clearBackground(rl.Color.white);

        {
            rl.beginMode3D(camera);
            defer rl.endMode3D();

            rl.drawGrid(50, 1);

            // rl.drawCubeWires(rl.Vector3.init(-4, 0, 2), 2, 5, 2, rl.Color.gold);
            rl.drawCube(rl.Vector3.init(-4, 0, 2), 2, 5, 2, rl.Color.red);

            rl.drawRay(.{ .position = myBoid.get_position_vector3(), .direction = rl.Vector3.init(myBoid.x + 0.2, myBoid.y + 0.2, myBoid.z + 0.2) }, myBoid.color);
            const num_points = 300;
            const turn_fraction = 0.618033;

            for (0..num_points) |i| {
                // Have to cast the usize 'i' to the f32 expected by Raylib
                const f = @as(f32, @floatFromInt(i));
                const t: f32 = f / (num_points - 1);
                const inclination = std.math.acos(1 - 2 * t);
                const azimuth = 2 * std.math.pi * turn_fraction * f;

                const x = std.math.sin(inclination) * std.math.cos(azimuth);
                const y = std.math.sin(inclination) * std.math.sin(azimuth);
                const z = std.math.cos(inclination);

                const direction = rl.Vector3.init(x * 0.0002, y * 0.0002, z * 0.0002);

                rl.drawRay(
                    .{ .position = myBoid.get_position_vector3(), .direction = direction },
                    myBoid.color,
                );
            }
            rl.drawCylinder(myBoid.get_position_vector3(), 0, 0.3, 1, 9, myBoid.color);
            // rl.drawLine(.{ .position = myBoid.get_position_vector3(), .direction = rl.Vector3.init(myBoid.x + 100, myBoid.y + 100, myBoid.z + 100) }, myBoid.color);
            // myBoid.draw();
        }

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
        //----------------------------------------------------------------------------------
    }
}
