#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248510 "NPR EcomCreateVchrImpl"
{
    Access = Internal;

    internal procedure Process(var EcommSalesLine: Record "NPR Ecom Sales Line"): Boolean
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.SetLoadFields("Creation Status");
        EcomSalesHeader.Get(EcommSalesLine."Document Entry No.");

        //lock table
        EcommSalesLine.ReadIsolation := EcommSalesLine.ReadIsolation::UpdLock;
        EcommSalesLine.Get(EcommSalesLine.RecordId);
        CheckIfLineCanBeProcessed(EcommSalesLine, EcomSalesHeader);
        CreateVoucher(EcommSalesLine);

        EcomVirtualItemEvents.OnAfterVoucherProcessBeforeCommit(EcommSalesLine);
        exit(true);
    end;

    internal procedure CheckIfLineCanBeProcessed(EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader.SetLoadFields("Creation Status");
        EcomSalesHeader.Get(EcommSalesLine."Document Entry No.");


        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            EcomSalesHeader.FieldError("Creation Status");

        if EcommSalesLine.Type <> EcommSalesLine.Type::Voucher then
            EcommSalesLine.FieldError(Type);

        if not EcommSalesLine.Captured then
            EcommSalesLine.FieldError(Captured);

        if (EcommSalesLine.Quantity = 0) then
            EcommSalesLine.FieldError(Quantity);

        if (EcommSalesLine."Unit Price" = 0) then
            EcommSalesLine.FieldError("Unit Price");

        if EcommSalesLine."Document Type" = EcommSalesLine."Document Type"::"Return Order" then
            EcommSalesLine.FieldError("Document Type");

        if EcommSalesLine."Virtual Item Process Status" = EcommSalesLine."Virtual Item Process Status"::Processed then
            EcommSalesLine.FieldError(EcommSalesLine."Virtual Item Process Status");
    end;

    local procedure ReserveVoucher(EcommSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"): text[50]
    var
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        TempVoucher: Record "NPR NpRv Voucher" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
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
        NpRvSalesLine.Amount := EcommSalesLine."Line Amount";
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

    local procedure UpdateRvSalesLineFromEcomm(var NpRvSalesLine: Record "NPR NpRv Sales Line"; EcommSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        NpRvSalesLine.Amount := EcommSalesLine."Line Amount";
        NpRvSalesLine."NPR Inc Ecom Sales Line Id" := EcommSalesLine.SystemId;
        NpRvSalesLine."Document Type" := EcommSalesLine."Document Type";
        EcomSalesHeader.Get(EcommSalesLine."Document Entry No.");
        UpdateRvSalesLineFromHeader(NpRvSalesLine, EcomSalesHeader);
    end;

    local procedure UpdateRvSalesLineFromHeader(var NpRvSalesLine: Record "NPR NpRv Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        // EcomSalesHeader."Sell-to Invoice Email"?
        if NpRvSalesLine."E-mail" = '' then
            NpRvSalesLine."E-mail" := EcomSalesHeader."Sell-to Email";
        if NpRvSalesLine."Phone No." = '' then
            NpRvSalesLine."Phone No." := EcomSalesHeader."Sell-to Phone No.";
        if NpRvSalesLine."External Document No." = '' then
            NpRvSalesLine."External Document No." := EcomSalesHeader."External No.";
    end;

    local procedure CreateVoucher(var EcommSalesLine: Record "NPR Ecom Sales Line")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
        NpRvGlobalVoucher: Codeunit "NPR NpRv Global Voucher WS";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.Get(EcommSalesLine."Document Entry No.");
        IF EcommSalesLine."Barcode No." = '' then
            EcommSalesLine."Barcode No." := ReserveVoucher(EcommSalesLine, EcomSalesHeader);

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("Reference No.", EcommSalesLine."Barcode No.");
        NpRvSalesLine.SetRange("External Document No.", EcomSalesHeader."External No.");
        NpRvSalesLine.SetFilter(Type, '%1|%2', NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up");
        if not NpRvSalesLine.FindFirst() then begin
            if NpRvGlobalVoucher.FindVoucher('', CopyStr(EcommSalesLine."Barcode No.", 1, 50), NpRvVoucher) then begin
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
        UpdateRvSalesLineFromEcomm(NpRvSalesLine, EcommSalesLine);
        NpRvSalesLine.UpdateIsSendViaEmail();

        NpRvVoucherType.Get(NpRvSalesLine."Voucher Type");
        if not VoucherAlreadyExist(NpRvSalesLine."Voucher No.") then
            InsertVoucher(NpRvVoucher, NpRvVoucherType, NpRvSalesLine);
        UpdateSalesLineFromVoucher(NpRvVoucher, NpRvSalesLine);

        PostIssueVoucherEntry(NpRvVoucher, EcommSalesLine, NpRvVoucherType, NpRvSalesLine);
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

        EcommSalesLine."No." := NpRvVoucher."No.";
        EcommSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        EcommSalesLine.Modify(true);
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
    begin
        NpRvVoucherMgt.InitVoucher(NpRvVoucherType, NpRvSalesLine."Voucher No.", NpRvSalesLine."Reference No.", 0DT, true, NpRvVoucher);
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
    end;


    local procedure PostIssueVoucherEntry(Voucher: Record "NPR NpRv Voucher"; IncEcomLines: record "NPR Ecom Sales Line"; VoucherType: Record "NPR NpRv Voucher Type"; NpRvSalesLine: Record "NPR NpRv Sales Line")
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
        VoucherEntry.Amount := IncEcomLines."Line Amount";
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

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    local procedure UpdateVoucherEntryPostingInformationSalesInvoice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var SalesInvLine: Record "Sales Invoice Line")
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
        if not NpRvSalesLine.FindFirst() then
            exit;
        NpRvVoucherEntry.SetCurrentKey("Entry No.", "Voucher No.", "Voucher Type", "External Document No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2', NpRvVoucherEntry."Entry Type"::"Issue Voucher", NpRvVoucherEntry."Entry Type"::"Top-up");
        NpRvVoucherEntry.SetRange("Voucher No.", NpRvSalesLine."Voucher No.");
        NpRvVoucherEntry.SetRange("Voucher Type", NpRvSalesLine."Voucher Type");
        NpRvVoucherEntry.SetRange("External Document No.", SalesHeader."External Document No.");
        NpRvVoucherEntry.SetLoadFields("Document No.", "Document Line No.");
        IF NpRvVoucherEntry.FindFirst() then begin
            //  NpRvVoucherEntry."Posting Date" := NpRvSalesLine."Sale Date";
            NpRvVoucherEntry."Document No." := SalesInvLine."Document No.";
            NpRvVoucherEntry."Document Line No." := SalesInvLine."Line No.";
            NpRvVoucherEntry.Modify();
        end;
    end;
#endif
    internal procedure ShowRelatedVouchersAction(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        TempNpRvVoucher: Record "NPR NpRv Voucher" temporary;
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.Setrange(Type, EcomSalesLine.Type::Voucher);
        EcomSalesLine.SetRange("Virtual Item Process Status", EcomSalesLine."Virtual Item Process Status"::Processed);
        if not EcomSalesLine.FindSet() then
            exit;
        repeat
            Clear(NpRvVoucher);
            if NpRvVoucher.Get(EcomSalesLine."No.") then begin
                TempNpRvVoucher.TransferFields(NpRvVoucher);
                TempNpRvVoucher.Insert();
            end;
        until EcomSalesLine.Next() = 0;
        if not TempNpRvVoucher.IsEmpty() then
            PAGE.Run(0, TempNpRvVoucher);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesLine, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesLine"(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var SalesInvLine: Record "Sales Invoice Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; var xSalesLine: Record "Sales Line")
    begin
        if SalesHeader.Invoice then
            UpdateVoucherEntryPostingInformationSalesInvoice(SalesHeader, SalesLine, SalesInvLine);
    end;

    var
        EcomVirtualItemEvents: codeunit "NPR EcomVirtualItemEvents";
}
#endif