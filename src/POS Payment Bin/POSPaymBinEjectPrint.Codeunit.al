codeunit 6150643 "NPR POS Paym. Bin Eject: Print"
{
    // NPR5.40/MMV /20180228 CASE 300660 Created object
    // NPR5.41/MMV /20180425 CASE 312990 Renamed object


    trigger OnRun()
    begin
    end;

    local procedure InvokeMethodCode(): Text
    begin
        exit('PRINTER');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnEjectPaymentBin', '', false, false)]
    local procedure OnEjectPaymentBin(POSPaymentBin: Record "NPR POS Payment Bin"; var Ejected: Boolean)
    var
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        LinePrintMgt.ProcessCodeunit(CODEUNIT::"NPR Report: Open drawer IV", 0);
        Ejected := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnLookupBinInvokeMethods', '', false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := InvokeMethodCode;
        tmpRetailList.Value := InvokeMethodCode;
        tmpRetailList.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnShowInvokeParameters', '', false, false)]
    local procedure OnShowInvokeParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    begin
        //No parameters
    end;
}

