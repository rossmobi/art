// raylib-zig (c) Nikolas Wipper 2023

const rl = @import("raylib");

const Boid = struct {
    x: f32,
    y: f32,
    z: f32,
    l: f32,
    b: f32,
    h: f32,
    show_sphere: bool,
    fn draw(self: *Boid) void {
        rl.drawCylinder(rl.Vector3.init(1.0, 0.0, -4.0), 0.0, 1.5, 3.0, 8, rl.Color.gold);
        rl.drawCylinder(
            rl.Vector3.init(self.x, self.y, self.z),
            self.l,
            self.b,
            self.h,
            8,
            rl.Color.gold,
        );
        if (self.show_sphere == true) {
            rl.drawSphere(
                rl.Vector3.init(self.x, self.y, self.z),
                self.h * 2,
                rl.Color.gold.fade(0.2),
            );
        }
    }
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

    rl.hideCursor();

    var myBoid = Boid{
        .x = 2,
        .y = 2,
        .z = 2,
        .l = 0.0,
        .b = 1.5,
        .h = 3.0,
        .show_sphere = true,
    };

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        // if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
        //     camera.position
        // }
        camera.update(rl.CameraMode.camera_first_person);
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

            rl.drawCubeWires(rl.Vector3.init(-4, 0, 2), 2, 5, 2, rl.Color.gold);
            rl.drawCube(rl.Vector3.init(-4 - 4, 0 - 4, 2 - 4), 2, 5, 2, rl.Color.red);

            myBoid.draw();
        }

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
        //----------------------------------------------------------------------------------
    }
}
