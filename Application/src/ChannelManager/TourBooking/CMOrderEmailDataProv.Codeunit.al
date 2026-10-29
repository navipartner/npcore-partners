codeunit 6151583 "NPR CMOrderEmailDataProv" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        NotifEntry: Record "NPR Digital Notification Entry";
        Order: Record "NPR CMOrder";
        OrderLine: Record "NPR CMOrderLine";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Distribution: Codeunit "NPR CMOrderDistribution";
        TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        JObject: JsonObject;
        JLines: JsonArray;
        WalletCount: Integer;
        AmountExclVat: Decimal;
        AmountInclVat: Decimal;
        TotalExclVat: Decimal;
        TotalInclVat: Decimal;
        CurrencyCode: Code[10];
        LineCurrencyCode: Code[10];
    begin
        if (not Distribution.GetNotificationOrder(RecRef, NotifEntry, Order)) then
            exit(JObject);

        Distribution.AddRecipientFields(JObject, NotifEntry);
        JObject.Add('order_number', Order.DocumentNo);
        JObject.Add('customer_reference', Order.SellToOrderReference);
        JObject.Add('customer_no', Order.SellToCustomerNo);
        JObject.Add('document_date', Distribution.FormatVisitDate(DT2Date(Order.ReceivedAt)));

        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        if (OrderLine.FindSet()) then
            repeat
                TourBookingMgt.GetLineTotals(OrderLine, WalletCount, AmountExclVat, AmountInclVat, LineCurrencyCode);
                if (LineCurrencyCode <> '') then
                    CurrencyCode := LineCurrencyCode;
                TotalExclVat += AmountExclVat;
                TotalInclVat += AmountInclVat;
                JLines.Add(GetLineJson(OrderLine, NotifEntry."Language Code", WalletCount, AmountExclVat, AmountInclVat));
            until (OrderLine.Next() = 0);

        if (CurrencyCode = '') then begin
            GeneralLedgerSetup.SetLoadFields("LCY Code");
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        JObject.Add('currency_code', CurrencyCode);
        JObject.Add('total_amount_excl_vat', TotalExclVat);
        JObject.Add('total_amount_excl_vat_formatted', Distribution.FormatAmount(TotalExclVat));
        JObject.Add('total_amount_incl_vat', TotalInclVat);
        JObject.Add('total_amount_incl_vat_formatted', Distribution.FormatAmount(TotalInclVat));
        JObject.Add('document_lines', JLines);
        exit(JObject);
    end;

    local procedure GetLineJson(var OrderLine: Record "NPR CMOrderLine"; LanguageCode: Code[10]; WalletCount: Integer; AmountExclVat: Decimal; AmountInclVat: Decimal) JLine: JsonObject
    var
        Distribution: Codeunit "NPR CMOrderDistribution";
        UnitPriceInclVat: Decimal;
        VatPct: Decimal;
    begin
        if (WalletCount <> 0) then
            UnitPriceInclVat := AmountInclVat / WalletCount;
        if (AmountExclVat <> 0) then
            VatPct := Round((AmountInclVat / AmountExclVat - 1) * 100, 0.01);

        JLine.Add('line_no', OrderLine.LineNo);
        JLine.Add('no', OrderLine.ItemNo);
        JLine.Add('description', Distribution.GetItemDescription(OrderLine.ItemNo, LanguageCode));
        JLine.Add('visit_date', Distribution.FormatVisitDate(OrderLine.VisitDate));
        JLine.Add('visit_time', Distribution.FormatVisitTime(OrderLine.VisitTime));
        JLine.Add('quantity', WalletCount);
        JLine.Add('unit_price_incl_vat', UnitPriceInclVat);
        JLine.Add('unit_price_incl_vat_formatted', Distribution.FormatAmount(UnitPriceInclVat));
        JLine.Add('line_amount_excl_vat', AmountExclVat);
        JLine.Add('line_amount_excl_vat_formatted', Distribution.FormatAmount(AmountExclVat));
        JLine.Add('line_amount_incl_vat', AmountInclVat);
        JLine.Add('line_amount_incl_vat_formatted', Distribution.FormatAmount(AmountInclVat));
        JLine.Add('vat_pct', VatPct);
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject: JsonObject;
        JLines: JsonArray;
        JLine: JsonObject;
    begin
        JObject.Add('recipient_email', 'groups@example-hotel.com');
        JObject.Add('recipient_name', 'Example Hotel');
        JObject.Add('language_code', 'ENU');
        JObject.Add('notification_type', 'Order Confirmation');
        JObject.Add('order_number', 'TB-000123');
        JObject.Add('customer_reference', 'PO-4711');
        JObject.Add('customer_no', 'C00010');
        JObject.Add('document_date', '2026-10-19');

        JLine.Add('line_no', 10000);
        JLine.Add('no', 'PACKAGE-DAY');
        JLine.Add('description', 'Day package');
        JLine.Add('visit_date', '2026-11-04');
        JLine.Add('visit_time', '12:00');
        JLine.Add('quantity', 4);
        JLine.Add('unit_price_incl_vat', 250);
        JLine.Add('unit_price_incl_vat_formatted', Format(250, 0, '<Precision,2><Standard Format,2>'));
        JLine.Add('line_amount_excl_vat', 800);
        JLine.Add('line_amount_excl_vat_formatted', Format(800, 0, '<Precision,2><Standard Format,2>'));
        JLine.Add('line_amount_incl_vat', 1000);
        JLine.Add('line_amount_incl_vat_formatted', Format(1000, 0, '<Precision,2><Standard Format,2>'));
        JLine.Add('vat_pct', 25);
        JLines.Add(JLine);

        JObject.Add('currency_code', 'DKK');
        JObject.Add('total_amount_excl_vat', 800);
        JObject.Add('total_amount_excl_vat_formatted', Format(800, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('total_amount_incl_vat', 1000);
        JObject.Add('total_amount_incl_vat_formatted', Format(1000, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('document_lines', JLines);
        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
    end;
}
