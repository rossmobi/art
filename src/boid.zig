// const Boid = struct {
//     x: f32,
//     y: f32,
//     z: f32,
//     l: f32,
//     b: f32,
//     h: f32,
//     show_sphere: bool,
//     fn draw(self: *Boid) void {
//         rl.drawCylinder(rl.Vector3.init(1.0, 0.0, -4.0), 0.0, 1.5, 3.0, 8, rl.Color.gold);
//         rl.drawCylinder(
//             rl.Vector3.init(self.x, self.y, self.z),
//             self.l,
//             self.b,
//             self.h,
//             8,
//             rl.Color.gold,
//         );
//         if (self.show_sphere == true) {
//             rl.drawSphere(
//                 rl.Vector3.init(self.x, self.y, self.z),
//                 self.h * 2,
//                 rl.Color.gold.fade(0.2),
//             );
//         }
//     }
// };
