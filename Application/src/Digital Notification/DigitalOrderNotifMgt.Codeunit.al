#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6150961 "NPR Digital Order Notif. Mgt."
{
    Access = Internal;

    var
        DigitalNotifSetup: Record "NPR Digital Notification Setup";
        DigitalNotifSetupRead: Boolean;

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

        if SalesHeader.IsCreditDocType() then begin
            if SalesHeader.Correction then
                exit;
            if not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
                exit;
            PopulateBuffersFromCrMemo(SalesCrMemoHeader, TempHeaderBuffer, TempLineBuffer);
        end else begin
            if not SalesInvHeader.Get(SalesInvHdrNo) then
                exit;
            PopulateBuffersFromInvoice(SalesInvHeader, TempHeaderBuffer, TempLineBuffer);
        end;

        ProcessSalesDocument(TempHeaderBuffer, TempLineBuffer);
    end;

    internal procedure SendDigitalOrderNotificationManual(RecVariant: Variant)
    var
        ErrorMessage: Text;
        SuccessMsgTxt: Label 'Digital notification has been queued for sending. The customer will receive the email shortly.';
        NoAssetsMsg: Label 'No digital assets (tickets, vouchers) were found in this document. No notification has been created.';
    begin
        if not ValidateDigitalNotifSetup(ErrorMessage) then
            Error(ErrorMessage);

        if ProcessSalesDocumentManual(RecVariant) then
            Message(SuccessMsgTxt)
        else
            Message(NoAssetsMsg);
    end;

    // main worker that can be used for all processes: Magento, Shopify, Ecom documents
    internal procedure ProcessSalesDocument(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary): Boolean
    var
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
        ManifestId, NullGuid : Guid;
        AssetsAdded: Integer;
    begin
        if TempHeaderBuffer."Recipient E-mail" = '' then
            exit(false);

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
            1 .. 10: // Single asset or small batch - go directly to asset
                NPDesignerManifestFacade.SetShowTableOfContents(ManifestId, false);
            else // Multiple assets - show table of contents
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
    begin
        if TempLineBuffer.FindSet() then
            repeat
                ProcessLineAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
            until TempLineBuffer.Next() = 0;
    end;

    local procedure ProcessLineAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        AssetType: Option None,Voucher,"Member Card",Coupon,Ticket,Wallet;
    begin
        AssetType := IdentifyAssetType(TempHeaderBuffer, TempLineBuffer);

        if not (AssetType in [AssetType::Voucher, AssetType::Ticket]) then
            exit;

        case AssetType of
            AssetType::Voucher:
                ProcessVoucherAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
            AssetType::"Member Card":
                ProcessMemberCardAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
            AssetType::Coupon:
                ProcessCouponAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
            AssetType::Ticket:
                ProcessTicketAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
            AssetType::Wallet:
                ProcessWalletAssets(TempHeaderBuffer, TempLineBuffer, ManifestId, AssetsAdded);
        end;
    end;

    internal procedure IdentifyAssetType(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary): Option None,Voucher,"Member Card",Coupon,Ticket,Wallet
    var
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        CouponItemSaleSetup: Record "NPR NpDc Iss.OnSale Setup Line";
        CouponWalletSalesSetup: Record "NPR WalletCouponSetup";
        Item: Record Item;
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        ItemAddOn: Record "NPR NpIa Item AddOn";
        AssetType: Option None,Voucher,"Member Card",Coupon,Ticket,Wallet;
    begin
        NpRvVoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2',
            NpRvVoucherEntry."Entry Type"::"Issue Voucher",
            NpRvVoucherEntry."Entry Type"::"Top-up");

        // Map enum to option using case statement to avoid type mismatch
        case TempHeaderBuffer."Document Type" of
            TempHeaderBuffer."Document Type"::Invoice:
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::Invoice);
            TempHeaderBuffer."Document Type"::"Credit Memo":
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::"Credit Memo");
            TempHeaderBuffer."Document Type"::"Ecom Sales Document":
                exit(AssetType::None);
        end;

        NpRvVoucherEntry.SetRange("Document No.", TempHeaderBuffer."Posted Document No.");
        NpRvVoucherEntry.SetRange("Document Line No.", TempLineBuffer."Line No.");
        if not NpRvVoucherEntry.IsEmpty() then
            exit(AssetType::Voucher);

        // Other digital assets are Item-based only
        if TempLineBuffer.Type <> TempLineBuffer.Type::Item then
            exit(AssetType::None);

        // Check if this line is a coupon
        CouponItemSaleSetup.SetRange(Type, CouponItemSaleSetup.Type::Item);
        CouponItemSaleSetup.SetRange("No.", TempLineBuffer."No.");
        if not CouponItemSaleSetup.IsEmpty() then
            exit(AssetType::Coupon);

        // Check if this line is a coupon wallet
        CouponWalletSalesSetup.SetRange(TriggerOnItemNo, TempLineBuffer."No.");
        if not CouponWalletSalesSetup.IsEmpty() then
            exit(AssetType::Coupon);

        // Check if this line is a member card (setup-based check)
        MembershipSalesSetup.SetRange(Type, MembershipSalesSetup.Type::ITEM);
        MembershipSalesSetup.SetRange("No.", TempLineBuffer."No.");
        if not MembershipSalesSetup.IsEmpty() then
            exit(AssetType::"Member Card");

        Item.SetLoadFields("No.", "NPR Ticket Type", "NPR Item AddOn No.");
        if Item.Get(TempLineBuffer."No.") then begin
            // Check if this line is a ticket
            if Item."NPR Ticket Type" <> '' then begin
                TicketBOM.SetRange("Item No.", TempLineBuffer."No.");
                if not TicketBOM.IsEmpty() then
                    exit(AssetType::Ticket);
            end;

            // Check if this line is a wallet
            if Item."NPR Item AddOn No." <> '' then begin
                ItemAddOn.SetLoadFields(WalletTemplate);
                if ItemAddOn.Get(Item."NPR Item AddOn No.") then begin
                    if ItemAddOn.WalletTemplate then
                        exit(AssetType::Wallet);
                end;
            end;
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
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        if DigitalNotifSetup."Exclude Vouchers From Manifest" then
            exit;

        NpRvVoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2',
            NpRvVoucherEntry."Entry Type"::"Issue Voucher",
            NpRvVoucherEntry."Entry Type"::"Top-up");

        // Map enum to option using case statement to avoid type mismatch
        case TempHeaderBuffer."Document Type" of
            TempHeaderBuffer."Document Type"::Invoice:
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::Invoice);
            TempHeaderBuffer."Document Type"::"Credit Memo":
                NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::"Credit Memo");
            TempHeaderBuffer."Document Type"::"Ecom Sales Document":
                exit;
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
        CouponItemSaleSetup: Record "NPR NpDc Iss.OnSale Setup Line";
        CouponEntry: Record "NPR NpDc Coupon Entry";
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        if TempLineBuffer.Type <> TempLineBuffer.Type::Item then
            exit;

        CouponItemSaleSetup.SetRange(Type, CouponItemSaleSetup.Type::Item);
        CouponItemSaleSetup.SetRange("No.", TempLineBuffer."No.");
        if not CouponItemSaleSetup.FindFirst() then
            exit;

        CouponType.SetLoadFields(NPDesignerTemplateId);
        if not CouponType.Get(CouponItemSaleSetup."Coupon Type") then
            exit;
        if CouponType.NPDesignerTemplateId = '' then
            exit;

        CouponEntry.SetLoadFields("Coupon No.");
        CouponEntry.SetRange("Entry Type", CouponEntry."Entry Type"::"Issue Coupon");
        CouponEntry.SetRange("Coupon Type", CouponItemSaleSetup."Coupon Type");

        // Filter coupon entries by posted document (Magento flow - after posting)
        case TempHeaderBuffer."Document Type" of
            TempHeaderBuffer."Document Type"::Invoice:
                CouponEntry.SetRange("Document Type", CouponEntry."Document Type"::"Posted Sales Invoice");
            TempHeaderBuffer."Document Type"::"Credit Memo":
                CouponEntry.SetRange("Document Type", CouponEntry."Document Type"::"Posted Sales Credit Memo");
            TempHeaderBuffer."Document Type"::"Ecom Sales Document":
                exit;
        end;

        CouponEntry.SetRange("Document No.", TempHeaderBuffer."Posted Document No.");

        if not CouponEntry.FindLast() then
            exit;

        Coupon.SetLoadFields(SystemId, "Reference No.");
        if Coupon.Get(CouponEntry."Coupon No.") then begin
            NPDesignerManifestFacade.AddAssetToManifest(
                ManifestId,
                Database::"NPR NpDc Coupon",
                Coupon.SystemId,
                Coupon."Reference No.",
                CouponType.NPDesignerTemplateId
            );
            AssetsAdded += 1;
        end;
    end;

    local procedure ProcessTicketAssets(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer)
    var
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        // Filter by External Order No. + Line No. to match this specific sales line
        TicketReservationReq.SetRange("External Order No.", TempHeaderBuffer."External Order No.");
        TicketReservationReq.SetRange("Ext. Line Reference No.", TempLineBuffer."Line No.");
        TicketReservationReq.SetRange("Request Status", TicketReservationReq."Request Status"::CONFIRMED);

        if TicketReservationReq.IsEmpty() then begin
            // External system might not send the Ext. Line Reference No., so we search by Item No and Variant Code
            TicketReservationReq.SetRange("Ext. Line Reference No.");
            TicketReservationReq.SetRange("Item No.", TempLineBuffer."No.");
            TicketReservationReq.SetRange("Variant Code", TempLineBuffer."Variant Code");
        end;

        if not TicketReservationReq.FindLast() then
            exit;

        // Process all tickets for this reservation (multiple tickets if qty > 1)
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
        FoundWallet: Boolean;
    begin
        // Filter wallets by External Order No.
        WalletAssetHeaderRef.SetRange(LinkToReference, TempHeaderBuffer."External Order No.");

        if not WalletAssetHeaderRef.FindSet() then
            exit;

        // Search for wallet matching this line's item no. (get the last one created)
        FoundWallet := false;
        repeat
            WalletAssetHeader.SetLoadFields(TransactionId);
            if WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo) then begin
                WalletAssetLine.SetCurrentKey(TransactionId);
                WalletAssetLine.SetRange(TransactionId, WalletAssetHeader.TransactionId);
                WalletAssetLine.SetRange(Type, WalletAssetLine.Type::WALLET);

                if WalletAssetLine.FindLast() then
                    FoundWallet := TryAddWalletAssetToManifest(WalletAssetLine, TempLineBuffer, ManifestId, AssetsAdded);
            end;
        until (WalletAssetHeaderRef.Next() = 0) or FoundWallet;
    end;

    local procedure TryAddWalletAssetToManifest(
        WalletAssetLine: Record "NPR WalletAssetLine";
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        ManifestId: Guid;
        var AssetsAdded: Integer): Boolean
    var
        Wallet: Record "NPR AttractionWallet";
        Item: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        NPDesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
    begin
        Wallet.SetLoadFields(OriginatesFromItemNo, SystemId, ReferenceNumber);
        if not Wallet.GetBySystemId(WalletAssetLine.LineTypeSystemId) then
            exit(false);

        // Check if this wallet matches the line's item no.
        if Wallet.OriginatesFromItemNo <> TempLineBuffer."No." then
            exit(false);

        Item.SetLoadFields("NPR Item AddOn No.");
        if not Item.Get(Wallet.OriginatesFromItemNo) then
            exit(false);

        ItemAddOn.SetLoadFields(NPDesignerTemplateId);
        if not ItemAddOn.Get(Item."NPR Item AddOn No.") then
            exit(false);

        if ItemAddOn.NPDesignerTemplateId = '' then
            exit(false);

        NPDesignerManifestFacade.AddAssetToManifest(
            ManifestId,
            Database::"NPR AttractionWallet",
            Wallet.SystemId,
            Wallet.ReferenceNumber,
            ItemAddOn.NPDesignerTemplateId
        );
        AssetsAdded += 1;
        exit(true);
    end;

    local procedure CreateNotificationEntry(
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        ManifestId: Guid)
    var
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
    begin
        if not ValidateDigitalNotifSetup() then
            exit;

        DigitalNotifEntry.Init();
        DigitalNotifEntry."External Order No." := TempHeaderBuffer."External Order No.";
        DigitalNotifEntry."Document Type" := TempHeaderBuffer."Document Type";
        DigitalNotifEntry."Posted Document No." := TempHeaderBuffer."Posted Document No.";
        DigitalNotifEntry."Recipient E-mail" := TempHeaderBuffer."Recipient E-mail";
        DigitalNotifEntry."Recipient Name" := TempHeaderBuffer."Recipient Name";
        DigitalNotifEntry."Language Code" := TempHeaderBuffer."Language Code";
        DigitalNotifEntry."Manifest ID" := ManifestId;
        DigitalNotifEntry."Email Template Id" := DigitalNotifSetup."Email Template Id Order";
        DigitalNotifEntry.Sent := false;

        DigitalNotifEntry.Insert(true);
    end;

    internal procedure ValidateDigitalNotifSetup(): Boolean
    var
        ErrorMessage: Text;
    begin
        Exit(ValidateDigitalNotifSetup(ErrorMessage));
    end;

    internal procedure ValidateDigitalNotifSetup(var ErrorMessage: Text): Boolean
    var
        NoSetupErr: Label 'Digital Notification setup is not configured. Please configure the setup before sending digital notifications.';
        NoEmailTemplateErr: Label 'Email Template ID is not configured in Digital Order Notification setup.';
        NotEnabledErr: Label 'Digital Notification is not enabled in the setup.';
    begin
        ErrorMessage := '';
        if DigitalNotifSetupRead then
            exit(true);

        DigitalNotifSetup.SetLoadFields(Enabled, "Email Template Id Order", "Exclude Vouchers From Manifest");
        if not DigitalNotifSetup.Get() then begin
            ErrorMessage := NoSetupErr;
            exit(false);
        end;

        if not DigitalNotifSetup.Enabled then begin
            ErrorMessage := NotEnabledErr;
            exit(false);
        end;

        if DigitalNotifSetup."Email Template Id Order" = '' then begin
            ErrorMessage := NoEmailTemplateErr;
            exit(false);
        end;

        DigitalNotifSetupRead := true;
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


    local procedure ConfirmResendNotification(DocumentNo: Code[20]; DocumentType: Enum "NPR Digital Document Type"): Boolean
    var
        DigitalNotifEntry: Record "NPR Digital Notification Entry";
        ConfirmManagement: Codeunit "Confirm Management";
        ResendConfirmQst: Label 'A digital notification has already been sent for this document. Do you want to send it again?';
    begin
        // Check if notification already sent for this document
        DigitalNotifEntry.SetRange("Posted Document No.", DocumentNo);
        DigitalNotifEntry.SetRange("Document Type", DocumentType);

        if DigitalNotifEntry.IsEmpty() then
            exit(true); // No previous notification, proceed without confirmation

        exit(ConfirmManagement.GetResponseOrDefault(ResendConfirmQst, false));
    end;

    local procedure ProcessSalesDocumentManual(RecVariant: Variant): Boolean
    var
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        RecRef: RecordRef;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DocumentNo: Code[20];
        CustomerNoEmailErr: Label 'Customer %1 does not have an email address configured. Please add an email address before sending the digital notification.', Comment = '%1 = Customer No.';
        UnsupportedDocumentTypeErr: Label 'Document type %1 is not supported for manual digital notification sending.', Comment = '%1 = Record name';
    begin
        RecRef.GetTable(RecVariant);

        case RecRef.Number of
            Database::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader := RecVariant;
                    DocumentNo := SalesInvoiceHeader."No.";

                    if not ConfirmResendNotification(DocumentNo, "NPR Digital Document Type"::Invoice) then
                        exit(false);

                    PopulateBuffersFromInvoice(SalesInvoiceHeader, TempHeaderBuffer, TempLineBuffer);
                end;

            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader := RecVariant;
                    DocumentNo := SalesCrMemoHeader."No.";

                    if not ConfirmResendNotification(DocumentNo, "NPR Digital Document Type"::"Credit Memo") then
                        exit(false);

                    PopulateBuffersFromCrMemo(SalesCrMemoHeader, TempHeaderBuffer, TempLineBuffer);
                end;
            else
                Error(UnsupportedDocumentTypeErr, RecRef.Name);
        end;

        if TempHeaderBuffer."Recipient E-mail" = '' then
            Error(CustomerNoEmailErr, TempHeaderBuffer."Customer No.");

        exit(ProcessSalesDocument(TempHeaderBuffer, TempLineBuffer));
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

    internal procedure PopulateBuffersFromInvoice(
        SalesInvHeader: Record "Sales Invoice Header";
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        RecipientEmail: Text[80];
        RecipientName: Text[100];
        CurrencyCode: Code[10];
    begin
        GetRecipientInfo(SalesInvHeader, RecipientEmail, RecipientName);

        SalesInvHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");

        // Get currency code, fallback to LCY if empty
        CurrencyCode := SalesInvHeader."Currency Code";
        if CurrencyCode = '' then begin
            GeneralLedgerSetup.SetLoadFields("LCY Code");
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        TempHeaderBuffer.Init();
        TempHeaderBuffer."External Order No." := SalesInvHeader."NPR External Order No.";
        TempHeaderBuffer."Document Type" := TempHeaderBuffer."Document Type"::Invoice;
        TempHeaderBuffer."Posted Document No." := SalesInvHeader."No.";
        TempHeaderBuffer."Customer No." := SalesInvHeader."Sell-to Customer No.";
        TempHeaderBuffer."Recipient E-mail" := RecipientEmail;
        TempHeaderBuffer."Recipient Name" := RecipientName;
        TempHeaderBuffer."Language Code" := SalesInvHeader."Language Code";
        if SalesInvHeader."Order Date" <> 0D then
            TempHeaderBuffer."Document Date" := SalesInvHeader."Order Date"
        else
            TempHeaderBuffer."Document Date" := SalesInvHeader."Posting Date";
        TempHeaderBuffer."Currency Code" := CurrencyCode;
        TempHeaderBuffer."Total Amount Excl. VAT" := SalesInvHeader.Amount;
        TempHeaderBuffer."Total Amount Incl. VAT" := SalesInvHeader."Amount Including VAT";
        TempHeaderBuffer."Invoice Discount Amount" := SalesInvHeader."Invoice Discount Amount";
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
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        RecipientEmail: Text[80];
        RecipientName: Text[100];
        CurrencyCode: Code[10];
    begin
        GetRecipientInfo(SalesCrMemoHeader, RecipientEmail, RecipientName);

        SalesCrMemoHeader.CalcFields(Amount, "Amount Including VAT", "Invoice Discount Amount");

        CurrencyCode := SalesCrMemoHeader."Currency Code";
        if CurrencyCode = '' then begin
            GeneralLedgerSetup.SetLoadFields("LCY Code");
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        TempHeaderBuffer.Init();
        TempHeaderBuffer."External Order No." := SalesCrMemoHeader."NPR External Order No.";
        TempHeaderBuffer."Document Type" := TempHeaderBuffer."Document Type"::"Credit Memo";
        TempHeaderBuffer."Posted Document No." := SalesCrMemoHeader."No.";
        TempHeaderBuffer."Customer No." := SalesCrMemoHeader."Sell-to Customer No.";
        TempHeaderBuffer."Recipient E-mail" := RecipientEmail;
        TempHeaderBuffer."Recipient Name" := RecipientName;
        TempHeaderBuffer."Language Code" := SalesCrMemoHeader."Language Code";
        TempHeaderBuffer."Document Date" := SalesCrMemoHeader."Posting Date";
        TempHeaderBuffer."Currency Code" := CurrencyCode;
        TempHeaderBuffer."Total Amount Excl. VAT" := SalesCrMemoHeader.Amount;
        TempHeaderBuffer."Total Amount Incl. VAT" := SalesCrMemoHeader."Amount Including VAT";
        TempHeaderBuffer."Invoice Discount Amount" := SalesCrMemoHeader."Invoice Discount Amount";
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
}
#endif
