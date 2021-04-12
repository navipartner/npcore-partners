codeunit 6150748 "NPR POS Run Workflow"
{
    var
        ReadingErr: Label 'reading in %1';

    procedure RunWorkflow(ActionCode: Code[20]; var Parameters: Record "NPR POS Parameter Value" temporary; Context: JsonObject) Result: Guid
    var
        Request: Codeunit "NPR Front-End: Generic";
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
        MethodName: Label 'OnRunWorkflowCompleted', Locked = true;
    begin
        if Method <> MethodName then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        OnRunWorkflowCompleted(Method, JSON.GetStringOrFail('id', StrSubstNo(ReadingErr, MethodName)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure RunWorkflowFailed(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        MethodName: Label 'OnRunWorkflowFailed', Locked = true;
    begin
        if Method <> MethodName then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        OnRunWorkflowFailed(Method, JSON.GetStringOrFail('id', StrSubstNo(ReadingErr, MethodName)), JSON.GetStringOrFail('error', StrSubstNo(ReadingErr, MethodName)));
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
