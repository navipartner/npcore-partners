codeunit 6014499 "NPR Retention Period Impl." implements "Retention Period"
{
    // based on codeunit 3900 "Retention Period Impl." from System App

    Access = Internal;

    var
        WrongInterfaceImplementationErr: Label 'This implementation of the interface does not support the enum value selected. Contact your Microsoft partner for assistance. The following information can help them address the issue: Value: %1, Interface: Interface Retention Period, Implementation: codeunit 3900 Retention Period Impl.', Comment = '%1 = a value such as 1 Week, 1 Month, 3 Months, or Custom.';
        FutureDateCalcErr: Label 'The date formula (%1) must result in a date that is at least two days before the current date. For example, to calculate a period for the past week, month, or year, use either -1W, -1M, or -1Y.', comment = '%1 = a date formula';

    local procedure RetentionPeriodDateFormula(RetentionPeriod: enum "Retention Period Enum"; Translated: Boolean): Text;
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        PeriodDateFormula: DateFormula;
    begin
        case RetentionPeriod of
            RetentionPeriod::"NPR 14 Days":
                Evaluate(PeriodDateFormula, '<-14D>');
            RetentionPeriod::"NPR 2 Years":
                Evaluate(PeriodDateFormula, '<-2Y>');
            RetentionPeriod::"NPR 6 Years":
                Evaluate(PeriodDateFormula, '<-6Y>');
            else
                RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(WrongInterfaceImplementationErr, RetentionPeriod));
        end;

        if Translated then
            Exit(Format(PeriodDateFormula, 0, 1))
        else
            Exit(Format(PeriodDateFormula, 0, 2))
    end;

    procedure RetentionPeriodDateFormula(RetentionPolicy: Record "Retention Period"): Text
    begin
        exit(RetentionPeriodDateFormula(RetentionPolicy, false));
    end;

    procedure RetentionPeriodDateFormula(RetentionPolicy: Record "Retention Period"; Translated: Boolean) DateFormulaText: Text
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        DateFormulaText := RetentionPeriodDateFormula(RetentionPolicy."Retention Period", Translated);
        if DateFormulaText = '' then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(WrongInterfaceImplementationErr, RetentionPolicy."Retention Period"));
    end;

    procedure CalculateExpirationDate(RetentionPolicy: Record "Retention Period"): Date
    begin
        Exit(CalcDate(RetentionPeriodDateFormula(RetentionPolicy), Today()))
    end;

    procedure CalculateExpirationDate(RetentionPolicy: Record "Retention Period"; UseDate: Date): Date
    begin
        Exit(CalcDate(RetentionPeriodDateFormula(RetentionPolicy), UseDate))
    end;

    procedure CalculateExpirationDate(RetentionPolicy: Record "Retention Period"; UseDateTime: DateTime): DateTime
    var
        UseTime: Time;
    begin
        if RetentionPolicy."Retention Period" = RetentionPolicy."Retention Period"::"Never Delete" then
            UseTime := 235959.999T
        else
            UseTime := DT2Time(UseDateTime);
        Exit(CreateDateTime(CalcDate(RetentionPeriodDateFormula(RetentionPolicy), DT2Date(UseDateTime)), UseTime))
    end;

    procedure ValidateRetentionPeriodDateFormula(DateFormula: DateFormula)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        if Format(DateFormula) <> '' then
            if IsFutureDateFormula(DateFormula) then
                RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(FutureDateCalcErr, DateFormula));
    end;

    local procedure IsFutureDateFormula(DateFormula: DateFormula): Boolean
    begin
        Exit(CalcDate(DateFormula, Today()) >= Yesterday());
    end;

    local procedure Yesterday(): Date
    begin
        Exit(CalcDate('<-1D>', Today()))
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Period");
    end;
}
