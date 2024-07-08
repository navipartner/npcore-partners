codeunit 6060079 "NPR Dragonglass Response Queue"
{
    //Before this object, all of our AL code that needed to send data to dragonglass (the javascript frontend), just called the 
    //control addin procedure directly and kept executing more AL code.
    //
    //This meant that we sometimes had more than 1 call back to dragonglass from within the same AL stack.
    //This caused several problems:
    //
    //1. From the point of view of the frontend, especially as a frontend developer with no BC knowledge, you cannot easily
    //grasp and debug an architecture where you send 1 request to the backend and N responses come back.
    //Not only that, all N responses happen over a websocket, so you do not see them nicely awaited in your javascript debugger.
    //Instead, the websocket event handler beneath microsofts helper functions will schedule the processing of the events at the 
    //back of the JS event loop, meaning the frontend JS has to go "idle" before all N events from AL are processed.
    //Totally disjointed, and if anything fails, an error/exception cannot bubble up to the correct place, leading to even more 
    //confusing logs and stack traces.
    //
    //2. A "1 request -> N responses" architecture is not compatible with HTTP, meaning you cannot get more than 1 response to your 1 request
    //over odata or SOAP.
    //
    //Because of these limitations, this object has been added - instead of calling directly back to frontend,
    //all calls will instead be queued here, and at the end of the AL callstack, the queue will be emptied and any
    //json objects will be batched into one json array. That json array will then be send to the dragonglass frontend.
    //This ensures that each 1 request will at most result in 1 response, making the solution HTTP API compliant and easier to grok from the frontend.        

    Access = Internal;

    var
        _QueuedRequests: JsonArray;

    procedure QueueInvokeFrontendRequest(Request: JsonObject)
    begin
        _QueuedRequests.Add(Request);
    end;

    procedure PopQueuedRequests() QueuedRequests: JsonArray
    begin
        QueuedRequests := _QueuedRequests;
        Clear(_QueuedRequests);
    end;
}