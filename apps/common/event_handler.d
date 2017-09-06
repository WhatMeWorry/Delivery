
module event_handler;




import derelict.opengl3.gl3;
import derelict.glfw3.glfw3; 
import std.stdio;
import mytoolbox;


//import common_game.game;
import app;  // for bool enum effects 
import game;  // needed for postProc
import post_processor;  // needed for new PostProcessor
import common_game;     // needed for  resource_manager.ResMgr.getShader("effects")
import resource_manager;  // needed for  resource_manager.ResMgr.getShader("effects")

enum EventType
{
    updateEditMode,
    keyboard,
    textext,
    windowSize,
    frameBufferSize,
    windowFocus,
    cursorInOrOut,
    cursorPosition,
    mouseScroll,
    mouseButton,
    mousePos,
    joystickStatus,
    joystickAxes,
    joystickButton
}

enum Key
{
    unknown    = GLFW_KEY_UNKNOWN,
    space      = GLFW_KEY_SPACE,
    apostrophe = GLFW_KEY_APOSTROPHE,
    comma      = GLFW_KEY_COMMA,
    minus      = GLFW_KEY_MINUS,
    period     = GLFW_KEY_PERIOD,
    slash      = GLFW_KEY_SLASH,
    semicolon  = GLFW_KEY_SEMICOLON,
    equal      = GLFW_KEY_EQUAL,

    num0 = GLFW_KEY_0,
    num1 = GLFW_KEY_1,
    num2 = GLFW_KEY_2,
    num3 = GLFW_KEY_3,
    num4 = GLFW_KEY_4,
    num5 = GLFW_KEY_5,
    num6 = GLFW_KEY_6,
    num7 = GLFW_KEY_7,
    num8 = GLFW_KEY_8,
    num9 = GLFW_KEY_9,

    a = GLFW_KEY_A,
    b = GLFW_KEY_B,
    c = GLFW_KEY_C,
    d = GLFW_KEY_D,
    e = GLFW_KEY_E,
    f = GLFW_KEY_F,
    g = GLFW_KEY_G,
    h = GLFW_KEY_H,
    i = GLFW_KEY_I,
    j = GLFW_KEY_J,
    k = GLFW_KEY_K,
    l = GLFW_KEY_L,
    m = GLFW_KEY_M,
    n = GLFW_KEY_N,
    o = GLFW_KEY_O,
    p = GLFW_KEY_P,
    q = GLFW_KEY_Q,
    r = GLFW_KEY_R,
    s = GLFW_KEY_S,
    t = GLFW_KEY_T,
    u = GLFW_KEY_U,
    v = GLFW_KEY_V,
    w = GLFW_KEY_W,
    x = GLFW_KEY_X,
    y = GLFW_KEY_Y,
    z = GLFW_KEY_Z,

    leftBracket  = GLFW_KEY_LEFT_BRACKET,
    backslash    = GLFW_KEY_BACKSLASH,
    rightBracket = GLFW_KEY_RIGHT_BRACKET,
    graveAccent  = GLFW_KEY_GRAVE_ACCENT,
    world1       = GLFW_KEY_WORLD_1,
    world2       = GLFW_KEY_WORLD_2,

    escape      = GLFW_KEY_ESCAPE,
    enter       = GLFW_KEY_ENTER,
    tab         = GLFW_KEY_TAB,
    backspace   = GLFW_KEY_BACKSPACE,
    insert      = GLFW_KEY_INSERT,
    delete_     = GLFW_KEY_DELETE,
    right       = GLFW_KEY_RIGHT,
    left        = GLFW_KEY_LEFT,
    down        = GLFW_KEY_DOWN,
    up          = GLFW_KEY_UP,
    pageUp      = GLFW_KEY_PAGE_UP,
    pageDown    = GLFW_KEY_PAGE_DOWN,
    home        = GLFW_KEY_HOME,
    end         = GLFW_KEY_END,
    capsLock    = GLFW_KEY_CAPS_LOCK,
    scrollLock  = GLFW_KEY_SCROLL_LOCK,
    numLock     = GLFW_KEY_NUM_LOCK,
    printScreen = GLFW_KEY_PRINT_SCREEN,
    pause       = GLFW_KEY_PAUSE,

