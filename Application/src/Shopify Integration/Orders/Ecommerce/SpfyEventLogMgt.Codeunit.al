#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248621 "NPR Spfy Event Log Mgt."
{
    Access = Internal;
    internal procedure InsertShopifyLog(OrderTkn: JsonToken; PSpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
    begin
        SpfyEventLogEntry.Init();
        SpfyEventLogEntry := PSpfyEventLogEntry;
        if not TryInsertLog(OrderTkn, SpfyEventLogEntry) then
            exit;
        exit(SpfyEventLogEntry.Insert());
    end;

    [TryFunction]
    local procedure TryInsertLog(OrderTkn: JsonToken; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        AlreadyExistsErr: Label 'A log entry for Order ID %1 with status %2 already exists.', Comment = '%1=Order ID, %2=Order Status';
    begin
        SpfyEventLogEntry.Type := SpfyEventLogEntry.Type::"Incoming Sales Order";
        SpfyEventLogEntry."Entry No." := 0;
        SpfyEventLogEntry."Shopify ID" := OrderMgt.GetNumericId(JsonHelper.GetJText(OrderTkn, 'id', true));
        SpfyEventLogEntry."Event Date-Time" := JsonHelper.GetJDT(OrderTkn, 'createdAt', true);
        SpfyEventLogEntry."Document Name" := CopyStr(JsonHelper.GetJText(OrderTkn, 'name', false), 1, MaxStrLen(SpfyEventLogEntry."Document Name"));
        SpfyEventLogEntry."Bucket Id" := Random(100);
        SetCurrencyCode(OrderTkn, SpfyEventLogEntry);
        SetDates(SpfyEventLogEntry, SpfyEventLogEntry."Document Status", OrderTkn);
        If LogEntryExist(SpfyEventLogEntry."Shopify ID", SpfyEventLogEntry."Document Status", SpfyEventLogEntry."Store Code") then
            Error(AlreadyExistsErr, SpfyEventLogEntry."Shopify ID", SpfyEventLogEntry."Document Status");
    end;

    internal procedure LogEntryExist(OrderId: Text; OrderStatus: enum "NPR SpfyAPIDocumentStatus"; StoreCode: code[20]): Boolean
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
    begin
        LogEntry.SetCurrentKey("Type", "Store Code", "Shopify ID", "Document Status", "Document Type");
        LogEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        LogEntry.SetRange(Type, LogEntry.Type::"Incoming Sales Order");
        LogEntry.SetRange("Store Code", StoreCode);
        LogEntry.SetRange("Shopify ID", OrderId);
        LogEntry.SetRange("Document Type", LogEntry."Document Type"::Order);
        LogEntry.SetFilter("Document Status", '%1|%2', OrderStatus, OrderStatus::" ");
        exit(LogEntry.FindFirst());
    end;

    local procedure SetDates(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; OrderStatus: enum "NPR SpfyAPIDocumentStatus"; OrderToken: JsonToken)
    begin
        case true of
            OrderStatus = OrderStatus::Closed:
                SpfyEventLogEntry."Closed Date-Time" := JsonHelper.GetJDT(OrderToken, 'closedAt', true);
            OrderStatus = OrderStatus::Cancelled:
                SpfyEventLogEntry."Cancelled Date" := DT2Date(JsonHelper.GetJDT(OrderToken, 'cancelledAt', true));
        end;
    end;

    local procedure SetCurrencyCode(Order: JsonToken; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        PresentmentCurrencyCodeIsLCY: Boolean;
        StoreCurrencyCodeIsLCY: Boolean;
        CurrencyFactor: Decimal;
    begin
        SpfyEventLogEntry."Amount (PCY)" := JsonHelper.GetJDecimal(Order, 'currentTotalPriceSet.presentmentMoney.amount', true);
        SpfyEventLogEntry."Presentment Currency Code" := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJCode(Order, 'presentmentCurrencyCode', false), false, PresentmentCurrencyCodeIsLCY);
        SpfyEventLogEntry."Amount (SCY)" := JsonHelper.GetJDecimal(Order, 'currentTotalPriceSet.shopMoney.amount', true);
        SpfyEventLogEntry."Store Currency Code" := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(JsonHelper.GetJCode(Order, 'currencyCode', false), false, StoreCurrencyCodeIsLCY);

        if StoreCurrencyCodeIsLCY and not PresentmentCurrencyCodeIsLCY and
           (SpfyEventLogEntry."Amount (PCY)" <> 0) and (SpfyEventLogEntry."Amount (SCY)" <> 0)
        then begin
            if SpfyEventLogEntry."Amount (SCY)" = SpfyEventLogEntry."Amount (PCY)" then
                CurrencyFactor := 1
            else
                CurrencyFactor := SpfyEventLogEntry."Amount (PCY)" / SpfyEventLogEntry."Amount (SCY)";
        end;
        if CurrencyFactor = 0 then
            CalculateCurrencyFactor(CurrencyFactor, SpfyEventLogEntry);
        Currency.InitRoundingPrecision();
        case true of
            StoreCurrencyCodeIsLCY:
                SpfyEventLogEntry."Amount (LCY)" := SpfyEventLogEntry."Amount (SCY)";
            PresentmentCurrencyCodeIsLCY:
                SpfyEventLogEntry."Amount (LCY)" := SpfyEventLogEntry."Amount (PCY)";
            else
                SpfyEventLogEntry."Amount (LCY)" :=
                    CurrExchRate.ExchangeAmtFCYToLCY(
                             DT2Date(SpfyEventLogEntry."Event Date-Time"), SpfyEventLogEntry."Presentment Currency Code", SpfyEventLogEntry."Amount (PCY)", CurrencyFactor);

        end;
        SpfyEventLogEntry."Amount (LCY)" := Round(SpfyEventLogEntry."Amount (LCY)", Currency."Amount Rounding Precision");
    end;

    internal procedure CalculateCurrencyFactor(var CurrencyFactor: Decimal; SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyDate: Date;
        PostingDate: Date;
    begin
        PostingDate := DT2Date(SpfyEventLogEntry."Event Date-Time");
        if PostingDate <> 0D then
            CurrencyDate := PostingDate
        else
            CurrencyDate := WorkDate();

        CurrencyFactor := CurrExchRate.ExchangeRate(CurrencyDate, SpfyEventLogEntry."Presentment Currency Code");
    end;

    internal procedure UpdateProcessing(Success: Boolean; InputTxt: text; var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    begin
        case true of
            SpfyEventLogEntry.Postponed:
                begin
                    SpfyEventLogEntry."Last Error Date" := Today;
                    SpfyEventLogEntry."Process Retry Count" += 1;
                    if MaxRetryLimitReached(SpfyEventLogEntry) then
                        SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Error
                    else
                        SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Postponed;
                end;
            Success:
                begin
                    SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Processed;
                    SpfyEventLogEntry."Last Error Date" := 0D;
                    SpfyEventLogEntry."Last Error Message" := '';
                end;
            not Success:
                begin
                    SpfyEventLogEntry."Processing Status" := SpfyEventLogEntry."Processing Status"::Error;
                    SpfyEventLogEntry."Last Error Date" := Today;
                    SpfyEventLogEntry."Last Error Message" := CopyStr(InputTxt, 1, MaxStrLen(SpfyEventLogEntry."Last Error Message"));
                    SpfyEventLogEntry."Process Retry Count" += 1;
                end;
        end;
    end;

    internal procedure GetLogEntryStatusStyle(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") StyleText: Text
    begin
        Case SpfyEventLogEntry."Processing Status" of
            SpfyEventLogEntry."Processing Status"::Error:
                StyleText := 'Unfavorable';
            SpfyEventLogEntry."Processing Status"::Processed:
                StyleText := 'Favorable';
            SpfyEventLogEntry."Processing Status"::Postponed:
                StyleText := 'Attention';
        End;
    end;

    internal procedure GetLogEntryErrorInformationStyle(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") StyleText: Text
    begin
        Case SpfyEventLogEntry."Processing Status" of
            SpfyEventLogEntry."Processing Status"::Error:
                StyleText := 'Unfavorable';
        End;
    end;

    internal procedure GetMaxRetryStyleText(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry") StyleText: Text
    begin
        if MaxRetryLimitReached(SpfyEventLogEntry) then
            StyleText := 'Unfavorable';
    end;

    internal procedure MaxRetryLimitReached(SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyEventLogEntry."Process Retry Count" >= SpfyIntegrationMgt.GetMaxDocRetryCount());
    end;

    internal procedure GetEcommerceErrorStyleText(EcommerceErrorText: Text) StyleText: Text
    begin
        if EcommerceErrorText <> '' then
            StyleText := 'Unfavorable'
        else
            StyleText := 'Standard';
    end;

    internal procedure GetOrderData(Rec: Record "NPR Spfy Event Log Entry"): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        Rec.CalcFields("Order Data");
        if not Rec."Order Data".HasValue then
            exit('');
        Rec."Order Data".CreateInStream(InStr, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, TypeHelper.LFSeparator()));
    end;

    internal procedure MarkEntryCreatedOutSideEcommerceFlow(var LogEntry: Record "NPR Spfy Event Log Entry"; OrderTkn: JsonToken)
    var
        LogEntryCreatedOutSideLbl: Label 'Log Entry is created outside Ecommerce flow.';
    begin
        LogEntry."Document Name" := CopyStr(JsonHelper.GetJText(OrderTkn, 'name', false), 1, MaxStrLen(LogEntry."Document Name"));
        LogEntry."Processing Status" := LogEntry."Processing Status"::Processed;
        LogEntry."Last Error Message" := LogEntryCreatedOutSideLbl;
    end;

    var
        JsonHelper: Codeunit "NPR Json Helper";
}

#endif