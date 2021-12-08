table 6060137 "NPR MM Member Notific. Setup"
{

    Caption = 'MM Member Notification Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MM Member Notific. Setup";
    LookupPageID = "NPR MM Member Notific. Setup";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Welcome,Membership Renewal,Wallet Update,Wallet Create, Coupon';
            OptionMembers = WELCOME,RENEWAL,WALLET_UPDATE,WALLET_CREATE,COUPON;
        }
        field(30; "Days Before"; Integer)
        {
            Caption = 'Days Before';
            DataClassification = CustomerContent;
        }
        field(40; "Days Past"; Integer)
        {
            Caption = 'Days Past';
            DataClassification = CustomerContent;
        }
        field(50; "Template Filter Value"; Code[20])
        {
            Caption = 'Template Filter Value';
            DataClassification = CustomerContent;
        }
        field(60; "Community Code"; Code[20])
        {
            Caption = 'Community Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Community";
        }
        field(61; "Membership Code"; Code[20])
        {
            Caption = 'Membership Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(70; "Next Notification Code"; Code[10])
        {
            Caption = 'Next Notification Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Notific. Setup";
        }
        field(75; "Cancel Overdue Notif. (Days)"; Integer)
        {
            Caption = 'Cancel Overdue Notif. (Days)';
            DataClassification = CustomerContent;
        }
        field(80; "Target Member Role"; Option)
        {
            Caption = 'Target Member Role';
            DataClassification = CustomerContent;
            OptionCaption = 'First Admin,All Admins,All Member';
            OptionMembers = FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS;
        }
        field(85; "Processing Method"; Option)
        {
            Caption = 'Processing Method';
            DataClassification = CustomerContent;
            Description = '';
            OptionCaption = 'Batch,Manual,Inline';
            OptionMembers = BATCH,MANUAL,INLINE;
        }
        field(100; "NP Pass Server Base URL"; Text[200])
        {
            Caption = 'NP Pass Server Base URL';
            DataClassification = CustomerContent;
            Description = '';
            InitValue = 'https://passes.npecommerce.dk/api/v1';
        }
        field(105; "Pass Notification Method"; Option)
        {
            Caption = 'Pass Notification Method';
            DataClassification = CustomerContent;
            Description = '';
            OptionCaption = 'Asynchronous,Synchronous';
            OptionMembers = ASYNCHRONOUS,SYNCHRONOUS;
        }
        field(110; "Passes API"; Text[50])
        {
            Caption = 'Passes API';
            DataClassification = CustomerContent;
            Description = '';
            InitValue = '/passes/%1/%2';
        }
        field(120; "PUT Passes Template"; BLOB)
        {
            Caption = 'PUT Passes Template';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(130; "Pass Token"; Text[150])
        {
            Caption = 'Pass Token';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(135; "Pass Type Code"; Text[30])
        {
            Caption = 'Pass Type Code';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(140; "Include NP Pass"; Boolean)
        {
            Caption = 'Include NP Pass';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(150; "Generate Magento PW URL"; Boolean)
        {
            Caption = 'Generate Magento PW URL';
            DataClassification = CustomerContent;
            Description = '';
        }
        field(155; "Fallback Magento PW URL"; Text[150])
        {
            Caption = 'Fallback Magento PW URL';
            DataClassification = CustomerContent;
            Description = '';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; Type, "Community Code", "Membership Code", "Days Before")
        {
        }
        key(Key3; Type, "Community Code", "Membership Code", "Days Past")
        {
        }
    }

    fieldgroups
    {
    }
}