    f1  = GLFW_KEY_F1,
    f2  = GLFW_KEY_F2,
    f3  = GLFW_KEY_F3,
    f4  = GLFW_KEY_F4,
    f5  = GLFW_KEY_F5,
    f6  = GLFW_KEY_F6,
    f7  = GLFW_KEY_F7,
    f8  = GLFW_KEY_F8,
    f9  = GLFW_KEY_F9,
    f10 = GLFW_KEY_F10,
    f11 = GLFW_KEY_F11,
    f12 = GLFW_KEY_F12,
    f13 = GLFW_KEY_F13,
    f14 = GLFW_KEY_F14,
    f15 = GLFW_KEY_F15,
    f16 = GLFW_KEY_F16,
    f17 = GLFW_KEY_F17,
    f18 = GLFW_KEY_F18,
    f19 = GLFW_KEY_F19,
    f20 = GLFW_KEY_F20,
    f21 = GLFW_KEY_F21,
    f22 = GLFW_KEY_F22,
    f23 = GLFW_KEY_F23,
    f24 = GLFW_KEY_F24,
    f25 = GLFW_KEY_F25,

    keyPad0 = GLFW_KEY_KP_0,
    keyPad1 = GLFW_KEY_KP_1,
    keyPad2 = GLFW_KEY_KP_2,
    keyPad3 = GLFW_KEY_KP_3,
    keyPad4 = GLFW_KEY_KP_4,
    keyPad5 = GLFW_KEY_KP_5,
    keyPad6 = GLFW_KEY_KP_6,
    keyPad7 = GLFW_KEY_KP_7,
    keyPad8 = GLFW_KEY_KP_8,
    keyPad9 = GLFW_KEY_KP_9,

    keyPadDecimal  = GLFW_KEY_KP_DECIMAL,
    keyPadDivide   = GLFW_KEY_KP_DIVIDE,
    keyPadMultiply = GLFW_KEY_KP_MULTIPLY,
    keyPadSubtract = GLFW_KEY_KP_SUBTRACT,
    keyPadAadd     = GLFW_KEY_KP_ADD,
    keyPadEnter    = GLFW_KEY_KP_ENTER,
    keyPadEqual    = GLFW_KEY_KP_EQUAL,

    leftShift      = GLFW_KEY_LEFT_SHIFT,
    leftControl    = GLFW_KEY_LEFT_CONTROL,
    leftAlt        = GLFW_KEY_LEFT_ALT,
    leftSuper      = GLFW_KEY_LEFT_SUPER,
    rightShift     = GLFW_KEY_RIGHT_SHIFT,
    rightControl   = GLFW_KEY_RIGHT_CONTROL,
    rightAlt       = GLFW_KEY_RIGHT_ALT,
    rightSuper     = GLFW_KEY_RIGHT_SUPER,
    menu           = GLFW_KEY_MENU,
    last           = GLFW_KEY_LAST,
}


// modifier is one or more of GLFW_MOD_SHIFT, GLFW_MOD_CONTROL, GLFW_MOD_ALT, GLFW_MOD_SUPER

struct Modifier
{
    int shift;
    int control;
    int alternate;
    int superKey;  // Window's window key or Apple's command (clover leaf) key
}


// Action is one of GLFW_PRESS, GLFW_REPEAT or GLFW_RELEASE

enum Action
{
    Pressed  = GLFW_PRESS,
    Released = GLFW_RELEASE,
    Repeat   = GLFW_REPEAT
}

enum CursorState
{
    In,
    Out
}

struct Keyboard
{
    Key       key;
    Action    action;
    Modifier  modifier;
}

struct FrameBufferSize
{
    int width;
    int height;
}

struct Position
{
    double x;
    double y;
}

struct Cursor
{
    int      state;
    Position position;
}


static this() 
{
    // the beginning operations of the module

    writeln("maxSize of even queue = ", maxSize);
    //writeln("queue = ", queue);
}

static ~this() 
{
    // the final operations of the module
    writeln("Inside static ~this() of module ", __MODULE__); // don't see it, if Ctrl^C in console
                                                             // see it, if close App Window normally
}


