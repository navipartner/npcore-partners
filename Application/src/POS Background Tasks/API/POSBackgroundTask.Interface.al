interface "NPR POS Background Task"
{
#if not BC17
    Access = internal;
#endif
    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text])
    procedure BackgroundTaskSuccessContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; Results: Dictionary of [Text, Text])
    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text)
    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text])
}