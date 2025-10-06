codeunit 6150659 "NPR POS Action: Quick Login B."
{
    Access = Internal;
    procedure OnActionLookupSalespersonCode(SalespersonCode: Code[20]; POSSale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSActionLogin: Codeunit "NPR POS Action - Login-B";
    begin
        POSSale.GetCurrentSale(SalePOS);

        if SalespersonPurchaser.Get(SalePOS."Salesperson Code") then;
        if SalespersonCode <> '' then
            if SalespersonPurchaser.Get(SalespersonCode) then;

        if Page.RunModal(0, SalespersonPurchaser) <> Action::LookupOK then
            exit;

        POSActionLogin.CheckPosUnitGroup(SalespersonPurchaser, SalePOS."Register No.");

        ApplySalespersonCode(SalespersonPurchaser.Code, POSSale);
    end;

    procedure ApplySalespersonCode(SalespersonCode: Code[20]; POSSale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
#if not (BC17 or BC18 or BC19)
        POSActionLoginB: Codeunit "NPR POS Action - Login-B";
#endif
    begin
#if not (BC17 or BC18 or BC19)
        POSActionLoginB.CheckSalespersonBlocked(SalespersonCode);
#endif
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.Validate("Salesperson Code", SalespersonCode);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
    end;
}