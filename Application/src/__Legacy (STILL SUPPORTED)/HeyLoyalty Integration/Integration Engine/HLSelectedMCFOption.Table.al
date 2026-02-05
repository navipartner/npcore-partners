table 6059851 "NPR HL Selected MCF Option"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    Caption = 'HL Selected MC Field Option';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(2; "BC Record ID"; RecordId)
        {
            Caption = 'BC Record ID';
            DataClassification = CustomerContent;
        }
        field(3; "Field Code"; Code[20])
        {
            Caption = 'Field Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR HL MultiChoice Field".Code;
        }
        field(10; "Field Option ID"; Integer)
        {
            Caption = 'Field Option ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR HL MultiChoice Fld Option"."Option ID" where("Field Code" = field("Field Code"));
        }
    }

    keys
    {
        key(PK; "Table No.", "BC Record ID", "Field Code", "Field Option ID")
        {
            Clustered = true;
        }
    }
}