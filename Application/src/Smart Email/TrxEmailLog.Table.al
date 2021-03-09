table 6059825 "NPR Trx Email Log"
{
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
            DataClassification = CustomerContent;
            OptionCaption = 'Campaign Monitor,Mailchimp';
            OptionMembers = "Campaign Monitor",Mailchimp;
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

}

