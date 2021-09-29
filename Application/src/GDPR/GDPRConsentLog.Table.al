table 6151123 "NPR GDPR Consent Log"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Consent Log';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR GDPR Consent Log";
    LookupPageID = "NPR GDPR Consent Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Entry Approval State"; Option)
        {
            Caption = 'Entry Approval State';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Pending,Accepted,Rejected,Delegated to Guardian';
            OptionMembers = NA,PENDING,ACCEPTED,REJECTED,DELEGATED;
        }
        field(20; "State Change"; DateTime)
        {
            Caption = 'State Change';
            DataClassification = CustomerContent;
        }
        field(25; "Valid From Date"; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
        }
        field(30; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            DataClassification = CustomerContent;
        }
        field(35; "Agreement Version"; Integer)
        {
            Caption = 'Agreement Version';
            DataClassification = CustomerContent;
        }
        field(40; "Data Subject Id"; Text[35])
        {
            Caption = 'Data Subject Id';
            DataClassification = CustomerContent;
        }
        field(90; "Last Changed By"; Text[50])
        {
            Caption = 'Last Changed By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(91; "Last Changed At"; DateTime)
        {
            Caption = 'Last Changed At';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Data Subject Id")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin

        "Last Changed By" := CopyStr(UserId, 1, MaxStrLen("Last Changed By"));
        "Last Changed At" := CurrentDateTime();
    end;

    trigger OnModify()
    begin

        "Last Changed By" := CopyStr(UserId, 1, MaxStrLen("Last Changed By"));
        "Last Changed At" := CurrentDateTime();
    end;

    trigger OnRename()
    begin
        Error('Rename not allowed.');
    end;
}

