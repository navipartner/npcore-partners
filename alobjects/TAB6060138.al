table 6060138 "MM Membership Notification"
{
    // MM1.14/TSA/20160603  CASE 240871 Transport MM1.13 - 1 June 2016
    // MM1.22/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.26/TSA /20180202 CASE 300681 Added flowfield for external membership no and external member no
    // MM1.29/TSA /20180504 CASE 314131 Include NP Pass / Wallet data in welcome mail
    // MM1.32/TSA /20180710 CASE 318132 Added option Wallet_Create to the Notification Trigger
    // MM1.32/TSA /20180711 CASE 318132 Added field Member Card Entry No.
    // #334163/JDH /20181109 CASE 334163 Added caption to field Member Card Entry No.
    // MM1.36/NPKNAV/20190125  CASE 328141-02 Transport MM1.36 - 25 January 2019

    Caption = 'Membership Notification';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(7;"Member Card Entry No.";Integer)
        {
            Caption = 'Member Card Entry No.';
        }
        field(8;"Membership Entry No.";Integer)
        {
            Caption = 'Membership Entry No.';
            TableRelation = "MM Membership";
        }
        field(9;"Member Entry No.";Integer)
        {
            Caption = 'Member Entry No.';
        }
        field(10;"Notification Code";Code[10])
        {
            Caption = 'Notification Code';
            TableRelation = "MM Member Notification Setup";
        }
        field(20;"Date To Notify";Date)
        {
            Caption = 'Date To Notify';
        }
        field(30;"Notification Status";Option)
        {
            Caption = 'Notification Status';
            OptionCaption = 'Pending,Processed,Canceled';
            OptionMembers = PENDING,PROCESSED,CANCELED;
        }
        field(31;"Notification Processed At";DateTime)
        {
            Caption = 'Notification Processed At';
        }
        field(32;"Notification Processed By User";Text[30])
        {
            Caption = 'Notification Processed By User';
        }
        field(40;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(41;"Blocked At";DateTime)
        {
            Caption = 'Blocked At';
        }
        field(42;"Blocked By User";Text[30])
        {
            Caption = 'Blocked By User';
        }
        field(50;"Notification Trigger";Option)
        {
            Caption = 'Notification Trigger';
            OptionCaption = 'Welcome,Membership Renewal,Wallet Update,Wallet Create';
            OptionMembers = WELCOME,RENEWAL,WALLET_UPDATE,WALLET_CREATE;
        }
        field(51;"Template Filter Value";Code[20])
        {
            Caption = 'Template Filter Value';
        }
        field(80;"Target Member Role";Option)
        {
            Caption = 'Target Member Role';
            OptionCaption = 'FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS';
            OptionMembers = FIRST_ADMIN,ALL_ADMINS,ALL_MEMBERS;
        }
        field(85;"Processing Method";Option)
        {
            Caption = 'Processing Method';
            Description = '//-MM1.29 [314131]';
            OptionCaption = 'Batch,Manual,Inline';
            OptionMembers = BATCH,MANUAL,INLINE;
        }
        field(90;"Notification Method Source";Option)
        {
            Caption = 'Notification Method Source';
            OptionCaption = 'Member,External';
            OptionMembers = MEMBER,EXTERNAL;
        }
        field(300;"External Membership No.";Code[20])
        {
            CalcFormula = Lookup("MM Membership"."External Membership No." WHERE ("Entry No."=FIELD("Membership Entry No.")));
            Caption = 'External Membership No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310;"External Member No.";Code[20])
        {
            CalcFormula = Lookup("MM Member"."External Member No." WHERE ("Entry No."=FIELD("Member Entry No.")));
            Caption = 'External Member No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(400;"Include NP Pass";Boolean)
        {
            Caption = 'Include NP Pass';
            Description = '//-MM1.29 [314131]';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Notification Status","Date To Notify")
        {
        }
        key(Key3;"Membership Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

