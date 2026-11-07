shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.0, 0.9, 1.0, 1.0); // Цвет неона
uniform float glow_intensity : hint_range(0.0, 10.0) = 3.5;         // Базовая яркость (чем больше, тем сильнее «горит»)
uniform float pulse_speed : hint_range(0.0, 10.0) = 4.0;           // Скорость пульсации
uniform float pulse_min : hint_range(0.0, 1.0) = 0.6;              // Минимальная точка пульса (глубина затухания)

void fragment() {
    // Плавное синусоидальное мерцание (пульсация)
    float pulse = pulse_min + (1.0 - pulse_min) * (0.5 + 0.5 * sin(TIME * pulse_speed));
    
    // Финальный цвет свечения с учетом яркости и пульса
    vec3 final_glow = glow_color.rgb * glow_intensity * pulse;
    
    // Оставляем альфа-канал меша (чтобы свечение повторяло форму фигуры)
    COLOR = vec4(final_glow, glow_color.a);
}