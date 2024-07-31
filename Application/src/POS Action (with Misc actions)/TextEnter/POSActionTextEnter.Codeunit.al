codeunit 6150722 "NPR POS Action: Text Enter" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for completing the TextEnter request passed from the front end (when user presses enter in a supported text box)';
        EventErr: Label 'is not handled';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('NotHandled', EventErr);
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
                    FrontEnd.WorkflowResponse(SendRequest(Context, POSAction, SetupCode, EventCode, Value, Setup, FrontEnd));
                end;
            'doLegacyWorkflow':  //continue for legacy
                begin
                    GetEanBoxSetupEvent(Context, EanBoxSetupEvent);
                    FrontEnd.WorkflowResponse(DoLegacyAction(Value, FrontEnd, EanBoxSetupEvent, POSSession));
                end;
        end;
    end;

    local procedure UseSimpleInsert(Context: Codeunit "NPR POS JSON Helper"; var POSAction: Record "NPR POS Action"; Setup: Codeunit "NPR POS Setup"; FrontEnd: Codeunit "NPR POS Front End Management"; WorkflowInvocationParameters: JsonObject; var Response: JsonObject) Success: Boolean
    var
        NPRPOSActionInsertItem: Codeunit "NPR POS Action: Insert Item";
        ValueJsonToken: JsonToken;
        ItemIdentifierType: Option ItemNo,ItemCrossReference,ItemSearch,SerialNoItemCrossReference,ItemGtin;
        ItemIdentifier: Text;
        UnitOfMeasureCode: Code[10];
        SelectLotNo: Integer;
        ItemQuantity: Decimal;
        PreSetUnitPrice: Decimal;
        UnitPrice: Decimal;
        SelectSerialNo: Boolean;
        SelectSerialNoListEmptyInput: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        UsePreSetUnitPrice: Boolean;
    begin
        if POSAction.Code <> NPRPOSActionInsertItem.ActionCode() then
            exit;

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('itemIdentifierType', ValueJsonToken) then
            exit;

        ItemIdentifierType := ValueJsonToken.AsValue().AsOption();

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('itemNo', ValueJsonToken) then
            exit;

        ItemIdentifier := ValueJsonToken.AsValue().AsText();

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('unitOfMeasure', ValueJsonToken) then
            exit;

#pragma warning disable AA0139
        UnitOfMeasureCode := ValueJsonToken.AsValue().AsCode();
#pragma warning restore AA0139

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('SelectSerialNo', ValueJsonToken) then
            exit;

        SelectSerialNo := ValueJsonToken.AsValue().AsBoolean();

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('itemQuantity', ValueJsonToken) then
            exit;

        ItemQuantity := ValueJsonToken.AsValue().AsDecimal();

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('usePreSetUnitPrice', ValueJsonToken) then
            exit;

        UsePreSetUnitPrice := ValueJsonToken.AsValue().AsBoolean();

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('preSetUnitPrice', ValueJsonToken) then
            exit;

        PreSetUnitPrice := ValueJsonToken.AsValue().AsDecimal();

        if UsePreSetUnitPrice then
            UnitPrice := PreSetUnitPrice;

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('SkipItemAvailabilityCheck', ValueJsonToken) then
            exit;

        SkipItemAvailabilityCheck := ValueJsonToken.AsValue().AsBoolean();

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('SelectSerialNoListEmptyInput', ValueJsonToken) then
            exit;

        SelectSerialNoListEmptyInput := ValueJsonToken.AsValue().AsBoolean();

        Clear(ValueJsonToken);
        if not WorkflowInvocationParameters.Get('SelectLotNo', ValueJsonToken) then
            exit;

        SelectLotNo := ValueJsonToken.AsValue().AsInteger();

        Success := NPRPOSActionInsertItem.SimpleItemInsert(Context, ItemIdentifier, ItemIdentifierType, ItemQuantity, UnitOfMeasureCode, UnitPrice, SkipItemAvailabilityCheck, SelectSerialNo, SelectLotNo, UsePreSetUnitPrice, SelectSerialNoListEmptyInput, Setup, FrontEnd, Response);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTextEnter.js###
'let main=async({workflow:e,context:a,captions:o,popup:n})=>{switch(a.id){case"EanBox":case"PaymentBox":const{workflowName:r,workflowVersion:t,setupcode:s,eventcode:d,parameters:i,simpleInsertUsed:c}=await e.respond("prepareRequest");if(c)return;t>1&&await e.run(r,{parameters:i}),t==1&&await e.respond("doLegacyWorkflow",{actionCode:r,setupcode:s,eventcode:d});return;default:n.error("Control "+a.id+" "+o.NotHandled);return}};'
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

    procedure SendRequest(Context: Codeunit "NPR POS JSON Helper"; var POSAction: Record "NPR POS Action"; SetupCode: code[20]; EventCode: Code[20]; EanBoxValue: Text; Setup: Codeunit "NPR POS Setup"; FrontEnd: Codeunit "NPR POS Front End Management") Request: JsonObject
    var
        EanBoxSetupEvent: Record "NPR Ean Box Setup Event";
        EanBoxEventHandler: Codeunit "NPR POS Input Box Evt Handler";
        WorkflowVersion: Integer;
        WorkflowInvocationParameters: JsonObject;
        WorkflowInvocationContext: JsonObject;
    begin
        EanBoxSetupEvent.get(SetupCode, EventCode);
        EanBoxEventHandler.SetEanParametersToPOSAction(EanBoxValue, POSAction, EanBoxSetupEvent);
        POSAction.GetWorkflowInvocationContext(WorkflowInvocationParameters, WorkflowInvocationContext);

        if UseSimpleInsert(Context, POSAction, Setup, FrontEnd, WorkflowInvocationParameters, Request) then
            exit;

        WorkflowVersion := GetWorkflowVersion(POSAction);
        Request := InitRequest(WorkflowVersion, POSAction.Code);

        IF POSAction."Workflow Implementation" <> POSAction."Workflow Implementation"::LEGACY then begin
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
