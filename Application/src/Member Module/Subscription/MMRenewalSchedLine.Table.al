table 6151232 "NPR MM Renewal Sched Line"
{
    DataClassification = CustomerContent;
    Caption = 'Renewal Sched Line';
    Access = Internal;

    fields
    {
        field(1; "Schedule Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }

        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
            AutoIncrement = true;
        }

        field(3; "Date Formula"; DateFormula)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Formula';
            trigger OnValidate()
            begin
                if Format(Rec."Date Formula") = '' then
                    Rec.FieldError("Date Formula");
                Rec."Date Formula Duration (Days)" := CalcDateFormulaDurationInDays();
                CheckUniqueness();
            end;
        }
        field(4; "Date Formula Duration (Days)"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Formula Duration (Days)';
        }

    }

    keys
    {
        key(Key1; "Schedule Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Schedule Code", "Date Formula Duration (Days)")
        {
        }
    }

    trigger OnInsert()
    begin
        CheckUniqueness();
    end;

    trigger OnModify()
    begin
        CheckUniqueness();
    end;

    local procedure CheckUniqueness()
    var
        RenewalSchedLine: Record "NPR MM Renewal Sched Line";
    begin
        RenewalSchedLine.Reset();
        RenewalSchedLine.SetRange("Schedule Code", Rec."Schedule Code");
        RenewalSchedLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
        RenewalSchedLine.SetRange("Date Formula", Rec."Date Formula");
        if RenewalSchedLine.IsEmpty then begin
            RenewalSchedLine.SetRange("Date Formula");
            RenewalSchedLine.SetRange("Date Formula Duration (Days)", Rec."Date Formula Duration (Days)");
            if RenewalSchedLine.IsEmpty then
                exit;
        end;

        Rec.FieldError("Date Formula");
    end;

    local procedure CalcDateFormulaDurationInDays(): Integer;
    var
        DateFormulaDate: Date;
        DateFormulaDurationInDays: Integer;
    begin
        if Format(Rec."Date Formula") = '' then
            exit;

        DateFormulaDate := CalcDate(Rec."Date Formula", Today);
        DateFormulaDurationInDays := DateFormulaDate - Today;
        exit(DateFormulaDurationInDays);
    end;
}