struct Event
{  
    EventType       type;
    Keyboard        keyboard;    // key, action, modifier
    Cursor          cursor;
    FrameBufferSize frameBufferSize;
}

enum Motion
{
    Entering,
    Leaving
}

/+
queue notes
queue will be manifested through an infinite array

   maxSize = infinite
   queue.initialize()
     L   E
   |_0_|_1_|_2_|_3_|_4_|_5_|_6_|_7_|_8_|_9_|...
   
   queue.add(a)  
     L   a   E
   |_0_|_1_|_2_|_3_|_4_|_5_|_6_|_7_|_8_|_9_|...  
   
   queue.add(b)
     L   a   b   E
   |_0_|_1_|_2_|_3_|_4_|_5_|_6_|_7_|_8_|_9_|...   

   
   obj = queue.remove()
         L   b   E
   |_0_|_1_|_2_|_3_|_4_|_5_|_6_|_7_|_8_|_9_|...   
   
  2 indices: enter and leave
leave = 0
enter = 1

Main Algorithm:

for entering the queue (producing)
WRITE (on current E index value), then advance index E
for leaving the queue (consuming)
advance index L, then READ

writing to array index enter is equivalent to an object entering the queue

foreach object that enters the queue  // PRODUCE
{
    queue[enter] = object
    increment enter           // advance enter to next empty slot to be ready for next object.
                              // infinite queue, so never need to check for resource exhaustion
}

reading from array index leave is equavilent to an object leaving the queue.

foreach object that leaves the queue    // CONSUMPTION
{
    increment leave            //
    next Object = queue[leave]
}

Degenerate Case 1: Since event buffer cannot be infinite,  the Advance algorathim must check for
                   end of array (maxSize-1); and if true, must set the index to 0.
 
Degenerate Case 1: Queue is empty. In this case, L(eave) will be "immediately behind" E(nter) index. 

Degenerate Case 2: Queue is full. In this case, E(nter) will be "immediately behind" L(ease) index.
                2a: another problem, with add


+/  

class TryException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) 
    {
        super(msg, file, line);
    }
}


 
bool isDirectlyBehind(long first, long second)
{
    if( (first+1 == second) ||     // Is enter right behind leave?
        ( (first == maxSize-1) && (second == 0)) ) 
    {
        return true;
    }
    return false;
}  

struct CircularQueue
{
    Event[maxSize] events;   // static array modeling a circular queue

    __gshared uint leave = 0;  // the index in queue of next entity to exit queue
    __gshared uint enter = 1;  // the index in queue of next entity to enter queue

    // queue is empty when leave index is right behind (index is one less) the enter index.

    Event eventOut;  // saves off the event taken out of the queue so 
                     // that the event is definitely saved off within the synchronized period
                     // Since event processing can vary so much in tine, we put the event into
                     // eventOut so that the queue can be freed up to process incoming events.
    Event eventIn;   // Not so critical as eventOut, but implement for symmetry  

    // Modulus operator is "%" which is the remainder of dividing 'first' by 'second' first % second
    // Could replace in advance function, but potential for overflow?  Decided to keep as is.

    void advance(ref uint x)
    {
        if(x == (maxSize-1))  // are we wrapping around clockwise?
            x = 0;
        else
            x++;
    }
   
    bool enterOrLeave(Motion move)
    {
        synchronized   // lock everything down when an event enters or exists.
        {
            if(move == Motion.Leaving)
            {
                if(isDirectlyBehind(leave, enter))   
                {
                    //writeln("Queue is empty leave = ", leave, " enter = ", enter);
                    return false;
                }

                advance(leave);  // There is an event go to it
                eventOut = queue.events[queue.leave];
                return true;
            }
            if(move == Motion.Entering)
            { 
                if(isDirectlyBehind(enter, leave))
                {             
                    //writeln("Queue is full enter = ", enter, " leave = ", leave);
                    return false;
                }

                queue.events[queue.enter] = eventIn;
                advance(enter);    // advance to new open slot
                return true;
            }
            assert(0);  // should never get here
        } 
        assert(0);  // should never get here
    }
}

immutable uint maxSize = 1024;

