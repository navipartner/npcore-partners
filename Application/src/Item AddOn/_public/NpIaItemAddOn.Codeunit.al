codeunit 6059900 "NPR NpIa Item AddOn"
{
    procedure InsertPOSAddOnLines(ItemAddOn: Record "NPR NpIa Item AddOn"; SelectedAddOnLines: JsonToken; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer; CompulsoryAddOn: Boolean): Boolean
    var
        ItemAddOnImpl: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        exit(ItemAddOnImpl.InsertPOSAddOnLines(ItemAddOn, SelectedAddOnLines, POSSession, AppliesToLineNo, CompulsoryAddOn));
    end;

    procedure InsertMandatoryPOSAddOnLinesSilent(ItemAddOn: Record "NPR NpIa Item AddOn"; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer; CompulsoryAddOn: Boolean): Boolean
    var
        ItemAddOnImpl: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        exit(ItemAddOnImpl.InsertMandatoryPOSAddOnLinesSilent(ItemAddOn, POSSession, AppliesToLineNo, CompulsoryAddOn));
    end;

    procedure GetUnitPricePctFromMaster(AddOnNo: Code[20]; AddOnLineNo: Integer): Decimal
    var
        ItemAddOnLineSetup: Codeunit "NPR NpIa Item AddOn Line Setup";
    begin
        exit(ItemAddOnLineSetup.GetUnitPricePctFromMaster(AddOnNo, AddOnLineNo));
    end;

    procedure UnitPriceFromMasterRunSetup(AddOnNo: Code[20]; AddOnLineNo: Integer)
    var
        ItemAddOnLineSetup: Codeunit "NPR NpIa Item AddOn Line Setup";
    begin
        ItemAddOnLineSetup.UnitPriceFromMasterRunSetup(AddOnNo, AddOnLineNo);
    end;

    procedure DeleteSetup(AddOnNo: Code[20]; AddOnLineNo: Integer)
    var
        ItemAddOnLineSetup: Codeunit "NPR NpIa Item AddOn Line Setup";
    begin
        ItemAddOnLineSetup.DeleteSetup(AddOnNo, AddOnLineNo);
    end;

    procedure BeforeInsertPOSAddOnLine(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; var NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    begin
        OnBeforeInsertPOSAddOnLine(SalePOS, AppliesToLineNo, NpIaItemAddOnLine);
    end;

    procedure CheckIfHasSetupBeforeInsertSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var HasSetup: Boolean)
    begin
        OnCheckIfHasSetupBeforeInsertSetup(NpIaItemAddOnLine, HasSetup);
    end;

    procedure RunBeforeInsertSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var IsHandled: Boolean)
    begin
        OnRunBeforeInsertSetup(NpIaItemAddOnLine, IsHandled);
    end;

    internal procedure FilterAttachedItemAddonLines(SaleLinePOS: Record "NPR POS Sale Line"; AppliesToLineNo: Integer; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn")
    begin
        OnFilterAttachedItemAddonLines(SaleLinePOS, AppliesToLineNo, SaleLinePOSAddOn);
    end;

    procedure CopyItemAddOnLinesToTempBeforeInsert(FromItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var ToItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var IsHandled: Boolean)
    begin
        OnCopyItemAddOnLinesToTempBeforeInsert(FromItemAddOnLine, ToItemAddOnLine, IsHandled);
    end;

    internal procedure FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS: Record "NPR POS Sale Line"; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn")
    begin
        OnFilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
    end;

    procedure FilterItemAddOnLine(var ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; ItemAddOn: Record "NPR NpIa Item AddOn"; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer; CompulsoryAddOn: Boolean)
    begin
        OnFilterItemAddOnLine(ItemAddOnLine, ItemAddOn, POSSession, AppliesToLineNo, CompulsoryAddOn);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSAddOnLine(SalePOS: Record "NPR POS Sale"; AppliesToLineNo: Integer; var NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckIfHasSetupBeforeInsertSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var HasSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunBeforeInsertSetup(NpIaItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFilterAttachedItemAddonLines(SaleLinePOS: Record "NPR POS Sale Line"; AppliesToLineNo: Integer; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS: Record "NPR POS Sale Line"; var SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFilterItemAddOnLine(var ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; ItemAddOn: Record "NPR NpIa Item AddOn"; POSSession: Codeunit "NPR POS Session"; AppliesToLineNo: Integer; CompulsoryAddOn: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyItemAddOnLinesToTempBeforeInsert(FromItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var ToItemAddOnLine: Record "NPR NpIa Item AddOn Line"; var IsHandled: Boolean)
    begin
    end;
}