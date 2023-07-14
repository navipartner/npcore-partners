codeunit 6151355 "NPR POS Action: Raptor B"
{
    Access = Internal;

    [TryFunction]
    procedure TryToRunAction(POSSale: Codeunit "NPR POS Sale"; RaptorActionCode: Code[20])
    var
        RaptorAction: Record "NPR Raptor Action";
        SalePOS: Record "NPR POS Sale";
        RaptorMgt: Codeunit "NPR Raptor Management";
    begin
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");

        if RaptorActionCode <> '' then
            RaptorAction.Get(RaptorActionCode)
        else
            if not RaptorMgt.SelectRaptorAction('', false, RaptorAction) then
                Error('');
        RaptorMgt.ShowRaptorData(RaptorAction, SalePOS."Customer No.");
    end;
}