codeunit 6151523 "Nc Trigger Sample Subscriber"
{
    // NC2.01/BR /20160809  CASE 247479 NaviConnect: Object created
    // NC2.01/BR/20161219  CASE 261431 Added subscriber codeunit to trigger


    trigger OnRun()
    begin
    end;

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
        WriteText(Output) ;
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151522, 'OnRunNcTriggerTask', '', false, false)]
    local procedure OnRunNcTriggerTaskProcessExport(TriggerCode: Code[20];var Output: Text;var NcTask: Record "Nc Task";var Handled: Boolean;var CurrentIteration: Integer;var MaxIterations: Integer;var Filename: Text;var Subject: Text;var Body: Text)
    var
        TxtSubject: Label 'This is the Subject of a sample email.';
        TxtBody: Label 'This is the Body text of a sample email.';
    begin
        if Handled then
          exit;
        if TriggerCode <> GetTriggerCode then
          exit;
        CreateOutput(Output);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151522, 'OnSetupNcTriggers', '', false, false)]
    local procedure OnSetupNcTriggersInsertNcTrigger()
    var
        NcTrigger: Record "Nc Trigger";
    begin
        if NcTrigger.Get(GetTriggerCode) then
          exit;
        NcTrigger.Init;
        NcTrigger.Validate(Code,GetTriggerCode);
        NcTrigger.Validate(Description,GetTriggerDescription);
        //-NC2.01 [261431]
        NcTrigger.Validate("Subscriber Codeunit ID",CODEUNIT::"Nc Trigger Sample Subscriber");
        //+NC2.01 [261431]
        NcTrigger.Insert(true);
    end;

    local procedure "--- Constants"()
    begin
    end;

    local procedure GetTriggerCode(): Code[20]
    begin
        exit('SAMPLE');
    end;

    local procedure GetTriggerDescription(): Text
    var
        TextDescr: Label 'This is a sample Nc Trigger';
    begin
        exit(TextDescr);
    end;
}

