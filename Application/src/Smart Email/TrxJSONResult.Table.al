table 6059829 "NPR Trx JSON Result"
{
    Access = Internal;
    Caption = 'Transactional JSON Result';
    DrillDownPageID = "NPR Trx JSON Result";
    LookupPageID = "NPR Trx JSON Result";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
            DataClassification = CustomerContent;
        }
        field(3; Provider; Option)
        {
            Caption = 'Provider';
            OptionCaption = 'Campaign Monitor,Mailchimp';
            OptionMembers = "Campaign Monitor",Mailchimp;
            DataClassification = CustomerContent;
        }
        field(10; ID; Text[50])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(20; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(30; Status; Text[30])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(40; Created; Date)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Name, Status, ID)
        {
        }
    }
}

