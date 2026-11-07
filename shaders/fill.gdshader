shader_type canvas_item;

// Настройки цветов заливки
uniform vec4 color_one : source_color = vec4(0.1, 0.05, 0.2, 1.0);
uniform vec4 color_two : source_color = vec4(0.4, 0.1, 0.5, 1.0);
uniform float noise_scale : hint_range(1.0, 30.0) = 8.0;   // Масштаб узора шума
uniform float animation_speed : hint_range(0.0, 5.0) = 0.5; // Скорость переливов

// Простая функция генерации псевдослучайного числа
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Плавный 2D-шум (Value Noise)
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
    // Создаем движущийся анимированный шум на основе UV и времени
    vec2 uv = UV * noise_scale;
    float n = noise(uv + TIME * animation_speed);
    
    // Дополнительный слой мелкого шума для текстурности
    float n2 = noise(uv * 2.0 - TIME * (animation_speed * 0.5));
    float final_noise = mix(n, n2, 0.5);
    
    // Смешиваем два цвета на основе получившегося шума
    vec3 final_color = mix(color_one.rgb, color_two.rgb, final_noise);
    
    COLOR = vec4(final_color, 1.0);
}