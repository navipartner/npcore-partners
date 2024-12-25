table 6150992 "NPR SI Salesbook Receipt"
{
    Access = Internal;
    Caption = 'SI Salesbook Receipt';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Set Number"; Text[2])
        {
            Caption = 'Set Number';
            DataClassification = CustomerContent;
        }
        field(3; "Serial Number"; Text[12])
        {
            Caption = 'Serial Number';
            DataClassification = CustomerContent;
        }
        field(4; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(5; "Receipt Issue Date"; Date)
        {
            Caption = 'Receipt Issue Date';
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

    internal procedure GetLastEntryNo(): Integer
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;
}