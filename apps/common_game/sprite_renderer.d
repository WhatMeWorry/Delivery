module sprite_renderer;

import common;
import common_game;

import gl3n.linalg;  // vec2  vec3

alias ROW_MAJOR = GL_TRUE;
alias COL_MAJOR = GL_FALSE;

class SpriteRenderer
{
public:
    // Constructor (inits shaders/shapes)
    this(ShaderBreakout shader)
    {
        this.shader = shader;
        this.initRenderData();
    }
    ~this()
    {
        glDeleteVertexArrays(1, &this.quadVAO);
    } 
	
    // Renders a defined quad textured with given sprite
    void drawSprite(Texture2D texture, 
                    vec2 position, 
                    vec2 size = vec2(10, 10), 
                    GLfloat angle = 0.0f, 
                    vec3 color = vec3(0.0f, 1.0f, 0.0f) )
    {
        // Prepare transformations

        /+ Translate matrix   Scaling Matrix
        1 0 0 X               X 0 0 0
        0 1 0 Y               0 Y 0 0
        0 0 1 Z               0 0 Z 0
        0 0 0 1               0 0 0 1
        +/
        /+
        Until then, we only considered 3D vertices as a (x,y,z) triplet. Let’s introduce w.
        We will now have (x,y,z,w) vectors. This will be more clear soon, but for now, just 
        remember this :

        If w == 1, then the vector (x,y,z,1) is a position in space.
        If w == 0, then the vector (x,y,z,0) is a direction.
        +/

        this.shader.use();
        mat4 model = mat4.identity;

        // Note: Matrix Multiplication is not commutative!
        //       Order matters!

        mat4 translationMatrix = mat4.identity;
        translationMatrix = translationMatrix.translate(vec3(position, 1.0f));

        // specified the quad's vertices with (0,0) as the top-left 
        // coordinate of the quad, Rotations always revolve around the origin. 
        // Need to center quad (sprite/texture) about the center
 
        mat4 rotationMatrix = mat4.identity;
        {
            mat4 centerSprite = mat4.identity;
            centerSprite = centerSprite.translate(vec3(0.5f * size.x, 0.5f * size.y, 0.0f));

            mat4 rotMatrix = mat4.identity;
            rotMatrix = rotMatrix.rotate(angle, vec3(0.0f, 0.0f, 1.0f));

            mat4 uncenterSprite = mat4.identity;
            uncenterSprite = uncenterSprite.translate(vec3(-0.5f * size.x, -0.5f * size.y, 0.0f));

            rotationMatrix = centerSprite * rotMatrix * uncenterSprite;
        }

        mat4 scalingMatrix = mat4.identity; 
        scalingMatrix = scalingMatrix.scaling(size.x, size.y, 1.0f);

        model = translationMatrix * rotationMatrix * scalingMatrix;

        /+
        If transpose is GL_FALSE, each matrix is assumed to be supplied in column major order. 
        If transpose is GL_TRUE, each matrix is assumed to be supplied in row major order. The 
        count argument indicates the number of matrices to be passed. A count of 1 should be 
        used if modifying the value of a single matrix, and a count greater than 1 can be used to 
        modify an array of matrices
        +/

        // This model is created using gl3n; matrices in gl3n are in row major order

        this.shader.setMatrix4("model", model, ROW_MAJOR, true );
        this.shader.setVector3f("spriteColor", color, true);

        glActiveTexture(GL_TEXTURE0);
        texture.bind();

        glBindVertexArray(this.quadVAO);
            glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArray(0);
    }
private:

    ShaderBreakout shader; 
    GLuint         quadVAO;
	
    // Initializes and configures the quad's buffer and vertex attributes
    void initRenderData()
    {
        // Configure VAO/VBO
        GLuint VBO;
        GLfloat[] vertices = 
		[   // Position   // Texture coords
            0.0f, 1.0f, 0.0f, 1.0f,
            1.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 0.0f, 

            0.0f, 1.0f, 0.0f, 1.0f,
            1.0f, 1.0f, 1.0f, 1.0f,
            1.0f, 0.0f, 1.0f, 0.0f
        ];

        glGenVertexArrays(1, &this.quadVAO);
        glGenBuffers(1, &VBO);

        glBindVertexArray(this.quadVAO);
            glBindBuffer(GL_ARRAY_BUFFER, VBO);
                glBufferData(GL_ARRAY_BUFFER, vertices.arraySizeInBytes, vertices.ptr, GL_STATIC_DRAW);
                glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * GLfloat.sizeof, cast(const(void)*) 0 );
                glEnableVertexAttribArray(0);
            glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }
};



