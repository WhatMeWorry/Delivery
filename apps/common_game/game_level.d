module game_level;

//import common;
//import common_game;

import std.stdio;
import gl3n.linalg; // vec2  vec3
import std.string;  // strip
import std.conv;    // to


/// GameLevel holds all Tiles as part of a Breakout level and 
/// hosts functionality to Load/render levels from the harddisk.
class GameLevel
{
public:
    // Level state
    GameObject[] bricks;

    // Constructor
    this() { }
    // Loads level from file

    //   Very Good D File Tutorial
    //   http://nomad.so/2015/09/working-with-files-in-the-d-programming-language/

    //  http://forum.dlang.org/post/pvslggohbexxdnnixlzp@forum.dlang.org

    void loadLevel(string fileName, GLuint levelWidth, GLuint levelHeight)
    {
        bricks = [];  // clear the dynamic array

        // Load from file
        GLuint tileCode;
        GameLevel level;
        //string line;
        writeln("fileName = ", fileName);

        File file = File(fileName, "r");   // note: File is a structure
 
        //                               col 0  col 1   col 2   col 3   col 4 
        //                             +--------------------------------------+
        // uint[cols][rows]      row 0 |      |       |       |       |       |
        //                             +--------------------------------------+
        // uint[c][r] tiles      row 1 |      |       |       |       |       |
        //       or                    +--------------------------------------+
        // (uint[c])[r] tiles    row 2 |      |       |       |       |       |
        //                             +--------------------------------------+
        //
        // tiles[r][c] is an array of r elements, where each element is an array of c elements 

        GLuint[][] tiles;
        while (!file.eof()) 
        {
            string line = strip(file.readln());
            if (line.length == 0)    // guard against empty lines or
                break;               // extraneous \n or spaces at eof.
            string[] tokens = split(line);
            GLuint[] row;
            foreach(token; tokens)
            {
                row ~= to!GLuint(token);
            }
            tiles ~= row;
        }
 
        //writeln("tiles has ", tiles[].length, " rows");

        uint rows = cast(uint) tiles[].length;
        //writeln("tiles has ", tiles[rows-1][].length, " columns");
        uint columns = cast(uint) tiles[rows-1][].length;


        //writeln("levelWidth = ", levelWidth);
        //writeln("levelHeight = ", levelHeight);
        //writeAndPause("Guess everything worked");   
        writeln("Level Loaded");

        if (((levelWidth > 0) && (levelHeight > 0)) &&
            ((rows > 0) && (columns > 0)) )
        {
            this.init(tiles, levelWidth, levelHeight);   //this->init(tileData, levelWidth, levelHeight);
        }
    }

    // Render level
    void drawLevel(SpriteRenderer renderer)
    {
        //writeAndPause("Inside game_level.GameLevel.Draw");
        foreach(i, tile; bricks)
        {
            if (!tile.destroyed)
            {
                tile.draw(renderer);
            }
        }
    }

    // Check if the level is completed (all non-solid tiles are destroyed)
    GLboolean IsCompleted()
    {
        //for (GameObject &tile : this->Bricks)
        foreach(tile; bricks)   
        {
            if (!tile.isSolid && !tile.destroyed)
            {
                return GL_FALSE;  // keep playing
            }
        }
        return GL_TRUE;  // finished level
    }
private:
    // Initialize level from tile data
    //void init(std::vector<std::vector<GLuint>> tileData, GLuint levelWidth, GLuint levelHeight);
    void init(GLuint[][] tiles, GLuint levelWidth, GLuint levelHeight)
    {
        // Calculate dimensions

        uint height = cast(uint) tiles[].length;
        uint width = cast(uint) tiles[height-1][].length;

        GLfloat unit_width = levelWidth / width;
        GLfloat unit_height = levelHeight / height;

        //writeln("height = ", height);
        //writeln("width = ", width);
        //writeln("unit_width = ", unit_width);
        //writeln("unit_height = ", unit_height);
        //writeln("Check numbers ********************************************************");

        /+
        foreach(i, row; tiles[])
            foreach(j, elem; tiles[i][])
                // elem
        +/

        // Initialize level tiles based on tiles
        //for (GLuint y = 0; y < height; ++y)
        foreach(i, row; tiles[])
        {
            //writeln("begin row");
            //for (GLuint x = 0; x < width; ++x)
            foreach(j, elem; tiles[i][])
            {
                //writeln("tiles[", i, "][", j, "] = ", tiles[i][j]);
                // Check block type from level data (2D level array)
                if (tiles[i][j] == 1)         // Solid
                {
                    vec2 pos = vec2(unit_width * j, unit_height * i);  // originally vec2(unit_width * i, unit_height * j);
                    vec2 size = vec2(unit_width, unit_height);
                    //writeln("pos = ", pos);
                    //writeln("size = ", size);
                    GameObject obj = new GameObject(pos, size, 
                                                    resource_manager.ResMgr.getTexture("block_solid"), 
                                                    vec3(0.8f, 0.8f, 0.7f), vec2(0.0f, 0.0f));
                    obj.isSolid = GL_TRUE;
                    this.bricks ~= obj;
                }
                else if (tiles[i][j] > 1)  // Non-solid; now determine its color based on level data
                {
                    vec3 color = vec3(1.0f); // original: white
                    if (tiles[i][j] == 2)
                        color = vec3(0.2f, 0.6f, 1.0f);
                    else if (tiles[i][j] == 3)
                        color = vec3(0.0f, 0.7f, 0.0f);
                    else if (tiles[i][j] == 4)
                        color = vec3(0.8f, 0.8f, 0.4f);
                    else if (tiles[i][j] == 5)
                        color = vec3(1.0f, 0.5f, 0.0f);
                    else
                        writeAndPause("Invalid tile number");

                    vec2 pos = vec2(unit_width * j, unit_height * i); // originally vec2(unit_width * i, unit_height * j);
                    vec2 size = vec2(unit_width, unit_height);
                    vec2 vel = vec2(0.0f, 0.0f);
                    GameObject obj = new GameObject(pos, size, 
                                                    resource_manager.ResMgr.getTexture("block"), 
                                                    color, vel);
                    obj.isSolid = GL_FALSE;
                    this.bricks ~= obj;      // equivalent to C++ STL push_back()
                }
            }
        }
        
        foreach(brick; this.bricks)
        {
            //writeln("brick.Position = ", brick.position);
            //writeln("brick.Size = ", brick.size);
        } 
        writeln("bricks.length = ", bricks.length);
    }
}




