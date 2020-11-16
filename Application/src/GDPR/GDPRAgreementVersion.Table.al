table 6151122 "NPR GDPR Agreement Version"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Agreement Version';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Version; Integer)
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; URL; Text[200])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;
        }
        field(30; "Activation Date"; Date)
        {
            Caption = 'Activation Date';
            DataClassification = CustomerContent;
        }
        field(100; "Anonymize After"; DateFormula)
        {
            Caption = 'Anonymize After';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.", Version)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        GDPRSetup: Record "NPR GDPR Setup";
        GDPRAgreement: Record "NPR GDPR Agreement";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        TestField("Activation Date");
        TestField("Anonymize After");

        GDPRAgreement.Get(Rec."No.");
        if (Rec.Description = '') then
            Rec.Description := GDPRAgreement.Description;
    end;

    trigger OnModify()
    begin
        TestField("Activation Date");
        TestField("Anonymize After");
    end;
}

