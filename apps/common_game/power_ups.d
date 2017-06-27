
module power_ups;

import common;
import common_game;

import derelict.opengl3.gl3;
import gl3n.linalg : mat4, vec2, vec3, vec4; 
import std.random;
import std.stdio;

enum vec2 powerUpSize = vec2(60, 20);
enum vec2 powerUpVelocity = vec2(0.0f, 150f);

class PowerUp : GameObject 
{
public:
    // PowerUp State
    string     type;
    GLfloat    duration;	
    GLboolean  activated;
    // Constructor
    this(string type, vec3 color, GLfloat duration, vec2 position, Texture2D texture)
    {
        super(position, powerUpSize, texture, color, powerUpVelocity);
        this.type = type;
        this.duration = duration;
        this.activated = false;		
    }
	
	void display()
    {
        writeln("type = ", type);	
        writeln("position = ", position);
        writeln("duration = ", duration);	
        writeln("powerUpSize = ", powerUpSize);	
    }

	
	
	
	
	
} 