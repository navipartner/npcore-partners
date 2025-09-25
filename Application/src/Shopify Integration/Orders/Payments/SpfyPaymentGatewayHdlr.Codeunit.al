#if not BC17
codeunit 6184821 "NPR Spfy Payment Gateway Hdlr" implements "NPR IPaymentGateway"
{
    Access = Internal;

    var
        _GLSetup: Record "General Ledger Setup";
        _GLSetupRetrieved: Boolean;

    procedure Capture(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        Success: Boolean;
    begin
        InitNcTaskFromPmtRequest(Request, TempNcTask);
        if not CheckPrerequisites(TempNcTask, Response) then
            exit;
        Success := SpfyCapturePayment.CaptureShopifyPayment(TempNcTask, false);
        SetResponse(TempNcTask, Response, Success);
    end;

    procedure Refund(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        TempNcTask: Record "NPR Nc Task" temporary;
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        Success: Boolean;
    begin
        InitNcTaskFromPmtRequest(Request, TempNcTask);
        Success := SpfyCapturePayment.RefundShopifyPayment(TempNcTask, false);
        SetResponse(TempNcTask, Response, Success);
    end;

    procedure Cancel(var Request: Record "NPR PG Payment Request"; var Response: Record "NPR PG Payment Response")
    var
        NotSupportedMsg: Label 'Cancellation requests are not supported for Shopify payments. Please try to cancel the payment directly with Shopify.';
    begin
        Message(NotSupportedMsg);
    end;

    procedure RunSetupCard(PaymentGatewayCode: Code[10])
    var
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
    begin
        if not SpfyPaymentGateway.Get(PaymentGatewayCode) then begin
            SpfyPaymentGateway.Init();
            SpfyPaymentGateway.Code := PaymentGatewayCode;
            SpfyPaymentGateway.Insert(true);
            Commit();
        end;

        Page.Run(Page::"NPR Spfy Payment Gateway Card", SpfyPaymentGateway);
    end;

    local procedure InitNcTaskFromPmtRequest(Request: Record "NPR PG Payment Request"; var NcTask: Record "NPR Nc Task")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if IsNullGuid(Request."Document System Id") or IsNullGuid(Request."Payment Line System Id") then
            Error('');  //usupported request

        Clear(NcTask);
        case Request."Document Table No." of
            Database::"Sales Header":
                begin
                    if not SalesHeader.GetBySystemId(Request."Document System Id") then
                        Error('');  //doc not found
                    NcTask."Record ID" := SalesHeader.RecordId();
                end;
            Database::"Sales Invoice Header":
                begin
                    SalesInvHeader.GetBySystemId(Request."Document System Id");
                    NcTask."Record ID" := SalesInvHeader.RecordId();
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.GetBySystemId(Request."Document System Id");
                    NcTask."Record ID" := SalesCrMemoHeader.RecordId();
                end;
            else
                Error('');  //usupported request
        end;

        PaymentLine.GetBySystemId(Request."Payment Line System Id");
        NcTask."Store Code" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));
        NcTask."Record Value" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Entry ID"), 1, MaxStrLen(NcTask."Record Value"));
        NcTask."Table No." := Database::"NPR Magento Payment Line";
        NcTask."Record ID" := PaymentLine.RecordId();
    end;

    local procedure CheckPrerequisites(NcTask: Record "NPR Nc Task"; var Response: Record "NPR PG Payment Response"): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        IntegrationNotEnabledMsg: Label 'Either sending capture requests is disabled, or Shopify integration is not enabled for store %1.';
    begin
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Payment Capture Requests", NcTask."Store Code") then begin
            SetResponse(StrSubstNo(IntegrationNotEnabledMsg, NcTask."Store Code"), Response, false);
            if UpdateLastErrorText(StrSubstNo(IntegrationNotEnabledMsg, NcTask."Store Code")) then;
            exit;
        end;
        exit(true);
    end;

    [TryFunction]
    local procedure UpdateLastErrorText(ErrorMsg: Text)
    begin
        Error(ErrorMsg);
    end;

    local procedure SetResponse(var NcTask: Record "NPR Nc Task"; var Response: Record "NPR PG Payment Response"; Success: Boolean)
    begin
        Response."Response Success" := Success;
        Response."Response Body" := NcTask.Response;
    end;

    local procedure SetResponse(ResponseMsg: Text; var Response: Record "NPR PG Payment Response"; Success: Boolean)
    var
        OStream: OutStream;
    begin
        Response."Response Success" := Success;
        Response."Response Body".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(ResponseMsg);
    end;

#if not (BC18 or BC19 or BC20 or BC21 or BC22)
    internal procedure RegisterBillingEvents(var PaymentLine: Record "NPR Magento Payment Line")
    var
        EventBillingClient: Codeunit "NPR Event Billing Client";
        MetadataJson: JsonObject;
    begin
        if not IsShopifyPaymentLine(PaymentLine.RecordId()) then
            exit;

        MetadataJson.Add('shopify_store_code', GetShopifyStoreCode(PaymentLine));
        MetadataJson.Add('currency', PaymentLine.TransactionCurrencyCode(false));
        EventBillingClient.RegisterEvent(
            PaymentLine.SystemId, Enum::"NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_PRESENTMENT, PaymentLine.Amount, MetadataJson.AsToken());

        if PaymentLine."Amount (Store Currency)" <> 0 then begin
            MetadataJson.Replace('currency', PaymentLine."Store Currency Code");
            PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id" := CreateGuid();
            EventBillingClient.RegisterEvent(
                PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", Enum::"NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_SHOP, PaymentLine."Amount (Store Currency)", MetadataJson.AsToken());
        end;
    end;

    local procedure IsShopifyPaymentLine(PaymentLineRecID: RecordId): Boolean
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        exit(SpfyAssignedIDMgt.GetAssignedShopifyID(PaymentLineRecID, "NPR Spfy ID Type"::"Entry ID") <> '');
    end;

    local procedure GetShopifyStoreCode(PaymentLine: Record "NPR Magento Payment Line"): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyStoreCode: Text;
    begin
        case PaymentLine."Document Table No." of
            Database::"Sales Header":
                begin
                    SalesHeader."Document Type" := PaymentLine."Document Type";
                    SalesHeader."No." := PaymentLine."Document No.";
                    ShopifyStoreCode := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
                end;
            Database::"Sales Invoice Header":
                begin
                    SalesInvHeader."No." := PaymentLine."Document No.";
                    ShopifyStoreCode := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesInvHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader."No." := PaymentLine."Document No.";
                    ShopifyStoreCode := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Store Code");
                end;
        end;
        exit(CopyStr(ShopifyStoreCode, 1, 20));
    end;
#endif

    internal procedure TranslateCurrencyCode(ShopifyCurrencyCode: Text): Code[10]
    var
        IsLCY: Boolean;
    begin
        exit(TranslateCurrencyCode(ShopifyCurrencyCode, false, IsLCY));
    end;

    internal procedure TranslateCurrencyCode(ShopifyCurrencyCode: Text; BlankIfLCY: Boolean; var IsLCY: Boolean): Code[10]
    var
        Currency: Record Currency;
    begin
        GetGLSetup();
        if ShopifyCurrencyCode = '' then
            Currency.Code := _GLSetup."LCY Code"
        else begin
            ShopifyCurrencyCode := ShopifyCurrencyCode.ToUpper();
            Currency.SetLoadFields(Code);
            Currency.SetRange("ISO Code", CopyStr(ShopifyCurrencyCode, 1, MaxStrLen(Currency."ISO Code")));
            if not Currency.FindFirst() then
                if not Currency.Get(CopyStr(ShopifyCurrencyCode, 1, MaxStrLen(Currency.Code))) then begin
                    if CopyStr(ShopifyCurrencyCode, 1, MaxStrLen(_GLSetup."LCY Code")) = _GLSetup."LCY Code" then
                        Currency.Code := _GLSetup."LCY Code"
                    else
                        Currency.FindFirst();  //raise error
                end;
        end;
        IsLCY := Currency.Code = _GLSetup."LCY Code";
        if IsLCY and BlankIfLCY then
            exit('');
        exit(Currency.Code);
    end;

    internal procedure CurrencyISOCode(CurrencyCode: Code[10]): Code[3]
    var
        Currency: Record Currency;
    begin
        if CurrencyCode = '' then begin
            GetGLSetup();
            CurrencyCode := _GLSetup."LCY Code";
        end;

        if Currency.Get(CurrencyCode) then
            if Currency."ISO Code" <> '' then
                exit(Currency."ISO Code");

        exit(CopyStr(CurrencyCode, 1, 3));
    end;

    local procedure GetGLSetup()
    begin
        if _GLSetupRetrieved then
            exit;
        _GLSetupRetrieved := true;
        if not _GLSetup.Get() then
            _GLSetup.Init();
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Gateway", 'OnAfterDeleteEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Gateway", OnAfterDeleteEvent, '', false, false)]
#endif
    local procedure RemoveShopifyPaymentGatewaySetup(var Rec: Record "NPR Magento Payment Gateway")
    var
        SpfyPaymentGateway: Record "NPR Spfy Payment Gateway";
    begin
        if Rec.IsTemporary() then
            exit;

        if SpfyPaymentGateway.Get(Rec.Code) then
            SpfyPaymentGateway.Delete(true);
    end;
}
#endif