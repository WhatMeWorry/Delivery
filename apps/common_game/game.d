module game;

import app;

import common;
import common_game;

//import derelict.opengl3.gl3;
import gl3n.linalg;               // vec2
import std.algorithm.comparison;  // clamp
import std.stdio;                 // writeln
import std.typecons;              // Tuple
import std.math;                  // abs  pow  fmax  fmin
import std.algorithm.comparison;  // clamp
import std.random : dice;
import std.conv : to;

// current state of the game
enum GameState 
{
    GAME_ACTIVE,
    GAME_MENU,
    GAME_WIN
};


// Represents the four possible (collision) directions
enum Direction 
{
    UP,
    RIGHT,
    DOWN,
    LEFT
};

// Defines a Collision typedef that represents collision data
//typedef std::tuple<GLboolean, Direction, glm::vec2> Collision; 

// Struct Tuple
//
// Tuple of values, for example Tuple!(int, string) is a record that stores 
// an int and a string. Tuple can be used to bundle values together, notably 
// when returning multiple values from a function. If obj is a Tuple, the 
// individual members are accessible with the syntax obj[0] for the first field,
// obj[1] for the second, and so on.

// The choice of zero-based indexing instead of one-base indexing was motivated 
// by the ability to use value Tuples with various compile-time loop constructs 
// (e.g. std.meta.AliasSeq iteration), all of which use zero-based indexing.

// typedef std::tuple<GLboolean, Direction, glm::vec2> Collision;  
// <collision?, what direction?, difference vector center - closest point>
alias Collision = Tuple!(GLboolean, Direction, vec2);
//alias Collision = AliasSeq!(GLboolean, Direction, vec2);

// the problem is D functions cannot return language tuples (only TypeTuple from 
// std.typecons which is what the tuple() call creates) so you would always need 
// to call "expand" before the function call



// Initial size of the player's paddle
enum vec2 PaddleSize = vec2(100, 20);              // originally (100, 20)   //  (200, 40) for 4K monitors


// Initial velocity of the player's paddle
enum GLfloat PaddleVelocity = 500.0f;              // originally 500.0f      // 4000.0 for 4K monitor

// Initial velocity of the Ball
enum vec2 BallVelocity = vec2(100.0f, -350.0f);  // originally (100.0f, -350.0f);  // (1600.0f, -5600.0f) for 4K monitors


// Radius of the ball object
const GLfloat BallRadius = 12.5f;                  // originally 12.5        // 25.0f for 4K monitor

SpriteRenderer    renderer; // just a declaration (no memory allocation)
GameObject        paddle;   // just a declaration (no memory allocation)
BallObject        ball;     // just a declaration (no memory allocation)
ParticleGenerator partGen;  // just a declaration (no memory allocation)
PostProcessor     postProc; // just a declaration (no memory allocation)
GLfloat           shakeTime = 0.0f;

// Game holds all game-related state and functionality.
// Combines all game-related data into a single class for
// easy access to each of the components and manageability.


class Game
{
public:
    // Game state
    GameState   state;	
    static      GLboolean[512] keys;
    GLuint      width;
    GLuint      height;

    GameLevel[] levels;
    GLuint      currentLevel;
	
    static if (__traits(compiles,powUps) && powUps)
    {
        PowerUp[] powerUps;
    }
    
    /+
    static if (__traits(compiles,crap) && crap)
    {
    GLuint  width;
    }
    +/
	
    static if (__traits(compiles, screenText) && screenText)
    {
    GLuint  lives;
    }
	
    // Constructor/Destructor	
    this(GLuint width, GLuint height)
    {
        state = GameState.GAME_ACTIVE;
        this.width = width; 
        this.height = height; 
		
        static if (__traits(compiles, screenText) && screenText)
        {
        lives = 3;			
        }
	
		
    }


    void doCollisions_02()
    {
        foreach(i, box; this.levels[this.currentLevel].bricks)
        {
            //writeln("box ", i, " box.Destroyed = ", box.Destroyed);
            if (!box.destroyed)
            {
                //if (CheckCollision(Ball, box))
                if (checkRectCollision_02(ball, box))
                {
                    //writeAndPause("Collision Detected");
                    if (!box.isSolid)
                    {
                        box.destroyed = GL_TRUE;
                        //writeAndPause("box is Destroyed");
                    }
                }
            }
        }       
    }

	

    GLboolean checkRectCollision_02(GameObject one, GameObject two) // AABB - AABB collision
    {
        // Collision x-axis?
        bool collisionX = ((one.position.x + one.size.x) >= two.position.x) &&
                          ((two.position.x + two.size.x) >= one.position.x);

        // Collision y-axis?
        bool collisionY = ((one.position.y + one.size.y) >= two.position.y) &&
                          ((two.position.y + two.size.y) >= one.position.y);

        //writeln("collisionX = ", collisionX);
        //writeln("collisionY = ", collisionY);

        // Collision only if on both axes
        return collisionX && collisionY;
    } 




