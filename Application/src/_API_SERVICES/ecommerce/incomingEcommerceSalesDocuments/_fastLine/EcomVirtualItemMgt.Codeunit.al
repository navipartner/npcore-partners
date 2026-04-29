#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248551 "NPR Ecom Virtual Item Mgt"
{
    Access = Internal;

    local procedure ProcessVirtualItemLine(var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        UnsupportedSubtypeLbl: Label 'Subtype %1 in %2 is not supported.', Comment = '%1 - ecom sales line subtype, %2 - record id';
    begin
        if EcomSalesLine."Virtual Item Process Status" <> EcomSalesLine."Virtual Item Process Status"::Processed then
            case EcomSalesLine.Subtype of
                EcomSalesLine.Subtype::Voucher:
                    CreateVoucher(EcomSalesLine, true, false);
                EcomSalesLine.Subtype::Ticket:
                    begin
                        EcomSalesHeader.Get(EcomSalesLine."Document Entry No.");
                        CreateTickets(EcomSalesHeader, true, false);
                    end;
                EcomSalesLine.Subtype::Membership:
                    CreateMembership(EcomSalesLine, true, false);
                EcomSalesLine.Subtype::Coupon:
                    CreateCoupons(EcomSalesLine, true, false);
                else
                    if not EcomSalesLine."Is Attraction Wallet" then
                        Error(UnsupportedSubtypeLbl, EcomSalesLine.Subtype, EcomSalesLine.RecordId);
            end;

        if EcomSalesLine."Is Attraction Wallet" then begin
            EcomSalesLine.Get(EcomSalesLine.RecordId());
            CreateWallets(EcomSalesLine, true, false);
        end;
    end;

    internal procedure ProcessVirtualItemLineWithConfirmation(var EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmVirtualItemLbl: Label 'Are you sure you want to process the virtual item?';
    begin
        if not ConfirmManagement.GetResponseOrDefault(ConfirmVirtualItemLbl, true) then
            exit;

        ProcessVirtualItemLine(EcomSalesLine);
    end;

    internal procedure CreateVouchers(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        if not EcomSalesHeader."Vouchers Exist" then
            exit;

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;

        if (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::"Partially Processed") and
            (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::Processed) then
            exit;

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Voucher);
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::" ");
        EcomSalesLine.SetRange(Captured, true);
        EcomSalesLine.SetFilter(Quantity, '<>0');
        EcomSalesLine.SetFilter("Unit Price", '<>0');
        if EcomSalesLine.FindSet() then
            repeat
                CreateVoucher(EcomSalesLine, ShowError, UpdateRetryCount);
            until EcomSalesLine.Next() = 0;

        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
    end;

    internal procedure CaptureEcomDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomSaleDocCaptureProcess: Codeunit "NPR EcomSaleDocCaptureProcess";
    begin
        if not EcomSalesHeader."Virtual Items Exist" then
            exit;

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;

        Clear(EcomSaleDocCaptureProcess);
        EcomSaleDocCaptureProcess.SetShowError(ShowError);
        EcomSaleDocCaptureProcess.SetUpdateRetryCount(UpdateRetryCount);
        EcomSaleDocCaptureProcess.Run(EcomSalesHeader);
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
    end;

    local procedure CreateVoucher(var EcomSalesLine: Record "NPR Ecom Sales Line"; ShowError: Boolean; UpdateRetryCount: Boolean) Success: Boolean
    var
        EcomCreateVchrProcess: Codeunit "NPR EcomCreateVchrProcess";
    begin
        Clear(EcomCreateVchrProcess);
        EcomCreateVchrProcess.SetShowError(ShowError);
        EcomCreateVchrProcess.SetUpdateRetryCount(UpdateRetryCount);
        Success := EcomCreateVchrProcess.Run(EcomSalesLine);
    end;

    internal procedure CreateMemberships(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        if not EcomSalesHeader."Memberships Exist" then
            exit;

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;

        if (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::"Partially Processed") and
                    (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::Processed) then
            exit;

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Membership);
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::" ");
        EcomSalesLine.SetRange(Captured, true);
        EcomSalesLine.SetFilter(Quantity, '<>0');
        if EcomSalesLine.FindSet() then
            repeat
                CreateMembership(EcomSalesLine, ShowError, UpdateRetryCount);
            until EcomSalesLine.Next() = 0;

        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
    end;

    local procedure CreateMembership(var EcomSalesLine: Record "NPR Ecom Sales Line"; ShowError: Boolean; UpdateRetryCount: Boolean) Success: Boolean
    var
        EcomCreateMMShipProcess: Codeunit "NPR EcomCreateMMShipProcess";
    begin
        Clear(EcomCreateMMShipProcess);
        EcomCreateMMShipProcess.SetShowError(ShowError);
        EcomCreateMMShipProcess.SetUpdateRetryCount(UpdateRetryCount);
        Success := EcomCreateMMShipProcess.Run(EcomSalesLine);
    end;

    internal procedure CreateCoupons(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        if not EcomSalesHeader."Coupons Exist" then
            exit;
        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;
        if not (EcomSalesHeader."Capture Processing Status" in [EcomSalesHeader."Capture Processing Status"::"Partially Processed", EcomSalesHeader."Capture Processing Status"::Processed]) then
            exit;

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Coupon);
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::" ");
        EcomSalesLine.SetRange(Captured, true);
        EcomSalesLine.SetFilter(Quantity, '<>%1', 0);
        if EcomSalesLine.FindSet() then
            repeat
                CreateCoupons(EcomSalesLine, ShowError, UpdateRetryCount);
            until EcomSalesLine.Next() = 0;

        EcomSalesHeader.Get(EcomSalesHeader.RecordId());
    end;

    local procedure CreateCoupons(var EcomSalesLine: Record "NPR Ecom Sales Line"; ShowError: Boolean; UpdateRetryCount: Boolean) Success: Boolean
    var
        EcomCreateCouponProcess: Codeunit "NPR EcomCreateCouponProcess";
    begin
        Clear(EcomCreateCouponProcess);
        EcomCreateCouponProcess.SetShowError(ShowError);
        EcomCreateCouponProcess.SetUpdateRetryCount(UpdateRetryCount);
        Success := EcomCreateCouponProcess.Run(EcomSalesLine);
    end;

    local procedure CreateWallets(var EcomSalesLine: Record "NPR Ecom Sales Line"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomCreateWalletMgt: Codeunit "NPR EcomCreateWalletMgt";
    begin
        EcomCreateWalletMgt.CreateWalletsForTopLevelParentLineWithCheck(EcomSalesLine, ShowError, UpdateRetryCount);
    end;

    internal procedure CreateTickets(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ShowError: Boolean; UpdateRetryCount: Boolean)
    var
        EcomCreateTicketProcess: Codeunit "NPR EcomCreateTicketProcess";
        Success: Boolean;
    begin
        if not EcomSalesHeader."Tickets Exist" then
            exit;

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            exit;

        if (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::"Partially Processed") and
            (EcomSalesHeader."Capture Processing Status" <> EcomSalesHeader."Capture Processing Status"::Processed) then
            exit;

        if not AllTicketLinesCapturedAndUnprocessed(EcomSalesHeader, ShowError) then
            exit;

        Clear(EcomCreateTicketProcess);
        EcomCreateTicketProcess.SetShowError(ShowError);
        EcomCreateTicketProcess.SetUpdateRetryCount(UpdateRetryCount);
        Success := EcomCreateTicketProcess.Run(EcomSalesHeader);

        if not Success and ShowError then
            Error(GetLastErrorText());

        EcomSalesHeader.Get(EcomSalesHeader.RecordId);
    end;

    local procedure AllTicketLinesCapturedAndUnprocessed(EcomSalesHeader: Record "NPR Ecom Sales Header"; RunPageAction: Boolean): Boolean
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        EcomSalesLine.SetFilter(Quantity, '<>0');

        if EcomSalesLine.IsEmpty() then
            exit(false);

        EcomSalesLine.SetRange(Captured, false);
        if not EcomSalesLine.IsEmpty() then
            exit(false);

        EcomSalesLine.SetRange(Captured);
        if RunPageAction then begin
            EcomSalesLine.SetFilter("Virtual Item Process Status", '<>%1&<>%2', EcomSalesLine."Virtual Item Process Status"::" ", EcomSalesLine."Virtual Item Process Status"::Error);
            if not EcomSalesLine.IsEmpty() then
                exit(false);
        end else begin
            EcomSalesLine.SetFilter("Virtual Item Process Status", '<>%1', EcomSalesLine."Virtual Item Process Status"::" ");
            if not EcomSalesLine.IsEmpty() then
                exit(false);
        end;
        exit(true);
    end;

    internal procedure AssignBucketLines(EcomSalesHeader: Record "NPR Ecom Sales Header"): Integer
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        BucketInt: Integer;
    begin
        BucketInt := Random(100);

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        SetVirtualItemSubtypeFilter(EcomSalesLine);
        EcomSalesLine.ModifyAll("Bucket Id", BucketInt);

        exit(BucketInt);
    end;

    internal procedure GetRetryCaptureCountFilter(): Integer
    var
        EcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if not EcomSalesDocSetup.Get() then
            EcomSalesDocSetup.Init();
        exit(EcomSalesDocSetup."Max Capture Retry Count");
    end;

    internal procedure UpdateVirtualItemInformationInHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomVirtualItemEvents: Codeunit "NPR EcomVirtualItemEvents";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");

        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Voucher);
        EcomSalesHeader."Vouchers Exist" := not EcomSalesLine.IsEmpty;

        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        EcomSalesHeader."Tickets Exist" := not EcomSalesLine.IsEmpty;

        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Membership);
        EcomSalesHeader."Memberships Exist" := not EcomSalesLine.IsEmpty;

        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Coupon);
        EcomSalesHeader."Coupons Exist" := not EcomSalesLine.IsEmpty();
        EcomSalesLine.SetRange(Subtype);

        EcomSalesLine.SetRange("Is Attraction Wallet", true);
        EcomSalesHeader."Attraction Wallets Exist" := not EcomSalesLine.IsEmpty();
        EcomSalesLine.SetRange("Is Attraction Wallet");

        EcomSalesHeader."Virtual Items Exist" :=
            EcomSalesHeader."Vouchers Exist" or EcomSalesHeader."Tickets Exist" or EcomSalesHeader."Memberships Exist" or EcomSalesHeader."Coupons Exist" or EcomSalesHeader."Attraction Wallets Exist";

        EcomVirtualItemEvents.OnUpdateVirtualInformationInHeaderBeforeModify(EcomSalesHeader);
        EcomSalesHeader.Modify();
    end;

    internal procedure OpenEcomVoucherLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Voucher);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomMembershipLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Item);
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Membership);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomVirtualItemLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        SetVirtualItemSubtypeFilter(EcomSalesLine);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomTicketLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Item);
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Ticket);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomCouponLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Subtype, EcomSalesLine.Subtype::Coupon);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomWalletLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetCurrentKey("Document Entry No.", "Is Attraction Wallet");
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange("Is Attraction Wallet", true);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure OpenEcomCapturedLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Captured, true);
        Page.Run(0, EcomSalesLine);
    end;

    internal procedure GetVoucherProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        if not EcomSalesHeader."Vouchers Exist" then begin
            StyleText := 'Subordinate';
            exit;
        end;
        case EcomSalesHeader."Voucher Processing Status" of
            EcomSalesHeader."Voucher Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Voucher Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetCouponProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        if not EcomSalesHeader."Coupons Exist" then begin
            StyleText := 'Subordinate';
            exit;
        end;
        case EcomSalesHeader."Coupon Processing Status" of
            EcomSalesHeader."Coupon Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Coupon Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetTicketProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        if not EcomSalesHeader."Tickets Exist" then begin
            StyleText := 'Subordinate';
            exit;
        end;
        case EcomSalesHeader."Ticket Processing Status" of
            EcomSalesHeader."Ticket Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Ticket Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetVirtualItemProcessingStatusStyle(EcomSalesLine: Record "NPR Ecom Sales Line") StyleText: Text
    begin
        case EcomSalesLine."Virtual Item Process Status" of
            EcomSalesLine."Virtual Item Process Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesLine."Virtual Item Process Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetVirtualItemErrorTextStyle(EcomSalesLine: Record "NPR Ecom Sales Line") StyleText: Text
    begin
        case EcomSalesLine."Virtual Item Process Status" of
            EcomSalesLine."Virtual Item Process Status"::Error:
                StyleText := 'Unfavorable';
        end;
    end;

    internal procedure GetCaptureProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Capture Processing Status" of
            EcomSalesHeader."Capture Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Capture Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetCaptureErrorStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Capture Processing Status" of
            EcomSalesHeader."Capture Processing Status"::Error:
                StyleText := 'Unfavorable';
        end;
    end;

    internal procedure GetVirtualItemProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Virtual Items Process Status" of
            EcomSalesHeader."Virtual Items Process Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Virtual Items Process Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetMembershipProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        if not EcomSalesHeader."Memberships Exist" then begin
            StyleText := 'Subordinate';
            exit;
        end;
        case EcomSalesHeader."Membership Processing Status" of
            EcomSalesHeader."Membership Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Membership Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetWalletProcessingStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        if not EcomSalesHeader."Attraction Wallets Exist" then begin
            StyleText := 'Subordinate';
            exit;
        end;
        case EcomSalesHeader."Attr. Wallet Processing Status" of
            EcomSalesHeader."Attr. Wallet Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Attr. Wallet Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetWalletProcessingStatusStyle(EcomSalesLine: Record "NPR Ecom Sales Line") StyleText: Text
    begin
        case EcomSalesLine."Attr. Wallet Processing Status" of
            EcomSalesLine."Attr. Wallet Processing Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesLine."Attr. Wallet Processing Status"::Processed:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure FindVoucher(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var Voucher: Record "NPR NpRv Voucher")
    var
        GlobalVoucherWS: Codeunit "NPR NpRv Global Voucher WS";
    begin
        if not GlobalVoucherWS.FindVoucher('', CopyStr(EcomSalesPmtLine."Payment Reference", 1, 50), Voucher) then
            CheckIfVoucherHasBeenArchived(EcomSalesPmtLine)
        else
            ValidateActiveVoucher(Voucher);
    end;

    [TryFunction]
    internal procedure TryFindVoucher(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var Voucher: Record "NPR NpRv Voucher")
    begin
        FindVoucher(EcomSalesPmtLine, Voucher);
    end;

    local procedure CheckIfVoucherHasBeenArchived(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        ArchivedVoucher: Record "NPR NpRv Arch. Voucher";
        InvalidReferenceErrorLbl: Label 'Invalid voucher reference no. %1.', Comment = '%1 - reference no';
        VoucherArchivedErrorLbl: Label 'Voucher with type %1 and reference no. %2 has been archived.', Comment = '%1 - voucher type, %2 - reference no.';
    begin
        ArchivedVoucher.Reset();
        ArchivedVoucher.SetRange("Reference No.", EcomSalesPmtLine."Payment Reference");
        if not ArchivedVoucher.FindFirst() then
            Error(InvalidReferenceErrorLbl, EcomSalesPmtLine."Payment Reference");

        Error(VoucherArchivedErrorLbl, ArchivedVoucher."Voucher Type", EcomSalesPmtLine."Payment Reference");
    end;

    local procedure ValidateActiveVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        VoucherFullyUsedErrorLbl: Label 'Voucher with type %1 and reference no. %2 is fully used.', Comment = '%1 - voucher type, %2 - reference no.';
        NotValidVoucherErrorLbl: Label 'Voucher with type %1 and reference no. %2 is not valid yet.', Comment = '%1 - voucher type, %2 - reference no.';
        ExpiredValidVoucherErrorLbl: Label 'Voucher with type %1 and reference no. %2 has expired.', Comment = '%1 - voucher type, %2 - reference no.';
        TimeStamp: DateTime;
    begin
        if not Voucher."Allow Top-up" then begin
            Voucher.CalcFields(Open);
            if not Voucher.Open then
                Error(VoucherFullyUsedErrorLbl, Voucher."Voucher Type", Voucher."Reference No.");
        end;

        Timestamp := CurrentDateTime;
        if Voucher."Starting Date" > Timestamp then
            Error(NotValidVoucherErrorLbl, Voucher."Voucher Type", Voucher."Reference No.");

        if (Voucher."Ending Date" < Timestamp) and (Voucher."Ending Date" <> 0DT) then
            Error(ExpiredValidVoucherErrorLbl, Voucher."Voucher Type", Voucher."Reference No.");
    end;

    internal procedure CalculateVirtualItemsDocStatus(EcomSalesHeader: Record "NPR Ecom Sales Header") VirtualItemsDocStatus: Enum "NPR EcomVirtualItemDocStatus";
    var
        HasError: Boolean;
        AllProcessed: Boolean;
    begin
        HasError :=
            (EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::Error) or
            (EcomSalesHeader."Ticket Processing Status" = EcomSalesHeader."Ticket Processing Status"::Error) or
            (EcomSalesHeader."Membership Processing Status" = EcomSalesHeader."Membership Processing Status"::Error) or
            (EcomSalesHeader."Coupon Processing Status" = EcomSalesHeader."Coupon Processing Status"::Error) or
            (EcomSalesHeader."Attr. Wallet Processing Status" = EcomSalesHeader."Attr. Wallet Processing Status"::Error);

        if HasError then begin
            VirtualItemsDocStatus := VirtualItemsDocStatus::Error;
            exit;
        end;

        // Partially Processed logic:
        // - Tickets can never be partially processed on their own; they are either processed or not processed
        // - Vouchers, coupons, memberships and wallets can be partially processed
        // - The document is partially processed if any voucher, coupon, membership or wallet is explicitly partially processed,
        //   or if existing virtual item types are in a mixed processed/not-processed state
        if IsPartiallyProcessed(EcomSalesHeader, AllProcessed) then begin
            VirtualItemsDocStatus := VirtualItemsDocStatus::"Partially Processed";
            exit;
        end;

        if AllProcessed and (EcomSalesHeader."Vouchers Exist" or EcomSalesHeader."Tickets Exist" or EcomSalesHeader."Memberships Exist" or EcomSalesHeader."Coupons Exist" or EcomSalesHeader."Attraction Wallets Exist") then begin
            VirtualItemsDocStatus := VirtualItemsDocStatus::Processed;
            exit;
        end;

        // Default to Pending
        VirtualItemsDocStatus := VirtualItemsDocStatus::Pending;
    end;

    local procedure IsPartiallyProcessed(EcomSalesHeader: Record "NPR Ecom Sales Header"; var AllProcessed: Boolean): Boolean
    var
        AnyExists: Boolean;
        CouponProcessed: Boolean;
        MembershipProcessed: Boolean;
        NoneProcessed: Boolean;
        TicketProcessed: Boolean;
        VoucherProcessed: Boolean;
        WalletProcessed: Boolean;
    begin
        if (EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::"Partially Processed") or
           (EcomSalesHeader."Membership Processing Status" = EcomSalesHeader."Membership Processing Status"::"Partially Processed") or
           (EcomSalesHeader."Coupon Processing Status" = EcomSalesHeader."Coupon Processing Status"::"Partially Processed") or
           (EcomSalesHeader."Attr. Wallet Processing Status" = EcomSalesHeader."Attr. Wallet Processing Status"::"Partially Processed")
        then
            exit(true);

        VoucherProcessed := (not EcomSalesHeader."Vouchers Exist") or (EcomSalesHeader."Voucher Processing Status" = EcomSalesHeader."Voucher Processing Status"::Processed);
        TicketProcessed := (not EcomSalesHeader."Tickets Exist") or (EcomSalesHeader."Ticket Processing Status" = EcomSalesHeader."Ticket Processing Status"::Processed);
        MembershipProcessed := (not EcomSalesHeader."Memberships Exist") or (EcomSalesHeader."Membership Processing Status" = EcomSalesHeader."Membership Processing Status"::Processed);
        CouponProcessed := (not EcomSalesHeader."Coupons Exist") or (EcomSalesHeader."Coupon Processing Status" = EcomSalesHeader."Coupon Processing Status"::Processed);
        WalletProcessed := (not EcomSalesHeader."Attraction Wallets Exist") or (EcomSalesHeader."Attr. Wallet Processing Status" = EcomSalesHeader."Attr. Wallet Processing Status"::Processed);

        AnyExists := EcomSalesHeader."Vouchers Exist" or EcomSalesHeader."Tickets Exist" or EcomSalesHeader."Memberships Exist" or EcomSalesHeader."Coupons Exist" or EcomSalesHeader."Attraction Wallets Exist";

        AllProcessed := VoucherProcessed and TicketProcessed and MembershipProcessed and CouponProcessed and WalletProcessed;

        NoneProcessed :=
            ((not EcomSalesHeader."Vouchers Exist") or (not VoucherProcessed)) and
            ((not EcomSalesHeader."Tickets Exist") or (not TicketProcessed)) and
            ((not EcomSalesHeader."Memberships Exist") or (not MembershipProcessed)) and
            ((not EcomSalesHeader."Coupons Exist") or (not CouponProcessed)) and
            ((not EcomSalesHeader."Attraction Wallets Exist") or (not WalletProcessed));

        exit(AnyExists and not AllProcessed and not NoneProcessed);
    end;

    internal procedure IsTicketLine(Item: Record Item): Boolean
    begin
        exit(Item."NPR Ticket Type" <> '');
    end;

    internal procedure IsMembershipLine(ItemNo: Code[20]): Boolean
    var
        MMMembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        if EcomCreateMMShipImpl.GetMembershipSaleSetup(MMMembershipSalesSetup, ItemNo) then
            exit(true);
        //do we need different logic for these
        if HasMembershipAlterationSetup(ItemNo) then
            exit(true);
        exit(false);
    end;

    internal procedure HasMembershipAlterationSetup(ItemNo: Code[20]): Boolean
    var
        MMMembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        MMMembershipAlterationSetup.SetRange("Sales Item No.", ItemNo);
        exit(not MMMembershipAlterationSetup.IsEmpty());
    end;

    internal procedure IsCouponItem(EcomSalesLine: Record "NPR Ecom Sales Line"; CheckCouponTypes: Boolean): Boolean
    var
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        exit(EcomCreateCouponImpl.IsCouponItem(EcomSalesLine, CheckCouponTypes));
    end;

    internal procedure EmitError(ErrorTxt: text; EventId: text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_ErrorText', ErrorTxt);
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_CallStack', GetLastErrorCallStack());

        Session.LogMessage(EventId, ErrorTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    internal procedure SetVirtualItemSubtypeFilter(var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        EcomSalesLine.SetFilter(Subtype, '%1|%2|%3|%4', EcomSalesLine.Subtype::Ticket, EcomSalesLine.Subtype::Voucher, EcomSalesLine.SubType::Membership, EcomSalesLine.Subtype::Coupon);
    end;
}
#endif