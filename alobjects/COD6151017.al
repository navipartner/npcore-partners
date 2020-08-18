codeunit 6151017 "NpRv Module Payment - Default"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.40/VB  /20180307 CASE 306347 Refactored InvokeWorkflow call.
    // NPR5.48/MHA /20190213  CASE 342920 Return Amount should not be rounded and consider Min. Amount on Payment Type
    // NPR5.55/MHA /20200603  CASE 363864 Added interface for Sales Document Payments


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Apply Payment - Default (Full Payment)';

    procedure ApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sales Line")
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

    procedure ApplyPaymentSalesDoc(NpRvVoucherType: Record "NpRv Voucher Type";SalesHeader: Record "Sales Header";var NpRvSalesLine: Record "NpRv Sales Line")
    var
        MagentoPaymentLine: Record "Magento Payment Line";
        MagentoPaymentLineNew: Record "Magento Payment Line";
        NpRvVoucher: Record "NpRv Voucher";
        NpRvVoucherTypeNew: Record "NpRv Voucher Type";
        NpRvSalesLineNew: Record "NpRv Sales Line";
        NpRvSalesLineReference: Record "NpRv Sales Line Reference";
        NpRvReturnVoucherType: Record "NpRv Return Voucher Type";
        PaymentTypePOS: Record "Payment Type POS";
        TempNpRvVoucher: Record "NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
        ReturnAmount: Decimal;
        LineNo: Integer;
        ReturnLineExists: Boolean;
    begin
        //-NPR5.55 [363864]
        NpRvSalesLine.Get(NpRvSalesLine.Id);
        NpRvSalesLine.TestField("Document Source",NpRvSalesLine."Document Source"::"Payment Line");
        MagentoPaymentLine.Get(DATABASE::"Sales Header",SalesHeader."Document Type",SalesHeader."No.",NpRvSalesLine."Document Line No.");
        NpRvVoucher.Get(NpRvSalesLine."Voucher No.");

        NpRvVoucher.CalcFields(Amount);
        if MagentoPaymentLine.Amount < NpRvVoucher.Amount then begin
          MagentoPaymentLine.Amount := NpRvVoucher.Amount;
          MagentoPaymentLine.Modify(true);
        end;

        NpRvReturnVoucherType.Get(NpRvVoucherType.Code);
        NpRvReturnVoucherType.TestField("Return Voucher Type");
        NpRvVoucherTypeNew.Get(NpRvReturnVoucherType."Return Voucher Type");

        SalesHeader.CalcFields("Magento Payment Amount");
        ReturnAmount := SalesHeader."Magento Payment Amount" - GetTotalAmtInclVat(SalesHeader);
        NpRvSalesLineNew.SetRange("Parent Id",NpRvSalesLine.Id);
        NpRvSalesLineNew.SetRange("Document Source",NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLineNew.SetRange(Type,NpRvSalesLine.Type::"New Voucher");
        if NpRvSalesLineNew.FindFirst then begin
          ReturnLineExists := true;
          MagentoPaymentLineNew.Get(DATABASE::"Sales Header",NpRvSalesLineNew."Document Type",
            NpRvSalesLineNew."Document No.",NpRvSalesLineNew."Document Line No.");
          ReturnAmount -= MagentoPaymentLineNew.Amount;
        end;

        if ReturnAmount <= 0 then begin
          if ReturnLineExists then
            RemoveReturnVoucher(NpRvSalesLine);
          exit;
        end;

        if PaymentTypePOS.Get(NpRvVoucherTypeNew."Payment Type") then begin
          if PaymentTypePOS."Rounding Precision" > 0 then
            ReturnAmount := Round(ReturnAmount,PaymentTypePOS."Rounding Precision");

          if (PaymentTypePOS."Minimum Amount" > 0) and (Abs(ReturnAmount) < Abs(PaymentTypePOS."Minimum Amount")) then begin
            if ReturnLineExists then
              RemoveReturnVoucher(NpRvSalesLine);
            exit;
          end;
        end;

        if ReturnLineExists then begin
          if MagentoPaymentLineNew.Amount <> -ReturnAmount then begin
            MagentoPaymentLineNew.Amount := -ReturnAmount;
            MagentoPaymentLineNew.Modify(true);
          end;

          exit;
        end;

        NpRvVoucherMgt.GenerateTempVoucher(NpRvVoucherTypeNew,TempNpRvVoucher);

        MagentoPaymentLineNew.SetRange("Document Table No.",DATABASE::"Sales Header");
        MagentoPaymentLineNew.SetRange("Document Type",SalesHeader."Document Type");
        MagentoPaymentLineNew.SetRange("Document No.",SalesHeader."No.");
        if MagentoPaymentLineNew.FindLast then;
        LineNo := MagentoPaymentLineNew."Line No." + 10000;

        MagentoPaymentLineNew.Init;
        MagentoPaymentLineNew."Document Table No." := DATABASE::"Sales Header";
        MagentoPaymentLineNew."Document Type" := SalesHeader."Document Type";
        MagentoPaymentLineNew."Document No." := SalesHeader."No.";
        MagentoPaymentLineNew."Line No." := LineNo;
        MagentoPaymentLineNew."External Reference No." := SalesHeader."External Order No.";
        MagentoPaymentLineNew."Payment Type" := MagentoPaymentLineNew."Payment Type"::Voucher;
        MagentoPaymentLineNew."No." := TempNpRvVoucher."Reference No.";
        MagentoPaymentLineNew.Amount := -ReturnAmount;
        MagentoPaymentLineNew."Account Type" := MagentoPaymentLineNew."Account Type"::"G/L Account";
        MagentoPaymentLineNew."Account No." := NpRvVoucherType."Account No.";
        MagentoPaymentLineNew.Description := TempNpRvVoucher.Description;
        MagentoPaymentLineNew."Source Table No." := DATABASE::"NpRv Voucher";
        MagentoPaymentLineNew."Source No." := TempNpRvVoucher."No.";
        MagentoPaymentLineNew."Posting Date" := SalesHeader."Posting Date";
        MagentoPaymentLineNew.Insert(true);

        NpRvSalesLineNew.Init;
        NpRvSalesLineNew.Id := CreateGuid;
        NpRvSalesLineNew."Parent Id" := NpRvSalesLine.Id;
        NpRvSalesLineNew."Document Source" := NpRvSalesLineNew."Document Source"::"Payment Line";
        NpRvSalesLineNew."Document Type" := MagentoPaymentLineNew."Document Type";
        NpRvSalesLineNew."Document No." := MagentoPaymentLineNew."Document No.";
        NpRvSalesLineNew."Document Line No." := MagentoPaymentLineNew."Line No.";
        NpRvSalesLineNew."External Document No." := MagentoPaymentLineNew."External Reference No.";
        NpRvSalesLineNew.Type := NpRvSalesLineNew.Type::"New Voucher";
        NpRvSalesLineNew."Voucher Type" := TempNpRvVoucher."Voucher Type";
        NpRvSalesLineNew."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLineNew."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLineNew.Description := TempNpRvVoucher.Description;
        NpRvSalesLineNew.Validate("Customer No.",SalesHeader."Sell-to Customer No.");
        if (not NpRvSalesLineNew."Send via Print") and (not NpRvSalesLineNew."Send via SMS") and (NpRvSalesLineNew."E-mail" <> '') then
          NpRvSalesLineNew."Send via E-mail" := true;
        NpRvSalesLineNew.Insert(true);

        NpRvSalesLineReference.Init;
        NpRvSalesLineReference.Id := CreateGuid;
        NpRvSalesLineReference."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLineReference."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLineReference."Sales Line Id" := NpRvSalesLineNew.Id;
        NpRvSalesLineReference.Insert(true);
        //+NPR5.55 [363864]
    end;

    local procedure RemoveReturnVoucher(NpRvSalesLineParent: Record "NpRv Sales Line")
    var
        MagentoPaymentLine: Record "Magento Payment Line";
        NpRvSalesLine: Record "NpRv Sales Line";
    begin
        //-NPR5.55 [363864]
        NpRvSalesLine.SetRange("Parent Id",NpRvSalesLineParent.Id);
        NpRvSalesLine.SetRange("Document Source",NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange(Type,NpRvSalesLine.Type::"New Voucher");
        if NpRvSalesLine.FindSet then
          repeat
            if MagentoPaymentLine.Get(DATABASE::"Sales Header",NpRvSalesLine."Document Type",
              NpRvSalesLine."Document No.",NpRvSalesLine."Document Line No.")
            then
              MagentoPaymentLine.Delete;

            NpRvSalesLine.Delete(true);
          until NpRvSalesLine.Next = 0;
        //+NPR5.55 [363864]
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
    local procedure OnRunApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sales Line";var Handled: Boolean)
    begin
        if Handled then
          exit;
        if not IsSubscriber(VoucherType) then
          exit;

        Handled := true;

        ApplyPayment(FrontEnd,POSSession,VoucherType,SaleLinePOSVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunApplyPaymentSalesDoc', '', true, true)]
    local procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NpRv Voucher Type";SalesHeader: Record "Sales Header";var NpRvSalesLine: Record "NpRv Sales Line";var Handled: Boolean)
    begin
        //-NPR5.55 [363864]
        if Handled then
          exit;
        if not IsSubscriber(VoucherType) then
          exit;

        Handled := true;

        ApplyPaymentSalesDoc(VoucherType,SalesHeader,NpRvSalesLine);
        //+NPR5.55 [363864]
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

    local procedure GetTotalAmtInclVat(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLineTemp: Record "Sales Line" temporary;
        VATAmountLineTemp: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        //-NPR5.55 [363864]
        SalesPost.GetSalesLines(SalesHeader,SalesLineTemp,0);
        SalesLineTemp.CalcVATAmountLines(0,SalesHeader,SalesLineTemp,VATAmountLineTemp);
        SalesLineTemp.UpdateVATOnLines(0,SalesHeader,SalesLineTemp,VATAmountLineTemp);
        exit(VATAmountLineTemp.GetTotalAmountInclVAT());
        //+NPR5.55 [363864]
    end;
}