    Collision doesCircleCollideWithRect(BallObject circle, ref GameObject rect)  // AABB - Circle collision
    {
        // Get center point of the circle first 
		
        vec2 circCenter = vec2(circle.position.x + circle.radius, circle.position.y + circle.radius);
		
        float deltaX = circCenter.x - fmax(rect.position.x, fmin(circCenter.x, rect.position.x + rect.size.x));
        float deltaY = circCenter.y - fmax(rect.position.y, fmin(circCenter.y, rect.position.y + rect.size.y));		
	
        // writeln("center of circle = ", circCenter);
        // writeln("deltas squared = ",(deltaX * deltaX + deltaY * deltaY));
        // writeln("circle.radius squared = ",(circle.radius * circle.radius));	

        vec2 rectCenter = vec2( (rect.position.x + (rect.size.x / 2.0)), (rect.position.y + (rect.size.y / 2.0)) );
		 
        // Get difference vector between both centers
        vec2 difference = circCenter - rectCenter;		

        Collision hitOrMiss;
		
        if ((deltaX * deltaX + deltaY * deltaY) <  (circle.radius * circle.radius))
        {
            hitOrMiss[0] = GL_TRUE;
            hitOrMiss[1] = VectorDirection(difference);
            hitOrMiss[2] = difference;
        }
        else
        {
            hitOrMiss[0] = GL_FALSE;
            hitOrMiss[1] = Direction.UP;
            hitOrMiss[2] = vec2(0,0);
        }
 
        return hitOrMiss;
    }	
	
	
	
	
	
    GLboolean checkCollisionCircleWithRectReturnBool(BallObject one, GameObject two) // AABB - Circle collision
    {
	
        // glm::vec2 center(one.Position + one.Radius);  // original C++ code
        // It works via operator overloading, and adding a scalar simply means 
		// adding it to all vector components.	
		
        // Get center point of the circle first 
		
        vec2 center = vec2(one.position.x + one.radius, one.position.y + one.radius);
		
		writeln("center = ", center);
		
		
        // Calculate AABB info (center, half-extents)
        vec2 aabb_half_extents = vec2( (two.size.x / 2), (two.size.y / 2) );
		
        vec2 aabb_center = vec2(two.position.x + aabb_half_extents.x, 
                                two.position.y + aabb_half_extents.y);
								
         writeln("aabb_half_extents = ", aabb_half_extents);
        writeln("aabb_center = ", aabb_center);		 
		 
        // Get difference vector between both centers
        vec2 difference = center - aabb_center;
		
		writeln("difference between both centers = ", difference);
		
        vec2 clamped = clamp(difference, -aabb_half_extents, aabb_half_extents);
		
        writeln("clamped = ", clamped);
		writeAndPause(" ");
		
		
        // float clamp(float value, float min, float max) 
        // {
        //    return std::max(min, std::min(max, value));  C++ code
        // }
		
        // auto clamp(T1, T2, T3)(T1 val, T2 lower, T3 upper);   D code
        // This functions is equivalent to max(lower, min(upper, val)).		
		
        // Add clamped value to AABB_center and we get the value of box closest to circle
        vec2 closest = aabb_center + clamped;   
        // Retrieve vector between center circle and closest point AABB and check if length <= radius
        difference = closest - center;

        //return glm::length(difference) < one.Radius;
        // genType::value_type glm::length(genType const &x)	
        // Returns the length of x, i.e., sqrt(x * x).

        /// Returns the magnitude of the vector.
        // @property real magnitude() const 
        // {
        //    return sqrt(magnitude_squared);
        // }
        // alias magnitude_squared length_squared; /// ditto
        // alias magnitude length; /// ditto
	

        //return (difference.length < one.radius);
		
        GLboolean hit = false;
        if (difference.magnitude < one.radius)		
        {
            hit = true;
        }
        return hit;		
    }  


