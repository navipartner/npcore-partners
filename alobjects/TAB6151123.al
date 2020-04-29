table 6151123 "GDPR Consent Log"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Consent Log';
    DrillDownPageID = "GDPR Consent Log";
    LookupPageID = "GDPR Consent Log";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Entry Approval State";Option)
        {
            Caption = 'Entry Approval State';
            OptionCaption = ' ,Pending,Accepted,Rejected,Delegated to Guardian';
            OptionMembers = NA,PENDING,ACCEPTED,REJECTED,DELEGATED;
        }
        field(20;"State Change";DateTime)
        {
            Caption = 'State Change';
        }
        field(25;"Valid From Date";Date)
        {
            Caption = 'Valid From Date';
        }
        field(30;"Agreement No.";Code[20])
        {
            Caption = 'Agreement No.';
        }
        field(35;"Agreement Version";Integer)
        {
            Caption = 'Agreement Version';
        }
        field(40;"Data Subject Id";Text[35])
        {
            Caption = 'Data Subject Id';
        }
        field(90;"Last Changed By";Text[50])
        {
            Caption = 'Last Changed By';
            Editable = false;
        }
        field(91;"Last Changed At";DateTime)
        {
            Caption = 'Last Changed At';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Data Subject Id")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin

        "Last Changed By" := UserId;
        "Last Changed At" := CurrentDateTime ();
    end;

    trigger OnModify()
    begin

        "Last Changed By" := UserId;
        "Last Changed At" := CurrentDateTime ();
    end;

    trigger OnRename()
    begin
        Error ('Rename not allowed.');
    end;
}

