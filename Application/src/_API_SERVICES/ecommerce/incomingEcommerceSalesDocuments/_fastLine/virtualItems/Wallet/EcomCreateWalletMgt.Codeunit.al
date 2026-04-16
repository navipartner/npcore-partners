#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151072 "NPR EcomCreateWalletMgt"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Line";

    var
        AttractionWalletFacade: Codeunit "NPR AttractionWalletFacade";

    trigger OnRun()
    begin
        CreateWalletsForBundle(Rec);
    end;

    local procedure CreateWalletsForBundle(ParentLine: Record "NPR Ecom Sales Line")
    var
        Customer: Record Customer;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        WalletEntryNos: List of [Integer];
        WalletRefNo: Text[50];
        WalletCount: Integer;
        WalletEntryNo: Integer;
        i: Integer;
    begin
        WalletCount := Round(ParentLine.Quantity, 1, '>');
        if WalletCount <= 0 then
            WalletCount := 1;

        EcomSalesHeader.Get(ParentLine."Document Entry No.");

        for i := 1 to WalletCount do begin
            WalletRefNo := '';
            WalletEntryNo := AttractionWalletFacade.CreateWallet(CopyStr(ParentLine."No.", 1, 20), CopyStr(ParentLine.Description, 1, 100), WalletRefNo);
            WalletEntryNos.Add(WalletEntryNo);

            AttractionWalletFacade.SetWalletReferenceNumber(WalletEntryNo, Database::"NPR Ecom Sales Header", EcomSalesHeader.SystemId, CopyStr(Format(EcomSalesHeader.RecordId()), 1, 100));
            AttractionWalletFacade.SetWalletReferenceNumber(WalletEntryNo, Database::"NPR Ecom Sales Line", ParentLine.SystemId, CopyStr(Format(ParentLine.RecordId()), 1, 100));
            if (EcomSalesHeader."Sell-to Customer No." <> '') and Customer.Get(EcomSalesHeader."Sell-to Customer No.") then
                AttractionWalletFacade.SetWalletReferenceNumber(WalletEntryNo, Database::Customer, Customer.SystemId, Customer."No.");
        end;

        AddAssetsToWallets(WalletEntryNos, WalletEntryNos.Count(), EcomSalesHeader, ParentLine);
    end;

    local procedure AddAssetsToWallets(WalletEntryNos: List of [Integer]; WalletCount: Integer; EcomSalesHeader: Record "NPR Ecom Sales Header"; ParentLine: Record "NPR Ecom Sales Line")
    var
        ComponentLine: Record "NPR Ecom Sales Line";
        ParentLine2: Record "NPR Ecom Sales Line";
        TempAssetEcomSalesLine: Record "NPR Ecom Sales Line" temporary;
        AllAssetIds: List of [Guid];
        AllVoucherIds: List of [Guid];
        WalletAssetIds: List of [Guid];
        AssetId: Guid;
        WalletEntryNo: Integer;
        WalletIdx: Integer;
        AssetIdx: Integer;
    begin
        if WalletCount = 0 then
            exit;

        if ParentLine."Is Attraction Wallet" then begin  // top parent line of the attraction wallet
            ParentLine2 := ParentLine;
            ParentLine2.SetRecFilter();
            ParentLine2.SetRange("Virtual Item Process Status", ParentLine2."Virtual Item Process Status"::Processed);
            SetComponentLineSupportedSubtypeFilter(ParentLine2);
            if ParentLine2.Find() then begin
                TempAssetEcomSalesLine := ParentLine2;
                TempAssetEcomSalesLine.Insert();
            end;
        end;

        ComponentLine.SetCurrentKey("Document Entry No.", "Parent Ext. Line ID", "External Line ID", "Is Attraction Wallet");
        ComponentLine.SetRange("Document Entry No.", ParentLine."Document Entry No.");
        ComponentLine.SetRange("Parent Ext. Line ID", ParentLine."External Line ID");
        ComponentLine.SetFilter("External Line ID", '<>%1', ParentLine."External Line ID");
        ComponentLine.SetRange("Is Attraction Wallet", false);  // Nested wallets are not supported
        if ComponentLine.FindSet() then
            repeat
                TempAssetEcomSalesLine := ComponentLine;
                TempAssetEcomSalesLine.Insert();
            until ComponentLine.Next() = 0;

        if not TempAssetEcomSalesLine.FindSet() then
            exit;
        repeat
            Clear(AllAssetIds);
            case TempAssetEcomSalesLine.Subtype of
                TempAssetEcomSalesLine.Subtype::Ticket:
                    GetTicketSystemIds(TempAssetEcomSalesLine, AllAssetIds);
                TempAssetEcomSalesLine.Subtype::Voucher:
                    GetVoucherSystemIds(TempAssetEcomSalesLine, AllVoucherIds);  // Accumulate across all voucher lines before distributing
                TempAssetEcomSalesLine.Subtype::Coupon:
                    GetCouponSystemIds(EcomSalesHeader, TempAssetEcomSalesLine, AllAssetIds);
                TempAssetEcomSalesLine.Subtype::Membership:
                    ; // Membership support is coming in a future release, so for now we simply skip any membership lines instead of throwing an error
            end;

            if AllAssetIds.Count() > 0 then
                for WalletIdx := 1 to WalletCount do begin
                    Clear(WalletAssetIds);
                    AssetIdx := WalletIdx - 1;
                    while AssetIdx < AllAssetIds.Count() do begin
                        AllAssetIds.Get(AssetIdx + 1, AssetId);
                        WalletAssetIds.Add(AssetId);
                        AssetIdx += WalletCount;
                    end;
                    if WalletAssetIds.Count() > 0 then begin
                        WalletEntryNos.Get(WalletIdx, WalletEntryNo);
                        case TempAssetEcomSalesLine.Subtype of
                            TempAssetEcomSalesLine.Subtype::Ticket:
                                AttractionWalletFacade.AddTicketsToWallet(WalletEntryNo, WalletAssetIds);
                            TempAssetEcomSalesLine.Subtype::Coupon:
                                AttractionWalletFacade.AddCouponsToWallets(WalletEntryNo, WalletAssetIds, '', EcomSalesHeader."External No.");
                        end;
                    end;
                end;

            if not TempAssetEcomSalesLine."Is Attraction Wallet" then
                AddAssetsToWallets(WalletEntryNos, WalletCount, EcomSalesHeader, TempAssetEcomSalesLine);  // Recursively add assets for nested bundle components
        until TempAssetEcomSalesLine.Next() = 0;

        // Distribute all accumulated voucher IDs across wallets using the same round-robin algorithm.
        // Vouchers have one ecom sales line per voucher (unlike tickets/coupons which can have multiple assets per line),
        // so they must be collected from all component lines first before splitting across wallets.
        if AllVoucherIds.Count() > 0 then
            for WalletIdx := 1 to WalletCount do begin
                Clear(WalletAssetIds);
                AssetIdx := WalletIdx - 1;
                while AssetIdx < AllVoucherIds.Count() do begin
                    AllVoucherIds.Get(AssetIdx + 1, AssetId);
                    WalletAssetIds.Add(AssetId);
                    AssetIdx += WalletCount;
                end;
                if WalletAssetIds.Count() > 0 then begin
                    WalletEntryNos.Get(WalletIdx, WalletEntryNo);
                    AttractionWalletFacade.AddVouchersToWallets(WalletEntryNo, WalletAssetIds, '', CopyStr(EcomSalesHeader."External Document No.", 1, 20));
                end;
            end;
    end;

    local procedure GetTicketSystemIds(ComponentLine: Record "NPR Ecom Sales Line"; var TicketIds: List of [Guid])
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationReq: Record "NPR TM Ticket Reservation Req.";
    begin
        if IsNullGuid(ComponentLine."Ticket Reservation Line Id") then
            exit;
        if not TicketReservationReq.GetBySystemId(ComponentLine."Ticket Reservation Line Id") then
            exit;
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetRange("Ticket Reservation Entry No.", TicketReservationReq."Entry No.");
        if Ticket.FindSet() then
            repeat
                TicketIds.Add(Ticket.SystemId);
            until Ticket.Next() = 0;
    end;

    local procedure GetVoucherSystemIds(ComponentLine: Record "NPR Ecom Sales Line"; var VoucherIds: List of [Guid])
    var
        Voucher: Record "NPR NpRv Voucher";
    begin
        if Voucher.Get(ComponentLine."No.") then
            VoucherIds.Add(Voucher.SystemId);
    end;

    local procedure GetCouponSystemIds(EcomSalesHeader: Record "NPR Ecom Sales Header"; ComponentLine: Record "NPR Ecom Sales Line"; var CouponIds: List of [Guid])
    var
        EcomSalesCouponLink: Record "NPR Ecom Sales Coupon Link";
    begin
        EcomSalesCouponLink.SetCurrentKey("Source", "Source System Id", "Source Line System Id");
        EcomSalesCouponLink.SetRange("Source", EcomSalesCouponLink."Source"::"Ecom Sales Document");
        EcomSalesCouponLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        EcomSalesCouponLink.SetRange("Source Line System Id", ComponentLine.SystemId);
        if not EcomSalesCouponLink.FindSet() then
            exit;
        repeat
            CouponIds.Add(EcomSalesCouponLink."Coupon System Id");
        until EcomSalesCouponLink.Next() = 0;
    end;

    internal procedure CreateWallets(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        ParentLine: Record "NPR Ecom Sales Line";
        ParentLine2: Record "NPR Ecom Sales Line";
    begin
        if not EcomSalesHeader."Attraction Wallets Exist" or
           (EcomSalesHeader."Attr. Wallet Processing Status" = EcomSalesHeader."Attr. Wallet Processing Status"::Processed) or
           (EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created) or
           not (EcomSalesHeader."Capture Processing Status" in [EcomSalesHeader."Capture Processing Status"::"Partially Processed", EcomSalesHeader."Capture Processing Status"::Processed])
        then
            exit;

        ParentLine.SetCurrentKey("Document Entry No.", "Is Attraction Wallet", "Attr. Wallet Processing Status");
        ParentLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        ParentLine.SetRange("Is Attraction Wallet", true);
        ParentLine.SetFilter("Attr. Wallet Processing Status", '<>%1', ParentLine."Attr. Wallet Processing Status"::Processed);
        if ParentLine.FindSet() then
            repeat
                ParentLine2 := ParentLine;
                CreateWalletsForTopLevelParentLine(EcomSalesHeader, ParentLine2, ShowError, UpdateRetryCount);
            until ParentLine.Next() = 0;

        EcomSalesHeader.Get(EcomSalesHeader.RecordId());
    end;

    internal procedure ShowRelatedWallets(TableId: Integer; SystemId: Guid)
    var
        TempWallet: Record "NPR AttractionWallet" temporary;
        Wallet: Record "NPR AttractionWallet";
        WalletAssetHeader: Record "NPR WalletAssetHeader";
        WalletAssetHeaderRef: Record "NPR WalletAssetHeaderReference";
        WalletAssetLine: Record "NPR WalletAssetLine";
    begin
        WalletAssetLine.SetCurrentKey(TransactionId, Type);
        WalletAssetLine.SetRange(Type, WalletAssetLine.Type::WALLET);

        WalletAssetHeaderRef.SetCurrentKey(LinkToTableId, LinkToSystemId);
        WalletAssetHeaderRef.SetRange(LinkToTableId, TableId);
        WalletAssetHeaderRef.SetRange(LinkToSystemId, SystemId);
        if WalletAssetHeaderRef.FindSet() then
            repeat
                if WalletAssetHeader.Get(WalletAssetHeaderRef.WalletHeaderEntryNo) then begin
                    WalletAssetLine.SetRange(TransactionId, WalletAssetHeader.TransactionId);
                    if WalletAssetLine.FindSet() then
                        repeat
                            if Wallet.GetBySystemId(WalletAssetLine.LineTypeSystemId) then begin
                                TempWallet := Wallet;
                                if TempWallet.Insert() then;
                            end;
                        until WalletAssetLine.Next() = 0;
                end;
            until WalletAssetHeaderRef.Next() = 0;

        Page.RunModal(Page::"NPR AttractionWallets", TempWallet);
    end;

    internal procedure CreateWalletsForTopLevelParentLineWithCheck(var ParentLine: Record "NPR Ecom Sales Line"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        if not ParentLine."Is Attraction Wallet" or
           (ParentLine."Attr. Wallet Processing Status" = ParentLine."Attr. Wallet Processing Status"::Processed)
        then
            exit;
        EcomSalesHeader.Get(ParentLine."Document Entry No.");
        if (EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created) or
           not (EcomSalesHeader."Capture Processing Status" in [EcomSalesHeader."Capture Processing Status"::"Partially Processed", EcomSalesHeader."Capture Processing Status"::Processed])
        then
            exit;

        CreateWalletsForTopLevelParentLine(EcomSalesHeader, ParentLine, ShowError, UpdateRetryCount);
    end;

    local procedure CreateWalletsForTopLevelParentLine(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var ParentLine: Record "NPR Ecom Sales Line"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        ErrorText: Text;
        Success: Boolean;
        VirtualItemProcessingFailed: Boolean;
        BundleComponentsFailedErr: Label 'Cannot create wallet: one or more wallet virtual components failed to process. Line ID: %1.', Comment = '%1 - Parent external line ID';
    begin
        Success := AllBundleVirtualComponentsProcessed(ParentLine, VirtualItemProcessingFailed);
        if Success then
            Success := ParentLineProcessedAsVirtualItem(ParentLine, VirtualItemProcessingFailed);
        if not Success then begin
            if VirtualItemProcessingFailed then begin
                ErrorText := StrSubstNo(BundleComponentsFailedErr, ParentLine."External Line ID");
                SetParentLineErrorStatus(EcomSalesHeader, ParentLine, UpdateRetryCount, ErrorText);
                Commit();
                if ShowError then
                    Error(ErrorText);
            end;
            exit;
        end;

        ClearLastError();
        Commit();

        Success := Codeunit.Run(Codeunit::"NPR EcomCreateWalletMgt", ParentLine);
        if not Success then
            ErrorText := GetLastErrorText();
        HandleResponse(Success, EcomSalesHeader, ParentLine, UpdateRetryCount, ErrorText);
        Commit();

        if not Success and ShowError then
            Error(ErrorText);
    end;

    local procedure AllBundleVirtualComponentsProcessed(ParentLine: Record "NPR Ecom Sales Line"; var VirtualItemProcessingFailed: Boolean): Boolean
    var
        ComponentLine: Record "NPR Ecom Sales Line";
    begin
        ComponentLine.SetCurrentKey("Document Entry No.", "Parent Ext. Line ID", "External Line ID", "Is Attraction Wallet", Subtype, "Virtual Item Process Status");
        ComponentLine.SetRange("Document Entry No.", ParentLine."Document Entry No.");
        ComponentLine.SetRange("Parent Ext. Line ID", ParentLine."External Line ID");
        ComponentLine.SetFilter("External Line ID", '<>%1', ParentLine."External Line ID");
        ComponentLine.SetRange("Is Attraction Wallet", false);  // Nested wallets are not supported
        SetComponentLineSupportedSubtypeFilter(ComponentLine);
        if ComponentLine.IsEmpty() then  // No virtual item components
            exit(true);

        ComponentLine.SetFilter("Virtual Item Process Status", '<>%1', ComponentLine."Virtual Item Process Status"::Processed);
        if not ComponentLine.IsEmpty() then begin
            ComponentLine.SetRange("Virtual Item Process Status", ComponentLine."Virtual Item Process Status"::Error);
            VirtualItemProcessingFailed := not ComponentLine.IsEmpty();
            exit(false);
        end;

        ComponentLine.SetRange(Subtype);
        ComponentLine.SetRange("Virtual Item Process Status");
        if ComponentLine.FindSet() then
            repeat
                if not AllBundleVirtualComponentsProcessed(ComponentLine, VirtualItemProcessingFailed) then
                    exit(false);
            until ComponentLine.Next() = 0;
        exit(true);
    end;

    local procedure ParentLineProcessedAsVirtualItem(ParentLine: Record "NPR Ecom Sales Line"; var VirtualItemProcessingFailed: Boolean): Boolean
    begin
        if not ParentLine.IsVirtualItem() then
            exit(true); // Non-virtual item lines are still considered processed for wallet creation purposes

        if ParentLine."Virtual Item Process Status" = ParentLine."Virtual Item Process Status"::Processed then
            exit(true);

        if ParentLine."Virtual Item Process Status" = ParentLine."Virtual Item Process Status"::Error then
            VirtualItemProcessingFailed := true;

        exit(false);
    end;

    local procedure SetParentLineErrorStatus(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var ParentLine: Record "NPR Ecom Sales Line"; UpdateRetryCount: Boolean; ErrorText: Text)
    var
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        ParentLine.ReadIsolation := ParentLine.ReadIsolation::UpdLock;
        ParentLine.Get(ParentLine.RecordId());
        ParentLine."Attr. Wallet Process ErrMsg" := CopyStr(ErrorText, 1, MaxStrLen(ParentLine."Attr. Wallet Process ErrMsg"));
        if UpdateRetryCount then
            ParentLine."Attr. Wallet Retry Count" += 1;
        ParentLine."Attr. Wallet Processing Status" := ParentLine."Attr. Wallet Processing Status"::Error;
        ParentLine.Modify(true);

        EcomSalesHeader2.ReadIsolation := EcomSalesHeader2.ReadIsolation::UpdLock;
        EcomSalesHeader2.Get(EcomSalesHeader."Entry No.");
        EmitWalletProcessingError(ErrorText);
        EcomSalesHeader2."Attr. Wallet Processing Status" := EcomSalesHeader2."Attr. Wallet Processing Status"::Error;
        EcomSalesHeader2."Virtual Items Process Status" := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader2);
        EcomSalesHeader2.Modify(true);

        EcomSalesHeader := EcomSalesHeader2;
    end;

    local procedure HandleResponse(Success: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var ParentLine: Record "NPR Ecom Sales Line"; UpdateRetryCount: Boolean; ErrorText: Text)
    var
        EcomSalesHeader2: Record "NPR Ecom Sales Header";
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();
        if IncEcomSalesDocSetup."Max Attr. Wallet Retry Count" <= 0 then
            IncEcomSalesDocSetup."Max Attr. Wallet Retry Count" := 3;

        EcomSalesHeader2.ReadIsolation := EcomSalesHeader2.ReadIsolation::UpdLock;
        EcomSalesHeader2.Get(EcomSalesHeader."Entry No.");

        ParentLine.ReadIsolation := ParentLine.ReadIsolation::UpdLock;
        ParentLine.Get(ParentLine.RecordId());

        if UpdateRetryCount then
            ParentLine."Attr. Wallet Retry Count" += 1;
        if Success then begin
            ParentLine."Attr. Wallet Processing Status" := ParentLine."Attr. Wallet Processing Status"::Processed;
            ParentLine."Attr. Wallet Process ErrMsg" := ''; // Clear any previous error message
        end else begin
            ParentLine."Attr. Wallet Process ErrMsg" := CopyStr(ErrorText, 1, MaxStrLen(ParentLine."Attr. Wallet Process ErrMsg"));
            if ParentLine."Attr. Wallet Retry Count" >= IncEcomSalesDocSetup."Max Attr. Wallet Retry Count" then
                ParentLine."Attr. Wallet Processing Status" := ParentLine."Attr. Wallet Processing Status"::Error;
            EmitWalletProcessingError(ErrorText);
        end;
        ParentLine.Modify(true);

        EcomSalesHeader := EcomSalesHeader2;
        CalculateWalletDocStatus(EcomSalesHeader2);
        EcomSalesHeader2."Virtual Items Process Status" := EcomVirtualItemMgt.CalculateVirtualItemsDocStatus(EcomSalesHeader2);
        if (EcomSalesHeader."Attr. Wallet Processing Status" <> EcomSalesHeader2."Attr. Wallet Processing Status") or
           (EcomSalesHeader."Virtual Items Process Status" <> EcomSalesHeader2."Virtual Items Process Status")
        then
            EcomSalesHeader2.Modify(true);

        EcomSalesHeader := EcomSalesHeader2;
    end;

    local procedure CalculateWalletDocStatus(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange("Is Attraction Wallet", true);
        if EcomSalesLine.IsEmpty() then
            exit; // no wallets in the document

        EcomSalesLine.SetRange("Attr. Wallet Processing Status", EcomSalesLine."Attr. Wallet Processing Status"::Error);
        if not EcomSalesLine.IsEmpty() then begin
            EcomSalesHeader."Attr. Wallet Processing Status" := EcomSalesHeader."Attr. Wallet Processing Status"::Error;
            exit;
        end;

        EcomSalesLine.SetRange("Attr. Wallet Processing Status", EcomSalesLine."Attr. Wallet Processing Status"::Processed);
        if not EcomSalesLine.IsEmpty() then begin
            EcomSalesLine.SetRange("Attr. Wallet Processing Status", EcomSalesLine."Attr. Wallet Processing Status"::" ");
            if not EcomSalesLine.IsEmpty() then
                EcomSalesHeader."Attr. Wallet Processing Status" := EcomSalesHeader."Attr. Wallet Processing Status"::"Partially Processed"
            else
                EcomSalesHeader."Attr. Wallet Processing Status" := EcomSalesHeader."Attr. Wallet Processing Status"::Processed;
            exit;
        end;

        EcomSalesHeader."Attr. Wallet Processing Status" := EcomSalesHeader."Attr. Wallet Processing Status"::Pending;
    end;

    local procedure SetComponentLineSupportedSubtypeFilter(var ComponentLine: Record "NPR Ecom Sales Line")
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
    begin
        EcomVirtualItemMgt.SetVirtualItemSubtypeFilter(ComponentLine);
    end;

    local procedure EmitWalletProcessingError(ErrorText: Text)
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        WalletEventId: Label 'NPR_API_Ecommerce_WalletCreationFailed', Locked = true;
    begin
        EcomVirtualItemMgt.EmitError(ErrorText, WalletEventId);
    end;

    internal procedure IsAttractionWallet(EcomSalesLine: Record "NPR Ecom Sales Line"): Boolean
    var
        Item: Record Item;
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        ItemNo: Code[20];
        VariantCode: Code[10];
    begin
        if EcomSalesDocUtils.GetItemNoAndVariantNoFromEcomSalesLine(EcomSalesLine, ItemNo, VariantCode) then
            if ItemNo <> '' then
                if Item.Get(ItemNo) then
                    exit(Item."NPR CreateAttractionWallet");
        exit(false);
    end;

    internal procedure IsPartOfAttractionWalletBundle(EcomSalesLine: Record "NPR Ecom Sales Line"): Boolean
    var
        ParentEcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        if EcomSalesLine."Is Attraction Wallet" then
            exit(true);
        if EcomSalesLine."Parent Ext. Line ID" = '' then
            exit(false);
        ParentEcomSalesLine.SetCurrentKey("Document Entry No.", "Parent Ext. Line ID", "External Line ID");
        ParentEcomSalesLine.SetRange("Document Entry No.", EcomSalesLine."Document Entry No.");
        ParentEcomSalesLine.SetFilter("Line No.", '<>%1', EcomSalesLine."Line No.");
        ParentEcomSalesLine.SetRange("External Line ID", EcomSalesLine."Parent Ext. Line ID");
        if ParentEcomSalesLine.FindFirst() then
            exit(IsPartOfAttractionWalletBundle(ParentEcomSalesLine));
    end;
}
#endif
