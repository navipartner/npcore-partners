table 6184488 "NPR Pepper EFT Trx Type"
{
    // NPR5.20/BR  /20160316  CASE 231481 Object Created
    // NPR5.28/BR  /20161124  CASE 255137 Added field "Suppress Receipt Print"
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT, added Field Integration Type
    // NPR5.46/MMV /20180714 CASE 290734 Renamed

    Caption = 'Pepper EFT Transaction Type';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Pepper EFT Trans. Types";
    LookupPageID = "NPR Pepper EFT Trans. Types";

    fields
    {
        field(5; "Integration Type"; Code[20])
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

