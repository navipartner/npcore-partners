table 6060137 "MM Member Notification Setup"
{
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.29/TSA /20180506 CASE 314131 Added fields "Activate NP Pass" and "Processing Method"
    // MM1.32/TSA /20180710 CASE 318132 Added option Wallet_Create to the Type

    Caption = 'MM Member Notification Setup';
    DrillDownPageID = "MM Member Notification Setup";
    LookupPageID = "MM Member Notification Setup";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Welcome,Membership Renewal,Wallet Update,Wallet Create';
            OptionMembers = WELCOME,RENEWAL,WALLET_UPDATE,WALLET_CREATE;
        }
        field(30;"Days Before";Integer)
        {
            Caption = 'Days Before';
        }
        field(40;"Days Past";Integer)
        {
            Caption = 'Days Past';
        }
        field(50;"Template Filter Value";Code[20])
        {
            Caption = 'Template Filter Value';
        }
        field(60;"Community Code";Code[20])
        {
            Caption = 'Community Code';
            TableRelation = "MM Member Community";
        }
        field(61;"Membership Code";Code[20])
        {
            Caption = 'Membership Code';
            TableRelation = "MM Membership Setup";
        }
        field(70;"Next Notification Code";Code[10])
        {
            Caption = 'Next Notification Code';
            TableRelation = "MM Member Notification Setup";
        }
        field(75;"Cancel Overdue Notif. (Days)";Integer)
        {
            Caption = 'Cancel Overdue Notif. (Days)';
        }
        field(80;"Target Member Role";Option)
        {
            Caption = 'Target Member Role';
            OptionCaption = 'First Admin,All Admins,All Member';
            OptionMembers = FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS;
        }
        field(85;"Processing Method";Option)
        {
            Caption = 'Processing Method';
            Description = '//-MM1.29 [314131]';
            OptionCaption = 'Batch,Manual,Inline';
            OptionMembers = BATCH,MANUAL,INLINE;
        }
        field(100;"NP Pass Server Base URL";Text[200])
        {
            Caption = 'NP Pass Server Base URL';
            Description = '//-MM1.29 [314131]';
            InitValue = 'https://passes.npecommerce.dk/api/v1';
        }
        field(105;"Pass Notification Method";Option)
        {
            Caption = 'Pass Notification Method';
            Description = '//-MM1.29 [314131]';
            OptionCaption = 'Asynchronous,Synchronous';
            OptionMembers = ASYNCHRONOUS,SYNCHRONOUS;
        }
        field(110;"Passes API";Text[50])
        {
            Caption = 'Passes API';
            Description = '//-MM1.29 [314131]';
            InitValue = '/passes/%1/%2';
        }
        field(120;"PUT Passes Template";BLOB)
        {
            Caption = 'PUT Passes Template';
            Description = '//-MM1.29 [314131]';
        }
        field(130;"Pass Token";Text[150])
        {
            Caption = 'Pass Token';
            Description = '//-MM1.29 [314131]';
        }
        field(135;"Pass Type Code";Text[30])
        {
            Caption = 'Pass Type Code';
            Description = '//-MM1.29 [314131]';
        }
        field(140;"Include NP Pass";Boolean)
        {
            Caption = 'Include NP Pass';
            Description = '//-MM1.29 [314131]';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;Type,"Community Code","Membership Code","Days Before")
        {
        }
        key(Key3;Type,"Community Code","Membership Code","Days Past")
        {
        }
    }

    fieldgroups
    {
    }
}

