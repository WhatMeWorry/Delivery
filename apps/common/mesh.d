
module mesh;

import common;


import gl3n.linalg; // vec3, vec2
//import ShaderClass;
import mytoolbox;  


import std.stdio; //  writeln

struct Vertex 
{
   vec3 Position;
   vec3 Normal;
   vec2 TexCoords;
   vec3 Tangent;
   vec3 Bitangent;
}

struct Texture 
{
   GLuint id;
   string type;
   aiString path;
}

class Mesh 
{
public:
    //  Mesh Data
    Vertex[]  vertices;
    GLuint[]  indices;
    Texture[] textures;
    GLuint VAO;

    // Constructor
    this(Vertex[] vertices, GLuint[] indices, Texture[] textures)
    {
        this.vertices = vertices;
        this.indices = indices;
        this.textures = textures;

        // Now that we have all the required data, set the vertex buffers and its attribute pointers.
        writeAndPause("Mesh Constructor - Call this.setupMesh");
        this.setupMesh();
        writeAndPause("After - this.setupMesh();");
    }
	
    // Render the mesh
    void draw(Shader shader) 
    {
        // Bind appropriate textures
        GLuint diffuseNr  = 1;
        GLuint specularNr = 1;
        GLuint normalNr   = 1;
        GLuint heightNr   = 1;
        //writeln("this.textures.length = ", this.textures.length);
        //writeAndPause("look at textures length");
        for(GLuint i = 0; i < this.textures.length; i++)
        {
            glActiveTexture(GL_TEXTURE0 + i); // Active proper texture unit before binding
            // Retrieve texture number (the N in diffuse_textureN)
            //stringstream ss;
            string number;
            string name = this.textures[i].type;

            //writeln("name = ", name);
            //writeAndPause(" ");

            //if(name == "texture_diffuse")
            //    ss << diffuseNr++; // Transfer GLuint to stream
            //else if(name == "texture_specular")
            //    ss << specularNr++; // Transfer GLuint to stream
            //number = ss.str(); 
            // Now set the sampler to the correct texture unit

            //TODO: glUniform1i(glGetUniformLocation(shader.Program, name + toString(number)), i);

            // And finally bind the texture
            glBindTexture(GL_TEXTURE_2D, this.textures[i].id);
        }

        // Also set each mesh's shininess property to a default value (if you want you could extend this to another mesh property and possibly change this value)
        glUniform1f(glGetUniformLocation(/+shader.Program+/ shader.ID, "material.shininess"), 16.0f);

        // Draw mesh
        glBindVertexArray(this.VAO);
        glDrawElements(GL_TRIANGLES, cast(int) this.indices.length, GL_UNSIGNED_INT, cast(const(void)*) 0);
        glBindVertexArray(0);

        // Always good practice to set everything back to defaults once configured.
        for (GLuint i = 0; i < this.textures.length; i++)
        {
            glActiveTexture(GL_TEXTURE0 + i);
            glBindTexture(GL_TEXTURE_2D, 0);
        }
    }

    //private:
    /*  Render data  */
    GLuint VBO, EBO;  // kludge make these accessable from outside class


public:  // kludge so to make setupMesh() accessable from outside class

    /*  Functions    */
    // Initializes all the buffer objects/arrays
    void setupMesh()
    {
	  writeln("within setupMesh");
        // Create buffers/arrays
        glGenVertexArrays(1, &this.VAO);
        glGenBuffers(1, &this.VBO);
        glGenBuffers(1, &this.EBO);

        glBindVertexArray(this.VAO);
        // Load data into vertex buffers
        glBindBuffer(GL_ARRAY_BUFFER, this.VBO);
        // A great thing about structs is that their memory layout is sequential for all its items.
        // The effect is that we can simply pass a pointer to the struct and it translates perfectly to a glm::vec3/2 array which
        // again translates to 3/2 floats which translates to a byte array.
        //glBufferData(GL_ARRAY_BUFFER, this->vertices.size() * sizeof(Vertex), &this->vertices[0], GL_STATIC_DRAW);
        //glBufferData(GL_ARRAY_BUFFER, this.vertices.length * Vertex.sizeof, &this.vertices[0], GL_STATIC_DRAW); 
		
		writeln("00");
        glBufferData(GL_ARRAY_BUFFER, this.vertices.length * Vertex.sizeof, this.vertices.ptr, GL_STATIC_DRAW);
		writeln("01");
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this.EBO);
		writeln("02");		
        //glBufferData(GL_ELEMENT_ARRAY_BUFFER, this.indices.length * GLuint.sizeof, &this.indices[0], GL_STATIC_DRAW);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, this.indices.length * GLuint.sizeof, this.indices.ptr, GL_STATIC_DRAW);		

			  writeln("1111111111111111111111");
		
        /+
        vec3 Position;
        vec3 Normal;
        vec2 TexCoords;
        vec3 Tangent;
        vec3 Bitangent;
        +/
        // Set the vertex attribute pointers
        //                                              stride         starting offset
        // Vertex Positions                                            cast(const(void)*) (3 * GLfloat.sizeof)
        glEnableVertexAttribArray(0);	
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(const(void)*) 0);  // Position 
        // Vertex Normals
        glEnableVertexAttribArray(1);	
        //glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(const(void)*) Vertex.Normal.offset );
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(const(void)*) (3 * GLfloat.sizeof) );
        // Vertex Texture Coords
        glEnableVertexAttribArray(2);	
        //glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), cast(const(void)*) offsetof(Vertex, TexCoords) );
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(const(void)*) (6 * GLfloat.sizeof) );      
        // Vertex Tangent
        glEnableVertexAttribArray(3);
        //glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), cast(const(void)*) offsetof(Vertex, Tangent));
        glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(const(void)*) (8 * GLfloat.sizeof) );
        // Vertex Bitangent
        glEnableVertexAttribArray(4);
        //glVertexAttribPointer(4, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), cast(const(void)*) offsetof(Vertex, Bitangent));
        glVertexAttribPointer(4, 3, GL_FLOAT, GL_FALSE, Vertex.sizeof, cast(const(void)*) (11 * GLfloat.sizeof) );      
        glBindVertexArray(0);
    }
};

	