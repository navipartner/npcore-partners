codeunit 6151017 "NPR NpRv Module Pay.: Default"
{
    var
        Text000: Label 'Apply Payment - Default (Full Payment)';

    procedure ApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSAction: Record "NPR POS Action";
        ReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
        VoucherType2: Record "NPR NpRv Voucher Type";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        ReturnPOSActionMgt: Codeunit "NPR NpRv Ret. POSAction Mgt.";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if Subtotal >= 0 then
            exit;

        if ReturnVoucherType.Get(VoucherType.Code) then;
        if VoucherType2.Get(ReturnVoucherType."Return Voucher Type") and POSPaymentMethod.Get(VoucherType2."Payment Type") then begin
            ReturnAmount := SaleAmount - PaidAmount;
            if POSPaymentMethod."Rounding Precision" > 0 then
                ReturnAmount := Round(SaleAmount - PaidAmount, POSPaymentMethod."Rounding Precision");

            if (POSPaymentMethod."Minimum Amount" > 0) and (Abs(ReturnAmount) < (POSPaymentMethod."Minimum Amount")) then
                exit;
            if (VoucherType2."Minimum Amount Issue" > 0) and (Abs(ReturnAmount) < VoucherType2."Minimum Amount Issue") then
                exit;

        end;
        if not POSSession.RetrieveSessionAction(ReturnPOSActionMgt.ActionCode(), POSAction) then
            POSAction.Get(ReturnPOSActionMgt.ActionCode());
        POSAction.SetWorkflowInvocationParameter('VoucherTypeCode', ReturnVoucherType."Return Voucher Type", FrontEnd);
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    procedure ApplyPaymentSalesDoc(NpRvVoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        MagentoPaymentLineNew: Record "NPR Magento Payment Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherTypeNew: Record "NPR NpRv Voucher Type";
        NpRvSalesLineNew: Record "NPR NpRv Sales Line";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        NpRvReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        TempNpRvVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        ReturnAmount: Decimal;
        LineNo: Integer;
        ReturnLineExists: Boolean;
    begin
        NpRvSalesLine.Get(NpRvSalesLine.Id);
        NpRvSalesLine.TestField("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        MagentoPaymentLine.Get(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", NpRvSalesLine."Document Line No.");
        NpRvVoucher.Get(NpRvSalesLine."Voucher No.");

        NpRvVoucher.CalcFields(Amount);
        if MagentoPaymentLine.Amount < NpRvVoucher.Amount then begin
            MagentoPaymentLine.Amount := NpRvVoucher.Amount;
            MagentoPaymentLine.Modify(true);
        end;

        NpRvReturnVoucherType.Get(NpRvVoucherType.Code);
        NpRvReturnVoucherType.TestField("Return Voucher Type");
        NpRvVoucherTypeNew.Get(NpRvReturnVoucherType."Return Voucher Type");

        SalesHeader.CalcFields("NPR Magento Payment Amount");
        ReturnAmount := SalesHeader."NPR Magento Payment Amount" - GetTotalAmtInclVat(SalesHeader);
        NpRvSalesLineNew.SetRange("Parent Id", NpRvSalesLine.Id);
        NpRvSalesLineNew.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLineNew.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if NpRvSalesLineNew.FindFirst then begin
            ReturnLineExists := true;
            MagentoPaymentLineNew.Get(DATABASE::"Sales Header", NpRvSalesLineNew."Document Type",
              NpRvSalesLineNew."Document No.", NpRvSalesLineNew."Document Line No.");
            ReturnAmount -= MagentoPaymentLineNew.Amount;
        end;

        if ReturnAmount <= 0 then begin
            if ReturnLineExists then
                RemoveReturnVoucher(NpRvSalesLine);
            exit;
        end;

        if POSPaymentMethod.Get(NpRvVoucherTypeNew."Payment Type") then begin
            if POSPaymentMethod."Rounding Precision" > 0 then
                ReturnAmount := Round(ReturnAmount, POSPaymentMethod."Rounding Precision");

            if not POSPaymentMethod."No Min Amount on Web Orders" then
                if (POSPaymentMethod."Minimum Amount" > 0) and (Abs(ReturnAmount) < Abs(POSPaymentMethod."Minimum Amount")) then begin
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

        NpRvVoucherMgt.GenerateTempVoucher(NpRvVoucherTypeNew, TempNpRvVoucher);

        MagentoPaymentLineNew.SetRange("Document Table No.", DATABASE::"Sales Header");
        MagentoPaymentLineNew.SetRange("Document Type", SalesHeader."Document Type");
        MagentoPaymentLineNew.SetRange("Document No.", SalesHeader."No.");
        if MagentoPaymentLineNew.FindLast then;
        LineNo := MagentoPaymentLineNew."Line No." + 10000;

        MagentoPaymentLineNew.Init;
        MagentoPaymentLineNew."Document Table No." := DATABASE::"Sales Header";
        MagentoPaymentLineNew."Document Type" := SalesHeader."Document Type";
        MagentoPaymentLineNew."Document No." := SalesHeader."No.";
        MagentoPaymentLineNew."Line No." := LineNo;
        MagentoPaymentLineNew."External Reference No." := SalesHeader."NPR External Order No.";
        MagentoPaymentLineNew."Payment Type" := MagentoPaymentLineNew."Payment Type"::Voucher;
        MagentoPaymentLineNew."No." := TempNpRvVoucher."Reference No.";
        MagentoPaymentLineNew.Amount := -ReturnAmount;
        MagentoPaymentLineNew."Account Type" := MagentoPaymentLineNew."Account Type"::"G/L Account";
        MagentoPaymentLineNew."Account No." := NpRvVoucherType."Account No.";
        MagentoPaymentLineNew.Description := TempNpRvVoucher.Description;
        MagentoPaymentLineNew."Source Table No." := DATABASE::"NPR NpRv Voucher";
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
        NpRvSalesLineNew.Validate("Customer No.", SalesHeader."Sell-to Customer No.");
        if (not NpRvSalesLineNew."Send via Print") and (not NpRvSalesLineNew."Send via SMS") and (NpRvSalesLineNew."E-mail" <> '') then
            NpRvSalesLineNew."Send via E-mail" := true;
        NpRvSalesLineNew.Insert(true);

        NpRvSalesLineReference.Init;
        NpRvSalesLineReference.Id := CreateGuid;
        NpRvSalesLineReference."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLineReference."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLineReference."Sales Line Id" := NpRvSalesLineNew.Id;
        NpRvSalesLineReference.Insert(true);
    end;

    local procedure RemoveReturnVoucher(NpRvSalesLineParent: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Parent Id", NpRvSalesLineParent.Id);
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if NpRvSalesLine.FindSet then
            repeat
                if MagentoPaymentLine.Get(DATABASE::"Sales Header", NpRvSalesLine."Document Type",
                  NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.")
                then
                    MagentoPaymentLine.Delete;

                NpRvSalesLine.Delete(true);
            until NpRvSalesLine.Next = 0;
    end;

    //--- Voucher Interface ---
    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Apply Payment", ModuleCode()) then
            exit;

        VoucherModule.Init;
        VoucherModule.Type := VoucherModule.Type::"Apply Payment";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnHasApplyPaymentSetup', '', true, true)]
    local procedure OnHasApplyPaymentSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        HasApplySetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnSetupApplyPayment', '', true, true)]
    local procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    var
        ReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        if not ReturnVoucherType.Get(VoucherType.Code) then begin
            ReturnVoucherType.Init;
            ReturnVoucherType."Voucher Type" := VoucherType.Code;
            ReturnVoucherType.Insert(true);
        end;

        PAGE.Run(PAGE::"NPR NpRv Ret. Vouch. Card", ReturnVoucherType);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunApplyPayment', '', true, true)]
    local procedure OnRunApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPayment(FrontEnd, POSSession, VoucherType, SaleLinePOSVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151011, 'OnRunApplyPaymentSalesDoc', '', true, true)]
    local procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPaymentSalesDoc(VoucherType, SalesHeader, NpRvSalesLine);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRv Module Pay.: Default");
    end;

    local procedure IsSubscriber(VoucherType: Record "NPR NpRv Voucher Type"): Boolean
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
        SalesPost.GetSalesLines(SalesHeader, SalesLineTemp, 0);
        SalesLineTemp.CalcVATAmountLines(0, SalesHeader, SalesLineTemp, VATAmountLineTemp);
        SalesLineTemp.UpdateVATOnLines(0, SalesHeader, SalesLineTemp, VATAmountLineTemp);
        exit(VATAmountLineTemp.GetTotalAmountInclVAT());
    end;
}