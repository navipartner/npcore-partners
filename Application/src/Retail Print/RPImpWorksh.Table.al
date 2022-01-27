table 6014569 "NPR RP Imp. Worksh."
{
    Access = Internal;
    Caption = 'Import Worksheet';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; Template; Code[20])
        {
            Caption = 'Template';
            DataClassification = CustomerContent;
        }
        field(3; "Action"; Option)
        {
            Caption = 'Action';
            OptionCaption = 'Create,Replace,Skip';
            OptionMembers = Create,Replace,Skip;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "New Template" then begin
                    if Action = Action::Replace then
                        Error(ERROR_INVALID_ACTION, Action, Template);
                end else begin
                    if Action = Action::Create then
                        Error(ERROR_INVALID_ACTION, Action, Template);
                end;
            end;
        }
        field(4; Warning; Boolean)
        {
            Caption = 'Warning';
            DataClassification = CustomerContent;
        }
        field(5; "Existing Description"; Text[250])
        {
            Caption = 'Existing Description';
            DataClassification = CustomerContent;
        }
        field(6; "New Description"; Text[250])
        {
            Caption = 'New Description';
            DataClassification = CustomerContent;
        }
        field(7; "Existing Version"; Code[50])
        {
            Caption = 'Existing Version';
            DataClassification = CustomerContent;
        }
        field(8; "New Version"; Code[50])
        {
            Caption = 'New Version';
            DataClassification = CustomerContent;
        }
        field(9; "Existing Last Modified At"; DateTime)
        {
            Caption = 'Existing Last Modified At';
            DataClassification = CustomerContent;
        }
        field(10; "New Last Modified At"; DateTime)
        {
            Caption = 'New Last Modified At';
            DataClassification = CustomerContent;
        }
        field(11; "New Template"; Boolean)
        {
            Caption = 'New Template';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    trigger OnInsert()
    begin
        SetDefaultAction();
    end;

    var
        ERROR_INVALID_ACTION: Label 'Invalid action %1 for template %2';

    procedure SetDefaultAction()
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if not RPTemplateHeader.Get(Template) then begin
            "New Template" := true;
            Action := Action::Create;
            exit;
        end;

        if ("Existing Version" = "New Version") then
            if CompareDateTime("Existing Last Modified At", "New Last Modified At") then begin
                Action := Action::Skip;
                exit;
            end;

        if IsSafeVersionIncrease() then
            Action := Action::Replace
        else begin
            Action := Action::Skip;
            Warning := true;
        end;
    end;

    procedure SetStyle(): Text
    begin
        if Warning then
            exit('Unfavorable');

        if Action = Action::Skip then
            exit('Subordinate');

        if Action = Action::Create then
            exit('Favorable');

        if IsSafeVersionIncrease() then
            exit('Favorable')
        else
            exit('Unfavorable');
    end;

    local procedure IsSafeVersionIncrease(): Boolean
    var
        VersionArray: List of [Text];
        ExistingVersion: Text;
        Version: Text;
        VersionPos: Integer;
        EndOfString: Boolean;
        Length: Integer;
        TotalLength: Integer;
        NewVersionDecimal: Decimal;
        ExistingVersionDecimal: Decimal;
        VersionTag: Text;
    begin
        if ("Existing Version" = '') or ("New Version" = '') then
            exit(false);

        if ("Existing Version" = "New Version") then begin
            if CompareDateTime("Existing Last Modified At", "New Last Modified At") then
                exit(true)
            else
                exit(false);
        end;

        if "Existing Last Modified At" > "New Last Modified At" then
            exit(false);

        ExistingVersion := "Existing Version";
        VersionArray := ExistingVersion.Split(',');
        foreach Version in VersionArray do begin
            VersionTag := DelChr(Version, '=', '0123456789.');
            VersionPos := StrPos("New Version", VersionTag);
            if VersionPos = 0 then
                exit(false);

            VersionPos += StrLen(VersionTag);

            if not Evaluate(ExistingVersionDecimal, CopyStr(Version, VersionPos)) then
                exit(false);

            EndOfString := false;
            Length := 1;
            TotalLength := StrLen("New Version");
            while (not EndOfString) do begin
                if Length + 1 > TotalLength then
                    EndOfString := true
                else
                    EndOfString := not ("New Version"[VersionPos + Length] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']);
                Length += 1;
            end;

            if Length < 1 then
                exit(false);
            if not Evaluate(NewVersionDecimal, CopyStr("New Version", VersionPos, Length - 1)) then
                exit(false);
            if ExistingVersionDecimal > NewVersionDecimal then
                exit(false);
        end;

        exit(true);
    end;

    local procedure CompareDateTime(DateTime1: DateTime; DateTime2: DateTime): Boolean
    begin
        //Accept equality without seconds since they have been cut off the datetime on some package files, due to an older bug that has since been fixed.
        exit((RoundDateTime(DateTime1, 60000, '<') = RoundDateTime(DateTime2, 60000, '<')) and (DateTime1 <> 0DT));
    end;
}
