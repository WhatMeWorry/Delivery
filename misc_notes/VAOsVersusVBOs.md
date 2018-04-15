
http://www.falloutsoftware.com/tutorials/gl/gl3.htm


VAO and VBO
Inevitably on your journey to understand modern OpenGL rendering techniques, you will stumble across two principles. They are VAO or Vertex Array Object and VBO or Vertex Buffer Object. Let's get familiar with them.

VBO and VAO can cause a little confusion at first. Because they seem like they are used together or for the same or similar purpose. However, they have little to do with one another. First question is what is the difference between the two? This is probably a wrong question to ask, as they perform two unique actions.

VBO stores actual vertex data. The most important thing about a VBO is not that it stores data, though it is its primary function, but where it is stored. A VBO object resides on GPU, the graphics processing unit. This means it is very fast, it is stored in memory on the graphics card itself. How cool is that? Storing data on the computer processor or RAM is slow mostly because it needs to be transferred to the GPU, and this transfer can be costly.

VAO represents properties, rather than actual data. But these properties do describe the objects actually stored in the VBO. VAO can be thought of as an advanced memory pointer to objects. Similar to C-language pointers, they do a whole lot more tracking than just the address. They are very sophisticated.

VAOs are a lot like helpers, rather than actual data storage. That's what they're for. They also keep track of properties to be used in current rendering process. Finally, they describe properties of objects, rather than the raw data of those objects that is by all means already stored in a VBO.

VAOs are not directly related to VBOs, although it may seem that way at first. VAOs simply save time to enable a certain application state needed to be set. Without VAO, you would have to call a bunch of gl* commands to do the same thing.

VBO is used to render complex 3D geometry represented as a list stored in GPU memory. It's tough to abandon glBegin and glEnd methods in favor of VBO. But we are gaining so much more in terms of performance. And if we want to achieve a greater amount of realism we will use VBOs together with GLSL shaders. But that's a subject of another tutorial.

---------------------------------------------------------------------------------------------------------------

A Vertex Array Object (VAO) is an object which contains one or more Vertex Buffer Objects and is designed to store the information for a complete rendered object. In our example this is a diamond consisting of four vertices as well as a color for each vertex.

A Vertex Buffer Object (VBO) is a memory buffer in the high speed memory of your video card designed to hold information about vertices. In our example we have two VBOs, one that describes the coordinates of our vertices and another that describes the color associated with each vertex. VBOs can also store information such as normals, texcoords, indicies, etc.

---------------------------------------------------------------------------------------------------------------

VAO stores data about vertex attribute locations. (And some other data related to them.)
"VBO bindings, active shader program, texture bindings, texture sampling/wrapping settings, uniforms" are completely unrelated to it.

You may ask why it doesn't remember VBO binding. Because you don't need to bind VBO to draw something, you only need to bind it when creating VAO: When you call glVertexAttribPointer(...), VAO remembers what VBO is currently bound. And VAO will take attributes from these VBOs when you draw it, even if these VBOs are not bound currently.

Also, VAOs and VBOs must be used slighty differently:

This will not work

Generate VAO
BindVAO
---- Specify vertex attributes
---- Generate VBO's
---- BindVBO's
-------- Buffer vertex data in VBO's
---- Unbind VBO's
Unbind VAO
because you need to bind VBO to specify attribute locations.

So, you should do it like this:

Generate VAO
BindVAO
Generate VBO's
BindVBO's
Specify vertex attributes

You can change VBO's data whenever you want, but you must bind it before.

And drawing should look like this:

Bind VAO
Draw

As you may noticed, I removed unbind calls from your lists. They are almost completely useless and they will slightly slow down your program, so I see no reason to call them.

---------------------------------------------------------------------------------------------------------------

Here is a simple but effective explanation , basically a buffer object has information which can be interpreted as just simply bits of raw data, which on its own mean nothing, so it is PURELY the data which can be looked at any way really

i.e float vbo[]={1.0,2.0,34.0...}
and the way OpenGL was designed to work is that you must DEFINE what the data that your passing to the various shaders is going to look like to the shaders

in that you also have to define how it will read that data, what format it is in, and what to do with it and how it will be used and for what,all of this information is stored in the VAO

for example you can declare data that is stored in an array like this float vbo = {11.0,2.0,3.0,4.0}

what is required next at this point is how to interpret that data from the VBO in the VAO, and what that means is as follows

the VAO can be set to read 2 floats per vertex (which would make it 2 vectors with two dimensions x,y) or you can tell the vao to interpret it as 1 vector with 4 dimensions i.e x,y,z,w etc

but also other attributes of that data is defined and stored in the VAO such as data format(despite that you declared an array of float you can tell the shader to read it in as an integer, with of course the system converting the raw data in the process from float to integer and has its own set of rules what to do in such circumstances)

So basically the VBO is the data, and the VAO stores how to interpret that data, because the shaders and OpenGL server is designed to be very nosey and needs to know everything before it decides how to process it and what to do with it and where to put it

of course its not actually nosey, its actually looking to be most efficient because it needs to store that data on the graphics server memory so that it gets the most efficient and quickest processing(unless it decides that it doesn't need to do this if the data is not to be processed in such a way and used for some other information that isnt accessed often) , and hence why the details of what to do with the data and how to process it is required to be stored in the VAO , so the VAO is like a header and the VBO is like the pure raw data that the header uses and defines(in this case passes to the shader vertex attributes) with the exception that the VBO is not limited only to be used by one VAO, it can be used and reused and bound to many VAO's for example:
what you can do is you can bind one buffer object to VAO1 and also(separately) bind the same buffer object to VAO2 with each interpreting it differently so that if your shader where to process the data, depending on which VAO is the one that is bound it would process the same raw data differently to the frambuffer(drawing pixels to window) resulting in different display of the same data which would be based upon how you defined its use in the VAO


---------------------------------------------------------------------------------------------------------------

It only stores the vertex binding and the index buffer binding

That is all the parameters of glVertexAttribPointer plus the buffer bound to Vertex_Array_buffer at the time of the call to glVertexAttribPointer and the bound Element_Array_buffer.

Uniforms are part of the current program.

Everything else is global state.

In doubt you can check the state tables in the spec of the version you are using.

---------------------------------------------------------------------------------------------------------------

https://www.khronos.org/registry/OpenGL/specs/gl/glspec45.core.pdf
