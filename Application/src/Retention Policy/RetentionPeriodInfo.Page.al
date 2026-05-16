#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
page 6150957 "NPR Retention Period Info"
{
    Caption = 'Retention Period Information';
    PageType = Worksheet;
    ApplicationArea = NPRRetail;
    UsageCategory = None;
    SourceTable = "NPR Retention Policy Period";
    SourceTableTemporary = true;
    DataCaptionExpression = PageDataCaption;
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(InstructionsEditable)
            {
                ShowCaption = false;
                Visible = RetentionPeriodsEditable;
                InstructionalText = 'Retention periods control how long records matching each description are kept before they are automatically deleted. Use a negative date formula such as -3M (three months) or -1Y (one year). Clear a period to reset it to the system default.';
            }
            group(InstructionsReadOnly)
            {
                ShowCaption = false;
                Visible = not RetentionPeriodsEditable;
                InstructionalText = 'The retention periods shown here control how long records matching each description are kept before they are automatically deleted.';
            }
            repeater(PeriodLines)
            {
                ShowCaption = false;

                field(Description; PeriodDescription)
                {
                    Caption = 'Description';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the kind of records the retention period on this line applies to.';
                }
                field("Retention Period"; Rec."Retention Period")
                {
                    Caption = 'Retention Period';
                    ApplicationArea = NPRRetail;
                    Editable = RetentionPeriodsEditable;
                    ToolTip = 'Specifies how long records matching the description are kept before they are automatically deleted.';

                    trigger OnValidate()
                    begin
                        ValidateRetentionPeriodIsNegative(Rec."Retention Period");
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PeriodDescription := GetPeriodDescription(Rec."Period Type");
    end;

    internal procedure SetRetentionPolicy(RetentionPolicy: Record "NPR Retention Policy")
    var
        EmptyDateFormula: DateFormula;
        ActiveRetentionPeriod: DateFormula;
        PeriodType: Enum "NPR Retention Period Type";
    begin
        _RetentionPolicy := RetentionPolicy;
        _RetentionPolicy.CalcFields("Table Caption");
        PageDataCaption := _RetentionPolicy."Table Caption";

        Rec.Reset();
        Rec.DeleteAll();
        foreach PeriodType in Enum::"NPR Retention Period Type".Ordinals() do begin
            ActiveRetentionPeriod := _RetentionPolicy.GetActiveRetentionPeriod(PeriodType);
            if (ActiveRetentionPeriod <> EmptyDateFormula) or _PeriodDescriptions.ContainsKey(PeriodType) then begin
                Rec.Init();
                Rec."Table Id" := _RetentionPolicy."Table Id";
                Rec."Period Type" := PeriodType;
                Rec."Retention Period" := ActiveRetentionPeriod;
                Rec.Insert();
            end;
        end;
    end;

    internal procedure SetRetentionPeriodsEditable(PeriodsEditable: Boolean)
    begin
        RetentionPeriodsEditable := PeriodsEditable;
    end;

    internal procedure SetRetentionPeriodDescriptions(PeriodDescriptions: Dictionary of [Enum "NPR Retention Period Type", Text])
    begin
        _PeriodDescriptions := PeriodDescriptions;
    end;

    internal procedure GetRetentionPeriods(var Periods: Dictionary of [Enum "NPR Retention Period Type", DateFormula])
    begin
        Clear(Periods);
        Rec.Reset();
        if Rec.FindSet() then
            repeat
                Periods.Add(Rec."Period Type", Rec."Retention Period");
            until Rec.Next() = 0;
    end;

    local procedure GetPeriodDescription(PeriodType: Enum "NPR Retention Period Type"): Text
    var
        Descr: Text;
        DefaultPeriodDescLbl: Label 'All entries in the table';
        AlternativePeriodDescLbl: Label 'Alternative %1';
    begin
        if _PeriodDescriptions.Get(PeriodType, Descr) then
            exit(Descr);
        if PeriodType = PeriodType::"Period 1" then
            exit(DefaultPeriodDescLbl);
        exit(StrSubstNo(AlternativePeriodDescLbl, Format(PeriodType)));
    end;

    local procedure ValidateRetentionPeriodIsNegative(RetentionPeriod: DateFormula)
    var
        EmptyDateFormula: DateFormula;
        NegativeDateFormulaErr: Label 'The retention period must be negative or cleared.';
    begin
        if RetentionPeriod = EmptyDateFormula then
            exit;

        if CalcDate(RetentionPeriod, Today()) >= Today() then
            Error(NegativeDateFormulaErr);
    end;

    var
        _RetentionPolicy: Record "NPR Retention Policy";
        _PeriodDescriptions: Dictionary of [Enum "NPR Retention Period Type", Text];
        RetentionPeriodsEditable: Boolean;
        PageDataCaption: Text;
        PeriodDescription: Text;
}
#endif
