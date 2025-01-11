table 6151008 "NPR DE Submission"
{
    Access = Internal;
    Caption = 'DE Submission';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR DE Submissions";
    LookupPageId = "NPR DE Submissions";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code (Establishment)';
            DataClassification = CustomerContent;
            TableRelation = "NPR DE Establishment";
            Editable = false;
        }
        field(15; "Establishment Id"; Guid)
        {
            Caption = 'Establishment Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; State; Enum "NPR DE Submission State")
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(30; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(40; "Generated At"; DateTime)
        {
            Caption = 'Generated At';
            DataClassification = CustomerContent;
        }
        field(50; "Transmitted At"; DateTime)
        {
            Caption = 'Transmitted At';
            DataClassification = CustomerContent;
        }
        field(60; "Errored At"; DateTime)
        {
            Caption = 'Errored At';
            DataClassification = CustomerContent;
        }
        field(70; Error; Text[1000])
        {
            Caption = 'Errored Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        SystemId := CreateGuid();
    end;

    trigger OnDelete()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        DeleteConfirmQst: Label 'Are you sure that you want to delete this %1 since it has been already sent to Fiskaly and it can cause data discrepancy?', Comment = '%1 - DE Submission table caption';
    begin
        if not ConfirmManagement.GetResponse(StrSubstNo(DeleteConfirmQst, TableCaption()), false) then
            Error('');
    end;

    internal procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;
}