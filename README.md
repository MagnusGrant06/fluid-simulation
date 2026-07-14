# Fluid Simulation

This is a simple, rudimentary water / fluid simulation as the first assignment for CGRA359 - Games and Graphics Project. I am building this using the Godot game engine, and using it's built in GDShader language, a high-level shading language similar to GLSL where you manually control the vertex and fragment shaders.
## Features and Methods Used
For the surface of the water I primarily use 3 methods: [Schlicks Approximation](https://www.researchgate.net/publication/354065225_The_Schlick_Fresnel_Approximation) to calculate the contribution of reflections and refractions depending on view angle, then
use screen space and skybox sampling to create reflections and refractions respectively. For waves I primarily used [Gerstner / Trochoidal Waves](https://jaynakum.github.io/blog/5/GerstnerWaves.html) which sums multiple cosine waves to create cheap but fairly realistic ocean wave simulations. 
