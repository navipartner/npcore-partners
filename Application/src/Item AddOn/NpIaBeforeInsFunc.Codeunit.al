codeunit 6151129 "NPR NpIa Before Ins. Func."
{
    Access = Internal;
    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpIa Item AddOn", 'OnBeforeInsertPOSAddOnLine', '', true, true)]
    local procedure UnitPriceFromMaster(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; var NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemAddOnLineSetup: Codeunit "NPR NpIa Item AddOn Line Setup";
        UnitPricePctFromMaster: Decimal;
    begin
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
            exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
            exit;

        if not SaleLinePOS.Get(SalePOS."Register No.", SalePOS."Sales Ticket No.", SalePOS.Date, SalePOS."Sale type", AppliesToLineNo) then
            exit;
    
        UnitPricePctFromMaster := ItemAddOnLineSetup.GetUnitPricePctFromMaster(NpIaItemAddOnLine."AddOn No.", NpIaItemAddOnLine."Line No.");

        if (SaleLinePOS.Quantity = 0) or (UnitPricePctFromMaster = 0) then begin
            NpIaItemAddOnLine."Unit Price" := 0;
            exit;
        end;

        NpIaItemAddOnLine."Unit Price" := (SaleLinePOS."Amount Including VAT" / SaleLinePOS.Quantity) * (UnitPricePctFromMaster / 100);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpIa Item AddOn", 'OnCheckIfHasSetupBeforeInsertSetup', '', true, true)]
    local procedure UnitPriceFromMasterHasSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var HasSetup: Boolean)
    begin
        if HasSetup then
            exit;
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
            exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
            exit;

        HasSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpIa Item AddOn", 'OnRunBeforeInsertSetup', '', true, true)]
    local procedure UnitPriceFromMasterRunSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var Handled: Boolean)
    var
        ItemAddOnLineSetup: Codeunit "NPR NpIa Item AddOn Line Setup";
    begin
        if Handled then
            exit;
        if NpIaItemAddOnLine."Before Insert Function" <> 'UnitPriceFromMaster' then
            exit;
        if NpIaItemAddOnLine."Before Insert Codeunit ID" <> CurrCodeunitId() then
            exit;

        ItemAddOnLineSetup.UnitPriceFromMasterRunSetup(NpIaItemAddOnLine."AddOn No.", NpIaItemAddOnLine."Line No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpIa Item AddOn Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteAddOnLine(var Rec: Record "NPR NpIa Item AddOn Line"; RunTrigger: Boolean)
    var
        ItemAddOnLineSetup: Codeunit "NPR NpIa Item AddOn Line Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Before Insert Function" <> 'UnitPriceFromMaster' then
            exit;
        if Rec."Before Insert Codeunit ID" <> CurrCodeunitId() then
            exit;            

        ItemAddOnLineSetup.DeleteSetup(Rec."AddOn No.", Rec."Line No.");
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpIa Before Ins. Func.");
    end;
}

