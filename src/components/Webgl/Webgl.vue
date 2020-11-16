<template>
  <div class="webgl-component" ref="container"></div>
</template>

<script lang="ts">
/* eslint-disable @typescript-eslint/no-unused-vars */

import { onMounted, ref } from 'vue'
import * as THREE from 'three'

import glsl from 'glslify'

import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'

import city from './textures/city.png'

// eslint-disable-next-line
let OrbitControls = require('three-orbit-controls')(THREE)

export default {
  name: 'Webgl',
  setup() {
    const container = ref()

    let time = 0
    let camera, scene, renderer
    let sketchGeometry, sketchMaterial, sketchMesh
    let lineGeometry, lineMaterial, lineMesh
    let curveGeometry, curveMaterial, curveMesh
    let composer, renderPass, bloomPass
    let cityMaterial

    const cityContainer = new THREE.Object3D()
    const lastPoint = new THREE.Vector2(0, 0)

    const textures = [new THREE.TextureLoader().load(city)]

    const gR = 1.6180339887
    const pi = Math.PI

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

    const createSketch = (addToScene = true) => {
      sketchGeometry = new THREE.PlaneBufferGeometry(1.0 * gR, 1.0, 1.0, 1.0)

      sketchMaterial = new THREE.MeshNormalMaterial({
        side: THREE.DoubleSide,
        wireframe: true,
      })
      // sketchMaterial = new THREE.ShaderMaterial({
      //   fragmentShader: glsl(require('./glsl/sketch.frag').default),
      //   vertexShader: glsl(require('./glsl/sketch.vert').default),
      //   uniforms: {
      //     uDrums: { value: 0.0 },
      //     uPads: { value: 0.0 },
      //     uTime: { value: 0.0 },
      //   },
      //   transparent: true,
      // })

      sketchMesh = new THREE.Mesh(sketchGeometry, sketchMaterial)
      // sketchMesh.position.y += 0.5

      addToScene && scene.add(sketchMesh)
    }

    const createCurve = (origin, radius, angle, addToScene = true) => {
      const curve = new THREE.EllipseCurve(
        origin.x,
        origin.y,
        radius,
        radius,
        angle,
        angle - pi / 2,
        true,
        0
      )

      const points = curve.getPoints(50)
      const geometry = new THREE.BufferGeometry().setFromPoints(points)

      const material = new THREE.LineBasicMaterial({ color: 0xffffff })

      // Create the final object to add to the scene
      const curveMesh = new THREE.Line(geometry, material)

      addToScene && scene.add(curveMesh)
    }

    const createPoint = (origin, addToScene = true) => {
      const geometry = new THREE.BufferGeometry().setFromPoints([origin])

      const material = new THREE.PointsMaterial({
        color: 0xffffff,
        size: 0.001,
      })

      // Create the final object to add to the scene
      const pointMesh = new THREE.Points(geometry, material)

      addToScene && scene.add(pointMesh)
    }

    const createCity = (addToScene = true) => {
      const origin = new THREE.Vector2(0 + (1 - gR / 2), 0 - 0.5)
      const radius = [1, 1]
      let delta
      let startAngle = pi

      const geometry = new THREE.PlaneGeometry(radius[1], radius[1], 1, 1)
      cityMaterial = new THREE.ShaderMaterial({
        fragmentShader: glsl(require('./glsl/box.frag').default),
        vertexShader: glsl(require('./glsl/box.vert').default),
        uniforms: {
          city: { value: textures[0] },
          uTime: { value: 0.0 },
        },
        side: THREE.DoubleSide,
        transparent: true,
      })

      // const planeMesh = new THREE.Mesh(geometry, cityMaterial)
      // planeMesh.position.x = origin.x - radius[1] / 2
      // planeMesh.position.y = origin.y + radius[1] / 2

      // cityContainer.add(planeMesh)
      // addToScene && scene.add(planeMesh)

      // createPoint(origin)
      // createCurve(origin, radius[1], startAngle, true)

      for (let i = 2; i < 22; i++) {
        radius[1] = radius[0] / gR
        delta = radius[0] - radius[1]

        const geometry = new THREE.PlaneBufferGeometry(
          radius[1],
          radius[1],
          1,
          1
        )
        const planeMesh = new THREE.Mesh(geometry, cityMaterial)

        switch (i % 4) {
          case 0:
            origin.y = origin.y + delta
            startAngle = pi / 2
            planeMesh.position.x = origin.x + radius[1] / 2
            planeMesh.position.y = origin.y + radius[1] / 2
            break
          case 1:
            origin.x = origin.x + delta
            startAngle = 0
            planeMesh.position.x = origin.x + radius[1] / 2
            planeMesh.position.y = origin.y - radius[1] / 2
            break
          case 2:
            origin.y = origin.y - delta
            startAngle = -pi / 2
            planeMesh.position.x = origin.x - radius[1] / 2
            planeMesh.position.y = origin.y - radius[1] / 2
            break
          case 3:
            origin.x = origin.x - delta
            startAngle = pi
            planeMesh.position.x = origin.x - radius[1] / 2
            planeMesh.position.y = origin.y + radius[1] / 2
            break
        }

        planeMesh.rotateZ(pi + startAngle)
        cityContainer.add(planeMesh)
        // addToScene && scene.add(planeMesh)

        // createPoint(origin)
        createCurve(origin, radius[1], startAngle)
        radius[0] = radius[1]

        lastPoint.set(origin.x, origin.y)
      }

      cityContainer.children.forEach(m => {
        m.position.x -= lastPoint.x
        m.position.y -= lastPoint.y
      })

      // cityContainer.rotateZ(THREE.MathUtils.degToRad(90))

      addToScene && scene.add(cityContainer)
    }

    const createCamera = () => {
      const { width, height } = container.value.getBoundingClientRect()

      camera = new THREE.PerspectiveCamera(70, width / height, 0.001, 100)
      camera.position.z = 0.05
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

      cityMaterial.uniforms.uTime.value = time

      const v = (time / 600) % 1 // 0 .. 1 based on time

      const rotationAngle = THREE.MathUtils.degToRad(v * -360)
      cityContainer.rotation.z = rotationAngle

      // How should I make evolve the scale based on the rotation?
      // default: (1.0, 1.0, 1.0)
      const scaleScalar = 1 - (1 - 0.146) * v // 1 .. 0.855
      cityContainer.scale.setScalar(scaleScalar)

      window.requestAnimationFrame(update)
    }

    const viewportHandler = () => {
      setSize()
      setCameraAspect()
    }

    onMounted(() => {
      createCamera()
      createScene()

      createSketch(false)
      createCity()

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
