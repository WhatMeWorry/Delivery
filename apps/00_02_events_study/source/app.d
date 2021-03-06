
module app; // 00_02_events_study


import event_buffer;
import mytoolbox;

import std.stdio;
import std.concurrency;
import core.thread;


import bindbc.opengl;  // GLint, glGetIntegerv, glGetString;
import bindbc.glfw;

import dynamic_libs.glfw;
import dynamic_libs.opengl;


void createEvents(shared EventBuffer eventBuffer)
{
    int ignore = 0;
    // we will simulate user activity with mouse, keyboard, etc.
    // We will create and put events on the queue as fast
    // as possible while the eventHandler will be called
    // every pass through the main loop of the main()

    for (int i; i < 10; i++)
    {
        eventBuffer.inEvent.category = Category.Keyboard;
        eventBuffer.inEvent.keyboard.key = Key.a;
        eventBuffer.inEvent.keyboard.action = Action.Pressed; 

        writeln("==================================before enterOrLeaveQueue");

        eventBuffer.enterOrLeaveQueue(Direction.Entering);

        writeln("++++++++++++++++++++++++++++++++ After  enterOrLeaveQueue");
        Thread.sleep(700.msecs);        
        //writeln("Creating event ", i); 
    }

    eventBuffer.inEvent.category = Category.Keyboard;
    eventBuffer.inEvent.keyboard.key = Key.Escape;
    eventBuffer.inEvent.keyboard.action = Action.Pressed; 

}



void main()
{
    //load_libraries();

    load_GLFW_Library();

    load_openGL_Library();  

    shared EventBuffer eventBuffer = shared EventBuffer(24);

    auto window = glfwCreateWindow(800, 600, "00_02_events_study", null, null);

    glfwMakeContextCurrent(window);

    // you must set the callbacks after creating the window

    //            glfwSetKeyCallback(window, &onKeyEvent);
    //glfwSetFramebufferSizeCallback(window, &onFrameBufferResize); 
    //    glfwSetCursorEnterCallback(window, &onCursorEnterOrLeaveWindow);   
          //glfwSetCursorPosCallback(window, &onCursorPosition);  


    writeln("Move Cursor into Window before attempting Keyboard Events!");

    
    spawn(&createEvents, eventBuffer);

    writeAndPause("After spawn");

    while (!glfwWindowShouldClose(window))    // Loop until the user closes the window
    {
        //write(".");
        // glfwPollEvents processes only those events that are already in the event queue and 
        // then returns immediately. Processing events will cause the window and input callbacks 
        // associated with those events to be called.
/+
        EventBuffer.inEvent.category = Category.Keyboard;
        EventBuffer.inEvent.keyboard.key = Key.a;
        EventBuffer.inEvent.keyboard.action = Action.Pressed; 

        EventBuffer.enterOrLeaveQueue(Direction.Entering);

        EventBuffer.enterOrLeaveQueue(Direction.Entering);
+/
        Thread.sleep(1500.msecs);      
        //writeln("inside main loop");        

        // if glfwPollEvents() is not called, none of the glfw callbacks are ever executed
        //glfwPollEvents();
        handleEvent(window);
    }
}



 