table 6150658 "NPR SS Profile"
{
    Access = Internal;
    Caption = 'POS Self Service Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR SS Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Kiosk Mode Unlock PIN"; Text[30])
        {
            Caption = 'Kiosk Mode Unlock PIN';
            DataClassification = CustomerContent;
        }
        field(30; "QR Card Payment Method"; Code[10])
        {
            Caption = 'QR Card Payment Method';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
        field(40; "Selfservice Card Payment Meth."; Code[10])
        {
            Caption = 'Selfservice Card Payment Method';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