    void init()
    {
		writeAndPause("Before e_manager.ResMgr.loadShader");	
        resource_manager.ResMgr.loadShader("source/VertexShader.glsl", 
                                           "source/FragmentShader.glsl", 
                                           null, "sprite");

        mat4 projection = orthographicFunc(0.0, this.width, this.height, 0.0, -1.0f, 1.0f);

        /+
        Uniforms are another way to pass data from our application on the CPU to the shaders 
        on the GPU, but uniforms are slightly different compared to vertex attributes. First 
        of all, uniforms are global. Global, meaning that a uniform variable is unique per shader 
        program object, and can be accessed from any shader at any stage in the shader program. 
        Second, whatever you set the uniform value to, uniforms will keep their values until 
        they’re either reset or updated.
        +/

        ShaderBreakout sB = resource_manager.ResMgr.getShader("sprite");

        sB.use();

        // The default texture unit for a texture is 0 which is the default active 
        // texture unit so we did not had to assign a location in the previous section.
			
        sB.setInteger("image", 0);   // in Fragment Shader
                                     // glUniform1i(glGetUniformLocation(this.ID, name), value);
                                     // uniform sampler2D image;	
        /+
        You probably wondered why the sampler2D variable is a uniform if we didn’t even assign it 
        some value with glUniform. Using glUniform1i we can actually assign a location value to 
        the texture sampler so we can set multiple textures at once in a fragment shader. This 
        location of a texture is more commonly known as a texture unit. The default texture unit 
        for a texture is 0 which is the default active texture unit so we did not had to assign a 
        location in the previous section.

        The main purpose of texture units is to allow us to use more than 1 texture in our shaders. 
        By assigning texture units to the samplers, we can bind to multiple textures at once as long 
        as we activate the corresponding texture unit ﬁrst. Just like glBindTexture we can activate 
        texture units using glActiveTexture passing in the texture unit we’d like to use:
            glActiveTexture(GL_TEXTURE0); // Activate the texture unit first before binding texture 
            glBindTexture(GL_TEXTURE_2D, texture);
            After activating a texture unit, a subsequent glBindTexture call will bind th
        +/

        sB.setMatrix4("projection", projection, COL_MAJOR, true);  // in Vertex Shader
                                                                   // uniform mat4 projection;
        // Load textures
        GLuint tempTexID;
        Texture2D tempTexture = new Texture2D();

        import texturefuncs;
        loadTextureKCH_Unique(tempTexture.ID, "../art/awesomeface.png");

        tempTexture.friendlyName = "face";

        resource_manager.ResMgr.aaTextures["face"] = tempTexture;

        foreach( tex; resource_manager.ResMgr.aaTextures)
        {
            //writeln("FOREACH tex.ID = ", tex.ID);
            //writeln("FOREACH tex = ", tex.friendlyName);
        }

        sB = resource_manager.ResMgr.getShader("sprite");

                    // SpriteRenderer constructor calls initRenderData();		
        renderer = new SpriteRenderer(resource_manager.ResMgr.getShader("sprite"));
    }
	

//=========================================================================================================

	
    // Initialize game state (load all shaders/textures/levels)
    void initGame()
    {
        resource_manager.ResMgr.loadShader("source/VertexShader.glsl", 
                                           "source/FragmentShader.glsl", 
                                           null, "sprite");

        // ..\common_game\game.d(371,21): Error: module particles is not an expression
        // particles conflicted with module particles.d   Had to pick another flag variable name
        static if (__traits(compiles, particulate) && particulate)   // inject code only if using post processor effects
        {										   
        resource_manager.ResMgr.loadShader("source/VertexShaderParticle.glsl", 
                                           "source/FragmentShaderParticle.glsl", 
                                           null, "particle");
        } 
       
		
        static if (__traits(compiles, effects) && effects)   // inject code only if using post processor effects
        {
        resource_manager.ResMgr.loadShader("source/VertexShaderEffects.glsl", 
                                           "source/FragmentShaderEffects.glsl", 
                                           null, "effects");											   
        }
		
        static if (__traits(compiles, screenText) && screenText)
        {
            textRend = new TextRenderer(this.width, this.height);
			writeln("textRend.textShader.ID = ", textRend.textShader.ID);
			
            textRend.load("../fonts/ocraext.ttf", 24);
        } 		
      	

        mat4 projection = orthographicFunc(0.0, this.width, this.height, 0.0, -1.0f, 1.0f);


        // ResourceManager::GetShader("sprite").Use().SetInteger("sprite", 0);  // changed sprite to image	
		
        ShaderBreakout sB = resource_manager.ResMgr.getShader("sprite");
        sB.use();
        sB.setInteger("image", 0);   // in Fragment Shader: FragmentShader.glsl
                                     // glUniform1i(glGetUniformLocation(this.ID, name), value);
                                     // uniform sampler2D image;	
		
        // ResourceManager::GetShader("sprite").SetMatrix4("projection", projection);		

        sB.setMatrix4("projection", projection, COL_MAJOR, true);  // in Vertex Shader
                                                                   // uniform mat4 projection;

        // ResourceManager::GetShader("particle").Use().SetInteger("sprite", 0);

        static if (__traits(compiles, particulate) && particulate)	
        {		
        ShaderBreakout sB2 = resource_manager.ResMgr.getShader("particle");
        sB2.use();
        sB2.setInteger("sprite", 0);   // in Fragment Shader: FragmentShaderParticle.glsl

        sB2.setMatrix4("projection", projection, COL_MAJOR, true); 
        }
				
																   
        // Load textures
        Texture2D tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/awesomeface.png");
        tempTexture.friendlyName = "face";
        resource_manager.ResMgr.aaTextures["face"] = tempTexture;  // save if off in static associative array

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/background.jpg");
        tempTexture.friendlyName = "background";
        resource_manager.ResMgr.aaTextures["background"] = tempTexture;

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/block.png");
        tempTexture.friendlyName = "block";
        resource_manager.ResMgr.aaTextures["block"] = tempTexture;

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/block_solid.png");
        tempTexture.friendlyName = "block_solid";
        resource_manager.ResMgr.aaTextures["block_solid"] = tempTexture;

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/paddle.png");
        tempTexture.friendlyName = "paddle";
        resource_manager.ResMgr.aaTextures["paddle"] = tempTexture;
		
        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/face.png");
        tempTexture.friendlyName = "face";
        resource_manager.ResMgr.aaTextures["face"] = tempTexture;
		
        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/small_face.png");
        tempTexture.friendlyName = "small_face";
        resource_manager.ResMgr.aaTextures["small_face"] = tempTexture;	

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/particle.png");
        tempTexture.friendlyName = "particle";
        resource_manager.ResMgr.aaTextures["particle"] = tempTexture;			

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/powerup_speed.png");
        tempTexture.friendlyName = "tex_speed";
        resource_manager.ResMgr.aaTextures["tex_speed"] = tempTexture;		

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/powerup_sticky.png");
        tempTexture.friendlyName = "tex_sticky";
        resource_manager.ResMgr.aaTextures["tex_sticky"] = tempTexture;		

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/powerup_increase.png");
        tempTexture.friendlyName = "tex_size";
        resource_manager.ResMgr.aaTextures["tex_size"] = tempTexture;		
		
	    tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/powerup_confuse.png");
        tempTexture.friendlyName = "tex_confuse";
        resource_manager.ResMgr.aaTextures["tex_confuse"] = tempTexture;

        tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/powerup_chaos.png");
        tempTexture.friendlyName = "tex_chaos";
        resource_manager.ResMgr.aaTextures["tex_chaos"] = tempTexture;		
		
	    tempTexture = new Texture2D();
        loadTextureKCH_Unique(tempTexture.ID, "../art/powerup_passthrough.png");
        tempTexture.friendlyName = "tex_pass";
        resource_manager.ResMgr.aaTextures["tex_pass"] = tempTexture;




		
        // Set render-specific controls
        // Renderer = new SpriteRenderer(ResourceManager::GetShader("sprite"));

        renderer = new SpriteRenderer(resource_manager.ResMgr.getShader("sprite"));

        static if (__traits(compiles, particulate) && particulate)
        {		
        partGen = new ParticleGenerator(resource_manager.ResMgr.getShader("particle"), 
                                        resource_manager.ResMgr.getTexture("particle"), 
                                        500);
        }

        static if (__traits(compiles, effects) && effects)		
        {
		
        //PostProcessor postProc = new PostProcessor(resource_manager.ResMgr.getShader("effects"),
        //                                           this.width, this.height); 
        // BAD BUG: this makes a new local scope variable called postProc.  Not the module scope 
        writeln("****************this.width = ", this.width, " this.height = ", this.height);

        int pixelWidth, pixelHeight;
        glfwGetFramebufferSize(winMain, &pixelWidth, &pixelHeight); 

        postProc = new PostProcessor(resource_manager.ResMgr.getShader("effects"),
                                     pixelWidth, pixelHeight);  
        // Mac OS (Screen)
        // this.width and this.height are in Screen Coordinate size.  Need pixel sizes
        // on Mac machines with Retina.
        // Windows and Linux seem to have the their screen coordinates scale to pixels.
        //postProc = new PostProcessor(resource_manager.ResMgr.getShader("effects"),
        //                             this.width, this.height);  		
        }		

        // Load levels
        GameLevel level1 = new GameLevel; 
        level1.loadLevel("../levels/level1.txt", this.width, cast(GLuint) (this.height * 0.5));
        GameLevel level2 = new GameLevel; 
        level2.loadLevel("../levels/level2.txt", this.width, cast(GLuint) (this.height * 0.5));
        GameLevel level3 = new GameLevel; 
        level3.loadLevel("../levels/level3.txt", this.width, cast(GLuint) (this.height * 0.5));
        GameLevel level4 = new GameLevel; 
        level4.loadLevel("../levels/level4.txt", this.width, cast(GLuint) (this.height * 0.5));

        //writeAndPause("All 4 levels have been Loaded");

        this.levels ~= level1;
        this.levels ~= level2;
        this.levels ~= level3;
        this.levels ~= level4;
		
        this.currentLevel = 0;  // start game off at first level

 
				   
        // Configure game objects
        vec3 color = vec3(0.0, 0.5, 0.5);
        vec2 velocity = vec2(0.0, 0.0);
        vec2 paddlePos = vec2((this.width / 2) - (PaddleSize.x / 2), this.height - PaddleSize.y);
        paddle = new GameObject(paddlePos, 
                                PaddleSize, 
                                resource_manager.ResMgr.getTexture("paddle"),
                                color, velocity);
								
        vec2 ballPos = paddlePos + vec2(PaddleSize.x / 2 - BallRadius, -BallRadius * 2);

        ball = new BallObject(ballPos, BallRadius, BallVelocity,
                              resource_manager.ResMgr.getTexture("small_face"));												
    }	
	
		
    // GameLoop
    void processInput(GLfloat dt)
    {
        if (this.state == GameState.GAME_ACTIVE)
        {
            // this is entered
            GLfloat velocity = PaddleVelocity * dt;
            // Move player's paddle
            if (Game.keys[GLFW_KEY_A])
            {
                if (paddle.position.x >= 0)
                {
                    paddle.position.x -= velocity;
                    if (ball.stuck)
                    {
                        ball.position.x -= velocity;					
                    }

                }						
            }
            if (Game.keys[GLFW_KEY_D])
            {
                if (paddle.position.x <= (this.width - paddle.size.x))
                {
                    paddle.position.x += velocity;
                    if (ball.stuck)
                    {
                        ball.position.x += velocity;					
                    }					
                }						
            }
            if (Game.keys[GLFW_KEY_SPACE])
            {
                ball.stuck = false;			
			}					
        }
    }
	

	
    void update(GLfloat dt)
    {   

    }		

