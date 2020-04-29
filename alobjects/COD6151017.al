codeunit 6151017 "NpRv Module Payment - Default"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.40/VB  /20180307 CASE 306347 Refactored InvokeWorkflow call.
    // NPR5.48/MHA /20190213  CASE 342920 Return Amount should not be rounded and consider Min. Amount on Payment Type


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Apply Payment - Default (Full Payment)';

    procedure ApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher")
    var
        PaymentTypePOS: Record "Payment Type POS";
        POSAction: Record "POS Action";
        ReturnVoucherType: Record "NpRv Return Voucher Type";
        VoucherType2: Record "NpRv Voucher Type";
        POSPaymentLine: Codeunit "POS Payment Line";
        POSSale: Codeunit "POS Sale";
        ReturnPOSActionMgt: Codeunit "NpRv Return POS Action Mgt.";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount,PaidAmount,ReturnAmount,Subtotal);
        if Subtotal >= 0 then
          exit;

        if ReturnVoucherType.Get(VoucherType.Code) then;
        //-NPR5.48 [342920]
        if VoucherType2.Get(ReturnVoucherType."Return Voucher Type") and PaymentTypePOS.Get(VoucherType2."Payment Type") then begin
          ReturnAmount := SaleAmount - PaidAmount;
          if PaymentTypePOS."Rounding Precision" > 0 then
            ReturnAmount := Round(SaleAmount - PaidAmount,PaymentTypePOS."Rounding Precision");

          if (PaymentTypePOS."Minimum Amount" > 0) and (Abs(ReturnAmount) < (PaymentTypePOS."Minimum Amount")) then
            exit;
        end;
        //+NPR5.48 [342920]
        //-NPR5.40 [306347]
        //POSAction.GET(ReturnPOSActionMgt.ActionCode());
        if not POSSession.RetrieveSessionAction(ReturnPOSActionMgt.ActionCode(),POSAction) then
          POSAction.Get(ReturnPOSActionMgt.ActionCode());
        //+NPR5.40 [306347]
        POSAction.SetWorkflowInvocationParameter('VoucherTypeCode',ReturnVoucherType."Return Voucher Type",FrontEnd);
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure "--- Voucher Interface"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Apply Payment",ModuleCode()) then
          exit;

        VoucherModule.Init;
        VoucherModule.Type := VoucherModule.Type::"Apply Payment";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasApplyPaymentSetup', '', true, true)]
    local procedure OnHasApplyPaymentSetup(VoucherType: Record "NpRv Voucher Type";var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
          exit;

        HasApplySetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupApplyPayment', '', true, true)]
    local procedure OnSetupApplyPayment(var VoucherType: Record "NpRv Voucher Type")
    var
        ReturnVoucherType: Record "NpRv Return Voucher Type";
    begin
        if not IsSubscriber(VoucherType) then
          exit;

        if not ReturnVoucherType.Get(VoucherType.Code) then begin
          ReturnVoucherType.Init;
          ReturnVoucherType."Voucher Type" := VoucherType.Code;
          ReturnVoucherType.Insert(true);
        end;

        PAGE.Run(PAGE::"NpRv Return Voucher Card",ReturnVoucherType);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunApplyPayment', '', true, true)]
    local procedure OnRunApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sale Line POS Voucher";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriber(VoucherType) then
          exit;

        Handled := true;

        ApplyPayment(FrontEnd,POSSession,VoucherType,SaleLinePOSVoucher);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpRv Module Payment - Default");
    end;

    local procedure IsSubscriber(VoucherType: Record "NpRv Voucher Type"): Boolean
    begin
        exit(VoucherType."Apply Payment Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}

