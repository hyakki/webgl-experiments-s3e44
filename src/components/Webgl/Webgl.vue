<template>
  <div class="webgl-component" ref="container"></div>
</template>

<script lang="ts">
import { onMounted, ref } from 'vue'
import * as THREE from 'three'

import glsl from 'glslify'

import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'

// eslint-disable-next-line
let OrbitControls = require('three-orbit-controls')(THREE)

export default {
  name: 'Webgl',
  setup() {
    const container = ref()

    let time = 0
    let camera, scene, renderer
    let worldGeometry, worldMaterial, worldMesh
    let composer, renderPass, bloomPass

    const setSize = () => {
      const { width, height } = container.value.getBoundingClientRect()

      renderer.setSize(width, height)
      composer.setSize(width, height)
    }

    const setCameraAspect = () => {
      const { width, height } = container.value.getBoundingClientRect()

      camera.aspect = width / height
      camera.updateProjectionMatrix()
    }

    const createWorld = (addToScene = true) => {
      worldGeometry = new THREE.SphereBufferGeometry(0.7, 30.0, 30.0)
      worldMaterial = new THREE.ShaderMaterial({
        fragmentShader: glsl(require('./glsl/world.frag').default),
        vertexShader: glsl(require('./glsl/world.vert').default),
        uniforms: {
          uDrums: { value: 0.0 },
          uPads: { value: 0.0 },
          uTime: { value: 0.0 },
        },
        transparent: true,
      })

      worldMesh = new THREE.Mesh(worldGeometry, worldMaterial)

      addToScene && scene.add(worldMesh)
    }

    const createCamera = () => {
      const { width, height } = container.value.getBoundingClientRect()

      camera = new THREE.PerspectiveCamera(70, width / height, 0.01, 100)
      camera.position.z = 2
      camera.rotateX(-0.04)
    }

    const createScene = () => {
      scene = new THREE.Scene()
      scene.background = new THREE.Color(0x40162c)
    }

    const createRenderer = () => {
      const { width, height } = container.value.getBoundingClientRect()

      renderer = new THREE.WebGLRenderer({ antialias: false })
      composer = new EffectComposer(renderer)

      renderPass = new RenderPass(scene, camera)
      bloomPass = new UnrealBloomPass(
        new THREE.Vector2(width, height),
        0.0, // strength
        1.0, // radius
        0.2 // threshold
      )

      composer.addPass(renderPass)
      composer.addPass(bloomPass)

      bloomPass.renderToScreen = true
    }

    const createOrbitControls = () => {
      new OrbitControls(camera, renderer.domElement)
    }

    const update = () => {
      composer.render(scene, camera)
      time += 1
      worldMaterial.uniforms.uTime.value = time
      window.requestAnimationFrame(update)
    }

    const viewportHandler = () => {
      setSize()
      setCameraAspect()
    }

    onMounted(() => {
      createCamera()
      createScene()

      createWorld()

      createRenderer()
      createOrbitControls()

      setSize()
      container.value.appendChild(renderer.domElement)

      update()

      window.addEventListener('resize', viewportHandler)
    })

    return {
      container,
    }
  },
}
</script>
