codeunit 6151324 "NPR POSActionInputBoxJson" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        _ActionDescription: Label 'This is a build in action to handle JSON sent to the input box.';
        _PayloadKey: Label 'payload', Locked = true;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        PayloadCaption: Label 'Payload';
        PayloadDescription: Label 'The JSON payload that should be processed.';

    begin
        WorkflowConfig.AddActionDescription(_ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter(_PayloadKey, '', PayloadCaption, PayloadDescription);
    end;

    procedure RunWorkflow(Step: Text;
                          Context: Codeunit "NPR POS JSON Helper";
                          FrontEnd: Codeunit "NPR POS Front End Management";
                          Sale: Codeunit "NPR POS Sale";
                          SaleLine: Codeunit "NPR POS Sale Line";
                          PaymentLine: Codeunit "NPR POS Payment Line";
                          Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'delegateRequest':
                FrontEnd.WorkflowResponse(DelegateToRequestHandler(Context, FrontEnd));
        end;
    end;

    local procedure DelegateToRequestHandler(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"): JsonObject
    var
        JObject: JsonObject;
        Payload: Text;
        JToken: JsonToken;
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
    begin
        Payload := Context.GetStringParameter(_PayloadKey);
        JObject.ReadFrom(Payload);

        if (JObject.Get('createMembership', JToken)) then
            exit(MemberRetailIntegration.CreateMembershipFromJson(JToken.AsObject(), FrontEnd));

        Error('DelegateToRequestHandler, unhandled JSON : %1', Context.ToString());
    end;


    local procedure InputBoxEventCode(): Code[20]
    begin
        exit('INPUTBOX_JSON_ACTION');
    end;

    procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::INPUTBOX_JSON));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action Member Mgt WF3");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    begin

        if (not EanBoxEvent.Get(InputBoxEventCode())) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := InputBoxEventCode();
            EanBoxEvent."Module Name" := 'Json Action Orchestration';
            EanBoxEvent.Description := 'Json Payload action';
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitId();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin

        case EanBoxEvent.Code of
            InputBoxEventCode():
                begin
                    Sender.SetNonEditableParameterValues(EanBoxEvent, _PayloadKey, true, '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeMemberCardNo(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        JObject: JsonObject;
    begin

        if (EanBoxSetupEvent."Event Code" <> InputBoxEventCode()) then
            exit;

        if (StrLen(EanBoxValue) < 5) then
            exit;

        if ((CopyStr(EanBoxValue, 1, 2) <> '{"') and (CopyStr(EanBoxValue, StrLen(EanBoxValue)) <> '}')) then
            exit;

        if (not JObject.ReadFrom(EanBoxValue)) then
            exit;

        InScope := true;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionInputBoxJson.js###
'let main=async({workflow:e,context:t,captions:a,popup:n})=>{await e.respond("delegateRequest")};'
        );
    end;

}
