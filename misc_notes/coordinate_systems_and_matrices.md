

Transforming coordinates to NDC and then to screen coordinates is usually accomplished in a step-by-step fashion where we transform an object's vertices to several coordinate systems before finally transforming them to screen coordinates. The advantage of transforming them to several intermediate coordinate systems is that some operations/calculations are easier in certain coordinate systems as will soon become apparent. There are a total of 5 different coordinate systems that are of importance to us:

Coordinate Systems and Matrices  (matrices allow transitions between coordinate systems)

```
Local Coordinate System (1)   (aka Object Space)  
      ||
      ||
   Model matrix   every model has its own matrix that
      ||          transforms each object to world space         
      ||
World Coordinate System (2)   (aka World Space)
      ||
      ||
   View matrix    transform World space into Camera space
      ||          usually only need one of these
      ||
View Coordinate System (3)   (aka Camera Space, Eye Space)
      ||
      ||   
   Projection Matrix (3m)
      ||
      ||
Clip Coordinates System (4)  (aka Clip Space Clip) (coordinates fall between the -1.0 and 1.0 range 
      ||                      and determine which vertices will end up on the screen.
      ||
   Viewport Transformation matrix (4m)  (convertes -1..)
      ||
      ||
Screen Coordinates
```

Those are all a different state at which our vertices will be transformed in before finally ending up as fragments.


(1) Models can be as simple as a basic cube or an very detailed game unit.  
models are usually created with 3D modeling software: Maya, Blender, Studio Max 
Typically their origin (0,0,0) would be at center of the cube or shifted down 
so that the origin is on the "ground" between the fame unit's feet.
In summary, the Local coordinate is simply the coordinate system that a model was made in.

```
(1m) The Model matrix - When a Model is moved (posed) into the World, it will probably need to be 
resized (Scaled), re-orientated (Rotated), and moved (Translated).  Matrices allow this to be done.
But the order is crucial.  You will probably want to scale first, rotate second and finally translate.
So M = S * R * T
```

(2) World coordinates is the coordinate space of the virtual environment that the models will
reside in. Typically the world system is much larger than the model space.

```
(2m) The View Matrix - transform World space into Camera space usually only need one of these

glm::mat4 CameraMatrix = glm::lookAt(
    cameraPosition, // the position of your camera, in world space
    cameraTarget,   // where you want to look at, in world space
    upVector        // probably glm::vec3(0,1,0), but (0,-1,0) would make you looking upside-down
);
```

(3) Camera coordinates is the coordinate space where everything is relative to the
camera's position. You can think in terms of a stationary camera. The camera never moves, but
the world (and models) move around the camera.

```
(3m) The Projection matrix transforms 3D data into 2D space.  There are two kinds: Orthographic and Perspective
Orthographic projection has no depth perception; think of architectural blue-prints or schematic drawings.
Perspective is used to provide depth to a scene; it has a vanishing point.  The end result of the projection
matrix is that all data has Normalized Device Coordinates or between -1.0 and 1.0.
```

(4) Clip coordinates are processed to the -1.0 and 1.0 range and determine which vertices will end up on the screen.

```
(4m) converts -1.0 .. 1.0 range to pixel coordinates.
      nx - # of horizontal pixels
      my = # of vertical pixels
      
      nx/2   0    0   (nx-1)/2      i   pixel coordinates
        0   ny/2  0   (ny-1)/2      j  
        0    0    1      0          .
        0    0    0      1          .
```

Notes:

Matrix is a mathematical construct that can Translate (move), Rotate, and Scale.
Usually 4x4 array.  

Model * View * Projection is actually completely wrong for OpenGL. OpenGL uses column-major matrices, 
which means the canonical (formal math notation) is actually Projection * View * Model. Direct3D uses 
row-major, which is where Model * View * Projection would actually be correct. 



