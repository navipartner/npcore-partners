codeunit 6151338 "NPR Item Benef List Line Utils"
{
    Access = Internal;
    internal procedure UpdateItemFields(var NPRItemBenefitListLine: Record "NPR Item Benefit List Line")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        if not Item.Get(NPRItemBenefitListLine."No.") then
            Clear(Item);

        if not ItemVariant.Get(NPRItemBenefitListLine."No.",
                               NPRItemBenefitListLine."Variant Code")
        then
            Clear(ItemVariant);

        NPRItemBenefitListLine.Description := Item.Description;

        if ItemVariant.Description <> '' then
            NPRItemBenefitListLine.Description := ItemVariant.Description;

    end;

    internal procedure CheckIfListPartOfActiveTotalDiscount(var NPRItemBenefitListLine: Record "NPR Item Benefit List Line")
    var
        NPRItemBenefitListHeader: Record "NPR Item Benefit List Header";
        NPRItemBenefListHeadUtils: Codeunit "NPR Item Benef List Head Utils";
    begin
        if not NPRItemBenefitListHeader.Get(NPRItemBenefitListLine."List Code") then
            exit;

        NPRItemBenefListHeadUtils.CheckIfListPartOfActiveTotalDiscount(NPRItemBenefitListHeader);
    end;
}