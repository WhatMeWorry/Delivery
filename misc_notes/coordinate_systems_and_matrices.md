

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
View Coordinate System (3)   (aka View Space, Camera Space, Eye Space)
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

(3) View coordinates is the coordinate space where everything is relative to the
camera's (or eye's) position. You can think in terms of a stationary camera. The camera never moves, but
the world (and models) move around the camera.

The camera in OpenGL cannot move and is defined to be located at (0,0,0) facing the negative Z direction. That means that instead of moving and rotating the camera, the world is moved and rotated around the camera to construct the appropriate view.

This seems paradoxical. We've introduced a camera yet move all of the objects in the world to the camera's outlook! Why not just move the camera? Well, the camera is actually just a logical construct to make it easier to reason about. Remember, the only actual things we have are created are models. And yes, these objects are mathematical constructs of vertices, but they are nonetheless the only "real" thing we can work with.

```
(3m) The Projection matrix transforms 3D data into 2D space. There are two kinds: Orthographic
and Perspective. Orthographic projection has no depth perception; think of architectural 
blue-prints, or schematic drawings. Or just close one of your eyes and try to reach out and 
touch something. Perspective is used to provide depth to a scene; it has a vanishing point.  
The end result of the projection matrix is that all data (vertices) are clipped to values 
between -1.0 and 1.0. These values are formally called Normalized Device Coordinates.

The default projection matrix is the identity matrix, which is the same as glOrtho(-1, 1, -1, 1, 1, -1).
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



Pixel Aspect Ratio:

Historically, (early 1980s) computers and video game consoles with their video raster displayed on a CRT screen
were clearly wider or narrower than their height. To draw perfect circles instead of elongated ellipsoids you 
needed to take the pixel aspect ratio in account 

Nowadays, pixels on LCD monitors have square pixels. So pixel aspect ratio is now 1:1.  So pixel aspect ratio
can be simply ignored.


Display Aspect Ratio:

is the proportional relationship between its width and its height.  It is expressed as two numbers separated by 
a colon (x:y). Common aspect ratios for displays, past and present, include 5:4, 4:3, 16:10 and 16:9.

Opengl uses Normalized Device Coordinates with x, y, and z where each axis has range between -1.0 and 1.0

Instead of thinking that the NDC range (-1.0, 1.0) represents absolute
positions, I like to think of them as representing a percentage of leftness
or rightness; of topness or bottomness; So the origin (Center) at (0,0)
can be thought of as zero rightness or leftness, and zero topness or
bottomness. 

```
                  1.0 (top most position)
                   |  
                   |
                   |
                   |
 -1.0 -------------+---------------1.0
 (furthest left)   |          (furthest right)
                   |
                   |
                   |
                 -1.0 (bottom most position)
```

However, if your display aspect ratio is not square, then every
position is going to be skewed.  So if I have a half unit circle
of 0.5 then the ideal circle will come out a squashed ellipsoid 
a 1920 x 1080 pixel display.

So how do we deal with this?



https://www.3dgep.com/understanding-the-view-matrix/

Understanding the View Matrix

Understanding how the view matrix works in 3D space is one of the most underestimated concepts of 3D game programming.  
The reason for this is the abstract nature of this elusive matrix.  The (((WRONG: world transformation) _model_ matrix 
is the matrix that determines the position and orientation of an object in 3D space. The view matrix is used to 
transform a model’s vertices from world-space to view-space.  Don’t be mistaken and think that these two things are 
the same thing!

In order to understand this correctly, we must think in terms of two different things:

```
The Camera Transformation Matrix: The transformation that places the camera in the correct position and orientation 
in world space (this is the transformation that you would apply to a 3D model of the camera if you wanted to 
represent it in the scene).

