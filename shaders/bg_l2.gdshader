shader_type canvas_item;

// Настройки цвета и плотности
uniform vec4 nebula_color_1 : source_color = vec4(0.5, 0.1, 0.8, 1.0); // Основной фиолетовый оттенок
uniform vec4 nebula_color_2 : source_color = vec4(0.1, 0.4, 0.9, 1.0); // Дополнительный синий/неоновый оттенок
uniform float cloud_scale : hint_range(0.5, 10.0) = 2.0;               // Масштаб облаков
uniform float density : hint_range(0.1, 5.0) = 1.2;                  // Общая плотность / насыщенность туманности
uniform vec2 drift_speed = vec2(0.01, 0.005);                        // Скорость медленного дрейфа туманности

// Псевдослучайный генератор
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Плавный шум
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

// Фрактальный броуновский шум (FBM) для создания детализированных облаков
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    
    // 4 октавы шума для клубящейся структуры
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    // Медленно смещаем координаты во времени для эффекта живого дрейфа газа
    vec2 uv = (UV * cloud_scale) + (TIME * drift_speed);
    
    // Создаем сложный узор туманности с помощью FBM
    vec2 q = vec2(fbm(uv + vec2(0.0, 0.0)), fbm(uv + vec2(5.2, 1.3)));
    vec2 r = vec2(fbm(uv + 4.0 * q + vec2(1.7, 9.2)), fbm(uv + 4.0 * q + vec2(8.3, 2.8)));
    float pattern = fbm(uv + 4.0 * r);
    
    // Управляем контрастом и плотностью туманности
    float cloud_mask = smoothstep(0.2, 0.8, pattern) * density;
    
    // Смешиваем два цвета туманности в зависимости от структуры узора
    vec3 final_nebula_color = mix(nebula_color_1.rgb, nebula_color_2.rgb, clamp(r.x * 2.0, 0.0, 1.0));
    
    // Делаем края туманности полупрозрачными, а плотные центры более насыщенными
    float alpha = clamp(cloud_mask * 1.5, 0.0, 1.0);
    
    // Если пиксель слишком пустой, делаем его абсолютно прозрачным
    if (alpha < 0.1) {
        discard;
    }
    
    COLOR = vec4(final_nebula_color * cloud_mask, alpha/9.0);
}