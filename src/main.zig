// raylib-zig (c) Nikolas Wipper 2023

const std = @import("std");
const rl = @import("raylib");
const types = @import("boid.zig");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1024;
    const screenHeight = 800;

    var run: bool = true;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    // rl.toggleFullscreen();
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // ross - create Camera
    var camera = rl.Camera{
        .fovy = 45,
        .position = rl.Vector3.init(10, 10, 10),
        .projection = rl.CameraProjection.camera_perspective,
        .target = rl.Vector3.init(0, 0, 0),
        .up = rl.Vector3.init(0, 1, 0),
    };

    rl.hideCursor();

    var myBoid = types.Boid{
        .x = 80,
        .y = 1,
        .z = 2,
        .l = 0.0,
        .b = 1.5,
        .h = 3.0,
        .num_points = 300,
        .color = rl.Color.blue,
        .collision_color_normal = rl.Color.red,
        .collision_color_point = rl.Color.green,
    };

    var yourBoid = types.Boid{
        .x = 1,
        .y = 1,
        .z = 1,
        .l = 0.0,
        .b = 1.5,
        .h = 3.0,
        .num_points = 0,
        .color = rl.Color.orange,
        .collision_color_normal = rl.Color.pink,
        .collision_color_point = rl.Color.purple,
    };

    var position = rl.Vector3.init(0, 0, 0);
    var positionOne = rl.Vector3.init(1, 1, 1);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        if (rl.isCursorHidden())
            camera.update(rl.CameraMode.camera_first_person);
        if (run) {
            if (myBoid.x < 1) {
                myBoid.x = 80;
                yourBoid.x = 1;
            }
            myBoid.x -= 0.01;
            yourBoid.x += 0.01;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_p)) {
            run = !run;
            // rl.drawText("P is pressed!", 90, 20, 20, rl.Color.light_gray);
        }
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

            // rl.drawGrid(50, 1);
            rl.drawCubeWiresV(rl.Vector3.init(25, 0, 0), rl.Vector3.init(50, 50, 50), rl.Color.gray);

            // DRAW RAYS
            draw_boid(&myBoid, &yourBoid);
            draw_boid(&yourBoid, &myBoid);
            // rl.drawCylinder(myBoid.get_position_vector3(), 0, 0.3, 1, 9, myBoid.color);
            // rl.drawCylinder(yourBoid.get_position_vector3(), 0, 0.3, 1, 9, yourBoid.color);

            const rayOne = rl.Ray{ .direction = rl.Vector3.init(0.0002, 0.0002, 0.0002), .position = rl.Vector3.init(0, 0, 0) };
            const rayTwo = rl.Ray{ .direction = rl.Vector3.init(0.0030, 0.0060, 0.0090), .position = rl.Vector3.init(0, 0, 0) };
            rl.drawRay(rayOne, rl.Color.red);
            rl.drawRay(rayTwo, rl.Color.blue);

            const boxOne = rl.BoundingBox{ .min = position, .max = positionOne };
            rl.drawBoundingBox(boxOne, rl.Color.red);
            const collisionOne = rl.getRayCollisionBox(rayOne, boxOne);
            if (collisionOne.hit) {
                const stdout = std.io.getStdOut().writer();
                stdout.print("Hit", .{}) catch {};
                rl.drawSphere(collisionOne.point, 0.1, rl.Color.blue);
            } else {
                const stdout = std.io.getStdOut().writer();
                stdout.print("No hit", .{}) catch {};
            }
            position.x += 0.001;
            positionOne.x += 0.001;
        }

        rl.drawText("Congrats! You created your first window!", 190, 150, 20, rl.Color.light_gray);
        //----------------------------------------------------------------------------------
    }
}

fn draw_boid(boid: *types.Boid, otherBoid: *types.Boid) void {
    // const stdout = std.io.getStdOut();

    const turn_fraction = 0.618033;
    if (boid.num_points < 1)
        return;

    // Previously I started from 0, but then later 0 multipliers would result in just 0
    for (1..boid.num_points) |i| {
        // Have to cast the usize 'i' to the f32 expected by Raylib
        const f = @as(f32, @floatFromInt(i));
        const t: f32 = f / (@as(f32, @floatFromInt(boid.num_points)) - 1);
        const inclination = std.math.acos(1 - 2 * t);
        const azimuth = 2 * std.math.pi * turn_fraction * f;

        const x = std.math.sin(inclination) * std.math.cos(azimuth);
        const y = std.math.sin(inclination) * std.math.sin(azimuth);
        const z = std.math.cos(inclination);

        // const direction = rl.Vector3.init(x * 0.002, y * 0.002, z * 0.002);
        const direction = rl.Vector3.init(x, y, z);

        const ray = rl.Ray{ .position = boid.get_position_vector3(), .direction = direction };

        const collision = rl.getRayCollisionSphere(ray, otherBoid.get_position_vector3(), 2);

        rl.drawSphereWires(boid.get_position_vector3(), 2, 10, 10, rl.Color.violet);
        rl.drawSphereWires(otherBoid.get_position_vector3(), 2, 10, 10, rl.Color.violet);

        rl.drawRay(
            ray,
            rl.Color.red,
        );
        if (collision.hit) {
            rl.drawSphereWires(collision.point, 0.05, 10, 10, boid.collision_color_point);
            // rl.drawSphereWires(collision.normal, 0.05, 10, 10, boid.collision_color_normal);
            // rl.drawSphereWires(rl.math.vector3Add(boid.get_position_vector3(), collision.point), 0.05, 10, 10, rl.Color.yellow);
            // rl.drawSphereWires(rl.math.vector3Add(boid.get_position_vector3(), collision.normal), 0.05, 10, 10, rl.Color.yellow);
        }

        // {
        //     rl.endMode3D();
        //     defer rl.beginMode3D(camera);
        //     if (i == 1) {
        //         // if () {
        //         const string = std.fmt.allocPrint(
        //             std.heap.page_allocator,
        //             "bx: {},\n by: {},\n bz: {}\nx: {},\n y: {},\n z: {},\n dist: {},\n hit: {}\n",
        //             .{ boid.x, boid.y, boid.z, x, y, z, 2, collision.hit },
        //         ) catch {
        //             return;
        //         };
        //         const cString: [*:0]const u8 = @ptrCast(string);
        //         defer std.heap.page_allocator.free(string);
        //         rl.drawText(cString, 190, 200, 20, rl.Color.black);
        //     }
        // }
    }
}
