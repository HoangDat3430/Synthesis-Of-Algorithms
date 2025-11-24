# THIS PROJECT IS A SYNTHESIS AND VISUALIZE SOME USEFUL ALGORITHMS IN GAME DEVELOPMENT

## Description
  The goal of this project is to synthesize commonly used algorithms in game
development, and implement them into game so that they can be visualized.
Although it is a minimalist project with a focus on algorithm implementation, I
still built a complete system to organize a clean source code, easy to read,
scalable and maintain. Because I will continue this project in the future as a
tracking for any knowledge that I acquired during my developing path.

## Algorithms
### 1. A* & Flow-field Pathfinding
#### Demo

https://github.com/user-attachments/assets/43522386-2c31-424e-b11d-50eff119c0b7

#### Features:
 - The grid map is made up of tiles. These tiles are created entirely in C# code (based on creating a Mesh Renderer by vertices and triangles).
 - The system is designed to be easily updated or supplemented with other grid types or pathfinding algorithms.
 - Note: Green nodes are start positions, Red is the goal, others are terrain types (water, swamp, rock, hole) with different mCost.

### 2. Cut Mesh 2D (On going)
### 3. Arange Squad (in RTS games like AOE, RA2 - On going) 
### 4. Waves effects by Unity Shader (HLSL programming)
#### Demo

https://github.com/user-attachments/assets/dd0ca21f-53b4-4607-8287-6cca4ca1bd8f

#### Features:
 - This is my custom URP Lit Shader. Its have lighting effect on the surface, metallic and smoothness (using UniversalFragmentPBR) base on normal, tangent, bitangent, lightmapUV,...
 - To create the wave effect. I apply the wave formula called GerstnerWave.
 - In the demo, there is a combination of 3 waves with differents direction, steepness and wave length.
 - To reflection the lighting on waves, normal vector of each vertex also recalculated

### 5. Water surface simulation by Unity Shader (HLSL programming)
#### 5.1. Interactable water surface by Unity Shader
#### Demo

https://github.com/user-attachments/assets/ed879b89-5c14-4ade-9c49-48cd5dd4a638

#### Features:
 - This effect uses sine wave graph to create the wave, but this formula is periodic graph, So I need e^(-(x^2)) to create just 1 wave only at touch point
 - The water flow effect using 1 texture map but sample into 2 normal map with different speed and direction to make it looked reality
 - To create wave reflection when reach the boundary, I created 4 waves at 4 symmetric touch points based on each bound at the same time

#### 5.2. Application of Water surface simulation shader
#### Demo

[https://github.com/user-attachments/assets/ed879b89-5c14-4ade-9c49-48cd5dd4a638](https://github.com/user-attachments/assets/24520440-fd72-4dc4-ae3d-9a576356711b)

#### Features:
 - This is an application of water surface simulation shader that creates an effect the character is moving on an interactable water surface.
 - This is a further development based on the principles and features of topic 5.1 above.

### 6. [Advanced] Water surface simulation by Unity Shader (HLSL combined with particle system and render texture) 
#### Demo

[https://github.com/user-attachments/assets/ed879b89-5c14-4ade-9c49-48cd5dd4a638](https://github.com/user-attachments/assets/a651f05e-9621-4227-ba44-d667b7f80212)

#### Features:
 - This is an advanced application of the topic of water surface simulation using Unity shaders. Helps to handle the unoptimized visual and performance problems of the previous method.
##### Problems:
 - The visual effect will occur aliasing when we descrease the wavelength because there is using vertex displacement technique to simulate the wave which is require a very detailed mesh (to much triangle & vertices) to bring out the better wave visual results.
 - If we need to create a big interactable water region, it's requires a mesh that have too many vertices to simulate => large of resources and significant reduced the perfornance
##### Solutions:
 - Use a particle system to simulate the wave image spreading at the character's position continuously when moving
 - Use a camera to capture that particle and draw it on a render texture
 - Use a shader to calculate the wave spreading over time
 - Use another shader to calculate the normal map, lighting for the water surface based on the wave images recorded on the render texture.

=> The wave effect can be created regardless of how many vertices the mesh has and performance is increased (because of low tris and batch).

=> No more aliasing in waveform because it is not dependent on the number of vertices.










 
