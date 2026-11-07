shader_type canvas_item;

// Настройки фона и звезд
uniform vec4 space_bg_color : source_color = vec4(0.02, 0.01, 0.05, 1.0); // Глубокий темно-фиолетовый/ночной космос
uniform float star_density : hint_range(10.0, 200.0) = 80.0;            // Плотность мелких звезд
uniform float twinkle_speed : hint_range(0.1, 5.0) = 1.5;             // Скорость мерцания звезд
uniform vec2 parallax_scroll_speed = vec2(0.02, 0.01);                // Медленное авто-смещение фона

// Функция генерации псевдослучайного числа по вектору
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Генерация шума для больших звезд
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
    // Базовые координаты с возможностью медленного авто-скролла от времени
    vec2 uv = (UV * star_density) + (TIME * parallax_scroll_speed);
    
    // --- 1. СЛОЙ МЕЛКИХ ЗВЕЗД (ПЫЛЬ) ---
    vec2 ipos = floor(uv);
    vec2 fpos = fract(uv);
    
    // Случайная яркость для каждой звезды на основе ее ячейки
    float star_rand = random(ipos);
    
    // Оставляем только те ячейки, которые становятся "звездами"
    float star = 0.0;
    if (star_rand > 0.85) {
        float dist = length(fpos - vec2(0.5 + 0.3 * sin(star_rand * 10.0)));
        float twinkle = 0.5 + 0.5 * sin(TIME * twinkle_speed + star_rand * 50.0);
        star = smoothstep(0.15, 0.0, dist) * twinkle * (star_rand);
    }
    
    // --- 2. СЛОЙ КРУПНЫХ ОТДЕЛЬНЫХ ЗВЕЗД ---
    vec2 large_uv = (UV * (star_density * 0.25)) + (TIME * parallax_scroll_speed * 0.5);
    float large_noise = noise(large_uv);
    float big_star = 0.0;
    if (large_noise > 0.92) {
        vec2 f_large = fract(large_uv);
        float dist_big = length(f_large - vec2(0.5));
        float big_twinkle = 0.6 + 0.4 * cos(TIME * (twinkle_speed * 1.2) + large_noise * 30.0);
        big_star = smoothstep(0.3, 0.0, dist_big) * big_twinkle * 1.5;
    }
    
    // --- 3. ФИНАЛЬНОЕ СМЕШИВАНИЕ ---
    vec3 final_color = space_bg_color.rgb;
    
    vec3 star_color = vec3(0.9, 0.95, 1.0);
    final_color += star_color * star;
    
    vec3 big_star_color = vec3(1.0, 0.95, 0.8);
    final_color += big_star_color * big_star;
    
    COLOR = vec4(final_color, 1.0);
}