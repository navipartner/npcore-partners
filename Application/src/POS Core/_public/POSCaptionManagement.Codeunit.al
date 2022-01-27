codeunit 6150720 "NPR POS Caption Management"
{
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
        Captions: JsonObject;
        Duplicate: Integer;
        Initialized: Boolean;
        Text001: Label 'Caption management has not been initialized, and an attempt was made to use it. This is a programming bug, not a user error.';
        Text002: Label 'Caption with ID %1 has already been added to the front end, and an attempt was made to add it again. The original caption value is retained.';
        Text003: Label 'There have been %1 duplicate captions detected during action initialization. This indicates a programming issue, most likely an action codeunit that uses the same action ID as another action codeunit. Please check the front-end log for warnings to learn which captions are duplicated.';

    procedure Initialize(var FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        FrontEnd := FrontEndIn;
        Initialized := true;
    end;

    procedure Finalize(var CaptionsOut: JsonObject)
    var
        CaptionKey: Text;
        CaptionToken: JsonToken;
        DuplicateWarning: Text;
    begin
        FailIfNotInitialized();

        Duplicate := 0;
        foreach CaptionKey in Captions.Keys() do begin
            Captions.Get(CaptionKey, CaptionToken);
            AddCaptionToCollection(CaptionsOut, CaptionKey, CaptionToken.AsValue().AsText(), false);
        end;

        if Duplicate > 0 then begin
            DuplicateWarning := StrSubstNo(Text003, Duplicate);
            FrontEnd.ReportWarning(DuplicateWarning, false);
            Message(DuplicateWarning);
        end;
    end;

    local procedure FailIfNotInitialized()
    begin
        if not Initialized then
            Error(Text001);
    end;

    local procedure AddCaptionToCollection(Target: JsonObject; CaptionId: Text; CaptionValue: Text; RejectDuplicate: Boolean)
    begin
        if Target.Contains(CaptionId) then begin
            FrontEnd.ReportWarning(StrSubstNo(Text002, CaptionId), false);
            Duplicate += 1;
            if RejectDuplicate then
                exit;
            Target.Remove(CaptionId);
        end;

        Target.Add(CaptionId, CaptionValue);
    end;

    procedure AddCaption(CaptionId: Text; CaptionText: Text)
    begin
        FailIfNotInitialized();
        AddCaptionToCollection(Captions, CaptionId, CaptionText, true);
    end;

    procedure AddActionCaption(ActionCode: Text; CaptionId: Text; CaptionText: Text)
    begin
        AddCaption(ActionCode + '.' + CaptionId, CaptionText);
    end;
}
