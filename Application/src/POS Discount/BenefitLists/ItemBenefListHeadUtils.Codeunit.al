codeunit 6151339 "NPR Item Benef List Head Utils"
{
    Access = Internal;

    internal procedure DeleteLines(NPRItemBenefitListHeader: Record "NPR Item Benefit List Header")
    var
        NPRItemBenefitListLine: Record "NPR Item Benefit List Line";
    begin
        NPRItemBenefitListLine.Reset();
        NPRItemBenefitListLine.SetRange("List Code", NPRItemBenefitListHeader.Code);
        if not NPRItemBenefitListLine.IsEmpty then
            NPRItemBenefitListLine.DeleteAll(true);
    end;

    internal procedure CheckIfListPartOfActiveTotalDiscount(NPRItemBenefitListHeader: Record "NPR Item Benefit List Header")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        TotalDiscountStatusErrorLbl: Label 'Total Discount %1 - %2 must be disabled.', Comment = '%1 - Total Discount Code, %2 - Description';
    begin
        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetcurrentKey(Status,
                                             Type,
                                             "No.");

        NPRTotalDiscountBenefit.SetRange(Status, NPRTotalDiscountBenefit.Status::Active);
        NPRTotalDiscountBenefit.SetRange(Type, NPRTotalDiscountBenefit.Type::"Item List");
        NPRTotalDiscountBenefit.SetRange("No.", NPRItemBenefitListHeader.Code);
        if not NPRTotalDiscountBenefit.FindFirst() then
            exit;

        if not NPRTotalDiscountHeader.Get(NPRTotalDiscountBenefit."Total Discount Code") then
            Clear(NPRTotalDiscountHeader);

        Error(TotalDiscountStatusErrorLbl,
              NPRTotalDiscountHeader."Code",
              NPRTotalDiscountHeader.Description);
    end;

    internal procedure GetBenefitItemListLinesLastLineNo(NPRItemBenefitListHeader: Record "NPR Item Benefit List Header") LastLineNo: Integer
    var
        NPRItemBenefitListLine: Record "NPR Item Benefit List Line";
    begin
        NPRItemBenefitListLine.Reset();
        NPRItemBenefitListLine.SetRange("List Code", NPRItemBenefitListHeader.Code);
        NPRItemBenefitListLine.SetLoadFields("List Code",
                                             "Line No.");
        if not NPRItemBenefitListLine.FindLast() then
            exit;

        LastLineNo := NPRItemBenefitListLine."Line No.";

    end;
}