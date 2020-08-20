table 6151186 "MM Sponsorship Ticket Entry"
{
    // MM1.41/TSA /20191004 CASE 367471 Initial Version

    Caption = 'Sponsorship Ticket Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "MM Membership Setup";
        }
        field(2; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Registered,Finalized';
            OptionMembers = REGISTERED,FINALIZED;
        }
        field(5; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "MM Membership";
        }
        field(7; "Setup Line No."; Integer)
        {
            Caption = 'Setup Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Ticket Token"; Text[100])
        {
            Caption = 'Ticket Token';
            DataClassification = CustomerContent;
        }
        field(11; "Ticket No."; Code[20])
        {
            Caption = 'Ticket No.';
            DataClassification = CustomerContent;
        }
        field(12; "Event Type"; Option)
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,On New,On Renew,On Demand';
            OptionMembers = NA,ONNEW,ONRENEW,ONDEMAND;
        }
        field(20; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(30; "Notification Send Status"; Option)
        {
            Caption = 'Notification Send Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Pending,Delivered,Canceled,Failed,Not Delivered,Pick-Up';
            OptionMembers = PENDING,DELIVERED,CANCELED,FAILED,NOT_DELIVERED,"PICK-UP";
        }
        field(31; "Notification Sent At"; DateTime)
        {
            Caption = 'Notification Sent At';
            DataClassification = CustomerContent;
        }
        field(32; "Notification Sent By User"; Text[30])
        {
            Caption = 'Notification Sent By User';
            DataClassification = CustomerContent;
        }
        field(40; "Notification Address"; Text[80])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(45; "Picked Up At"; DateTime)
        {
            Caption = 'Picked Up At';
            DataClassification = CustomerContent;
        }
        field(100; "External Member No."; Code[20])
        {
            Caption = 'External Member No.';
            DataClassification = CustomerContent;
        }
        field(110; "E-Mail Address"; Text[80])
        {
            Caption = 'E-Mail Address';
            DataClassification = CustomerContent;
        }
        field(111; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
        }
        field(120; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(121; "Middle Name"; Text[50])
        {
            Caption = 'Middle Name';
            DataClassification = CustomerContent;
        }
        field(122; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(123; "Display Name"; Text[100])
        {
            Caption = 'Display Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(130; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(131; "Post Code Code"; Code[20])
        {
            Caption = 'ZIP Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(132; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(133; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(134; Country; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(140; Birthday; Date)
        {
            Caption = 'Birthday';
            DataClassification = CustomerContent;
        }
        field(150; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "MM Member Community";
        }
        field(151; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "MM Membership Setup";
        }
        field(153; "Membership Valid From"; Date)
        {
            Caption = 'Membership Valid From';
            DataClassification = CustomerContent;
        }
        field(154; "Membership Valid Until"; Date)
        {
            Caption = 'Membership Valid Until';
            DataClassification = CustomerContent;
        }
        field(160; "External Membership No."; Code[20])
        {
            Caption = 'External Membership No.';
            DataClassification = CustomerContent;
            TableRelation = "MM Membership"."External Membership No.";
        }
        field(200; "Failed With Message"; Text[250])
        {
            Caption = 'Failed With Message';
            DataClassification = CustomerContent;
        }
        field(405; "Ticket URL"; Text[200])
        {
            Caption = 'Ticket URL';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Membership Entry No.", "Event Type")
        {
        }
        key(Key3; "Membership Entry No.", Status)
        {
        }
    }

    fieldgroups
    {
    }
}