    void update_01(GLfloat dt)
    {   
        ball.move(dt, this.width);
    }		
	

    void update_02(GLfloat dt)
    {
        // Update objects
		ball.move(dt, this.width);
		
        // Check for collisions
        this.doCollisions_02();
    }
	
    void update_03(GLfloat dt)
    {
        // Update objects
		ball.move(dt, this.width);
		
        // Check for collisions
        this.doCollisions_03();
		
        // Check loss condition
        if (ball.position.y >= this.height) // Did ball reach bottom edge?
        {
            this.resetLevel();
            this.resetPlayer();
        }
    }

    void update_04(GLfloat dt)
    {
        // Update objects
		ball.move(dt, this.width);

        static if (__traits(compiles, particulate) && particulate)
        {		
        partGen.update(dt, ball, 1, vec2(ball.radius / 2));       // Update particles		
        }
		
        // Update PowerUps
        static if (__traits(compiles,powUps) && powUps)
        {				
        this.updatePowerUps(dt);
        }		
		
        // Check for collisions
        this.doCollisions_03();
		
        static if (__traits(compiles, effects) && effects)  // only include this code block if using game effects      
        {		
        if (shakeTime > 0.0f)
        {
            shakeTime -= dt;
            if (shakeTime <= 0.0f)
                postProc.shake = false;
        }   
        }	

        // Check loss condition
        if (ball.position.y >= this.height) // Did ball reach bottom edge?
        {
            static if (__traits(compiles, screenText) && screenText)
            {  		
            this.lives--;
			// Did the player lose all his lives? : Game over
            if (this.lives == 0)
            {	
                this.resetLevel();
                this.state = GameState.GAME_MENU;
            }
            }
            this.resetPlayer();
        }		
    }
	
	
    void render()
    {       
        renderer.drawSprite(resource_manager.ResMgr.getTexture("face"), 
                                                   vec2(200, 200), 
                                                   vec2(100, 100),
                                                   45.0f, 
                                                   vec3(0.0f, 1.0f, 0.0f));
    }
	
	
    void renderGame()
    {
        if(this.state == GameState.GAME_ACTIVE)
        {
            writeln("this.width = ", this.width, " this.height = ", this.height);
            renderer.drawSprite(resource_manager.ResMgr.getTexture("background"), 
                                vec2(0, 0), 
                                vec2(this.width, this.height),
                                0.0f, 
                                //vec3(0.3f, 0.3f, 0.75f));   // original values
                                vec3(0.95f, 0.95f, 0.95f));                               
								
            paddle.draw(renderer);

            ulong len = this.levels[0].bricks.length;				
            this.levels[this.currentLevel].drawLevel(renderer);
			
            ball.draw(renderer);			
        }
    }
	
	
    void renderGameWithParticles()
    {
        if(this.state == GameState.GAME_ACTIVE)
        {
            static if (__traits(compiles, effects) && effects)
            {
            postProc.beginRender();
            }
			
            renderer.drawSprite(resource_manager.ResMgr.getTexture("background"), 
                                vec2(0, 0), 
                                vec2(this.width, this.height),
                                0.0f, 
                                //vec3(0.3f, 0.3f, 0.75f));   // original values
                                vec3(0.95f, 0.95f, 0.95f));                               
								
            paddle.draw(renderer);    // draw paddle/player

            ulong len = this.levels[0].bricks.length;				
            this.levels[this.currentLevel].drawLevel(renderer);

            static if (__traits(compiles, particulate) && particulate)	
            {			
            partGen.draw();
            }
			
            ball.draw(renderer);	

            static if (__traits(compiles, effects) && effects)
            {	
            postProc.endRender();	
            postProc.render(glfwGetTime());
            }	

            static if (__traits(compiles,powUps) && powUps)	
            {
                foreach(pup; powerUps)	
                {
                    if (!pup.destroyed)
                        pup.draw(renderer);					
                }				
            }
            static if (__traits(compiles, screenText) && screenText)	
            {
                string str = "Lives: " ~ to!string(this.lives);
                textRend.renderText(str, 10.0f, 550.0f, 1.0);	
            }
        }
    }
	
	
    void resetLevel()
    {
        writeln("this.currentLevel = ", this.currentLevel);
        if (this.currentLevel == 0)
            this.levels[0].loadLevel("../levels/level1.txt", this.width, cast(GLuint) (this.height * 0.5f));
        else if (this.currentLevel == 1)
            this.levels[1].loadLevel("../levels/level2.txt", this.width, cast(GLuint) (this.height * 0.5f));
        else if (this.currentLevel == 2)
            this.levels[2].loadLevel("../levels/level3.txt", this.width, cast(GLuint) (this.height * 0.5f));
        else if (this.currentLevel == 3)
            this.levels[3].loadLevel("../levels/level4.txt", this.width, cast(GLuint) (this.height * 0.5f));
    }

	
    void resetPlayer()
    {
        // Reset paddle/ball stats
        paddle.size = PaddleSize;
        paddle.position = vec2(this.width / 2 - PaddleSize.x / 2, this.height - PaddleSize.y);
        ball.reset(paddle.position + vec2(PaddleSize.x / 2 - BallRadius, -(BallRadius * 2)), BallVelocity);
    }
	


/+
    https://yal.cc/rectangle-circle-intersection-test/

