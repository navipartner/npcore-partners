codeunit 6059862 "NPR POSAction - Task Example" implements "NPR IPOS Workflow", "NPR POS Background Task"
{
    SingleInstance = true;
    Access = Internal;
    var
        _TaskDone: Dictionary of [Integer, Boolean];
        _TaskStatus: Dictionary of [Integer, Text];

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'An example action for using POS Background Tasks';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        Parameters: Dictionary of [Text, Text];
        TaskId: Integer;
        IsDone: Boolean;
        Response: JsonObject;
    begin
        case Step of
            'startBackgroundTask':
                begin
                    POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
                    Parameters.Add('URL', 'https://jsonplaceholder.typicode.com/posts');
                    POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::Example, Parameters, (60 * 1000));
                    _TaskDone.Set(TaskId, false);
                    _TaskStatus.Set(TaskId, 'Active');
                    Response.Add('taskId', TaskId);
                    FrontEnd.WorkflowResponse(Response);
                end;
            'cancelBackgroundTask':
                begin
                    POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
                    POSBackgroundTaskAPI.CancelBackgroundTask(Context.GetInteger('taskId'));
                    FrontEnd.WorkflowResponse('');
                end;
            'isTaskDone':
                begin
                    TaskId := Context.GetInteger('taskId');
                    IsDone := _TaskDone.Get(TaskId);
                    Response.Add('isDone', IsDone);
                    Response.Add('status', _TaskStatus.Get(TaskId));
                    FrontEnd.WorkflowResponse(Response);
                    if IsDone then begin
                        _TaskDone.Remove(TaskId);
                    end;
                end;
        end;
    end;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        Http: HttpClient;
        HttpResponse: HttpResponseMessage;
        HttpResponseContent: Text;
    begin
        //Do async. work on a child session

        Sleep(10 * 1000); //mimic slow HTTP request
        Http.Get(Parameters.Get('URL'), HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseContent);

        Result.Add('HttpResponseStatusCode', Format(HttpResponse.HttpStatusCode));
        Result.Add('HttpResponseContent', HttpResponseContent);
        Result.Add('SessionId', Format(SessionId()));
        Result.Add('CurrentClientType', Format(CurrentClientType()));
    end;

    procedure BackgroundTaskSuccessContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; Result: Dictionary of [Text, Text]);
    var
        Json: JsonArray;
        SessionId: Integer;
    begin
        //Handle continuation of async. work back on user session. 
        SessionId := SessionId();
        Json.ReadFrom(Result.Get('HttpResponseContent'));

        //Yay, we wrote server-side asynchronous code in NAV from inside a codeunit without using Automations or DotNet. One step closer to javascript callbacks or C# tasks :)
        //We can parse the JSON and write to DB here.

        _TaskDone.Set(TaskId, true);
        _TaskStatus.Set(TaskId, 'Success');
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    begin
        //Handle error of async. work back on user session.

        //We should probably inspect the error and log it to DB.
        _TaskDone.Set(TaskId, true);
        _TaskStatus.Set(TaskId, 'Error');
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    begin
        //Handle cancellation of async. work back on user session.

        _TaskDone.Set(TaskId, true);
        _TaskStatus.Set(TaskId, 'Cancellation');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTaskExample.js###
'let main=async({workflow:a,context:n})=>{let{taskId:t}=await a.respond("startBackgroundTask",n),s="",i=new Promise(async o=>{let e=async()=>{let{isDone:c,status:k}=await a.respond("isTaskDone",{taskId:t});if(c){s=k,o();return}setTimeout(e,1e3)};setTimeout(e,1e3)});await popup.confirm("Attempt cancellation of background task?")&&await a.respond("cancelBackgroundTask",{taskId:t}),await i,await popup.message("Background task is done with status: "+s)};'
        );
    end;
}
