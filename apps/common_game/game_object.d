module game_object;

import common;
import common_game;

import derelict.opengl3.gl3; // GLfloat, GLboolean
import gl3n.linalg;          // vec2, vec3
import mytoolbox;
import std.stdio;

// Container object for holding all state relevant for a single
// game object entity. Each object in the game likely needs the
// minimal of state as described within GameObject.

class GameObject
{
public:
    this(vec2 pos, vec2 size, Texture2D sprite, vec3 color, vec2 velocity)
    {
        this.position = pos;
        this.size = size;
        this.velocity = velocity;
        this.color = color;
        this.rotation = 0.0f;
        this.sprite = sprite;
        this.isSolid = false;
        this.destroyed = false;
    }

    // Object state
    vec2     position;
    vec2     size; 
    vec2     velocity;
    vec3     color;
    GLfloat  rotation;
    bool     isSolid;
    bool     destroyed;
    // Render state
    Texture2D sprite;	

	
    void traceGameObject()
    {
        writeln("position = ", this.position);
        writeln("size = ", this.size);
        writeln("velocity = ", this.velocity);

    }		
	
    void draw(SpriteRenderer renderer)
    {
        renderer.drawSprite(this.sprite, this.position, this.size, this.rotation, this.color);
    }
}

