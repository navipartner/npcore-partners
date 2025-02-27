#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248331 "NPR WalletApiAgent"
{
    Access = Internal;

    var
        _InvalidWalletId: Label 'Invalid wallet id', Locked = true;


    #region API functions
    internal procedure FindWalletUsingReferenceNumber(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ReferenceNumber: Text;
        FindWallet: Query "NPR FindAttractionWallets";
        ResponseJson: Codeunit "NPR Json Builder";
        ReferenceNumberRequired: Label 'Missing required parameter: referenceNumber', Locked = true;
    begin

        if (not Request.QueryParams().ContainsKey('referenceNumber')) then
            exit(Response.RespondBadRequest(ReferenceNumberRequired));

        ReferenceNumber := Request.QueryParams().Get('referenceNumber');
        if (ReferenceNumber = '') then
            exit(Response.RespondBadRequest(ReferenceNumberRequired));

        ResponseJson.StartArray();

        FindWallet.SetFilter(ReferenceNumber, '=%1', ReferenceNumber);
        FindWallet.Open();
        while (FindWallet.Read()) do begin
            ResponseJson.StartObject()
                .AddProperty('walletId', Format(FindWallet.WalletSystemId, 0, 4).ToLower())
                .AddProperty('referenceNumber', FindWallet.WalletReferenceNumber)
                .AddProperty('description', FindWallet.WalletDescription)
                .AddProperty('expiryDatetime', FindWallet.WalletExpirationDate)
                .AddProperty('lastPrintedAt', FindWallet.WalletLastPrintAt)
                .AddProperty('printCount', FindWallet.WalletPrintCount)
                .EndObject();
        end;
        ResponseJson.EndArray();
        FindWallet.Close();

        exit(Response.RespondOk(ResponseJson.BuildAsArray()));
    end;

    internal procedure GetWalletUsingId(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Wallet: Record "NPR AttractionWallet";
    begin

        if (not GetWalletById(Request, 2, Wallet)) then
            exit(Response.RespondBadRequest(_InvalidWalletId));

        exit(GetAssetsResponse(Wallet));

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

        exit(GetAssetsResponse(Wallet));
    end;

    internal procedure CreateWallet(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Wallet: Record "NPR AttractionWallet";
        WalletReferenceNumber: Text[50];
        WalletName: Text[100];
        Body: JsonObject;
        JToken: JsonToken;
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
    begin
        Wallet.Init();

        Body := Request.BodyJson().AsObject();
        if (Body.Get('name', JToken)) then
            WalletName := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(WalletName));

        Wallet.Get(AttractionWallet.CreateWallet(WalletName, WalletReferenceNumber));

        if (Body.Get('tickets', JToken)) then
            if (JToken.IsArray()) then
                StoreTickets(Wallet, JToken.AsArray());

        if (Body.Get('memberCards', JToken)) then
            if (JToken.IsArray()) then
                StoreMemberCards(Wallet, JToken.AsArray());

        exit(GetAssetsResponse(Wallet));
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

    #endregion


    #region Helper methods
    local procedure GetAssetsResponse(Wallet: Record "NPR AttractionWallet") Response: Codeunit "NPR API Response"
    var
        WalletAssets: Query "NPR AttractionWalletAssets";
        ResponseJson: Codeunit "NPR Json Builder";
    begin
        ResponseJson.StartObject()
            .AddProperty('walletId', Format(Wallet.SystemId, 0, 4).ToLower())
            .AddProperty('referenceNumber', Wallet.ReferenceNumber)
            .AddProperty('description', Wallet.Description)
            .AddProperty('expiryDatetime', Wallet.ExpirationDate)
            .AddProperty('lastPrintedAt', Wallet.LastPrintAt)
            .AddProperty('printCount', Wallet.PrintCount)
            .StartArray('assets');

        WalletAssets.SetFilter(WalletSystemId, '=%1', Wallet.SystemId);
        WalletAssets.Open();
        while (WalletAssets.Read()) do begin
            ResponseJson.StartObject()
                .AddProperty('id', Format(WalletAssets.SystemId, 0, 4).ToLower())

                .AddProperty('type', WalletAssets.AssetType.Names.Get(WalletAssets.AssetType.Ordinals.IndexOf(WalletAssets.AssetType.AsInteger())).ToLower())
                .AddProperty('assetId', Format(WalletAssets.AssetSystemId, 0, 4).ToLower())
                .AddProperty('itemNo', WalletAssets.AssetItemNo)
                .AddProperty('description', WalletAssets.AssetDescription)
                .AddProperty('referenceNumber', WalletAssets.AssetReferenceNumber)
                .AddProperty('isSuperseded', WalletAssets.SupersededByEntryNo <> 0)
                .AddObject(AddOptionalProperty(ResponseJson, 'expiryDatetime', WalletAssets.AssetExpirationDate))
                .EndObject();
        end;

        ResponseJson.EndArray()
            .EndObject();
        WalletAssets.Close();

        exit(Response.RespondOk(ResponseJson.Build()));
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
        Ticket: Record "NPR TM Ticket";
        TicketToken: JsonToken;
        TicketId: Guid;
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
        TicketIds: List of [Guid];
    begin

        foreach TicketToken in Tickets do
            if (TicketToken.IsValue()) then begin
                Evaluate(TicketId, TicketToken.AsValue().AsText());
                Ticket.GetBySystemId(TicketId);
                TicketIds.Add(TicketId);
            end;

        AttractionWallet.AddTicketsToWallet(Wallet.EntryNo, TicketIds);

    end;

    local procedure StoreMemberCards(Wallet: Record "NPR AttractionWallet"; MemberCards: JsonArray)
    var
        MemberCard: Record "NPR MM Member Card";
        MemberCardToken: JsonToken;
        MemberCardId: Guid;
        AttractionWallet: Codeunit "NPR AttractionWalletFacade";
        MemberCardIds: List of [Guid];
    begin

        foreach MemberCardToken in MemberCards do
            if (MemberCardToken.IsValue()) then begin
                Evaluate(MemberCardId, MemberCardToken.AsValue().AsText());
                MemberCard.GetBySystemId(MemberCardId);
                MemberCardIds.Add(MemberCardId);
            end;

        AttractionWallet.AddMemberCardsToWallet(Wallet.EntryNo, MemberCardIds);
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