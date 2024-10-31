codeunit 6151024 "NPR NpRv Sales Doc. Mgt."
{
    var
        Text002: Label 'Retail Voucher Payment Amount %1 is higher than Remaining Amount %2 on Retail Voucher %3';
        Text003: Label 'Order Amount %1 is lower than Payment Amount %2.\Issue Return Voucher on remaining amount.';
        Text004: Label 'Voucher %1 issued on new Sales Line';
        Text005: Label 'Voucher Payment Amount %1 exceeds Voucher Amount %2';
        Text006: Label 'Voucher %1 is already in use';
        VoucherNotFoundErr: Label 'A voucher with reference no. "%1" could not be found', Comment = '%1 = Retail voucher number';
        VoucherInUseErr: Label 'The voucher is already in use.';

    internal procedure SelectVoucherType(var NpRvVoucherType: Record "NPR NpRv Voucher Type"): Boolean
    var
        TempNpRvVoucherType: Record "NPR NpRv Voucher Type" temporary;
    begin
        Clear(NpRvVoucherType);
        FindVoucherTypes(TempNpRvVoucherType);
        if TempNpRvVoucherType.FindLast() then begin
            NpRvVoucherType.Get(TempNpRvVoucherType.Code);
            TempNpRvVoucherType.FindFirst();
            if NpRvVoucherType.Code = TempNpRvVoucherType.Code then
                exit(true);
        end;
        if PAGE.RunModal(0, TempNpRvVoucherType) <> ACTION::LookupOK then
            exit(false);

        exit(NpRvVoucherType.Get(TempNpRvVoucherType.Code));
    end;

    internal procedure IssueVoucher(SalesHeader: Record "Sales Header"; NpRvVoucherType: Record "NPR NpRv Voucher Type") VoucherNo: Text
    var
        SalesLine: Record "Sales Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        TempNpRvVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        ReferenceNumber: Code[50];
    begin
        InputVoucherReferenceNumber(NpRvVoucherType, ReferenceNumber);

        NpRvVoucherMgt.GenerateTempVoucher(NpRvVoucherType, TempNpRvVoucher);

        if ReferenceNumber <> '' then begin
            TempNpRvVoucher."Reference No." := ReferenceNumber;
            TempNpRvVoucher.Description := CopyStr(TempNpRvVoucher."Reference No." + ' ' + NpRvVoucherType.Description, 1, MaxStrLen(NpRvVoucherType.Description));
        end;

        OnAfterGenerateTempVoucher(NpRvVoucherType, TempNpRvVoucher);

        InsertSalesLine(SalesHeader, SalesLine, TempNpRvVoucher);

        InsertNpRvSalesLine(SalesHeader, SalesLine, NpRvSalesLine, TempNpRvVoucher);
        InsertNpRVSalesLineReference(NpRvSalesLine, TempNpRvVoucher);

        exit(TempNpRvVoucher."No.");
    end;

    procedure InsertPayment(Element: XmlElement; var SalesHeader: Record "Sales Header"; var NpRvVoucher: Record "NPR NpRv Voucher"; Amount: Decimal): Boolean
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        LineNo: Integer;
    begin
        NpRvVoucher.CalcFields(Amount);
        if NpRvVoucher.Amount < Amount then
            Error(Text005, Amount, NpRvVoucher.Amount);

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
        NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if not NpRvSalesLine.FindFirst() then begin
            if NpRvVoucher.CalcInUseQty() > 0 then
                Error(Text006, NpRvVoucher."Reference No.");

            NpRvSalesLine.Init();
            NpRvSalesLine.Id := CreateGuid();
            NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
            NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
            NpRvSalesLine."Document Type" := SalesHeader."Document Type";
            NpRvSalesLine."Document No." := SalesHeader."No.";
            NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
            NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
            NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
            NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
            NpRvSalesLine.Description := NpRvVoucher.Description;
            NpRvSalesLine.Insert(true);
        end;

        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        MagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
        if MagentoPaymentLine.FindLast() then;
        LineNo := MagentoPaymentLine."Line No." + 10000;

        Clear(MagentoPaymentLine);
        MagentoPaymentLine.Init();
        MagentoPaymentLine."Document Table No." := Database::"Sales Header";
        MagentoPaymentLine."Document Type" := SalesHeader."Document Type";
        MagentoPaymentLine."Document No." := SalesHeader."No.";
        MagentoPaymentLine."Line No." := LineNo;
        MagentoPaymentLine."Payment Type" := MagentoPaymentLine."Payment Type"::Voucher;
        MagentoPaymentLine.Description := NpRvVoucher.Description;
        MagentoPaymentLine."Account No." := NpRvVoucher."Account No.";
        MagentoPaymentLine."No." := NpRvVoucher."Reference No.";
        MagentoPaymentLine."Posting Date" := SalesHeader."Posting Date";
        MagentoPaymentLine."Source Table No." := Database::"NPR NpRv Voucher";
        MagentoPaymentLine."Source No." := NpRvVoucher."No.";
        MagentoPaymentLine."External Reference No." := SalesHeader."NPR External Order No.";
        MagentoPaymentLine.Amount := Amount;
        MagentoPaymentLine.Insert(true);

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Type" := SalesHeader."Document Type"::Order;
        NpRvSalesLine."Document No." := SalesHeader."No.";
        NpRvSalesLine."Document Line No." := MagentoPaymentLine."Line No.";
        NpRvSalesLine.Modify(true);

        ApplyPayment(SalesHeader, NpRvSalesLine);
    end;

    procedure ApplyPayment(SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModulePaymentDefault: Codeunit "NPR NpRv Module Pay.: Default";
        Handled: Boolean;
    begin
        NpRvVoucherType.Get(NpRvSalesLine."Voucher Type");
        NpRvModuleMgt.OnRunApplyPaymentSalesDoc(NpRvVoucherType, SalesHeader, NpRvSalesLine, Handled);
        if Handled then
            exit;

        NpRvModulePaymentDefault.ApplyPaymentSalesDoc(NpRvVoucherType, SalesHeader, NpRvSalesLine);
    end;

    local procedure PrepareToReverseVoucherPayments(SalesHeader: Record "Sales Header")
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        PaymentLine: Record "NPR Magento Payment Line";
        TempPaymentLine: Record "NPR Magento Payment Line" temporary;
        NpRvReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        if not SalesHeader.IsCreditDocType() then
            exit;

        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Posted, false);
        if not NpRvSalesLine.IsEmpty() then
            NpRvSalesLine.DeleteAll(true);
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);

        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
        PaymentLine.SetRange(Posted, false);
        if not PaymentLine.FindSet() then
            exit;

        repeat
            if not Voucher.Get(PaymentLine."Source No.") then begin
                if not FindArchivedVoucher(PaymentLine."Source No.", PaymentLine."No.", ArchVoucher) then
                    ArchVoucher.FindLast();  //Show error
                if SalesHeader.Correction and (PaymentLine.Amount <> 0) then begin
                    VoucherMgt.UnarchiveVoucher(ArchVoucher."No.", false);
                    Voucher.Get(ArchVoucher."Arch. No.");
                end else begin
                    Voucher.TransferFields(ArchVoucher);
                    Voucher."No." := ArchVoucher."Arch. No.";
                end;
            end;

            if not SalesHeader.Correction then begin
                if not NpRvReturnVoucherType.Get(Voucher."Voucher Type") then
                    Clear(NpRvReturnVoucherType);
                if NpRvReturnVoucherType."Return Voucher Type" = '' then
                    NpRvReturnVoucherType."Return Voucher Type" := Voucher."Voucher Type";
                Voucher."Voucher Type" := NpRvReturnVoucherType."Return Voucher Type";
            end;

            NpRvSalesLine.SetRange("Voucher Type", Voucher."Voucher Type");
            if not NpRvSalesLine.FindFirst() or SalesHeader.Correction then begin
                NpRvSalesLine.Init();
                NpRvSalesLine.Id := CreateGuid();
                NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
                NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
                NpRvSalesLine."Document Type" := SalesHeader."Document Type";
                NpRvSalesLine."Document No." := SalesHeader."No.";
                NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
                NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
                NpRvSalesLine."Voucher Type" := Voucher."Voucher Type";
                NpRvSalesLine."Voucher No." := Voucher."No.";
                NpRvSalesLine."Reference No." := Voucher."Reference No.";
                NpRvSalesLine.Description := Voucher.Description;
                NpRvSalesLine.Insert(true);

                TempPaymentLine := PaymentLine;
                TempPaymentLine.Insert();
            end else begin
                TempPaymentLine.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", NpRvSalesLine."Document Line No.");
                TempPaymentLine.Amount := TempPaymentLine.Amount + PaymentLine.Amount;
                TempPaymentLine.Modify();

                PaymentLine.Delete(true);
            end;
        until PaymentLine.Next() = 0;

        if TempPaymentLine.FindSet() then
            repeat
                PaymentLine := TempPaymentLine;
                PaymentLine.Find();
                if PaymentLine.Amount <> TempPaymentLine.Amount then begin
                    PaymentLine.Amount := TempPaymentLine.Amount;
                    PaymentLine.Modify();
                end;
            until TempPaymentLine.Next() = 0;

        if SalesHeader.Correction then
            exit;

        NpRvSalesLine.SetRange("Voucher Type");
        if NpRvSalesLine.FindSet() then
            repeat
                InsertVoucherPaymentReturn(SalesHeader, NpRvSalesLine);
            until NpRvSalesLine.Next() = 0;
    end;

    internal procedure InsertVoucherPaymentReturn(SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
        NpRvModulePaymentDefault: Codeunit "NPR NpRv Module Pay.: Default";
        Handled: Boolean;
    begin
        NpRvVoucherType.Get(NpRvSalesLine."Voucher Type");
        NpRvModuleMgt.OnInsertVoucherPaymentReturnSalesDoc(NpRvVoucherType, SalesHeader, NpRvSalesLine, Handled);
        if Handled then
            exit;

        NpRvModulePaymentDefault.InsertVoucherPaymentReturnSalesDoc(NpRvVoucherType, SalesHeader, NpRvSalesLine);
    end;

    local procedure FindArchivedVoucher(VoucherNo: Code[20]; ReferenceNo: Text; var ArchVoucher: Record "NPR NpRv Arch. Voucher"): Boolean
    begin
        ArchVoucher.Reset();
        ArchVoucher.SetCurrentKey("Arch. No.");
        ArchVoucher.SetRange("Arch. No.", VoucherNo);
        if ArchVoucher.IsEmpty() then begin
            ArchVoucher.Reset();
            ArchVoucher.SetCurrentKey("Reference No.");
            ArchVoucher.SetRange("Reference No.", ReferenceNo);
            if ArchVoucher.IsEmpty() then begin
                ArchVoucher.Reset();
                ArchVoucher.SetRange("No.", VoucherNo);
            end;
        end;
        exit(ArchVoucher.FindLast());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Type <> Rec.Type::"G/L Account" then
            exit;

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("Document Type", Rec."Document Type");
        NpRvSalesLine.SetRange("Document No.", Rec."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", Rec."Line No.");
        if NpRvSalesLine.FindFirst() then
            NpRvSalesLine.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Magento Payment Line", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteMagentoPaymentLine(var Rec: Record "NPR Magento Payment Line"; RunTrigger: Boolean)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if Rec.IsTemporary then
            exit;
        if not RunTrigger then
            exit;
        if Rec."Payment Type" <> Rec."Payment Type"::Voucher then
            exit;
        if Rec."Source Table No." <> Database::"NPR NpRv Voucher" then
            exit;

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", Rec."Document Type");
        NpRvSalesLine.SetRange("Document No.", Rec."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", Rec."Line No.");
        if NpRvSalesLine.FindFirst() then
            NpRvSalesLine.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', true, true)]
    local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange(Posted, false);
        if NpRvSalesLine.IsEmpty then
            exit;

        NpRvSalesLine.FindSet();
        repeat
            ApplyPayment(SalesHeader, NpRvSalesLine);
        until NpRvSalesLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', true, false)]
    local procedure CheckVoucherAmounts(var SalesHeader: Record "Sales Header")
    var
        NpRvArchVoucher: Record "NPR NpRv Arch. Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        TotalAmtInclVat: Decimal;
        VoucherQty: Decimal;
        VoucherUnitPrice: Decimal;
        SalesHeaderMagentoPaymentAmount: Decimal;
        AlreadyArchivedErr: Label 'Retail voucher %1 has already been redeemed and archived.\You must cancel all the redeem transactions for the voucher prior to posting this document.', Comment = '%1 = Retail voucher number';
        InsufficientVouchAmtErr: Label 'Retail voucher %1 remaining amount %2 is not sufficient to post the corrective amount %3.', Comment = '%1 = Retail voucher number, %2 = voucher remaining amount, %3 = document amount';
    begin
        if not SalesHeader.Invoice then
            exit;


        if SalesHeader.Correction and SalesHeader.IsCreditDocType() then begin
            //Correction (exact reversing) mode: ensure issued vouchers still have enough amount to write off
            MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
            MagentoPaymentLine.SetRange("Document Type", SalesHeader."Document Type");
            MagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
            MagentoPaymentLine.SetRange("Payment Type", MagentoPaymentLine."Payment Type"::Voucher);
            MagentoPaymentLine.SetRange(Posted, false);
            MagentoPaymentLine.SetFilter(Amount, '<%1', 0);
            if MagentoPaymentLine.FindSet() then begin
                CheckHeader(SalesHeader);
                repeat
                    if not NpRvVoucher.Get(MagentoPaymentLine."Source No.") then begin
                        if FindArchivedVoucher(MagentoPaymentLine."Source No.", MagentoPaymentLine."No.", NpRvArchVoucher) then
                            Error(AlreadyArchivedErr, MagentoPaymentLine."Source No.")
                        else
                            Error(VoucherNotFoundErr, MagentoPaymentLine."Source No.");
                    end;
                    NpRvVoucher.TestField("Reference No.", MagentoPaymentLine."No.");
                    NpRvVoucher.CalcFields(Amount);
                    if NpRvVoucher.Amount < -MagentoPaymentLine.Amount then
                        Error(InsufficientVouchAmtErr, NpRvVoucher."Reference No.", NpRvVoucher.Amount, MagentoPaymentLine.Amount);
                until MagentoPaymentLine.Next() = 0;
            end;
        end;

        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Posted, false);
        if SalesHeader.IsCreditDocType() then begin
            NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
            if NpRvSalesLine.FindSet() then begin
                CheckHeader(SalesHeader);

                repeat
                    if (NpRvSalesLine.Type in [NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up", NpRvSalesLine.Type::"Partner Issue Voucher"]) and
                       (NpRvSalesLine."Voucher No." <> '')
                    then begin

                        if not NpRvVoucher.Get(NpRvSalesLine."Voucher No.") then begin
                            if FindArchivedVoucher(NpRvSalesLine."Voucher No.", NpRvSalesLine."Reference No.", NpRvArchVoucher) then
                                Error(AlreadyArchivedErr, NpRvSalesLine."Voucher No.")
                            else
                                Error(VoucherNotFoundErr, NpRvSalesLine."Voucher No.");
                        end;
                        NpRvVoucher.TestField("Reference No.", NpRvSalesLine."Reference No.");
                        NpRvVoucher.CalcFields(Amount);
                        NpRvVoucherMgt.GetVoucherQtyAndUnitPriceFromSalesLine(NpRvSalesLine, VoucherQty, VoucherUnitPrice);
                        if NpRvVoucher.Amount < VoucherUnitPrice then
                            Error(InsufficientVouchAmtErr, NpRvVoucher."Reference No.", NpRvVoucher.Amount, VoucherUnitPrice);

                    end;
                until NpRvSalesLine.Next() = 0;
            end;
        end;

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        if SalesHeader.IsCreditDocType() then begin
            if not NpRvSalesLine.IsEmpty() then
                NpRvSalesLine.DeleteAll(true);
            exit;
        end;
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if NpRvSalesLine.IsEmpty then
            exit;

        SalesHeader.CalcFields("NPR Magento Payment Amount");
        SalesHeaderMagentoPaymentAmount := SalesHeader."NPR Magento Payment Amount";

        OnBeforeReleaseSalesDoc(SalesHeader);

        if not NpRvSalesLine.FindSet() then
            exit
        else begin
            CheckHeader(SalesHeader);
            repeat
                MagentoPaymentLine.Get(Database::"Sales Header", NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.");
                NpRvVoucher.Get(NpRvSalesLine."Voucher No.");
                NpRvVoucher.TestField("Reference No.", NpRvSalesLine."Reference No.");
                NpRvVoucher.CalcFields(Amount);
                if NpRvVoucher.Amount < MagentoPaymentLine.Amount then
                    Error(Text002, MagentoPaymentLine.Amount, NpRvVoucher.Amount, NpRvVoucher."Reference No.");
            until NpRvSalesLine.Next() = 0;
        end;

        TotalAmtInclVat := GetTotalAmtInclVat(SalesHeader);
        if TotalAmtInclVat < SalesHeaderMagentoPaymentAmount then
            Error(Text003, TotalAmtInclVat, SalesHeaderMagentoPaymentAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostLines', '', true, false)]
    local procedure OnBeforePostCommitSalesDoc(SalesHeader: Record "Sales Header")
    var
        NoSeriesLine: Record "No. Series Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PostingNo: Code[20];
    begin
        if not SalesHeader.Invoice then
            exit;

        if SalesHeader.IsCreditDocType() then
            PrepareToReverseVoucherPayments(SalesHeader);

        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetFilter("Document Source", '%1|%2',
            NpRvSalesLine."Document Source"::"Sales Document", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Posted, false);
        if NpRvSalesLine.IsEmpty then
            exit;

        PostingNo := SalesHeader."Posting No.";
        if PostingNo = '' then begin
            NoSeriesMgt.SetNoSeriesLineFilter(NoSeriesLine, SalesHeader."Posting No. Series", 0D);
            NoSeriesLine.FindLast();
            PostingNo := NoSeriesLine."Last No. Used";
        end;
        NpRvSalesLine.ModifyAll("Posting No.", PostingNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLines', '', true, false)]
    local procedure OnAfterPostSalesLines(var SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if not SalesHeader.Invoice then
            exit;

        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetFilter("Document Source", '%1|%2',
            NpRvSalesLine."Document Source"::"Sales Document", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Posted, false);
        if NpRvSalesLine.IsEmpty then
            exit;

        IssueNewVouchers(SalesHeader);
        if not SalesHeader.IsCreditDocType() or SalesHeader.Correction then
            PostVoucherPayments(SalesHeader);

        NpRvSalesLine.ModifyAll("Posting No.", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if not SalesHeader.Invoice then
            exit;
        if SalesHeader.IsCreditDocType() then begin
            if SalesHeader.Correction then
                exit;
            if not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
                exit;
            NpRvVoucherEntry."Document Type" := NpRvVoucherEntry."Document Type"::"Credit Memo";
            NpRvVoucherEntry."Document No." := SalesCrMemoHeader."No.";
        end else begin
            if not SalesInvHeader.Get(SalesInvHdrNo) then
                exit;
            NpRvVoucherEntry."Document Type" := NpRvVoucherEntry."Document Type"::Invoice;
            NpRvVoucherEntry."Document No." := SalesInvHeader."No.";
        end;

        NpRvVoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.");
        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2|%3',
            NpRvVoucherEntry."Entry Type"::"Issue Voucher", NpRvVoucherEntry."Entry Type"::Payment, NpRvVoucherEntry."Entry Type"::"Top-up");
        NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type");
        NpRvVoucherEntry.SetRange("Document No.", NpRvVoucherEntry."Document No.");
        if not NpRvVoucherEntry.FindSet() then
            exit;

        repeat
            if NpRvVoucher.Get(NpRvVoucherEntry."Voucher No.") then
                SendVoucher(NpRvVoucher);
        until NpRvVoucherEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesLineFromSalesLineBuffer', '', true, false)]
    local procedure OnAfterCopyPostedSalesInvLine(var ToSalesLine: Record "Sales Line"; FromSalesInvLine: Record "Sales Invoice Line"; ToSalesHeader: Record "Sales Header")
    var
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        if not ToSalesHeader.IsCreditDocType() then
            exit;

        VoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.", "Document Line No.");
        VoucherEntry.SetFilter("Entry Type", '%1|%2|%3',
            VoucherEntry."Entry Type"::"Issue Voucher",
            VoucherEntry."Entry Type"::"Partner Issue Voucher",
            VoucherEntry."Entry Type"::"Top-up");
        VoucherEntry.SetRange("Document Type", VoucherEntry."Document Type"::Invoice);
        VoucherEntry.SetRange("Document No.", FromSalesInvLine."Document No.");
        VoucherEntry.SetRange("Document Line No.", FromSalesInvLine."Line No.");
        if VoucherEntry.FindFirst() then begin
            MagentoPaymentLine.Reset();
            MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
            MagentoPaymentLine.SetRange("Document No.", VoucherEntry."Document No.");
            MagentoPaymentLine.SetRange("Line No.", VoucherEntry."Document Line No.");
            if not MagentoPaymentLine.IsEmpty then
                exit;

            Voucher.Get(VoucherEntry."Voucher No.")
        end else begin
            ArchVoucherEntry.SetCurrentKey("Entry Type", "Document Type", "Document No.", "Document Line No.");
            ArchVoucherEntry.SetFilter("Entry Type", '%1|%2|%3',
                ArchVoucherEntry."Entry Type"::"Issue Voucher",
                ArchVoucherEntry."Entry Type"::"Partner Issue Voucher",
                ArchVoucherEntry."Entry Type"::"Top-up");
            ArchVoucherEntry.SetRange("Document Type", ArchVoucherEntry."Document Type"::Invoice);
            ArchVoucherEntry.SetRange("Document No.", FromSalesInvLine."Document No.");
            ArchVoucherEntry.SetRange("Document Line No.", FromSalesInvLine."Line No.");
            if not ArchVoucherEntry.FindFirst() then
                exit;
            VoucherEntry.TransferFields(ArchVoucherEntry);
            ArchVoucher.Get(ArchVoucherEntry."Arch. Voucher No.");
            Voucher.TransferFields(ArchVoucher);
            Voucher."No." := ArchVoucher."Arch. No.";
            if Voucher."No." = '' then
                Voucher."No." := ArchVoucher."No.";
        end;

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."External Document No." := ToSalesHeader."NPR External Order No.";
        NpRvSalesLine."Document Type" := ToSalesLine."Document Type";
        NpRvSalesLine."Document No." := ToSalesLine."Document No.";
        NpRvSalesLine."Document Line No." := ToSalesLine."Line No.";
        case VoucherEntry."Entry Type" of
            VoucherEntry."Entry Type"::"Issue Voucher":
                NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
            VoucherEntry."Entry Type"::"Partner Issue Voucher":
                NpRvSalesLine.Type := NpRvSalesLine.Type::"Partner Issue Voucher";
            VoucherEntry."Entry Type"::"Top-up":
                NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
        end;
        NpRvSalesLine."Voucher Type" := Voucher."Voucher Type";
        NpRvSalesLine."Voucher No." := Voucher."No.";
        NpRvSalesLine."Reference No." := Voucher."Reference No.";
        NpRvSalesLine.Description := Voucher.Description;
        NpRvSalesLine.Insert(true);

        NpRvSalesLineReference.Init();
        NpRvSalesLineReference.Id := CreateGuid();
        NpRvSalesLineReference."Voucher No." := NpRvSalesLine."Voucher No.";
        NpRvSalesLineReference."Reference No." := NpRvSalesLine."Reference No.";
        NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
        NpRvSalesLineReference.Insert(true);
    end;

    local procedure IssueNewVouchers(SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetFilter("Document Source", '%1|%2',
            NpRvSalesLine."Document Source"::"Sales Document", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetFilter(Type, '%1|%2|%3', NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up", NpRvSalesLine.Type::"Partner Issue Voucher");
        NpRvSalesLine.SetRange(Posted, false);
        if NpRvSalesLine.FindSet() then
            repeat
                NpRvVoucherMgt.IssueVouchers(NpRvSalesLine);
            until NpRvSalesLine.Next() = 0;
    end;

    local procedure PostVoucherPayments(SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange(Posted, false);
        if NpRvSalesLine.FindSet() then
            repeat
                NpRvVoucherMgt.PostPayment(NpRvSalesLine);
            until NpRvSalesLine.Next() = 0;
    end;

    internal procedure IssueVoucherAction(SalesHeader: Record "Sales Header")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        VoucherNo: Text;
    begin
        CheckHeader(SalesHeader);
        if not SelectVoucherType(NpRvVoucherType) then
            exit;

        VoucherNo := IssueVoucher(SalesHeader, NpRvVoucherType);
        Message(Text004, VoucherNo);
    end;

    internal procedure RedeemVoucherAction(SalesHeader: Record "Sales Header")
    var
        ReferenceNo: Text;
        DialogBox: Page "NPR Input Dialog";
        Voucher: Record "NPR NpRv Voucher";
        VoucherRedeemedLbl: Label 'Voucher with reference no. "%1" has been redeem on the Sales Header';
    begin
        CheckHeader(SalesHeader);

        DialogBox.SetInput(1, ReferenceNo, Voucher.FieldCaption("Reference No."));
        if DialogBox.RunModal() <> Action::OK then
            exit;

        DialogBox.InputText(1, ReferenceNo);
        if ReferenceNo = '' then
            exit;

        RedeemVoucher(SalesHeader, ReferenceNo);
        Message(VoucherRedeemedLbl, ReferenceNo);
    end;

    internal procedure RedeemVoucher(SalesHeader: Record "Sales Header"; ReferenceNo: Text)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        PmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
        Amount: Decimal;
        TotalAmountToPay: Decimal;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        VoucherCanBeUsed: Boolean;
        HasPOSPaymentMethodItemFilter: Boolean;
        AmountNotGtZero: Label 'The remaining amount to be paid on the Sales Header is not greater than 0';
        VoucherCannotBeUsedWithItemsErr: Label 'Voucher cannot be used with items currently present on Sales Order.';
    begin
        Voucher.SetCurrentKey("Reference No.");
        Voucher.SetRange("Reference No.", ReferenceNo);
        if not Voucher.FindFirst() then
            Error(VoucherNotFoundErr, ReferenceNo);

        Voucher.CalcFields("In-use Quantity", Amount);
        if Voucher."In-use Quantity" > 0 then
            Error(VoucherInUseErr);

        if not VoucherType.Get(Voucher."Voucher Type") then
            Clear(VoucherType);

        SalesHeader.CalcFields("Amount Including VAT");
        TotalAmountToPay := MagentoPmtMgt.GetAmountToPay(SalesHeader."Amount Including VAT", Database::"Sales Header", SalesHeader."No.", SalesHeader."Document Type");

        HasPOSPaymentMethodItemFilter := PmtMethodItemMgt.HasPOSPaymentMethodItemFilter(VoucherType."Payment Type");
        if HasPOSPaymentMethodItemFilter then begin

            VoucherCanBeUsed := CheckIfPaymentMethodCanBeUsedWithSalesOrder(SalesHeader, VoucherType."Payment Type");
            if not VoucherCanBeUsed then
                Error(VoucherCannotBeUsedWithItemsErr);

            SalesAmount := CalcSalesOrderPaymentMethodItemSalesAmount(SalesHeader, VoucherType."Payment Type");
            PaidAmount := CalcSalesOrderPaymentMethodItemPaymentAmount(SalesHeader, VoucherType.Code, VoucherType."Payment Type");
            Amount := SalesAmount - PaidAmount;

            if Amount > TotalAmountToPay then
                Amount := TotalAmountToPay;
        end else
            // Default to the remaining amount to be paid
            Amount := TotalAmountToPay;

        if Amount <= 0 then
            Error(AmountNotGtZero);

        // Set to voucher's full amount if the total amount isn't available
        if Amount > Voucher.Amount then
            Amount := Voucher.Amount;

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Document Type" := SalesHeader."Document Type";
        NpRvSalesLine."Document No." := SalesHeader."No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher Type" := Voucher."Voucher Type";
        NpRvSalesLine."Voucher No." := Voucher."No.";
        NpRvSalesLine."Reference No." := Voucher."Reference No.";
        NpRvSalesLine.Description := CopyStr(Voucher.Description, 1, MaxStrLen(NpRvSalesLine.Description));
        NpRvSalesLine.Insert(true);

        RedeemVoucher(SalesHeader, NpRvSalesLine, Amount);
    end;

    local procedure CheckIfPaymentMethodCanBeUsedWithSalesOrder(SalesHeader: Record "Sales Header"; POSPaymentMethodCode: Code[10]) VoucherTypeCanBeUsed: Boolean;
    var
        SalesLine: Record "Sales Line";
        PmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        if POSPaymentMethodCode = '' then
            exit;

        if not PmtMethodItemMgt.HasPOSPaymentMethodItemFilter(POSPaymentMethodCode) then
            exit;

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '>0');
        SalesLine.SetLoadFields("Document Type", "Document No.", Type, "No.", Quantity, "Item Category Code");
        if not SalesLine.FindSet() then
            exit;

        repeat
            VoucherTypeCanBeUsed := PmtMethodItemMgt.IsThisPOSPaymentMethodItem(POSPaymentMethodCode, SalesLine."Item Category Code", SalesLine."No.");
            if VoucherTypeCanBeUsed then
                exit;
        until (SalesLine.Next() = 0);
    end;

    internal procedure CalcSalesOrderPaymentMethodItemSalesAmount(SalesHader: Record "Sales Header"; POSPaymentMethodCode: Code[10]) SalesAmount: Decimal;
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempOtherVoucherPaymentLines: Record "NPR Magento Payment Line" temporary;
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        if POSPaymentMethodCode = '' then
            exit;

        if SalesHader."Document Type" <> SalesHader."Document Type"::Order then
            exit;

        if not POSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(POSPaymentMethodCode) then
            exit;

        FindSalesLines(SalesHader, TempSalesLine);
        FindOtherVoucherPaymentLines(SalesHader, TempOtherVoucherPaymentLines, POSPaymentMethodCode);
        DecreaseOnlySalesLineThatCanOnlyBePaidWithOtherVouchersPaymentTypes(TempSalesLine, TempOtherVoucherPaymentLines, POSPaymentMethodCode);
        DecreaseSalesLinesThatCanBePaidWithOtherVouchersPaymentTypes(TempSalesLine, TempOtherVoucherPaymentLines);
        SalesAmount := CalculateSaleAmountWithThisPOSPaymentMethod(TempSalesLine, POSPaymentMethodCode);
    end;

    internal procedure DecreaseOnlySalesLineThatCanOnlyBePaidWithOtherVouchersPaymentTypes(var TempSalesLine: Record "Sales Line" temporary; var TempOtherPaymentVoucherLine: Record "NPR Magento Payment Line" temporary; POSPaymentMethodCode: Code[20])
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        OtherPaymentMethodCode: Code[10];
        TempSalesLineNotTemporaryErrorLbl: Label 'Parameter TempSalesLine must be tempoarary. This is a programming error.';
        TempOtherPaymentVoucherLineNotTemporaryLbl: Label 'Parameter TempOtherPaymentVoucherLine must be temporary. This is a programming error.';
    begin
        if POSPaymentMethodCode = '' then
            exit;

        if not TempSalesLine.IsTemporary then
            Error(TempSalesLineNotTemporaryErrorLbl);

        if not TempOtherPaymentVoucherLine.IsTemporary then
            Error(TempOtherPaymentVoucherLineNotTemporaryLbl);

        TempOtherPaymentVoucherLine.Reset();
        if not TempOtherPaymentVoucherLine.FindSet() then
            exit;

        repeat
            OtherPaymentMethodCode := NpRvVoucherMgt.GetVoucherPaymentMethod(TempOtherPaymentVoucherLine."No.");
            TempSalesLine.Reset();
            if TempSalesLine.FindSet() then
                repeat
                    if POSPmtMethodItemMgt.IsThisPOSPaymentMethodItem(OtherPaymentMethodCode, TempSalesLine) then
                        if not POSPmtMethodItemMgt.IsThisPOSPaymentMethodItem(POSPaymentMethodCode, TempSalesLine) then
                            if TempOtherPaymentVoucherLine.Amount >= TempSalesLine."Amount Including VAT" then begin
                                TempOtherPaymentVoucherLine.Amount -= TempSalesLine."Amount Including VAT";
                                TempOtherPaymentVoucherLine.Modify();
                                TempSalesLine."Amount Including VAT" := 0;
                                TempSalesLine.Modify();
                            end else begin
                                TempSalesLine."Amount Including VAT" -= TempOtherPaymentVoucherLine.Amount;
                                TempSalesLine.Modify();
                                TempOtherPaymentVoucherLine.Amount := 0;
                                TempOtherPaymentVoucherLine.Modify();
                            end;
                until (TempSalesLine.Next() = 0) or (TempOtherPaymentVoucherLine.Amount = 0);

            TempSalesLine.Reset();
            TempSalesLine.SetRange("Amount Including VAT", 0);
            TempSalesLine.DeleteAll();
        until TempOtherPaymentVoucherLine.Next() = 0;

        TempOtherPaymentVoucherLine.Reset();
        TempOtherPaymentVoucherLine.SetRange(Amount, 0);
        TempOtherPaymentVoucherLine.DeleteAll();
    end;

    internal procedure DecreaseSalesLinesThatCanBePaidWithOtherVouchersPaymentTypes(var TempSalesLine: Record "Sales Line" temporary; var TempOtherPaymentVoucherLine: Record "NPR Magento Payment Line" temporary)
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        OtherPaymentMethodCode: Code[10];
        TempSalesLineNotTemporaryErrorLbl: Label 'Parameter TempSalesLine must be tempoarary. This is a programming error.';
        TempOtherPaymentVoucherLineNotTemporaryLbl: Label 'Parameter TempOtherPaymentVoucherLine must be temporary. This is a programming error.';
    begin
        if not TempSalesLine.IsTemporary then
            Error(TempSalesLineNotTemporaryErrorLbl);

        if not TempOtherPaymentVoucherLine.IsTemporary then
            Error(TempOtherPaymentVoucherLineNotTemporaryLbl);


        TempOtherPaymentVoucherLine.Reset();
        if not TempOtherPaymentVoucherLine.FindSet() then
            exit;

        repeat
            OtherPaymentMethodCode := NpRvVoucherMgt.GetVoucherPaymentMethod(TempOtherPaymentVoucherLine."No.");
            TempSalesLine.Reset();
            if TempSalesLine.FindSet() then
                repeat
                    if POSPmtMethodItemMgt.IsThisPOSPaymentMethodItem(OtherPaymentMethodCode, TempSalesLine) then
                        if TempOtherPaymentVoucherLine."Amount" >= TempSalesLine."Amount Including VAT" then begin
                            TempOtherPaymentVoucherLine."Amount" -= TempSalesLine."Amount Including VAT";
                            TempOtherPaymentVoucherLine.Modify();
                            TempSalesLine."Amount Including VAT" := 0;
                            TempSalesLine.Modify();
                        end else begin
                            TempSalesLine."Amount Including VAT" -= TempOtherPaymentVoucherLine."Amount";
                            TempSalesLine.Modify();
                            TempOtherPaymentVoucherLine."Amount" := 0;
                            TempOtherPaymentVoucherLine.Modify();
                        end;
                until (TempSalesLine.Next() = 0) or (TempOtherPaymentVoucherLine."Amount" = 0);

            TempSalesLine.Reset();
            TempSalesLine.SetRange("Amount Including VAT", 0);
            TempSalesLine.DeleteAll();
        until TempOtherPaymentVoucherLine.Next() = 0;
    end;

    internal procedure CalculateSaleAmountWithThisPOSPaymentMethod(var TempSaleSaleLine: Record "Sales Line" temporary; POSPaymentMethodCode: Code[20]) SaleAmount: Decimal
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        TempSaleSaleLine.Reset();
        if not TempSaleSaleLine.FindSet() then
            exit;

        repeat
            if POSPmtMethodItemMgt.IsThisPOSPaymentMethodItem(POSPaymentMethodCode, TempSaleSaleLine) then
                SaleAmount += TempSaleSaleLine."Amount Including VAT";
        until TempSaleSaleLine.Next() = 0;
    end;

    internal procedure CalcSalesOrderPaymentMethodItemPaymentAmount(SalesHeader: Record "Sales Header"; VoucherType: Code[20]; POSPaymentMethodCode: Code[10]) PaidAmount: Decimal;
    var
        CurrVoucherSalesLine: Record "NPR NpRv Sales Line";
        RelatedVoucherSalesLine: Record "NPR NpRv Sales Line";
        CurrMagentoPaymentLine: Record "NPR Magento Payment Line";
        TempRelatedMagentoPaymentLineProcessed: Record "NPR Magento Payment Line" temporary;
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        if not POSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(POSPaymentMethodCode) then
            exit;

        CurrVoucherSalesLine.Reset();
        CurrVoucherSalesLine.SetRange("Document Source", CurrVoucherSalesLine."Document Source"::"Payment Line");
        CurrVoucherSalesLine.SetRange("Document No.", SalesHeader."No.");
        CurrVoucherSalesLine.SetRange("Document Type", CurrVoucherSalesLine."Document Type"::Order);
        CurrVoucherSalesLine.SetRange("Voucher Type", VoucherType);
        CurrVoucherSalesLine.SetLoadFields("Document Source", "Document No.", "Document Type", "Voucher Type", "Document Line No.", "Parent Id");
        if not CurrVoucherSalesLine.FindSet() then
            exit;

        repeat
            if not TempRelatedMagentoPaymentLineProcessed.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", CurrVoucherSalesLine."Document Line No.") then begin
                CurrMagentoPaymentLine.SetLoadFields(Amount);
                if CurrMagentoPaymentLine.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", CurrVoucherSalesLine."Document Line No.") then
                    PaidAmount += CurrMagentoPaymentLine.Amount;

                RelatedVoucherSalesLine.SetLoadFields(Id, "Document Line No.");
                if RelatedVoucherSalesLine.Get(CurrVoucherSalesLine."Parent Id") then
                    ProcessRelatedVoucherSalesLineWhenCalcSalesOrderPaymentMethodItemPaymentAmount(RelatedVoucherSalesLine, PaidAmount, TempRelatedMagentoPaymentLineProcessed);

                RelatedVoucherSalesLine.Reset();
                RelatedVoucherSalesLine.SetRange("Parent Id", CurrVoucherSalesLine.Id);
                RelatedVoucherSalesLine.SetLoadFields("Parent Id", "Document Line No.");
                if RelatedVoucherSalesLine.FindFirst() then
                    ProcessRelatedVoucherSalesLineWhenCalcSalesOrderPaymentMethodItemPaymentAmount(RelatedVoucherSalesLine, PaidAmount, TempRelatedMagentoPaymentLineProcessed);
            end;
        until CurrVoucherSalesLine.Next() = 0;
    end;

    local procedure ProcessRelatedVoucherSalesLineWhenCalcSalesOrderPaymentMethodItemPaymentAmount(RelatedVoucherSalesLine: Record "NPR NpRv Sales Line"; var PaidAmount: Decimal; var TempRelatedMagentoPaymentLineProcessed: Record "NPR Magento Payment Line" temporary)
    var
        RelatedMagentoPaymentLine: Record "NPR Magento Payment Line";
        TempRelatedMagentoPaymentLineProcessedErrorLbl: Label 'Parameter TempRelatedMagentoPaymentLineProcessed must be temporary. This is a programming error.';
    begin
        if not TempRelatedMagentoPaymentLineProcessed.IsTemporary then
            Error(TempRelatedMagentoPaymentLineProcessedErrorLbl);

        RelatedMagentoPaymentLine.SetLoadFields(Amount);
        if not RelatedMagentoPaymentLine.Get(Database::"Sales Header", RelatedVoucherSalesLine."Document Type", RelatedVoucherSalesLine."Document No.", RelatedVoucherSalesLine."Document Line No.") then
            exit;

        PaidAmount += RelatedMagentoPaymentLine.Amount;
        if TempRelatedMagentoPaymentLineProcessed.Get(RelatedMagentoPaymentLine.RecordId) then
            exit;

        TempRelatedMagentoPaymentLineProcessed.Init();
        TempRelatedMagentoPaymentLineProcessed := RelatedMagentoPaymentLine;
        TempRelatedMagentoPaymentLineProcessed.Insert();

    end;

    internal procedure CalcSalesOrderPaymentMethodItemPaymentAmountFromBuffers(SalesHeader: Record "Sales Header";
                                                                               var TempVoucherSalesLine: Record "NPR NpRv Sales Line" temporary;
                                                                               var TempDocumentMagentoPaymentLines: Record "NPR Magento Payment Line" temporary;
                                                                               POSPaymentMethodCode: Code[10]) PaidAmount: Decimal;
    var
        TempRelatedVoucherSalesLine: Record "NPR NpRv Sales Line" temporary;
        TempRelatedDocumentMagentoPaymentLines: Record "NPR Magento Payment Line" temporary;
        TempRelatedMagentoPaymentLineProcessed: Record "NPR Magento Payment Line" temporary;
        VoucherType: Record "NPR NpRv Voucher Type";
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        if not POSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(POSPaymentMethodCode) then
            exit;
        CopyVoucherSalesLineBuffer(TempVoucherSalesLine, TempRelatedVoucherSalesLine);
        CopyMagentoPaymentLineBuffer(TempDocumentMagentoPaymentLines, TempRelatedDocumentMagentoPaymentLines);

        TempVoucherSalesLine.Reset();
        if not TempVoucherSalesLine.FindSet() then
            exit;

        repeat
            VoucherType.Reset();
            VoucherType.SetRange("Payment Type", POSPaymentMethodCode);
            VoucherType.SetRange(Code, TempVoucherSalesLine."Voucher Type");
            if not VoucherType.IsEmpty then begin
                if not TempRelatedMagentoPaymentLineProcessed.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", TempVoucherSalesLine."Document Line No.") then begin
                    if TempDocumentMagentoPaymentLines.Get(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", TempVoucherSalesLine."Document Line No.") then
                        PaidAmount += TempDocumentMagentoPaymentLines.Amount;

                    if TempRelatedVoucherSalesLine.Get(TempVoucherSalesLine."Parent Id") then
                        ProcessRelatedVoucherSalesLineWhenCalcSalesOrderPaymentMethodItemPaymentAmountFromBuffers(TempRelatedVoucherSalesLine,
                                                                                                                  TempRelatedDocumentMagentoPaymentLines,
                                                                                                                  PaidAmount,
                                                                                                                  TempRelatedMagentoPaymentLineProcessed);

                    TempRelatedVoucherSalesLine.Reset();
                    TempRelatedVoucherSalesLine.SetRange("Parent Id", TempVoucherSalesLine.Id);
                    TempRelatedVoucherSalesLine.SetLoadFields("Parent Id", "Document Line No.");
                    if TempRelatedVoucherSalesLine.FindFirst() then
                        ProcessRelatedVoucherSalesLineWhenCalcSalesOrderPaymentMethodItemPaymentAmountFromBuffers(TempRelatedVoucherSalesLine,
                                                                                                                  TempRelatedDocumentMagentoPaymentLines,
                                                                                                                  PaidAmount,
                                                                                                                  TempRelatedMagentoPaymentLineProcessed);
                end;
            end;
        until TempVoucherSalesLine.Next() = 0;
    end;

    local procedure ProcessRelatedVoucherSalesLineWhenCalcSalesOrderPaymentMethodItemPaymentAmountFromBuffers(RelatedVoucherSalesLine: Record "NPR NpRv Sales Line";
                                                                                                              var TempRelatedMagentoPaymentLine: Record "NPR Magento Payment Line" temporary;
                                                                                                              var PaidAmount: Decimal;
                                                                                                              var TempRelatedMagentoPaymentLineProcessed: Record "NPR Magento Payment Line" temporary)
    var
        TempRelatedMagentoPaymentLineProcessedErrorLbl: Label 'Parameter TempRelatedMagentoPaymentLineProcessed must be temporary. This is a programming error.';
    begin
        if not TempRelatedMagentoPaymentLineProcessed.IsTemporary then
            Error(TempRelatedMagentoPaymentLineProcessedErrorLbl);

        if not TempRelatedMagentoPaymentLine.Get(Database::"Sales Header", RelatedVoucherSalesLine."Document Type", RelatedVoucherSalesLine."Document No.", RelatedVoucherSalesLine."Document Line No.") then
            exit;

        PaidAmount += TempRelatedMagentoPaymentLine.Amount;
        if TempRelatedMagentoPaymentLineProcessed.Get(TempRelatedMagentoPaymentLine.RecordId) then
            exit;

        TempRelatedMagentoPaymentLineProcessed.Init();
        TempRelatedMagentoPaymentLineProcessed := TempRelatedMagentoPaymentLine;
        TempRelatedMagentoPaymentLineProcessed.Insert();

    end;

    internal procedure FindSalesLines(SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary)
    var
        SalesLine: Record "Sales Line";
        TempSalesLineNotTemporaryErrorLbl: Label 'Parameter TempSalesLine must be temporary. This is a programming error.';
    begin
        if not TempSalesLine.IsTemporary then
            Error(TempSalesLineNotTemporaryErrorLbl);

        TempSalesLine.Reset();
        if not TempSalesLine.IsEmpty then
            TempSalesLine.DeleteAll();

        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetLoadFields("Document No.", "Document Type", "Line No.", "Amount Including VAT");
        if not SalesLine.FindSet() then
            exit;

        repeat
            TempSalesLine.Init();
            TempSalesLine := SalesLine;
            TempSalesLine.Insert()
        until SalesLine.Next() = 0;

    end;

    local procedure FindOtherVoucherPaymentLines(SalesHeader: Record "Sales Header"; var TempOtherVoucherPaymentLine: Record "NPR Magento Payment Line" temporary; POSPaymentMethodCode: Code[10])
    var
        CurrMagentoPaymentLine: Record "NPR Magento Payment Line";
        TempCurrMagentoPaymentLine: Record "NPR Magento Payment Line" temporary;
        CurrVoucherSalesLine: Record "NPR NpRv Sales Line";
        RelatedVoucherSalesLine: Record "NPR NpRv Sales Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        RelatedVoucherType: Record "NPR NpRv Voucher Type";
        TempMagentoPaymentLineProccessed: Record "NPR Magento Payment Line" temporary;
        SkipLine: Boolean;
        TempOtherVoucherPaymentLineTemporaryError: Label 'The parameter TempOtherVoucherPaymentLine must be temporary. This is a programming error.';
    begin
        if not TempOtherVoucherPaymentLine.IsTemporary then
            Error(TempOtherVoucherPaymentLineTemporaryError);

        TempOtherVoucherPaymentLine.Reset();
        if not TempOtherVoucherPaymentLine.IsEmpty then
            TempOtherVoucherPaymentLine.DeleteAll();

        CurrMagentoPaymentLine.Reset();
        CurrMagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        CurrMagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
        CurrMagentoPaymentLine.SetRange("Payment Type", CurrMagentoPaymentLine."Payment Type"::Voucher);
        CurrMagentoPaymentLine.SetLoadFields("Document Table No.", "Document No.", "Payment Type", "No.");
        if not CurrMagentoPaymentLine.FindSet() then
            exit;

        repeat
            if not TempMagentoPaymentLineProccessed.get(CurrMagentoPaymentLine.RecordId) then begin
                TempCurrMagentoPaymentLine := CurrMagentoPaymentLine;

                Voucher.SetCurrentKey("Reference No.");
                Voucher.SetRange("Reference No.", TempCurrMagentoPaymentLine."No.");
                Voucher.SetLoadFields("Reference No.", "Voucher Type");
                if Voucher.FindFirst() then begin
                    VoucherType.SetLoadFields(Code, "Payment Type");
                    if VoucherType.Get(Voucher."Voucher Type") then
                        if VoucherType."Payment Type" <> POSPaymentMethodCode then begin
                            SkipLine := false;

                            CurrVoucherSalesLine.Reset();
                            CurrVoucherSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
                            CurrVoucherSalesLine.SetRange("Document Type", CurrVoucherSalesLine."Document Type"::Order);
                            CurrVoucherSalesLine.SetRange("Document Source", CurrVoucherSalesLine."Document Source"::"Payment Line");
                            CurrVoucherSalesLine.SetRange("Document No.", TempCurrMagentoPaymentLine."Document No.");
                            CurrVoucherSalesLine.SetRange("Document Line No.", TempCurrMagentoPaymentLine."Line No.");
                            CurrVoucherSalesLine.SetLoadFields("Document Type", "Document Source", "Document No.", "Document Line No.", "Parent Id");
                            if CurrVoucherSalesLine.FindFirst() then begin
                                RelatedVoucherSalesLine.SetLoadFields("Voucher Type");
                                if RelatedVoucherSalesLine.Get(CurrVoucherSalesLine."Parent Id") then begin
                                    RelatedVoucherType.SetLoadFields("Payment Type");
                                    if RelatedVoucherType.Get(RelatedVoucherSalesLine."Voucher Type") then
                                        ProcessRelatedVoucherSalesLineWhenFindingOtherPaymentLines(TempCurrMagentoPaymentLine, RelatedVoucherSalesLine, SkipLine, POSPaymentMethodCode, TempMagentoPaymentLineProccessed);
                                end;

                                RelatedVoucherSalesLine.Reset();
                                RelatedVoucherSalesLine.SetRange("Parent Id", CurrVoucherSalesLine.Id);
                                RelatedVoucherSalesLine.SetLoadFields("Voucher Type");
                                if RelatedVoucherSalesLine.FindFirst() then
                                    ProcessRelatedVoucherSalesLineWhenFindingOtherPaymentLines(TempCurrMagentoPaymentLine, RelatedVoucherSalesLine, SkipLine, POSPaymentMethodCode, TempMagentoPaymentLineProccessed);
                            end;

                            if not SkipLine then begin
                                TempOtherVoucherPaymentLine.Init();
                                TempOtherVoucherPaymentLine := TempCurrMagentoPaymentLine;
                                TempOtherVoucherPaymentLine.Insert();
                            end;
                        end
                end;
            end;
        until CurrMagentoPaymentLine.Next() = 0;
    end;

    local procedure ProcessRelatedVoucherSalesLineWhenFindingOtherPaymentLines(var CurrMagentoPaymentLine: Record "NPR Magento Payment Line" temporary; RelatedVoucherSalesLine: Record "NPR NpRv Sales Line"; var SkipLine: Boolean; POSPaymentMethodCode: Code[10]; var TempRelatedProcessedMagentoPaymentLine: Record "NPR Magento Payment Line" temporary)
    var
        RelatedVoucherType: Record "NPR NpRv Voucher Type";
        RelatedMagentoPaymentLine: Record "NPR Magento Payment Line";
        TempRelatedProcessedSalesLinePOSError: Label 'Parameter TempRelatedProcessedMagentoPaymentLine must be temporary. This is a programming error.';
    begin
        if not TempRelatedProcessedMagentoPaymentLine.IsTemporary then
            Error(TempRelatedProcessedSalesLinePOSError);

        RelatedVoucherType.SetLoadFields("Payment Type");
        if not RelatedVoucherType.Get(RelatedVoucherSalesLine."Voucher Type") then
            exit;

        SkipLine := SkipLine or (RelatedVoucherType."Payment Type" = POSPaymentMethodCode);
        if SkipLine then
            exit;

        if not RelatedMagentoPaymentLine.Get(Database::"Sales Header", RelatedVoucherSalesLine."Document Type", RelatedVoucherSalesLine."Document No.", RelatedVoucherSalesLine."Document Line No.") then
            exit;

        CurrMagentoPaymentLine."Amount" += RelatedMagentoPaymentLine."Amount";
        if TempRelatedProcessedMagentoPaymentLine.Get(RelatedMagentoPaymentLine.RecordId) then
            exit;

        TempRelatedProcessedMagentoPaymentLine := RelatedMagentoPaymentLine;
        TempRelatedProcessedMagentoPaymentLine.Insert();

    end;

    internal procedure RedeemVoucher(SalesHeader: Record "Sales Header"; var
                                                                             NpRvSalesLine: Record "NPR NpRv Sales Line";
                                                                             Amount: Decimal)
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        Voucher: Record "NPR NpRv Voucher";
        LineNo: Decimal;
        Modi: Boolean;
    begin
        Voucher.SetCurrentKey("Reference No.");
        Voucher.SetRange("Reference No.", NpRvSalesLine."Reference No.");
        if not Voucher.FindFirst() then
            Error(VoucherNotFoundErr, NpRvSalesLine."Reference No.");

        if NpRvSalesLine."External Document No." <> SalesHeader."NPR External Order No." then begin
            NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
            Modi := true;
        end;

        if NpRvSalesLine."Document Source" <> NpRvSalesLine."Document Source"::"Sales Document" then begin
            NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
            Modi := true;
        end;

        if NpRvSalesLine."Document Type" <> SalesHeader."Document Type" then begin
            NpRvSalesLine."Document Type" := SalesHeader."Document Type";
            Modi := true;
        end;

        if NpRvSalesLine."Document No." <> SalesHeader."No." then begin
            NpRvSalesLine."Document No." := SalesHeader."No.";
            Modi := true;
        end;

        if Modi then
            NpRvSalesLine.Modify(true);

        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        MagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
        if MagentoPaymentLine.FindLast() then;
        LineNo := MagentoPaymentLine."Line No." + 10000;

        MagentoPaymentLine.Init();
        MagentoPaymentLine."Document Table No." := Database::"Sales Header";
        MagentoPaymentLine."Document Type" := SalesHeader."Document Type";
        MagentoPaymentLine."Document No." := SalesHeader."No.";
        MagentoPaymentLine."Line No." := LineNo;
        MagentoPaymentLine."Payment Type" := MagentoPaymentLine."Payment Type"::Voucher;
        MagentoPaymentLine.Description := CopyStr(Voucher.Description, 1, MaxStrLen(MagentoPaymentLine.Description));
        MagentoPaymentLine."Account No." := Voucher."Account No.";
        MagentoPaymentLine."No." := Voucher."Reference No.";
        MagentoPaymentLine."Posting Date" := SalesHeader."Posting Date";
        MagentoPaymentLine."Source Table No." := Database::"NPR NpRv Voucher";
        MagentoPaymentLine."Source No." := Voucher."No.";
        MagentoPaymentLine."External Reference No." := SalesHeader."NPR External Order No.";
        MagentoPaymentLine."Requested Amount" := Amount;
        MagentoPaymentLine.Amount := Amount;
        MagentoPaymentLine.Insert(true);

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Type" := SalesHeader."Document Type"::Order;
        NpRvSalesLine."Document No." := SalesHeader."No.";
        NpRvSalesLine."Document Line No." := MagentoPaymentLine."Line No.";
        NpRvSalesLine.Modify(true);

        // Lastly run ApplyPayment() so we leave the lines in the correct state.
        ApplyPayment(SalesHeader, NpRvSalesLine);
    end;

    internal procedure CreateMagentoPaymentLines(SalesHeader: Record "Sales Header"; var CurrVoucherSalesLine: Record "NPR NpRv Sales Line"; Amount: Decimal; var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        RelatedVoucherSalesLine: Record "NPR NpRv Sales Line";
        RelatedSaleLinePOS: Record "NPR POS Sale Line";
        LineNo: Decimal;
        RequestedAmount: Decimal;
        Modi: Boolean;
        LineDescriptionLbl: Label '%1 %2';
    begin
        VoucherType.Get(CurrVoucherSalesLine."Voucher Type");
        if CurrVoucherSalesLine."External Document No." <> SalesHeader."NPR External Order No." then begin
            CurrVoucherSalesLine."External Document No." := SalesHeader."NPR External Order No.";
            Modi := true;
        end;

        if CurrVoucherSalesLine."Document Source" <> CurrVoucherSalesLine."Document Source"::"Sales Document" then begin
            CurrVoucherSalesLine."Document Source" := CurrVoucherSalesLine."Document Source"::"Sales Document";
            Modi := true;
        end;

        if CurrVoucherSalesLine."Document Type" <> SalesHeader."Document Type" then begin
            CurrVoucherSalesLine."Document Type" := SalesHeader."Document Type";
            Modi := true;
        end;

        if CurrVoucherSalesLine."Document No." <> SalesHeader."No." then begin
            CurrVoucherSalesLine."Document No." := SalesHeader."No.";
            Modi := true;
        end;

        if Modi then
            CurrVoucherSalesLine.Modify(true);

        RequestedAmount := Amount;

        RelatedVoucherSalesLine.Reset();
        RelatedVoucherSalesLine.SetLoadFields("Sales Ticket No.", "Register No.", "Retail ID", "Sale Line No.");
        if RelatedVoucherSalesLine.Get(RelatedVoucherSalesLine."Parent Id") then
            if RelatedSaleLinePOS.GetBySystemId(RelatedVoucherSalesLine."Retail ID") then
                RequestedAmount += RelatedSaleLinePOS."Amount Including VAT";

        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        MagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
        if not MagentoPaymentLine.FindLast() then
            Clear(MagentoPaymentLine);

        LineNo := MagentoPaymentLine."Line No." + 10000;

        MagentoPaymentLine.Init();
        MagentoPaymentLine."Document Table No." := Database::"Sales Header";
        MagentoPaymentLine."Document Type" := SalesHeader."Document Type";
        MagentoPaymentLine."Document No." := SalesHeader."No.";
        MagentoPaymentLine."Line No." := LineNo;
        MagentoPaymentLine."Payment Type" := MagentoPaymentLine."Payment Type"::Voucher;
        MagentoPaymentLine.Description := CopyStr(StrSubstNo(LineDescriptionLbl, CurrVoucherSalesLine."Reference No.", CurrVoucherSalesLine."Voucher Type"), 1, MaxStrLen(MagentoPaymentLine.Description));
        MagentoPaymentLine."Account No." := VoucherType."Account No.";
        MagentoPaymentLine."No." := CurrVoucherSalesLine."Reference No.";
        MagentoPaymentLine."Posting Date" := SalesHeader."Posting Date";
        MagentoPaymentLine."Source Table No." := Database::"NPR NpRv Voucher";
        MagentoPaymentLine."Source No." := CurrVoucherSalesLine."Voucher No.";
        MagentoPaymentLine."External Reference No." := SalesHeader."NPR External Order No.";
        MagentoPaymentLine."Requested Amount" := RequestedAmount;
        MagentoPaymentLine.Amount := Amount;
        MagentoPaymentLine.Insert(true);

        CurrVoucherSalesLine."Document Source" := CurrVoucherSalesLine."Document Source"::"Payment Line";
        CurrVoucherSalesLine."Document Type" := SalesHeader."Document Type"::Order;
        CurrVoucherSalesLine."Document No." := SalesHeader."No.";
        CurrVoucherSalesLine."Document Line No." := MagentoPaymentLine."Line No.";
        CurrVoucherSalesLine.Modify(true);
    end;

    internal procedure ShowRelatedVouchersAction(SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetCurrentKey("Document Source", "Document Type", "Document No.", "Document Line No.");
        NpRvSalesLine.SetFilter("Document Source", '%1|%2',
            NpRvSalesLine."Document Source"::"Sales Document", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        PAGE.Run(0, NpRvSalesLine);
    end;

    local procedure GetTotalAmtInclVat(SalesHeader: Record "Sales Header"): Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 0);
        TempSalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
        exit(TempVATAmountLine.GetTotalAmountInclVAT());
    end;

    local procedure FindVoucherTypes(var TempNpRvVoucherType: Record "NPR NpRv Voucher Type" temporary)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
    begin
        if NpRvVoucherType.FindSet() then
            repeat
                if not TempNpRvVoucherType.Get(NpRvVoucherType.Code) then begin
                    TempNpRvVoucherType.Init();
                    TempNpRvVoucherType := NpRvVoucherType;
                    TempNpRvVoucherType.Insert();
                end;
            until NpRvVoucherType.Next() = 0;
    end;

    local procedure CheckHeader(SalesHeader: Record "Sales Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        NotSupportedErr: Label 'Voucher operations in foreign currency are not supported.';
    begin
        If SalesHeader."Currency Code" = '' then
            exit;

        GeneralLedgerSetup.Get();
        if SalesHeader."Currency Code" <> GeneralLedgerSetup."LCY Code" then
            Error(NotSupportedErr);
    end;

    local procedure InputVoucherReferenceNumber(NpRvVoucherType: Record "NPR NpRv Voucher Type"; var ReferenceNumber: Code[50])
    var
        Voucher: Record "NPR NpRv Voucher";
        InputDialog: Page "NPR Input Dialog";
        EnterReferenceNumberLbl: Label 'Enter new voucher reference number';
        AlreadyUsedLbl: Label 'Reference No. %1 is already used.';
        EmtyReferenceErr: Label 'Voucher reference number must be entered';
    begin
        if not NpRvVoucherType."Manual Reference number SO" then
            exit;
        InputDialog.LookupMode := true;
        InputDialog.SetInput(1, ReferenceNumber, EnterReferenceNumberLbl);
        if InputDialog.RunModal() = ACTION::LookupOK then
            InputDialog.InputCodeValue(1, ReferenceNumber);

        if ReferenceNumber = '' then
            Error(EmtyReferenceErr);

        Voucher.SetRange("Reference No.", ReferenceNumber);
        if Voucher.FindFirst() then
            Error(AlreadyUsedLbl, ReferenceNumber);
    end;

    local procedure InsertSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var TempNpRvVoucher: Record "NPR NpRv Voucher" temporary)
    var
        LineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then;
        LineNo := SalesLine."Line No." + 10000;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", TempNpRvVoucher."Account No.");
        SalesLine.Description := TempNpRvVoucher.Description;
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);
    end;

    local procedure InsertNpRvSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var TempNpRvVoucher: Record "NPR NpRv Voucher" temporary)
    begin
        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
        NpRvSalesLine."Document Type" := SalesLine."Document Type";
        NpRvSalesLine."Document No." := SalesLine."Document No.";
        NpRvSalesLine."Document Line No." := SalesLine."Line No.";
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Voucher Type" := TempNpRvVoucher."Voucher Type";
        NpRvSalesLine."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLine."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLine."Voucher Message" := TempNpRvVoucher."Voucher Message";
        NpRvSalesLine.Description := TempNpRvVoucher.Description;
        NpRvSalesLine.Validate("Customer No.", SalesHeader."Sell-to Customer No.");
        if (not NpRvSalesLine."Send via Print") and (not NpRvSalesLine."Send via SMS") and (NpRvSalesLine."E-mail" <> '') then
            NpRvSalesLine."Send via E-mail" := true;
        NpRvSalesLine.Insert(true);
    end;

    local procedure InsertNpRVSalesLineReference(var NpRvSalesLine: Record "NPR NpRv Sales Line"; var TempNpRvVoucher: Record "NPR NpRv Voucher" temporary)
    var
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
    begin
        NpRvSalesLineReference.Init();
        NpRvSalesLineReference.Id := CreateGuid();
        NpRvSalesLineReference."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLineReference."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
        NpRvSalesLineReference.Insert(true);
    end;

    internal procedure SendVoucher(NpRvVoucher: Record "NPR NpRv Voucher")
    var
        LastErrorText: Text;
    begin
        NpRvVoucher.CalcFields(Amount);
        if NpRvVoucher.Amount > 0 then begin
            ClearLastError();
            Commit();
            if not Codeunit.Run(codeunit::"NPR NpRv Voucher Mgt.", NpRvVoucher) then begin
                LastErrorText := GetLastErrorText;
                if LastErrorText <> '' then
                    Message(LastErrorText);
            end;
            Commit();
        end;
    end;

    internal procedure FindOtherVoucherPaymentLinesFromBuffers(var TempOtherVoucherPaymentLine: Record "NPR Magento Payment Line" temporary;
                                                               var TempDocumentMagentoPaymentLine: Record "NPR Magento Payment Line" temporary;
                                                               var TempCurrVoucherSalesLine: Record "NPR NpRv Sales Line" temporary;
                                                               POSPaymentMethodCode: Code[10])
    var

        TempCurrMagentoPaymentLine: Record "NPR Magento Payment Line" temporary;
        TempRelatedDocumentMagentoPaymentLine: Record "NPR Magento Payment Line" temporary;
        TempRelatedVoucherSalesLine: Record "NPR NpRv Sales Line" temporary;
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        RelatedVoucherType: Record "NPR NpRv Voucher Type";
        TempMagentoPaymentLineProccessed: Record "NPR Magento Payment Line" temporary;
        SkipLine: Boolean;
        TempOtherVoucherPaymentLineTemporaryErrorLbl: Label 'The parameter TempOtherVoucherPaymentLine must be temporary. This is a programming error.';
    begin
        if not TempOtherVoucherPaymentLine.IsTemporary then
            Error(TempOtherVoucherPaymentLineTemporaryErrorLbl);

        TempOtherVoucherPaymentLine.Reset();
        if not TempOtherVoucherPaymentLine.IsEmpty then
            TempOtherVoucherPaymentLine.DeleteAll();

        CopyVoucherSalesLineBuffer(TempCurrVoucherSalesLine, TempRelatedVoucherSalesLine);
        CopyMagentoPaymentLineBuffer(TempDocumentMagentoPaymentLine, TempRelatedDocumentMagentoPaymentLine);

        TempDocumentMagentoPaymentLine.Reset();
        TempDocumentMagentoPaymentLine.SetRange("Payment Type", TempDocumentMagentoPaymentLine."Payment Type"::Voucher);
        if not TempDocumentMagentoPaymentLine.FindSet() then begin
            TempDocumentMagentoPaymentLine.Reset();
            exit;
        end;

        repeat
            if not TempMagentoPaymentLineProccessed.get(TempDocumentMagentoPaymentLine.RecordId) then begin
                TempCurrMagentoPaymentLine := TempDocumentMagentoPaymentLine;

                Voucher.SetCurrentKey("Reference No.");
                Voucher.SetRange("Reference No.", TempCurrMagentoPaymentLine."No.");
                Voucher.SetLoadFields("Reference No.", "Voucher Type");
                if Voucher.FindFirst() then begin
                    VoucherType.SetLoadFields(Code, "Payment Type");
                    if VoucherType.Get(Voucher."Voucher Type") then
                        if VoucherType."Payment Type" <> POSPaymentMethodCode then begin
                            SkipLine := false;

                            TempCurrVoucherSalesLine.Reset();
                            TempCurrVoucherSalesLine.SetRange("Document Type", TempCurrVoucherSalesLine."Document Type"::Order);
                            TempCurrVoucherSalesLine.SetRange("Document Source", TempCurrVoucherSalesLine."Document Source"::"Payment Line");
                            TempCurrVoucherSalesLine.SetRange("Document No.", TempCurrMagentoPaymentLine."Document No.");
                            TempCurrVoucherSalesLine.SetRange("Document Line No.", TempCurrMagentoPaymentLine."Line No.");
                            if TempCurrVoucherSalesLine.FindFirst() then begin
                                if TempRelatedVoucherSalesLine.Get(TempCurrVoucherSalesLine."Parent Id") then begin
                                    RelatedVoucherType.SetLoadFields("Payment Type");
                                    if RelatedVoucherType.Get(TempRelatedVoucherSalesLine."Voucher Type") then
                                        ProcessRelatedVoucherSalesLineWhenFindingOtherPaymentLines(TempCurrMagentoPaymentLine,
                                                                                                    TempRelatedVoucherSalesLine,
                                                                                                    SkipLine,
                                                                                                    POSPaymentMethodCode,
                                                                                                    TempRelatedDocumentMagentoPaymentLine,
                                                                                                    TempMagentoPaymentLineProccessed);
                                end;

                                TempRelatedVoucherSalesLine.Reset();
                                TempRelatedVoucherSalesLine.SetRange("Parent Id", TempCurrVoucherSalesLine.Id);
                                if TempRelatedVoucherSalesLine.FindFirst() then
                                    ProcessRelatedVoucherSalesLineWhenFindingOtherPaymentLines(TempCurrMagentoPaymentLine,
                                                                                               TempRelatedVoucherSalesLine,
                                                                                               SkipLine,
                                                                                               POSPaymentMethodCode,
                                                                                               TempRelatedDocumentMagentoPaymentLine,
                                                                                               TempMagentoPaymentLineProccessed);
                            end;

                            if not SkipLine then begin
                                TempOtherVoucherPaymentLine.Init();
                                TempOtherVoucherPaymentLine := TempCurrMagentoPaymentLine;
                                TempOtherVoucherPaymentLine.Insert();
                            end;
                        end
                end;
            end;
        until TempDocumentMagentoPaymentLine.Next() = 0;
    end;

    local procedure ProcessRelatedVoucherSalesLineWhenFindingOtherPaymentLines(var CurrMagentoPaymentLine: Record "NPR Magento Payment Line" temporary;
                                                                                RelatedVoucherSalesLine: Record "NPR NpRv Sales Line";
                                                                                var SkipLine: Boolean;
                                                                                POSPaymentMethodCode: Code[10];
                                                                                var TempRelatedVoucherSalesLine: Record "NPR Magento Payment Line" temporary;
                                                                                var TempRelatedProcessedMagentoPaymentLine: Record "NPR Magento Payment Line" temporary)
    var
        RelatedVoucherType: Record "NPR NpRv Voucher Type";
        TempRelatedProcessedSalesLinePOSErrorLbl: Label 'Parameter TempRelatedProcessedMagentoPaymentLine must be temporary. This is a programming error.';
    begin
        if not TempRelatedProcessedMagentoPaymentLine.IsTemporary then
            Error(TempRelatedProcessedSalesLinePOSErrorLbl);

        RelatedVoucherType.SetLoadFields("Payment Type");
        if not RelatedVoucherType.Get(RelatedVoucherSalesLine."Voucher Type") then
            exit;

        SkipLine := SkipLine or (RelatedVoucherType."Payment Type" = POSPaymentMethodCode);
        if SkipLine then
            exit;

        if not TempRelatedVoucherSalesLine.Get(Database::"Sales Header", RelatedVoucherSalesLine."Document Type", RelatedVoucherSalesLine."Document No.", RelatedVoucherSalesLine."Document Line No.") then
            exit;

        CurrMagentoPaymentLine."Amount" += TempRelatedVoucherSalesLine."Amount";
        if TempRelatedProcessedMagentoPaymentLine.Get(TempRelatedVoucherSalesLine.RecordId) then
            exit;

        TempRelatedProcessedMagentoPaymentLine := TempRelatedVoucherSalesLine;
        TempRelatedProcessedMagentoPaymentLine.Insert();
    end;

    local procedure CopyMagentoPaymentLineBuffer(var TempFromMagentoPaymentLineBuffer: Record "NPR Magento Payment Line" temporary; var TempToMagentoPaymentLineBuffer: Record "NPR Magento Payment Line" temporary)
    var
        TempFromMagentoPaymentLineBufferErrorLbl: Label 'Parameter TempFromMagentoPaymentLineBuffer must be temporary. This is a programming error.';
        TempToMagentoPaymentLineBufferErrorLbl: Label 'Parameter TempToMagentoPaymentLineBuffer must be temporary. This is a programming error.';
    begin
        if not TempFromMagentoPaymentLineBuffer.IsTemporary then
            Error(TempFromMagentoPaymentLineBufferErrorLbl);

        if not TempToMagentoPaymentLineBuffer.IsTemporary then
            Error(TempToMagentoPaymentLineBufferErrorLbl);

        TempToMagentoPaymentLineBuffer.Reset();
        if not TempToMagentoPaymentLineBuffer.IsEmpty then
            TempToMagentoPaymentLineBuffer.DeleteAll();

        if not TempFromMagentoPaymentLineBuffer.FindSet() then
            exit;

        repeat
            TempToMagentoPaymentLineBuffer.Init();
            TempToMagentoPaymentLineBuffer := TempFromMagentoPaymentLineBuffer;
            TempToMagentoPaymentLineBuffer.Insert();
        until TempFromMagentoPaymentLineBuffer.Next() = 0;
    end;

    local procedure CopyVoucherSalesLineBuffer(var TempFromVoucherSalesLine: Record "NPR NpRv Sales Line" temporary; var TempToVoucherSalesLine: Record "NPR NpRv Sales Line" temporary)
    var
        TempFromVoucherSalesLineErrorLbl: Label 'Parameter TempFromVoucherSalesLine must be temporary. This is a programming error.';
        TempToVoucherSalesLineErrorLbl: Label 'Parameter TempToVoucherSalesLine must be temporary. This is a programming error.';
    begin
        if not TempFromVoucherSalesLine.IsTemporary then
            Error(TempFromVoucherSalesLineErrorLbl);

        if not TempToVoucherSalesLine.IsTemporary then
            Error(TempToVoucherSalesLineErrorLbl);

        TempToVoucherSalesLine.Reset();
        if not TempToVoucherSalesLine.IsEmpty then
            TempToVoucherSalesLine.DeleteAll();

        if not TempFromVoucherSalesLine.FindSet() then
            exit;

        repeat
            TempToVoucherSalesLine.Init();
            TempToVoucherSalesLine := TempFromVoucherSalesLine;
            TempToVoucherSalesLine.Insert();
        until TempFromVoucherSalesLine.Next() = 0;

    end;

    internal procedure GetVoucherSalesLinesPOSBuffer(SalesTicketNo: Code[20]; RegisterNo: Code[20]; var TempVoucherSalesLine: Record "NPR NpRv Sales Line" temporary)
    var
        CurrVoucherSalesLine: Record "NPR NpRv Sales Line";
        TempVoucherSalesLineErrorLbl: Label 'TempVoucherSalesLine must be temporary. This is a programming error.';
    begin
        if not TempVoucherSalesLine.IsTemporary then
            Error(TempVoucherSalesLineErrorLbl);

        TempVoucherSalesLine.Reset();
        if not TempVoucherSalesLine.IsEmpty then
            TempVoucherSalesLine.DeleteAll();

        CurrVoucherSalesLine.Reset();
        CurrVoucherSalesLine.SetRange("Sales Ticket No.", SalesTicketNo);
        CurrVoucherSalesLine.SetRange("Register No.", RegisterNo);
        if not CurrVoucherSalesLine.FindSet() then
            exit;

        repeat
            TempVoucherSalesLine.Init();
            TempVoucherSalesLine := CurrVoucherSalesLine;
            TempVoucherSalesLine.Insert();
        until CurrVoucherSalesLine.Next() = 0;
    end;

    internal procedure GetSalesPOSVoucherLinesAsSalesDocumentMagentoPaymentLines(SalesHeader: Record "Sales Header"; var TempVoucherSalesLine: Record "NPR NpRv Sales Line" temporary; var TempSalesLinePOS: Record "NPR POS Sale Line" temporary; var TempMagentoPaymentLine: Record "NPR Magento Payment Line" temporary)
    var
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        TempVoucherSalesLineErrorLbl: Label 'Parameter TempVoucherSalesLine must be temporary. This is a programming error.';
        TempSalesLinePOSErrorLbl: Label 'Parameter TempSalesLinePOS must be temporary. This is a programming error.';
        TempMagentoPaymentLineErrorLbl: Label 'Parameter TempMagentoPaymentLine must be temporary. This is a programming error.';
    begin
        if not TempVoucherSalesLine.IsTemporary then
            Error(TempVoucherSalesLineErrorLbl);

        if not TempSalesLinePOS.IsTemporary then
            Error(TempSalesLinePOSErrorLbl);

        if not TempMagentoPaymentLine.IsTemporary then
            Error(TempMagentoPaymentLineErrorLbl);

        TempVoucherSalesLine.Reset();
        if not TempVoucherSalesLine.FindSet() then
            exit;

        repeat
            if TempSalesLinePOS.GetBySystemId(TempVoucherSalesLine."Retail ID") then
                NpRvSalesDocMgt.CreateMagentoPaymentLines(SalesHeader, TempVoucherSalesLine, TempSalesLinePOS."Amount Including VAT", TempMagentoPaymentLine);
        until TempVoucherSalesLine.Next() = 0;
    end;


    internal procedure GetSalesDocumentVoucherLines(SalesHeader: Record "Sales Header"; var TempVoucherSalesLine: Record "NPR NpRv Sales Line" temporary)
    var
        VoucherSalesLine: Record "NPR NpRv Sales Line";
        TempVoucherSalesLineErrorLbl: Label 'Parameter TempVoucherSalesLine must be temporary. This is a programming error.';
    begin
        if not TempVoucherSalesLine.IsTemporary then
            Error(TempVoucherSalesLineErrorLbl);

        TempVoucherSalesLine.Reset();
        if not TempVoucherSalesLine.IsEmpty then
            TempVoucherSalesLine.DeleteAll();

        VoucherSalesLine.Reset();
        VoucherSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        VoucherSalesLine.SetRange("Document No.", SalesHeader."No.");
        VoucherSalesLine.SetRange("Document Source", VoucherSalesLine."Document Source"::"Payment Line");
        if not VoucherSalesLine.FindSet() then
            exit;

        repeat
            TempVoucherSalesLine.Init();
            TempVoucherSalesLine := VoucherSalesLine;
            TempVoucherSalesLine.Insert();
        until VoucherSalesLine.Next() = 0;

    end;

    internal procedure GetSalesDocumentMagentoPaymentLines(SalesHeader: Record "Sales Header"; var TempSalesDocumentMagentoPaymentLines: Record "NPR Magento Payment Line" temporary)
    var
        TempSalesDocumentMagentoPaymentLinesErrorLbl: Label 'Parameter TempSalesDocumentMagentoPaymentLines must be temporary. This is a programming error.';
        SalesDocumentMagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        if not TempSalesDocumentMagentoPaymentLines.IsTemporary then
            Error(TempSalesDocumentMagentoPaymentLinesErrorLbl);

        if not TempSalesDocumentMagentoPaymentLines.IsEmpty then
            TempSalesDocumentMagentoPaymentLines.DeleteAll();

        SalesDocumentMagentoPaymentLine.Reset();
        SalesDocumentMagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        SalesDocumentMagentoPaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesDocumentMagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
        if not SalesDocumentMagentoPaymentLine.FindSet() then
            exit;

        repeat
            TempSalesDocumentMagentoPaymentLines.Init();
            TempSalesDocumentMagentoPaymentLines := SalesDocumentMagentoPaymentLine;
            TempSalesDocumentMagentoPaymentLines.Insert()
        until SalesDocumentMagentoPaymentLine.Next() = 0;
    end;

    internal procedure CalcPaidAmountFromMagentoPaymentLineBuffer(var TempMagentoPaymentLine: Record "NPR Magento Payment Line" temporary) PaidAmount: Decimal;
    begin
        TempMagentoPaymentLine.Reset();
        TempMagentoPaymentLine.CalcSums(Amount);
        PaidAmount := TempMagentoPaymentLine.Amount;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGenerateTempVoucher(NpRvVoucherType: Record "NPR NpRv Voucher Type"; var TempNpRvVoucher: Record "NPR NpRv Voucher" temporary)
    begin
    end;
}
