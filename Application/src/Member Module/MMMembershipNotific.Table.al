table 6060138 "NPR MM Membership Notific."
{

    Caption = 'Membership Notification';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(7; "Member Card Entry No."; Integer)
        {
            Caption = 'Member Card Entry No.';
            DataClassification = CustomerContent;
        }
        field(8; "Membership Entry No."; Integer)
        {
            Caption = 'Membership Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership";
        }
        field(9; "Member Entry No."; Integer)
        {
            Caption = 'Member Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Notification Code"; Code[10])
        {
            Caption = 'Notification Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Member Notific. Setup";
        }
        field(20; "Date To Notify"; Date)
        {
            Caption = 'Date To Notify';
            DataClassification = CustomerContent;
        }
        field(30; "Notification Status"; Option)
        {
            Caption = 'Notification Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Pending,Processed,Canceled';
            OptionMembers = PENDING,PROCESSED,CANCELED;
        }
        field(31; "Notification Processed At"; DateTime)
        {
            Caption = 'Notification Processed At';
            DataClassification = CustomerContent;
        }
        field(32; "Notification Processed By User"; Text[30])
        {
            Caption = 'Notification Processed By User';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(40; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(41; "Blocked At"; DateTime)
        {
            Caption = 'Blocked At';
            DataClassification = CustomerContent;
        }
        field(42; "Blocked By User"; Text[30])
        {
            Caption = 'Blocked By User';
            DataClassification = CustomerContent;
        }
        field(50; "Notification Trigger"; Option)
        {
            Caption = 'Notification Trigger';
            DataClassification = CustomerContent;
            OptionCaption = 'Welcome,Membership Renewal,Wallet Update,Wallet Create';
            OptionMembers = WELCOME,RENEWAL,WALLET_UPDATE,WALLET_CREATE;
        }
        field(51; "Template Filter Value"; Code[20])
        {
            Caption = 'Template Filter Value';
            DataClassification = CustomerContent;
        }
        field(80; "Target Member Role"; Option)
        {
            Caption = 'Target Member Role';
            DataClassification = CustomerContent;
            OptionCaption = 'FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS';
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
        field(90; "Notification Method Source"; Option)
        {
            Caption = 'Notification Method Source';
            DataClassification = CustomerContent;
            OptionCaption = 'Member,External';
            OptionMembers = MEMBER,EXTERNAL;
        }
        field(300; "External Membership No."; Code[20])
        {
            CalcFormula = Lookup("NPR MM Membership"."External Membership No." WHERE("Entry No." = FIELD("Membership Entry No.")));
            Caption = 'External Membership No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310; "External Member No."; Code[20])
        {
            CalcFormula = Lookup("NPR MM Member"."External Member No." WHERE("Entry No." = FIELD("Member Entry No.")));
            Caption = 'External Member No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(400; "Include NP Pass"; Boolean)
        {
            Caption = 'Include NP Pass';
            DataClassification = CustomerContent;
            Description = '';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Notification Status", "Date To Notify")
        {
        }
        key(Key3; "Membership Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