    First things first, you may already know how to check circle-point collision - it's 
    simply checking that the distance between the circle' center and the point is smaller than the circle' radius:

    DeltaX = CircleX - PointX;
    DeltaY = CircleY - PointY;
    return (DeltaX * DeltaX + DeltaY * DeltaY) < (CircleRadius * CircleRadius);
	
    Surprisingly or not, rectangle-circle collisions are not all too different - first you find the point 
    of rectangle that is the closest to the circle' center, and check that point is in the circle.

    And, if the rectangle is not rotated, finding a point closest to the circle' center is simply a matter of 
    clamping the circle' center coordinates to rectangle coordinates:

    NearestX = Max(RectX, Min(CircleX, RectX + RectWidth));
    NearestY = Max(RectY, Min(CircleY, RectY + RectHeight));
	
    So, combining the above two snippets yields you a 3-line function for circle-rectangle check:

    DeltaX = CircleX - Max(RectX, Min(CircleX, RectX + RectWidth));
    DeltaY = CircleY - Max(RectY, Min(CircleY, RectY + RectHeight));
    return (DeltaX * DeltaX + DeltaY * DeltaY) < (CircleRadius * CircleRadius);	
+/
	
    void doCollisions_03()
    {
        foreach(i, ref box; this.levels[this.currentLevel].bricks)
        {
		    Collision collide;  // Collision is a tuple not a struct.

            if (!box.destroyed)   // skip boxes that have been previously destroyed
            {
                collide = doesCircleCollideWithRect(ball, box);	
				
                if (collide[0]) // If collision is true
                {		
                    if (!box.isSolid)   // is box is destructable 
                    {
                        box.destroyed = true;
                        static if (__traits(compiles,powUps) && powUps)						
                            this.spawnPowerUps(box);
                        static if (__traits(compiles, audio) && audio)						
                            //playSound(FMOD_LOOP_OFF, soundSys.system, "../audio/bleep.mp3");	
                            playSound(soundSys, 1 );							
                    }
                    else  // if block is solid, enable shake effect
                    {
                        shakeTime = 0.05f;
                        postProc.shake = true;
                        static if (__traits(compiles, audio) && audio)						
                            playSound(soundSys, 2 );													
                    }
							
                    // Collision resolution
                    Direction dir = collide[1];
                    vec2 diff_vector = collide[2];
                    if (dir == Direction.LEFT || dir == Direction.RIGHT) // Horizontal collision
                    {
                        //writeln("Horizontal collision");
                        //writeAndPause("within dir == Direction.LEFT || dir == Direction.RIGHT");
                        ball.velocity.x = -ball.velocity.x; // Reverse horizontal velocity
                        // Relocate
                        GLfloat penetration = ball.radius - abs(diff_vector.x);
                        if (dir == Direction.LEFT)
                            ball.position.x += penetration; // Move ball to right
                        else
                            ball.position.x -= penetration; // Move ball to left;
                    }
                    else // Vertical collision
                    {
                        //writeln("Vertical collision");
                        //writeAndPause("within dir == Direction.UP || dir == Direction.DOWN");					
                        ball.velocity.y = -ball.velocity.y; // Reverse vertical velocity
                        // Relocate
                        GLfloat penetration = ball.radius - abs(diff_vector.y);
 
                        if (dir == Direction.UP)
                            ball.position.y -= penetration; // move ball up
                        else
                            ball.position.y += penetration; // move ball down
                    }
                }
            }    
        }
		
        // Also check collisions on PowerUps and if so, activate them	
        static if (__traits(compiles,powUps) && powUps)
        {
        foreach (ref pow; this.powerUps)
        {
            if (!pow.destroyed)
            {
                if (pow.position.y >= this.height)
                    pow.destroyed = GL_TRUE;

                if (checkRectCollision_02(paddle, pow))
                {	// Collided with player, now activate powerup
                    activatePowerUp(pow);
                    pow.destroyed = GL_TRUE;
                    pow.activated = GL_TRUE;
                    static if (__traits(compiles, audio) && audio)						
                        playSound(soundSys, 3 );																	
                }
            }
        }  
        }				
		
         		
        // And finally check collisions for player's paddle (unless stuck)
		
        Collision result = doesCircleCollideWithRect(ball, paddle);
		
        if (!ball.stuck && result[0])
        {
            //writeAndPause("Ball has struck paddle");
            // Check where it hit the board, and change velocity based on where it hit the board
            GLfloat centerPaddle = paddle.position.x + (paddle.size.x / 2);
            GLfloat distance = (ball.position.x + ball.radius) - centerPaddle;
            GLfloat percentage = distance / (paddle.size.x / 2);
            // Then move accordingly
            GLfloat strength = 2.0f;
            vec2 oldVelocity = ball.velocity;
            ball.velocity.x = BallVelocity.x * percentage * strength; 

            // Keep speed consistent over both axes (multiply by length of old velocity, 
			// so total strength is not changed)			
			
            ball.velocity = (ball.velocity).normalized * (oldVelocity.length); 
			
            // Fix sticky paddle
            ball.velocity.y = -1 * abs(ball.velocity.y);
			
            // If Sticky powerup is activated, also stick ball to paddle once 
            // new velocity vectors were calculated
            static if (__traits(compiles,powUps) && powUps)	
            {			
            ball.stuck = ball.sticky;
            }
            static if (__traits(compiles, audio) && audio)
            {			
                playSound(soundSys, 4 );
            }				
        }


    }



/+ http://stackoverflow.com/questions/401847/circle-rectangle-collision-detection-intersection?rq=1


90
down vote
Here is another solution that's pretty simple to implement (and pretty fast, too). It will catch all intersections, including when the sphere has fully entered the rectangle.

// clamp(value, min, max) - limits value to the range min..max

// Find the closest point to the circle within the rectangle
float closestX = clamp(circle.X, rectangle.Left, rectangle.Right);
float closestY = clamp(circle.Y, rectangle.Top, rectangle.Bottom);

// Calculate the distance between the circle's center and this closest point
float distanceX = circle.X - closestX;
float distanceY = circle.Y - closestY;

// If the distance is less than the circle's radius, an intersection occurs

float distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);
return distanceSquared < (circle.Radius * circle.Radius);

