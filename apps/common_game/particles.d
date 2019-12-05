
module particles;

//import common;
//import common_game;

import gl3n.linalg : mat4, vec2, vec3, vec4; 
import std.random;
import std.stdio;



// Represents a single particle and its state
struct Particle 
{
    vec2 position = 0.0; 
    vec2 velocity = 0.0;
    vec4 color = 1.0;
    GLfloat life = 0.0f;

    //Particle() : Position(0.0f), Velocity(0.0f), Color(1.0f), Life(0.0f) { }
};


// ParticleGenerator acts as a container for rendering a large number of 
// particles by repeatedly spawning and updating particles and killing 
// them after a given amount of time.
class ParticleGenerator
{
public:

    // Constructor
    this(ShaderBreakout shader, Texture2D texture, GLuint amount)
    {
        this.shader = shader;
        this.texture = texture;
        this.amount = amount;
        this.init();
    }


    // Update all particles

    void update(GLfloat dt, GameObject object, GLuint newParticles, vec2 offset = vec2(0.0f, 0.0f))
    {
        // Add new particle 
        if (hasThisFuncBeenCalledThisManyTimes(5))
 
        {
            for (GLuint i = 0; i < newParticles; i++)
            {
                int unusedParticle = this.firstUnusedParticle();
                this.respawnParticle(this.particles[unusedParticle], object, offset);
            }
        }
        // Update all particles
        for (GLuint i = 0; i < this.amount; ++i)
        {
            //Particle p = Particle();
            //p = this.particles[i];
            //p.Life -= dt; // reduce life
  
            if (this.particles[i].life > 0.0f)
            {   // particle is alive, thus update
                float decayFactor = 6.0;
                this.particles[i].life -= dt * decayFactor;

                this.particles[i].position -= this.particles[i].velocity * dt; 
                //p.Color.a -= dt * 2.5;

                this.particles[i].color.a -= dt * decayFactor;  // lower alpha (make more transparent)
            }
        }

    }

    // Render all particles
    void draw()
    {
        // Use additive blending to give it a 'glow' effect
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        this.shader.use();
        foreach(particle ; this.particles)
        {
            if (particle.life > 0.0f)
            {
                this.shader.setVector2f("offset", particle.position, true);
                this.shader.setVector4f("color", particle.color, true);
                this.texture.bind();
                glBindVertexArray(this.VAO);
                glDrawArrays(GL_TRIANGLES, 0, 6);
                glBindVertexArray(0);
            }
        }
        // Don't forget to reset to default blending mode
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }

private:
    // State
    Particle[]     particles;
    GLuint         amount;
    ShaderBreakout shader;
    Texture2D      texture;
    GLuint         VAO;
    // Initializes buffer and vertex attributes
    // void ParticleGenerator::init()
    void init()
    {
        // Set up mesh and attribute properties
        GLuint VBO;
        GLfloat[] particle_quad = 
        [
            0.0f, 1.0f, 0.0f, 1.0f,
            1.0f, 0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 0.0f, 0.0f,

            0.0f, 1.0f, 0.0f, 1.0f,
            1.0f, 1.0f, 1.0f, 1.0f,
            1.0f, 0.0f, 1.0f, 0.0f
        ]; 
        glGenVertexArrays(1, &this.VAO);
        glGenBuffers(1, &VBO);
        glBindVertexArray(this.VAO);
        // Fill mesh buffer
            glBindBuffer(GL_ARRAY_BUFFER, VBO);
                glBufferData(GL_ARRAY_BUFFER, particle_quad.arrayByteSize, particle_quad.ptr, GL_STATIC_DRAW);
                glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * GLfloat.sizeof, cast(const(void)*) 0);
                glEnableVertexAttribArray(0);
            glBindBuffer(GL_ARRAY_BUFFER, 0); 
        glBindVertexArray(0);

        // Create this->amount default particle instances
        foreach( i; 0..this.amount)
        {
            //this->particles.push_back(Particle());
            this.particles ~= Particle();
        }
    }




    // Stores the index of the last particle used (for quick access to next dead particle)
    GLuint lastUsedParticle = 0;

    // Returns the first Particle index that's currently unused, Life <= 0.0f or
    // 0 if all particles are in use.

    GLuint firstUnusedParticle()
    {
        // First search from last used particle, this will usually return almost instantly
        for (GLuint i = lastUsedParticle; i < this.amount; ++i)
        {
            if (this.particles[i].life <= 0.0f)
            {
                lastUsedParticle = i;
                return i;
            }
        }
        // Otherwise, do a linear search
        for (GLuint i = 0; i < lastUsedParticle; ++i)
        {
            if (this.particles[i].life <= 0.0f)
            {
                lastUsedParticle = i;
                return i;
            }
        }
        // All particles are taken, override the first one (note that if it repeatedly hits this case, more particles should be reserved)
        lastUsedParticle = 0;
        return 0;
    }


    // Respawns particle
    //void respawnParticle(Particle particle, GameObject object, vec2 offset = vec2(0.0f, 0.0f));

    void respawnParticle(ref Particle particle, GameObject object, vec2 offset = vec2(0.0f, 0.0f))
    {
        // GLfloat random = ((rand() % 100) - 50) / 10.0f;  
        // rand() returns a random number between 0 and a large number.
        // % 100 gets the remainder after dividing by 100, which will be an integer from 0 to 99 inclusive.
        // - 50 will change the range from -50 to 50
        // / 10.0 will change the range from -5 to 5

        //writeln("Inside respawnParticle");

        auto gen = Random(unpredictableSeed);
        
        GLfloat random = uniform(-5, 6, gen);
        //GLfloat rColor = 0.5 + ((rand() % 100) / 100.0f);

        //GLfloat rColor = 0.5 + (uniform(0, 100, gen) / 100.0f);
        GLfloat rColor = 0.5;  // originally 0.5

        // rand() returns a random number between 0 and a large number.
        // % 100 gets the remainder after dividing by 100, which will be an integer from 0 to 99 inclusive.
        // / 100.0 will change range from 0.0, .01, ... .99 

        particle.position.x = object.position.x + random + offset.x;
        particle.position.y = object.position.y + random + offset.y;
        particle.color = vec4(rColor, rColor, rColor, 1.0f);
        particle.life = 1.0f;

        // let's try just keeping the particles stationary
        //particle.Velocity = object.Velocity * 0.1f;


        //writeln("particle = ", particle);
        //writeAndPause("done with a spawn or respawn");
    }
};












