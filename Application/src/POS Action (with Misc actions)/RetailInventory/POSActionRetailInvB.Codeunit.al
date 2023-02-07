codeunit 6150622 "NPR POS Action - Retail Inv. B"
{
    Access = Internal;
    procedure ProcessInventorySet(POSSaleLine: Codeunit "NPR POS Sale Line"; FixedInventorySetCode: Code[20])
    var
        RetailInventoryBuffer: Record "NPR RIS Retail Inv. Buffer";
        RetailInventorySet: Record "NPR RIS Retail Inv. Set";
        SaleLinePOS: Record "NPR POS Sale Line";
        RetailInventorySetMgt: Codeunit "NPR RIS Retail Inv. Set Mgt.";
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS.TestField("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.TestField("No.");

        if not SelectRetailInventorySetCode(FixedInventorySetCode, RetailInventorySet) then
            exit;

        RetailInventorySetMgt.ProcessInventorySet(RetailInventorySet, SaleLinePOS."No.", SaleLinePOS."Variant Code", RetailInventoryBuffer);
        PAGE.RunModal(0, RetailInventoryBuffer);
    end;

    local procedure SelectRetailInventorySetCode(FixedInventorySetCode: Code[20]; var RetailInventorySet: Record "NPR RIS Retail Inv. Set") EntrySetSelected: Boolean
    begin
        if (FixedInventorySetCode <> '') and RetailInventorySet.Get(FixedInventorySetCode) then
            exit(true);

        RetailInventorySet.FindLast();
        FixedInventorySetCode := RetailInventorySet.Code;
        RetailInventorySet.FindFirst();
        if FixedInventorySetCode = RetailInventorySet.Code then
            exit(true);

        EntrySetSelected := PAGE.RunModal(0, RetailInventorySet) = ACTION::LookupOK;
        exit(EntrySetSelected);
    end;
}