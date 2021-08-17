table 6184488 "NPR Pepper EFT Trx Type"
{
    Caption = 'Pepper EFT Transaction Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Pepper EFT Trans. Types";
    LookupPageID = "NPR Pepper EFT Trans. Types";

    fields
    {
        field(5; "Integration Type"; Code[10])
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Allow Test Modes"; Boolean)
        {
            Caption = 'Allow Test Modes';
            DataClassification = CustomerContent;
        }
        field(40; "Processing Type"; Option)
        {
            Caption = 'Processing Type';
            DataClassification = CustomerContent;
            OptionCaption = ',Payment,Refund,Open,Close,Auxiliary,Other';
            OptionMembers = ,Payment,Refund,Open,Close,Auxiliary,Other;
        }
        field(50; "POS Timeout (Seconds)"; Integer)
        {
            Caption = 'POS Timeout (Seconds)';
            DataClassification = CustomerContent;
        }
        field(60; "Suppress Receipt Print"; Boolean)
        {
            Caption = 'Suppress Receipt Print';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';
        }
    }

    keys
    {
        key(Key1; "Integration Type", "Code")
        {
        }
    }

    fieldgroups
    {
    }
}
