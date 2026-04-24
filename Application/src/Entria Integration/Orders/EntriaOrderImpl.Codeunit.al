#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151027 "NPR Entria Order Impl."
{
    Access = Internal;

    internal procedure ImportOrder(OrderTkn: JsonToken; EntriaStore: Record "NPR Entria Store"; DocumentNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        CreateEcommerceDocument(OrderTkn, EntriaStore, DocumentNo, EcomSalesHeader);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure CreateEcommerceDocument(OrderJson: JsonToken; EntriaStore: Record "NPR Entria Store"; DocumentNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        ProcessEcomSalesHeader(OrderJson, EntriaStore, DocumentNo, EcomSalesHeader);
        InsertEcomSalesLines(OrderJson, EcomSalesHeader);
        InsertEcomPaymentLines(OrderJson, EcomSalesHeader);
        _EcomVirtualItemMgt.UpdateVirtualItemInformationInHeader(EcomSalesHeader);
        _EcomSalesDocUtils.UpdateIndentation(EcomSalesHeader);
        _IntegrationEvents.OnAfterCreateEcomDocument(EntriaStore.Code, DocumentNo, EcomSalesHeader);
    end;

    local procedure ProcessEcomSalesHeader(OrderJson: JsonToken; EntriaStore: Record "NPR Entria Store"; DocumentNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        InsertEcomSalesHeader(OrderJson, EntriaStore, DocumentNo, EcomSalesHeader);
        Clear(_Currency);
        _Currency.Initialize(EcomSalesHeader."Currency Code", true);
    end;

    local procedure InsertEcomSalesHeader(Request: JsonToken; EntriaStore: Record "NPR Entria Store"; DocumentNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        Clear(EcomSalesHeader);
        EcomSalesHeader.Init();
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."External No." := DocumentNo;
        EcomSalesHeader."Received Date" := Today();
        EcomSalesHeader."Received Time" := Time();
        EcomSalesHeader."Requested API Version Date" := Today;
        EcomSalesHeader."API Version Date" := _EcomSalesDocUtils.GetApiVersionDateByRequest(Today);
        EcomSalesHeader."Location Code" := EntriaStore."Location Code";
        EcomSalesHeader."Ecommerce Store Code" := EntriaStore.Code;
        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Entria;
        SetEcomSalesHeaderDimensions(EntriaStore, EcomSalesHeader);
        DeserializeEntriaOrderHeader(Request, EcomSalesHeader);

        _IntegrationEvents.OnBeforeInsertEcommerceSalesHeader(EcomSalesHeader, Request);
        EcomSalesHeader.Insert(true);
        _IntegrationEvents.OnAfterInsertEcommerceSalesHeader(EcomSalesHeader, Request);
    end;

    local procedure DeserializeEntriaOrderHeader(RequestBody: JsonToken; var EcomSalesHeader: Record "NPR Ecom Sales Header");
    var
        EcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ShipToJsonToken: JsonToken;
        CurrencyCodeText: Code[10];
    begin
        if EcomSalesHeader."Location Code" = '' then begin
            EcomSalesDocSetup.SetLoadFields("Def. Sales Location Code");
            if EcomSalesDocSetup.Get() then
                EcomSalesHeader."Location Code" := EcomSalesDocSetup."Def. Sales Location Code";
        end;
#pragma warning disable AA0139
        CurrencyCodeText := _JsonHelper.GetJText(RequestBody, 'currency_code', false);
        if CurrencyCodeText <> '' then begin
            GeneralLedgerSetup.GetRecordOnce();
            if CurrencyCodeText <> GeneralLedgerSetup."LCY Code" then
                EcomSalesHeader."Currency Code" := CurrencyCodeText;
        end;
        EcomSalesHeader."Price Excl. VAT" := false; // Web always sends tax-inclusive amounts.
        EcomSalesHeader."Ticket Reservation Token" := _JsonHelper.GetJText(RequestBody, 'metadata.reservation_token', MaxStrLen(EcomSalesHeader."Ticket Reservation Token"), true, false);
        if EcomSalesHeader."Ticket Reservation Token" <> '' then
            EcomCreateTicketImpl.UpdateExpiryTimeBasedOnCapturedStatus(EcomSalesHeader);
        EcomSalesHeader."External Document Id" := _JsonHelper.GetJText(RequestBody, 'id', MaxStrLen(EcomSalesHeader."External Document Id"), true, true);
        EcomSalesHeader."Your Reference" := _JsonHelper.GetJText(RequestBody, 'display_id', MaxStrLen(EcomSalesHeader."Your Reference"), true, false);
        EcomSalesHeader."Sell-to Name" := BuildFullName(_JsonHelper.GetJText(RequestBody, 'billing_address.first_name', MaxStrLen(EcomSalesHeader."Sell-to Name"), true, false), _JsonHelper.GetJText(RequestBody, 'billing_address.last_name', MaxStrLen(EcomSalesHeader."Sell-to Name"), true, false), MaxStrLen(EcomSalesHeader."Sell-to Name"));
        //billing adress
        EcomSalesHeader."Sell-to Address" := _JsonHelper.GetJText(RequestBody, 'billing_address.address_1', MaxStrLen(EcomSalesHeader."Sell-to Address"), true, false);
        EcomSalesHeader."Sell-to Address 2" := _JsonHelper.GetJText(RequestBody, 'billing_address.address_2', MaxStrLen(EcomSalesHeader."Sell-to Address 2"), true, false);
        EcomSalesHeader."Sell-to Post Code" := _JsonHelper.GetJText(RequestBody, 'billing_address.postal_code', MaxStrLen(EcomSalesHeader."Sell-to Post Code"), true, false);
        EcomSalesHeader."Sell-to County" := _JsonHelper.GetJText(RequestBody, 'billing_address.province', MaxStrLen(EcomSalesHeader."Sell-to County"), true, false);
        EcomSalesHeader."Sell-to City" := _JsonHelper.GetJText(RequestBody, 'billing_address.city', MaxStrLen(EcomSalesHeader."Sell-to City"), true, false);
        EcomSalesHeader."Sell-to Country Code" := _JsonHelper.GetJText(RequestBody, 'billing_address.country_code', MaxStrLen(EcomSalesHeader."Sell-to Country Code"), true, false);
        EcomSalesHeader."Sell-to Contact" := _JsonHelper.GetJText(RequestBody, 'billing_address.company', MaxStrLen(EcomSalesHeader."Sell-to Contact"), true, false);
        EcomSalesHeader."Sell-to Email" := _JsonHelper.GetJText(RequestBody, 'email', MaxStrLen(EcomSalesHeader."Sell-to Email"), true, false);
        EcomSalesHeader."Sell-to Phone No." := _JsonHelper.GetJText(RequestBody, 'billing_address.phone', MaxStrLen(EcomSalesHeader."Sell-to Phone No."), true, false);
        //Ship-to
        if _JsonHelper.GetJsonToken(RequestBody, 'shipping_address', ShipToJsonToken) then begin
            EcomSalesHeader."Ship-to Name" := BuildFullName(_JsonHelper.GetJText(RequestBody, 'shipping_address.first_name', MaxStrLen(EcomSalesHeader."Ship-to Name"), true, false), _JsonHelper.GetJText(RequestBody, 'shipping_address.last_name', MaxStrLen(EcomSalesHeader."Ship-to Name"), true, false), MaxStrLen(EcomSalesHeader."Ship-to Name"));
            EcomSalesHeader."Ship-to Address" := _JsonHelper.GetJText(RequestBody, 'shipping_address.address_1', MaxStrLen(EcomSalesHeader."Ship-to Address"), true, false);
            EcomSalesHeader."Ship-to Address 2" := _JsonHelper.GetJText(RequestBody, 'shipping_address.address_2', MaxStrLen(EcomSalesHeader."Ship-to Address 2"), true, false);
            EcomSalesHeader."Ship-to Post Code" := _JsonHelper.GetJText(RequestBody, 'shipping_address.postal_code', MaxStrLen(EcomSalesHeader."Ship-to Post Code"), true, false);
            EcomSalesHeader."Ship-to County" := _JsonHelper.GetJText(RequestBody, 'shipping_address.province', MaxStrLen(EcomSalesHeader."Ship-to County"), true, false);
            EcomSalesHeader."Ship-to City" := _JsonHelper.GetJText(RequestBody, 'shipping_address.city', MaxStrLen(EcomSalesHeader."Ship-to City"), true, false);
            EcomSalesHeader."Ship-to Country Code" := _JsonHelper.GetJText(RequestBody, 'shipping_address.country_code', MaxStrLen(EcomSalesHeader."Ship-to Country Code"), true, false);
            EcomSalesHeader."Ship-to Contact" := _JsonHelper.GetJText(RequestBody, 'shipping_address.company', MaxStrLen(EcomSalesHeader."Ship-to Contact"), true, false);
        end;
        //Shipment method
        EcomSalesHeader."Shipment Method Code" := _JsonHelper.GetJText(RequestBody, 'shipping_methods[0].name', MaxStrLen(EcomSalesHeader."Shipment Method Code"), true, false);
#pragma warning restore AA0139
        _IntegrationEvents.OnAfterDeserializeEntriaOrderHeader(EcomSalesHeader, RequestBody);
    end;

    local procedure BuildFullName(FirstName: Text; LastName: Text; MaxLength: Integer): Text
    var
        FullName: Text;
    begin
        FullName := FirstName;

        if (FullName <> '') and (LastName <> '') then
            FullName += ' ';

        FullName += LastName;

        exit(CopyStr(FullName, 1, MaxLength));
    end;

    local procedure InsertEcomSalesLines(OrderJson: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SalesLineJsonToken: JsonToken;
        SalesLinesJsonToken: JsonToken;
        LastLineNo: Integer;
        SalesLinesNoArrayErr: Label 'The items property is not an array.';
    begin
        SalesLinesJsonToken := _JsonHelper.GetJsonToken(OrderJson, 'items');

        if (not SalesLinesJsonToken.IsArray()) then
            Error(SalesLinesNoArrayErr);

        LastLineNo := _EcomSalesDocUtils.GetSalesDocLastSalesLineLineNo(EcomSalesHeader);
        foreach SalesLineJsonToken in SalesLinesJsonToken.AsArray() do
            ProcessEcommerceSaleLine(SalesLineJsonToken, EcomSalesHeader, LastLineNo);
    end;

    local procedure ProcessEcommerceSaleLine(ItemToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var LastLineNo: Integer)
    var
        EcomSalesLineParams: Record "NPR Ecom Sales Line";
    begin
        PrepareEcomSalesLineParams(ItemToken, EcomSalesLineParams);
        InsertEcomSalesLinesByQuantity(ItemToken, EcomSalesHeader, EcomSalesLineParams, LastLineNo);

        HandleAttractionWalletLine(ItemToken, EcomSalesHeader, EcomSalesLineParams, LastLineNo);
    end;

    local procedure InsertEcomSalesLinesByQuantity(ItemToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLineParams: Record "NPR Ecom Sales Line"; var LastLineNo: Integer)
    var
        QuantityCount: Integer;
        QuantityIndex: Integer;
        TotalAmount: Decimal;
        InsertedAmount: Decimal;
    begin
        QuantityCount := GetQuantityCount(ItemToken, EcomSalesLineParams);
        TotalAmount := _JsonHelper.GetJDecimal(ItemToken, 'total', true);

        for QuantityIndex := 1 to QuantityCount do
            InsertEcomSalesLine(ItemToken, EcomSalesHeader, EcomSalesLineParams, LastLineNo, QuantityIndex, QuantityCount, TotalAmount, InsertedAmount);
    end;

    local procedure PrepareEcomSalesLineParams(ItemToken: JsonToken; var EcomSalesLineParams: Record "NPR Ecom Sales Line")
    var
        EcomCreateWalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        Clear(EcomSalesLineParams);
        SetLineTypes(ItemToken, EcomSalesLineParams);
        if EcomCreateWalletMgt.IsAttractionWallet(EcomSalesLineParams) then begin
            EcomSalesLineParams."Is Attraction Wallet" := true;
#pragma warning disable AA0139
            EcomSalesLineParams."External Line ID" := _JsonHelper.GetJText(ItemToken, 'id', MaxStrLen(EcomSalesLineParams."External Line ID"), true, false);
#pragma warning restore AA0139
        end;
    end;

    local procedure EnsureNo(ItemToken: JsonToken; var EcomSalesLineParams: Record "NPR Ecom Sales Line")
    begin
        if EcomSalesLineParams."No." <> '' then
            exit;
#pragma warning disable AA0139
        EcomSalesLineParams."No." := _JsonHelper.GetJText(ItemToken, 'metadata.external_id', MaxStrLen(EcomSalesLineParams."No."), false, false);
#pragma warning restore AA0139
    end;

    local procedure GetQuantityCount(ItemToken: JsonToken; EcomSalesLineParams: Record "NPR Ecom Sales Line"): Integer
    begin
        if EcomSalesLineParams."Is Attraction Wallet" then
            exit(1);

        case EcomSalesLineParams.Subtype of
            EcomSalesLineParams.Subtype::Voucher,
            EcomSalesLineParams.Subtype::Membership:
                exit(_JsonHelper.GetJInteger(ItemToken, 'quantity', true));
            else
                exit(1);//no spliting for non-voucher and non-membership lines
        end;
    end;

    local procedure HandleAttractionWalletLine(ItemToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLineParams: Record "NPR Ecom Sales Line"; var LastLineNo: Integer)
    begin
        if not EcomSalesLineParams."Is Attraction Wallet" then
            exit;

        InsertWalletChildLines(ItemToken, EcomSalesHeader, LastLineNo, EcomSalesLineParams."External Line ID");
    end;

    local procedure InsertWalletChildLines(ItemToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var LastLineNo: Integer; ParentExternalLineId: Text[100])
    var
        ChildrenToken: JsonToken;
        ChildToken: JsonToken;
        MetadataArrayErr: Label 'The metadata.children property is not an array.';
    begin
        if not ItemToken.SelectToken('metadata.children', ChildrenToken) then
            exit;

        if not ChildrenToken.IsArray() then
            Error(MetadataArrayErr);

        foreach ChildToken in ChildrenToken.AsArray() do
            InsertWalletChildLine(ChildToken, EcomSalesHeader, LastLineNo, ParentExternalLineId);
    end;

    local procedure InsertWalletChildLine(ChildToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var LastLineNo: Integer; ParentExternalLineId: Text[100])
    var
        ChildLine: Record "NPR Ecom Sales Line";
    begin
        LastLineNo += 10000;
        ChildLine.Init();
        ChildLine."Document Entry No." := EcomSalesHeader."Entry No.";
        ChildLine."Document Type" := EcomSalesHeader."Document Type";
        ChildLine."External Document No." := EcomSalesHeader."External No.";
        ChildLine."Line No." := LastLineNo;
        DeserializeWalletChildLine(ChildToken, ChildLine);
        ChildLine."External Line ID" := CopyStr((Format(LastLineNo) + '-' + ParentExternalLineId), 1, MaxStrLen(ChildLine."External Line ID"));
        ChildLine."Parent Ext. Line ID" := ParentExternalLineId;
        ChildLine."Is Attraction Wallet" := false;

        _IntegrationEvents.OnBeforeInsertEcommerceSalesLine(ChildToken, EcomSalesHeader, ChildLine);
        ChildLine.Insert(true);
        _IntegrationEvents.OnAfterInsertEcommerceSalesLine(ChildToken, EcomSalesHeader, ChildLine);
    end;

    local procedure HasPricedWalletChildren(ItemToken: JsonToken): Boolean
    var
        ChildrenToken: JsonToken;
        ChildToken: JsonToken;
    begin
        if not ItemToken.SelectToken('metadata.children', ChildrenToken) then
            exit(false);

        if not ChildrenToken.IsArray() then
            exit(false);

        foreach ChildToken in ChildrenToken.AsArray() do
            if (_JsonHelper.GetJDecimal(ChildToken, 'quantity', false) <> 0) and (_JsonHelper.GetJDecimal(ChildToken, 'base_price', false) <> 0) then
                exit(true);
        exit(false);
    end;

    local procedure InsertEcomSalesLine(ItemToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLineParams: Record "NPR Ecom Sales Line"; var LastLineNo: Integer; QuantityIndex: Integer; QuantityCount: Integer; TotalAmount: Decimal; var InsertedAmount: Decimal)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        LastLineNo += 10000;
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesLine."Line No." := LastLineNo;
        EcomSalesLine.Type := EcomSalesLineParams.Type;
        EcomSalesLine.Subtype := EcomSalesLineParams.Subtype;
        DeserializeEcomSalesLine(ItemToken, EcomSalesLine, EcomSalesLineParams, QuantityIndex, QuantityCount, TotalAmount, InsertedAmount);
        ApplyParentWalletAmounts(ItemToken, EcomSalesLine);

        _IntegrationEvents.OnBeforeInsertEcommerceSalesLine(ItemToken, EcomSalesHeader, EcomSalesLine);
        EcomSalesLine.Insert(true);
        _IntegrationEvents.OnAfterInsertEcommerceSalesLine(ItemToken, EcomSalesHeader, EcomSalesLine);
    end;

    local procedure ApplyParentWalletAmounts(ItemToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        if not EcomSalesLine."Is Attraction Wallet" then
            exit;

        if not HasPricedWalletChildren(ItemToken) then
            exit;

        EcomSalesLine."Unit Price" := 0;
        EcomSalesLine."Line Amount" := 0;
        EcomSalesLine."VAT %" := 0;
    end;

    local procedure DeserializeWalletChildLine(ChildToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
#pragma warning disable AA0139
        EcomSalesLine."No." := _JsonHelper.GetJText(ChildToken, 'external_id', MaxStrLen(EcomSalesLine."No."), false, false);
        SetLineTypes(ChildToken, EcomSalesLine);
        EcomSalesLine.Description := _JsonHelper.GetJText(ChildToken, 'title', MaxStrLen(EcomSalesLine.Description), true, false);
        EcomSalesLine.Quantity := _JsonHelper.GetJDecimal(ChildToken, 'quantity', false);
        EcomSalesLine."Unit Price" := _JsonHelper.GetJDecimal(ChildToken, 'base_price', true);
        EcomSalesLine."Line Amount" := _JsonHelper.GetJDecimal(ChildToken, 'total', true);
        EcomSalesLine."VAT %" := _JsonHelper.GetJDecimal(ChildToken, 'tax_rate', false);
        GetTicketReservationLineId(ChildToken, 'reservation_line_id', EcomSalesLine);
#pragma warning restore AA0139
    end;

    local procedure DeserializeEcomSalesLine(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesLineParams: Record "NPR Ecom Sales Line"; QuantityIndex: Integer; QuantityCount: Integer; TotalAmount: Decimal; var InsertedAmount: Decimal)
    begin
#pragma warning disable AA0139
        case EcomSalesLine.Type of
            EcomSalesLine.Type::Item:
                begin
                    EcomSalesLine."No." := EcomSalesLineParams."No.";
                    case EcomSalesLine.Subtype of
                        EcomSalesLine.Subtype::Item,
                        EcomSalesLine.Subtype::Coupon:
                            DeserializeItemLineValues(SalesLineJsonToken, EcomSalesLine);
                        EcomSalesLine.Subtype::Ticket:
                            begin
                                DeserializeItemLineValues(SalesLineJsonToken, EcomSalesLine);
                                GetTicketReservationLineId(SalesLineJsonToken, 'metadata.reservation_line_id', EcomSalesLine);
                            end;
                        EcomSalesLine.Subtype::Membership:
                            begin
                                DeserializeSplitedLineValues(SalesLineJsonToken, EcomSalesLine, QuantityIndex, QuantityCount, TotalAmount, InsertedAmount);
                                EcomSalesLine."Member Birthday" := _JsonHelper.GetJDate(SalesLineJsonToken, 'metadata.birthdate', false);
                                EcomSalesLine."Membership Activation Date" := _JsonHelper.GetJDate(SalesLineJsonToken, 'metadata.activation_date', false);
                                EcomSalesLine."Member First Name" := _JsonHelper.GetJText(SalesLineJsonToken, 'metadata.member_first_name', MaxStrLen(EcomSalesLine."Member First Name"), false, false);
                                EcomSalesLine."Member Email" := _JsonHelper.GetJText(SalesLineJsonToken, 'metadata.member_email', MaxStrLen(EcomSalesLine."Member Email"), false, false);
                            end;
                    end;
                end;
            EcomSalesLine.Type::Voucher:
                begin
                    EcomSalesLine."Voucher Type" := EcomSalesLineParams."No.";
                    DeserializeSplitedLineValues(SalesLineJsonToken, EcomSalesLine, QuantityIndex, QuantityCount, TotalAmount, InsertedAmount);
                end;
        end;
        EcomSalesLine.Description := _JsonHelper.GetJText(SalesLineJsonToken, 'title', MaxStrLen(EcomSalesLine.Description), true, false);
        EcomSalesLine."Unit Price" := _JsonHelper.GetJDecimal(SalesLineJsonToken, 'unit_price', false);
        EcomSalesLine."Is Attraction Wallet" := EcomSalesLineParams."Is Attraction Wallet";
        if EcomSalesLine."Is Attraction Wallet" then
            EcomSalesLine."External Line ID" := EcomSalesLineParams."External Line ID";

        _IntegrationEvents.OnAfterDeserializeEcommerceSalesLine(SalesLineJsonToken, EcomSalesLine);
#pragma warning restore AA0139
    end;

    local procedure GetTicketReservationLineId(LineJsonToken: JsonToken; JsonPath: Text; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        TicketReservationLineTxt: Text;
        InvalidGuidErr: Label 'Invalid value at %1. Expected a GUID.', Comment = '%1 = field caption';
    begin
        TicketReservationLineTxt := _JsonHelper.GetJText(LineJsonToken, JsonPath, 50, false, false).Trim();
        if TicketReservationLineTxt = '' then
            exit;

        if not Evaluate(EcomSalesLine."Ticket Reservation Line Id", TicketReservationLineTxt) then
            Error(InvalidGuidErr, EcomSalesLine.FieldCaption("Ticket Reservation Line Id"));

    end;

    local procedure DeserializeItemLineValues(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        ItemTaxTotal: Decimal;
    begin
#pragma warning disable AA0139
        EcomSalesLine.Quantity := _JsonHelper.GetJDecimal(SalesLineJsonToken, 'quantity', false);
        ItemTaxTotal := _JsonHelper.GetJDecimal(SalesLineJsonToken, 'tax_total', false);//The tax total of the item including promotions.
        if ItemTaxTotal <> 0 then
            EcomSalesLine."VAT %" := CalculateTotalVATRate(SalesLineJsonToken, ItemTaxTotal);
        EcomSalesLine."Line Amount" := _JsonHelper.GetJDecimal(SalesLineJsonToken, 'total', true);//The item's total, including taxes and promotions.
#pragma warning restore AA0139

    end;

    local procedure DeserializeSplitedLineValues(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line"; QuantityIndex: Integer; QuantityCount: Integer; TotalAmount: Decimal; var InsertedAmount: Decimal)
    var
        ItemTaxTotal: Decimal;
        CurrentLineAmount: Decimal;
    begin
#pragma warning disable AA0139
        EcomSalesLine.Quantity := 1;
        ItemTaxTotal := _JsonHelper.GetJDecimal(SalesLineJsonToken, 'tax_total', false);
        if ItemTaxTotal <> 0 then
            EcomSalesLine."VAT %" := CalculateTotalVATRate(SalesLineJsonToken, ItemTaxTotal);

        if QuantityIndex < QuantityCount then
            CurrentLineAmount := Round(TotalAmount / QuantityCount, _Currency."Amount Rounding Precision")
        else
            CurrentLineAmount := TotalAmount - InsertedAmount;

        EcomSalesLine."Line Amount" := CurrentLineAmount;
        InsertedAmount += CurrentLineAmount;
#pragma warning restore AA0139
    end;

    local procedure CalculateTotalVATRate(ItemToken: JsonToken; ItemTaxTotal: Decimal): Decimal
    var
        SubtotalExclVat: Decimal;
        TaxLinesToken: JsonToken;
        TaxLineToken: JsonToken;
        ItemTaxLinesArrayErr: Label 'The tax_lines property is not an array.';
        ItemTaxLinesMissingErr: Label 'Item tax total is %1, but no tax_lines were provided in the payload.';
    begin
        if not ItemToken.SelectToken('tax_lines', TaxLinesToken) then
            Error(ItemTaxLinesMissingErr, ItemTaxTotal);

        if not TaxLinesToken.IsArray() then
            Error(ItemTaxLinesArrayErr);

        // Single tax line - use rate directly
        if TaxLinesToken.AsArray().Count = 1 then begin
            TaxLinesToken.AsArray().Get(0, TaxLineToken);
            exit(_JsonHelper.GetJDecimal(TaxLineToken, 'rate', false));
        end;
        SubtotalExclVat := _JsonHelper.GetJDecimal(ItemToken, 'subtotal', false);//The item's total excluding taxes, including promotions.
        if SubtotalExclVat = 0 then
            exit(0);

        exit(Round((ItemTaxTotal / SubtotalExclVat) * 100, _Currency."Amount Rounding Precision"));
    end;

    local procedure SetLineTypes(ItemToken: JsonToken; var EcomSalesLineParams: Record "NPR Ecom Sales Line")
    var
        ProductTypeText: Text;
    begin
        Clear(EcomSalesLineParams.Subtype);
        Clear(EcomSalesLineParams.Type);
        EnsureNo(ItemToken, EcomSalesLineParams);

        ProductTypeText := LowerCase(_JsonHelper.GetJText(ItemToken, 'product_type', false));
        if _JsonHelper.GetJBoolean(ItemToken, 'is_giftcard', false) or (ProductTypeText = 'voucher') then begin
            EcomSalesLineParams.Type := EcomSalesLineParams.Type::Voucher;
            EcomSalesLineParams.Subtype := EcomSalesLineParams.Subtype::Voucher;
            exit;
        end;
        EcomSalesLineParams.Type := EcomSalesLineParams.Type::Item;
        EcomSalesLineParams.Subtype := TrySetItemSubtype(EcomSalesLineParams);
    end;

    local procedure TrySetItemSubtype(EcomSalesLine: Record "NPR Ecom Sales Line") Subtype: Enum "NPR Ecom Sales Line Subtype"
    var
        Item: Record Item;
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        ItemCode: Code[20];
    begin
        If not Evaluate(ItemCode, EcomSalesLine."No.") then
            exit;
        Item.SetLoadFields("NPR Ticket Type");//add missing fields for other types if needed
        if not Item.Get(ItemCode) then
            exit;
        case true of
            EcomVirtualItemMgt.IsTicketLine(Item):
                exit(Subtype::Ticket);
            EcomVirtualItemMgt.IsMembershipLine(Item."No."):
                exit(Subtype::Membership);
            EcomVirtualItemMgt.IsCouponItem(EcomSalesLine, false):
                exit(Subtype::Coupon);
            else
                exit(Subtype::Item);
        end;
    end;

    local procedure InsertEcomPaymentLines(RequestBody: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        PaymentCollectionToken: JsonToken;
        PaymentCollectionsToken: JsonToken;
        PaymentsArrayToken: JsonToken;
        PaymentToken: JsonToken;
        LastLineNo: Integer;
    begin
        LastLineNo := _EcomSalesDocUtils.GetSalesDocLastPaymentLineLineNo(EcomSalesHeader);
        if RequestBody.SelectToken('payment_collections', PaymentCollectionsToken) then
            if PaymentCollectionsToken.IsArray() then
                foreach PaymentCollectionToken in PaymentCollectionsToken.AsArray() do
                    if PaymentCollectionToken.SelectToken('payments', PaymentsArrayToken) and PaymentsArrayToken.IsArray() then
                        foreach PaymentToken in PaymentsArrayToken.AsArray() do
                            InsertEcomPaymentLine(PaymentToken, EcomSalesHeader, LastLineNo);
    end;

    local procedure InsertEcomPaymentLine(PaymentJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var LastLineNo: Integer)
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        LastLineNo += 10000;
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesPmtLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesPmtLine."Line No." := LastLineNo;
        DeserializeEntriaPaymentLine(PaymentJsonToken, EcomSalesPmtLine);

        _IntegrationEvents.OnBeforeInsertEcommerceSalesPaymentLine(PaymentJsonToken, EcomSalesHeader, EcomSalesPmtLine);
        EcomSalesPmtLine.Insert(true);
        _IntegrationEvents.OnAfterInsertEcommerceSalesPaymentLine(PaymentJsonToken, EcomSalesHeader, EcomSalesPmtLine);

        if EcomSalesPmtLine."Payment Method Type" = EcomSalesPmtLine."Payment Method Type"::Voucher then
            ReserveVoucher(EcomSalesHeader, EcomSalesPmtLine);
    end;

    local procedure DeserializeEntriaPaymentLine(PaymentToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    begin
        SetPaymentReference(PaymentToken, EcomSalesPmtLine);
#pragma warning disable AA0139
        EcomSalesPmtLine.Description := _JsonHelper.GetJText(PaymentToken, 'provider_id', MaxStrLen(EcomSalesPmtLine.Description), false, false);
        EcomSalesPmtLine.Amount := _JsonHelper.GetJDecimal(PaymentToken, 'amount', true);
        case EcomSalesPmtLine."Payment Method Type" of
            EcomSalesPmtLine."Payment Method Type"::"Payment Method":
                begin
                    EcomSalesPmtLine."External Payment Method Code" := EcomSalesPmtLine.Description;
                    EcomSalesPmtLine."External Payment Type" := _JsonHelper.GetJText(PaymentToken, 'data.paymentMethod', true);
                    EcomSalesPmtLine."PSP Token" := _JsonHelper.GetJText(PaymentToken, 'data.recurringToken', MaxStrLen(EcomSalesPmtLine."PSP Token"), true, false);
                    EcomSalesPmtLine."PAR Token" := _JsonHelper.GetJText(PaymentToken, 'data.shopperReference', MaxStrLen(EcomSalesPmtLine."PAR Token"), true, false);
                end;
            EcomSalesPmtLine."Payment Method Type"::Voucher:
                EcomSalesPmtLine.Description := CopyStr(EcomSalesPmtLine.Description + ' ' + EcomSalesPmtLine."Payment Reference", 1, MaxStrLen(EcomSalesPmtLine.Description));
#pragma warning restore AA0139
        end;
        _IntegrationEvents.OnAfterDeserializeEntriaPaymentLine(PaymentToken, EcomSalesPmtLine);
    end;

    local procedure SetPaymentReference(PaymentToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        DataToken: JsonToken;
        PaymentReference: Text[250];
        InvalidDataErr: Label 'Payment payload "%1" must be a JSON object.', Comment = '%1=absolute path';
        MissingDataErr: Label 'Missing required payment data: %1', Comment = '%1=absolute path';
    begin
        if not PaymentToken.SelectToken('data', DataToken) then
            Error(MissingDataErr, _JsonHelper.GetAbsolutePath(PaymentToken, 'data'));
        if not DataToken.IsObject() then
            Error(InvalidDataErr, _JsonHelper.GetAbsolutePath(PaymentToken, 'data'));
#pragma warning disable AA0139
        PaymentReference := _JsonHelper.GetJText(DataToken, 'voucher_code', false);

        if PaymentReference <> '' then
            EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::Voucher
        else begin
            PaymentReference := _JsonHelper.GetJText(DataToken, 'pspReference', false);
            EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::"Payment Method";
        end;
#pragma warning restore AA0139
        EcomSalesPmtLine."Payment Reference" := PaymentReference;

    end;

    local procedure ReserveVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        VoucherSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherMngt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        if EcomSalesPmtLine."Payment Method Type" <> EcomSalesPmtLine."Payment Method Type"::Voucher then
            exit;

        if not _EcomVirtualItemMgt.TryFindVoucher(EcomSalesPmtLine, Voucher) then
            exit;

        VoucherSalesLine.Reset();
        VoucherSalesLine.SetRange("Document Source", VoucherSalesLine."Document Source"::"Sales Document");
        VoucherSalesLine.SetRange("External Document No.", EcomSalesHeader."External No.");
        VoucherSalesLine.SetRange("Voucher Type", Voucher."Voucher Type");
        VoucherSalesLine.SetRange("Voucher No.", Voucher."No.");
        VoucherSalesLine.SetRange(Type, VoucherSalesLine.Type::Payment);
        if not VoucherSalesLine.FindFirst() then begin
            if not VoucherMngt.VoucherReservationByAmountFeatureEnabled() then begin
                if Voucher.CalcInUseQty() > 0 then
                    exit;
            end;

            VoucherSalesLine.Init();
            VoucherSalesLine.Id := CreateGuid();
            VoucherSalesLine."Document Source" := VoucherSalesLine."Document Source"::"Sales Document";
            VoucherSalesLine."External Document No." := EcomSalesHeader."External No.";
            VoucherSalesLine.Type := VoucherSalesLine.Type::Payment;
            VoucherSalesLine."Voucher Type" := Voucher."Voucher Type";
            VoucherSalesLine."Voucher No." := Voucher."No.";
            VoucherSalesLine."Reference No." := Voucher."Reference No.";
            VoucherSalesLine.Description := Voucher.Description;
            VoucherSalesLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
            VoucherSalesLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
            VoucherSalesLine.Amount := EcomSalesPmtLine.Amount;
            VoucherSalesLine.Insert();
        end else begin
            VoucherSalesLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
            VoucherSalesLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
            VoucherSalesLine.Amount := EcomSalesPmtLine.Amount;
            VoucherSalesLine.Modify();
        end;

        _IntegrationEvents.OnAfterReserveEntriaVoucher(EcomSalesHeader, EcomSalesPmtLine, VoucherSalesLine);
    end;

    local procedure SetEcomSalesHeaderDimensions(EntriaStore: Record "NPR Entria Store"; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        DimensionMgt: Codeunit DimensionManagement;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        GlobalDim1Code: Code[20];
        GlobalDim2Code: Code[20];
    begin
        DimensionMgt.AddDimSource(DefaultDimSource, Database::"NPR Entria Store", EntriaStore.Code);
        EcomSalesHeader."Dimension Set ID" := DimensionMgt.GetDefaultDimID(DefaultDimSource, '', GlobalDim1Code, GlobalDim2Code, 0, 0);
        EcomSalesHeader."Global Dimension 1 Code" := GlobalDim1Code;
        EcomSalesHeader."Global Dimension 2 Code" := GlobalDim2Code;
    end;

    var
        _Currency: Record Currency;
        _EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        _EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        _IntegrationEvents: Codeunit "NPR Entria Integration Events";
        _JsonHelper: Codeunit "NPR Json Helper";
}
#endif
