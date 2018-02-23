
module event_buffer;


/+
Event Processing 
  with the Polling method, the program asks the GLFW/Operating System if any events has occurred.
  with the Interrupt method, an event triggers the GLFW/Opwerating System to signal the program that an even has taken place.

The Circular Queue is an "endless" array that can store events as they come in. We use an array so multiple events
can be stored; If a flurry of events came in suddenly, we could lose events if only one event was stored at a time.

Usage:
EventBuffer events();  // create an event buffer holding 1024 events
EventBuffer moreEvents(128);  // create an event buffer holding 128 events

+/ 






import derelict.opengl3.gl3;
import derelict.glfw3.glfw3; 
import std.stdio;
import mytoolbox;


//import common_game.game;
/+
import app;  // for bool enum effects 
import game;  // needed for postProc
import post_processor;  // needed for new PostProcessor
import common_game;     // needed for  resource_manager.ResMgr.getShader("effects")
import resource_manager;  // needed for  resource_manager.ResMgr.getShader("effects")
+/





enum Category
{
    UpdateEditMode,
    Keyboard,
    Textext,
    WindowSize,
    FrameBufferSize,
    WindowFocus,
    CursorInOrOut,
    CursorPosition,
    MouseScroll,
    MouseButton,
    MousePos,
    JoystickStatus,
    JoystickAxes,
    JoystickButton
}

enum Key
{
    Unknown    = GLFW_KEY_UNKNOWN,
    Space      = GLFW_KEY_SPACE,
    Apostrophe = GLFW_KEY_APOSTROPHE,
    Comma      = GLFW_KEY_COMMA,
    Minus      = GLFW_KEY_MINUS,
    Period     = GLFW_KEY_PERIOD,
    Slash      = GLFW_KEY_SLASH,
    Semicolon  = GLFW_KEY_SEMICOLON,
    Equal      = GLFW_KEY_EQUAL,

    Num0 = GLFW_KEY_0,
    Num1 = GLFW_KEY_1,
    Num2 = GLFW_KEY_2,
    Num3 = GLFW_KEY_3,
    Num4 = GLFW_KEY_4,
    Num5 = GLFW_KEY_5,
    Num6 = GLFW_KEY_6,
    Num7 = GLFW_KEY_7,
    Num8 = GLFW_KEY_8,
    Num9 = GLFW_KEY_9,

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

    LeftBracket  = GLFW_KEY_LEFT_BRACKET,
    Backslash    = GLFW_KEY_BACKSLASH,
    RightBracket = GLFW_KEY_RIGHT_BRACKET,
    GraveAccent  = GLFW_KEY_GRAVE_ACCENT,
    World1       = GLFW_KEY_WORLD_1,
    World2       = GLFW_KEY_WORLD_2,

    Escape      = GLFW_KEY_ESCAPE,
    Enter       = GLFW_KEY_ENTER,
    Tab         = GLFW_KEY_TAB,
    Backspace   = GLFW_KEY_BACKSPACE,
    Insert      = GLFW_KEY_INSERT,
    Delete_     = GLFW_KEY_DELETE,
    Right       = GLFW_KEY_RIGHT,
    Left        = GLFW_KEY_LEFT,
    Down        = GLFW_KEY_DOWN,
    Up          = GLFW_KEY_UP,
    PageUp      = GLFW_KEY_PAGE_UP,
    PageDown    = GLFW_KEY_PAGE_DOWN,
    Home        = GLFW_KEY_HOME,
    End         = GLFW_KEY_END,
    CapsLock    = GLFW_KEY_CAPS_LOCK,
    ScrollLock  = GLFW_KEY_SCROLL_LOCK,
    NumLock     = GLFW_KEY_NUM_LOCK,
    PrintScreen = GLFW_KEY_PRINT_SCREEN,
    Pause       = GLFW_KEY_PAUSE,

