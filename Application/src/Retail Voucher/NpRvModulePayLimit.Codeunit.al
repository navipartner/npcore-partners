codeunit 6151034 "NPR NpRv Module Pay.: Limit"
{
    Access = Internal;

    var
        Text000: Label 'Apply Payment - Limit';

    local procedure DoEndSale(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"): Boolean
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
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

    #region V3
    procedure ApplyPayment(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean; var ActionContext: JsonObject)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSaleLine: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
        VoucherAmtErr: Label 'The Voucher value %1 is higher than the Amount to be paid %2.', Comment = '%1 = Voucher.Amount;%2=Sale Amount';
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentMethod.Get(VoucherType."Payment Type");
        POSPaymentLine.CalculateBalance(POSPaymentMethod, SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        POSPaymentLine.GetCurrentPaymentLine(POSSaleLine);

        case true of
            Subtotal < 0:
                begin
                    CancelGlobalReservation(SaleLinePOSVoucher);
                    Error(VoucherAmtErr, Format(POSSaleLine."Amount Including VAT"), Format((POSSaleLine."Amount Including VAT" + Subtotal)));
                end;
            Subtotal = 0:
                if EndSale then
                    ActionContext.Add('stopEndSaleExecution', not DoEndSale(POSSession, VoucherType))
        end;

    end;

    [Obsolete('Delete when final v1/v2 workflow is gone', '2023-06-28')]
    procedure ApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSaleLine: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
        VoucherAmtErr2: Label 'The Voucher value %1 is higher than the Amount to be paid %2.', Comment = '%1 = Voucher.Amount;%2=Sale Amount';
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentMethod.Get(VoucherType."Payment Type");
        POSPaymentLine.CalculateBalance(POSPaymentMethod, SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        POSPaymentLine.GetCurrentPaymentLine(POSSaleLine);
        case true of
            Subtotal < 0:
                Error(VoucherAmtErr2, Format(POSSaleLine."Amount Including VAT"), Format((POSSaleLine."Amount Including VAT" + Subtotal)));
            Subtotal = 0:
                if EndSale then
                    DoEndSale(POSSession, VoucherType);
        end;
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

        HasApplySetup := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnSetupApplyPayment', '', true, true)]
    local procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
        if not IsSubscriber(VoucherType) then
            exit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", 'OnRunApplyPaymentSalesDoc', '', true, true)]
    local procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if not IsSubscriber(VoucherType) then
            exit;

        Handled := true;

        NotSupportedError(VoucherType.Code);
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
        exit(Codeunit::"NPR NpRv Module Pay.: LIMIT");
    end;

    local procedure IsSubscriber(VoucherType: Record "NPR NpRv Voucher Type"): Boolean
    begin
        exit(VoucherType."Apply Payment Module" = ModuleCode());
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('LIMIT');
    end;

    local procedure NotSupportedError(VoucherType: Code[20])
    var
        NotSupportedErr: Label 'Voucher Type %1 doesnot support this bussiness process.';
    begin
        Error(NotSupportedErr, VoucherType);
    end;

    local procedure CancelGlobalReservation(NpRvSaleLinePOSVoucher: Record "NPR NpRv Sales Line")
    var
        NpRvModuleValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        if not IsNullGuid(NpRvSaleLinePOSVoucher."Reservation Line Id") then
            NpRvModuleValidGlobal.TryCancelReservation(NpRvSaleLinePOSVoucher);
    end;
}
