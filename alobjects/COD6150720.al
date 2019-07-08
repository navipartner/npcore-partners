codeunit 6150720 "POS Caption Management"
{
    // NPR5.44/JDH /20180731  CASE 323499 Changed all functions to be External


    trigger OnRun()
    begin
    end;

    var
        FrontEnd: Codeunit "POS Front End Management";
        Captions: DotNet Dictionary_Of_T_U;
        Duplicate: Integer;
        Initialized: Boolean;
        Text001: Label 'Caption management has not been initialized, and an attempt was made to use it. This is a programming bug, not a user error.';
        Text002: Label 'Caption with ID %1 has already been added to the front end, and an attempt was made to add it again. The original caption value is retained.';
        Text003: Label 'There have been %1 duplicate captions detected during action initialization. This indicates a programming issue, most likely an action codeunit that uses the same action ID as another action codeunit. Please check the front-end log for warnings to learn which captions are duplicated.';

    [Scope('Personalization')]
    procedure Initialize(var FrontEndIn: Codeunit "POS Front End Management")
    begin
        FrontEnd := FrontEndIn;
        Captions := Captions.Dictionary;
        Initialized := true;
    end;

    [Scope('Personalization')]
    procedure Finalize(CaptionsOut: DotNet Dictionary_Of_T_U)
    var
        KeyValuePair: DotNet KeyValuePair_Of_T_U;
        DuplicateWarning: Text;
    begin
        FailIfNotInitialized();

        if IsNull(CaptionsOut) then
          exit;

        Duplicate := 0;
        foreach KeyValuePair in Captions do
          AddCaptionToCollection(CaptionsOut,KeyValuePair.Key,KeyValuePair.Value,false);

        if Duplicate > 0 then begin
          DuplicateWarning := StrSubstNo(Text003,Duplicate);
          FrontEnd.ReportWarning(DuplicateWarning,false);
          Message(DuplicateWarning);
        end;
    end;

    local procedure FailIfNotInitialized()
    begin
        if not Initialized then
          Error(Text001);
    end;

    local procedure AddCaptionToCollection(Target: DotNet Dictionary_Of_T_U;CaptionId: Text;CaptionText: Text;RejectDuplicate: Boolean)
    begin
        if Target.ContainsKey(CaptionId) then begin
          FrontEnd.ReportWarning(StrSubstNo(Text002,CaptionId),false);
          Duplicate += 1;
          if RejectDuplicate then
            exit;
          Target.Remove(CaptionId);
        end;

        Target.Add(CaptionId,CaptionText);
    end;

    [Scope('Personalization')]
    procedure AddCaption(CaptionId: Text;CaptionText: Text)
    begin
        FailIfNotInitialized();
        AddCaptionToCollection(Captions,CaptionId,CaptionText,true);
    end;

    [Scope('Personalization')]
    procedure AddActionCaption(ActionCode: Text;CaptionId: Text;CaptionText: Text)
    begin
        AddCaption(ActionCode + '.' + CaptionId,CaptionText);
    end;
}

