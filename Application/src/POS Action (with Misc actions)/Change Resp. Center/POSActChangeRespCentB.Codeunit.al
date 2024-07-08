codeunit 6150699 "NPR POS Act:Change Resp Cent B"
{
    Access = Internal;
    procedure OnActionLookupRespCenter(RespCenterCode: Code[10]; POSSale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        POSSale.GetCurrentSale(SalePOS);
        if ResponsibilityCenter.Get(SalePOS."Responsibility Center") then;
        if RespCenterCode <> '' then
            if ResponsibilityCenter.Get(RespCenterCode) then;
        if Page.RunModal(0, ResponsibilityCenter) <> Action::LookupOK then
            exit;

        ApplyRespCenterCode(ResponsibilityCenter.Code, POSSale);
    end;

    procedure ApplyRespCenterCode(RespCenterCode: Code[10]; POSSale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.Validate("Responsibility Center", RespCenterCode);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
    end;
}