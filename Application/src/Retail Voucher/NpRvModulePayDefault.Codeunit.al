codeunit 6151017 "NPR NpRv Module Pay.: Default"
{
    Access = Internal;

    var
        Text000: Label 'Apply Payment - Default (Full Payment)';

    [Obsolete('Delete when final v1/v2 workflow is gone', '2023-06-28')]
    procedure ApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean)
    var
        POSAction: Record "NPR POS Action";
        ReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        ReturnPOSActionMgt: Codeunit "NPR NpRv Ret. POSAction Mgt.";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if Subtotal >= 0 then begin
            if EndSale then
                DoEndSale(POSSession, VoucherType);
            exit;
        end;

        ReturnVoucherType.Get(VoucherType.Code);
        if not CheckReturnVoucherType(ReturnVoucherType, SaleAmount, PaidAmount) then
            exit;

        if not POSSession.RetrieveSessionAction(ReturnPOSActionMgt.ActionCode(), POSAction) then
            POSAction.Get(ReturnPOSActionMgt.ActionCode());
        POSAction.SetWorkflowInvocationParameter('VoucherTypeCode', ReturnVoucherType."Return Voucher Type", FrontEnd);
        POSAction.SetWorkflowInvocationParameter('EndSale', EndSale, FrontEnd);
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure DoEndSale(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"): Boolean
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSetup: Codeunit "NPR POS Setup";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        POSSession.GetSetup(POSSetup);
        if Abs(Subtotal) > Abs(POSSetup.AmountRoundingPrecision()) then
            exit(false);

        if not POSPaymentMethod.Get(VoucherType."Payment Type") then
            exit(false);
        if not ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code") then
            exit(false);
        if POSPaymentLine.CalculateRemainingPaymentSuggestion(SaleAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, false) <> 0 then
            exit(false);

        exit(true);
    end;

    procedure ApplyPaymentSalesDoc(NpRvVoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        MagentoPaymentLineNew: Record "NPR Magento Payment Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherTypeNew: Record "NPR NpRv Voucher Type";
        NpRvSalesLineNew: Record "NPR NpRv Sales Line";
        NpRvReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        TempNpRvVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        PmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        AvailableAmount: Decimal;
        ReturnAmount: Decimal;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        TotalReturnAmount: Decimal;
        TotalSalesAmount: Decimal;
        TotalPaidAmount: Decimal;
        LineNo: Integer;
        ReturnLineExists: Boolean;
        HasPOSPaymentMethodItemFilter: Boolean;
    begin
        NpRvSalesLine.Get(NpRvSalesLine.Id);
        NpRvSalesLine.TestField("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        MagentoPaymentLine.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", NpRvSalesLine."Document Line No.");
        NpRvVoucher.Get(NpRvSalesLine."Voucher No.");

        if NpRvVoucherMgt.ValidateAmount(NpRvVoucher, MagentoPaymentLine.SystemId, MagentoPaymentLine.Amount, AvailableAmount) then begin
            MagentoPaymentLine.Amount := AvailableAmount;
            MagentoPaymentLine.Modify(true);

            NpRvSalesLine.Amount := MagentoPaymentLine.Amount;
            NpRvSalesLine.Modify();
        end;

        SalesHeader.CalcFields("NPR Magento Payment Amount");
        TotalSalesAmount := GetTotalAmtInclVat(SalesHeader);
        TotalPaidAmount := SalesHeader."NPR Magento Payment Amount";
        TotalReturnAmount := TotalPaidAmount - TotalSalesAmount;

        HasPOSPaymentMethodItemFilter := PmtMethodItemMgt.HasPOSPaymentMethodItemFilter(NpRvVoucherType."Payment Type");
        if HasPOSPaymentMethodItemFilter then begin
            SalesAmount := NpRvSalesDocMgt.CalcSalesOrderPaymentMethodItemSalesAmount(SalesHeader, NpRvVoucherType."Payment Type");
            PaidAmount := NpRvSalesDocMgt.CalcSalesOrderPaymentMethodItemPaymentAmount(SalesHeader, NpRvVoucherType.Code, NpRvVoucherType."Payment Type");
            ReturnAmount := PaidAmount - SalesAmount;
            if ReturnAmount < TotalReturnAmount then
                ReturnAmount := TotalReturnAmount;
        end else
            ReturnAmount := TotalReturnAmount;

        NpRvReturnVoucherType.Get(NpRvVoucherType.Code);
        NpRvReturnVoucherType.TestField("Return Voucher Type");
        NpRvVoucherTypeNew.Get(NpRvReturnVoucherType."Return Voucher Type");

        NpRvSalesLineNew.SetRange("Parent Id", NpRvSalesLine.Id);
        NpRvSalesLineNew.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLineNew.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if NpRvSalesLineNew.FindFirst() then begin
            ReturnLineExists := true;
            MagentoPaymentLineNew.Get(Database::"Sales Header", NpRvSalesLineNew."Document Type",
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

        MagentoPaymentLineNew.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLineNew.SetRange("Document Type", SalesHeader."Document Type");
        MagentoPaymentLineNew.SetRange("Document No.", SalesHeader."No.");
        if MagentoPaymentLineNew.FindLast() then;
        LineNo := MagentoPaymentLineNew."Line No." + 10000;

        MagentoPaymentLineNew.Init();
        MagentoPaymentLineNew."Document Table No." := Database::"Sales Header";
        MagentoPaymentLineNew."Document Type" := SalesHeader."Document Type";
        MagentoPaymentLineNew."Document No." := SalesHeader."No.";
        MagentoPaymentLineNew."Line No." := LineNo;
        MagentoPaymentLineNew."External Reference No." := SalesHeader."NPR External Order No.";
        MagentoPaymentLineNew."Payment Type" := MagentoPaymentLineNew."Payment Type"::Voucher;
        MagentoPaymentLineNew."No." := TempNpRvVoucher."Reference No.";
        MagentoPaymentLineNew."Requested Amount" := -ReturnAmount;
        MagentoPaymentLineNew.Amount := -ReturnAmount;
        MagentoPaymentLineNew."Account Type" := MagentoPaymentLineNew."Account Type"::"G/L Account";
        MagentoPaymentLineNew."Account No." := NpRvVoucherTypeNew."Account No.";
        MagentoPaymentLineNew.Description := TempNpRvVoucher.Description;
        MagentoPaymentLineNew."Source Table No." := Database::"NPR NpRv Voucher";
        MagentoPaymentLineNew."Source No." := TempNpRvVoucher."No.";
        MagentoPaymentLineNew."Posting Date" := SalesHeader."Posting Date";
        MagentoPaymentLineNew.Insert(true);

        NpRvSalesLineNew.Init();
        NpRvSalesLineNew.Id := CreateGuid();
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
        NpRvSalesLineNew.UpdateIsSendViaEmail();
        NpRvSalesLineNew.Insert(true);

        NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLineNew, TempNpRvVoucher);
    end;

    local procedure RemoveReturnVoucher(NpRvSalesLineParent: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Parent Id", NpRvSalesLineParent.Id);
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        if NpRvSalesLine.FindSet() then
            repeat
                if MagentoPaymentLine.Get(Database::"Sales Header", NpRvSalesLine."Document Type",
                  NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.")
                then
                    MagentoPaymentLine.Delete();

                NpRvSalesLine.Delete(true);
            until NpRvSalesLine.Next() = 0;
    end;

    procedure InsertVoucherPaymentReturnSalesDoc(NpRvVoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        MagentoPaymentLineNew: Record "NPR Magento Payment Line";
        NpRvReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
        NpRvSalesLineNew: Record "NPR NpRv Sales Line";
        NpRvVoucherTypeNew: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        TempNpRvVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        ReturnAmount: Decimal;
        LineNo: Integer;
        ReturnLineExists: Boolean;
    begin
        NpRvSalesLine.Find();
        NpRvSalesLine.TestField("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        MagentoPaymentLine.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", NpRvSalesLine."Document Line No.");
        MagentoPaymentLine.Posted := true;
        MagentoPaymentLine.Modify(true);

        if not NpRvReturnVoucherType.Get(NpRvVoucherType.Code) or (NpRvReturnVoucherType."Return Voucher Type" = '') then
            NpRvReturnVoucherType."Return Voucher Type" := NpRvVoucherType.Code;
        NpRvVoucherTypeNew.Get(NpRvReturnVoucherType."Return Voucher Type");

        ReturnAmount := MagentoPaymentLine.Amount;
        NpRvSalesLineNew.SetRange("Parent Id", NpRvSalesLine.Id);
        NpRvSalesLineNew.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLineNew.SetRange(Type, NpRvSalesLine.Type::"New Voucher");
        ReturnLineExists := not NpRvSalesLineNew.IsEmpty();

        if ReturnAmount <= 0 then begin
            if ReturnLineExists then
                RemoveReturnVoucher(NpRvSalesLine);
            exit;
        end;

        if POSPaymentMethod.Get(NpRvVoucherTypeNew."Payment Type") then
            if POSPaymentMethod."Rounding Precision" > 0 then
                ReturnAmount := Round(ReturnAmount, POSPaymentMethod."Rounding Precision");

        if ReturnLineExists then begin
            if MagentoPaymentLineNew.Amount <> ReturnAmount then begin
                MagentoPaymentLineNew.Amount := ReturnAmount;
                MagentoPaymentLineNew.Modify(true);
            end;
            exit;
        end;

        NpRvVoucherMgt.GenerateTempVoucher(NpRvVoucherTypeNew, TempNpRvVoucher);

        MagentoPaymentLineNew.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLineNew.SetRange("Document Type", SalesHeader."Document Type");
        MagentoPaymentLineNew.SetRange("Document No.", SalesHeader."No.");
        if not MagentoPaymentLineNew.FindLast() then
            MagentoPaymentLineNew."Line No." := 0;
        LineNo := MagentoPaymentLineNew."Line No." + 10000;

        MagentoPaymentLineNew.Init();
        MagentoPaymentLineNew."Document Table No." := Database::"Sales Header";
        MagentoPaymentLineNew."Document Type" := SalesHeader."Document Type";
        MagentoPaymentLineNew."Document No." := SalesHeader."No.";
        MagentoPaymentLineNew."Line No." := LineNo;
        MagentoPaymentLineNew."External Reference No." := SalesHeader."NPR External Order No.";
        MagentoPaymentLineNew."Payment Type" := MagentoPaymentLineNew."Payment Type"::Voucher;
        MagentoPaymentLineNew."No." := TempNpRvVoucher."Reference No.";
        MagentoPaymentLineNew.Amount := ReturnAmount;
        MagentoPaymentLineNew."Account Type" := MagentoPaymentLineNew."Account Type"::"G/L Account";
        MagentoPaymentLineNew."Account No." := NpRvVoucherTypeNew."Account No.";
        MagentoPaymentLineNew.Description := TempNpRvVoucher.Description;
        MagentoPaymentLineNew."Source Table No." := Database::"NPR NpRv Voucher";
        MagentoPaymentLineNew."Source No." := TempNpRvVoucher."No.";
        MagentoPaymentLineNew."Posting Date" := SalesHeader."Posting Date";
        MagentoPaymentLineNew.Insert(true);

        NpRvSalesLineNew.Init();
        NpRvSalesLineNew.Id := CreateGuid();
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
        NpRvSalesLineNew.UpdateIsSendViaEmail();
        NpRvSalesLineNew.Insert(true);

        NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLineNew, TempNpRvVoucher);
    end;

    #region V3
    procedure ApplyPayment(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean; var ActionContext: JsonObject)
    var
        ReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
        CurrentPOSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSActIssueReturnVchr: Codeunit "NPR POSAction: Issue Rtrn Vchr";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
        POSAction: Record "NPR POS Action";
        Parameters: JsonObject;
        ActionVersion: Integer;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        CurrentPOSPaymentMethod.Get(VoucherType."Payment Type");
        POSPaymentLine.CalculateBalance(CurrentPOSPaymentMethod, SaleAmount, PaidAmount, ReturnAmount, SubTotal);

        if Subtotal >= 0 then begin
            if EndSale then
                ActionContext.Add('stopEndSaleExecution', not DoEndSale(POSSession, VoucherType));
            exit;
        end;

        ReturnVoucherType.Get(VoucherType.Code);
        if not CheckReturnVoucherType(ReturnVoucherType, SaleAmount, PaidAmount) then
            exit;

        if not POSSession.RetrieveSessionAction(POSActIssueReturnVchr.ActionCode(), POSAction) then
            POSAction.Get(POSActIssueReturnVchr.ActionCode());
        ActionVersion := 3;
        if POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY then
            ActionVersion := 1;

        ActionContext.Add('name', POSAction.Code);
        ActionContext.Add('version', ActionVersion);

        Parameters.Add('VoucherTypeCode', ReturnVoucherType."Return Voucher Type");
        Parameters.Add('EndSale', EndSale);
        ActionContext.Add('parameters', parameters)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPaymentV3', '', true, true)]
    local procedure OnRunApplyPaymentV3(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean; var Handled: Boolean; var ActionContext: JsonObject)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPayment(POSSession, VoucherType, SaleLinePOSVoucher, EndSale, ActionContext);
    end;
    #endregion V3

    local procedure CheckReturnVoucherType(ReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type"; SaleAmount: Decimal; PaidAmount: Decimal): Boolean
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        VoucherType: Record "NPR NpRv Voucher Type";
        ReturnAmount: Decimal;
    begin
        ReturnVoucherType.TestField("Return Voucher Type");
        if VoucherType.Get(ReturnVoucherType."Return Voucher Type") then begin
            VoucherType.TestField("Payment Type");
            if POSPaymentMethod.Get(VoucherType."Payment Type") then begin
                ReturnAmount := SaleAmount - PaidAmount;
                if POSPaymentMethod."Rounding Precision" > 0 then
                    ReturnAmount := Round(SaleAmount - PaidAmount, POSPaymentMethod."Rounding Precision");
                if (POSPaymentMethod."Minimum Amount" > 0) and (Abs(ReturnAmount) < (POSPaymentMethod."Minimum Amount")) then
                    exit;
                if (VoucherType."Minimum Amount Issue" > 0) and (Abs(ReturnAmount) < VoucherType."Minimum Amount Issue") then
                    exit;
            end;
        end;
        exit(true);
    end;

    //--- Voucher Interface ---
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnInitVoucherModules', '', true, true)]
    local procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
        if VoucherModule.Get(VoucherModule.Type::"Apply Payment", ModuleCode()) then
            exit;

        VoucherModule.Init();
        VoucherModule.Type := VoucherModule.Type::"Apply Payment";
        VoucherModule.Code := ModuleCode();
        VoucherModule.Description := Text000;
        VoucherModule."Event Codeunit ID" := CurrCodeunitId();
        VoucherModule.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnHasApplyPaymentSetup', '', true, true)]
    local procedure OnHasApplyPaymentSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasApplySetup: Boolean)
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        HasApplySetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnSetupApplyPayment', '', true, true)]
    local procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    var
        ReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
    begin
        if not IsSubscriber(VoucherType) then
            exit;

        if not ReturnVoucherType.Get(VoucherType.Code) then begin
            ReturnVoucherType.Init();
            ReturnVoucherType."Voucher Type" := VoucherType.Code;
            ReturnVoucherType.Insert(true);
        end;

        PAGE.Run(PAGE::"NPR NpRv Ret. Vouch. Card", ReturnVoucherType);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPayment', '', true, true)]
    local procedure OnRunApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPayment(FrontEnd, POSSession, VoucherType, SaleLinePOSVoucher, EndSale);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPaymentSalesDoc', '', true, true)]
    local procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        ApplyPaymentSalesDoc(VoucherType, SalesHeader, NpRvSalesLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpRv Voucher Module", 'OnAfterValidateEvent', 'Ask For Amount', true, true)]
    local procedure OnAfterValidateAskForAmount(var Rec: Record "NPR NpRv Voucher Module")
    begin
        if Rec.Code <> ModuleCode() then
            exit;

        Rec.TestField("Ask For Amount", false);
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
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 0);
        TempSalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
        exit(TempVATAmountLine.GetTotalAmountInclVAT());
    end;
}
