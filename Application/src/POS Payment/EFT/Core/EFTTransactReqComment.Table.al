table 6184496 "NPR EFT Transact. Req. Comment"
{
    Access = Internal;

    Caption = 'EFT Transact. Req. Comment';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Transaction Request";
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(30; Comment; Text[1024])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