    F1  = GLFW_KEY_F1,
    F2  = GLFW_KEY_F2,
    F3  = GLFW_KEY_F3,
    F4  = GLFW_KEY_F4,
    F5  = GLFW_KEY_F5,
    F6  = GLFW_KEY_F6,
    F7  = GLFW_KEY_F7,
    F8  = GLFW_KEY_F8,
    F9  = GLFW_KEY_F9,
    F10 = GLFW_KEY_F10,
    F11 = GLFW_KEY_F11,
    F12 = GLFW_KEY_F12,
    F13 = GLFW_KEY_F13,
    F14 = GLFW_KEY_F14,
    F15 = GLFW_KEY_F15,
    F16 = GLFW_KEY_F16,
    F17 = GLFW_KEY_F17,
    F18 = GLFW_KEY_F18,
    F19 = GLFW_KEY_F19,
    F20 = GLFW_KEY_F20,
    F21 = GLFW_KEY_F21,
    F22 = GLFW_KEY_F22,
    F23 = GLFW_KEY_F23,
    F24 = GLFW_KEY_F24,
    F25 = GLFW_KEY_F25,

    KeyPad0 = GLFW_KEY_KP_0,
    KeyPad1 = GLFW_KEY_KP_1,
    KeyPad2 = GLFW_KEY_KP_2,
    KeyPad3 = GLFW_KEY_KP_3,
    KeyPad4 = GLFW_KEY_KP_4,
    KeyPad5 = GLFW_KEY_KP_5,
    KeyPad6 = GLFW_KEY_KP_6,
    KeyPad7 = GLFW_KEY_KP_7,
    KeyPad8 = GLFW_KEY_KP_8,
    KeyPad9 = GLFW_KEY_KP_9,

    KeyPadDecimal  = GLFW_KEY_KP_DECIMAL,
    KeyPadDivide   = GLFW_KEY_KP_DIVIDE,
    KeyPadMultiply = GLFW_KEY_KP_MULTIPLY,
    KeyPadSubtract = GLFW_KEY_KP_SUBTRACT,
    KeyPadAadd     = GLFW_KEY_KP_ADD,
    KeyPadEnter    = GLFW_KEY_KP_ENTER,
    KeyPadEqual    = GLFW_KEY_KP_EQUAL,

    LeftShift      = GLFW_KEY_LEFT_SHIFT,
    LeftControl    = GLFW_KEY_LEFT_CONTROL,
    LeftAlt        = GLFW_KEY_LEFT_ALT,
    LeftSuper      = GLFW_KEY_LEFT_SUPER,
    RightShift     = GLFW_KEY_RIGHT_SHIFT,
    RightControl   = GLFW_KEY_RIGHT_CONTROL,
    RightAlt       = GLFW_KEY_RIGHT_ALT,
    RightSuper     = GLFW_KEY_RIGHT_SUPER,
    Menu           = GLFW_KEY_MENU,
    Last           = GLFW_KEY_LAST,
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


struct Event
{  
    Category        category;
    Keyboard        keyboard;    // key, action, modifier
    Cursor          cursor;
    FrameBufferSize frameBufferSize;
}

enum Direction
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




struct EventBuffer
{
    Event[] queue;    // static array modeling a circular queue

    __gshared uint leave = 0;  // the index in queue of next event to exit queue for processing
    __gshared uint enter = 1;  // the index in queue of next event to enter waiting queue to wait for 

    // queue is empty when leave index is right behind (index is one less) the enter index.

    Event outEvent;  // current event being processed (handling the event)
                     // saves off the event taken out of the queue so 
                     // that the event is definitely saved off within the synchronized period
                     // Since event processing can vary so much in tine, we put the event into
                     // eventOut so that the queue can be freed up to process incoming events.
    Event inEvent;   // current event being sent to the queue  (storing the event)
                     // Not so critical as eventOut, since processing is so simple: just put on queue.
                     // implement for symmetry  


    this(uint size)
    {
        queue = new Event[size]; 
    }

    // Modulus operator is "%" which is the remainder of dividing 'first' by 'second' first % second
    // Could replace in advance function, but potential for overflow?  Decided to keep as is.

