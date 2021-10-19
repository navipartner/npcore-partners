codeunit 6151523 "NPR Nc Trigger Sample Sub."
{
    var
        CRLFString: Text[20];

    local procedure WriteText(var Output: Text)
    begin
        Output := '---> Sample Output Text Line 1 <----';
        Output := Output + CRLFString;
        Output := Output + '---> Sample Output Text Line 2 <----';
    end;

    local procedure CreateOutput(var Output: Text)
    begin
        Output := '';
        CRLFString[1] := 13;
        CRLFString[2] := 10;
        //Header
        WriteText(Output);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Trigger Task Mgt.", 'OnRunNcTriggerTask', '', false, false)]
    local procedure OnRunNcTriggerTaskProcessExport(TriggerCode: Code[20]; var Output: Text; var NcTask: Record "NPR Nc Task"; var Handled: Boolean; var CurrentIteration: Integer; var MaxIterations: Integer; var Filename: Text; var Subject: Text; var Body: Text)
    begin
        if Handled then
            exit;
        if TriggerCode <> GetTriggerCode() then
            exit;
        CreateOutput(Output);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Nc Trigger Task Mgt.", 'OnSetupNcTriggers', '', false, false)]
    local procedure OnSetupNcTriggersInsertNcTrigger()
    var
        NcTrigger: Record "NPR Nc Trigger";
    begin
        if NcTrigger.Get(GetTriggerCode()) then
            exit;
        NcTrigger.Init();
        NcTrigger.Validate(Code, GetTriggerCode());
        NcTrigger.Validate(Description, GetTriggerDescription());
        NcTrigger.Validate("Subscriber Codeunit ID", CODEUNIT::"NPR Nc Trigger Sample Sub.");
        NcTrigger.Insert(true);
    end;

    local procedure GetTriggerCode(): Code[20]
    begin
        exit('SAMPLE');
    end;

    local procedure GetTriggerDescription(): Text
    var
        SampleTxt: Label 'This is a sample Nc Trigger';
    begin
        exit(SampleTxt);
    end;
}

