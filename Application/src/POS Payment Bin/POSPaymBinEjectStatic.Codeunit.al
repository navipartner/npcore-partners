codeunit 6248740 "NPR POS Paym.Bin Eject: Static"
{
    Access = Internal;

    internal procedure InvokeMethodCode(): Text
    begin
        exit('STATIC');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Bin Eject Mgt.", 'OnEjectPaymentBin', '', false, false)]
    local procedure OnEjectPaymentBin(POSPaymentBin: Record "NPR POS Payment Bin"; var Ejected: Boolean)
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        Codeunit.Run(Codeunit::"NPR Static Cash Drawer Open", POSPaymentBin);
        Ejected := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Bin Eject Mgt.", 'OnLookupBinInvokeMethods', '', false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "NPR Retail List")
    var
        NewCashDrawerOpenExp: Codeunit "NPR New Cash Drawer Open Exp";
    begin
        if not NewCashDrawerOpenExp.IsFeatureEnabled() then
            exit;

        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(InvokeMethodCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Value := CopyStr(InvokeMethodCode(), 1, MaxStrLen(tmpRetailList.Value));
        tmpRetailList.Insert();
    end;
}
