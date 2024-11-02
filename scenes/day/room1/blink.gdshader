shader_type canvas_item;

uniform float visibility :hint_range(0.0, 1.0, 0.01) = 1.0;
uniform vec4 color : source_color = vec4(1.0);
uniform float blink_speed : hint_range(0.0, 20.0, 0.1) = 3.0;

void fragment() {
	float time_factor = 0.5 * sin(TIME * blink_speed) + 0.5;
	COLOR = color * COLOR.a;
	COLOR.a *= visibility * time_factor; 
}
