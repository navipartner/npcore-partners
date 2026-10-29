codeunit 6151586 "NPR CMWalletsEmailDataProv" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        NotifEntry: Record "NPR Digital Notification Entry";
        Order: Record "NPR CMOrder";
        OrderLine: Record "NPR CMOrderLine";
        OrderWallet: Record "NPR CMOrderWallet";
        Distribution: Codeunit "NPR CMOrderDistribution";
        JObject: JsonObject;
        JWallets: JsonArray;
        BookingManifestUrl: Text;
    begin
        if (not Distribution.GetNotificationOrder(RecRef, NotifEntry, Order)) then
            exit(JObject);

        // The booking's manifest shows every wallet of the booking, so only the booking's own recipient gets it.
        if (CopyStr(LowerCase(Order.SellToEmail), 1, MaxStrLen(NotifEntry."Recipient E-mail")) = NotifEntry."Recipient E-mail") then
            BookingManifestUrl := Order.ManifestUrl;

        Distribution.AddRecipientFields(JObject, NotifEntry);
        JObject.Add('manifest_url', BookingManifestUrl);

        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        if (OrderLine.FindSet()) then
            repeat
                if (Distribution.IsLineRecipient(Order, OrderLine, NotifEntry."Recipient E-mail")) then begin
                    OrderWallet.SetFilter(OrderId, '=%1', OrderLine.OrderId);
                    OrderWallet.SetFilter(LineNo, '=%1', OrderLine.LineNo);
                    if (OrderWallet.FindSet()) then
                        repeat
                            JWallets.Add(GetWalletJson(OrderLine, OrderWallet, NotifEntry."Language Code"));
                        until (OrderWallet.Next() = 0);
                end;
            until (OrderLine.Next() = 0);

        JObject.Add('wallets', JWallets);
        exit(JObject);
    end;

    local procedure GetWalletJson(var OrderLine: Record "NPR CMOrderLine"; var OrderWallet: Record "NPR CMOrderWallet"; LanguageCode: Code[10]) JWallet: JsonObject
    var
        Distribution: Codeunit "NPR CMOrderDistribution";
    begin
        JWallet.Add('external_reference_number', OrderWallet.ExternalReferenceNumber);
        JWallet.Add('name', OrderWallet.WalletName);
        JWallet.Add('description', Distribution.GetItemDescription(OrderLine.ItemNo, LanguageCode));
        JWallet.Add('visit_date', Distribution.FormatVisitDate(OrderLine.VisitDate));
        JWallet.Add('visit_time', Distribution.FormatVisitTime(OrderLine.VisitTime));
        JWallet.Add('manifest_url', OrderWallet.ManifestUrl);
        JWallet.Add('assets', GetAssetsJson(OrderWallet.WalletEntryNo, LanguageCode));
    end;

    local procedure GetAssetsJson(WalletEntryNo: Integer; LanguageCode: Code[10]) JAssets: JsonArray
    var
        AssetRef: Record "NPR WalletAssetLineReference";
        AssetLine: Record "NPR WalletAssetLine";
    begin
        if (WalletEntryNo = 0) then
            exit;

        AssetRef.SetCurrentKey(WalletEntryNo);
        AssetRef.SetFilter(WalletEntryNo, '=%1', WalletEntryNo);
        AssetRef.SetFilter(SupersededBy, '=%1', 0);
        if (not AssetRef.FindSet()) then
            exit;

        repeat
            if (AssetLine.Get(AssetRef.WalletAssetLineEntryNo)) then
                case AssetLine.Type of
                    AssetLine.Type::Ticket:
                        AddTicketAsset(JAssets, AssetLine, LanguageCode);
                    AssetLine.Type::Coupon:
                        AddCouponAsset(JAssets, AssetLine, LanguageCode);
                end;
        until (AssetRef.Next() = 0);
    end;

    local procedure AddTicketAsset(var JAssets: JsonArray; var AssetLine: Record "NPR WalletAssetLine"; LanguageCode: Code[10])
    var
        Ticket: Record "NPR TM Ticket";
        Distribution: Codeunit "NPR CMOrderDistribution";
        JAsset: JsonObject;
        VisitDate: Date;
        VisitTime: Time;
    begin
        if (not Ticket.GetBySystemId(AssetLine.LineTypeSystemId)) then
            exit;

        GetTicketVisit(Ticket, VisitDate, VisitTime);
        JAsset.Add('description', Distribution.GetItemDescription(Ticket."Item No.", LanguageCode));
        JAsset.Add('visit_date', Distribution.FormatVisitDate(VisitDate));
        JAsset.Add('visit_time', Distribution.FormatVisitTime(VisitTime));
        JAssets.Add(JAsset);
    end;

    local procedure AddCouponAsset(var JAssets: JsonArray; var AssetLine: Record "NPR WalletAssetLine"; LanguageCode: Code[10])
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponSetup: Record "NPR WalletCouponSetup";
        Distribution: Codeunit "NPR CMOrderDistribution";
        JAsset: JsonObject;
        Description: Text;
    begin
        if (not Coupon.GetBySystemId(AssetLine.LineTypeSystemId)) then
            exit;

        Description := Coupon.Description;
        if (CouponSetup.Get(Coupon."Coupon Type")) then
            if (CouponSetup.TriggerOnItemNo <> '') then
                Description := Distribution.GetItemDescription(CouponSetup.TriggerOnItemNo, LanguageCode);

        JAsset.Add('description', Description);
        JAsset.Add('visit_date', '');
        JAsset.Add('visit_time', '');
        JAssets.Add(JAsset);
    end;

    local procedure GetTicketVisit(var Ticket: Record "NPR TM Ticket"; var VisitDate: Date; var VisitTime: Time)
    var
        AccessEntry: Record "NPR TM Ticket Access Entry";
        DetAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        VisitDate := Ticket."Valid From Date";
        VisitTime := 0T;

        AccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
        AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        if (not AccessEntry.FindFirst()) then
            exit;

        DetAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
        DetAccessEntry.SetFilter(Type, '=%1', DetAccessEntry.Type::RESERVATION);
        if (DetAccessEntry.IsEmpty()) then
            DetAccessEntry.SetFilter(Type, '=%1', DetAccessEntry.Type::INITIAL_ENTRY);
        if (not DetAccessEntry.FindFirst()) then
            exit;
        if (DetAccessEntry."External Adm. Sch. Entry No." = 0) then
            exit;

        ScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetAccessEntry."External Adm. Sch. Entry No.");
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not ScheduleEntry.FindLast()) then
            exit;

        VisitDate := ScheduleEntry."Admission Start Date";
        VisitTime := ScheduleEntry."Event Arrival From Time";
        if (VisitTime = 0T) then
            VisitTime := ScheduleEntry."Admission Start Time";
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject: JsonObject;
        JWallets: JsonArray;
        JWallet: JsonObject;
        JAssets: JsonArray;
        JEntryTicket: JsonObject;
        JGhostHouse: JsonObject;
    begin
        JObject.Add('recipient_email', 'groups@example-hotel.com');
        JObject.Add('recipient_name', 'Example Hotel');
        JObject.Add('language_code', 'ENU');
        JObject.Add('notification_type', 'Digital Assets');
        JObject.Add('manifest_url', 'https://example.com/manifest/booking');

        JEntryTicket.Add('description', 'Entry ticket');
        JEntryTicket.Add('visit_date', '2026-11-04');
        JEntryTicket.Add('visit_time', '12:00');
        JAssets.Add(JEntryTicket);
        JGhostHouse.Add('description', 'Ghost house');
        JGhostHouse.Add('visit_date', '2026-11-04');
        JGhostHouse.Add('visit_time', '14:15');
        JAssets.Add(JGhostHouse);

        JWallet.Add('external_reference_number', 'W-000123-1');
        JWallet.Add('name', 'Guest 1');
        JWallet.Add('description', 'Day package');
        JWallet.Add('visit_date', '2026-11-04');
        JWallet.Add('visit_time', '12:00');
        JWallet.Add('manifest_url', 'https://example.com/manifest/wallet-1');
        JWallet.Add('assets', JAssets);
        JWallets.Add(JWallet);

        JObject.Add('wallets', JWallets);
        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
    end;
}
