table 6059829 "NPR Trx JSON Result"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider

    Caption = 'Transactional JSON Result';
    DrillDownPageID = "NPR Trx JSON Result";
    LookupPageID = "NPR Trx JSON Result";

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
        }
        field(3; Provider; Option)
        {
            Caption = 'Provider';
            OptionCaption = 'Campaign Monitor,Mailchimp';
            OptionMembers = "Campaign Monitor",Mailchimp;
        }
        field(10; ID; Text[50])
        {
            Caption = 'ID';
        }
        field(20; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(30; Status; Text[30])
        {
            Caption = 'Status';
        }
        field(40; Created; Date)
        {
            Caption = 'Created';
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

