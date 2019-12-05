
module post_processor;

//import common;
//import common_game;


import gl3n.linalg : mat4, vec2, vec3, vec4; 
import std.random;
import std.stdio;

/+

// Represents a single particle and its state
struct Particle 
{
    vec2 position = 0.0; 
    vec2 velocity = 0.0;
    vec4 color = 1.0;
    GLfloat life = 0.0f;

    //Particle() : Position(0.0f), Velocity(0.0f), Color(1.0f), Life(0.0f) { }
};
+/

void specifyError(GLenum err)
{
    write("glCheckFramebufferStatus returned error of ");
    if (err == GL_FRAMEBUFFER_UNDEFINED)
        writeln("GL_FRAMEBUFFER_UNDEFINED");
    else if (err == GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT )
        writeln("GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
    else if (err == GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT )
        writeln("GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT");
    else if (err == GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER )
        writeln("GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER");
    else if (err == GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER )
        writeln("GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER");
    else if (err == GL_FRAMEBUFFER_UNSUPPORTED )
        writeln("GL_FRAMEBUFFER_UNSUPPORTED");
    else if (err == GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE )
        writeln("GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE");
    else if (err == GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS )
        writeln("GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS");
    else
        writeln("unknown. Check documentation.");
}





/+
PostProcessor hosts all  post processing effects for the Breakout Game. It renders the game on a 
textured quad after which one can enable specific effects by enabling either the Confuse, Chaos or 
Shake boolean.  It is required to call BeginRender() before rendering the game EndRender() after 
rendering the game for the class to work.
+/

class PostProcessor
{
public:
    // State
    ShaderBreakout postProcShader;
    Texture2D      texas;
    GLuint         postProcWidth; 
    GLuint         postProcHeight;
    // Options
    GLboolean      confuse;
    GLboolean      chaos;
    GLboolean      shake;

    // Render state
    GLuint MSFBO; // MSFBO is a Multisampled FBO
    GLuint FBO;   // FBO is regular, used for blitting MS color-buffer to texture
    GLuint RBO;   // RBO is used for multisampled color buffer
    GLuint VAO;

    // Constructor
    this(ShaderBreakout shader, GLuint width, GLuint height)
    {
        postProcShader = shader;
        texas = new Texture2D;
        this.postProcWidth = width;
        this.postProcHeight = height; 
        confuse = GL_FALSE;
        chaos = GL_FALSE;
        shake = GL_FALSE;

        // initialize renderbuffer/framebuffer object
        glGenFramebuffers(1, &this.MSFBO);
        glGenFramebuffers(1, &this.FBO);
        glGenRenderbuffers(1, &this.RBO);
    
        // initialize renderbuffer storage with a multisampled color buffer (don't need a depth/stencil buffer)
        glBindFramebuffer(GL_FRAMEBUFFER, this.MSFBO);
        glBindRenderbuffer(GL_RENDERBUFFER, this.RBO);

        glRenderbufferStorageMultisample(GL_RENDERBUFFER, 8, GL_RGB, width, height); // Allocate storage for render buffer object
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, this.RBO); // Attach MS render buffer object to framebuffer
        GLenum ret = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (ret != GL_FRAMEBUFFER_COMPLETE)
        {
            specifyError(ret);
            writeAndPause("Error: Post Processor failed to initialize MSFBO");
        }

        // also initialize the FBO/texture to blit multisampled color-buffer to; used for shader operations (for postprocessing effects)
        glBindFramebuffer(GL_FRAMEBUFFER, this.FBO);
        this.texas.generate(width, height, null);

        // attach texture to framebuffer as its color attachment
        glFramebufferTexture2D(GL_FRAMEBUFFER,       // specifies the target buffer. Here the Frame buffer 
                               GL_COLOR_ATTACHMENT0, // GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, or GL_STENCIL_ATTACHMENT.
                               GL_TEXTURE_2D,        // specify the texture target  Could be one of GL_TEXTURE_CUBE_xxx resources.
                               this.texas.ID,        // specifies the texture object whose image is to be attached
                               0); 
   
        ret = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (ret != GL_FRAMEBUFFER_COMPLETE)
        {
            specifyError(ret);
            writeAndPause("Error: Post Processor failed to initialize FBO");
        }
        glBindFramebuffer(GL_FRAMEBUFFER, 0);

        // Initialize render data and uniforms
        this.initRenderData();
        this.postProcShader.setInteger("scene", 0, GL_TRUE);
        GLfloat offset = 1.0f / 300.0f;
        GLfloat[2][9] offsets = 
        [
            [ -offset,  offset  ],  // top-left
            [  0.0f,    offset  ],  // top-center
            [  offset,  offset  ],  // top-right
            [ -offset,  0.0f    ],  // center-left
            [  0.0f,    0.0f    ],  // center-center
            [  offset,  0.0f    ],  // center - right
            [ -offset, -offset  ],  // bottom-left
            [  0.0f,   -offset  ],  // bottom-center
            [  offset, -offset  ]   // bottom-right    
        ];
        glUniform2fv(glGetUniformLocation(this.postProcShader.ID, "offsets"), 9, cast(GLfloat*) offsets);

        GLint[9] edge_kernel = 
        [
            -1, -1, -1,
            -1,  8, -1,
            -1, -1, -1
        ];
        glUniform1iv(glGetUniformLocation(this.postProcShader.ID, "edge_kernel"), 9, edge_kernel.ptr);

        GLfloat[9] blur_kernel = 
        [
            1.0 / 16, 2.0 / 16, 1.0 / 16,
            2.0 / 16, 4.0 / 16, 2.0 / 16,
            1.0 / 16, 2.0 / 16, 1.0 / 16
        ];
        glUniform1fv(glGetUniformLocation(this.postProcShader.ID, "blur_kernel"), 9, blur_kernel.ptr);    
    }
  

 
    void beginRender()
    {
        glBindFramebuffer(GL_FRAMEBUFFER, this.MSFBO);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
    }


    void endRender()
    {
        // Now resolve multisampled color-buffer into intermediate FBO to store to texture
        glBindFramebuffer(GL_READ_FRAMEBUFFER, this.MSFBO);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, this.FBO);
        glBlitFramebuffer(0, 0, this.postProcWidth, this.postProcHeight, 0, 0, this.postProcWidth, this.postProcHeight, GL_COLOR_BUFFER_BIT, GL_NEAREST);
        glBindFramebuffer(GL_FRAMEBUFFER, 0); // Binds both READ and WRITE framebuffer to default framebuffer
    }

    void render(GLfloat time)
    {
        // Set uniforms/options
        this.postProcShader.use();
        this.postProcShader.setFloat("time", time);
        this.postProcShader.setInteger("confuse", this.confuse);
        this.postProcShader.setInteger("chaos",   this.chaos);
        this.postProcShader.setInteger("shake",   this.shake);
        // Render textured quad
        glActiveTexture(GL_TEXTURE0);
        this.texas.bind();
        glBindVertexArray(this.VAO);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArray(0);
    }

    // Initialize quad for rendering postprocessing texture
    void initRenderData()
    {
        // Configure VAO/VBO
        GLuint VBO;
        GLfloat[] vertices = 
        [
          // Pos        // Tex
        -1.0f, -1.0f, 0.0f, 0.0f,
         1.0f,  1.0f, 1.0f, 1.0f,
        -1.0f,  1.0f, 0.0f, 1.0f,

        -1.0f, -1.0f, 0.0f, 0.0f,
         1.0f, -1.0f, 1.0f, 0.0f,
         1.0f,  1.0f, 1.0f, 1.0f
        ];

        glGenVertexArrays(1, &this.VAO);
        glGenBuffers(1, &VBO);

        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, vertices.arrayByteSize, vertices.ptr, GL_STATIC_DRAW);

        glBindVertexArray(this.VAO);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * GLfloat.sizeof, cast(const(void)*) 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }

};