With any decent math library, that can be shortened to 3 or 4 lines.

shareimprove this answer
edited May 22 '11 at 0:11

Theodore
2815
answered Dec 10 '09 at 7:30

Cygon
5,83732945
2	 	
You have a bug in there, you search for closestY with Left and Right, not Top and Bottom, otherwise lovely solution. – manveru May 21 '10 at 21:24

+/




/+   http://jsfiddle.net/m1erickson/n6U8D/

// return true if the rectangle and circle are colliding
function RectCircleColliding(circle, rect) {
    var distX = Math.abs(circle.x - rect.x - rect.w / 2);
    var distY = Math.abs(circle.y - rect.y - rect.h / 2);

    if (distX > (rect.w / 2 + circle.r)) {
        return false;
    }
    if (distY > (rect.h / 2 + circle.r)) {
        return false;
    }

    if (distX <= (rect.w / 2)) {
        return true;
    }
    if (distY <= (rect.h / 2)) {
        return true;
    }

    var dx = distX - rect.w / 2;
    var dy = distY - rect.h / 2;
    return (dx * dx + dy * dy <= (circle.r * circle.r));
}

+/

    Collision checkCollisionCircleWithRect(BallObject one, GameObject two)  // AABB - Circle collision
    {
        // glm::vec2 center(one.Position + one.Radius);  // original C++ code
        // It works via operator overloading, and adding a scalar simply means 
		// adding it to all vector components.	
		
        // Get center point of the circle first 
        vec2 center = vec2(one.position.x + one.radius, one.position.y + one.radius);
		
        // Calculate AABB info (center, half-extents)
        vec2 aabb_half_extents = vec2( (two.size.x / 2), (two.size.y / 2) );
		
        vec2 aabb_center = vec2(two.position.x + aabb_half_extents.x, two.position.y + aabb_half_extents.y);
		
        // Get difference vector between both centers
        vec2 difference = center - aabb_center;
        ///////vec2 clamped = clamp(difference, -aabb_half_extents, aabb_half_extents);
		
        // float clamp(float value, float min, float max) 
        // {
        //    return std::max(min, std::min(max, value));  C++ code
        // }
		
        // auto clamp(T1, T2, T3)(T1 val, T2 lower, T3 upper);   D code
        // This functions is equivalent to max(lower, min(upper, val)).		
		
        // Add clamped value to AABB_center and we get the value of box closest to circle
        /////////vec2 closest = aabb_center + clamped;   
        // Retrieve vector between center circle and closest point AABB and check if length <= radius
        /////////difference = closest - center;

		writeln("difference = ", difference);
		writeln("difference.magnitude = ", difference.magnitude);
        //writeAndPause(" ");		

        //return glm::length(difference) < one.Radius;
        // genType::value_type glm::length(genType const &x)	
        // Returns the length of x, i.e., sqrt(x * x).

        /// Returns the magnitude of the vector.
        // @property real magnitude() const 
        // {
        //    return sqrt(magnitude_squared);
        // }
        // alias magnitude_squared length_squared; /// ditto
        // alias magnitude length; /// ditto
		
        Collision hitOrMiss;

        if (difference.magnitude < one.radius)  // not <= since in that case a collision also occurs when object one exactly touches
        {                                    // object two, which they are at the end of each collision resolution stage.
            hitOrMiss[0] = GL_TRUE;
            hitOrMiss[1] = VectorDirection(difference);
            hitOrMiss[2] = difference;
        }
        else
        {
            hitOrMiss[0] = GL_FALSE;
            hitOrMiss[1] = Direction.UP;
            hitOrMiss[2] = vec2(0,0);
        }

        return hitOrMiss;
    }

    // Calculates which direction a vector is facing (N,E,S or W)
    Direction VectorDirection(vec2 target)
    {
        vec2[] compass = [
                          vec2( 0.0f, 1.0f), // up
                          vec2( 1.0f, 0.0f), // right
                          vec2( 0.0f,-1.0f), // down
                          vec2(-1.0f, 0.0f)	 // left
                         ];
        GLfloat max = 0.0f;
        GLuint best_match = -1;
        for (GLuint i = 0; i < 4; i++)
        {
            GLfloat dot_product = dot(target.normalized, compass[i]);
            if (dot_product > max)
            {
                max = dot_product;
                best_match = i;
            }
        }
        return cast (Direction) best_match;
    }   

    static if (__traits(compiles,powUps) && powUps)
    {		
	
    GLboolean shouldSpawn(GLuint chances)
    {
        //GLuint random = rand() % chance;
        //return random == 0;
		
        auto z = dice(chances, 1);  // 1 in X chances
		if (z == 1)
            return true;
        return false;
    }	


	void spawnPowerUps(GameObject block)
    {
        if (shouldSpawn(75)) // 1 in 75 chance
		    powerUps ~= new PowerUp("speed", vec3(0.5f, 0.5f, 1.0f), 0.0f, block.position, 
			                        resource_manager.ResMgr.aaTextures["tex_speed"]);
        if (shouldSpawn(75))
            powerUps ~= new PowerUp("sticky", vec3(1.0f, 0.5f, 1.0f), 20.0f, block.position,
                                    resource_manager.ResMgr.aaTextures["tex_sticky"]);			
        if (shouldSpawn(75))
            powerUps ~= new PowerUp("pass-through", vec3(0.5f, 1.0f, 0.5f), 10.0f, block.position,
                                    resource_manager.ResMgr.aaTextures["tex_pass"]);
        if (shouldSpawn(75))
            powerUps ~= new PowerUp("pad-size-increase", vec3(1.0f, 0.6f, 0.4), 0.0f, block.position,
                                    resource_manager.ResMgr.aaTextures["tex_size"]);			
        if (shouldSpawn(75)) // Negative powerups should spawn more often
            powerUps ~= new PowerUp("confuse", vec3(1.0f, 0.3f, 0.3f), 15.0f, block.position,
                                    resource_manager.ResMgr.aaTextures["tex_confuse"]);			
        if (shouldSpawn(75))	
            powerUps ~= new PowerUp("chaos", vec3(0.9f, 0.25f, 0.25f), 15.0f, block.position,
                                    resource_manager.ResMgr.aaTextures["tex_chaos"]);			
    }

	
	void activatePowerUp(ref PowerUp pup)
    {
        // Initiate a powerup based type of powerup
        if (pup.type == "speed")
        {
            ball.velocity *= 1.2;
        }
        else if (pup.type == "sticky")
        {
            ball.sticky = GL_TRUE;
            paddle.color = vec3(1.0f, 0.5f, 1.0f);
        }
        else if (pup.type == "pass-through")
        {
            ball.passThrough = GL_TRUE;
            ball.color = vec3(1.0f, 0.5f, 0.5f);
        }
        else if (pup.type == "pad-size-increase")
        {
            paddle.size.x += 50;
        }
        else if (pup.type == "confuse")
        {
            if (!postProc.chaos)
                postProc.confuse = GL_TRUE; // Only activate if chaos wasn't already active
        }
        else if (pup.type == "chaos")
        {
            if (!postProc.confuse)
                postProc.chaos = GL_TRUE;
        }
    }

    GLboolean isOtherPowerUpActive(PowerUp[] pups, string type)
    {
        // Check if another PowerUp of the same type is still active
        // in which case we don't disable its effect (yet)
        foreach (pup; pups)
        {
            if (pup.activated)
                if (pup.type == type)
                    return GL_TRUE;
        }
        return GL_FALSE;
    }

    void updatePowerUps(GLfloat dt)
    {
        foreach (pup; this.powerUps)
        {
            pup.position += pup.velocity * dt;
            if (pup.activated)
            {
                pup.duration -= dt;

                if (pup.duration <= 0.0f)
                {
                    // Remove powerup from list (will later be removed)
                    pup.activated = GL_FALSE;
                    // Deactivate effects
                    if (pup.type == "sticky")
                    {
                        if (!isOtherPowerUpActive(this.powerUps, "sticky"))
                        {	// Only reset if no other PowerUp of type sticky is active
                            ball.sticky = GL_FALSE;
                            paddle.color = vec3(1.0f);
                        }
                    }
                    else if (pup.type == "pass-through")
                    {
                        if (!isOtherPowerUpActive(this.powerUps, "pass-through"))
                        {	// Only reset if no other PowerUp of type pass-through is active
                            ball.passThrough = GL_FALSE;
                            ball.color = vec3(1.0f);
                        }
                    }
                    else if (pup.type == "confuse")
                    {
                        if (!isOtherPowerUpActive(this.powerUps, "confuse"))
                        {	// Only reset if no other PowerUp of type confuse is active
                            postProc.confuse = GL_FALSE;
                        }
                    }
                    else if (pup.type == "chaos")
                    {
                        if (!isOtherPowerUpActive(this.powerUps, "chaos"))
                        {	// Only reset if no other PowerUp of type chaos is active
                            postProc.chaos = GL_FALSE;
                        }
                    }                
                }
            }
        }
		/+
        this->PowerUps.erase(std::remove_if(this->PowerUps.begin(), 
                             this->PowerUps.end(),
                             [](const PowerUp &powerUp) 
                             { return powerUp.Destroyed && !powerUp.Activated; }
                             ), this->PowerUps.end());
        +/
    } 
    } 	
	
}


