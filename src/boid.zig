const rl = @import("raylib");

pub const Boid = struct {
    x: f32,
    y: f32,
    z: f32,
    l: f32,
    b: f32,
    h: f32,
    num_points: u32,
    color: rl.Color,
    collision_color_normal: rl.Color,
    collision_color_point: rl.Color,
    pub fn get_position_vector3(self: *Boid) rl.Vector3 {
        return rl.Vector3.init(self.x, self.y, self.z);
    }
};