CircularQueue  queue;

//===================================== ON Events ========================================


// Trigger             GLFW Activation
/+   
onKeyEvent           glfwSetKeyCallback
onCursorEnterLeave   glfwSetCursorEnterCallback
onMouseButton        glfwSetMouseButtonCallback
onCursorPosition     glfwSetCusorPosCallback
?????????            glfwSetWindowSizeCallback
onFrameBufferResize  glfwSetFramebufferSizeCallback
onWindowMovement     glfwSetWindowPosCallback
+/

/+
Window coordinates are relative to the monitor and/or the window and are given in artificial units that do not necessarily 
correspond to real screen pixels. This is especially the case when dpi scaling is activated (for example, on Macs with retina display).
Framebuffer sizes are, in contrast to the window coordinates, given in pixels in order to match OpenGLs requirements for glViewport.
Note, that on some systems window coordinates and pixel coordinates can be the same but this is not necessarily true.
+/

extern(C) void onKeyEvent(GLFWwindow* window, int key, int scancode, int action, int modifier) nothrow
{
    try  // try is needed because of the nothrow
    {
        queue.eventIn.type = EventType.keyboard;
        queue.eventIn.keyboard.key = cast(Key) key;
        queue.eventIn.keyboard.action = cast(Action) action; 

        //writeln("modifier = ", modifier);
        if (modifier & GLFW_MOD_SHIFT)
        {
            //writeln("Shift key pressed");
            queue.eventIn.keyboard.modifier.shift = true;
        }
        if (modifier & GLFW_MOD_CONTROL)
        {
            //writeln("Control key pressed");
            queue.eventIn.keyboard.modifier.control = true;
        }
        if (modifier & GLFW_MOD_ALT)
        {
            //writeln("Alternate key pressed");
            queue.eventIn.keyboard.modifier.alternate = true;
        }
        if (modifier & GLFW_MOD_SUPER)
        {
            //writeln("Super key pressed");
            queue.eventIn.keyboard.modifier.superKey = true;
        }

        if (queue.enterOrLeave(Motion.Entering))
        {
            writeln("key = ", queue.eventIn.keyboard.key, " entered at = ", queue.enter-1);
        }
        else
        {
            writeln("queue is full");
        }
    }
    catch(Exception e)
    {
        //throw new TryException("The try block failed: ");
    }
}


extern(C) void onCursorEnterLeave(GLFWwindow* window, int entered) nothrow
{
    try  // try is needed because of the nothrow
    {
        queue.eventIn.type = EventType.cursorInOrOut;
        if(entered)
            queue.eventIn.cursor.state = CursorState.In;    
        else
            queue.eventIn.cursor.state = CursorState.Out;

        if (queue.enterOrLeave(Motion.Entering))
        {
            //writeln("cursorState = ", queue.eventIn.cursorState, " entered at = ", queue.enter-1);
        }
        else
        {
            //writeln("queue is full");
        }
    }
    catch(Exception e)
    {
        // how to handle e?    
    }
}
 

extern(C) void onMouseButton(GLFWwindow* window, int button, int action, int modifierKeys) nothrow
{
    try  // try is needed because of the nothrow
    {
        queue.eventIn.type = EventType.mouseButton;
        //writeln("button = ", button);
        /+
        if(entered)
            queue.eventIn.c = Cursor.In;    
        else
            queue.eventIn.cursorState = Cursor.Out;
        +/
        auto success = queue.enterOrLeave(Motion.Entering);
        if(success)
        {
            //writeln("cursorState = ", queue.eventIn.cursorState, " entered at = ", queue.enter-1);
        }
    }
    catch(Exception e)
    {
    }
}
 
 
//   (0,0)                      
//        +----------------------+
//        |                      |
//        |                      |
//        |   (xpos, ypos)       |
//        |                      |
//        |                      |
//        |                      |
//        +----------------------+ 
//                           (400,400)

 extern(C) void onCursorPosition(GLFWwindow* window, double x, double y) nothrow
{
    try  // try is needed because of the nothrow
    {
        queue.eventIn.type = EventType.cursorPosition;

        queue.eventIn.cursor.position.x = x;
        queue.eventIn.cursor.position.y = y;

        auto success = queue.enterOrLeave(Motion.Entering);
        if(success)
        {
            //writeln("cursorState = ", queue.eventIn.cursorState, " entered at = ", queue.enter-1);
        }
    }
    catch(Exception e)
    {
    }
}
 
 /+
 extern(C) void onWindowMovement(...)
 {

 }
