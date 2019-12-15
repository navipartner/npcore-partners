table 6184496 "EFT Transact. Req. Comment"
{
    // NPR5.20/BR  /20160316  CASE 231481 Object Created
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT

    Caption = 'EFT Transact. Req. Comment';

    fields
    {
        field(10;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
            TableRelation = "EFT Transaction Request";
        }
        field(20;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(30;Comment;Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1;"Entry No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

