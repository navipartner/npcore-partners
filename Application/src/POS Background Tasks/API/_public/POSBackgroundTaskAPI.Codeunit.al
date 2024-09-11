codeunit 6059863 "NPR POS Background Task API"
{
    var
        _POSBackgroundTaskManager: Codeunit "NPR POS Backgr. Task Manager";
        _Initialized: Boolean;

    procedure Initialize(POSBackgroundTaskManager: Codeunit "NPR POS Backgr. Task Manager")
    begin
        if (_Initialized) then
            Error('Attempted to initialize the POS background task module more than once. This is a programming bug.');
        _POSBackgroundTaskManager := POSBackgroundTaskManager;
        _Initialized := true;
    end;

    procedure EnqueuePOSBackgroundTask(var TaskIdOut: Integer; TaskImplementation: Enum "NPR POS Background Task"; var Parameters: Dictionary of [Text, Text]; Timeout: Integer)
    begin
        ErrorIfNotInitialized();
        _POSBackgroundTaskManager.EnqueuePOSBackgroundTask(TaskIdOut, TaskImplementation, Parameters, Timeout);
    end;

    procedure CancelBackgroundTask(TaskId: Integer)
    begin
        ErrorIfNotInitialized();
        _POSBackgroundTaskManager.CancelPOSBackgroundTask(TaskId);
    end;

    local procedure ErrorIfNotInitialized()
    begin
        if not _Initialized then
            Error('Attempted to queue a POS background task on an un-initialized instance of the POS background task module. This is a programming bug. Use the POSSession getter.');
    end;
}