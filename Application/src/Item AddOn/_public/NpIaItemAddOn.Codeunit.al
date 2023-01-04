codeunit 6059900 "NPR NpIa Item AddOn"
{
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
}