+/

extern(C) void onFrameBufferResize(GLFWwindow* window, int width, int height) nothrow
{
    try  // try is needed because of the nothrow
    {
        queue.eventIn.type = EventType.frameBufferSize;
        //writeln("Inside onFrameBufferResize ");
        //writeln("frame width = ", width, "  frame height = ", height);

        int srcWidth, srcHeight;
        glfwGetWindowSize(window, &srcWidth, &srcHeight);
        //writeln("Inside FrameBufferResize but lets look at screen coordinates");
        //writeln("Screen Coordinates: srcWidth = ", srcWidth, "  srcHeight = ", srcHeight);

        int pixelWidth, pixelHeight;
        glfwGetFramebufferSize(window, &pixelWidth, &pixelHeight);
        //writeln("Pixels size: pixelWidth = ", pixelWidth, "  pixelHeight = ", pixelHeight);

        //writeln("width passed in = ", width, "  height passed in = ", height);

        queue.eventIn.frameBufferSize.width = width;
        queue.eventIn.frameBufferSize.height = height;
        //writeln("Before Q Add  leave = ", queue.leave, "  enter = ", queue.enter);
        if (queue.enterOrLeave(Motion.Entering))
        {
            //writeln("After Q Add  leave = ", queue.leave, "  enter = ", queue.enter);
        }
        else
        {
            //writeln("============= QUEUE NOT ADDED TO ===============");
        }
    }
    catch(Exception e)
    {
    }
}
 
 
void handleEvent(GLFWwindow* window)
{
    Event eve;
    //writeln("Before Q SUB  leave = ", queue.leave, "  enter = ", queue.enter);
    if (queue.enterOrLeave(Motion.Leaving))
    {
        //writeln("After Q SUB  leave = ", queue.leave, "  enter = ", queue.enter);       
        eve = queue.eventOut;
    
        if (eve.type == EventType.keyboard)
        {
            //writeln("eve.key = ", eve.keyboard.key, " left at = ", queue.leave-1);
            if (eve.keyboard.key == Key.escape)
                glfwSetWindowShouldClose(window, GLFW_TRUE);
        }
        if (eve.type == EventType.cursorInOrOut)
        {
            //writeln("eve.cursorState = ", eve.cursorState);
        }
        if (eve.type == EventType.frameBufferSize)
        {
            //writeln("frameBufferSize Event = ");
            //glfwSetWindowSize(window, eve.frameBufferSize.width, eve.frameBufferSize.height);   
            //writeln("eve.frameBufferSize.width ", eve.frameBufferSize.width);
            //writeln("eve.frameBufferSize.height ", eve.frameBufferSize.height);
            //writeln("Before glViewport");

            /+ 
            Do not pass the window size to glViewport or other pixel-based OpenGL calls. The 
            window size is in screen coordinates, not pixels. Use the framebuffer size, which 
            is in pixels, for pixel-based calls.
            +/
            glViewport(0, 0, eve.frameBufferSize.width, eve.frameBufferSize.height);

            static if (__traits(compiles, effects) && effects)
            {
                postProc.postProcWidth =  eve.frameBufferSize.width;
                postProc.postProcHeight =  eve.frameBufferSize.height; 
                postProc = new PostProcessor(resource_manager.ResMgr.getShader("effects"),
                                             postProc.postProcWidth, postProc.postProcHeight);  
            }
            //writeln("leave = ", queue.leave);
            //writeln("enter = ", queue.enter);
            //writeAndPause("pause");
        }
    }
    else
    {
        //writeln("Event Queue is Empty");
    }

}


bool getNextEvent(GLFWwindow* window, out Event event)
{
    if (queue.enterOrLeave(Motion.Leaving))
    {     
        event = queue.eventOut;
        return true; 

    }
    else
    {
        return false;
    }

}

