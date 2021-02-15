codeunit 6151024 "NPR NpRv Sales Doc. Mgt."
{
    var
        Text002: Label 'Retail Voucher Payment Amount %1 is higher than Remaining Amount %2 on Retail Voucher %3';
        Text003: Label 'Order Amount %1 is lower than Payment Amount %2.\Issue Return Voucher on remaining amount.';
        Text004: Label 'Voucher %1 issued on new Sales Line';
        Text005: Label 'Voucher Payment Amount %1 exceeds Voucher Amount %2';
        Text006: Label 'Voucher %1 is already in use';

    procedure SelectVoucherType(var NpRvVoucherType: Record "NPR NpRv Voucher Type"): Boolean
    var
        TempNpRvVoucherType: Record "NPR NpRv Voucher Type" temporary;
    begin
        Clear(NpRvVoucherType);
        FindVoucherTypes(TempNpRvVoucherType);
        if TempNpRvVoucherType.FindLast then begin
            NpRvVoucherType.Get(TempNpRvVoucherType.Code);
            TempNpRvVoucherType.FindFirst;
            if NpRvVoucherType.Code = TempNpRvVoucherType.Code then
                exit(true);
        end;
        if PAGE.RunModal(0, TempNpRvVoucherType) <> ACTION::LookupOK then
            exit(false);

        exit(NpRvVoucherType.Get(TempNpRvVoucherType.Code));
    end;

    procedure IssueVoucher(SalesHeader: Record "Sales Header"; NpRvVoucherType: Record "NPR NpRv Voucher Type") VoucherNo: Text
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
        if SalesLine.FindLast then;
        LineNo := SalesLine."Line No." + 10000;

        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", TempNpRvVoucher."Account No.");
        SalesLine.Description := TempNpRvVoucher.Description;
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);

        NpRvSalesLine.Init;
        NpRvSalesLine.Id := CreateGuid;
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

        NpRvSalesLineReference.Init;
        NpRvSalesLineReference.Id := CreateGuid;
        NpRvSalesLineReference."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLineReference."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLineReference."Sales Line Id" := NpRvSalesLine.Id;
        NpRvSalesLineReference.Insert(true);

        exit(TempNpRvVoucher."No.");
    end;

    procedure InsertPayment(Element: XmlElement; var SalesHeader: Record "Sales Header"; var NpRvVoucher: Record "NPR NpRv Voucher"; Amount: Decimal): Boolean
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvGlobalVoucherWebservice: Codeunit "NPR NpRv Global Voucher WS";
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
        if not NpRvSalesLine.FindFirst then begin
            if NpRvVoucher.CalcInUseQty() > 0 then
                Error(Text006, NpRvVoucher."Reference No.");

            NpRvSalesLine.Init;
            NpRvSalesLine.Id := CreateGuid;
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


        LineNo += 10000;
        MagentoPaymentLine.Init;
        MagentoPaymentLine."Document Table No." := DATABASE::"Sales Header";
        MagentoPaymentLine."Document Type" := SalesHeader."Document Type";
        MagentoPaymentLine."Document No." := SalesHeader."No.";
        MagentoPaymentLine."Line No." := LineNo;
        MagentoPaymentLine."Payment Type" := MagentoPaymentLine."Payment Type"::Voucher;
        MagentoPaymentLine.Description := NpRvVoucher.Description;
        MagentoPaymentLine."Account No." := NpRvVoucher."Account No.";
        MagentoPaymentLine."No." := NpRvVoucher."Reference No.";
        MagentoPaymentLine."Posting Date" := SalesHeader."Posting Date";
        MagentoPaymentLine."Source Table No." := DATABASE::"NPR NpRv Voucher";
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
        if NpRvSalesLine.FindFirst then
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
        if Rec."Source Table No." <> DATABASE::"NPR NpRv Voucher" then
            exit;

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", Rec."Document Type");
        NpRvSalesLine.SetRange("Document No.", Rec."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", Rec."Line No.");
        if NpRvSalesLine.FindFirst then
            NpRvSalesLine.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', true, true)]
    local procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        TotalAmtInclVat: Decimal;
    begin
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange(Posted, false);
        if NpRvSalesLine.IsEmpty then
            exit;

        NpRvSalesLine.FindSet;
        repeat
            ApplyPayment(SalesHeader, NpRvSalesLine);
        until NpRvSalesLine.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, true)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        TotalAmtInclVat: Decimal;
    begin
        if not SalesHeader.Invoice then
            exit;

        OnBeforeReleaseSalesDoc(SalesHeader);

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if NpRvSalesLine.IsEmpty then
            exit;

        NpRvSalesLine.FindSet;
        repeat
            MagentoPaymentLine.Get(DATABASE::"Sales Header", NpRvSalesLine."Document Type", NpRvSalesLine."Document No.", NpRvSalesLine."Document Line No.");
            NpRvVoucher.Get(NpRvSalesLine."Voucher No.");
            NpRvVoucher.TestField("Reference No.", NpRvSalesLine."Reference No.");
            NpRvVoucher.CalcFields(Amount);
            if NpRvVoucher.Amount < MagentoPaymentLine.Amount then
                Error(Text002, MagentoPaymentLine.Amount, NpRvVoucher.Amount, NpRvVoucher."Reference No.");
        until NpRvSalesLine.Next = 0;

        TotalAmtInclVat := GetTotalAmtInclVat(SalesHeader);
        SalesHeader.CalcFields("NPR Magento Payment Amount");
        if TotalAmtInclVat < SalesHeader."NPR Magento Payment Amount" then
            Error(Text003, TotalAmtInclVat, SalesHeader."NPR Magento Payment Amount");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostCommitSalesDoc', '', true, false)]
    local procedure OnBeforePostCommitSalesDoc(var SalesHeader: Record "Sales Header")
    var
        NoSeriesLine: Record "No. Series Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PostingNo: Code[20];
    begin
        if not SalesHeader.Invoice and
           not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"])
        then
            exit;

        NpRvSalesLine.SetFilter("Document Source", '%1|%2',
          NpRvSalesLine."Document Source"::"Sales Document", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        if NpRvSalesLine.IsEmpty then
            exit;

        PostingNo := SalesHeader."Posting No.";
        if PostingNo = '' then begin
            NoSeriesMgt.SetNoSeriesLineFilter(NoSeriesLine, SalesHeader."Posting No. Series", 0D);
            NoSeriesLine.FindLast;
            PostingNo := NoSeriesLine."Last No. Used";
        end;
        NpRvSalesLine.ModifyAll("Posting No.", PostingNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLines', '', true, false)]
    local procedure OnAfterPostSalesLines(var SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        if not SalesHeader.Invoice and
           not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"])
        then
            exit;

        NpRvSalesLine.SetFilter("Document Source", '%1|%2',
          NpRvSalesLine."Document Source"::"Sales Document", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        if NpRvSalesLine.IsEmpty then
            exit;

        IssueNewVouchers(SalesHeader);
        PostVoucherPayments(SalesHeader);

        NpRvSalesLine.ModifyAll("Posting No.", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20])
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherEntry: Record "NPR NpRv Voucher Entry";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if not SalesHeader.Invoice then
            exit;
        if SalesInvHdrNo = '' then
            exit;
        if not SalesInvHeader.Get(SalesInvHdrNo) then
            exit;

        NpRvVoucherEntry.SetFilter("Entry Type", '%1|%2|%3',
          NpRvVoucherEntry."Entry Type"::"Issue Voucher", NpRvVoucherEntry."Entry Type"::Payment, NpRvVoucherEntry."Entry Type"::"Top-up");
        NpRvVoucherEntry.SetRange("Document Type", NpRvVoucherEntry."Document Type"::Invoice);
        NpRvVoucherEntry.SetRange("Document No.", SalesInvHeader."No.");
        if not NpRvVoucherEntry.FindSet then
            exit;

        repeat
            if NpRvVoucher.Get(NpRvVoucherEntry."Voucher No.") then
                SendVoucher(NpRvVoucher);
        until NpRvVoucherEntry.Next = 0;
    end;

    local procedure IssueNewVouchers(SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvSalesLine.SetFilter("Document Source", '%1|%2',
          NpRvSalesLine."Document Source"::"Sales Document", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetFilter(Type, '%1|%2|%3', NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up", NpRvSalesLine.Type::"Partner Issue Voucher");
        if NpRvSalesLine.FindSet then
            repeat
                NpRvVoucherMgt.IssueVouchers(NpRvSalesLine);
            until NpRvSalesLine.Next = 0;
    end;

    local procedure PostVoucherPayments(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if NpRvSalesLine.FindSet then
            repeat
                NpRvVoucherMgt.PostPayment(NpRvSalesLine);
            until NpRvSalesLine.Next = 0;
    end;

    local procedure SendOpenVouchers(SalesInvHeader: Record "Sales Invoice Header")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        MagentoPaymentLine.SetRange("Document Table No.", DATABASE::"Sales Invoice Header");
        MagentoPaymentLine.SetRange("Document No.", SalesInvHeader."No.");
        MagentoPaymentLine.SetRange("Payment Type", MagentoPaymentLine."Payment Type"::Voucher);
        MagentoPaymentLine.SetRange("Source Table No.", DATABASE::"NPR NpRv Voucher");
        if MagentoPaymentLine.IsEmpty then
            exit;

        Commit;
        MagentoPaymentLine.FindSet;
        repeat
            if NpRvVoucher.Get(MagentoPaymentLine."Source No.") then
                SendVoucher(NpRvVoucher);
        until MagentoPaymentLine.Next = 0;
    end;

    procedure IssueVoucherAction(SalesHeader: Record "Sales Header")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        TotalAmtInclVat: Decimal;
        VoucherNo: Text;
    begin
        if not SelectVoucherType(NpRvVoucherType) then
            exit;

        VoucherNo := IssueVoucher(SalesHeader, NpRvVoucherType);
        Message(Text004, VoucherNo);
    end;

    procedure ShowRelatedVouchersAction(SalesHeader: Record "Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetFilter("Document Source", '%1|%2',
          NpRvSalesLine."Document Source"::"Sales Document", NpRvSalesLine."Document Source"::"Payment Line");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        PAGE.Run(0, NpRvSalesLine);
    end;

    local procedure GetTotalAmtInclVat(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLineTemp: Record "Sales Line" temporary;
        VATAmountLineTemp: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.GetSalesLines(SalesHeader, SalesLineTemp, 0);
        SalesLineTemp.CalcVATAmountLines(0, SalesHeader, SalesLineTemp, VATAmountLineTemp);
        SalesLineTemp.UpdateVATOnLines(0, SalesHeader, SalesLineTemp, VATAmountLineTemp);
        exit(VATAmountLineTemp.GetTotalAmountInclVAT());
    end;

    local procedure FindVoucherTypes(var TempNpRvVoucherType: Record "NPR NpRv Voucher Type" temporary)
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvReturnVoucherType: Record "NPR NpRv Ret. Vouch. Type";
    begin
        if NpRvVoucherType.FindSet then
            repeat
                NpRvReturnVoucherType.SetRange("Return Voucher Type", NpRvVoucherType.Code);
                if NpRvReturnVoucherType.IsEmpty and not TempNpRvVoucherType.Get(NpRvVoucherType.Code) then begin
                    TempNpRvVoucherType.Init;
                    TempNpRvVoucherType := NpRvVoucherType;
                    TempNpRvVoucherType.Insert;
                end;
            until NpRvVoucherType.Next = 0;
    end;

    procedure SendVoucher(NpRvVoucher: Record "NPR NpRv Voucher")
    var
        LastErrorText: Text;
    begin
        NpRvVoucher.CalcFields(Amount);
        if NpRvVoucher.Amount > 0 then begin
            ClearLastError();
            if not Codeunit.Run(codeunit::"NPR NpRv Voucher Mgt.", NpRvVoucher) then begin
                LastErrorText := GetLastErrorText;
                if LastErrorText <> '' then
                    Message(LastErrorText);
            end;
            Commit();
        end;
    end;
}