table 6150858 "NPR TM POS Ticket Profile"
{
    Access = Internal;
    Caption = 'POS Ticket Profile';
    DataClassification = CustomerContent;
    LookupPageId = "NPR TM POS Ticket Profiles";
    DrillDownPageId = "NPR TM POS Ticket Profiles";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; "Print Ticket On Sale"; Boolean)
        {
            Caption = 'Print Ticket On Sale';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}