codeunit 6151534 "NPR CMOrderDistribution"
{
    Access = Internal;

    #region Queue
    internal procedure QueueOrderConfirmation(var Order: Record "NPR CMOrder")
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
        NoManifest: Guid;
    begin
        if (Order.SellToEmail = '') then
            exit;
        if (not GetNPMailPartner(Order, PartnerSetup)) then
            exit;
        if (PartnerSetup.OrderConfirmationTemplateId = '') then
            exit;
        if (HasNotification(Order, "NPR Dig. Notif. Type"::"Order Confirmation")) then
            exit;

        InsertNotification(Order, "NPR Dig. Notif. Type"::"Order Confirmation", PartnerSetup.OrderConfirmationTemplateId, NoManifest, Order.SellToEmail, Order.SellToName, Order.SellToLanguage);
    end;

    internal procedure QueueNewOrderConfirmation(var Order: Record "NPR CMOrder")
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
        NoManifest: Guid;
        NoNPMailErr: Label 'Partner %1 does not send bookings by %2.', Comment = '%1 = partner name, %2 = the NP Mail distribution';
        NoTemplateErr: Label '%1 is not set on partner %2.', Comment = '%1 = Order Confirmation Email Template field caption, %2 = partner name';
        NoEmailErr: Label 'Booking %1 has no %2.', Comment = '%1 = booking reference, %2 = Sell-to Email field caption';
    begin
        PartnerSetup.Get(Order.PartnerId);
        if (PartnerSetup.Distribution <> PartnerSetup.Distribution::NPMail) then
            Error(NoNPMailErr, PartnerSetup.Name, Format(PartnerSetup.Distribution::NPMail));
        if (PartnerSetup.OrderConfirmationTemplateId = '') then
            Error(NoTemplateErr, PartnerSetup.FieldCaption(OrderConfirmationTemplateId), PartnerSetup.Name);
        if (Order.SellToEmail = '') then
            Error(NoEmailErr, Order.DocumentNo, Order.FieldCaption(SellToEmail));
        ValidateHasWallets(Order);

        InsertNotification(Order, "NPR Dig. Notif. Type"::"Order Confirmation", PartnerSetup.OrderConfirmationTemplateId, NoManifest, Order.SellToEmail, Order.SellToName, Order.SellToLanguage);
    end;

    // One wallet mail per recipient: a line with its own e-mail address sends its wallets there instead of to the booking's address.
    internal procedure QueueWalletNotification(var Order: Record "NPR CMOrder")
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
        OrderLine: Record "NPR CMOrderLine";
        QueuedRecipients: List of [Text];
        Recipient: Text;
    begin
        if (not GetNPMailPartner(Order, PartnerSetup)) then
            exit;
        if (PartnerSetup.WalletEmailTemplateId = '') then
            exit;
        if (IsNullGuid(Order.ManifestId)) then
            exit;

        OrderLine.SetFilter(OrderId, '=%1', Order.OrderId);
        if (not OrderLine.FindSet()) then
            exit;

        repeat
            Recipient := GetLineRecipient(Order, OrderLine);
            if (Recipient <> '') then
                if (not QueuedRecipients.Contains(Recipient)) then begin
                    QueuedRecipients.Add(Recipient);
                    if (not HasRecipientNotification(Order, "NPR Dig. Notif. Type"::"Digital Assets", Recipient)) then
                        InsertNotification(Order, "NPR Dig. Notif. Type"::"Digital Assets", PartnerSetup.WalletEmailTemplateId, Order.ManifestId, Recipient, GetLineRecipientName(Order, OrderLine), GetLineLanguage(Order, OrderLine));
                end;
        until (OrderLine.Next() = 0);
    end;

    local procedure GetNPMailPartner(var Order: Record "NPR CMOrder"; var PartnerSetup: Record "NPR CMPartnerSetup"): Boolean
    begin
        if (not PartnerSetup.Get(Order.PartnerId)) then
            exit(false);
        exit(PartnerSetup.Distribution = PartnerSetup.Distribution::NPMail);
    end;

    internal procedure DeleteUnsentNotifications(var Order: Record "NPR CMOrder")
    var
        NotifEntry: Record "NPR Digital Notification Entry";
    begin
        if (IsNullGuid(Order.OrderId)) then
            exit;

        NotifEntry.SetCurrentKey("Source Document Id", "Notification Type");
        NotifEntry.SetFilter("Source Document Id", '=%1', Order.OrderId);
        NotifEntry.SetFilter("Document Type", '=%1', NotifEntry."Document Type"::"Channel Manager Order");
        NotifEntry.SetFilter(Sent, '=%1', false);
        NotifEntry.DeleteAll();
    end;

    internal procedure AnonymizeNotifications(var Order: Record "NPR CMOrder"; AnonymizedAddress: Text[100]; var AffectedAssets: Dictionary of [Guid, Integer])
    var
        NotifEntry: Record "NPR Digital Notification Entry";
        HasChanges: Boolean;
    begin
        if (IsNullGuid(Order.OrderId)) then
            exit;

        // A mail still queued would go to the address being removed.
        DeleteUnsentNotifications(Order);

        NotifEntry.SetCurrentKey("Source Document Id", "Notification Type");
        NotifEntry.SetFilter("Source Document Id", '=%1', Order.OrderId);
        NotifEntry.SetFilter("Document Type", '=%1', NotifEntry."Document Type"::"Channel Manager Order");
        if (not NotifEntry.FindSet(true)) then
            exit;

        repeat
            HasChanges := false;

            if (not (NotifEntry."Recipient E-mail" in ['', AnonymizedAddress])) then begin
                NotifEntry."Recipient E-mail" := CopyStr(AnonymizedAddress, 1, MaxStrLen(NotifEntry."Recipient E-mail"));
                NotifEntry."Error Message" := '';
                HasChanges := true;
            end;

            if (NotifEntry."Recipient Name" <> '') then begin
                NotifEntry."Recipient Name" := '';
                HasChanges := true;
            end;

            if (HasChanges) then begin
                NotifEntry.Modify();
                AffectedAssets.Set(NotifEntry.SystemId, Database::"NPR Digital Notification Entry");
            end;
        until (NotifEntry.Next() = 0);
    end;

    internal procedure HasOrderConfirmation(var Order: Record "NPR CMOrder"): Boolean
    begin
        exit(HasNotification(Order, "NPR Dig. Notif. Type"::"Order Confirmation"));
    end;

    local procedure HasNotification(var Order: Record "NPR CMOrder"; NotificationType: Enum "NPR Dig. Notif. Type"): Boolean
    var
        NotifEntry: Record "NPR Digital Notification Entry";
    begin
        NotifEntry.SetCurrentKey("Source Document Id", "Notification Type");
        NotifEntry.SetFilter("Source Document Id", '=%1', Order.OrderId);
        NotifEntry.SetFilter("Notification Type", '=%1', NotificationType);
        exit(not NotifEntry.IsEmpty());
    end;

    local procedure HasRecipientNotification(var Order: Record "NPR CMOrder"; NotificationType: Enum "NPR Dig. Notif. Type"; Recipient: Text): Boolean
    var
        NotifEntry: Record "NPR Digital Notification Entry";
    begin
        NotifEntry.SetCurrentKey("Source Document Id", "Notification Type");
        NotifEntry.SetFilter("Source Document Id", '=%1', Order.OrderId);
        NotifEntry.SetFilter("Notification Type", '=%1', NotificationType);
        NotifEntry.SetFilter("Recipient E-mail", '=%1', CopyStr(Recipient, 1, MaxStrLen(NotifEntry."Recipient E-mail")));
        exit(not NotifEntry.IsEmpty());
    end;

    local procedure InsertNotification(var Order: Record "NPR CMOrder"; NotificationType: Enum "NPR Dig. Notif. Type"; EmailTemplateId: Code[20]; ManifestId: Guid; RecipientEmail: Text; RecipientName: Text[100]; LanguageCode: Code[10])
    var
        NotifEntry: Record "NPR Digital Notification Entry";
    begin
        InitNotification(NotifEntry, Order, NotificationType, EmailTemplateId, ManifestId, RecipientEmail, RecipientName, LanguageCode);
        NotifEntry.Insert(true);
    end;

    local procedure InitNotification(var NotifEntry: Record "NPR Digital Notification Entry"; var Order: Record "NPR CMOrder"; NotificationType: Enum "NPR Dig. Notif. Type"; EmailTemplateId: Code[20]; ManifestId: Guid; RecipientEmail: Text; RecipientName: Text[100]; LanguageCode: Code[10])
    begin
        NotifEntry.Init();
        NotifEntry."External Order No." := Order.DocumentNo;
        NotifEntry."Document Type" := NotifEntry."Document Type"::"Channel Manager Order";
        NotifEntry."Notification Type" := NotificationType;
        NotifEntry."Recipient E-mail" := CopyStr(LowerCase(RecipientEmail), 1, MaxStrLen(NotifEntry."Recipient E-mail"));
        NotifEntry."Recipient Name" := RecipientName;
        NotifEntry."Language Code" := LanguageCode;
        NotifEntry."Manifest ID" := ManifestId;
        NotifEntry."Email Template Id" := EmailTemplateId;
        NotifEntry."Source Document Id" := Order.OrderId;
    end;
    #endregion

    #region Mail data preview
    // The preview entry is never inserted; the providers only read its fields.
    internal procedure GetOrderConfirmationData(var Order: Record "NPR CMOrder") JsonText: Text
    var
        NotifEntry: Record "NPR Digital Notification Entry";
        OrderEmailDataProv: Codeunit "NPR CMOrderEmailDataProv";
        RecRef: RecordRef;
        NoManifest: Guid;
    begin
        ValidateHasWallets(Order);
        InitNotification(NotifEntry, Order, "NPR Dig. Notif. Type"::"Order Confirmation", '', NoManifest, Order.SellToEmail, Order.SellToName, Order.SellToLanguage);
        RecRef.GetTable(NotifEntry);
        OrderEmailDataProv.GetContent(RecRef).WriteTo(JsonText);
    end;

    internal procedure GetWalletMailData(var Order: Record "NPR CMOrder"; var OrderLine: Record "NPR CMOrderLine") JsonText: Text
    var
        NotifEntry: Record "NPR Digital Notification Entry";
        WalletsEmailDataProv: Codeunit "NPR CMWalletsEmailDataProv";
        RecRef: RecordRef;
    begin
        ValidateHasWallets(Order);
        InitNotification(NotifEntry, Order, "NPR Dig. Notif. Type"::"Digital Assets", '', Order.ManifestId, GetLineRecipient(Order, OrderLine), GetLineRecipientName(Order, OrderLine), GetLineLanguage(Order, OrderLine));
        RecRef.GetTable(NotifEntry);
        WalletsEmailDataProv.GetContent(RecRef).WriteTo(JsonText);
    end;

    local procedure ValidateHasWallets(var Order: Record "NPR CMOrder")
    var
        OrderWallet: Record "NPR CMOrderWallet";
        NoWalletsErr: Label 'Booking %1 has no wallets yet.', Comment = '%1 = booking reference';
    begin
        OrderWallet.SetFilter(OrderId, '=%1', Order.OrderId);
        if (OrderWallet.IsEmpty()) then
            Error(NoWalletsErr, Order.DocumentNo);
    end;
    #endregion

    #region Send
    // Runs from the CM job queue, as the Digital Notification job queue only exists when that setup is enabled for posted sales documents.
    internal procedure SendPendingNotifications()
    var
        NotifEntry: Record "NPR Digital Notification Entry";
        DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
        Sentry: Codeunit "NPR Sentry";
    begin
        DigitalNotificationSend.FilterNotificationsToSend(NotifEntry);
        NotifEntry.SetFilter("Document Type", '=%1', NotifEntry."Document Type"::"Channel Manager Order");
        if (not NotifEntry.FindSet()) then
            exit;

        repeat
            ClearLastError();
            if (not DigitalNotificationSend.SendNotification(NotifEntry)) then
                if (NotifEntry."Attempt Count" = 1) then
                    Sentry.AddLastErrorIfProgrammingBug();
        until (NotifEntry.Next() = 0);
    end;
    #endregion

    #region Mail content
    internal procedure GetLineRecipient(var Order: Record "NPR CMOrder"; var OrderLine: Record "NPR CMOrderLine"): Text
    begin
        if (OrderLine.NotificationAddress <> '') then
            exit(LowerCase(OrderLine.NotificationAddress));
        exit(LowerCase(Order.SellToEmail));
    end;

    internal procedure IsLineRecipient(var Order: Record "NPR CMOrder"; var OrderLine: Record "NPR CMOrderLine"; RecipientEmail: Text): Boolean
    var
        NotifEntry: Record "NPR Digital Notification Entry";
    begin
        exit(CopyStr(GetLineRecipient(Order, OrderLine), 1, MaxStrLen(NotifEntry."Recipient E-mail")) = LowerCase(RecipientEmail));
    end;

    local procedure GetLineRecipientName(var Order: Record "NPR CMOrder"; var OrderLine: Record "NPR CMOrderLine"): Text[100]
    begin
        if (OrderLine.Name <> '') then
            exit(OrderLine.Name);
        exit(Order.SellToName);
    end;

    local procedure GetLineLanguage(var Order: Record "NPR CMOrder"; var OrderLine: Record "NPR CMOrderLine"): Code[10]
    begin
        if (OrderLine.Language <> '') then
            exit(OrderLine.Language);
        exit(Order.SellToLanguage);
    end;

    internal procedure GetNotificationOrder(RecRef: RecordRef; var NotifEntry: Record "NPR Digital Notification Entry"; var Order: Record "NPR CMOrder"): Boolean
    var
        WrongRecordErr: Label 'The Channel Manager e-mail data providers expect a Digital Notification Entry, but got table %1. This is a programming bug.', Locked = true;
    begin
        if (RecRef.Number() <> Database::"NPR Digital Notification Entry") then
            Error(WrongRecordErr, RecRef.Number());

        RecRef.SetTable(NotifEntry);
        exit(Order.Get(NotifEntry."Source Document Id"));
    end;

    internal procedure AddRecipientFields(var JObject: JsonObject; var NotifEntry: Record "NPR Digital Notification Entry")
    begin
        JObject.Add('recipient_email', NotifEntry."Recipient E-mail");
        JObject.Add('recipient_name', NotifEntry."Recipient Name");
        JObject.Add('language_code', NotifEntry."Language Code");
        JObject.Add('notification_type', NotifEntry."Notification Type".Names.Get(NotifEntry."Notification Type".Ordinals.IndexOf(NotifEntry."Notification Type".AsInteger())));
    end;

    internal procedure GetItemDescription(ItemNo: Code[20]; LanguageCode: Code[10]): Text[100]
    var
        Item: Record Item;
        ItemTranslation: Record "Item Translation";
    begin
        if (LanguageCode <> '') then
            if (ItemTranslation.Get(ItemNo, '', LanguageCode)) then
                exit(ItemTranslation.Description);

        Item.SetLoadFields(Description);
        if (Item.Get(ItemNo)) then
            exit(Item.Description);
    end;

    internal procedure FormatVisitDate(VisitDate: Date): Text
    begin
        if (VisitDate = 0D) then
            exit('');
        exit(Format(VisitDate, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    internal procedure FormatVisitTime(VisitTime: Time): Text
    begin
        if (VisitTime = 0T) then
            exit('');
        exit(Format(VisitTime, 0, '<Hours24,2><Filler Character,0>:<Minutes,2>'));
    end;

    internal procedure FormatAmount(Amount: Decimal): Text
    begin
        exit(Format(Amount, 0, '<Precision,2><Standard Format,2>'));
    end;
    #endregion
}
