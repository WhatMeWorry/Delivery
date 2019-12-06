module ball_object;

//import app;     // for traits flag 
//import common;
//import common_game;

import gl3n.linalg;
import std.stdio;             // writeln

import dynamic_libs.opengl : GLboolean, GLfloat, GLuint; 

import game_object : GameObject;  //  Error: undefined identifier GameObject
import texture_2d : Texture2D;    // 

// BallObject holds the state of the Ball object inheriting
// relevant state data from GameObject. Contains some extra
// functionality specific to Breakout's ball object that
// were too specific for within GameObject alone.
//class SubClass : SuperClass   
class BallObject : GameObject
{
public:
    // Ball state
    GLfloat   radius;
    GLboolean stuck;
    //static if (__traits(compiles,powUps) && powUps)
    //{
    GLboolean sticky;
    GLboolean passThrough;
    //}
    // Constructor(s)
    //this();
    this(vec2 pos, GLfloat radius, vec2 velocity, Texture2D sprite)
    {
           //this(vec3 color, vec2 velocity)
        super(pos, vec2(radius*2, radius*2), sprite, vec3(1.0f), velocity);
        this.radius = radius;
        this.stuck = true; 
        static if (__traits(compiles,powUps) && powUps)
        {
        this.sticky = false;
        this.passThrough = false;
        }
    }

    // Moves the ball, keeping it constrained within the window bounds (except 
    // bottom edge); returns new position
    vec2 move(GLfloat dt, GLuint windowWidth)
    {
        // writeln("this.stuck = ", this.stuck);
        // If not stuck to player board
        if (!(this.stuck))
        { 
            // Move the ball
            this.position += this.velocity * dt;

            // Check if outside window bounds; if so, reverse velocity and restore at correct position
            if (this.position.x <= 0.0f)
            {
                this.velocity.x = -this.velocity.x;
                this.position.x = 0.0f;
            }
            else if (this.position.x + this.size.x >= windowWidth)
            {
                this.velocity.x = -this.velocity.x;
                this.position.x = windowWidth - this.size.x;
            }
            if (this.position.y <= 0.0f)
            {
                this.velocity.y = -this.velocity.y;
                this.position.y = 0.0f;
            }

        }
        return this.position;
    }

    // Resets the ball to original state with given position and velocity
    void reset(vec2 position, vec2 velocity)
    {
        this.position = position;
        this.velocity = velocity;
        this.stuck = true;
        static if (__traits(compiles,powUps) && powUps)
        {
        this.sticky = GL_FALSE;
        this.passThrough = GL_FALSE;      
        }
    }
}