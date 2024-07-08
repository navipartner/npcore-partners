codeunit 6151271 "NPR Tot Disc Time Interv Utils"
{
    Access = Internal;

    internal procedure UpdatePeriodDescription(var NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.")
    begin
        NPRTotalDiscTimeInterv."Period Description" := '';
        if NPRTotalDiscTimeInterv."Period Type" = NPRTotalDiscTimeInterv."Period Type"::"Every Day" then
            exit;

        if NPRTotalDiscTimeInterv.Monday then
            AppendPeriodDescription(NPRTotalDiscTimeInterv,
                                    NPRTotalDiscTimeInterv.FieldCaption(Monday));
        if NPRTotalDiscTimeInterv.Tuesday then
            AppendPeriodDescription(NPRTotalDiscTimeInterv,
                                    NPRTotalDiscTimeInterv.FieldCaption(Tuesday));
        if NPRTotalDiscTimeInterv.Wednesday then
            AppendPeriodDescription(NPRTotalDiscTimeInterv,
                                    NPRTotalDiscTimeInterv.FieldCaption(Wednesday));
        if NPRTotalDiscTimeInterv.Thursday then
            AppendPeriodDescription(NPRTotalDiscTimeInterv,
                                    NPRTotalDiscTimeInterv.FieldCaption(Thursday));
        if NPRTotalDiscTimeInterv.Friday then
            AppendPeriodDescription(NPRTotalDiscTimeInterv,
                                    NPRTotalDiscTimeInterv.FieldCaption(Friday));
        if NPRTotalDiscTimeInterv.Saturday then
            AppendPeriodDescription(NPRTotalDiscTimeInterv,
                                    NPRTotalDiscTimeInterv.FieldCaption(Saturday));
        if NPRTotalDiscTimeInterv.Sunday then
            AppendPeriodDescription(NPRTotalDiscTimeInterv,
                                    NPRTotalDiscTimeInterv.FieldCaption(Sunday));
    end;

    local procedure AppendPeriodDescription(var NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
                                            PeriodDescription: Text)
    begin
        if PeriodDescription = '' then
            exit;

        if NPRTotalDiscTimeInterv."Period Description" <> '' then
            NPRTotalDiscTimeInterv."Period Description" := CopyStr(NPRTotalDiscTimeInterv."Period Description" + ',' + PeriodDescription, 1, MaxStrLen(NPRTotalDiscTimeInterv."Period Description"))
        else
            NPRTotalDiscTimeInterv."Period Description" := CopyStr(PeriodDescription, 1, MaxStrLen(NPRTotalDiscTimeInterv."Period Description"));
    end;

    internal procedure CheckIfTotalDiscountEditable(var NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        if not NPRTotalDiscountHeader.Get(NPRTotalDiscTimeInterv."Total Discount Code") then
            exit;

        NPRTotalDiscHeaderUtils.CheckIfTotalDiscountEditable(NPRTotalDiscountHeader);

    end;

}