codeunit 6184663 "NPR Fiskaly API"
{
    Access = Internal;

    var
        _Response: HttpResponseMessage;

    [TryFunction]
    internal procedure TryCallApiPost(var POSEntry: Record "NPR POS Entry"; BearerToken: Text)
    var
        ResponseText: Text;
        ResponseErrorLbl: Label 'Received a bad response from the API.\Status Code: %1 - %2\Body: %3', Comment = '%1 = status code, %2 = reason phrase, %3 = body';
    begin
        ClearLastError();
        Clear(_Response);
        if not TryCallAPIPost(_Response, POSEntry, BearerToken) then
            Error(GetLastErrorText());

        if _Response.IsSuccessStatusCode() then
            exit;

        _Response.Content.ReadAs(ResponseText);
        Error(ResponseErrorLbl, _Response.HttpStatusCode(), _Response.ReasonPhrase(), ResponseText);
    end;

    [TryFunction]
    local procedure TryCallAPIPost(var Response: HttpResponseMessage; var POSEntry: Record "NPR POS Entry"; BearerToken: Text)
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: Text;
        Url: Text;
        ReceiptId: Code[20];
    begin
        ReceiptId := POSEntry."Fiscal No.";
        CreatePostReceiptBodyAsJsonObject(POSEntry, ReceiptId).WriteTo(Request);
        Content.WriteFrom(Request);

        Content.GetHeaders(ContentHeaders);
        if (ContentHeaders.Contains('Content-Type')) then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + BearerToken);
        Url := StrSubstNo(GetBaseUrlGetPostReceipt(), CreateGuid());
        Client.Put(Url, Content, Response);
    end;


    [TryFunction]
    internal procedure TryCallApiAuth(var BearerTokenValue: Text; var ExpiresAt: DateTime)
    var
        ResponseText: Text;
        ResponseErrorLbl: Label 'Received a bad response from the API.\Status Code: %1 - %2\Body: %3', Comment = '%1 = status code, %2 = reason phrase, %3 = body';
    begin
        ClearLastError();
        Clear(_Response);
        if not TryCallAPIAuth(_Response) then
            Error(GetLastErrorText());

        if _Response.IsSuccessStatusCode() then begin
            ExtractBearerToken(_Response, BearerTokenValue, ExpiresAt);
            exit;
        end;

        _Response.Content.ReadAs(ResponseText);
        Error(ResponseErrorLbl, _Response.HttpStatusCode(), _Response.ReasonPhrase(), ResponseText);
    end;

    [TryFunction]
    local procedure TryCallAPIAuth(var Response: HttpResponseMessage)
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: Text;
        Url: Text;
    begin
        CreateAuthBodyAsJsonObject().WriteTo(Request);
        Content.WriteFrom(Request);

        Content.GetHeaders(ContentHeaders);
        if (ContentHeaders.Contains('Content-Type')) then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Url := GetBaseUrlAuth();
        Client.Post(Url, Content, Response);
    end;

    local procedure ExtractBearerToken(Response: HttpResponseMessage; var BearerTokenValue: Text; var ExpiresAt: DateTime)
    var
        JsonManagement: Codeunit "JSON Management";
        TypeHelper: Codeunit "Type Helper";
        ResponseMessageContent: Text;
        AccessTokenExpiresAtUnix: BigInteger;
        AccessTokenExpiresAtVariant: Variant;
    begin
        Response.Content().ReadAs(ResponseMessageContent);
        if not Response.IsSuccessStatusCode() then
            exit;
        JsonManagement.InitializeObject(ResponseMessageContent);
        if JsonManagement.GetStringPropertyValueByName('access_token', BearerTokenValue) then;
        if JsonManagement.GetPropertyValueByName('access_token_expires_at', AccessTokenExpiresAtVariant) then begin
            AccessTokenExpiresAtUnix := AccessTokenExpiresAtVariant;
            ExpiresAt := TypeHelper.EvaluateUnixTimestamp(AccessTokenExpiresAtUnix);
        end;
    end;

    local procedure CreateAuthBodyAsJsonObject() AuthBodyJsonObject: JsonObject;
    var
        DigitalReceiptSetup: Record "NPR Digital Receipt Setup";
    begin
        DigitalReceiptSetup.FindFirst();
        DigitalReceiptSetup.TestField("Api Key");
        DigitalReceiptSetup.TestField("Api Secret");

        AuthBodyJsonObject.Add('api_key', DigitalReceiptSetup."Api Key");
        AuthBodyJsonObject.Add('api_secret', DigitalReceiptSetup."Api Secret");
    end;

    local procedure CreatePostReceiptBodyAsJsonObject(var POSEntry: Record "NPR POS Entry"; ReceiptId: Code[20]) CompleteBodyJsonObject: JsonObject;
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        GeneraLedgerSetup: Record "General Ledger Setup";
        LanguageMgt: Codeunit Language;
        TotalPOSPaymentAmount: Decimal;
        TotalDiscountValue: Decimal;
        LinesJsonArray: JsonArray;
        PaymentTypeJsonArray: JsonArray;
        SchemaJsonObject: JsonObject;
        SubSchemaJsonObject: JsonObject;
        DataJsonObject: JsonObject;
        HeadJsonObject: JsonObject;
        MiscJsonObject: JsonObject;
    begin
        TotalDiscountValue := 0;
        TotalPOSPaymentAmount := 0;
        Clear(SchemaJsonObject);
        Clear(SubSchemaJsonObject);
        Clear(PaymentTypeJsonArray);
        Clear(DataJsonObject);
        Clear(HeadJsonObject);
        Clear(MiscJsonObject);

        GeneraLedgerSetup.SetLoadFields("LCY Code");
        GeneraLedgerSetup.Get();
        DataJsonObject.Add('currency', GeneraLedgerSetup."LCY Code");
        DataJsonObject.Add('full_amount_incl_vat', Format(POSEntry."Amount Incl. Tax & Round", 0, '<Precision,2:2><Standard Format,2>'));

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetLoadFields("No.", Description, "Description 2", "VAT %", "Amount Incl. VAT (LCY)", "Line Amount", "Line Dsc. Amt. Incl. VAT (LCY)", "Unit Price", "Amount Incl. VAT", "Line Discount Amount Incl. VAT", Type, "Amount Excl. VAT", Quantity);
        if not POSEntrySalesLine.FindSet() then
            exit;
        Clear(LinesJsonArray);
        repeat
            CreateReceiptLineJSON(POSEntry, POSEntrySalesLine, TotalDiscountValue, LinesJsonArray);
        until POSEntrySalesLine.Next() = 0;


        CreateReceiptPaymentAmountsJSON(POSEntry, TotalPOSPaymentAmount, DataJsonObject, PaymentTypeJsonArray);

        CreateReceiptVATAmountsJSON(POSEntry, TotalPOSPaymentAmount, TotalDiscountValue, DataJsonObject, LinesJsonArray);

        CreateReceiptBuyerAndSellerInfo(POSEntry, ReceiptId, HeadJsonObject);

        MiscJsonObject.Add('footer_text', 'This receipt was rendered with the help of our partner, fiskaly GmbH');

        SubSchemaJsonObject.Add('custom_elements', CreateCustomElementsJSON());
        SubSchemaJsonObject.Add('data', DataJsonObject);
        SubSchemaJsonObject.Add('head', HeadJsonObject);
        SubSchemaJsonObject.Add('misc', MiscJsonObject);

        case LanguageMgt.GetUserLanguageCode() of
            'FRA':
                SubSchemaJsonObject.Add('language', 'fr');
            'ESP':
                SubSchemaJsonObject.Add('language', 'es');
            'DEU', 'DES', 'DEA':
                SubSchemaJsonObject.Add('language', 'de');
            else
                SubSchemaJsonObject.Add('language', 'en');
        end;

        SchemaJsonObject.Add('ekabs_v0', SubSchemaJsonObject);

        CompleteBodyJsonObject.Add('schema', SchemaJsonObject);
    end;

    local procedure CreateReceiptBuyerAndSellerInfo(POSEntry: Record "NPR POS Entry"; ReceiptId: Code[20]; HeadJsonObject: JsonObject)
    var
        Customer: Record Customer;
        CompanyInfo: Record "Company Information";
        BuyerJsonObject: JsonObject;
        BuyerAddressJsonObject: JsonObject;
        SellerAddressJsonobject: JsonObject;
        SellerJsonObject: JsonObject;
    begin
        Clear(BuyerAddressJsonObject);
        Clear(BuyerJsonObject);
        Clear(SellerAddressJsonobject);
        Clear(SellerJsonObject);

        Customer.SetLoadFields("No.", City, "Post Code", Address, Name, "Tax Area Code");
        if Customer.Get(POSEntry."Customer No.") then;
        BuyerAddressJsonObject.Add('city', Customer.City);
        if StrLen(Customer."Post Code") <= 10 then
            BuyerAddressJsonObject.Add('postal_code', Customer."Post Code");
        BuyerAddressJsonObject.Add('street', Customer.Address);

        BuyerJsonObject.Add('address', BuyerAddressJsonObject);
        BuyerJsonObject.Add('customer_number', Customer."No.");
        BuyerJsonObject.Add('name', Customer.Name);
        BuyerJsonObject.Add('tax_number', Customer."Tax Area Code");

        CompanyInfo.SetLoadFields(Name, City, "Post Code", Address, "VAT Registration No.");
        CompanyInfo.Get();
        SellerAddressJsonobject.Add('city', CompanyInfo.City);
        if StrLen(CompanyInfo."Post Code") <= 10 then
            SellerAddressJsonobject.Add('postal_code', CompanyInfo."Post Code");
        SellerAddressJsonobject.Add('street', CompanyInfo.Address);

        SellerJsonObject.Add('address', SellerAddressJsonobject);
        SellerJsonObject.Add('name', CompanyInfo.Name);
        SellerJsonObject.Add('tax_number', CompanyInfo."VAT Registration No.");

        HeadJsonObject.Add('_id', ReceiptId);
        HeadJsonObject.Add('buyer', BuyerJsonObject);
        HeadJsonObject.Add('date', GetUnixTime(CurrentDateTime()));
        HeadJsonObject.Add('number', POSEntry."Document No.");
        HeadJsonObject.Add('seller', SellerJsonObject);
    end;

    local procedure CreateReceiptVATAmountsJSON(POSEntry: Record "NPR POS Entry"; TotalPOSPaymentAmount: Decimal; TotalDiscountValue: Decimal; DataJsonObject: JsonObject; LinesJsonArray: JsonArray)
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        TotalVatAmountJsonObject: JsonObject;
        DiscountsJsonObject: JsonObject;
        DiscountsJsonArray: JsonArray;
        TotalVatAmountJsonArray: JsonArray;
    begin
        Clear(TotalVatAmountJsonArray);
        Clear(DiscountsJsonObject);
        Clear(DiscountsJsonArray);

        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryTaxLine.SetLoadFields("Tax %", "Amount Including Tax", "Tax Base Amount", "Tax Amount");
        if POSEntryTaxLine.FindSet() then
            repeat
                Clear(TotalVatAmountJsonObject);

                TotalVatAmountJsonObject.Add('percentage', Format(POSEntryTaxLine."Tax %" / 100, 0, '<Precision,2:2><Standard Format,2>'));
                TotalVatAmountJsonObject.Add('incl_vat', Format(POSEntryTaxLine."Amount Including Tax", 0, '<Precision,2:2><Standard Format,2>'));
                TotalVatAmountJsonObject.Add('excl_vat', Format(POSEntryTaxLine."Tax Base Amount", 0, '<Precision,2:2><Standard Format,2>'));
                TotalVatAmountJsonObject.Add('vat', Format(POSEntryTaxLine."Tax Amount", 0, '<Precision,2:2><Standard Format,2>'));
                TotalVatAmountJsonArray.Add(TotalVatAmountJsonObject);
            until POSEntryTaxLine.Next() = 0
        else begin
            Clear(TotalVatAmountJsonObject);

            TotalVatAmountJsonObject.Add('percentage', '0.00');
            TotalVatAmountJsonObject.Add('incl_vat', '0.00');
            TotalVatAmountJsonObject.Add('excl_vat', '0.00');
            TotalVatAmountJsonObject.Add('vat', '0.00');
            TotalVatAmountJsonArray.Add(TotalVatAmountJsonObject);
        end;
        DataJsonObject.Add('lines', LinesJsonArray);
        DataJsonObject.Add('vat_amounts', TotalVatAmountJsonArray);
        if TotalDiscountValue > 0 then begin
            DataJsonObject.Add('total_discount_value', Format(TotalDiscountValue, 0, '<Precision,2:2><Standard Format,2>'));
            DataJsonObject.Add('full_amount_incl_vat_before_discount', Format(TotalDiscountValue + TotalPOSPaymentAmount, 0, '<Precision,2:2><Standard Format,2>'))
        end;
        if TotalDiscountValue < 0 then begin
            DiscountsJsonObject.Add('discount_value', Format(TotalDiscountValue, 0, '<Precision,2:2><Standard Format,2>'));
            DiscountsJsonObject.Add('name', 'Discount');
            DiscountsJsonArray.Add(DiscountsJsonObject);
            DataJsonObject.Add('discounts', DiscountsJsonArray);
        end;
    end;

    local procedure CreateReceiptPaymentAmountsJSON(POSEntry: Record "NPR POS Entry"; var TotalPOSPaymentAmount: Decimal; DataJsonObject: JsonObject; PaymentTypeJsonArray: JsonArray)
    var
        PaymentAmountLine: Record "NPR POS Entry Payment Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PaymentTypeJsonObject: JsonObject;
        PaymentTransactionDetailsObject: JsonObject;
        OtherPaymentLbl: Label 'OTHER', Locked = true;
    begin
        PaymentAmountLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        PaymentAmountLine.SetLoadFields("POS Payment Method Code", "Amount (LCY)", Description, "Currency Code", Amount);
        if PaymentAmountLine.FindSet() then
            repeat
                Clear(PaymentTypeJsonObject);
                Clear(PaymentTransactionDetailsObject);

                POSPaymentMethod.SetLoadFields("Processing Type");
                if POSPaymentMethod.Get(PaymentAmountLine."POS Payment Method Code") then;
                case POSPaymentMethod."Processing Type" of
                    Enum::"NPR Payment Processing Type"::CASH:
                        PaymentTypeJsonObject.Add('name', Format(POSPaymentMethod."Processing Type").ToUpper());
                    Enum::"NPR Payment Processing Type"::EFT:
                        CreateEFTPaymentInformation(POSEntry, PaymentAmountLine, PaymentTypeJsonObject, PaymentTransactionDetailsObject);
                    else
                        PaymentTypeJsonObject.Add('name', OtherPaymentLbl);
                end;
                TotalPOSPaymentAmount += PaymentAmountLine."Amount (LCY)";

                PaymentTypeJsonObject.Add('amount', Format(PaymentAmountLine."Amount (LCY)", 0, '<Precision,2:2><Standard Format,2>'));
                PaymentTypeJsonObject.Add('display_name', PaymentAmountLine.Description);
                if PaymentAmountLine."Currency Code" <> '' then begin
                    PaymentTypeJsonObject.Add('foreign_amount', Format(PaymentAmountLine.Amount, 0, '<Precision,2:2><Standard Format,2>'));
                    PaymentTypeJsonObject.Add('foreign_currency', Format(PaymentAmountLine."Currency Code", 0, '<Precision,2:2><Standard Format,2>'));
                end;

                PaymentTypeJsonArray.Add(PaymentTypeJsonObject);
            until PaymentAmountLine.Next() = 0;

        DataJsonObject.Add('payment_types', PaymentTypeJsonArray);
    end;

    local procedure CreateReceiptLineJSON(POSEntry: Record "NPR POS Entry";
POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var
                                                      TotalDiscountValue: Decimal;
                                                      LinesJsonArray: JsonArray)
    var
        POSUnit: Record "NPR POS Unit";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        LineJsonObject: JsonObject;
        VatAmountJsonObject: JsonObject;
        ItemJsonObject: JsonObject;
        DiscountJsonObject: JsonObject;
        VatAmountsJsonArray: JsonArray;
        DiscountJsonArray: JsonArray;
        LineDiscountLbl: Label 'Line Discount Incl. VAT', Locked = true;
        UnitPrice: Decimal;
        FullAmount: Decimal;
        LineAmount: Decimal;
    begin
        Clear(LineJsonObject);
        Clear(VatAmountsJsonArray);
        Clear(VatAmountJsonObject);
        Clear(DiscountJsonArray);
        Clear(DiscountJsonObject);
        Clear(ItemJsonObject);

        LineJsonObject.Add('text', POSEntrySalesLine.Description);
        if POSEntrySalesLine."Description 2" <> '' then
            LineJsonObject.Add('additional_text', POSEntrySalesLine."Description 2");

        VatAmountJsonObject.Add('percentage', Format(POSEntrySalesLine."VAT %" / 100, 0, '<Precision,2:2><Standard Format,2>'));
        VatAmountJsonObject.Add('incl_vat', Format(POSEntrySalesLine."Amount Incl. VAT (LCY)" - POSEntrySalesLine."Line Amount", 0, '<Precision,2:2><Standard Format,2>'));
        VatAmountsJsonArray.Add(VatAmountJsonObject);

        POSUnit.SetLoadFields("POS Receipt Profile");
        if POSUnit.Get(POSEntry."POS Unit No.") then;
        POSReceiptProfile.SetLoadFields("Receipt Discount Information");
        if POSReceiptProfile.Get(POSUnit."POS Receipt Profile") then;
        case POSReceiptProfile."Receipt Discount Information" of
            POSReceiptProfile."Receipt Discount Information"::"Per Line":
                begin
                    if POSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)" <> 0 then begin
                        DiscountJsonObject.Add('discount_value', Format(POSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)", 0, '<Precision,2:2><Standard Format,2>'));
                        DiscountJsonObject.Add('name', LineDiscountLbl);
                        DiscountJsonArray.Add(DiscountJsonObject);
                        LineJsonObject.Add('discounts', DiscountJsonArray);
                    end;
                    UnitPrice := POSEntrySalesLine."Unit Price";
                    FullAmount := POSEntrySalesLine."Amount Incl. VAT (LCY)";
                end;
            POSReceiptProfile."Receipt Discount Information"::Summary:
                begin
                    TotalDiscountValue += POSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)";
                    UnitPrice := POSEntrySalesLine."Unit Price";
                    FullAmount := POSEntrySalesLine."Amount Incl. VAT" + POSEntrySalesLine."Line Discount Amount Incl. VAT";
                end;
            POSReceiptProfile."Receipt Discount Information"::"No Information":
                begin
                    if POSEntrySalesLine.Type = POSEntrySalesLine.Type::Rounding then
                        UnitPrice := POSEntrySalesLine."Unit Price"
                    else begin
                        if POSEntry."Prices Including VAT" then
                            LineAmount := POSEntrySalesLine."Amount Incl. VAT (LCY)"
                        else
                            LineAmount := POSEntrySalesLine."Amount Excl. VAT";

                        UnitPrice := 0;
                        if POSEntrySalesLine.Quantity <> 0 then
                            UnitPrice := LineAmount / POSEntrySalesLine.Quantity;
                    end;
                    FullAmount := POSEntrySalesLine."Amount Incl. VAT";
                end;
        end;
        ItemJsonObject.Add('price_per_unit', Format(UnitPrice, 0, '<Precision,2:2><Standard Format,2>'));
        ItemJsonObject.Add('full_amount', Format(FullAmount, 0, '<Precision,2:2><Standard Format,2>'));

        ItemJsonObject.Add('number', POSEntrySalesLine."No.");
        ItemJsonObject.Add('quantity', Format(POSEntrySalesLine.Quantity, 0, '<Precision,2:2><Standard Format,2>'));

        LineJsonObject.Add('vat_amounts', VatAmountsJsonArray);
        LineJsonObject.Add('item', ItemJsonObject);

        LinesJsonArray.Add(LineJsonObject);
    end;

    local procedure CreateEFTPaymentInformation(POSEntry: Record "NPR POS Entry"; PaymentAmountLine: Record "NPR POS Entry Payment Line"; PaymentTypeJsonObject: JsonObject; PaymentTransactionDetailsObject: JsonObject)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionRequestCardNameUpperCase: Text;
        EFTTransactionRequestPaymentNetwork: Text;
        EFTTransactionRequestPaymentType: Text;
        MaskedCard: Text;
        CardLbl: Label 'CARD', Locked = true;
        VISALbl: Label 'VISA', Locked = true;
        MasterCardLbl: Label 'MASTERCARD', Locked = true;
        AmexLbl: Label 'AMEX', Locked = true;
        MaestroLbl: Label 'MAESTRO', Locked = true;
        DebitLbl: Label 'DEBIT', Locked = true;
        CreditLbl: Label 'CREDIT', Locked = true;
        RefundPaymentTypeLbl: Label 'REFUND', Locked = true;
        AcceptedResponseLbl: Label 'ACCEPTED', Locked = true;
        DeclinedResponseLbl: Label 'DECLINED', Locked = true;
    begin
        Clear(EFTTransactionRequestPaymentNetwork);
        Clear(EFTTransactionRequestPaymentType);

        PaymentTypeJsonObject.Add('name', CardLbl);
        EFTTransactionRequest.SetRange("Sales Ticket No.", POSEntry."Fiscal No.");
        EFTTransactionRequest.SetRange("Register No.", POSEntry."POS Unit No.");
        EFTTransactionRequest.SetRange("Sales Line No.", PaymentAmountLine."Line No.");
        EFTTransactionRequest.SetLoadFields("Card Number", Finished, "Processing Type", "Authorisation Number", "Card Application ID", "Hardware ID", "External Transaction ID", "Acquirer ID", Successful, "Card Name");
        if EFTTransactionRequest.FindFirst() and ((Format(EFTTransactionRequest."Processing Type") = 'Payment') or (Format(EFTTransactionRequest."Processing Type") = 'Refund')) then begin
            if Format(EFTTransactionRequest."Processing Type") = 'Payment' then begin

                EFTTransactionRequestCardNameUpperCase := EFTTransactionRequest."Card Name".ToUpper();
                if EFTTransactionRequestCardNameUpperCase.Contains('VISA') then
                    EFTTransactionRequestPaymentNetwork := VISALbl;
                if EFTTransactionRequestCardNameUpperCase.Contains('MASTERCARD') then
                    EFTTransactionRequestPaymentNetwork := MasterCardLbl;
                if EFTTransactionRequestCardNameUpperCase.Contains('AMEX') then
                    EFTTransactionRequestPaymentNetwork := AmexLbl;
                if EFTTransactionRequestCardNameUpperCase.Contains('MAESTRO') then
                    EFTTransactionRequestPaymentNetwork := MaestroLbl;
                if EFTTransactionRequestPaymentNetwork = '' then
                    EFTTransactionRequestPaymentNetwork := 'OTHER';
                PaymentTransactionDetailsObject.Add('payment_network', EFTTransactionRequestPaymentNetwork);

                if EFTTransactionRequestCardNameUpperCase.Contains('DEBIT') then
                    EFTTransactionRequestPaymentType := DebitLbl;
                if EFTTransactionRequestCardNameUpperCase.Contains('CREDIT') then
                    EFTTransactionRequestPaymentType := CreditLbl;
                if EFTTransactionRequestPaymentType = '' then
                    EFTTransactionRequestPaymentType := DebitLbl;
                PaymentTransactionDetailsObject.Add('payment_type', EFTTransactionRequestPaymentType);
            end;
            if Format(EFTTransactionRequest."Processing Type") = 'Refund' then begin
                PaymentTransactionDetailsObject.Add('payment_network', 'OTHER');
                PaymentTransactionDetailsObject.Add('payment_type', RefundPaymentTypeLbl);
            end;
            if EFTTransactionRequest."Card Number" <> '' then begin
                MaskedCard := CopyStr(EFTTransactionRequest."Card Number", 8, MaxStrLen(EFTTransactionRequest."Card Number"));
                PaymentTypeJsonObject.Add('payment_identifier', MaskedCard);
            end;

            PaymentTransactionDetailsObject.Add('local_date_time', GetUnixTime(EFTTransactionRequest.Finished));
            PaymentTransactionDetailsObject.Add('id', EFTTransactionRequest."External Transaction ID");
            PaymentTransactionDetailsObject.Add('acquirer_id', EFTTransactionRequest."Acquirer ID");
            PaymentTransactionDetailsObject.Add('type', 'POS');
            PaymentTransactionDetailsObject.Add('authorization_code', EFTTransactionRequest."Authorisation Number");
            PaymentTransactionDetailsObject.Add('AID', EFTTransactionRequest."Card Application ID");
            PaymentTransactionDetailsObject.Add('terminal_id', EFTTransactionRequest."Hardware ID");
            if EFTTransactionRequest.Successful then
                PaymentTransactionDetailsObject.Add('response', AcceptedResponseLbl)
            else
                PaymentTransactionDetailsObject.Add('response', DeclinedResponseLbl);
            PaymentTypeJsonObject.Add('transaction_details', PaymentTransactionDetailsObject);
        end;
    end;

    local procedure CreateCustomElementsJSON() CustomElementsJsonArray: JsonArray
    var
        CustomElementsJsonObject: JsonObject;
        ContentJsonObject: JsonObject;
    begin
        Clear(CustomElementsJsonObject);
        Clear(CustomElementsJsonArray);
        Clear(ContentJsonObject);

        CustomElementsJsonObject.Add('alignment', 'CENTER');
        ContentJsonObject.Add('data', '');
        ContentJsonObject.Add('type', 'TEXT');
        CustomElementsJsonObject.Add('content', ContentJsonObject);
        CustomElementsJsonObject.Add('orientation', 'AFTER');
        CustomElementsJsonObject.Add('position', 'SECURITY');
        CustomElementsJsonArray.Add(CustomElementsJsonObject);
    end;

    internal procedure GetResponseAsBuffer(var POSEntry: Record "NPR POS Entry"; var TempPOSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry" temporary)
    var
        ResponseText: Text;
    begin
        _Response.Content.ReadAs(ResponseText);
        ParseResponseToSaleDigitalReceiptEntryTemp(ResponseText, POSEntry, TempPOSSaleDigitalReceiptEntry);
    end;

    local procedure ParseResponseToSaleDigitalReceiptEntryTemp(ResponseText: Text; var POSEntry: Record "NPR POS Entry"; var TempPOSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry" temporary)
    var
        JsonResponse: Codeunit "JSON Management";
        JsonPdfLinkPropertyObject: Codeunit "JSON Management";
        JsonQRCodeObject: Codeunit "JSON Management";
        JsonArrayText: Text;
        JsonQRCodeText: Text;
        IdText: Text;
        PDFLinkText: Text;
        QRCodeText: Text;
        NotTemporaryTableErrorLbl: Label 'The provided parameter must be a temporary table.';
    begin
        if not TempPOSSaleDigitalReceiptEntry.IsTemporary then
            Error(NotTemporaryTableErrorLbl);

        TempPOSSaleDigitalReceiptEntry.Reset();
        if not TempPOSSaleDigitalReceiptEntry.IsEmpty then
            TempPOSSaleDigitalReceiptEntry.DeleteAll();

        JsonResponse.InitializeObject(ResponseText);

        TempPOSSaleDigitalReceiptEntry.Init();
        JsonResponse.GetStringPropertyValueByName('_id', IdText);
        TempPOSSaleDigitalReceiptEntry.Validate(Id, IdText);
        JsonPdfLinkPropertyObject.InitializeObject(ResponseText);
        if JsonPdfLinkPropertyObject.GetArrayPropertyValueAsStringByName('assets', JsonArrayText) then begin
            JsonPdfLinkPropertyObject.InitializeObject(JsonArrayText);
            JsonPdfLinkPropertyObject.GetStringPropertyValueByName('pdf_link', PDFLinkText);
            TempPOSSaleDigitalReceiptEntry.Validate(PDFLink, PDFLinkText);
        end;
        JsonQRCodeObject.InitializeObject(ResponseText);
        if JsonQRCodeObject.GetArrayPropertyValueAsStringByName('public_link', JsonQRCodeText) then begin
            JsonQRCodeObject.InitializeObject(JsonQRCodeText);
            JsonQRCodeObject.GetStringPropertyValueByName('href', QRCodeText);
            TempPOSSaleDigitalReceiptEntry.Validate("QR Code Link", QRCodeText);
        end;
        TempPOSSaleDigitalReceiptEntry.Validate("POS Entry No.", POSEntry."Entry No.");
        TempPOSSaleDigitalReceiptEntry.Validate("POS Unit No.", POSEntry."POS Unit No.");
        TempPOSSaleDigitalReceiptEntry.Validate("Sales Ticket No.", POSEntry."Document No.");
        TempPOSSaleDigitalReceiptEntry.Insert()
    end;

    internal procedure CreatePOSSaleDigitalReceiptEntry(var TempPOSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry" temporary)
    var
        POSSaleDigitalReceiptEntry: Record "NPR POSSaleDigitalReceiptEntry";
    begin
        TempPOSSaleDigitalReceiptEntry.Reset();
        if not TempPOSSaleDigitalReceiptEntry.FindFirst() then
            exit;

        if POSSaleDigitalReceiptEntry.Get(TempPOSSaleDigitalReceiptEntry.RecordId) then
            exit;

        POSSaleDigitalReceiptEntry.Init();
        POSSaleDigitalReceiptEntry := TempPOSSaleDigitalReceiptEntry;
        POSSaleDigitalReceiptEntry.Insert(true);
    end;

    internal procedure TestAPICredentials(ApiKey: Text[250]; ApiSecret: Text[250]) TestResult: Boolean
    var
        CredentialsNotValidLbl: Label 'API Credentials are not valid.';
        ValidCredentialsLbl: Label 'API credentials are valid.';
    begin
        TryCallAPIAuth(_Response);
        TestResult := _Response.IsSuccessStatusCode();
        if TestResult then
            Message(ValidCredentialsLbl)
        else
            Error(CredentialsNotValidLbl);
    end;

    [TryFunction]
    internal procedure TryTestAPICredentials(ApiKey: Text[250]; ApiSecret: Text[250])
    var
        CredentialsNotValidLbl: Label 'API Credentials are not valid.';
        Success: Boolean;
    begin
        ClearLastError();
        if not TryCallAPIAuth(_Response) then
            Error(GetLastErrorText());

        Success := _Response.IsSuccessStatusCode();
        if not Success then
            Error(CredentialsNotValidLbl);
    end;

    local procedure GetBaseUrlAuth() BaseUrl: Text
    begin
        BaseUrl := 'https://receipt.fiskaly.com/api/v1/auth';
    end;

    local procedure GetBaseUrlGetPostReceipt() BaseUrl: Text
    begin
        BaseUrl := 'https://receipt.fiskaly.com/api/v1/receipt/%1';
    end;

    local procedure GetUnixTime(DateTime: DateTime): Integer
    var
        Duration: Duration;
        DurationMs: BigInteger;
        FromDateTime: DateTime;
        StartingDatePoint: Label '1970-01-01T00:00:00Z', Locked = true;
    begin
        Evaluate(FromDateTime, StartingDatePoint, 9);
        Duration := DateTime - FromDateTime;
        DurationMs := Duration;
        exit((DurationMs / 1000) div 1);
    end;
}
