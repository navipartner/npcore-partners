codeunit 6151376 "NPR POS Action: Switch RegistB"
{
    Access = Internal;
    procedure OnActionList(Setup: Codeunit "NPR POS Setup"; POSSale: Codeunit "NPR POS Sale"; FilterByPosUnitGroupValue: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        NewRegisterNo: Code[10];
    begin
        POSSale.GetCurrentSale(SalePOS);
        if not SelectRegister(SalePOS."Register No.", NewRegisterNo, Setup, FilterByPosUnitGroupValue) then
            exit;
        SwitchRegister(NewRegisterNo, Setup);
    end;

    local procedure TestAllowUnitSwitch(UnitNo: Code[10])
    var
        PSOUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
        Text000: Label 'User %1 is not allowed to Switch to Register %2';
    begin
        UserSetup.Get(UserId);
        if not UserSetup."NPR Allow Register Switch" then
            Error(Text000, UserSetup."User ID", UnitNo);
        if UserSetup."NPR Register Switch Filter" = '' then
            exit;

        PSOUnit.Get(UnitNo);
        PSOUnit.SetRecFilter();
        PSOUnit.FilterGroup(40);
        PSOUnit.SetFilter("No.", UserSetup."NPR Register Switch Filter");
        if not PSOUnit.FindFirst() then
            Error(Text000, UserSetup."User ID", UnitNo);
    end;

    local procedure SelectRegister(CurrUnitNo: Code[10]; var NewUnitNo: Code[10]; Setup: Codeunit "NPR POS Setup"; FilterByPosUnitGroupValue: Boolean) LookupOK: Boolean
    var
        POSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
        Text001: Label 'User %1 is not allowed to Switch Register';
    begin
        UserSetup.Get(UserId);
        if not UserSetup."NPR Allow Register Switch" then
            Error(Text001, UserSetup."User ID");

        POSUnit.FilterGroup(41);
        POSUnit.SetFilter("No.", '<>%1', CurrUnitNo);
        POSUnit.FilterGroup(42);
        POSUnit.SetFilter("No.", UserSetup."NPR Register Switch Filter");
        FilterByPOSUnitGr(FilterByPosUnitGroupValue, POSUnit, Setup);
        POSUnit.FilterGroup(0);

        LookupOK := PAGE.RunModal(0, POSUnit) = ACTION::LookupOK;
        NewUnitNo := POSUnit."No.";
        exit(LookupOK);
    end;

    internal procedure SwitchRegister(RegisterNo: code[10]; Setup: Codeunit "NPR POS Setup")
    var
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        TestAllowUnitSwitch(RegisterNo);

        UserSetup.Get(UserId);
        UserSetup.Validate("NPR POS Unit No.", RegisterNo);
        UserSetup.Modify();

        POSUnit.Get(RegisterNo);
        Setup.SetPOSUnit(POSUnit);
    end;

    internal procedure FilterByPOSUnitGr(FilterByPosUnitGroupValue: Boolean; var POSUnit: Record "NPR POS Unit"; Setup: Codeunit "NPR POS Setup")
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSUnitGroupLine: Record "NPR POS Unit Group Line";
        FilterText: Text;
    begin
        if not FilterByPosUnitGroupValue then
            exit;

        Setup.GetSalespersonRecord(SalespersonPurchaser);
        if SalespersonPurchaser."NPR POS Unit Group" = '' then
            exit;

        POSUnitGroupLine.SetRange("No.", SalespersonPurchaser."NPR POS Unit Group");
        if POSUnitGroupLine.IsEmpty() then
            exit;
        POSUnitGroupLine.FindSet();
        repeat
            if FilterText = '' then
                FilterText += POSUnitGroupLine."POS Unit"
            else
                FilterText += '|' + POSUnitGroupLine."POS Unit";
        until POSUnitGroupLine.Next() = 0;
        POSUnit.SetFilter("No.", FilterText);
    end;
}