#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151048 "NPR ChannelMgrOrderAgent"
{
    Access = Internal;

    #region API Handlers
    internal procedure CreateOrder(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Order: Record "NPR CMOrder";
        PartnerSetup: Record "NPR CMPartnerSetup";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Body: JsonObject;
    begin
        if (not Request.BodyJson().IsObject()) then
            exit(Response.RespondBadRequest('Body must be a JSON object'));

        Body := Request.BodyJson().AsObject();

        if (not TryParseHeader(Body, Order, Response)) then
            exit(Response);

        if (not TryGetPartnerSetup(Order.PartnerId, PartnerSetup, Response)) then
            exit(Response);

        if (IsDuplicateOrder(Order)) then
            exit(Response.RespondBadRequest(StrSubstNo('An order with sellToOrderReference ''%1'' already exists for partner ''%2''', Order.SellToOrderReference, PartnerSetup.Name)));

        Order.OrderId := CreateGuid();
        if (not TryParseItems(Body, Order, TempOrderLine, TempOrderComponent, TempOrderWallet, Response)) then
            exit(Response);

        // Default is async, opt out with ?sync=1.
        if (IsSyncRequested(Request)) then begin
            OrderIssuer.ProcessNewOrder(true, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);
            exit(Response.RespondCreated(BuildOrderResponseJson(Order)));
        end;

        OrderIssuer.ProcessNewOrder(false, Order, TempOrderLine, TempOrderComponent, TempOrderWallet);

        exit(Response.RespondCreated(BuildOrderResponseJson(Order)));
    end;

    internal procedure ReplaceOrder(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ExistingOrder: Record "NPR CMOrder";
        ParsedOrder: Record "NPR CMOrder";
        TempOrderLine: Record "NPR CMOrderLine" temporary;
        TempOrderComponent: Record "NPR CMOrderComponent" temporary;
        TempOrderWallet: Record "NPR CMOrderWallet" temporary;
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Body: JsonObject;
        OrderId: Guid;
    begin
        if (not TryGetOrderIdFromPath(Request, 2, OrderId, Response)) then
            exit(Response);

        if (not ExistingOrder.Get(OrderId)) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Order ''%1'' not found', OrderId)));

        if (not (ExistingOrder.Status in [ExistingOrder.Status::Draft, ExistingOrder.Status::Error])) then
            exit(Response.RespondBadRequest(StrSubstNo('Order cannot be replaced in status %1', ExistingOrder.Status)));

        if (not Request.BodyJson().IsObject()) then
            exit(Response.RespondBadRequest('Body must be a JSON object'));
        Body := Request.BodyJson().AsObject();

        if (not TryParseHeader(Body, ParsedOrder, Response)) then
            exit(Response);

        // PUT replaces contents, not identity.
        if (ParsedOrder.PartnerId <> ExistingOrder.PartnerId) then
            exit(Response.RespondBadRequest('partnerId cannot be changed via PUT'));
        if (ParsedOrder.SellToOrderReference <> ExistingOrder.SellToOrderReference) then
            exit(Response.RespondBadRequest('sellToOrderReference cannot be changed via PUT'));

        ParsedOrder.OrderId := ExistingOrder.OrderId;
        if (not TryParseItems(Body, ParsedOrder, TempOrderLine, TempOrderComponent, TempOrderWallet, Response)) then
            exit(Response);

        // Default is async, opt out with ?sync=1.
        if (IsSyncRequested(Request)) then begin
            OrderIssuer.ReplaceOrder(true, ExistingOrder, ParsedOrder, TempOrderLine, TempOrderComponent, TempOrderWallet);
            exit(Response.RespondOk(BuildOrderResponseJson(ExistingOrder)));
        end;

        OrderIssuer.ReplaceOrder(false, ExistingOrder, ParsedOrder, TempOrderLine, TempOrderComponent, TempOrderWallet);

        exit(Response.RespondOk(BuildOrderResponseJson(ExistingOrder)));
    end;

    internal procedure DeleteOrder(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Order: Record "NPR CMOrder";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        OrderId: Guid;
    begin
        if (not TryGetOrderIdFromPath(Request, 2, OrderId, Response)) then
            exit(Response);

        if (not Order.Get(OrderId)) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Order ''%1'' not found', OrderId)));

        if (Order.Status in [Order.Status::Submitted, Order.Status::Scheduled, Order.Status::Processing]) then
            exit(Response.RespondBadRequest(StrSubstNo('Order is mid-flight (status %1); retry once it has settled.', Order.Status)));

        OrderIssuer.DeleteOrder(Order);

        exit(Response.RespondOk(BuildOrderResponseJson(Order)));
    end;

    internal procedure GetOrder(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Order: Record "NPR CMOrder";
        OrderId: Guid;
    begin
        if (not TryGetOrderIdFromPath(Request, 2, OrderId, Response)) then
            exit(Response);

        if (not Order.Get(OrderId)) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Order ''%1'' not found', OrderId)));

        exit(Response.RespondOk(BuildOrderResponseJson(Order)));
    end;

    internal procedure ListOrdersByPartner(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Order: Record "NPR CMOrder";
        Fields: Dictionary of [Integer, Text];
        QueryParams: Dictionary of [Text, Text];
        PartnerId: Guid;
        PartnerIdText: Text;
        ReceivedAtFrom: DateTime;
        ReceivedAtTo: DateTime;
    begin
        PartnerIdText := Request.Paths().Get(3);
        if (not Evaluate(PartnerId, PartnerIdText)) then
            exit(Response.RespondBadRequest('Invalid partnerId'));

        QueryParams := Request.QueryParams();

        if (QueryParams.ContainsKey('sellToOrderReference')) then
            Order.SetCurrentKey(PartnerId, SellToOrderReference)
        else
            Order.SetCurrentKey(PartnerId, ReceivedAt);

        Order.SetFilter(PartnerId, '=%1', PartnerId);

        if (QueryParams.ContainsKey('status')) then
            Order.SetFilter(Status, QueryParams.Get('status').Replace(',', '|'));

        if (QueryParams.ContainsKey('sellToOrderReference')) then
            Order.SetFilter(SellToOrderReference, '=%1', QueryParams.Get('sellToOrderReference'));

        if ((QueryParams.ContainsKey('receivedAtFrom')) and (QueryParams.ContainsKey('receivedAtTo'))) then begin
            if (not Evaluate(ReceivedAtFrom, QueryParams.Get('receivedAtFrom'), 9)) then
                exit(Response.RespondBadRequest('receivedAtFrom must be ISO 8601 datetime'));
            if (not Evaluate(ReceivedAtTo, QueryParams.Get('receivedAtTo'), 9)) then
                exit(Response.RespondBadRequest('receivedAtTo must be ISO 8601 datetime'));
            Order.SetFilter(ReceivedAt, '>=%1&<=%2', ReceivedAtFrom, ReceivedAtTo);
        end else
            if (QueryParams.ContainsKey('receivedAtFrom')) then begin
                if (not Evaluate(ReceivedAtFrom, QueryParams.Get('receivedAtFrom'), 9)) then
                    exit(Response.RespondBadRequest('receivedAtFrom must be ISO 8601 datetime'));
                Order.SetFilter(ReceivedAt, '>=%1', ReceivedAtFrom);
            end else
                if (QueryParams.ContainsKey('receivedAtTo')) then begin
                    if (not Evaluate(ReceivedAtTo, QueryParams.Get('receivedAtTo'), 9)) then
                        exit(Response.RespondBadRequest('receivedAtTo must be ISO 8601 datetime'));
                    Order.SetFilter(ReceivedAt, '<=%1', ReceivedAtTo);
                end;

        Fields.Add(Order.FieldNo(OrderId), 'orderId');
        Fields.Add(Order.FieldNo(PartnerId), 'partnerId');
        Fields.Add(Order.FieldNo(SellToOrderReference), 'sellToOrderReference');
        Fields.Add(Order.FieldNo(DocumentNo), 'buyFromOrderReference');
        Fields.Add(Order.FieldNo(SellToEmail), 'sellToEmail');
        Fields.Add(Order.FieldNo(SellToName), 'sellToName');
        Fields.Add(Order.FieldNo(SellToLanguage), 'sellToLanguage');
        Fields.Add(Order.FieldNo(PaymentReference), 'paymentReference');
        Fields.Add(Order.FieldNo(Status), 'status');
        Fields.Add(Order.FieldNo(StatusMessage), 'statusMessage');
        Fields.Add(Order.FieldNo(ReceivedAt), 'receivedAt');
        Fields.Add(Order.FieldNo(JobId), 'jobId');
        Fields.Add(Order.FieldNo(ManifestUrl), 'manifestUrl');

        exit(Response.RespondOK(Request.GetData(Order, Fields)));
    end;

    internal procedure ConfirmOrder(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Order: Record "NPR CMOrder";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
        Body: JsonObject;
        OrderId: Guid;
        PaymentReference: Text;
    begin
        if (not TryGetOrderIdFromPath(Request, 2, OrderId, Response)) then
            exit(Response);

        if (not Order.Get(OrderId)) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Order ''%1'' not found', OrderId)));

        // Idempotency: confirming an already-Issued order is a no-op.
        if (Order.Status = Order.Status::Issued) then
            exit(Response.RespondOk(BuildOrderResponseJson(Order)));

        if (Order.Status <> Order.Status::Draft) then
            exit(Response.RespondBadRequest(StrSubstNo('Order cannot be confirmed in status %1', Order.Status)));

        if (not Request.BodyJson().IsObject()) then
            exit(Response.RespondBadRequest('Body must be a JSON object'));
        Body := Request.BodyJson().AsObject();

        if (not GetRequiredTextField(Body, 'paymentReference', PaymentReference, Response)) then
            exit(Response);

        Order.PaymentReference := CopyStr(PaymentReference, 1, MaxStrLen(Order.PaymentReference));
        Order.Modify();

        OrderIssuer.ConfirmOrder(Order);

        exit(Response.RespondOk(BuildOrderResponseJson(Order)));
    end;

    #endregion

    #region Internal Methods
    local procedure BuildOrderResponseJson(var Order: Record "NPR CMOrder"): Codeunit "NPR JSON Builder"
    var
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        ResponseJson.StartObject()
            .AddProperty('orderId', Format(Order.OrderId, 0, 4).ToLower())
            .AddProperty('status', GetStatusAsText(Order.Status))
            .AddProperty('statusMessage', Order.StatusMessage)
            .AddProperty('partnerId', Format(Order.PartnerId, 0, 4).ToLower())
            .AddProperty('sellToOrderReference', Order.SellToOrderReference)
            .AddProperty('buyFromOrderReference', Order.DocumentNo)
            .AddProperty('sellToEmail', Order.SellToEmail)
            .AddProperty('sellToName', Order.SellToName)
            .AddProperty('sellToLanguage', Order.SellToLanguage)
            .AddProperty('paymentReference', Order.PaymentReference)
            .AddProperty('receivedAt', Order.ReceivedAt)
            .AddProperty('jobId', Order.JobId);

        if (Order.ManifestUrl <> '') then
            ResponseJson.AddProperty('manifestUrl', Order.ManifestUrl);

        AppendOrderItemsArray(ResponseJson, Order);

        ResponseJson.EndObject();
        exit(ResponseJson);
    end;

    local procedure AppendOrderItemsArray(ResponseJson: Codeunit "NPR JSON Builder"; var Order: Record "NPR CMOrder")
    var
        Line: Record "NPR CMOrderLine";
    begin
        ResponseJson.StartArray('items');
        Line.ReadIsolation := IsolationLevel::ReadCommitted;
        Line.SetFilter(OrderId, '=%1', Order.OrderId);
        if (Line.FindSet()) then
            repeat
                AppendOrderLine(ResponseJson, Line);
            until (Line.Next() = 0);
        ResponseJson.EndArray();
    end;

    local procedure AppendOrderLine(ResponseJson: Codeunit "NPR JSON Builder"; var Line: Record "NPR CMOrderLine")
    var
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
        TicketDescription: Text;
    begin
        if (Item.Get(Line.ItemNo)) then
            if (ItemTranslation.Get(Item."No.", Line.Language)) then
                TicketDescription := ItemTranslation.Description
            else
                TicketDescription := Item.Description;

        ResponseJson.StartObject()
            .AddProperty('lineNo', Line.LineNo)
            .AddProperty('itemNumber', Line.ItemNo)
            .AddProperty('description', TicketDescription)
            .AddProperty('isPackage', Line.IsPackage)
            .AddProperty('quantity', Line.Quantity)
            .AddProperty('visitDate', Line.VisitDate)
            .AddProperty('visitTime', Line.VisitTime)
            .AddProperty('sellToName', Line.Name)
            .AddProperty('sellToEmail', Line.NotificationAddress)
            .AddProperty('sellToLanguage', Line.Language);

        if (Line.IsPackage) then
            AppendComponentScheduleArray(ResponseJson, Line);

        AppendLineWalletsArray(ResponseJson, Line);

        ResponseJson.EndObject();
    end;

    local procedure AppendComponentScheduleArray(ResponseJson: Codeunit "NPR JSON Builder"; var Line: Record "NPR CMOrderLine")
    var
        Component: Record "NPR CMOrderComponent";
    begin
        Component.SetFilter(OrderId, '=%1', Line.OrderId);
        Component.SetFilter(LineNo, '=%1', Line.LineNo);
        Component.ReadIsolation := IsolationLevel::ReadCommitted;
        if (Component.IsEmpty()) then
            exit;

        ResponseJson.StartArray('componentSchedule');
        if (Component.FindSet()) then
            repeat
                ResponseJson.StartObject()
                    .AddProperty('itemNumber', Component.ComponentItemNo)
                    .AddProperty('visitDate', Component.VisitDate)
                    .AddProperty('visitTime', Component.VisitTime)
                    .EndObject();
            until (Component.Next() = 0);
        ResponseJson.EndArray();
    end;

    local procedure AppendLineWalletsArray(ResponseJson: Codeunit "NPR JSON Builder"; var Line: Record "NPR CMOrderLine")
    var
        OrderWallet: Record "NPR CMOrderWallet";
    begin
        ResponseJson.StartArray('wallets');
        OrderWallet.ReadIsolation := IsolationLevel::ReadCommitted;
        OrderWallet.SetFilter(OrderId, '=%1', Line.OrderId);
        OrderWallet.SetFilter(LineNo, '=%1', Line.LineNo);
        if (OrderWallet.FindSet()) then
            repeat
                AppendWallet(ResponseJson, OrderWallet, Line);
            until (OrderWallet.Next() = 0);
        ResponseJson.EndArray();
    end;

    local procedure AppendWallet(ResponseJson: Codeunit "NPR JSON Builder"; var OrderWallet: Record "NPR CMOrderWallet"; Line: Record "NPR CMOrderLine")
    var
        Wallet: Record "NPR AttractionWallet";
        WalletReferenceNumber: Code[50];
        WalletId: Guid;
    begin
        Wallet.ReadIsolation := IsolationLevel::ReadCommitted;
        if (Wallet.Get(OrderWallet.WalletEntryNo)) then begin
            WalletReferenceNumber := Wallet.ReferenceNumber;
            WalletId := Wallet.SystemId;
        end;

        ResponseJson.StartObject()
            .AddProperty('seqNo', OrderWallet.SeqNo)
            .AddProperty('walletId', Format(WalletId, 0, 4).ToLower())
            .AddProperty('walletReferenceNumber', WalletReferenceNumber)
            .AddProperty('externalReferenceNumber', OrderWallet.ExternalReferenceNumber)
            .AddProperty('name', OrderWallet.WalletName)
            .AddProperty('issuedAt', OrderWallet.IssuedAt)
            .AddProperty('unitPriceExclVat', OrderWallet.UnitPriceExclVat)
            .AddProperty('unitPriceInclVat', OrderWallet.UnitPriceInclVat)
            .AddProperty('currencyCode', OrderWallet.CurrencyCode);

        if (OrderWallet.ManifestUrl <> '') then
            ResponseJson.AddProperty('manifestUrl', OrderWallet.ManifestUrl);

        AppendWalletAssetsArray(ResponseJson, OrderWallet.WalletEntryNo, Line.Language);

        ResponseJson.EndObject();
    end;

    local procedure AppendWalletAssetsArray(ResponseJson: Codeunit "NPR JSON Builder"; WalletEntryNo: Integer; LanguageCode: Code[10])
    var
        AssetRef: Record "NPR WalletAssetLineReference";
        AssetLine: Record "NPR WalletAssetLine";
    begin
        ResponseJson.StartArray('assets');
        if (WalletEntryNo <> 0) then begin
            AssetLine.ReadIsolation := IsolationLevel::ReadCommitted;

            AssetRef.SetCurrentKey(WalletEntryNo);
            AssetRef.ReadIsolation := IsolationLevel::ReadCommitted;
            AssetRef.SetFilter(WalletEntryNo, '=%1', WalletEntryNo);
            AssetRef.SetFilter(SupersededBy, '=%1', 0);
            if (AssetRef.FindSet()) then
                repeat
                    if (AssetLine.Get(AssetRef.WalletAssetLineEntryNo)) then
                        case AssetLine.Type of
                            AssetLine.Type::Ticket:
                                AppendTicket(ResponseJson, AssetLine, LanguageCode);
                            AssetLine.Type::Coupon:
                                AppendCoupon(ResponseJson, AssetLine, LanguageCode);
                        end;
                until (AssetRef.Next() = 0);
        end;
        ResponseJson.EndArray();
    end;


    local procedure AppendTicket(ResponseJson: Codeunit "NPR JSON Builder"; AssetLine: Record "NPR WalletAssetLine"; LanguageCode: Code[10])
    var
        Ticket: Record "NPR TM Ticket";
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
        TicketDescription: Text;
    begin
        if (Ticket.GetBySystemId(AssetLine.LineTypeSystemId)) then begin
            if (Item.Get(Ticket."Item No.")) then
                if (ItemTranslation.Get(Item."No.", '', LanguageCode)) then
                    TicketDescription := ItemTranslation.Description
                else
                    TicketDescription := Item.Description;

            ResponseJson.StartObject()
                .AddProperty('id', Format(AssetLine.SystemId, 0, 4).ToLower())
                .AddProperty('type', 'ticket')
                .AddProperty('assetId', Format(Ticket.SystemId, 0, 4).ToLower())
                .AddProperty('referenceNumber', Ticket."External Ticket No.")
                .AddProperty('itemNumber', Ticket."Item No.")
                .AddProperty('description', TicketDescription)
                .EndObject();
        end;
    end;

    local procedure AppendCoupon(ResponseJson: Codeunit "NPR JSON Builder"; AssetLine: Record "NPR WalletAssetLine"; LanguageCode: Code[10])
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponSetup: Record "NPR WalletCouponSetup";
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
        CouponDescription: Text;
    begin
        if (Coupon.GetBySystemId(AssetLine.LineTypeSystemId)) then begin
            CouponDescription := Coupon.Description;
            if (CouponSetup.Get(Coupon."Coupon Type")) then
                if (Item.Get(CouponSetup.TriggerOnItemNo)) then
                    if (ItemTranslation.Get(Item."No.", '', LanguageCode)) then
                        CouponDescription := ItemTranslation.Description
                    else
                        CouponDescription := Item.Description;

            ResponseJson.StartObject()
                .AddProperty('id', Format(AssetLine.SystemId, 0, 4).ToLower())
                .AddProperty('type', 'coupon')
                .AddProperty('assetId', Format(Coupon.SystemId, 0, 4).ToLower())
                .AddProperty('referenceNumber', Coupon."Reference No.")
                .AddProperty('itemNumber', CouponSetup.TriggerOnItemNo)
                .AddProperty('description', CouponDescription)
                .EndObject();
        end;
    end;

    // ---- Helpers ----
    local procedure TryParseHeader(Body: JsonObject; var Order: Record "NPR CMOrder"; var Response: Codeunit "NPR API Response"): Boolean
    var
        PartnerIdText: Text;
        SellToOrderReference: Text;
        SellToEmail: Text;
        SellToName: Text;
        SellToLanguage: Text;
        PaymentReference: Text;
    begin
        if (not GetRequiredTextField(Body, 'partnerId', PartnerIdText, Response)) then
            exit(false);
        if (not Evaluate(Order.PartnerId, PartnerIdText)) then begin
            Response.RespondBadRequest('partnerId is not a valid GUID');
            exit(false);
        end;

        if (not GetRequiredTextField(Body, 'sellToOrderReference', SellToOrderReference, Response)) then
            exit(false);
        if (not GetOptionalTextField(Body, 'sellToEmail', SellToEmail, Response)) then
            exit(false);
        if (not GetOptionalTextField(Body, 'sellToName', SellToName, Response)) then
            exit(false);
        if (not GetOptionalTextField(Body, 'sellToLanguage', SellToLanguage, Response)) then
            exit(false);
        if (not GetOptionalTextField(Body, 'paymentReference', PaymentReference, Response)) then
            exit(false);

        Order.SellToOrderReference := CopyStr(SellToOrderReference, 1, MaxStrLen(Order.SellToOrderReference));
        Order.SellToEmail := CopyStr(SellToEmail, 1, MaxStrLen(Order.SellToEmail));
        Order.SellToName := CopyStr(SellToName, 1, MaxStrLen(Order.SellToName));
        Order.SellToLanguage := CopyStr(SellToLanguage.ToUpper(), 1, MaxStrLen(Order.SellToLanguage));
        Order.PaymentReference := CopyStr(PaymentReference, 1, MaxStrLen(Order.PaymentReference));
        exit(true);
    end;

    local procedure TryGetPartnerSetup(PartnerId: Guid; var PartnerSetup: Record "NPR CMPartnerSetup"; var Response: Codeunit "NPR API Response"): Boolean
    begin
        if (not PartnerSetup.Get(PartnerId)) then begin
            Response.RespondBadRequest(StrSubstNo('Unknown partnerId ''%1''', PartnerId));
            exit(false);
        end;
        if (not PartnerSetup.Active) then begin
            Response.RespondBadRequest(StrSubstNo('Partner ''%1'' is not active', PartnerSetup.Name));
            exit(false);
        end;
        exit(true);
    end;

    local procedure IsSyncRequested(var Request: Codeunit "NPR API Request"): Boolean
    var
        QueryParams: Dictionary of [Text, Text];
        Value: Text;
    begin
        QueryParams := Request.QueryParams();
        if (not QueryParams.ContainsKey('sync')) then
            exit(false);
        Value := QueryParams.Get('sync').ToLower();
        exit(Value in ['1', 'true']);
    end;

    local procedure IsDuplicateOrder(var Order: Record "NPR CMOrder"): Boolean
    var
        ExistingOrder: Record "NPR CMOrder";
        OrderIssuer: Codeunit "NPR CMOrderIssuer";
    begin
        ExistingOrder.ReadIsolation := ExistingOrder.ReadIsolation::ReadUncommitted;
        ExistingOrder.SetFilter(PartnerId, '=%1', Order.PartnerId);
        ExistingOrder.SetFilter(SellToOrderReference, '=%1', Order.SellToOrderReference);
        if (ExistingOrder.IsEmpty()) then
            exit(false);

        ExistingOrder.ReadIsolation := ExistingOrder.ReadIsolation::UpdLock;
        ExistingOrder.SetFilter(Status, '=%1', ExistingOrder.Status::Error);
        if (ExistingOrder.FindFirst()) then begin
            OrderIssuer.DeleteOrder(ExistingOrder);
            exit(false);
        end;

        exit(true);
    end;

    local procedure TryParseItems(Body: JsonObject; var Order: Record "NPR CMOrder"; var TempOrderLine: Record "NPR CMOrderLine" temporary; var TempOrderComponent: Record "NPR CMOrderComponent" temporary; var TempOrderWallet: Record "NPR CMOrderWallet" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        ItemsToken: JsonToken;
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        LineNo: Integer;
    begin
        if (not Body.Get('items', ItemsToken)) then begin
            Response.RespondBadRequest('items array is required');
            exit(false);
        end;
        if (not ItemsToken.IsArray()) then begin
            Response.RespondBadRequest('items must be an array');
            exit(false);
        end;
        ItemsArray := ItemsToken.AsArray();
        if (ItemsArray.Count() = 0) then begin
            Response.RespondBadRequest('items array must contain at least one entry');
            exit(false);
        end;

        LineNo := 0;
        foreach ItemToken in ItemsArray do begin
            LineNo += 100000;
            if (not TryParseItem(ItemToken, Order, LineNo, TempOrderLine, TempOrderComponent, TempOrderWallet, Response)) then
                exit(false);
        end;
        exit(true);
    end;

    local procedure TryParseItem(ItemToken: JsonToken; var Order: Record "NPR CMOrder"; LineNo: Integer; var TempOrderLine: Record "NPR CMOrderLine" temporary; var TempOrderComponent: Record "NPR CMOrderComponent" temporary; var TempOrderWallet: Record "NPR CMOrderWallet" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Item: Record Item;
        ItemObj: JsonObject;
        Token: JsonToken;
        ItemNoText: Text;
        NotificationAddressText: Text;
        NameText: Text;
        LanguageText: Text;
        VisitDate: Date;
        VisitTime: Time;
        Quantity: Integer;
        SeqNo: Integer;
        LocalDateTime: DateTime;
    begin
        if (not ItemToken.IsObject()) then begin
            Response.RespondBadRequest(StrSubstNo('items[%1] must be an object', (LineNo div 100000) - 1));
            exit(false);
        end;
        ItemObj := ItemToken.AsObject();

        if (not GetRequiredTextField(ItemObj, 'itemNumber', ItemNoText, Response)) then
            exit(false);
        if (not Item.Get(CopyStr(ItemNoText, 1, MaxStrLen(Item."No.")))) then begin
            Response.RespondBadRequest(StrSubstNo('Unknown item ''%1''', ItemNoText));
            exit(false);
        end;

        Quantity := 1;
        if (ItemObj.Get('quantity', Token)) then
            if (not Token.AsValue().IsNull()) then
                Quantity := Token.AsValue().AsInteger();
        if (Quantity < 1) then begin
            Response.RespondBadRequest(StrSubstNo('quantity must be >= 1 (line %1)', LineNo));
            exit(false);
        end;

        if (not GetRequiredDateField(ItemObj, 'visitDate', VisitDate, Response)) then
            exit(false);

        if (not GetRequiredTimeField(ItemObj, 'visitTime', VisitTime, Response)) then
            exit(false);

        LocalDateTime := TimeHelper.GetLocalTimeAtAdmission('');
        if (VisitDate < DT2Date(LocalDateTime)) then begin
            Response.RespondBadRequest(StrSubstNo('items[%1] visitDate must not be in the past (received %2, local today %3)', (LineNo div 100000) - 1, VisitDate, DT2Date(LocalDateTime)));
            exit(false);
        end;

        NotificationAddressText := Order.SellToEmail;
        if (ItemObj.Get('sellToEmail', Token)) then
            if (Token.AsValue().IsNull()) then
                NotificationAddressText := ''
            else
                NotificationAddressText := Token.AsValue().AsText();

        NameText := Order.SellToName;
        if (ItemObj.Get('sellToName', Token)) then
            if (Token.AsValue().IsNull()) then
                NameText := ''
            else
                NameText := Token.AsValue().AsText();

        LanguageText := Order.SellToLanguage;
        if (ItemObj.Get('sellToLanguage', Token)) then
            if (Token.AsValue().IsNull()) then
                LanguageText := ''
            else
                LanguageText := Token.AsValue().AsText().ToUpper();

        TempOrderLine.Init();
        TempOrderLine.OrderId := Order.OrderId;
        TempOrderLine.LineNo := LineNo;
        TempOrderLine.ItemNo := Item."No.";
        TempOrderLine.IsPackage := IsPackageItem(Item);
        TempOrderLine.IsGroupTicket := (not TempOrderLine.IsPackage) and IsGroupTicketItem(Item);
        TempOrderLine.Quantity := Quantity;
        TempOrderLine.VisitDate := VisitDate;
        TempOrderLine.VisitTime := VisitTime;
        TempOrderLine.NotificationAddress := CopyStr(NotificationAddressText, 1, MaxStrLen(TempOrderLine.NotificationAddress));
        TempOrderLine.Name := CopyStr(NameText, 1, MaxStrLen(TempOrderLine.Name));
        TempOrderLine.Language := CopyStr(LanguageText, 1, MaxStrLen(TempOrderLine.Language));
        TempOrderLine.Insert();

        for SeqNo := 1 to ExpectedWalletCount(TempOrderLine) do begin
            TempOrderWallet.Init();
            TempOrderWallet.OrderId := Order.OrderId;
            TempOrderWallet.LineNo := LineNo;
            TempOrderWallet.SeqNo := SeqNo;
            TempOrderWallet.Insert();
        end;

        if (ItemObj.Get('wallet', Token)) then
            if (Token.IsObject()) then
                if (not TryParseWalletBlock(Token.AsObject(), TempOrderLine, Item, TempOrderComponent, TempOrderWallet, Response)) then
                    exit(false);

        exit(true);
    end;

    local procedure TryParseWalletBlock(WalletObj: JsonObject; var TempOrderLine: Record "NPR CMOrderLine" temporary; Item: Record Item; var TempOrderComponent: Record "NPR CMOrderComponent" temporary; var TempOrderWallet: Record "NPR CMOrderWallet" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        Token: JsonToken;
        EntryToken: JsonToken;
        NameArr: JsonArray;
        ExtRefArr: JsonArray;
        ScheduleArr: JsonArray;
        ScheduleEntry: JsonToken;
        SeqNo: Integer;
        ComponentNo: Integer;
        WalletCount: Integer;
    begin
        WalletCount := ExpectedWalletCount(TempOrderLine);

        if (WalletObj.Get('names', Token)) then
            if (Token.IsArray()) then begin
                NameArr := Token.AsArray();
                if (NameArr.Count() <> WalletCount) then begin
                    Response.RespondBadRequest(StrSubstNo('wallet.names array length (%1) must equal %2 on line %3', NameArr.Count(), WalletCount, TempOrderLine.LineNo));
                    exit(false);
                end;
                for SeqNo := 1 to WalletCount do begin
                    NameArr.Get(SeqNo - 1, EntryToken);
                    TempOrderWallet.Get(TempOrderLine.OrderId, TempOrderLine.LineNo, SeqNo);
                    TempOrderWallet.WalletName := CopyStr(EntryToken.AsValue().AsText(), 1, MaxStrLen(TempOrderWallet.WalletName));
                    TempOrderWallet.Modify();
                end;
            end;

        if (WalletObj.Get('externalReferenceNumbers', Token)) then
            if (Token.IsArray()) then begin
                ExtRefArr := Token.AsArray();
                if (ExtRefArr.Count() <> WalletCount) then begin
                    Response.RespondBadRequest(StrSubstNo('wallet.externalReferenceNumbers array length (%1) must equal %2 on line %3', ExtRefArr.Count(), WalletCount, TempOrderLine.LineNo));
                    exit(false);
                end;
                for SeqNo := 1 to WalletCount do begin
                    ExtRefArr.Get(SeqNo - 1, EntryToken);
                    TempOrderWallet.Get(TempOrderLine.OrderId, TempOrderLine.LineNo, SeqNo);
                    TempOrderWallet.ExternalReferenceNumber := CopyStr(EntryToken.AsValue().AsText(), 1, MaxStrLen(TempOrderWallet.ExternalReferenceNumber));
                    TempOrderWallet.Modify();
                end;
            end;

        if (WalletObj.Get('componentSchedule', Token)) then
            if (Token.IsArray()) then begin
                if (not TempOrderLine.IsPackage) then begin
                    Response.RespondBadRequest(StrSubstNo('wallet.componentSchedule is only valid for package items (line %1)', TempOrderLine.LineNo));
                    exit(false);
                end;
                ScheduleArr := Token.AsArray();
                ComponentNo := 0;
                foreach ScheduleEntry in ScheduleArr do begin
                    ComponentNo += 10000;
                    if (not TryParseComponentScheduleEntry(ScheduleEntry, TempOrderLine, Item, ComponentNo, TempOrderComponent, Response)) then
                        exit(false);
                end;
            end;
        exit(true);
    end;

    local procedure TryParseComponentScheduleEntry(EntryToken: JsonToken; var TempOrderLine: Record "NPR CMOrderLine" temporary; Item: Record Item; ComponentNo: Integer; var TempOrderComponent: Record "NPR CMOrderComponent" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
        EntryObj: JsonObject;
        ComponentItemNoText: Text;
        VisitDate: Date;
        VisitTime: Time;
        LocalDateTime: DateTime;
    begin
        if (not EntryToken.IsObject()) then begin
            Response.RespondBadRequest(StrSubstNo('wallet.componentSchedule entries must be objects (line %1)', TempOrderLine.LineNo));
            exit(false);
        end;
        EntryObj := EntryToken.AsObject();

        if (not GetRequiredTextField(EntryObj, 'itemNumber', ComponentItemNoText, Response)) then
            exit(false);
        if (not IsComponentInPackage(Item, ComponentItemNoText)) then begin
            Response.RespondBadRequest(StrSubstNo('''%1'' is not a component of package ''%2'' (line %3)', ComponentItemNoText, Item."No.", TempOrderLine.LineNo));
            exit(false);
        end;

        if (not GetRequiredDateField(EntryObj, 'visitDate', VisitDate, Response)) then
            exit(false);

        if (not GetRequiredTimeField(EntryObj, 'visitTime', VisitTime, Response)) then
            exit(false);

        // Same timezone-aware "today" pattern as the line-level check above — never trust Today()
        // for partner-facing date validation since the BC service may run in UTC.
        LocalDateTime := TimeHelper.GetLocalTimeAtAdmission('');

        if (VisitDate < DT2Date(LocalDateTime)) then begin
            Response.RespondBadRequest(StrSubstNo('items[%1].componentSchedule entry ''%2'' visitDate must not be in the past (received %3, local today %4)', (TempOrderLine.LineNo div 100000) - 1, ComponentItemNoText, VisitDate, DT2Date(LocalDateTime)));
            exit(false);
        end;

        TempOrderComponent.Init();
        TempOrderComponent.OrderId := TempOrderLine.OrderId;
        TempOrderComponent.LineNo := TempOrderLine.LineNo;
        TempOrderComponent.ComponentNo := ComponentNo;
        TempOrderComponent.ComponentItemNo := CopyStr(ComponentItemNoText, 1, MaxStrLen(TempOrderComponent.ComponentItemNo));
        TempOrderComponent.VisitDate := VisitDate;
        TempOrderComponent.VisitTime := VisitTime;
        TempOrderComponent.Insert();
        exit(true);
    end;

    local procedure IsPackageItem(Item: Record Item): Boolean
    begin
        exit(Item."NPR Item AddOn No." <> '');
    end;

    local procedure IsGroupTicketItem(Item: Record Item): Boolean
    var
        TicketType: Record "NPR TM Ticket Type";
    begin
        if (Item."NPR Ticket Type" = '') then
            exit(false);
        if (not TicketType.Get(Item."NPR Ticket Type")) then
            exit(false);
        exit(TicketType."Admission Registration" = TicketType."Admission Registration"::GROUP);
    end;

    local procedure ExpectedWalletCount(var Line: Record "NPR CMOrderLine" temporary): Integer
    begin
        if (Line.IsGroupTicket) then
            exit(1);
        exit(Line.Quantity);
    end;

    local procedure IsComponentInPackage(PackageItem: Record Item; ComponentItemNoText: Text): Boolean
    var
        AddOnLine: Record "NPR NpIa Item AddOn Line";
    begin
        if (PackageItem."NPR Item AddOn No." = '') then
            exit(false);
        AddOnLine.SetFilter("AddOn No.", '=%1', PackageItem."NPR Item AddOn No.");
        AddOnLine.SetFilter("Item No.", '=%1', CopyStr(ComponentItemNoText, 1, MaxStrLen(AddOnLine."Item No.")));
        exit(not AddOnLine.IsEmpty());
    end;

    local procedure GetRequiredField(Obj: JsonObject; FieldName: Text; var Token: JsonToken; var Response: Codeunit "NPR API Response"): Boolean
    begin
        if (not Obj.Get(FieldName, Token)) then begin
            Response.RespondBadRequest(StrSubstNo('Required field ''%1'' is missing', FieldName));
            exit(false);
        end;
        if (not Token.IsValue()) then begin
            Response.RespondBadRequest(StrSubstNo('Required field ''%1'' must be a primitive value', FieldName));
            exit(false);
        end;
        if (Token.AsValue().IsNull()) then begin
            Response.RespondBadRequest(StrSubstNo('Required field ''%1'' cannot be null', FieldName));
            exit(false);
        end;
        exit(true);
    end;

    local procedure GetOptionalTextField(Obj: JsonObject; FieldName: Text; var Value: Text; var Response: Codeunit "NPR API Response"): Boolean
    var
        Token: JsonToken;
    begin
        Value := '';
        if (Obj.Get(FieldName, Token)) then begin
            if (not Token.IsValue()) then begin
                Response.RespondBadRequest(StrSubstNo('Optional field ''%1'' must be a primitive value', FieldName));
                exit(false);
            end;
            if (not Token.AsValue().IsNull()) then
                Value := Token.AsValue().AsText();
        end;
        exit(true);
    end;

    local procedure GetRequiredTextField(Obj: JsonObject; FieldName: Text; var Value: Text; var Response: Codeunit "NPR API Response"): Boolean
    var
        Token: JsonToken;
    begin
        if (not GetRequiredField(Obj, FieldName, Token, Response)) then
            exit(false);

        Value := Token.AsValue().AsText();
        if (Value = '') then begin
            Response.RespondBadRequest(StrSubstNo('Required field ''%1'' cannot be empty', FieldName));
            exit(false);
        end;
        exit(true);
    end;

    local procedure GetRequiredTimeField(Obj: JsonObject; FieldName: Text; var Value: Time; var Response: Codeunit "NPR API Response"): Boolean
    var
        Token: JsonToken;
        Regex: Codeunit Regex;
    begin
        if (not GetRequiredField(Obj, FieldName, Token, Response)) then
            exit(false);

        if (not Regex.IsMatch(Token.AsValue().AsText(), '^([01]\d|2[0-3]):[0-5]\d:[0-5]\d$')) then begin
            Response.RespondBadRequest(StrSubstNo('Required field ''%1'' must be HH:mm:ss', FieldName));
            exit(false);
        end;

        Value := Token.AsValue().AsTime();
        exit(true);
    end;

    local procedure GetRequiredDateField(Obj: JsonObject; FieldName: Text; var Value: Date; var Response: Codeunit "NPR API Response"): Boolean
    var
        Token: JsonToken;
        Regex: Codeunit Regex;
    begin
        if (not GetRequiredField(Obj, FieldName, Token, Response)) then
            exit(false);

        if (not Regex.IsMatch(Token.AsValue().AsText(), '^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$')) then begin
            Response.RespondBadRequest(StrSubstNo('Required field ''%1'' must be YYYY-MM-DD', FieldName));
            exit(false);
        end;

        Value := Token.AsValue().AsDate();
        exit(true);
    end;


    local procedure TryGetOrderIdFromPath(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var OrderId: Guid; var Response: Codeunit "NPR API Response"): Boolean
    var
        OrderIdText: Text;
    begin
        OrderIdText := Request.Paths().Get(PathPosition);
        if (OrderIdText = '') then begin
            Response.RespondBadRequest('Invalid order id');
            exit(false);
        end;
        if (not Evaluate(OrderId, OrderIdText)) then begin
            Response.RespondBadRequest('Invalid order id');
            exit(false);
        end;
        exit(true);
    end;

    internal procedure GetStatusAsText(Status: Enum "NPR CMOrderStatus"): Text[50]
    begin
        case Status of
            Status::Submitted:
                exit('Submitted');
            Status::Scheduled:
                exit('Scheduled');
            Status::Processing:
                exit('Processing');
            Status::Draft:
                exit('Draft');
            Status::Issued:
                exit('Issued');
            Status::Cancelled:
                exit('Cancelled');
            Status::Error:
                exit('Error');
            else
                exit('Unknown');
        end;
    end;
    #endregion
}
#endif
