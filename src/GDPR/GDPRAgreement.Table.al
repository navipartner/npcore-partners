table 6151121 "NPR GDPR Agreement"
{
    // MM1.29/TSA /20180509 CASE 313795 Initial Version

    Caption = 'GDPR Agreement';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(100; "Anonymize After"; DateFormula)
        {
            Caption = 'Anonymize After';
            DataClassification = CustomerContent;
        }
        field(1000; "Latest Version"; Integer)
        {
            CalcFormula = Max ("NPR GDPR Agreement Version".Version WHERE("No." = FIELD("No.")));
            Caption = 'Latest Version';
            FieldClass = FlowField;
        }
        field(1001; "Current Version"; Integer)
        {
            CalcFormula = Max ("NPR GDPR Agreement Version".Version WHERE("No." = FIELD("No."),
                                                                      "Activation Date" = FIELD(UPPERLIMIT("Date Filter"))));
            Caption = 'Current Version';
            FieldClass = FlowField;
        }
        field(1010; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        GDPRSetup: Record "NPR GDPR Setup";
        GDPRAgreementVersion: Record "NPR GDPR Agreement Version";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        if ("No." = '') then begin
            GDPRSetup.Get();
            GDPRSetup.TestField("Agreement Nos.");
            "No." := NoSeriesManagement.GetNextNo(GDPRSetup."Agreement Nos.", Today, true);
        end;

        if (Format("Anonymize After") = '') then
            Evaluate("Anonymize After", '<+0D>');

        GDPRAgreementVersion.Init;
        GDPRAgreementVersion."No." := "No.";
        GDPRAgreementVersion.Version := 1;
        GDPRAgreementVersion.Description := Description;
        GDPRAgreementVersion."Activation Date" := Today;
        GDPRAgreementVersion."Anonymize After" := "Anonymize After";
        GDPRAgreementVersion.Insert();
    end;

    trigger OnModify()
    begin

        TestField("Anonymize After");
    end;
}

