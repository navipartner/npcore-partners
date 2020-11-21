codeunit 6150748 "NPR POS Run Workflow"
{
    procedure RunWorkflow(ActionCode: Code[20]; var Parameters: Record "NPR POS Parameter Value" temporary; Context: JsonObject) Result: Guid
    var
        Request: Codeunit "NPR Front-End: Generic";
        JContent: JsonObject;
        JParameters: JsonObject;
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        Result := CreateGuid();

        Request.SetMethod('RunWorkflow');
        Request.GetContent().Add('id', Result);
        Request.GetContent().Add('action', ActionCode);
        Request.GetContent().Add('context', Format(Context));

        if Parameters.FindSet() then begin
            repeat
                Parameters.AddParameterToJObject(JParameters);
            until Parameters.Next() = 0;
            Request.GetContent().Add('parameters', Format(JParameters));
        end;

        FrontEnd.InvokeFrontEndMethod(Request);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure RunWorkflowCompleted(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if Method <> 'OnRunWorkflowCompleted' then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        OnRunWorkflowCompleted(Method, JSON.GetString('id', true));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure RunWorkflowFailed(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if Method <> 'OnRunWorkflowFailed' then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        OnRunWorkflowFailed(Method, JSON.GetString('id', true), JSON.GetString('error', true));
    end;

    [BusinessEvent(false)]
    local procedure OnRunWorkflowCompleted(Method: Text; Id: Guid);
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnRunWorkflowFailed(Method: Text; Id: GUID; ErrorMessage: Text)
    begin
    end;
}
