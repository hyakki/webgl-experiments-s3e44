uniform float uSpeed;

void main() {
  vec4 color = vec4(1.0, 1.0, 1.0, 1.0);

  color.b = color.b - uSpeed;

  gl_FragColor = color;
}
