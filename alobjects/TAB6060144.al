table 6060144 "MM Membership Limitation Setup"
{
    // MM1.21/NPKNAV/20170728  CASE 284653 Transport MM1.21 - 28 July 2017
    // MM1.22/TSA /20170911 CASE 284560 New option to Constraint Type::TEMP_MEMBERCARD
    // MM1.29/TSA /20180511 CASE 313795 GDPR constraint source

    Caption = 'Membership Limitation Setup';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Membership  Code";Code[20])
        {
            Caption = 'Membership  Code';
            TableRelation = "MM Membership Setup";
        }
        field(15;"Admission Code";Code[20])
        {
            Caption = 'Admission Code';
            TableRelation = "TM Admission";
        }
        field(20;"Constraint Type";Option)
        {
            Caption = 'Constraint Type';
            OptionCaption = 'Relative Time,Fixed Time,Dateformula';
            OptionMembers = RELATIVE_TIME,FIXED_TIME,DATEFORMULA;
        }
        field(25;"Constraint Source";Option)
        {
            Caption = 'Constraint Source';
            OptionCaption = 'Membership,Member,Membercard,Temporary Card,GDPR Pending,GDPR Rejected';
            OptionMembers = MEMBERSHIP,MEMBER,MEMBERCARD,TEMP_MEMBERCARD,GDPR_PENDING,GDPR_REJECTED;
        }
        field(30;"Constraint Seconds";Integer)
        {
            Caption = 'Constraint Seconds';
        }
        field(34;"Constraint From Time";Time)
        {
            Caption = 'Constraint From Time';
        }
        field(35;"Constraint Until Time";Time)
        {
            Caption = 'Constraint Until Time';
        }
        field(38;"Constraint Dateformula";DateFormula)
        {
            Caption = 'Constraint Dateformula';
        }
        field(40;"Event Type";Option)
        {
            Caption = 'Event Type';
            OptionCaption = 'Success Count,Fail Count';
            OptionMembers = SUCCESS_COUNT,FAIL_COUNT;
        }
        field(45;"Event Limit";Integer)
        {
            Caption = 'Event Limit';
        }
        field(50;"POS Response Action";Option)
        {
            Caption = 'POS Response Action';
            OptionCaption = 'Error,Confirm,Message,Allow';
            OptionMembers = USER_ERROR,USER_CONFIRM,USER_MESSAGE,ALLOW;
        }
        field(55;"POS Response Message";Text[250])
        {
            Caption = 'POS Response Message';
        }
        field(60;"WS Response Action";Option)
        {
            Caption = 'WS Response Action';
            OptionCaption = 'Error,Allow';
            OptionMembers = USER_ERROR,ALLOW;
        }
        field(65;"WS Deny Message";Text[250])
        {
            Caption = 'WS Deny Message';
        }
        field(70;"Response Code";Integer)
        {
            Caption = 'Response Code';
            InitValue = -999;
        }
        field(75;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Constraint Source","Membership  Code","Admission Code","POS Response Action")
        {
        }
        key(Key3;"Constraint Source","Membership  Code","Admission Code","WS Response Action")
        {
        }
    }

    fieldgroups
    {
    }
}

