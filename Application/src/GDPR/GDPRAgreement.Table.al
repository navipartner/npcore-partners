table 6151121 "NPR GDPR Agreement"
{
    Access = Internal;

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
        field(110; KeepAnonymizedFor; Option)
        {
            Caption = 'Keep Anonymized Membership For';
            OptionMembers = FOREVER,ONE_DAY,ONE_WEEK,ONE_MONTH,THREE_MONTHS,SIX_MONTHS,TWELVE_MONTHS;
            DataClassification = CustomerContent;
            OptionCaption = 'Forever,1 Day,1 Week,1 Month,3 Months,6 Months,12 Months';
            InitValue = FOREVER;
        }
        field(1000; "Latest Version"; Integer)
        {
            CalcFormula = Max("NPR GDPR Agreement Version".Version WHERE("No." = FIELD("No.")));
            Caption = 'Latest Version';
            FieldClass = FlowField;
        }
        field(1001; "Current Version"; Integer)
        {
            CalcFormula = Max("NPR GDPR Agreement Version".Version WHERE("No." = FIELD("No."),
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
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
    begin

        if ("No." = '') then begin
            GDPRSetup.Get();
            GDPRSetup.TestField("Agreement Nos.");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            "No." := NoSeriesManagement.GetNextNo(GDPRSetup."Agreement Nos.", Today, false);
#ELSE
            "No." := NoSeriesManagement.GetNextNo(GDPRSetup."Agreement Nos.", Today, true);
#ENDIF
        end;

        if (Format("Anonymize After") = '') then
            Evaluate("Anonymize After", '<+0D>');

        GDPRAgreementVersion.Init();
        GDPRAgreementVersion."No." := "No.";
        GDPRAgreementVersion.Version := 1;
        GDPRAgreementVersion.Description := Description;
        GDPRAgreementVersion."Activation Date" := Today();
        GDPRAgreementVersion."Anonymize After" := "Anonymize After";
        GDPRAgreementVersion.Insert();
    end;

    trigger OnModify()
    begin

        TestField("Anonymize After");
    end;
}

