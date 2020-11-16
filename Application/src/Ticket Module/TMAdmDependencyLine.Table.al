table 6014436 "NPR TM Adm. Dependency Line"
{
    DataClassification = CustomerContent;
    Caption = 'Admission Dependency Line';

    fields
    {
        field(1; "Dependency Code"; Code[20])
        {
            Caption = 'Dependency Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Adm. Dependency";
        }

        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(15; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
        }

        field(20; "Rule Type"; enum "NPR TM Adm. Dep. Rules")
        {
            Caption = 'Rule Type';
            DataClassification = CustomerContent;
        }

        field(30; Timeframe; DateFormula)
        {
            Caption = 'Timeframe';
            DataClassification = CustomerContent;
        }

        field(40; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Admission";
        }

        field(50; "Rule Sequence"; Integer)
        {
            Caption = 'Rule Sequence';
            DataClassification = CustomerContent;
        }

        field(60; "Response Message"; Text[250])
        {
            Caption = 'Response Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Dependency Code", "Line No.")
        {
            Clustered = true;
        }
        key(rulesequence; "Dependency Code", "Rule Sequence")
        {

        }
    }

    trigger OnInsert()
    var
        AdmissionDependencyLine: Record "NPR TM Adm. Dependency Line";
    begin

        if ("Line No." = 0) then begin
            "Line No." := 10000;
            AdmissionDependencyLine.SetCurrentKey("Dependency Code", "Line No.");
            AdmissionDependencyLine.SetFilter("Dependency Code", '=%1', Rec."Dependency Code");
            if (AdmissionDependencyLine.FindLast()) then
                "Line No." := AdmissionDependencyLine."Line No." + 10000;
        end;

    end;

    trigger OnModify()
    begin

    end;

}