table 6060144 "NPR MM Membership Lim. Setup"
{
    Access = Internal;

    Caption = 'Membership Limitation Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Membership  Code"; Code[20])
        {
            Caption = 'Membership  Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Membership Setup";
        }
        field(15; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }
        field(20; "Constraint Type"; Option)
        {
            Caption = 'Constraint Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Relative Time,Fixed Time,Dateformula';
            OptionMembers = RELATIVE_TIME,FIXED_TIME,DATEFORMULA;
        }
        field(25; "Constraint Source"; Option)
        {
            Caption = 'Constraint Source';
            DataClassification = CustomerContent;
            OptionCaption = 'Membership,Member,Membercard,Temporary Card,GDPR Pending,GDPR Rejected';
            OptionMembers = MEMBERSHIP,MEMBER,MEMBERCARD,TEMP_MEMBERCARD,GDPR_PENDING,GDPR_REJECTED;
        }
        field(30; "Constraint Seconds"; Integer)
        {
            Caption = 'Constraint Seconds';
            DataClassification = CustomerContent;
        }
        field(34; "Constraint From Time"; Time)
        {
            Caption = 'Constraint From Time';
            DataClassification = CustomerContent;
        }
        field(35; "Constraint Until Time"; Time)
        {
            Caption = 'Constraint Until Time';
            DataClassification = CustomerContent;
        }
        field(38; "Constraint Dateformula"; DateFormula)
        {
            Caption = 'Constraint Dateformula';
            DataClassification = CustomerContent;
        }
        field(40; "Event Type"; Option)
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Success Count,Fail Count';
            OptionMembers = SUCCESS_COUNT,FAIL_COUNT;
        }
        field(45; "Event Limit"; Integer)
        {
            Caption = 'Event Limit';
            DataClassification = CustomerContent;
        }
        field(50; "POS Response Action"; Option)
        {
            Caption = 'POS Response Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Error,Confirm,Message,Allow';
            OptionMembers = USER_ERROR,USER_CONFIRM,USER_MESSAGE,ALLOW;
        }
        field(55; "POS Response Message"; Text[250])
        {
            Caption = 'POS Response Message';
            DataClassification = CustomerContent;
        }
        field(60; "WS Response Action"; Option)
        {
            Caption = 'WS Response Action';
            DataClassification = CustomerContent;
            OptionCaption = 'Error,Allow';
            OptionMembers = USER_ERROR,ALLOW;
        }
        field(65; "WS Deny Message"; Text[250])
        {
            Caption = 'WS Deny Message';
            DataClassification = CustomerContent;
        }
        field(70; "Response Code"; Integer)
        {
            Caption = 'Response Code';
            DataClassification = CustomerContent;
            InitValue = -999;
        }
        field(75; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Constraint Source", "Membership  Code", "Admission Code", "POS Response Action")
        {
        }
        key(Key3; "Constraint Source", "Membership  Code", "Admission Code", "WS Response Action")
        {
        }
    }

    fieldgroups
    {
    }
}

