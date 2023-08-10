page 6151114 "NPR Date Dialog"
{
    Extensible = false;
    PageType = StandardDialog;
    UsageCategory = None;
    Caption = 'Date Dialog';

    layout
    {
        area(content)
        {
            field(StartDateVar; StartDateValue)
            {
                ShowMandatory = true;
                Caption = 'Start Date';
                ToolTip = 'Specifies the date.';
                ApplicationArea = NPRRSLocal;

                trigger OnValidate()
                begin
                    CheckDates();
                end;
            }
            field(EndDateVar; EndDateValue)
            {
                ShowMandatory = true;
                Caption = 'End Date';
                ToolTip = 'Specifies the date.';
                ApplicationArea = NPRRSLocal;

                trigger OnValidate()
                begin
                    CheckDates();
                end;
            }
        }
    }

    var
        StartDateValue, EndDateValue : Date;
        StartDateHigherLbl: Label 'Start Date cannot be higher than End Date';

    internal procedure GetStartDate(): Date
    begin
        exit(StartDateValue);
    end;

    internal procedure GetEndDate(): Date
    begin
        exit(EndDateValue);
    end;

    local procedure CheckDates()
    begin
        if (StartDateValue <> 0D) and (EndDateValue <> 0D) then
            if StartDateValue > EndDateValue then
                Error(StartDateHigherLbl);
    end;
}