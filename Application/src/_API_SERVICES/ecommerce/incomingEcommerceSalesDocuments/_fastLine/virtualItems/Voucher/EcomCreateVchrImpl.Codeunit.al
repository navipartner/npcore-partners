#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248510 "NPR EcomCreateVchrImpl"
{
    Access = Internal;

    internal procedure Process(var EcommSalesLine: Record "NPR Ecom Sales Line"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.Get(EcommSalesLine."Document Entry No.");
        IsShopifyDocument := SpfyEcomSalesDocPrcssr.IsShopifyDocument(EcomSalesHeader);
        //lock table
        EcommSalesLine.ReadIsolation := EcommSalesLine.ReadIsolation::UpdLock;
        EcommSalesLine.Get(EcommSalesLine.RecordId);
        CheckIfLineCanBeProcessed(EcommSalesLine, EcomSalesHeader);
        CreateVoucher(EcommSalesLine, EcomSalesHeader);

        EcomVirtualItemEvents.OnAfterVoucherProcessBeforeCommit(EcommSalesLine);
        exit(true);
    end;

    internal procedure CheckIfLineCanBeProcessed(EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            EcomSalesHeader.FieldError("Creation Status");

        if EcommSalesLine.Type <> EcommSalesLine.Type::Voucher then
            EcommSalesLine.FieldError(Type);

        if not EcommSalesLine.Captured then
            EcommSalesLine.FieldError(Captured);

        if EcommSalesLine.Quantity <> Round(EcommSalesLine.Quantity, 1) then
            EcommSalesLine.FieldError(Quantity);

        if EcommSalesLine.Quantity < 1 then
            EcommSalesLine.FieldError(Quantity);

        if (EcommSalesLine."Barcode No." <> '') and (EcommSalesLine.Quantity <> 1) then
            EcommSalesLine.FieldError(Quantity);

        if (EcommSalesLine."Unit Price" = 0) then
            EcommSalesLine.FieldError("Unit Price");

        if EcommSalesLine."Document Type" = EcommSalesLine."Document Type"::"Return Order" then
            EcommSalesLine.FieldError("Document Type");

        if EcommSalesLine."Virtual Item Process Status" = EcommSalesLine."Virtual Item Process Status"::Processed then
            EcommSalesLine.FieldError(EcommSalesLine."Virtual Item Process Status");

        EcomSalesDocUtils.ErrorIfFCYDocument(EcomSalesHeader."Currency Code");
    end;

    local procedure CreateVoucher(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        QtyToIssue: Integer;
        AlreadyLinked: Integer;
        i: Integer;
        IssuedVoucher: Record "NPR NpRv Voucher";
        FirstVoucherNoOfLine: Code[20];
        FirstVoucherTypeOfLine: Code[20];
        FirstReferenceNoOfLine: Text[50];
        LinkCountExceedsQtyErr: Label 'Internal data inconsistency on voucher line %1: %2 voucher(s) issued but quantity is %3. Contact support to investigate. This is a programming bug.', Locked = true;
        PartialLinkStateErr: Label 'Internal data inconsistency on voucher line %1: %2 of %3 voucher(s) issued. Contact support to investigate. This is a programming bug.', Locked = true;
    begin
        QtyToIssue := EcomSalesLine.Quantity;
        AlreadyLinked := CountExistingLinks(EcomSalesHeader, EcomSalesLine);

        // Defensive invariant checks. UpdLock on EcomSalesLine prevents concurrent re-entry into
        // CreateVoucher for the same line, but it doesn't protect against a prior attempt that
        // crashed mid-loop (each IssueOrTopUpSingleVoucher commits voucher + link as a unit, so
        // partial state can survive on disk). The > and partial branches surface that as a
        // programming bug instead of silently re-issuing duplicate vouchers.
        case true of
            AlreadyLinked = QtyToIssue:
                exit;  // race recovery — another session already issued these vouchers
            AlreadyLinked > QtyToIssue:
                Error(LinkCountExceedsQtyErr, EcomSalesLine.RecordId(), AlreadyLinked, QtyToIssue);
            (AlreadyLinked > 0) and (AlreadyLinked < QtyToIssue):
                Error(PartialLinkStateErr, EcomSalesLine.RecordId(), AlreadyLinked, QtyToIssue);
        end;

        if EcomSalesLine."Barcode No." <> '' then begin
            IssueOrTopUpSingleVoucher(EcomSalesLine, EcomSalesHeader, EcomSalesLine."Barcode No.", IssuedVoucher);
            EcomSalesLine."No." := IssuedVoucher."No.";
            EcomSalesLine."Voucher Type" := IssuedVoucher."Voucher Type";
            EcomSalesLine.Modify(true);
            exit;
        end;

        for i := 1 to QtyToIssue do begin
            IssueOrTopUpSingleVoucher(EcomSalesLine, EcomSalesHeader, '', IssuedVoucher);
            if i = 1 then begin
                FirstVoucherNoOfLine := IssuedVoucher."No.";
                FirstVoucherTypeOfLine := IssuedVoucher."Voucher Type";
                FirstReferenceNoOfLine := IssuedVoucher."Reference No.";
            end;
        end;

        if QtyToIssue = 1 then begin
            EcomSalesLine."Barcode No." := FirstReferenceNoOfLine;
            EcomSalesLine."No." := FirstVoucherNoOfLine;
            EcomSalesLine."Voucher Type" := FirstVoucherTypeOfLine;
            EcomSalesLine.Modify(true);
        end;
    end;

    local procedure IssueOrTopUpSingleVoucher(EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; BarcodeNoParam: Text[50]; var NpRvVoucherOut: Record "NPR NpRv Voucher")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvGlobalVoucher: Codeunit "NPR NpRv Global Voucher WS";
        VoucherFaceValueLCY: Decimal;
        EffectiveBarcode: Text[50];
    begin
        // Sequencing invariant: InsertVoucherLink (the last call in this procedure) MUST remain
        // the final database operation. The link row is the durable race-recovery marker; any
        // future commit between voucher issuance and link insert would break CreateVoucher's
        // count-based guard. Do not move it.
        VoucherFaceValueLCY := CalculateVoucherFaceValueLCY(EcomSalesHeader, EcomSalesLine);
        EffectiveBarcode := BarcodeNoParam;
        if EffectiveBarcode = '' then
            EffectiveBarcode := ReserveVoucher(EcomSalesLine, EcomSalesHeader, VoucherFaceValueLCY);

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("Reference No.", EffectiveBarcode);
        NpRvSalesLine.SetRange("External Document No.", EcomSalesHeader."External No.");
        NpRvSalesLine.SetFilter(Type, '%1|%2', NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up");
        if not NpRvSalesLine.FindFirst() then begin
            if NpRvGlobalVoucher.FindVoucher('', CopyStr(EffectiveBarcode, 1, 50), NpRvVoucher) then begin
                NpRvVoucher.CalcFields("Issue Date");
                if (NpRvVoucher."Issue Date" <> 0D) then
                    NpRvVoucher.TestField("Allow Top-up");
                NpRvSalesLine.Init();
                NpRvSalesLine.Id := CreateGuid();
                NpRvSalesLine."External Document No." := EcomSalesHeader."External No.";
                NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
                NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
                NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
                NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
                NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
                NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
                NpRvSalesLine.Description := NpRvVoucher.Description;
                NpRvSalesLine.Insert(true);
            end;
        end;
        NpRvSalesLine.FindFirst();
        CheckVoucherLinkedWithSalesDocument(NpRvSalesLine);
        NpRvSalesLine.TestField("Voucher Type");
        UpdateRvSalesLineFromEcomm(NpRvSalesLine, EcomSalesLine, EcomSalesHeader, VoucherFaceValueLCY);
        NpRvSalesLine.UpdateIsSendViaEmail();

        NpRvVoucherType.Get(NpRvSalesLine."Voucher Type");
        if not VoucherAlreadyExist(NpRvSalesLine."Voucher No.") then
            InsertVoucher(NpRvVoucher, NpRvVoucherType, NpRvSalesLine);
        UpdateSalesLineFromVoucher(NpRvVoucher, NpRvSalesLine);

        PostIssueVoucherEntry(NpRvVoucher, NpRvVoucherType, NpRvSalesLine);
        NpRvSalesLine.Posted := true;
        NpRvSalesLine.Modify();

        NpRvSalesLineRef.SetLoadFields(Posted);
        NpRvSalesLineRef.SetCurrentKey("Sales Line Id", Posted);
        NpRvSalesLineRef.SetRange("Sales Line Id", NpRvSalesLine.Id);
        NpRvSalesLineRef.SetRange(Posted, false);
        if NpRvSalesLineRef.FindFirst() then begin
            NpRvSalesLineRef.Posted := true;
            NpRvSalesLineRef.Modify();
        end;

        if NpRvSalesLine."Spfy Gift Card ID" <> '' then
            SpfyEcomSalesDocPrcssr.AssignShopifyIDToVoucher(NpRvVoucher, NpRvSalesLine);

        NpRvVoucherOut := NpRvVoucher;
        InsertVoucherLink(EcomSalesHeader, EcomSalesLine, NpRvVoucher);
    end;

    local procedure ReserveVoucher(EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; VoucherFaceValueLCY: Decimal): text[50]
    var
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        EcommSalesLine.TestField("Voucher Type");
        VoucherType.Get(EcommSalesLine."Voucher Type");
        VoucherMgt.GenerateTempVoucher(VoucherType, TempVoucher);

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        UpdateSalesLineFromVoucher(TempVoucher, NpRvSalesLine);
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
#pragma warning disable AA0139
        NpRvSalesLine."External Document No." := EcomSalesHeader."External No.";
#pragma warning restore AA0139
        NpRvSalesLine.Amount := VoucherFaceValueLCY;
        NpRvSalesLine.Insert();

        NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLine, TempVoucher);

        EcomVirtualItemEvents.OnAfterVoucherReferenceNoReservation(NpRvSalesLine);
        exit(TempVoucher."Reference No.");
    end;


    local procedure UpdateSalesLineFromVoucher(Voucher: Record "NPR NpRv Voucher"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Voucher Type" := Voucher."Voucher Type";
        NpRvSalesLine."Voucher No." := Voucher."No.";
        NpRvSalesLine."Reference No." := Voucher."Reference No.";
        NpRvSalesLine.Description := Voucher.Description;
    end;

    local procedure UpdateRvSalesLineFromEcomm(var NpRvSalesLine: Record "NPR NpRv Sales Line"; EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; VoucherFaceValueLCY: Decimal)
    begin
        NpRvSalesLine.Amount := VoucherFaceValueLCY;
        NpRvSalesLine."NPR Inc Ecom Sales Line Id" := EcommSalesLine.SystemId;
        NpRvSalesLine."Document Type" := EcommSalesLine."Document Type";
        UpdateRvSalesLineFromHeader(NpRvSalesLine, EcomSalesHeader);
    end;

    local procedure UpdateRvSalesLineFromHeader(var NpRvSalesLine: Record "NPR NpRv Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        if NpRvSalesLine."E-mail" = '' then
            NpRvSalesLine."E-mail" := EcomSalesHeader."Sell-to Email";
        if NpRvSalesLine."Phone No." = '' then
            NpRvSalesLine."Phone No." := EcomSalesHeader."Sell-to Phone No.";
        if NpRvSalesLine."External Document No." = '' then
            NpRvSalesLine."External Document No." := EcomSalesHeader."External No.";
    end;

    local procedure CheckVoucherLinkedWithSalesDocument(var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        ErrLbl: Label 'Voucher is already Linked with Sales Document type %1 and no %2 .', Comment = '%1=NpRvSalesLine."Document Type";%2=NpRvSalesLine."Document No."', Locked = true;
    begin
        if (NpRvSalesLine."Document No." <> '') then
            Error(ErrLbl, NpRvSalesLine."Document Type", NpRvSalesLine."Document No.");
    end;

    local procedure InsertVoucher(var NpRvVoucher: Record "NPR NpRv Voucher"; NpRvVoucherType: Record "NPR NpRv Voucher Type"; NpRvSalesLine: Record "NPR NpRv Sales Line");
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        SpfySuspendVouchRefVal: Codeunit "NPR Spfy Suspend Vouch.Ref.Val";
    begin
        if IsShopifyDocument then
            BindSubscription(SpfySuspendVouchRefVal);
        NpRvVoucherMgt.InitVoucher(NpRvVoucherType, NpRvSalesLine."Voucher No.", NpRvSalesLine."Reference No.", 0DT, true, NpRvVoucher);
        if IsShopifyDocument then
            UnbindSubscription(SpfySuspendVouchRefVal);
        NpRvSalesLineToVoucher(NpRvVoucher, NpRvSalesLine);
        NpRvVoucher.Modify();
    end;

    local procedure NpRvSalesLineToVoucher(var NpRvVoucher: Record "NPR NpRv Voucher"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        NpRvVoucher.Name := NpRvSalesLine.Name;
        NpRvVoucher."Name 2" := NpRvSalesLine."Name 2";
        NpRvVoucher.Address := NpRvSalesLine.Address;
        NpRvVoucher."Address 2" := NpRvSalesLine."Address 2";
        NpRvVoucher."Post Code" := NpRvSalesLine."Post Code";
        NpRvVoucher.City := NpRvSalesLine.City;
        NpRvVoucher.County := NpRvSalesLine.County;
        NpRvVoucher."Country/Region Code" := NpRvSalesLine."Country/Region Code";
        NpRvVoucher."E-mail" := NpRvSalesLine."E-mail";
        NpRvVoucher."Phone No." := NpRvSalesLine."Phone No.";
        NpRvVoucher."Voucher Message" := NpRvSalesLine."Voucher Message";
        NpRvVoucher."Send via Print" := NpRvSalesLine."Send via Print";
        NpRvVoucher."Send via E-mail" := NpRvSalesLine."Send via E-mail";
        NpRvVoucher."Send via SMS" := NpRvSalesLine."Send via SMS";
#if not BC17
        NpRvVoucher."Spfy Send from Shopify" := NpRvSalesLine."Spfy Send from Shopify";
        NpRvVoucher."Spfy Send on" := NpRvSalesLine."Spfy Send on";
        NpRvVoucher."Spfy Liquid Template Suffix" := NpRvSalesLine."Spfy Liquid Template Suffix";
        NpRvVoucher."Spfy Recipient Name" := NpRvSalesLine."Spfy Recipient Name";
        NpRvVoucher."Spfy Recipient E-mail" := NpRvSalesLine."Spfy Recipient E-mail";
#endif
    end;

    local procedure PostIssueVoucherEntry(Voucher: Record "NPR NpRv Voucher"; VoucherType: Record "NPR NpRv Voucher Type"; NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Issue Voucher";
        if NpRvSalesLine.Type = NpRvSalesLine.Type::"Top-up" then
            if VoucherMgt.InitialEntryExists(Voucher) then
                VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
        VoucherEntry."External Document No." := NpRvSalesLine."External Document No.";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry.Amount := NpRvSalesLine.Amount;
        VoucherEntry."Remaining Amount" := VoucherEntry.Amount;
        VoucherEntry.Positive := VoucherEntry.Amount > 0;
        VoucherEntry."Posting Date" := DT2Date(Voucher."Starting Date");
        VoucherEntry.Open := VoucherEntry.Amount <> 0;
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
        VoucherEntry."Partner Code" := VoucherType."Partner Code";
        VoucherEntry."User ID" := CopyStr(UserId, 1, MaxStrLen(VoucherEntry."User ID"));
        VoucherEntry."Closed by Entry No." := 0;
        VoucherEntry.Company := CopyStr(CompanyName(), 1, MaxStrLen(VoucherEntry.Company));
        if NpRvSalesLine."Sale Date" = 0D then
            NpRvSalesLine."Sale Date" := WorkDate();
        VoucherEntry."Posting Date" := NpRvSalesLine."Sale Date";
#if not BC17
        VoucherEntry."Spfy Initiated in Shopify" := NpRvSalesLine."Spfy Initiated in Shopify";
#endif
        VoucherEntry.Insert();
    end;

    local procedure CalculateVoucherFaceValueLCY(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: record "NPR Ecom Sales Line"): Decimal
    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        FaceValueTCY: Decimal;
        Precalculated: Boolean;
    begin
        if EcomSalesHeader."Price Excl. VAT" and (EcomSalesLine."VAT %" > 0) then
            FaceValueTCY := EcomSalesLine."Unit Price" * (1 + EcomSalesLine."VAT %" / 100)
        else
            FaceValueTCY := EcomSalesLine."Unit Price";

        if NpRvSalesDocMgt.IsLCY(EcomSalesHeader."Currency Code") then begin
            Currency.InitRoundingPrecision();
            exit(Round(FaceValueTCY, Currency."Amount Rounding Precision"));
        end;

        if EcomSalesHeader."Received Date" = 0D then
            EcomSalesHeader."Received Date" := WorkDate();
        if (EcomSalesHeader."Currency Code" <> '') and (EcomSalesHeader."Currency Exchange Rate" = 0) then
            EcomSalesHeader."Currency Exchange Rate" := CurrExchRate.ExchangeRate(EcomSalesHeader."Received Date", EcomSalesHeader."Currency Code");
        exit(
            NpRvSalesDocMgt.ConvertTransactionCurrencyAmtToLCY(
                FaceValueTCY, EcomSalesHeader."Currency Code", EcomSalesHeader."Currency Exchange Rate", EcomSalesHeader."Received Date", Precalculated));
    end;

    local procedure VoucherAlreadyExist(VoucherNo: Code[20]): Boolean
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        if not NpRvVoucher.Get(VoucherNo) then
            exit;
        NpRvVoucher.CalcFields("Issue Date");
        if (NpRvVoucher."Issue Date" <> 0D) then
            NpRvVoucher.TestField("Allow Top-up");
        exit(true);
    end;

    local procedure CountExistingLinks(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"): Integer
    var
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    begin
        EcomSalesVoucherLink.SetCurrentKey("Source System Id", "Source Line System Id");
        EcomSalesVoucherLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        EcomSalesVoucherLink.SetRange("Source Line System Id", EcomSalesLine.SystemId);
        exit(EcomSalesVoucherLink.Count());
    end;

    local procedure InsertVoucherLink(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; NpRvVoucher: Record "NPR NpRv Voucher")
    var
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    begin
        EcomSalesVoucherLink.Init();
        EcomSalesVoucherLink."Source System Id" := EcomSalesHeader.SystemId;
        EcomSalesVoucherLink."Source Line System Id" := EcomSalesLine.SystemId;
        EcomSalesVoucherLink."Voucher System Id" := NpRvVoucher.SystemId;
        EcomSalesVoucherLink."Voucher No." := NpRvVoucher."No.";
        EcomSalesVoucherLink."Reference No." := NpRvVoucher."Reference No.";
        EcomSalesVoucherLink."Voucher Type" := NpRvVoucher."Voucher Type";
        EcomSalesVoucherLink."Voucher State" := EcomSalesVoucherLink."Voucher State"::Active;
        EcomSalesVoucherLink.Insert(true);
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    internal procedure UpdateVoucherEntryPostingInformationSalesInvoice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SalesInvLine: Record "Sales Invoice Line")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        if not EcomSalesLine.GetBySystemId(SalesLine."NPR Inc Ecom Sales Line Id") then
            exit;
        if not SalesHeader.Invoice then
            exit;

        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("NPR Inc Ecom Sales Line Id", SalesLine."NPR Inc Ecom Sales Line Id");
        NpRvSalesLine.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpRvSalesLine.SetRange(Posted, true);
        if not NpRvSalesLine.FindSet() then
            exit;

        NpRvVoucherEntry.SetCurrentKey("Voucher No.", "Entry Type", "Partner Code");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2', NpRvVoucherEntry."Entry Type"::"Issue Voucher", NpRvVoucherEntry."Entry Type"::"Top-up");
        NpRvVoucherEntry.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpRvVoucherEntry.SetRange("Document No.", '');
        NpRvVoucherEntry.SetLoadFields("Document No.", "Document Line No.");
        repeat
            NpRvVoucherEntry.SetRange("Voucher No.", NpRvSalesLine."Voucher No.");
            NpRvVoucherEntry.SetRange("Voucher Type", NpRvSalesLine."Voucher Type");
            if NpRvVoucherEntry.FindFirst() then begin
                NpRvVoucherEntry."Document No." := SalesInvLine."Document No.";
                NpRvVoucherEntry."Document Line No." := SalesInvLine."Line No.";
                NpRvVoucherEntry.Modify();
            end;
        until NpRvSalesLine.Next() = 0;
    end;
#endif

    internal procedure ShowRelatedVouchersAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        TempVoucher: Record "NPR NpRv Voucher" temporary;
    begin
        BuildVoucherTempBufferForDoc(EcomSalesHeader, TempVoucher);
        if not TempVoucher.IsEmpty() then
            Page.RunModal(Page::"NPR Ecom Voucher Lookup", TempVoucher);
    end;

    internal procedure ShowRelatedVouchersAction(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        NoVoucherFoundMsg: Label 'No retail vouchers are linked to this line in the system.';
    begin
        if not EcomSalesHeader.Get(EcomSalesLine."Document Entry No.") then
            exit;
        BuildVoucherTempBufferForLine(EcomSalesHeader, EcomSalesLine, TempVoucher);
        case TempVoucher.Count() of
            0:
                Message(NoVoucherFoundMsg);
            1:
                begin
                    TempVoucher.FindFirst();
                    OpenVoucherCardForSystemId(TempVoucher.SystemId);
                end;
            else
                Page.RunModal(Page::"NPR Ecom Voucher Lookup", TempVoucher);
        end;
    end;

    internal procedure BuildVoucherTempBufferForDoc(EcomSalesHeader: Record "NPR Ecom Sales Header"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
    var
        EmptyGuid: Guid;
    begin
        BuildVoucherTempBuffer(EcomSalesHeader, EmptyGuid, TempVoucher);
    end;

    internal procedure BuildVoucherTempBufferForLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
    begin
        BuildVoucherTempBuffer(EcomSalesHeader, EcomSalesLine.SystemId, TempVoucher);
    end;

    local procedure BuildVoucherTempBuffer(EcomSalesHeader: Record "NPR Ecom Sales Header"; SourceLineSystemIdFilter: Guid; var TempVoucher: Record "NPR NpRv Voucher" temporary)
    var
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
    begin
        EcomSalesVoucherLink.SetCurrentKey("Source System Id", "Source Line System Id");
        EcomSalesVoucherLink.SetRange("Source System Id", EcomSalesHeader.SystemId);
        if not IsNullGuid(SourceLineSystemIdFilter) then
            EcomSalesVoucherLink.SetRange("Source Line System Id", SourceLineSystemIdFilter);

        if EcomSalesVoucherLink.FindSet() then begin
            repeat
                case EcomSalesVoucherLink."Voucher State" of
                    EcomSalesVoucherLink."Voucher State"::Active:
                        if NpRvVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id") then begin
                            TempVoucher := NpRvVoucher;
                            if TempVoucher.Insert() then;
                        end;
                    EcomSalesVoucherLink."Voucher State"::Archived:
                        if NpRvArchVoucher.GetBySystemId(EcomSalesVoucherLink."Voucher System Id") then
                            InsertArchivedAsTempVoucher(NpRvArchVoucher, TempVoucher);
                end;
            until EcomSalesVoucherLink.Next() = 0;
            exit;
        end;

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::Voucher);
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::Processed);
        if not IsNullGuid(SourceLineSystemIdFilter) then
            EcomSalesLine.SetRange(SystemId, SourceLineSystemIdFilter);
        if EcomSalesLine.FindSet() then
            repeat
                if EcomSalesLine."No." <> '' then
                    if NpRvVoucher.Get(EcomSalesLine."No.") then begin
                        TempVoucher := NpRvVoucher;
                        if TempVoucher.Insert() then;
                    end else begin
                        NpRvArchVoucher.SetCurrentKey("Arch. No.");
                        NpRvArchVoucher.SetRange("Arch. No.", EcomSalesLine."No.");
                        if NpRvArchVoucher.FindFirst() then
                            InsertArchivedAsTempVoucher(NpRvArchVoucher, TempVoucher);
                    end;
            until EcomSalesLine.Next() = 0;
    end;

    local procedure InsertArchivedAsTempVoucher(NpRvArchVoucher: Record "NPR NpRv Arch. Voucher"; var TempVoucher: Record "NPR NpRv Voucher" temporary)
    var
        OriginalNo: Code[20];
    begin
        TempVoucher.Init();
        TempVoucher.TransferFields(NpRvArchVoucher);
        OriginalNo := NpRvArchVoucher."Arch. No.";
        if OriginalNo = '' then
            OriginalNo := NpRvArchVoucher."No.";
        TempVoucher."No." := OriginalNo;
        TempVoucher.Description := CopyStr(BuildArchivedDescription(NpRvArchVoucher.Description), 1, MaxStrLen(TempVoucher.Description));
        TempVoucher.SystemId := NpRvArchVoucher.SystemId;
        if TempVoucher.Insert() then;
    end;

    internal procedure BuildArchivedDescription(SourceDescription: Text): Text
    begin
        exit(GetArchivedPrefix() + SourceDescription);
    end;

    internal procedure IsArchivedTempDescription(Description: Text): Boolean
    var
        Prefix: Text;
    begin
        Prefix := GetArchivedPrefix();
        if Prefix = '' then
            exit(false);
        exit(Description.StartsWith(Prefix));
    end;

    local procedure GetArchivedPrefix(): Text
    var
        ArchivedPrefixLbl: Label '[Archived] ';
    begin
        exit(ArchivedPrefixLbl);
    end;

    internal procedure OpenVoucherCardForSystemId(SystemIdParam: Guid)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NotAvailableMsg: Label 'This voucher is no longer available in the system.';
    begin
        if NpRvVoucher.GetBySystemId(SystemIdParam) then begin
            NpRvVoucher.SetRecFilter();
            Page.Run(Page::"NPR NpRv Voucher Card", NpRvVoucher);
            exit;
        end;
        if NpRvArchVoucher.GetBySystemId(SystemIdParam) then begin
            NpRvArchVoucher.SetRecFilter();
            Page.Run(Page::"NPR NpRv Arch. Voucher Card", NpRvArchVoucher);
            exit;
        end;
        Message(NotAvailableMsg);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesLine, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesLine"(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var SalesInvLine: Record "Sales Invoice Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var xSalesLine: Record "Sales Line")
    begin
        if SalesHeader.Invoice then
            UpdateVoucherEntryPostingInformationSalesInvoice(SalesHeader, SalesLine, SalesInvLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", OnAfterArchiveVoucher, '', false, false)]
    local procedure OnAfterArchiveVoucher_FlipLinkState(Voucher: Record "NPR NpRv Voucher"; ArchVoucher: Record "NPR NpRv Arch. Voucher")
    var
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    begin
        EcomSalesVoucherLink.SetCurrentKey("Voucher System Id", "Voucher State");
        EcomSalesVoucherLink.SetRange("Voucher System Id", ArchVoucher.SystemId);
        EcomSalesVoucherLink.SetRange("Voucher State", EcomSalesVoucherLink."Voucher State"::Active);
        EcomSalesVoucherLink.ModifyAll("Voucher State", EcomSalesVoucherLink."Voucher State"::Archived);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Voucher Mgt.", OnAfterUnArchiveVoucher, '', false, false)]
    local procedure OnAfterUnArchiveVoucher_FlipLinkState(ArchVoucher: Record "NPR NpRv Arch. Voucher"; Voucher: Record "NPR NpRv Voucher")
    var
        EcomSalesVoucherLink: Record "NPR Ecom Sales Voucher Link";
    begin
        EcomSalesVoucherLink.SetCurrentKey("Voucher System Id", "Voucher State");
        EcomSalesVoucherLink.SetRange("Voucher System Id", Voucher.SystemId);
        EcomSalesVoucherLink.SetRange("Voucher State", EcomSalesVoucherLink."Voucher State"::Archived);
        EcomSalesVoucherLink.ModifyAll("Voucher State", EcomSalesVoucherLink."Voucher State"::Active);
    end;

    var
        EcomVirtualItemEvents: codeunit "NPR EcomVirtualItemEvents";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        IsShopifyDocument: Boolean;
}
#endif
