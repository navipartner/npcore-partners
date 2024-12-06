controladdin "NPR Backgr. Task Req. Handler"
{
    RequestedWidth = 0;
    RequestedHeight = 0;

    Scripts = 'src/_ControlAddIns/BGTaskRequestHandler/BackgroundTaskRequestHandler.js';

    event ControlAddInReady();

    /// <summary>
    /// Signals the completion of one polling process cycle.
    /// </summary>
    event BackgroundTaskCompletionCallBack()

    /// <summary>
    /// Starts the polling process cycle on the side of the control add-in, with a default interval of 1 second.
    /// </summary>
    procedure PollBackgroundTaskCompletion();
}
