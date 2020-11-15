varying vec3 vPosition;

uniform float uSpeed;

void main() {
  vec4 color = vec4(1.0, 1.0, 1.0, 0.2);

  color.b = color.b - uSpeed;

  // float alpha = vPosition.y;
  // color.a = alpha;

  gl_FragColor = color;
}
