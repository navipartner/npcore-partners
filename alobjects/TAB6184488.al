table 6184488 "Pepper EFT Transaction Type"
{
    // NPR5.20/BR  /20160316  CASE 231481 Object Created
    // NPR5.28/BR  /20161124  CASE 255137 Added field "Suppress Receipt Print"
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT, added Field Integration Type
    // NPR5.46/MMV /20180714 CASE 290734 Renamed

    Caption = 'Pepper EFT Transaction Type';
    DrillDownPageID = "Pepper EFT Transaction Types";
    LookupPageID = "Pepper EFT Transaction Types";

    fields
    {
        field(5;"Integration Type";Code[10])
        {
            Caption = 'Integration Type';
        }
        field(10;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(30;"Allow Test Modes";Boolean)
        {
            Caption = 'Allow Test Modes';
        }
        field(40;"Processing Type";Option)
        {
            Caption = 'Processing Type';
            OptionCaption = ',Payment,Refund,Open,Close,Auxiliary,Other';
            OptionMembers = ,Payment,Refund,Open,Close,Auxiliary,Other;
        }
        field(50;"POS Timeout (Seconds)";Integer)
        {
            Caption = 'POS Timeout (Seconds)';
        }
        field(60;"Suppress Receipt Print";Boolean)
        {
            Caption = 'Suppress Receipt Print';
            Description = 'NPR5.31';
        }
    }

    keys
    {
        key(Key1;"Integration Type","Code")
        {
        }
    }

    fieldgroups
    {
    }
}

