table 6151103 "NpRi Reimbursement Entry"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.53/TSA /20191024 CASE 374363 Added "Account Type"::Membership

    Caption = 'Reimbursement Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NpRi Reimbursement Entries";
    LookupPageID = "NpRi Reimbursement Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Party Type"; Code[20])
        {
            Caption = 'Party Type';
            DataClassification = CustomerContent;
            TableRelation = "NpRi Party Type";
        }
        field(10; "Party No."; Code[20])
        {
            Caption = 'Party No.';
            DataClassification = CustomerContent;
            TableRelation = "NpRi Party"."No." WHERE("Party Type" = FIELD("Party Type"));
        }
        field(15; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NpRi Reimbursement Template";
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(25; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Data Collection,Reimbursement,Manual Application';
            OptionMembers = "Data Collection",Reimbursement,"Manual Application";
        }
        field(100; "Source Company Name"; Text[30])
        {
            Caption = 'Source Company Name';
            DataClassification = CustomerContent;
        }
        field(115; "Source Record ID"; RecordID)
        {
            Caption = 'Source Record ID';
            DataClassification = CustomerContent;
        }
        field(120; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
            DataClassification = CustomerContent;
        }
        field(125; "Source Table Name"; Text[249])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Source Table No.")));
            Caption = 'Source Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "Source Record Position"; Text[250])
        {
            Caption = 'Source Record Position';
            DataClassification = CustomerContent;
        }
        field(135; "Source Entry No."; Integer)
        {
            Caption = 'Source Entry No.';
            DataClassification = CustomerContent;
        }
        field(140; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(205; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(210; Positive; Boolean)
        {
            Caption = 'Positive';
            DataClassification = CustomerContent;
        }
        field(215; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(220; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            DataClassification = CustomerContent;
        }
        field(225; "Closed by Entry No."; BigInteger)
        {
            BlankZero = true;
            Caption = 'Closed by Entry No.';
            DataClassification = CustomerContent;
        }
        field(300; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(305; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(310; "Account Type"; Option)
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset,IC Partner,Membership';
            OptionMembers = "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner",Membership;
        }
        field(315; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Account Type" = CONST("Fixed Asset")) "Fixed Asset"
            ELSE
            IF ("Account Type" = CONST("IC Partner")) "IC Partner"
            ELSE
            IF ("Account Type" = CONST(Membership)) "MM Membership";
        }
        field(320; "Reimbursement Amount"; Decimal)
        {
            Caption = 'Reimbursement Amount';
            DataClassification = CustomerContent;
        }
        field(400; "Last modified by"; Code[50])
        {
            Caption = 'Last modified by';
            DataClassification = CustomerContent;
        }
        field(405; "Last modified at"; DateTime)
        {
            Caption = 'Last modified at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Party Type", "Party No.", "Template Code", "Posting Date", "Entry Type", "Source Company Name", "Source Record ID")
        {
        }
        key(Key3; "Party Type", "Party No.", "Template Code", "Posting Date", "Entry Type", "Source Company Name", "Source Table No.", "Source Entry No.", "Source Record Position")
        {
        }
        key(Key4; "Party Type", "Party No.", "Template Code", "Entry Type", Open, "Posting Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Last modified by" := UserId;
        "Last modified at" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last modified by" := UserId;
        "Last modified at" := CurrentDateTime;
    end;
}

