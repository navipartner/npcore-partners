table 6150745 "NPR DK POS Audit Log Aux. Info"
{
    Access = Internal;
    Caption = 'DK POS Audit Log Aux. Info';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR DK POS Audit Log Aux. Info";
    LookupPageId = "NPR DK POS Audit Log Aux. Info";

    fields
    {
        field(1; "Audit Entry Type"; Enum "NPR DK Audit Entry Type")
        {
            Caption = 'Audit Entry Type';
            DataClassification = CustomerContent;
        }
        field(2; "Audit Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Audit Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry No.";
        }
        field(4; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry Date";
        }
        field(5; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store".Code;
        }
        field(6; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(7; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Audit Entry Type", "Audit Entry No.")
        {
        }
    }

    procedure GetAuditFromPOSEntry(POSEntryNo: Integer): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Audit Entry Type", Rec."Audit Entry Type"::"POS Entry");
        Rec.SetRange("POS Entry No.", POSEntryNo);
        exit(Rec.FindFirst());
    end;
}