    void advance(ref uint x)
    {
        if (x == queue.length-1)  // are we wrapping around clockwise?
            x = 0;
        else
            x++;
    }

 
    bool isDirectlyBehind(long first, long second)
    {
        if( (first+1 == second) ||     // Is enter right behind leave?
            ( (first == queue.length-1) && (second == 0)) ) 
        {
            return true;
        }
        return false;
    }  
    
   
    bool enterOrLeave(Direction move)
    {
        synchronized   // lock everything down when an event enters or exists.
        {
            if(move == Direction.Leaving)
            {
                if(isDirectlyBehind(leave, enter))   
                {
                    //writeln("Queue is empty leave = ", leave, " enter = ", enter);
                    return false;
                }

                advance(leave);  // There is an event go to it
                outEvent = queue[leave];
                return true;
            }
            if(move == Direction.Entering)
            { 
                if(isDirectlyBehind(enter, leave))
                {             
                    //writeln("Queue is full enter = ", enter, " leave = ", leave);
                    return false;
                }

                queue[enter] = inEvent;
                advance(enter);    // advance to new open slot
                return true;
            }
            assert(0);  // should never get here
        } 
        assert(0);  // should never get here
    }


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
        inEvent.category = Category.Keyboard;
        inEvent.keyboard.key = cast(Key) key;
        inEvent.keyboard.action = cast(Action) action; 

        //writeln("modifier = ", modifier);
        if (modifier & GLFW_MOD_SHIFT)
        {
            //writeln("Shift key pressed");
            inEvent.keyboard.modifier.shift = true;
        }
        if (modifier & GLFW_MOD_CONTROL)
        {
            //writeln("Control key pressed");
            inEvent.keyboard.modifier.control = true;
        }
        if (modifier & GLFW_MOD_ALT)
        {
            //writeln("Alternate key pressed");
            inEvent.keyboard.modifier.alternate = true;
        }
        if (modifier & GLFW_MOD_SUPER)
        {
            //writeln("Super key pressed");
            inEvent.keyboard.modifier.superKey = true;
        }

        if (enterOrLeave(Direction.Entering))
        {
            writeln("key = ", inEvent.keyboard.key, " entered at = ", enter-1);
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
        inEvent.category = Category.CursorInOrOut;
        if(entered)
            inEvent.cursor.state = CursorState.In;    
        else
            inEvent.cursor.state = CursorState.Out;

        if (enterOrLeave(Direction.Entering))
        {
            //writeln("cursorState = ", inEvent.cursorState, " entered at = ", enter-1);
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
        inEvent.category = Category.MouseButton;
 
        auto success = enterOrLeave(Direction.Entering);
        if(success)
        {
            //writeln("cursorState = ", inEvent.cursorState, " entered at = ", enter-1);
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
        inEvent.category = Category.CursorPosition;

        inEvent.cursor.position.x = x;
        inEvent.cursor.position.y = y;

        auto success = enterOrLeave(Direction.Entering);
        if(success)
        {
            //writeln("cursorState = ", queue.inEvent.cursorState, " entered at = ", queue.enter-1);
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
        inEvent.category = Category.FrameBufferSize;
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

        inEvent.frameBufferSize.width = width;
        inEvent.frameBufferSize.height = height;
        //writeln("Before Q Add  leave = ", leave, "  enter = ", enter);
        if (enterOrLeave(Direction.Entering))
        {
            //writeln("After Q Add  leave = ", leave, "  enter = ", enter);
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
    //writeln("Before Q SUB  leave = ", leave, "  enter = ", enter);
    if (enterOrLeave(Direction.Leaving))
    {
        //writeln("After Q SUB  leave = ", leave, "  enter = ", enter);       
        eve = outEvent;
    
        if (eve.category == Category.Keyboard)
        {
            //writeln("eve.key = ", eve.keyboard.key, " left at = ", leave-1);
            if (eve.keyboard.key == Key.Escape)
                glfwSetWindowShouldClose(window, GLFW_TRUE);
        }
        if (eve.category == Category.CursorInOrOut)
        {
            //writeln("eve.cursorState = ", eve.cursorState);
        }
        if (eve.category == Category.FrameBufferSize)
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
            //writeln("leave = ", leave);
            //writeln("enter = ", enter);
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
    if (enterOrLeave(Direction.Leaving))
    {     
        event = outEvent;
        return true; 
    }
    else
    {
        return false;
    }

}


}

