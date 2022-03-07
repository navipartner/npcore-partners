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
        NpRvSalesLineReference: Record "NPR NpRv Sales Line Ref.";
        TempNpRvVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        LineNo: Integer;
    begin
        NpRvVoucherMgt.GenerateTempVoucher(NpRvVoucherType, TempNpRvVoucher);

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
        NpRvSalesLine.Description := TempNpRvVoucher.Description;
        NpRvSalesLine.Validate("Customer No.", SalesHeader."Sell-to Customer No.");
        if (not NpRvSalesLine."Send via Print") and (not NpRvSalesLine."Send via SMS") and (NpRvSalesLine."E-mail" <> '') then
            NpRvSalesLine."Send via E-mail" := true;
        NpRvSalesLine.Insert(true);

        NpRvSalesLineReference.Init();
        NpRvSalesLineReference.Id := CreateGuid();
        NpRvSalesLineReference."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLineReference."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
        NpRvSalesLineReference.Insert(true);

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
        SalesHeader.CalcFields("NPR Magento Payment Amount");
        if TotalAmtInclVat < SalesHeader."NPR Magento Payment Amount" then
            Error(Text003, TotalAmtInclVat, SalesHeader."NPR Magento Payment Amount");
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
        if VoucherEntry.FindFirst() then
            Voucher.Get(VoucherEntry."Voucher No.")
        else begin
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

    local procedure RedeemVoucher(SalesHeader: Record "Sales Header"; ReferenceNo: Text)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        Voucher: Record "NPR NpRv Voucher";
        LineNo: Decimal;
        Amount: Decimal;
        AmountNotGtZero: Label 'The remaining amount to be paid on the Sales Header is not greater than 0';
    begin
        Voucher.SetRange("Reference No.", ReferenceNo);
        if not Voucher.FindFirst() then
            Error(VoucherNotFoundErr, ReferenceNo);

        Voucher.CalcFields("In-use Quantity", Amount);
        if Voucher."In-use Quantity" > 0 then
            Error(VoucherInUseErr);

        // Default to the remaining amount to be paid
        SalesHeader.CalcFields("NPR Magento Payment Amount");
        Amount := GetTotalAmtInclVat(SalesHeader) - SalesHeader."NPR Magento Payment Amount";

        if Amount <= 0 then
            Error(AmountNotGtZero);

        // Set to voucher's full amount if the total amount isn't available
        if Amount > Voucher.Amount then
            Amount := Voucher.Amount;

        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        MagentoPaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        MagentoPaymentLine.SetRange("Document No.", SalesHeader."No.");
        if MagentoPaymentLine.FindLast() then;
        LineNo := MagentoPaymentLine."Line No." + 10000;

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
}
