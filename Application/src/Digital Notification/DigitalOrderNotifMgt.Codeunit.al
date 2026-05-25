#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6150961 "NPR Digital Order Notif. Mgt."
{
    Access = Internal;

    var
        _DigitalNotifSetup: Record "NPR Digital Notification Setup";
        _DigitalNotifSetupLoaded: Boolean;

    #region Automatic Notification (Event Subscribers)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDocSendDigitalOrderConfirmation(
        var SalesHeader: Record "Sales Header";
        SalesInvHdrNo: Code[20];
        SalesCrMemoHdrNo: Code[20])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
    begin
        if not SalesHeader.Invoice then
            exit;

        if not ValidateDigitalNotifSetup() then
            exit;

        if not IsManifestFeatureEnabled() then
            exit;

        if SalesHeader."NPR External Order No." = '' then
            exit;

        // Skip notification for ecom-originated orders - handled by ecom notification flow
        if not IsNullGuid(SalesHeader."NPR Inc Ecom Sale Id") then
            exit;

        if SalesHeader.IsCreditDocType() then begin
            if SalesHeader.Correction then
                exit;
            if not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
                exit;
            PopulateBuffersFromCrMemo(SalesCrMemoHeader, "NPR Dig. Notif. Type"::"Digital Assets", TempHeaderBuffer, TempLineBuffer);
        end else begin
            if not SalesInvHeader.Get(SalesInvHdrNo) then
                exit;
            PopulateBuffersFromInvoice(SalesInvHeader, "NPR Dig. Notif. Type"::"Digital Assets", TempHeaderBuffer, TempLineBuffer);
        end;

        ProcessSalesDocument(TempHeaderBuffer, TempLineBuffer);
    end;

    internal procedure SyncBucketIdToNotifEntry(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
    begin
        DigitalNotifEntry.SetRange("Source Document Id", EcomSalesHeader.SystemId);
        DigitalNotifEntry.ModifyAll("Bucket Id", EcomSalesHeader."Bucket Id");
    end;

    internal procedure TryCreateEcomDigitalNotification(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        LockedEcomSalesHeader: Record "NPR Ecom Sales Header";
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
    begin
        if EcomSalesHeader."Virtual Items Process Status" <> EcomSalesHeader."Virtual Items Process Status"::Processed then
            exit;

        if not ValidateDigitalNotifSetup() then
            exit;

        if not IsManifestFeatureEnabled() then
            exit;

        // Serialize concurrent last-one-done callers for the same doc.
        // Example race: coupon JQ and wallet JQ both finish their last line at the same instant — both read
        // "Virtual Items Process Status = Processed" and call this procedure concurrently. Without the lock, both
        // could pass EcomDigitalNotifEntryExists and insert duplicate entries.
        LockedEcomSalesHeader.ReadIsolation := IsolationLevel::UpdLock;
        if not LockedEcomSalesHeader.Get(EcomSalesHeader."Entry No.") then
            exit;

        // Re-check under the lock using authoritative row state (passed-in record may be stale).
        if LockedEcomSalesHeader."Virtual Items Process Status" <> LockedEcomSalesHeader."Virtual Items Process Status"::Processed then
            exit;

        if EcomDigitalNotifEntryExists(LockedEcomSalesHeader.SystemId, "NPR Dig. Notif. Type"::"Digital Assets") then
            exit;

        PopulateBuffersFromEcomDoc(LockedEcomSalesHeader, "NPR Dig. Notif. Type"::"Digital Assets", TempHeaderBuffer, TempLineBuffer);

        ProcessSalesDocument(TempHeaderBuffer, TempLineBuffer);
    end;

    internal procedure TryCreateEcomOrderConfirmationNotification(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        LockedEcomSalesHeader: Record "NPR Ecom Sales Header";
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
    begin
        if not ValidateOrderConfirmationSetup() then
            exit;

        // Called synchronously from API doc creation (EcomSalesDocApiAgentV2.CreateIncomingEcomDocument);
        // there are no concurrent callers for a fresh doc, so the UpdLock alone is sufficient and we
        // intentionally do not re-check row state under the lock (unlike TryCreateEcomDigitalNotification,
        // which is called from multiple async virtual-item JQs and re-checks Virtual Items Process Status).
        // Revisit if this trigger ever moves to a JQ.
        LockedEcomSalesHeader.ReadIsolation := IsolationLevel::UpdLock;
        if not LockedEcomSalesHeader.Get(EcomSalesHeader."Entry No.") then
            exit;

        if EcomDigitalNotifEntryExists(LockedEcomSalesHeader.SystemId, "NPR Dig. Notif. Type"::"Order Confirmation") then
            exit;

        PopulateBuffersFromEcomDoc(LockedEcomSalesHeader, "NPR Dig. Notif. Type"::"Order Confirmation", TempHeaderBuffer, TempLineBuffer);

        ProcessSalesDocument(TempHeaderBuffer, TempLineBuffer);
    end;

    #endregion

    #region Manual Notification Sending
    internal procedure SendDigitalOrderNotificationManual(RecVariant: Variant; NotificationType: Enum "NPR Dig. Notif. Type")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        RecRef: RecordRef;
        ErrorMessage: Text;
        DigitalAssetsSuccessMsg: Label 'Digital notification has been queued for sending. The customer will receive the email shortly.';
        NoAssetsMsg: Label 'No digital assets (tickets, vouchers) were found in this document. No notification has been created.';
        OrderConfirmationSuccessMsg: Label 'Order confirmation notification has been queued for sending. The customer will receive the email shortly.';
        OrderConfirmationFailedMsg: Label 'Order confirmation notification could not be created (recipient email is missing).';
        OrderConfirmationNotEnabledErr: Label 'Order Confirmation is not enabled in the Digital Notification setup.';
        OrderConfirmationOnlyForEcomErr: Label 'Order Confirmation notifications can only be sent for %1 documents.', Comment = '%1 = NPR Ecom Sales Header table caption';
        Success: Boolean;
    begin
        // Order Confirmation is only meaningful for Ecom Sales Documents — the JSON shape, manifest URL,
        // and payment-line block all assume ecom semantics. Reject invalid combinations early before
        // ProcessSalesDocumentManual creates a stranded OC entry tied to a posted invoice / cr.memo.
        if NotificationType = NotificationType::"Order Confirmation" then begin
            RecRef.GetTable(RecVariant);
            if RecRef.Number <> Database::"NPR Ecom Sales Header" then
                Error(OrderConfirmationOnlyForEcomErr, EcomSalesHeader.TableCaption);
        end;

        case NotificationType of
            "NPR Dig. Notif. Type"::"Digital Assets":
                if not ValidateDigitalNotifSetup(ErrorMessage) then
                    Error(ErrorMessage);
            "NPR Dig. Notif. Type"::"Order Confirmation":
                if not ValidateOrderConfirmationSetup() then
                    Error(OrderConfirmationNotEnabledErr);
        end;

        Success := ProcessSalesDocumentManual(RecVariant, NotificationType);

        case NotificationType of
            "NPR Dig. Notif. Type"::"Digital Assets":
                if Success then
                    Message(DigitalAssetsSuccessMsg)
                else
                    Message(NoAssetsMsg);
            "NPR Dig. Notif. Type"::"Order Confirmation":
                if Success then
                    Message(OrderConfirmationSuccessMsg)
                else
                    Message(OrderConfirmationFailedMsg);
        end;
    end;

    local procedure ProcessSalesDocumentManual(RecVariant: Variant; NotificationType: Enum "NPR Dig. Notif. Type"): Boolean
    var
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        RecRef: RecordRef;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        MailManagement: Codeunit "Mail Management";
        UnsupportedDocumentTypeErr: Label 'Document type %1 is not supported for manual digital notification sending.', Comment = '%1 = Record name';
        UnprocessedEntryExistsQst: Label 'An unprocessed digital notification entry already exists for this document and is still being retried. Do you want to create a new one anyway?';
    begin
        RecRef.GetTable(RecVariant);

        case RecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader := RecVariant;

                    if not ConfirmResendNotification(SalesInvoiceHeader.SystemId, NotificationType) then
                        Error('');

                    PopulateBuffersFromInvoice(SalesInvoiceHeader, NotificationType, TempHeaderBuffer, TempLineBuffer);
                end;

            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader := RecVariant;

                    if not ConfirmResendNotification(SalesCrMemoHeader.SystemId, NotificationType) then
                        Error('');

                    PopulateBuffersFromCrMemo(SalesCrMemoHeader, NotificationType, TempHeaderBuffer, TempLineBuffer);
                end;

            Database::"NPR Ecom Sales Header":
                begin
                    EcomSalesHeader := RecVariant;

                    if not ConfirmResendNotification(EcomSalesHeader.SystemId, NotificationType) then
                        Error('');

                    if HasUnprocessedNotifEntry(EcomSalesHeader.SystemId, NotificationType) then
                        if not Confirm(UnprocessedEntryExistsQst) then
                            Error('');

                    PopulateBuffersFromEcomDoc(EcomSalesHeader, NotificationType, TempHeaderBuffer, TempLineBuffer);
                end;
            else
                Error(UnsupportedDocumentTypeErr, RecRef.Name);
        end;

        if not PromptForRecipientEmail(TempHeaderBuffer) then
            Error('');
        MailManagement.CheckValidEmailAddresses(TempHeaderBuffer."Recipient E-mail");

        if not ProcessSalesDocument(TempHeaderBuffer, TempLineBuffer) then
            exit(false);

        exit(true);
    end;

    internal procedure SendPendingNotificationsManual(): Boolean
    var
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
        NotifEntry: Record "NPR Digital Notification Entry";
        DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
    begin
        if not ValidateAnyEcomNotifEnabled(DigitalNotifSetup) then
            exit(false);

        NotifEntry.SetRange(Sent, false);
        if DigitalNotifSetup."Max Attempts" > 0 then
            NotifEntry.SetFilter("Attempt Count", '<%1', DigitalNotifSetup."Max Attempts");

        if not NotifEntry.FindSet() then
            exit(false);

        repeat
            DigitalNotificationSend.SendNotification(NotifEntry);
        until NotifEntry.Next() = 0;
        Commit();
        exit(true);
    end;

    local procedure ConfirmResendNotification(SourceDocumentId: Guid; NotificationType: Enum "NPR Dig. Notif. Type"): Boolean
    var
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
    begin
        DigitalNotifEntry.SetRange("Source Document Id", SourceDocumentId);
        DigitalNotifEntry.SetRange("Notification Type", NotificationType);
        exit(ConfirmResendIfEntryExists(DigitalNotifEntry));
    end;

    local procedure ConfirmResendIfEntryExists(var DigitalNotifEntry: Record "NPR Digital Notification Entry"): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ResendConfirmQst: Label 'A digital notification has already been sent for this document. Do you want to send it again?';
    begin
        if DigitalNotifEntry.IsEmpty() then
            exit(true);
        exit(ConfirmManagement.GetResponseOrDefault(ResendConfirmQst, false));
    end;

    local procedure HasUnprocessedNotifEntry(EcomSalesHeaderId: Guid; NotificationType: Enum "NPR Dig. Notif. Type"): Boolean
    var
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
    begin
        DigitalNotifEntry.SetRange("Source Document Id", EcomSalesHeaderId);
        DigitalNotifEntry.SetRange("Notification Type", NotificationType);
        DigitalNotifEntry.SetRange(Sent, false);
        if ValidateAnyEcomNotifEnabled(DigitalNotifSetup) and (DigitalNotifSetup."Max Attempts" > 0) then
            DigitalNotifEntry.SetFilter("Attempt Count", '<%1', DigitalNotifSetup."Max Attempts");
        exit(not DigitalNotifEntry.IsEmpty());
    end;

    local procedure PromptForRecipientEmail(var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary): Boolean
    var
        InputDialog: Page "NPR Input Dialog";
        EmailAddress: Text;
        EmailAddressLbl: Label 'Email Address';
    begin
        EmailAddress := TempHeaderBuffer."Recipient E-mail";
        InputDialog.SetInput(1, EmailAddress, EmailAddressLbl);
        if not (InputDialog.RunModal() = Action::OK) then
            exit(false);

        InputDialog.InputText(1, EmailAddress);
        TempHeaderBuffer."Recipient E-mail" := CopyStr(EmailAddress, 1, MaxStrLen(TempHeaderBuffer."Recipient E-mail"));
        TempHeaderBuffer.Modify();
        exit(true);
    end;
    #endregion

    #region Document Processing
    local procedure ProcessSalesDocument(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary): Boolean
    var
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
        ManifestId, NullGuid : Guid;
        AssetsAdded: Integer;
    begin
        if TempHeaderBuffer."Recipient E-mail" = '' then
            exit(false);

        if TempHeaderBuffer."Notification Type" = "NPR Dig. Notif. Type"::"Order Confirmation" then begin
            CreateNotificationEntry(TempHeaderBuffer, NullGuid);
            exit(true);
        end;

        ManifestId := NPDesignerManifestFacade.CreateManifest();
        if IsNullGuid(ManifestId) then
            exit(false);

        if TempHeaderBuffer."Language Code" <> '' then
            NPDesignerManifestFacade.SetPreferredRenderingLanguage(ManifestId, TempHeaderBuffer."Language Code");

        AssetsAdded := 0;
        ProcessSalesDocumentLines(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);

        case AssetsAdded of
            0:
                begin
                    NPDesignerManifestFacade.DeleteManifest(ManifestId);
                    ManifestId := NullGuid;
                    exit(false);  // Skip email notification if no digital assets (only send when assets exist)
                end;
            1 .. 10:
                NPDesignerManifestFacade.SetShowTableOfContents(ManifestId, false);
            else
                NPDesignerManifestFacade.SetShowTableOfContents(ManifestId, true);
        end;

        CreateNotificationEntry(TempHeaderBuffer, ManifestId);
        exit(true);
    end;

    local procedure ProcessSalesDocumentLines(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        ProcessedTicketReqEntryNos: List of [Integer];
    begin
        if TempLineBuffer.FindSet() then
            repeat
                ProcessLineAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded, ProcessedTicketReqEntryNos);
            until TempLineBuffer.Next() = 0;
    end;

    local procedure ProcessLineAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer;
        var ProcessedTicketReqEntryNos: List of [Integer])
    var
        AssetType: Option None,Voucher,"Member Card",Coupon,Ticket,Wallet;
    begin
        AssetType := IdentifyAssetType(TempHeaderBuffer, TempLineBuffer);

        if not (AssetType in [AssetType::Voucher, AssetType::Ticket, AssetType::Coupon, AssetType::Wallet]) then
            exit;

        case AssetType of
            AssetType::Voucher:
                ProcessVoucherAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
            AssetType::"Member Card":
                ProcessMemberCardAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
            AssetType::Coupon:
                ProcessCouponAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
            AssetType::Ticket:
                ProcessTicketAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded, ProcessedTicketReqEntryNos);
            AssetType::Wallet:
                ProcessWalletAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
        end;
    end;

    local procedure CreateNotificationEntry(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        ManifestId: Guid)
    var
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
        EmailTemplateId: Code[20];
    begin
        case TempHeaderBuffer."Notification Type" of
            "NPR Dig. Notif. Type"::"Digital Assets":
                begin
                    if not ValidateDigitalNotifSetup() then
                        exit;
                    EmailTemplateId := _DigitalNotifSetup."Email Template Id Order";
                end;
            "NPR Dig. Notif. Type"::"Order Confirmation":
                begin
                    if not ValidateOrderConfirmationSetup() then
                        exit;
                    EmailTemplateId := _DigitalNotifSetup."Ecom Order Confirm Template Id";
                end;
        end;

        DigitalNotifEntry.Init();
        DigitalNotifEntry."External Order No." := TempHeaderBuffer."External Order No.";
        DigitalNotifEntry."Shopify Order ID" := TempHeaderBuffer."Shopify Order ID";
        DigitalNotifEntry."Document Type" := TempHeaderBuffer."Document Type";
        DigitalNotifEntry."Notification Type" := TempHeaderBuffer."Notification Type";
        DigitalNotifEntry."Posted Document No." := TempHeaderBuffer."Posted Document No.";
        DigitalNotifEntry."Recipient E-mail" := TempHeaderBuffer."Recipient E-mail";
        DigitalNotifEntry."Recipient Name" := TempHeaderBuffer."Recipient Name";
        DigitalNotifEntry."Language Code" := TempHeaderBuffer."Language Code";
        DigitalNotifEntry."Manifest ID" := ManifestId;
        DigitalNotifEntry."Email Template Id" := EmailTemplateId;
        DigitalNotifEntry.Sent := false;
        DigitalNotifEntry."Bucket Id" := TempHeaderBuffer."Bucket Id";
        DigitalNotifEntry."Source Document Id" := TempHeaderBuffer."Source Document Id";

        DigitalNotifEntry.Insert(true);
    end;
    #endregion

    #region Asset Identification and Processing
    internal procedure IdentifyEcomLineAssetType(IsWallet: Boolean; EcomLineSubtype: Enum "NPR Ecom Sales Line Subtype"): Option None,Voucher,"Member Card",Coupon,Ticket,Wallet
    var
        AssetType: Option None,Voucher,"Member Card",Coupon,Ticket,Wallet;
    begin
        if IsWallet then
            exit(AssetType::Wallet);

        case EcomLineSubtype of
            EcomLineSubtype::Voucher:
                exit(AssetType::Voucher);
            EcomLineSubtype::Ticket:
                exit(AssetType::Ticket);
            EcomLineSubtype::Coupon:
                exit(AssetType::Coupon);
        end;

        exit(AssetType::None);
    end;

    internal procedure IdentifyAssetType(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary): Option None,Voucher,"Member Card",Coupon,Ticket,Wallet
    var
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        Item: Record Item;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        AssetType: Option None,Voucher,"Member Card",Coupon,Ticket,Wallet;
    begin
        if TempHeaderBuffer."Document Type" = TempHeaderBuffer."Document Type"::"Ecom Sales Document" then
            exit(IdentifyEcomLineAssetType(TempLineBuffer."Is Wallet", TempLineBuffer."Ecom Line Subtype"));

        // Magento / Shopify (Invoice / Credit Memo): identify voucher via voucher entries, member card / ticket via item setup.
        NpRvVoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2',
            NpRvVoucherEntry."Entry Type"::"Issue Voucher",
            NpRvVoucherEntry."Entry Type"::"Top-up");

        case TempHeaderBuffer."Document Type" of
            TempHeaderBuffer."Document Type"::Invoice:
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::Invoice);
            TempHeaderBuffer."Document Type"::"Credit Memo":
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::"Credit Memo");
        end;

        NpRvVoucherEntry.SetRange("Document No.", TempHeaderBuffer."Posted Document No.");
        NpRvVoucherEntry.SetRange("Document Line No.", TempLineBuffer."Line No.");
        if not NpRvVoucherEntry.IsEmpty() then
            exit(AssetType::Voucher);

        // Other digital assets are Item-based only
        if TempLineBuffer.Type <> TempLineBuffer.Type::Item then
            exit(AssetType::None);

        // Check if this line is a member card (setup-based check)
        MembershipSalesSetup.SetRange(Type, MembershipSalesSetup.Type::ITEM);
        MembershipSalesSetup.SetRange("No.", TempLineBuffer."No.");
        if not MembershipSalesSetup.IsEmpty() then
            exit(AssetType::"Member Card");

        // Check if this line is a ticket
        Item.SetLoadFields("No.", "NPR Ticket Type");
        if Item.Get(TempLineBuffer."No.") then
            if Item."NPR Ticket Type" <> '' then begin
                TicketBOM.SetRange("Item No.", TempLineBuffer."No.");
                if not TicketBOM.IsEmpty() then
                    exit(AssetType::Ticket);
            end;

        exit(AssetType::None);
    end;

    local procedure ProcessVoucherAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        if _DigitalNotifSetup."Exclude Vouchers From Manifest" then
            exit;

        if TempHeaderBuffer."Document Type" = TempHeaderBuffer."Document Type"::"Ecom Sales Document" then begin
            EcomSalesVoucherLink.SetCurrentKey("Source System Id", "Source Line System Id");
            EcomSalesVoucherLink.SetRange("Source System Id", TempHeaderBuffer."Source Document Id");
            EcomSalesVoucherLink.SetRange("Source Line System Id", TempLineBuffer."Source Line System Id");
            EcomSalesVoucherLink.SetRange("Voucher State", EcomSalesVoucherLink."Voucher State"::Active);
            if EcomSalesVoucherLink.FindSet() then begin
                repeat
                    if NpRvVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id") then begin
                        NpRvVoucherType.SetLoadFields(PDFDesignerTemplateId);
                        if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") and (NpRvVoucherType.PDFDesignerTemplateId <> '') then begin
                            NPDesignerManifestFacade.AddAssetToManifest(
                                ManifestId,
                                Database::"NPR NpRv Voucher",
                                NpRvVoucher.SystemId,
                                EcomSalesVoucherLink."Reference No.",
                                NpRvVoucherType.PDFDesignerTemplateId);
                            AssetsAdded += 1;
                        end;
                    end;
                until EcomSalesVoucherLink.Next() = 0;
                exit;
            end;
            // Legacy fallback for ecom docs created before the link table existed.
            // Active-only by design — archived legacy vouchers are intentionally skipped from the manifest.
            NpRvVoucher.SetLoadFields("Voucher Type", SystemId, "Reference No.");
            if NpRvVoucher.Get(TempLineBuffer."No.") then begin
                NpRvVoucherType.SetLoadFields(PDFDesignerTemplateId);
                if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") and (NpRvVoucherType.PDFDesignerTemplateId <> '') then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        ManifestId,
                        Database::"NPR NpRv Voucher",
                        NpRvVoucher.SystemId,
                        NpRvVoucher."Reference No.",
                        NpRvVoucherType.PDFDesignerTemplateId);
                    AssetsAdded += 1;
                end;
            end;
            exit;
        end;

        // Invoice / Credit Memo: find vouchers via voucher entries
        NpRvVoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2',
            NpRvVoucherEntry."Entry Type"::"Issue Voucher",
            NpRvVoucherEntry."Entry Type"::"Top-up");

        case TempHeaderBuffer."Document Type" of
            TempHeaderBuffer."Document Type"::Invoice:
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::Invoice);
            TempHeaderBuffer."Document Type"::"Credit Memo":
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::"Credit Memo");
        end;

        NpRvVoucherEntry.SetRange("Document No.", TempHeaderBuffer."Posted Document No.");
        NpRvVoucherEntry.SetRange("Document Line No.", TempLineBuffer."Line No.");
        if not NpRvVoucherEntry.FindSet() then
            exit;

        repeat
            NpRvVoucher.SetLoadFields("Voucher Type", SystemId, "Reference No.");
            if NpRvVoucher.Get(NpRvVoucherEntry."Voucher No.") then begin
                NpRvVoucherType.SetLoadFields(PDFDesignerTemplateId);
                if NpRvVoucherType.Get(NpRvVoucher."Voucher Type") and (NpRvVoucherType.PDFDesignerTemplateId <> '') then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        ManifestId,
                        Database::"NPR NpRv Voucher",
                        NpRvVoucher.SystemId,
                        NpRvVoucher."Reference No.",
                        NpRvVoucherType.PDFDesignerTemplateId
                    );
                    AssetsAdded += 1;
                end;
            end;
        until NpRvVoucherEntry.Next() = 0;
    end;

    local procedure ProcessMemberCardAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MemberNotificSetup: Record "NPR MM Member Notific. Setup";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        // Find membership entry for this order line (should be only one per line)
        // For Shopify orders use the Shopify Order ID (the canonical identifier used when creating the membership)
        if TempHeaderBuffer."Shopify Order ID" <> '' then
            MembershipEntry.SetRange("Document No.", TempHeaderBuffer."Shopify Order ID")
        else
            MembershipEntry.SetRange("Document No.", TempHeaderBuffer."External Order No.");
        MembershipEntry.SetRange("Item No.", TempLineBuffer."No.");
        if not MembershipEntry.FindLast() then
            exit;

        // Process the member card if it exists
        if MembershipEntry."Member Card Entry No." = 0 then
            exit;

        MemberCard.SetLoadFields(SystemId, "External Card No.");
        if not MemberCard.Get(MembershipEntry."Member Card Entry No.") then
            exit;

        Membership.SetLoadFields("Community Code", "Membership Code");
        if not Membership.Get(MembershipEntry."Membership Entry No.") then
            exit;

        // Find notification setup for this membership
        MemberNotificSetup.SetLoadFields(NPDesignerTemplateId);
        MemberNotificSetup.SetRange(Type, MemberNotificSetup.Type::WELCOME);
        MemberNotificSetup.SetRange("Community Code", Membership."Community Code");
        MemberNotificSetup.SetRange("Membership Code", Membership."Membership Code");
        if not MemberNotificSetup.FindFirst() then
            exit;

        if MemberNotificSetup.NPDesignerTemplateId = '' then
            exit;

        // Add member card to manifest
        NPDesignerManifestFacade.AddAssetToManifest(
            ManifestId,
            Database::"NPR MM Member Card",
            MemberCard.SystemId,
            MemberCard."External Card No.",
            MemberNotificSetup.NPDesignerTemplateId
        );
        AssetsAdded += 1;
    end;

    local procedure ProcessCouponAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        // Coupon asset emission is Ecom-exclusive.
        // For Magento/Shopify, coupons are not part of the digital notification manifest by product decision.
        if TempHeaderBuffer."Document Type" <> TempHeaderBuffer."Document Type"::"Ecom Sales Document" then
            exit;

        EcomSalesCouponLink.SetCurrentKey("Source", "Source System Id", "Source Line System Id");
        EcomSalesCouponLink.SetRange("Source", EcomSalesCouponLink."Source"::"Ecom Sales Document");
        EcomSalesCouponLink.SetRange("Source System Id", TempHeaderBuffer."Source Document Id");
        EcomSalesCouponLink.SetRange("Source Line System Id", TempLineBuffer."Source Line System Id");
        if not EcomSalesCouponLink.FindSet() then
            exit;

        repeat
            if Coupon.GetBySystemId(EcomSalesCouponLink."Coupon System Id") then begin
                CouponType.SetLoadFields(NPDesignerTemplateId);
                if CouponType.Get(Coupon."Coupon Type") and (CouponType.NPDesignerTemplateId <> '') then begin
                    NPDesignerManifestFacade.AddAssetToManifest(
                        ManifestId,
                        Database::"NPR NpDc Coupon",
                        Coupon.SystemId,
                        Coupon."Reference No.",
                        CouponType.NPDesignerTemplateId);
                    AssetsAdded += 1;
                end;
            end;
        until EcomSalesCouponLink.Next() = 0;
    end;

    local procedure ProcessTicketAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer;
        var ProcessedTicketReqEntryNos: List of [Integer])
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        OrderID: Text;
    begin
        if _DigitalNotifSetup."Exclude Tickets From Manifest" then
            exit;

        // 1. Ecom direct link: use Ticket Reservation Line Id (Guid) for precise 1:1 match
        if not IsNullGuid(TempLineBuffer."Ticket Reservation Line Id") then begin
            if TicketReservationReq.GetBySystemId(TempLineBuffer."Ticket Reservation Line Id") then
                if TicketReservationReq."Request Status" = TicketReservationReq."Request Status"::CONFIRMED then
                    AddTicketsFromReservation(TicketReservationReq, ManifestId, AssetsAdded, ProcessedTicketReqEntryNos);
            exit;
        end;

        // 2. Filter by External Order No. (or Shopify Order ID if available) + line reference / item fallback
        OrderID := TempHeaderBuffer."External Order No.";
        // For Shopify orders use the Shopify Order ID (the canonical identifier used when creating the reservation)
        if TempHeaderBuffer."Shopify Order ID" <> '' then
            OrderID := TempHeaderBuffer."Shopify Order ID";

        FilterTicketReservations(OrderID, TempLineBuffer, TicketReservationReq);
        if not TicketReservationReq.FindSet() then
            exit;

        repeat
            AddTicketsFromReservation(TicketReservationReq, ManifestId, AssetsAdded, ProcessedTicketReqEntryNos);
        until TicketReservationReq.Next() = 0;
    end;

    local procedure FilterTicketReservations(
        OrderID: Text;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        var TicketReservationReq: Record "NPR TM Ticket Reservation Req.")
    begin
        TicketReservationReq.Reset();
        TicketReservationReq.SetRange("External Order No.", OrderID);
        TicketReservationReq.SetRange("Request Status", TicketReservationReq."Request Status"::CONFIRMED);

        // Try precise match first: Ext. Line Reference No.
        TicketReservationReq.SetRange("Ext. Line Reference No.", TempLineBuffer."Line No.");
        if not TicketReservationReq.IsEmpty() then
            exit;

        // Fallback: match by Item No. + Variant Code
        // Process ALL matching reservations to handle multiple timeslots for the same item
        TicketReservationReq.SetRange("Ext. Line Reference No.");
        TicketReservationReq.SetRange("Item No.", TempLineBuffer."No.");
        TicketReservationReq.SetRange("Variant Code", TempLineBuffer."Variant Code");
    end;


    local procedure AddTicketsFromReservation(
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        ManifestId: Guid;
        var AssetsAdded: Integer;
        var ProcessedTicketReqEntryNos: List of [Integer])
    var
        Ticket: Record "NPR TM Ticket";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        if ProcessedTicketReqEntryNos.Contains(TicketReservationReq."Entry No.") then
            exit;

        ProcessedTicketReqEntryNos.Add(TicketReservationReq."Entry No.");

        Ticket.SetLoadFields("Item No.", "Variant Code", "External Ticket No.", SystemId);
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        if Ticket.FindSet() then
            repeat
                TicketAdmissionBOM.SetLoadFields(NPDesignerTemplateId);
                if TicketAdmissionBOM.Get(Ticket."Item No.", Ticket."Variant Code", TicketReservationReq."Admission Code") then
                    if TicketAdmissionBOM.NPDesignerTemplateId <> '' then begin
                        NPDesignerManifestFacade.AddAssetToManifest(
                            ManifestId,
                            Database::"NPR TM Ticket",
                            Ticket.SystemId,
                            Ticket."External Ticket No.",
                            TicketAdmissionBOM.NPDesignerTemplateId
                        );
                        AssetsAdded += 1;
                    end;
            until Ticket.Next() = 0;
    end;

    local procedure ProcessWalletAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletAssetHeader: Record "NPR WalletAssetHeader";
        WalletAssetLine: Record "NPR WalletAssetLine";
        Wallet: Record "NPR AttractionWallet";
    begin
        // Wallet asset emission is Ecom-exclusive.
        // For Magento/Shopify, wallets are not part of the digital notification manifest by product decision.
        if TempHeaderBuffer."Document Type" <> TempHeaderBuffer."Document Type"::"Ecom Sales Document" then
            exit;

        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetRange(LinkToTableId, Database::"NPR Ecom Sales Line");
        WalletAssetHeaderRef.SetRange(LinkToSystemId, TempLineBuffer."Source Line System Id");
        if not WalletAssetHeaderRef.FindSet() then
            exit;

        repeat
            if WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo) then begin
                WalletAssetLine.SetCurrentKey(TransactionId);
                WalletAssetLine.SetRange(TransactionId, WalletAssetHeader.TransactionId);
                WalletAssetLine.SetRange(Type, WalletAssetLine.Type::WALLET);
                if WalletAssetLine.FindSet() then
                    repeat
                        if Wallet.GetBySystemId(WalletAssetLine.LineTypeSystemId) then
                            TryAddWalletAssetToManifest(Wallet, ManifestId, AssetsAdded);
                    until WalletAssetLine.Next() = 0;
            end;
        until WalletAssetHeaderRef.Next() = 0;
    end;

    local procedure TryAddWalletAssetToManifest(
        Wallet: Record "NPR AttractionWallet";
        ManifestId: Guid;
        var AssetsAdded: Integer): Boolean
    var
        AttractionWallet: Codeunit "NPR AttractionWallet";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
        TemplateLabel: Text[80];
        TemplateId: Text[40];
    begin
        if not AttractionWallet.GetDesignerTemplate(Wallet.EntryNo, TemplateLabel, TemplateId) then
            exit(false);

        NPDesignerManifestFacade.AddAssetToManifest(
            ManifestId,
            Database::"NPR AttractionWallet",
            Wallet.SystemId,
            Wallet.ReferenceNumber,
            TemplateId);
        AssetsAdded += 1;
        exit(true);
    end;
    #endregion

    #region Buffer Population
    internal procedure PopulateBuffersFromInvoice(
        SalesInvHeader: Record "Sales Invoice Header";
        NotificationType: Enum "NPR Dig. Notif. Type";
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        RecipientEmail: Text[80];
        RecipientName: Text[100];
        CurrencyCode: Code[10];
    begin
        GetRecipientInfo(SalesInvHeader, RecipientEmail, RecipientName);

        SalesInvHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");

        CurrencyCode := GetEffectiveCurrencyCode(SalesInvHeader."Currency Code");

        TempHeaderBuffer.Init();
        TempHeaderBuffer."External Order No." := SalesInvHeader."NPR External Order No.";
        TempHeaderBuffer."Shopify Order ID" := GetShopifyOrderID(SalesInvHeader.RecordId());
        TempHeaderBuffer."Document Type" := TempHeaderBuffer."Document Type"::Invoice;
        TempHeaderBuffer."Posted Document No." := SalesInvHeader."No.";
        TempHeaderBuffer."Source Document Id" := SalesInvHeader.SystemId;
        TempHeaderBuffer."Customer No." := SalesInvHeader."Sell-to Customer No.";
        TempHeaderBuffer."Recipient E-mail" := RecipientEmail;
        TempHeaderBuffer."Recipient Name" := RecipientName;
        TempHeaderBuffer."Language Code" := ResolveLanguageCode(
            SalesInvHeader."Language Code",
            TempHeaderBuffer."Shopify Order ID",
            TempHeaderBuffer."External Order No.",
            TempHeaderBuffer."Customer No.");
        if SalesInvHeader."Order Date" <> 0D then
            TempHeaderBuffer."Document Date" := SalesInvHeader."Order Date"
        else
            TempHeaderBuffer."Document Date" := SalesInvHeader."Posting Date";
        TempHeaderBuffer."Currency Code" := CurrencyCode;
        TempHeaderBuffer."Total Amount Excl. VAT" := SalesInvHeader.Amount;
        TempHeaderBuffer."Total Amount Incl. VAT" := SalesInvHeader."Amount Including VAT";
        TempHeaderBuffer."Invoice Discount Amount" := SalesInvHeader."Invoice Discount Amount";
        TempHeaderBuffer."Notification Type" := NotificationType;
        TempHeaderBuffer.Insert();

        SalesInvoiceLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                TempLineBuffer.Init();
                TempLineBuffer."External Order No." := SalesInvHeader."NPR External Order No.";
                TempLineBuffer."Line No." := SalesInvoiceLine."Line No.";
                TempLineBuffer.Type := SalesInvoiceLine.Type;
                TempLineBuffer."No." := SalesInvoiceLine."No.";
                TempLineBuffer."Variant Code" := SalesInvoiceLine."Variant Code";
                TempLineBuffer.Description := CopyStr(SalesInvoiceLine.Description, 1, 100);
                TempLineBuffer.Quantity := SalesInvoiceLine.Quantity;
                TempLineBuffer."Unit Price" := SalesInvoiceLine."Unit Price";
                TempLineBuffer.Amount := SalesInvoiceLine.Amount;
                TempLineBuffer."Amount Including VAT" := SalesInvoiceLine."Amount Including VAT";
                TempLineBuffer."Line Discount Amount" := SalesInvoiceLine."Line Discount Amount";
                TempLineBuffer."VAT %" := SalesInvoiceLine."VAT %";
                TempLineBuffer.Insert();
            until SalesInvoiceLine.Next() = 0;
    end;

    internal procedure PopulateBuffersFromCrMemo(
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        NotificationType: Enum "NPR Dig. Notif. Type";
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        RecipientEmail: Text[80];
        RecipientName: Text[100];
        CurrencyCode: Code[10];
    begin
        GetRecipientInfo(SalesCrMemoHeader, RecipientEmail, RecipientName);

        SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");

        CurrencyCode := GetEffectiveCurrencyCode(SalesCrMemoHeader."Currency Code");

        TempHeaderBuffer.Init();
        TempHeaderBuffer."External Order No." := SalesCrMemoHeader."NPR External Order No.";
        TempHeaderBuffer."Shopify Order ID" := GetShopifyOrderID(SalesCrMemoHeader.RecordId());
        TempHeaderBuffer."Document Type" := TempHeaderBuffer."Document Type"::"Credit Memo";
        TempHeaderBuffer."Posted Document No." := SalesCrMemoHeader."No.";
        TempHeaderBuffer."Source Document Id" := SalesCrMemoHeader.SystemId;
        TempHeaderBuffer."Customer No." := SalesCrMemoHeader."Sell-to Customer No.";
        TempHeaderBuffer."Recipient E-mail" := RecipientEmail;
        TempHeaderBuffer."Recipient Name" := RecipientName;
        TempHeaderBuffer."Language Code" := ResolveLanguageCode(
            SalesCrMemoHeader."Language Code",
            TempHeaderBuffer."Shopify Order ID",
            TempHeaderBuffer."External Order No.",
            TempHeaderBuffer."Customer No.");
        TempHeaderBuffer."Document Date" := SalesCrMemoHeader."Posting Date";
        TempHeaderBuffer."Currency Code" := CurrencyCode;
        TempHeaderBuffer."Total Amount Excl. VAT" := SalesCrMemoHeader.Amount;
        TempHeaderBuffer."Total Amount Incl. VAT" := SalesCrMemoHeader."Amount Including VAT";
        TempHeaderBuffer."Invoice Discount Amount" := SalesCrMemoHeader."Invoice Discount Amount";
        TempHeaderBuffer."Notification Type" := NotificationType;
        TempHeaderBuffer.Insert();

        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        if SalesCrMemoLine.FindSet() then
            repeat
                TempLineBuffer.Init();
                TempLineBuffer."External Order No." := SalesCrMemoHeader."NPR External Order No.";
                TempLineBuffer."Line No." := SalesCrMemoLine."Line No.";
                TempLineBuffer.Type := SalesCrMemoLine.Type;
                TempLineBuffer."No." := SalesCrMemoLine."No.";
                TempLineBuffer."Variant Code" := SalesCrMemoLine."Variant Code";
                TempLineBuffer.Description := CopyStr(SalesCrMemoLine.Description, 1, 100);
                TempLineBuffer.Quantity := SalesCrMemoLine.Quantity;
                TempLineBuffer."Unit Price" := SalesCrMemoLine."Unit Price";
                TempLineBuffer.Amount := SalesCrMemoLine.Amount;
                TempLineBuffer."Amount Including VAT" := SalesCrMemoLine."Amount Including VAT";
                TempLineBuffer."Line Discount Amount" := SalesCrMemoLine."Line Discount Amount";
                TempLineBuffer."VAT %" := SalesCrMemoLine."VAT %";
                TempLineBuffer.Insert();
            until SalesCrMemoLine.Next() = 0;
    end;

    internal procedure PopulateBuffersFromEcomDoc(
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        NotificationType: Enum "NPR Dig. Notif. Type";
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary)
    var
        TempCandidateLine: Record "NPR Ecom Sales Line" temporary;
        WalletExtLineIds: Dictionary of [Text[100], Boolean];
        CurrencyCode: Code[10];
        TotalAmountExclVAT: Decimal;
        TotalAmountInclVAT: Decimal;
    begin
        CurrencyCode := GetEffectiveCurrencyCode(EcomSalesHeader."Currency Code");

        TempHeaderBuffer.Init();
        TempHeaderBuffer."External Order No." := EcomSalesHeader."External No.";
        TempHeaderBuffer."Document Type" := TempHeaderBuffer."Document Type"::"Ecom Sales Document";
        TempHeaderBuffer."Recipient E-mail" := EcomSalesHeader."Sell-to Email";
        TempHeaderBuffer."Recipient Name" := CopyStr(EcomSalesHeader."Sell-to Name", 1, MaxStrLen(TempHeaderBuffer."Recipient Name"));
        TempHeaderBuffer."Customer No." := EcomSalesHeader."Sell-to Customer No.";
        TempHeaderBuffer."Language Code" := ResolveLanguageCode(
            EcomSalesHeader."Language Code",
            EcomSalesHeader."Ticket Reservation Token",
            '',
            TempHeaderBuffer."External Order No.",
            EcomSalesHeader."Sell-to Customer No.");
        TempHeaderBuffer."Document Date" := EcomSalesHeader."Received Date";
        TempHeaderBuffer."Currency Code" := CurrencyCode;
        TempHeaderBuffer."Source Document Id" := EcomSalesHeader.SystemId;
        TempHeaderBuffer."Bucket Id" := EcomSalesHeader."Bucket Id";
        TempHeaderBuffer."Notification Type" := NotificationType;
        TempHeaderBuffer.Insert();

        CollectEcomLinesAndWalletSet(EcomSalesHeader."Entry No.", TempCandidateLine, WalletExtLineIds);

        if TempCandidateLine.FindSet() then
            repeat
                if ShouldEmitEcomAssetLine(TempCandidateLine, WalletExtLineIds) then begin
                    TempLineBuffer.Init();
                    TempLineBuffer."External Order No." := EcomSalesHeader."External No.";
                    TempLineBuffer."Line No." := TempCandidateLine."Line No.";
                    if TempCandidateLine.Subtype = TempCandidateLine.Subtype::Voucher then
                        TempLineBuffer.Type := TempLineBuffer.Type::" "
                    else
                        TempLineBuffer.Type := TempLineBuffer.Type::Item;
                    TempLineBuffer."Ecom Line Subtype" := TempCandidateLine.Subtype;
                    TempLineBuffer."Ticket Reservation Line Id" := TempCandidateLine."Ticket Reservation Line Id";
                    TempLineBuffer."No." := CopyStr(TempCandidateLine."No.", 1, MaxStrLen(TempLineBuffer."No."));
                    TempLineBuffer."Variant Code" := TempCandidateLine."Variant Code";
                    TempLineBuffer.Description := CopyStr(TempCandidateLine.Description, 1, 100);
                    TempLineBuffer.Quantity := TempCandidateLine.Quantity;
                    TempLineBuffer."Unit Price" := TempCandidateLine."Unit Price";
                    CalcEcomLineAmounts(TempCandidateLine."Line Amount", TempCandidateLine."VAT %", EcomSalesHeader."Price Excl. VAT", TempLineBuffer.Amount, TempLineBuffer."Amount Including VAT");
                    TempLineBuffer."VAT %" := TempCandidateLine."VAT %";
                    TempLineBuffer."Source Line System Id" := TempCandidateLine.SystemId;
                    TempLineBuffer."Is Wallet" := TempCandidateLine."Is Attraction Wallet";
                    TempLineBuffer.Insert();

                    TotalAmountExclVAT += TempLineBuffer.Amount;
                    TotalAmountInclVAT += TempLineBuffer."Amount Including VAT";
                end;
            until TempCandidateLine.Next() = 0;

        TempHeaderBuffer."Total Amount Excl. VAT" := TotalAmountExclVAT;
        TempHeaderBuffer."Total Amount Incl. VAT" := TotalAmountInclVAT;
        TempHeaderBuffer.Modify();
    end;

    internal procedure CollectEcomLinesAndWalletSet(
        DocumentEntryNo: BigInteger;
        var TempCandidateLine: Record "NPR Ecom Sales Line" temporary;
        var WalletExtLineIds: Dictionary of [Text[100], Boolean])
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", DocumentEntryNo);
        if EcomSalesLine.FindSet() then
            repeat
                if EcomSalesLine."Is Attraction Wallet" and (EcomSalesLine."External Line ID" <> '') then
                    if not WalletExtLineIds.ContainsKey(EcomSalesLine."External Line ID") then
                        WalletExtLineIds.Add(EcomSalesLine."External Line ID", true);

                TempCandidateLine := EcomSalesLine;
                TempCandidateLine.Insert();
            until EcomSalesLine.Next() = 0;
    end;

    internal procedure ShouldEmitEcomAssetLine(EcomSalesLine: Record "NPR Ecom Sales Line"; WalletExtLineIds: Dictionary of [Text[100], Boolean]): Boolean
    begin
        // Wallet bundle children are rendered inside the wallet asset, not as standalone JSON lines.
        if EcomSalesLine."Parent Ext. Line ID" <> '' then
            if WalletExtLineIds.ContainsKey(EcomSalesLine."Parent Ext. Line ID") then
                exit(false);
        exit(true);
    end;

    internal procedure CalcEcomLineAmounts(LineAmount: Decimal; VATPercent: Decimal; PriceExclVAT: Boolean; var AmountExclVAT: Decimal; var AmountInclVAT: Decimal)
    begin
        if PriceExclVAT then begin
            AmountExclVAT := LineAmount;
            if VATPercent <> 0 then
                AmountInclVAT := Round(LineAmount * (1 + VATPercent / 100))
            else
                AmountInclVAT := LineAmount;
        end else begin
            AmountInclVAT := LineAmount;
            if VATPercent <> 0 then
                AmountExclVAT := Round(LineAmount / (1 + VATPercent / 100))
            else
                AmountExclVAT := LineAmount;
        end;
    end;

    local procedure GetRecipientInfo(
       SalesInvHeader: Record "Sales Invoice Header";
       var RecipientEmail: Text[80];
       var RecipientName: Text[100])
    var
        Customer: Record Customer;
    begin
        RecipientEmail := SalesInvHeader."Sell-to E-Mail";
        RecipientName := SalesInvHeader."Sell-to Customer Name";

        if (RecipientEmail = '') or (RecipientName = '') then begin
            Customer.SetLoadFields("E-Mail", Name);
            if Customer.Get(SalesInvHeader."Sell-to Customer No.") then begin
                if RecipientEmail = '' then
                    RecipientEmail := Customer."E-Mail";
                if RecipientName = '' then
                    RecipientName := Customer.Name;
            end;
        end;
    end;

    local procedure GetRecipientInfo(
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        var RecipientEmail: Text[80];
        var RecipientName: Text[100])
    var
        Customer: Record Customer;
    begin
        RecipientEmail := SalesCrMemoHeader."Sell-to E-Mail";
        RecipientName := SalesCrMemoHeader."Sell-to Customer Name";

        if (RecipientEmail = '') or (RecipientName = '') then begin
            Customer.SetLoadFields("E-Mail", Name);
            if Customer.Get(SalesCrMemoHeader."Sell-to Customer No.") then begin
                if RecipientEmail = '' then
                    RecipientEmail := Customer."E-Mail";
                if RecipientName = '' then
                    RecipientName := Customer.Name;
            end;
        end;
    end;

    internal procedure GetEffectiveCurrencyCode(DocumentCurrencyCode: Code[10]): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if DocumentCurrencyCode <> '' then
            exit(DocumentCurrencyCode);

        GeneralLedgerSetup.SetLoadFields("LCY Code");
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."LCY Code");
    end;

    local procedure ResolveLanguageCode(DocumentLanguageCode: Code[10]; ShopifyOrderId: Text[30]; ExternalOrderNo: Code[20]; SellToCustomerNo: Code[20]): Code[10]
    begin
        exit(ResolveLanguageCode(DocumentLanguageCode, '', ShopifyOrderId, ExternalOrderNo, SellToCustomerNo));
    end;

    local procedure ResolveLanguageCode(InitialLanguageCode: Code[10]; SessionTokenId: Text[100]; ShopifyOrderId: Text[30]; ExternalOrderNo: Code[20]; SellToCustomerNo: Code[20]): Code[10]
    var
        Customer: Record Customer;
    begin
        if InitialLanguageCode <> '' then
            exit(InitialLanguageCode);

        if SellToCustomerNo <> '' then begin
            Customer.SetLoadFields("Language Code");
            if Customer.Get(SellToCustomerNo) then
                if Customer."Language Code" <> '' then
                    exit(Customer."Language Code");
        end;

        exit(FindReservationLanguage(SessionTokenId, ShopifyOrderId, ExternalOrderNo));
    end;

    local procedure FindReservationLanguage(SessionTokenId: Text[100]; ShopifyOrderId: Text[30]; ExternalOrderNo: Code[20]): Code[10]
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        LanguageCode: Code[10];
        OrderId: Text;
    begin
        // Session Token ID matches at OC creation time, before PreProcessDocument stamps External Order No.
        if SessionTokenId <> '' then begin
            TicketReservationReq.SetLoadFields(TicketHolderPreferredLanguage);
            TicketReservationReq.SetRange("Session Token ID", SessionTokenId);
            LanguageCode := PickReservationLanguage(TicketReservationReq);
            if LanguageCode <> '' then
                exit(LanguageCode);
        end;

        // Mirror ProcessTicketAssets: prefer Shopify Order ID for Shopify-imported orders, else External Order No.
        OrderId := ExternalOrderNo;
        if ShopifyOrderId <> '' then
            OrderId := ShopifyOrderId;

        if OrderId <> '' then begin
            TicketReservationReq.Reset();
            TicketReservationReq.SetLoadFields(TicketHolderPreferredLanguage);
            TicketReservationReq.SetRange("External Order No.", OrderId);
            LanguageCode := PickReservationLanguage(TicketReservationReq);
            if LanguageCode <> '' then
                exit(LanguageCode);
        end;

        exit('');
    end;

    local procedure PickReservationLanguage(var TicketReservationReq: Record "NPR TM Ticket Reservation Req."): Code[10]
    begin
        TicketReservationReq.SetFilter(TicketHolderPreferredLanguage, '<>%1', '');
        if TicketReservationReq.IsEmpty() then
            exit('');

        // Primary request line first for deterministic pick when multiple lines carry a language.
        TicketReservationReq.SetRange("Primary Request Line", true);
        if TicketReservationReq.FindFirst() then
            exit(TicketReservationReq.TicketHolderPreferredLanguage);

        TicketReservationReq.SetRange("Primary Request Line");
        if TicketReservationReq.FindFirst() then
            exit(TicketReservationReq.TicketHolderPreferredLanguage);

        exit('');
    end;
    #endregion

    #region Setup, Helpers and Job Queue
    local procedure ValidateDigitalNotifSetup(): Boolean
    var
        ErrorMessage: Text;
    begin
        Exit(ValidateDigitalNotifSetup(ErrorMessage));
    end;

    local procedure LoadDigitalNotifSetup(): Boolean
    begin
        if _DigitalNotifSetupLoaded then
            exit(true);

        _DigitalNotifSetup.SetLoadFields(
            Enabled,
            "Email Template Id Order",
            "Exclude Vouchers From Manifest",
            "Exclude Tickets From Manifest",
            "Send Ecom Order Confirmation",
            "Ecom Order Confirm Template Id",
            "Max Attempts");
        if not _DigitalNotifSetup.Get() then
            exit(false);

        _DigitalNotifSetupLoaded := true;
        exit(true);
    end;

    internal procedure ValidateDigitalNotifSetup(var ErrorMessage: Text): Boolean
    var
        NoSetupErr: Label 'Digital Notification setup is not configured. Please configure the setup before sending digital notifications.';
        NoEmailTemplateErr: Label 'Email Template ID is not configured in Digital Order Notification setup.';
        NotEnabledErr: Label 'Digital Notification is not enabled in the setup.';
    begin
        ErrorMessage := '';
        if not LoadDigitalNotifSetup() then begin
            ErrorMessage := NoSetupErr;
            exit(false);
        end;

        if not _DigitalNotifSetup.Enabled then begin
            ErrorMessage := NotEnabledErr;
            exit(false);
        end;

        if _DigitalNotifSetup."Email Template Id Order" = '' then begin
            ErrorMessage := NoEmailTemplateErr;
            exit(false);
        end;

        exit(true);
    end;

    internal procedure ValidateDigitalNotifSetup(var DigitalNotificationSetup: Record "NPR Digital Notification Setup"): Boolean
    begin
        if not ValidateDigitalNotifSetup() then
            exit(false);
        DigitalNotificationSetup := _DigitalNotifSetup;
        exit(true);
    end;

    local procedure ValidateOrderConfirmationSetup(): Boolean
    begin
        if not LoadDigitalNotifSetup() then
            exit(false);
        if not _DigitalNotifSetup."Send Ecom Order Confirmation" then
            exit(false);
        exit(_DigitalNotifSetup."Ecom Order Confirm Template Id" <> '');
    end;

    local procedure ValidateAnyEcomNotifEnabled(): Boolean
    begin
        if not LoadDigitalNotifSetup() then
            exit(false);
        if _DigitalNotifSetup.Enabled and (_DigitalNotifSetup."Email Template Id Order" <> '') then
            exit(true);
        if _DigitalNotifSetup."Send Ecom Order Confirmation" and (_DigitalNotifSetup."Ecom Order Confirm Template Id" <> '') then
            exit(true);
        exit(false);
    end;

    internal procedure ValidateAnyEcomNotifEnabled(var DigitalNotificationSetup: Record "NPR Digital Notification Setup"): Boolean
    begin
        if not ValidateAnyEcomNotifEnabled() then
            exit(false);
        DigitalNotificationSetup := _DigitalNotifSetup;
        exit(true);
    end;

    local procedure IsManifestFeatureEnabled(): Boolean
    var
        NPDesignerSetup: Record "NPR NPDesignerSetup";
    begin
        NPDesignerSetup.SetLoadFields(EnableManifest);
        if not NPDesignerSetup.Get() then
            exit(false);
        exit(NPDesignerSetup.EnableManifest);
    end;

    local procedure EcomDigitalNotifEntryExists(EcomSalesHeaderId: Guid; NotificationType: Enum "NPR Dig. Notif. Type"): Boolean
    var
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
    begin
        DigitalNotifEntry.SetRange("Source Document Id", EcomSalesHeaderId);
        DigitalNotifEntry.SetRange("Notification Type", NotificationType);
        exit(not DigitalNotifEntry.IsEmpty());
    end;

    local procedure GetShopifyOrderID(PostedDocRecordId: RecordId): Text[30]
    var
        SpfyAssignedIDMgtImpl: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        exit(SpfyAssignedIDMgtImpl.GetAssignedShopifyID(PostedDocRecordId, "NPR Spfy ID Type"::"Entry ID"));
    end;
    #endregion
}
#endif
