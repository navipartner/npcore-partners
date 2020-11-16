table 6059825 "NPR Trx Email Log"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider + "Status Message"

    Caption = 'Transactional Email Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; Provider; Option)
        {
            Caption = 'Provider';
            OptionCaption = 'Campaign Monitor,Mailchimp';
            OptionMembers = "Campaign Monitor",Mailchimp;
            DataClassification = CustomerContent;
        }
        field(10; "Message ID"; Guid)
        {
            Caption = 'Message ID';
            DataClassification = CustomerContent;
        }
        field(20; Status; Text[30])
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(25; "Status Message"; Text[250])
        {
            Caption = 'Status Message';
            DataClassification = CustomerContent;
        }
        field(30; Recipient; Text[80])
        {
            Caption = 'Recipient';
            DataClassification = CustomerContent;
        }
        field(35; Subject; Text[250])
        {
            Caption = 'Subject';
            DataClassification = CustomerContent;
        }
        field(40; "Smart Email ID"; Guid)
        {
            Caption = 'Smart Email ID';
            DataClassification = CustomerContent;
        }
        field(50; "Sent At"; DateTime)
        {
            Caption = 'Sent At';
            DataClassification = CustomerContent;
        }
        field(60; "Total Opens"; Integer)
        {
            Caption = 'Total Opens';
            DataClassification = CustomerContent;
        }
        field(65; "Total Clicks"; Integer)
        {
            Caption = 'Total Clicks';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

