codeunit 6151538 "NPR POS Action SS - Text Enter" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for completing the TextEnter request passed from the front end (when user presses enter in a supported text box) for Self Service';
        EventErr: Label 'is not handled';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('NotHandled', EventErr);
        WorkflowConfig.SetWorkflowTypeUnattended();
        WorkflowConfig.SetNonBlockingUI();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSAction: Record "NPR POS Action";
        POSSession: Codeunit "NPR POS Session";
        EanBoxEventHandler: Codeunit "NPR POS Input Box Evt Handler";
        EanBoxSetupEvent: Record "NPR Ean Box Setup Event";
        Value: Text;
        SetupCode: code[20];
        EventCode: Code[20];
    begin
        Value := Context.GetString('value');

        case Step of
            'prepareRequest':
                begin
                    EanBoxEventHandler.GetEanBox(Value, POSAction, POSSession, FrontEnd, SetupCode, EventCode);
                    FrontEnd.WorkflowResponse(SendRequest(POSAction, SetupCode, EventCode, Value));
                end;
            'doLegacyWorkflow':  //continue for legacy
                begin
                    GetEanBoxSetupEvent(Context, EanBoxSetupEvent);
                    FrontEnd.WorkflowResponse(DoLegacyAction(Value, FrontEnd, EanBoxSetupEvent, POSSession));
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSTextEnter.js###
'let main=async({workflow:e,context:a,captions:t,popup:n})=>{switch(a.id){case"EanBox":case"PaymentBox":const{workflowName:r,workflowVersion:o,setupcode:d,eventcode:s,parameters:i}=await e.respond("prepareRequest");o>1&&await e.run(r,{parameters:i}),o==1&&await e.respond("doLegacyWorkflow",{actionCode:r,setupcode:d,eventcode:s});return;default:n.error("Control "+a.id+" "+t.NotHandled);return}};'
        );
    end;


    local procedure DoLegacyAction(EanBoxValue: Text; FrontEnd: Codeunit "NPR POS Front End Management"; EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; POSSession: Codeunit "NPR POS Session") Response: JsonObject
    var
        EanBoxEventHandler: Codeunit "NPR POS Input Box Evt Handler";
    begin
        EanBoxEventHandler.InvokePOSAction(EanBoxValue, EanBoxSetupEvent, POSSession, FrontEnd);
        exit(Response);
    end;

    local procedure GetWorkflowVersion(POSAction: record "NPR POS Action"): Integer
    begin
        if POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY then
            exit(1);
        exit(3);
    end;

    local procedure InitRequest(Version: Integer; Name: text) Request: JsonObject
    begin
        Request.Add('workflowVersion', Version);
        Request.Add('workflowName', Name);
    end;

    procedure SendRequest(var POSAction: Record "NPR POS Action"; SetupCode: code[20]; EventCode: Code[20]; EanBoxValue: Text) Request: JsonObject
    var
        EanBoxSetupEvent: Record "NPR Ean Box Setup Event";
        WorkflowVersion: Integer;
        WorkflowInvocationParameters: JsonObject;
        WorkflowInvocationContext: JsonObject;
        EanBoxEventHandler: Codeunit "NPR POS Input Box Evt Handler";
    begin
        WorkflowVersion := GetWorkflowVersion(POSAction);
        Request := InitRequest(WorkflowVersion, POSAction.Code);
        EanBoxSetupEvent.get(SetupCode, EventCode);

        IF POSAction."Workflow Implementation" <> POSAction."Workflow Implementation"::LEGACY then begin
            EanBoxEventHandler.SetEanParametersToPOSAction(EanBoxValue, POSAction, EanBoxSetupEvent);
            POSAction.GetWorkflowInvocationContext(WorkflowInvocationParameters, WorkflowInvocationContext);
            Request.Add('parameters', WorkflowInvocationParameters);
        end else begin
            Request.add('setupcode', EanBoxSetupEvent."Setup Code");
            Request.add('eventcode', EanBoxSetupEvent."Event Code");
        end;

        exit(Request);
    end;

    internal procedure GetEanBoxSetupEvent(Context: Codeunit "NPR POS JSON Helper"; var EanBoxSetupEvent: Record "NPR Ean Box Setup Event")
    begin
        EanBoxSetupEvent.get(UpperCase(Context.GetString('setupcode')), UpperCase(Context.GetString('eventcode')));
    end;
}