The View Matrix: This matrix will transform vertices from world-space to view-space.  This matrix is the inverse of 
the camera’s transformation matrix.
```

If we think of the camera as an object in the scene (like any other object that is placed in the scene) then we can say that even the camera has a transformation matrix that can be used to orient and position it in the world space of the scene (the world transform, or in the context of this article, I will refer to this transform as the “camera transform” to differentiate it from the “view transform”). But since we want to render the scene from the view of the camera, we need to find a transformation matrix that will transform the camera into “view space”. In other words, we need a transformation matrix that will place the camera object at the origin of the world pointing down the Z-axis (the positive or negative Z-axis depends on whether we are working in a left-handed or right-handed coordinate system. For an explanation on left-handed and right-handed coordinate systems, you can refer to my article titled Coordinate Systems). In other words, we need to find a matrix V such that:

 I = VC
 
Where C is the camera transform matrix, and V is the view matrix we are looking for that will transform the camera transform matrix into the identity matrix I.

Well, it may be obvious that the matrix V is just the inverse of M. That is,

  V = M (raised) −1  
  
Coincidently, The V matrix is used to transform any object in the scene from world space into view space (or camera space).

The Camera Transformation

The camera transformation is the transformation matrix that can be used to position and orient an object or a model in the scene that represents the camera.  If you wanted to represent several cameras in the scene and you wanted to visualize where each camera was placed in the world, then this transformation would be used to transform the vertices of the model that represents the camera from object-space into world space. This is the same as a world-matrix or model-matrix that positions any model in the scene.  This transformation should not be mistaken as the view matrix.  It cannot be used directly to transform vertices from world-space into view-space.


And a vertex v can be transformed to clip-space by multiplying by the combined matrix MVP:

v′=MVP∗v
So that’s how it’s used, so how is the view matrix computed? There are several methods to compute the view matrix and the preferred method usually depends on how you intend to use it.

A common method to derive the view matrix is to compute a Look-at matrix given the position of the camera in world space (usually referred to as the “eye” position), an “up” vector (which is usually [010]T), and a target point to look at in world space.

If you are creating a first-person-shooter (FPS), you will probably not use the Look-at method to compute the view matrix. In this case, it would be much more convenient to use a method that computes the view matrix based on a position in world space and pitch (rotation about the X axis) and yaw (rotation about the Y axis) angles (usually we don’t want the camera to roll (rotation about the Z axis) in a FPS shooter).

If you want to create a camera that can be used to pivot around a 3D object, then you would probably want to create an arcball camera.

I will discuss these 3 typical camera models in the following sections.

Look At Camera
FPS Camera
Arcball Orbit Camera


https://solarianprogrammer.com/2013/05/22/opengl-101-matrices-projection-view-model/

The view matrix

By default, in OpenGL, the viewer is positioned on the z axis, it is like using a camera to take a shot. Imagine that your camera points to the origin of the Cartesian system. The up direction is parallel to the Oy axis and in the positive sense of Oy.

The view matrix in OpenGL controls the way we look at a scene. In this article we are going to use a view matrix that simulates a moving camera, usually named lookAt.

It is beyond the purpose of the present article to derive and present the way we create the view matrix, suffice to say that it is a 4x4 matrix, like the model matrix, and it is uniquely determined by 3 parameters:

The eye, or the position of the viewer;

The center, or the point where we the camera aims;

The up, which defines the direction of the up for the viewer.

The defaults in OpenGL are: the eye at (0, 0, -1); 
                         the center at (0, 0, 0) and 
                         the up is given by the positive direction of the Oy axis (0, 1, 0).

Non 1:1 Aspect Ratio Compensation

Obviously, the object is not altered by our unitary matrices multiplications. However, the square from the center of the image looks more like a rectangle. This is because the aspect ratio of our window 800:600 will distort the length of any segment that is not parallel with the Oy axis. We can correct this effect in two ways:

Using a window with a 1:1 aspect ratio;

Using the projection matrix to compensate the distortion of our window.

Let’s try to use the second solution, we start by imposing:

                 (width/height)  =  (right−left) / (top−bottom)
               
     multiply both sides by  have:

right−left=width⋅(top−bottom)height
from where:

right=width⋅(top−bottom)2⋅height
and

    left = −right

Assuming screen size of 800:600 for 4:3 gives us:

```
glm::mat4 Model, View, Projection;
 
// Set the projection matrix
// 4.0/3.0 is taken from the 800:600 aspect ratio
Projection = glm::ortho(-4.0f/3.0f, 4.0f/3.0f, -1.0f, 1.0f, -1.0f, 1.0f);
```
This technique works in orthographic projection by "narrowing" the longer
dimension so that it is equal shorter side. Thus creating a square display
area; the window itself will still be a rectangle.  We reinforce this idea
by displaying a NDC square within the 01_03_02_hex_resize project 

```
if (newWidth >= newHeight)
{
    aspectRatio = cast(float) newWidth / cast(float) newHeight;
    projection = orthographicFunc(-aspectRatio, aspectRatio, 1.0, -1.0, 1.0, 10.0); 
}                
else
{
    aspectRatio = cast(float) newHeight / cast(float) newWidth;  
    projection = orthographicFunc(-1.0, 1.0, aspectRatio, -aspectRatio, 1.0, 10.0);
}
```
