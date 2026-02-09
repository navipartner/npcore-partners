#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248331 "NPR WalletApiAgent"
{
    Access = Internal;

    var
        _InvalidWalletId: Label 'Invalid wallet id', Locked = true;


    #region API functions
    internal procedure FindWalletUsingReferenceNumber(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ReferenceNumberText: Text;
        ReferenceNumbersText: List of [Text];
        ReferenceNumber: Text[100];
        ReferenceNumbers: List of [Text[100]];
        Wallets: List of [Integer];
        FindWallet: Query "NPR FindAttractionWallets";
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
        ResponseJson: Codeunit "NPR Json Builder";
        ReferenceNumberParameterRequired: Label 'Missing required parameter: referenceNumber or referenceNumbers', Locked = true;
        ReferenceNumberRequired: Label 'Parameter value for referenceNumber cannot be empty.', Locked = true;
        InvalidLength: Label 'Reference number exceeds maximum length of 100 characters.', Locked = true;
        Wallet: Record "NPR AttractionWallet";
        WithDetails, WithAssets : Boolean;
        LanguageCode: Code[10];
    begin

        if (not (Request.QueryParams().ContainsKey('referenceNumber') or Request.QueryParams().ContainsKey('referenceNumbers'))) then
            exit(Response.RespondBadRequest(ReferenceNumberParameterRequired));

        if (Request.QueryParams().ContainsKey('referenceNumbers')) then
            ReferenceNumbersText := Request.QueryParams().Get('referenceNumbers').Split(',');

        if (Request.QueryParams().ContainsKey('referenceNumber')) then
            ReferenceNumbersText.Add(Request.QueryParams().Get('referenceNumber'));

        if (Request.QueryParams().ContainsKey('withAssets')) then
            WithAssets := (Request.QueryParams().Get('withAssets').ToLower() = 'true');

        if (Request.QueryParams().ContainsKey('withDetails')) then
            WithDetails := (Request.QueryParams().Get('withDetails').ToLower() = 'true');

        if (Request.QueryParams().ContainsKey('languageCode')) then
            LanguageCode := CopyStr(Request.QueryParams().Get('languageCode'), 1, MaxStrLen(LanguageCode));

        // Validate and prepare reference numbers
        foreach ReferenceNumberText in ReferenceNumbersText do begin
            ReferenceNumber := CopyStr(ReferenceNumberText.Trim(), 1, 100);

            if (ReferenceNumber = '') then
                exit(Response.RespondBadRequest(ReferenceNumberRequired));

            if (StrLen(ReferenceNumberText.Trim()) > 100) then
                exit(Response.RespondBadRequest(InvalidLength));

            if (not ReferenceNumbers.Contains(ReferenceNumber)) then
                ReferenceNumbers.Add(ReferenceNumber);
        end;

        // Retrieve wallets
        ResponseJson.StartArray();
        foreach ReferenceNumber in ReferenceNumbers do begin
            AttractionWallet.FindWalletByReferenceNumber(ReferenceNumber, FindWallet);
            while (FindWallet.Read()) do begin
                if (not Wallets.Contains(FindWallet.WalletEntryNo)) then begin
                    Wallets.Add(FindWallet.WalletEntryNo);
                    if (Wallet.Get(FindWallet.WalletEntryNo)) then
                        ResponseJson := GetWalletAssetsDTO(ResponseJson, Wallet, (WithAssets or WithDetails), WithDetails, LanguageCode);
                end;
            end;
            FindWallet.Close();
        end;
        ResponseJson.EndArray();

        exit(Response.RespondOk(ResponseJson.BuildAsArray()));
    end;

    internal procedure GetWalletUsingId(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Wallet: Record "NPR AttractionWallet";
        WithDetails: Boolean;
        LanguageCode: Code[10];
    begin

        if (not GetWalletById(Request, 2, Wallet)) then
            exit(Response.RespondBadRequest(_InvalidWalletId));

        if (Request.QueryParams().ContainsKey('withDetails')) then
            WithDetails := (Request.QueryParams().Get('withDetails').ToLower() = 'true');

        if (Request.QueryParams().ContainsKey('languageCode')) then
            LanguageCode := CopyStr(Request.QueryParams().Get('languageCode'), 1, MaxStrLen(LanguageCode));

        exit(GetWalletAssetsResponse(Wallet, WithDetails, LanguageCode));
    end;

    internal procedure AddAssets(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Wallet: Record "NPR AttractionWallet";
        Body: JsonObject;
        JToken: JsonToken;
    begin

        if (not GetWalletById(Request, 2, Wallet)) then
            exit(Response.RespondBadRequest(_InvalidWalletId));

        Body := Request.BodyJson().AsObject();

        if (Body.Get('tickets', JToken)) then
            if (JToken.IsArray()) then
                StoreTickets(Wallet, JToken.AsArray());

        if (Body.Get('memberCards', JToken)) then
            if (JToken.IsArray()) then
                StoreMemberCards(Wallet, JToken.AsArray());

        if (Body.Get('coupons', JToken)) then
            if (JToken.IsArray()) then
                StoreCoupons(Wallet, JToken.AsArray());

        if (Body.Get('vouchers', JToken)) then
            if (JToken.IsArray()) then
                StoreVouchers(Wallet, JToken.AsArray());

        exit(GetWalletAssetsResponse(Wallet, false));
    end;

    internal procedure CreateWallet(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Wallet: Record "NPR AttractionWallet";
        WalletReferenceNumber: Text[50];
        WalletName: Text[100];
        OriginatesFromItemNo: Code[20];
        Body: JsonObject;
        JToken: JsonToken;
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
    begin
        Wallet.Init();

        Body := Request.BodyJson().AsObject();
        if (Body.Get('name', JToken)) then
            WalletName := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(WalletName));

        if (Body.Get('originatesFromItemNo', JToken)) then
            OriginatesFromItemNo := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(OriginatesFromItemNo));

        Wallet.Get(AttractionWallet.CreateWallet(OriginatesFromItemNo, WalletName, WalletReferenceNumber));

        if (Body.Get('tickets', JToken)) then
            if (JToken.IsArray()) then
                StoreTickets(Wallet, JToken.AsArray());

        if (Body.Get('memberCards', JToken)) then
            if (JToken.IsArray()) then
                StoreMemberCards(Wallet, JToken.AsArray());

        if (Body.Get('coupons', JToken)) then
            if (JToken.IsArray()) then
                StoreCoupons(Wallet, JToken.AsArray());

        if (Body.Get('vouchers', JToken)) then
            if (JToken.IsArray()) then
                StoreVouchers(Wallet, JToken.AsArray());

        if (Body.Get('externalReferenceNumbers', JToken)) then
            if (JToken.IsArray()) then
                AddWalletExternalReferences(Wallet, JToken.AsArray());

        exit(GetWalletAssetsResponse(Wallet, false));
    end;

    internal procedure GetAssetHistory(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        AssetLine: Record "NPR WalletAssetLine";
        ResponseJson: Codeunit "NPR Json Builder";
        AssetHistory: Query "NPR AttractionWalletAssetHist";
    begin
        if (not GetAssetLineById(Request, 3, AssetLine)) then
            exit(Response.RespondBadRequest(_InvalidWalletId));

        ResponseJson.StartObject()
            .AddProperty('id', Format(AssetLine.SystemId, 0, 4).ToLower())
            .AddProperty('type', AssetLine.Type.Names.Get(AssetLine.Type.Ordinals.IndexOf(AssetLine.Type.AsInteger())).ToLower())
            .AddProperty('assetId', Format(AssetLine.LineTypeSystemId, 0, 4).ToLower())
            .AddProperty('itemNo', AssetLine.ItemNo)
            .AddProperty('description', AssetLine.Description)
            .AddProperty('referenceNumber', AssetLine.LineTypeReference)
            .AddProperty('transactionId', Format(AssetLine.TransactionId, 0, 4).ToLower());

        ResponseJson.StartArray('history');
        AssetHistory.SetFilter(SystemId, '=%1', AssetLine.SystemId);
        AssetHistory.Open();
        while (AssetHistory.Read()) do begin
            ResponseJson.StartObject()
                .AddProperty('entryNo', AssetHistory.AssetReferenceEntryNo)
                .AddProperty('supersededByEntryNo', AssetHistory.AssetReferenceSupersededByEntryNo)
                .AddObject(AddOptionalProperty(ResponseJson, 'expiryDatetime', AssetHistory.AssetReferenceExpirationDate))

                .AddProperty('walletId', Format(AssetHistory.WalletSystemId, 0, 4).ToLower())
                .AddProperty('walletReferenceNumber', AssetHistory.WalletReferenceNumber)
                .AddProperty('walletExpirationDate', AssetHistory.WalletExpirationDate)

                .AddProperty('createdAt', AssetHistory.AssetReferenceCreatedAt)
                .AddProperty('modifiedAt', AssetHistory.AssetReferenceModifiedAt)
                .EndObject()
        end;
        ResponseJson.EndArray().EndObject();
        AssetHistory.Close();

        exit(Response.RespondOk(ResponseJson.Build()));
    end;

    internal procedure ConfirmPrintWallet(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Wallet: Record "NPR AttractionWallet";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
    begin
        if (not GetWalletById(Request, 2, Wallet)) then
            exit(Response.RespondBadRequest(_InvalidWalletId));

        WalletFacade.IncrementPrintCount(Wallet.EntryNo);

        // Refresh the record after incrementing print count
        Wallet.Get(Wallet.EntryNo);

        exit(GetWalletAssetsResponse(Wallet, false));
    end;

    internal procedure ClearConfirmPrintWallet(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Wallet: Record "NPR AttractionWallet";
    begin
        Wallet.ReadIsolation := IsolationLevel::UpdLock;
        if (not GetWalletById(Request, 2, Wallet)) then
            exit(Response.RespondBadRequest(_InvalidWalletId));

        Wallet.LastPrintAt := 0DT;
        Wallet.Modify();

        exit(GetWalletAssetsResponse(Wallet, false));
    end;

    #endregion


    #region Helper methods
    local procedure WalletContentDTO(ResponseJson: Codeunit "NPR Json Builder"; Wallet: Record "NPR AttractionWallet"; LanguageCode: Code[10]): Codeunit "NPR Json Builder"
    var
        AttractionWallet: Codeunit "NPR AttractionWallet";
        ExternalReference: Text[100];
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
        ItemDescription: Text[250];
    begin

        ItemDescription := '';
        Item.SetLoadFields("No.", Description);
        if (Wallet.OriginatesFromItemNo <> '') then begin
            if (not Item.Get(Wallet.OriginatesFromItemNo)) then
                Item.Init();

            ItemDescription := Item.Description;
            if (ItemTranslation.Get(Wallet.OriginatesFromItemNo, '', LanguageCode)) then
                ItemDescription := ItemTranslation.Description;
        end;

        ResponseJson
            .AddProperty('walletId', Format(Wallet.SystemId, 0, 4).ToLower())
            .AddProperty('referenceNumber', Wallet.ReferenceNumber)
            .AddProperty('description', Wallet.Description)
            .AddProperty('originatesFromItemNo', Wallet.OriginatesFromItemNo)
            .AddProperty('originatesFromDescription', ItemDescription)
            .AddProperty('expiryDatetime', Wallet.ExpirationDate)
            .AddProperty('lastPrintedAt', Wallet.LastPrintAt)
            .AddProperty('printCount', Wallet.PrintCount);

        if (AttractionWallet.getWalletExternalReferenceNumber(Wallet.EntryNo, ExternalReference)) then
            ResponseJson.AddProperty('externalReferenceNumber', ExternalReference)
        else
            ResponseJson.AddProperty('externalReferenceNumber');

        exit(ResponseJson);
    end;

    local procedure GetWalletAssetsResponse(Wallet: Record "NPR AttractionWallet"; WithDetails: Boolean) Response: Codeunit "NPR API Response"
    var
        ResponseJson: Codeunit "NPR Json Builder";
    begin
        exit(Response.RespondOk(GetWalletAssetsDTO(ResponseJson, Wallet, true, WithDetails, '').Build()));
    end;

    local procedure GetWalletAssetsResponse(Wallet: Record "NPR AttractionWallet"; WithDetails: Boolean; LanguageCode: Code[10]) Response: Codeunit "NPR API Response"
    var
        ResponseJson: Codeunit "NPR Json Builder";
    begin
        exit(Response.RespondOk(GetWalletAssetsDTO(ResponseJson, Wallet, true, WithDetails, LanguageCode).Build()));
    end;

    local procedure GetWalletAssetsDTO(var ResponseJson: Codeunit "NPR Json Builder"; Wallet: Record "NPR AttractionWallet"; WithAssets: Boolean; WithDetails: Boolean; LanguageCode: Code[10]): Codeunit "NPR Json Builder"
    var
        WalletAssets: Query "NPR AttractionWalletAssets";
        Ticket: Record "NPR TM Ticket";
        ItemTranslation: Record "Item Translation";
        ItemDescription: Text[250];
    begin
        ResponseJson := WalletContentDTO(ResponseJson.StartObject(), Wallet, LanguageCode);
        if (not WithAssets) then
            exit(ResponseJson.EndObject());

        ResponseJson.StartArray('assets');

        WalletAssets.SetFilter(WalletSystemId, '=%1', Wallet.SystemId);
        WalletAssets.Open();
        while (WalletAssets.Read()) do begin

            ItemDescription := WalletAssets.AssetDescription;
            if (ItemTranslation.Get(WalletAssets.AssetItemNo, '', LanguageCode)) then
                ItemDescription := ItemTranslation.Description;

            ResponseJson.StartObject()
                .AddProperty('id', Format(WalletAssets.SystemId, 0, 4).ToLower())
                .AddProperty('type', WalletAssets.AssetType.Names.Get(WalletAssets.AssetType.Ordinals.IndexOf(WalletAssets.AssetType.AsInteger())).ToLower())
                .AddProperty('assetId', Format(WalletAssets.AssetSystemId, 0, 4).ToLower())
                .AddProperty('itemNo', WalletAssets.AssetItemNo)
                .AddProperty('description', ItemDescription)
                .AddProperty('referenceNumber', WalletAssets.AssetReferenceNumber)
                .AddProperty('isSuperseded', WalletAssets.SupersededByEntryNo <> 0)
                .AddObject(AddOptionalProperty(ResponseJson, 'expiryDatetime', WalletAssets.AssetExpirationDate));

            if (WithDetails) then begin
                if (WalletAssets.AssetType = WalletAssets.AssetType::Ticket) then begin
                    Ticket.GetBySystemId(WalletAssets.AssetSystemId);
                    ResponseJson.AddObject(AddTicketDetails(ResponseJson, Ticket, LanguageCode));
                end;

                if (WalletAssets.AssetType = WalletAssets.AssetType::MEMBERSHIP) then begin
                    // Add member card details in future
                    ResponseJson.StartObject('membershipDetails').EndObject();
                end;

                if (WalletAssets.AssetType = WalletAssets.AssetType::COUPON) then begin
                    // Add coupon details if in future
                    ResponseJson.StartObject('couponDetails').EndObject();
                end;

                if (WalletAssets.AssetType = WalletAssets.AssetType::VOUCHER) then begin
                    // Add voucher details in future
                    ResponseJson.StartObject('voucherDetails').EndObject();
                end;
            end;

            ResponseJson.EndObject();
        end;

        ResponseJson.EndArray()
            .EndObject();
        WalletAssets.Close();

        exit(ResponseJson);
    end;

    local procedure AddTicketDetails(ResponseJson: Codeunit "NPR Json Builder"; Ticket: Record "NPR TM Ticket"; LanguageCode: Code[10]): Codeunit "NPR Json Builder"
    var
        TicketAgent: Codeunit "NPR TicketingTicketAgent";
        TicketType: Record "NPR TM Ticket Type";
    begin
        TicketType.Get(Ticket."Ticket Type Code");

        ResponseJson
            .StartObject('ticketDetails')
            .AddObject(TicketAgent.TicketValidDateProperties(ResponseJson, Ticket))
            .AddObject(TicketAgent.AdmissionDetailsDTO(ResponseJson, 'content', Ticket, LanguageCode))
            .AddArray(TicketAgent.TicketHistoryDTO(ResponseJson, 'accessHistory', Ticket, TicketType, false))
            .EndObject();
        exit(ResponseJson);
    end;

    local procedure AddOptionalProperty(Json: Codeunit "NPR Json Builder"; PropertyName: Text; Value: DateTime): Codeunit "NPR Json Builder"
    begin
        if (Value <> 0DT) then
            Json.AddProperty(PropertyName, Value);

        if (Value = 0DT) then
            Json.AddProperty(PropertyName);

        exit(Json);
    end;



    local procedure StoreTickets(Wallet: Record "NPR AttractionWallet"; Tickets: JsonArray)
    var
        Ticket, Ticket2 : Record "NPR TM Ticket";
        TicketToken: JsonToken;
        TicketId: Guid;
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
        TicketIds: List of [Guid];
    begin

        Ticket.SetLoadFields(SystemId);
        Ticket2.SetLoadFields("External Ticket No.", SystemId);
        Ticket2.SetCurrentKey("External Ticket No.");

        foreach TicketToken in Tickets do
            if (TicketToken.IsValue()) then begin
                if (Evaluate(TicketId, TicketToken.AsValue().AsText())) then begin
                    Ticket.GetBySystemId(TicketId);
                    TicketIds.Add(TicketId);
                end else begin
                    Ticket2.SetFilter("External Ticket No.", '=%1', CopyStr(TicketToken.AsValue().AsText(), 1, MaxStrLen(Ticket2."External Ticket No.")));
                    if (Ticket2.FindFirst()) then
                        TicketIds.Add(Ticket2.SystemId);
                end;
            end;

        AttractionWallet.AddTicketsToWallet(Wallet.EntryNo, TicketIds);

    end;

    local procedure StoreMemberCards(Wallet: Record "NPR AttractionWallet"; MemberCards: JsonArray)
    var
        MemberCard, MemberCard2 : Record "NPR MM Member Card";
        MemberCardToken: JsonToken;
        MemberCardId: Guid;
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
        MemberCardIds: List of [Guid];
    begin

        MemberCard.SetLoadFields(SystemId);
        MemberCard2.SetLoadFields("External Card No.", SystemId);
        MemberCard2.SetCurrentKey("External Card No.");

        foreach MemberCardToken in MemberCards do
            if (MemberCardToken.IsValue()) then begin
                if (Evaluate(MemberCardId, MemberCardToken.AsValue().AsText())) then begin
                    MemberCard.GetBySystemId(MemberCardId);
                    MemberCardIds.Add(MemberCardId);
                end else begin
                    MemberCard2.SetFilter("External Card No.", '=%1', CopyStr(MemberCardToken.AsValue().AsText(), 1, MaxStrLen(MemberCard2."External Card No.")));
                    if (MemberCard2.FindFirst()) then
                        MemberCardIds.Add(MemberCard2.SystemId);
                end;
            end;

        AttractionWallet.AddMemberCardsToWallet(Wallet.EntryNo, MemberCardIds);
    end;

    local procedure StoreCoupons(Wallet: Record "NPR AttractionWallet"; Coupons: JsonArray)
    var
        Coupon, Coupon2 : Record "NPR NpDc Coupon";
        CouponToken: JsonToken;
        CouponId: Guid;
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
        CouponIds: List of [Guid];
    begin

        Coupon.SetLoadFields(SystemId);
        Coupon2.SetLoadFields("Reference No.", SystemId);
        Coupon2.SetCurrentKey("Reference No.");

        foreach CouponToken in Coupons do
            if (CouponToken.IsValue()) then begin
                if (Evaluate(CouponId, CouponToken.AsValue().AsText())) then begin
                    Coupon.GetBySystemId(CouponId);
                    CouponIds.Add(CouponId);
                end else begin
                    Coupon2.SetFilter("Reference No.", '=%1', CopyStr(CouponToken.AsValue().AsText(), 1, MaxStrLen(Coupon2."Reference No.")));
                    if (Coupon2.FindFirst()) then
                        CouponIds.Add(Coupon2.SystemId);
                end;
            end;

        AttractionWallet.AddCouponsToWallets(Wallet.EntryNo, CouponIds, '', '');
    end;

    local procedure StoreVouchers(Wallet: Record "NPR AttractionWallet"; Vouchers: JsonArray)
    var
        Voucher, Voucher2 : Record "NPR NpRv Voucher";
        VoucherToken: JsonToken;
        VoucherId: Guid;
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
        VoucherIds: List of [Guid];
    begin

        Voucher.SetLoadFields("Reference No.", SystemId);
        Voucher2.SetLoadFields("Reference No.", SystemId);
        Voucher2.SetCurrentKey("Reference No.");

        foreach VoucherToken in Vouchers do
            if (VoucherToken.IsValue()) then begin
                if (Evaluate(VoucherId, VoucherToken.AsValue().AsText())) then begin
                    Voucher.GetBySystemId(VoucherId);
                    VoucherIds.Add(VoucherId);
                end else begin
                    Voucher2.SetFilter("Reference No.", '=%1', CopyStr(VoucherToken.AsValue().AsText(), 1, MaxStrLen(Voucher2."Reference No.")));
                    if (Voucher2.FindFirst()) then
                        VoucherIds.Add(Voucher2.SystemId);
                end;
            end;

        AttractionWallet.AddVouchersToWallets(Wallet.EntryNo, VoucherIds, '', '');
    end;


    local procedure AddWalletExternalReferences(Wallet: Record "NPR AttractionWallet"; References: JsonArray)
    var
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
        Reference: JsonToken;
        NullGuid: Guid;
    begin
        foreach Reference in References do
            if (Reference.IsValue()) then
                AttractionWallet.SetWalletReferenceNumber(Wallet.EntryNo, 0, NullGuid, CopyStr(Reference.AsValue().AsText(), 1, 100));
    end;

    local procedure GetWalletById(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var Wallet: Record "NPR AttractionWallet"): Boolean
    var
        WalletIdText: Text[50];
        WalletId: Guid;
    begin
        WalletIdText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(WalletIdText));
        if (WalletIdText = '') then
            exit(false);

        if (not Evaluate(WalletId, WalletIdText)) then
            exit(false);

        if (not Wallet.GetBySystemId(WalletId)) then
            exit(false);

        exit(true);
    end;

    local procedure GetAssetLineById(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var AssetLine: Record "NPR WalletAssetLine"): Boolean
    var
        IdText: Text[50];
        Id: Guid;
    begin
        IdText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(IdText));
        if (IdText = '') then
            exit(false);

        if (not Evaluate(Id, IdText)) then
            exit(false);

        if (not AssetLine.GetBySystemId(Id)) then
            exit(false);

        exit(true);
    end;

    #endregion
}
#endif