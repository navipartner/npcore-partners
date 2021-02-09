codeunit 6151410 "NPR Magento Gift Voucher Mgt."
{
    var
        Text000: Label 'Gift Voucher Bitmap is missing in Magento Setup';
        Text002: Label 'Gift Voucher %1 has already been cashed on date %2';
        Text003: Label 'The Payment Amount exceeds the amount on Gift Voucher %1\  - Payment Amount: %3\ - Gift Voucher Amount: %2';
        Text004: Label 'Credit Voucher %1 has already been cashed on date %2';
        Text005: Label 'The Payment Amount exceeds the amount on Credit Voucher %1\  - Payment Amount: %3\ - Credit Voucher Amount: %2';
        Text006: Label 'Invalid Web Code!\No Giftvoucher or Creditvoucher with Web Code %1';
        Text007: Label 'Orders paid with Gift Voucher and/or Credit Voucher may not be partially invoiced nor adjusted.';

    local procedure ActivateGiftVoucher(var GiftVoucher: Record "NPR Gift Voucher")
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        GiftVoucher.Status := GiftVoucher.Status::Open;
        GiftVoucher.Modify(true);
    end;

    procedure ActivateCreditVoucher(var CreditVoucher: Record "NPR Credit Voucher")
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;
        CreditVoucher.Status := CreditVoucher.Status::Open;
        CreditVoucher.Modify(true);
    end;

    procedure DeactivateVouchers(ExternalReferenceNo: Code[30]; ExternalVoucherNo: Code[10])
    var
        MagentoSetup: Record "NPR Magento Setup";
        GiftVoucher: Record "NPR Gift Voucher";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        GiftVoucher.SetRange("External Reference No.", ExternalReferenceNo);
        GiftVoucher.SetRange("External Gift Voucher No.", ExternalVoucherNo);
        if GiftVoucher.FindFirst then begin
            GiftVoucher.Status := GiftVoucher.Status::Cashed;
            GiftVoucher.Modify(true);
        end;
    end;

    procedure ActivateAndMailGiftVouchers(ExternalOrderNo: Code[20]; EMail: Text[250])
    var
        CreditVoucher: Record "NPR Credit Voucher";
        GiftVoucher: Record "NPR Gift Voucher";
        TempCreditVoucher: Record "NPR Credit Voucher" temporary;
        MagentoSetup: Record "NPR Magento Setup";
        TempGiftVoucher: Record "NPR Gift Voucher" temporary;
    begin
        if ExternalOrderNo = '' then
            exit;
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        if FindGiftVouchers(ExternalOrderNo, TempGiftVoucher) then
            repeat
                GiftVoucher.Get(TempGiftVoucher."No.");
                ActivateGiftVoucher(GiftVoucher);
                Commit;
                EmailGiftVoucher(GiftVoucher, EMail);
                Commit;
            until TempGiftVoucher.Next = 0;

        if FindCreditVouchers(ExternalOrderNo, TempCreditVoucher) then
            repeat
                CreditVoucher.Get(TempCreditVoucher."No.");
                ActivateCreditVoucher(CreditVoucher);
                Commit;
                EmailCreditVoucher(CreditVoucher, EMail);
                Commit;
            until TempCreditVoucher.Next = 0;
    end;

    local procedure FindGiftVouchers(ExternalOrderNo: Code[50]; var TempGiftVoucher: Record "NPR Gift Voucher" temporary): Boolean
    var
        GiftVoucher: Record "NPR Gift Voucher";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempGiftVoucher);
        if not RecRef.IsTemporary then
            exit(false);
        TempGiftVoucher.DeleteAll;

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("NPR External Order No.", ExternalOrderNo);
        if SalesHeader.FindSet then
            repeat
                GiftVoucher.SetRange("Sales Order No.", SalesHeader."No.");
                GiftVoucher.SetRange(Status, GiftVoucher.Status::Cancelled);
                GiftVoucher.SetFilter(Amount, '>%1', 0);
                if GiftVoucher.FindSet then
                    repeat
                        if not TempGiftVoucher.Get(GiftVoucher."No.") then begin
                            TempGiftVoucher.Init;
                            TempGiftVoucher := GiftVoucher;
                            TempGiftVoucher.Insert;
                        end;
                    until GiftVoucher.Next = 0;
            until SalesHeader.Next = 0;

        SalesInvHeader.SetRange("NPR External Order No.", ExternalOrderNo);
        SalesInvHeader.SetFilter("Order No.", '<>%1', '');
        if SalesInvHeader.FindSet then
            repeat
                GiftVoucher.SetRange("Sales Order No.", SalesInvHeader."Order No.");
                GiftVoucher.SetRange(Status, GiftVoucher.Status::Cancelled);
                GiftVoucher.SetFilter(Amount, '>%1', 0);
                if GiftVoucher.FindSet then
                    repeat
                        if not TempGiftVoucher.Get(GiftVoucher."No.") then begin
                            TempGiftVoucher.Init;
                            TempGiftVoucher := GiftVoucher;
                            TempGiftVoucher.Insert;
                        end;
                    until GiftVoucher.Next = 0;
            until SalesInvHeader.Next = 0;
        exit(TempGiftVoucher.FindSet);
    end;

    local procedure FindCreditVouchers(ExternalOrderNo: Code[50]; var TempCreditVoucher: Record "NPR Credit Voucher" temporary): Boolean
    var
        CreditVoucher: Record "NPR Credit Voucher";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempCreditVoucher);
        if not RecRef.IsTemporary then
            exit(false);
        TempCreditVoucher.DeleteAll;

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("NPR External Order No.", ExternalOrderNo);
        if SalesHeader.FindSet then
            repeat
                CreditVoucher.SetRange("Sales Order No.", SalesHeader."No.");
                CreditVoucher.SetRange(Status, CreditVoucher.Status::Cancelled);
                CreditVoucher.SetFilter(Amount, '>%1', 0);
                if CreditVoucher.FindSet then
                    repeat
                        if not TempCreditVoucher.Get(CreditVoucher."No.") then begin
                            TempCreditVoucher.Init;
                            TempCreditVoucher := CreditVoucher;
                            TempCreditVoucher.Insert;
                        end;
                    until CreditVoucher.Next = 0;
            until SalesHeader.Next = 0;

        SalesInvHeader.SetRange("NPR External Order No.", ExternalOrderNo);
        SalesInvHeader.SetFilter("Order No.", '<>%1', '');
        if SalesInvHeader.FindSet then
            repeat
                CreditVoucher.SetRange("Sales Order No.", SalesInvHeader."Order No.");
                CreditVoucher.SetRange(Status, CreditVoucher.Status::Cancelled);
                CreditVoucher.SetFilter(Amount, '>%1', 0);
                if CreditVoucher.FindSet then
                    repeat
                        if not TempCreditVoucher.Get(CreditVoucher."No.") then begin
                            TempCreditVoucher.Init;
                            TempCreditVoucher := CreditVoucher;
                            TempCreditVoucher.Insert;
                        end;
                    until CreditVoucher.Next = 0;
            until SalesInvHeader.Next = 0;
        exit(TempCreditVoucher.FindSet);
    end;

    #region Posting

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'OnCheckPayment', '', true, true)]
    local procedure OnCheckPayment(SalesHeader: Record "Sales Header")
    begin
        if SalesHeader.IsTemporary then
            exit;

        CheckVoucherPayment(SalesHeader);
    end;

    local procedure CheckCreditVoucherPayment(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        CreditVoucher: Record "NPR Credit Voucher";
    begin
        CreditVoucher.SetRange("External Reference No.", PaymentLine."No.");
        if not CreditVoucher.FindFirst then
            exit(false);
        if CreditVoucher.Status = CreditVoucher.Status::Cashed then
            Error(Text004, CreditVoucher."No.", CreditVoucher."Cashed Date");

        if CreditVoucher.Amount < PaymentLine.Amount then
            Error(Text005, CreditVoucher."No.", CreditVoucher.Amount, PaymentLine.Amount);

        exit(true);
    end;

    local procedure CheckGiftVoucherPayment(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        GiftVoucher: Record "NPR Gift Voucher";
    begin
        GiftVoucher.SetRange("External Reference No.", PaymentLine."No.");
        if not GiftVoucher.FindFirst then
            exit(false);

        if GiftVoucher.Status = GiftVoucher.Status::Cashed then
            Error(Text002, GiftVoucher."No.", GiftVoucher."Cashed Date");

        if GiftVoucher.Amount < PaymentLine.Amount then
            Error(Text003, GiftVoucher."No.", GiftVoucher.Amount, PaymentLine.Amount);

        exit(true);
    end;

    procedure CheckVoucherPayment(var SalesHeader: Record "Sales Header")
    var
        MagentoSetup: Record "NPR Magento Setup";
        PaymentLine: Record "NPR Magento Payment Line";
        VoucherFound: Boolean;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
        PaymentLine.SetFilter("Source Table No.", '%1|%2', DATABASE::"NPR Credit Voucher", DATABASE::"NPR Gift Voucher");
        PaymentLine.SetFilter(Amount, '>%1', 0);
        if not PaymentLine.FindSet then
            exit;

        repeat
            case PaymentLine."Source Table No." of
                DATABASE::"NPR Credit Voucher":
                    VoucherFound := CheckCreditVoucherPayment(PaymentLine);
                DATABASE::"NPR Gift Voucher":
                    VoucherFound := CheckGiftVoucherPayment(PaymentLine);
                else
                    VoucherFound := false;
            end;
            if not VoucherFound then
                Error(StrSubstNo(Text006, PaymentLine."No."));
        until PaymentLine.Next = 0;

        PaymentLine.Reset;
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter("Account No.", '<>%1', '');
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
        if PaymentLine.FindFirst and (SalesHeader."NPR Magento Payment Amount" <> GetTotalAmountInclVat(SalesHeader)) then
            Error(Text007);
    end;

    local procedure GetTotalAmountInclVat(var SalesHeader: Record "Sales Header") TotalAmountInclVAT: Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        Clear(TempSalesLine);
        Clear(SalesPost);
        TempVATAmountLine.DeleteAll;
        TempSalesLine.DeleteAll;
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 1);
        TempSalesLine.CalcVATAmountLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TotalAmountInclVAT := TempVATAmountLine.GetTotalAmountInclVAT();
        exit(TotalAmountInclVAT);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'OnBeforePostPaymentLine', '', true, true)]
    local procedure OnBeforePostPaymentLine(var PaymentLine: Record "NPR Magento Payment Line")
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if PaymentLine.IsTemporary then
            exit;

        if PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header" then
            exit;
        if PaymentLine."Payment Type" <> PaymentLine."Payment Type"::Voucher then
            exit;
        if not SalesInvHeader.Get(PaymentLine."Document No.") then
            exit;

        PostVoucherPayment(PaymentLine, SalesInvHeader);
    end;

    procedure PostVoucherPayment(PaymentLine: Record "NPR Magento Payment Line"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CreditVoucher: Record "NPR Credit Voucher";
        GiftVoucher: Record "NPR Gift Voucher";
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        if not (PaymentLine.Find and SalesInvoiceHeader.Find and (PaymentLine."Document Table No." = DATABASE::"Sales Invoice Header") and (PaymentLine."Payment Type" = PaymentLine."Payment Type"::Voucher)
                and (PaymentLine."Document No." = SalesInvoiceHeader."No."))
                 then
            exit;

        if PaymentLine.Amount <= 0 then
            exit;

        GiftVoucher.LockTable;
        GiftVoucher.SetRange("External Reference No.", PaymentLine."No.");
        if GiftVoucher.FindFirst then begin
            GiftVoucher.Status := GiftVoucher.Status::Cashed;
            GiftVoucher."Cashed Date" := SalesInvoiceHeader."Posting Date";
            GiftVoucher."Cashed Salesperson" := SalesInvoiceHeader."Salesperson Code";
            GiftVoucher."Cashed in Global Dim 1 Code" := SalesInvoiceHeader."Shortcut Dimension 1 Code";
            GiftVoucher."Cashed in Location Code" := SalesInvoiceHeader."Location Code";
            GiftVoucher."Cashed Date" := SalesInvoiceHeader."Posting Date";
            GiftVoucher."Last Date Modified" := Today;
            GiftVoucher.Modify;
            exit;
        end;

        CreditVoucher.LockTable;
        CreditVoucher.SetRange("External Reference No.", PaymentLine."No.");
        if CreditVoucher.FindFirst then begin
            CreditVoucher.Status := CreditVoucher.Status::Cashed;
            CreditVoucher."Cashed Date" := SalesInvoiceHeader."Posting Date";
            CreditVoucher."Cashed Salesperson" := SalesInvoiceHeader."Salesperson Code";
            CreditVoucher."Cashed in Global Dim 1 Code" := SalesInvoiceHeader."Shortcut Dimension 1 Code";
            CreditVoucher."Cashed in Location Code" := SalesInvoiceHeader."Location Code";
            CreditVoucher."Cashed Date" := SalesInvoiceHeader."Posting Date";
            CreditVoucher."Last Date Modified" := Today;
            CreditVoucher.Modify;
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Pmt. Mgt.", 'OnAfterPostMagentoPayment', '', true, true)]
    local procedure OnAfterPostMagentoPayment(SalesInvHeader: Record "Sales Invoice Header")
    var
        Customer: Record Customer;
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if SalesInvHeader.IsTemporary then
            exit;
        if SalesInvHeader."NPR External Order No." = '' then
            exit;
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit;
        if not MagentoSetup."Gift Voucher Enabled" then
            exit;
        if MagentoSetup."Gift Voucher Activation" <> MagentoSetup."Gift Voucher Activation"::OnPosting then
            exit;

        if Customer.Get(SalesInvHeader."Sell-to Customer No.") then;
        ActivateAndMailGiftVouchers(SalesInvHeader."NPR External Order No.", Customer."E-Mail");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnCancelMagentoOrder(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        CreditVoucher: Record "NPR Credit Voucher";
        GiftVoucher: Record "NPR Gift Voucher";
        PaymentLine: Record "NPR Magento Payment Line";
        DataLogMgt: Codeunit "NPR Data Log Management";
        RecRef: RecordRef;
    begin
        if not RunTrigger then
            exit;
        if Rec.IsTemporary then
            exit;

        if Rec."NPR External Order No." = '' then
            exit;
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;

        CreditVoucher.SetRange("Sales Order No.", Rec."No.");
        CreditVoucher.SetRange(Status, CreditVoucher.Status::Open);
        CreditVoucher.SetFilter(Amount, '>%1', 0);
        if CreditVoucher.FindFirst then
            CreditVoucher.ModifyAll(Status, CreditVoucher.Status::Cancelled, true);

        GiftVoucher.SetRange("Sales Order No.", Rec."No.");
        GiftVoucher.SetRange(Status, GiftVoucher.Status::Open);
        GiftVoucher.SetFilter(Amount, '>%1', 0);
        if GiftVoucher.FindFirst then
            GiftVoucher.ModifyAll(Status, GiftVoucher.Status::Cancelled, true);

        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", Rec."Document Type");
        PaymentLine.SetRange("Document No.", Rec."No.");
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
        PaymentLine.SetFilter("Source Table No.", '%1|%2', DATABASE::"NPR Credit Voucher", DATABASE::"NPR Gift Voucher");
        if PaymentLine.FindSet then
            repeat
                case PaymentLine."Source Table No." of
                    DATABASE::"NPR Credit Voucher":
                        begin
                            Clear(CreditVoucher);
                            CreditVoucher.SetRange("External Reference No.", PaymentLine."No.");
                            if CreditVoucher.FindFirst then begin
                                RecRef.GetTable(CreditVoucher);
                                DataLogMgt.OnDatabaseModify(RecRef);
                            end;
                        end;
                    DATABASE::"NPR Gift Voucher":
                        begin
                            Clear(GiftVoucher);
                            GiftVoucher.SetRange("External Reference No.", PaymentLine."No.");
                            if GiftVoucher.FindFirst then begin
                                RecRef.GetTable(GiftVoucher);
                                DataLogMgt.OnDatabaseModify(RecRef);
                            end;
                        end;
                end;
            until PaymentLine.Next = 0;
    end;
    #endregion

    #region ExternalReferenceNo

    procedure GenerateExternalReferenceNo(GeneratePattern: Text[30]; VoucherNo: Code[20]) ExternalReferenceNo: Code[30]
    var
        MagentoSetup: Record "NPR Magento Setup";
        CodePattern: Text[1024];
        Pattern: Text[1024];
        Position: Integer;
        CodeCount: Integer;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;
        if GeneratePattern = '' then
            exit;

        repeat
            ExternalReferenceNo := '';
            Sleep(1);
            Randomize;
            Pattern := GeneratePattern;
            while Pattern <> '' do begin
                Position := StrPos(Pattern, '[');
                if Position = 0 then begin
                    ExternalReferenceNo := ExternalReferenceNo + Pattern;
                    Pattern := '';
                end else begin
                    if Position > 1 then
                        ExternalReferenceNo := ExternalReferenceNo + CopyStr(Pattern, 1, Position - 1);
                    Pattern := DelStr(Pattern, 1, Position);

                    Position := StrPos(Pattern, ']');
                    if Position <= 1 then
                        Error(Text000, Pattern);
                    CodePattern := CopyStr(Pattern, 1, Position - 1);
                    Pattern := DelStr(Pattern, 1, Position);

                    CodeCount := 1;
                    Position := StrPos(CodePattern, '*');
                    if (Position > 1) and (Position < StrLen(CodePattern)) then begin
                        if not Evaluate(CodeCount, CopyStr(CodePattern, Position + 1)) then
                            Error(Text000, CodePattern);
                        CodePattern := CopyStr(CodePattern, 1, Position - 1);
                    end;
                    for Position := 1 to CodeCount do begin
                        if CodePattern = 'S' then
                            ExternalReferenceNo := ExternalReferenceNo + VoucherNo
                        else
                            ExternalReferenceNo := ExternalReferenceNo + GenerateRandom(CodePattern);
                    end;
                end;
            end;
        until TestExternalReferenceNo(ExternalReferenceNo);
    end;

    procedure TestExternalReferenceNo(ExternalReferenceNo: Code[30]): Boolean
    var
        CreditVoucher: Record "NPR Credit Voucher";
        GiftVoucher: Record "NPR Gift Voucher";
    begin
        if ExternalReferenceNo = '' then
            exit(false);

        GiftVoucher.SetCurrentKey("External Reference No.");
        GiftVoucher.SetRange("External Reference No.", ExternalReferenceNo);
        CreditVoucher.SetCurrentKey("External Reference No.");
        CreditVoucher.SetRange("External Reference No.", ExternalReferenceNo);
        exit(not (CreditVoucher.FindFirst or GiftVoucher.FindFirst));
    end;

    local procedure GenerateRandom(Pattern: Code[2]) Random: Code[1]
    var
        Number: Integer;
        Char: Char;
    begin
        Number := GetRandom;
        case Pattern of
            'N':
                Random := Format(Number mod 10);
            'A':
                Char := (Number mod 25) + 65;
            'AN':
                if (GetRandom mod 35) < 10 then
                    Random := Format(Number mod 10)
                else
                    Char := (Number mod 25) + 65;
        end;

        if Random = '' then
            exit(UpperCase(Format(Char)));
    end;

    local procedure GetRandom(): Integer
    begin
        exit(Random(9999));
    end;
    #endregion

    procedure EmailGiftVoucher(var GiftVoucher: Record "NPR Gift Voucher"; EMail: Text[250])
    var
        MagentoSetup: Record "NPR Magento Setup";
        EmailManagement: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        RecRef.GetTable(GiftVoucher);
        EmailManagement.SendReport(MagentoSetup."Gift Voucher Report", RecRef, EMail, true);
    end;

    procedure EmailCreditVoucher(var CreditVoucher: Record "NPR Credit Voucher"; EMail: Text[250])
    var
        MagentoSetup: Record "NPR Magento Setup";
        EmailManagement: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;
        RecRef.GetTable(CreditVoucher);
        EmailManagement.SendReport(MagentoSetup."Credit Voucher Report", RecRef, EMail, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Credit Voucher", 'OnBeforeInsertEvent', '', true, true)]
    local procedure CreditVoucherOnInsert(var Rec: Record "NPR Credit Voucher"; RunTrigger: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not RunTrigger then
            exit;
        if IsTemporary(Rec) then
            exit;
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        if Rec."Expire Date" = 0D then
            Rec."Expire Date" := CalcDate(MagentoSetup."Credit Voucher Valid Period", Today);
        if (Rec."External Reference No." = '') and (MagentoSetup.Get) and (MagentoSetup."Credit Voucher Code Pattern" <> '') then
            Rec."External Reference No." := GenerateExternalReferenceNo(MagentoSetup."Credit Voucher Code Pattern", Rec."Voucher No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Credit Voucher", 'OnBeforeModifyEvent', '', true, true)]
    local procedure CreditVoucherOnModify(var Rec: Record "NPR Credit Voucher"; var xRec: Record "NPR Credit Voucher"; RunTrigger: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not RunTrigger then
            exit;
        if IsTemporary(Rec) then
            exit;
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        if (Rec."Expire Date" = 0D) and (xRec."Expire Date" <> Rec."Expire Date") then
            Rec."Expire Date" := CalcDate(MagentoSetup."Credit Voucher Valid Period", Today);
        if (Rec."External Reference No." = '') and (MagentoSetup.Get) and (MagentoSetup."Credit Voucher Code Pattern" <> '') then
            Rec."External Reference No." := GenerateExternalReferenceNo(MagentoSetup."Credit Voucher Code Pattern", Rec."Voucher No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Gift Voucher", 'OnBeforeInsertEvent', '', true, true)]
    local procedure GiftVoucherOnInsert(var Rec: Record "NPR Gift Voucher"; RunTrigger: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not RunTrigger then
            exit;
        if IsTemporary(Rec) then
            exit;
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        if Rec."Expire Date" = 0D then begin
            MagentoSetup.TestField("Gift Voucher Valid Period");
            Rec."Expire Date" := CalcDate(MagentoSetup."Gift Voucher Valid Period", Today);
        end;
        if (Rec."External Reference No." = '') and (MagentoSetup.Get) and (MagentoSetup."Gift Voucher Code Pattern" <> '') then
            Rec."External Reference No." := GenerateExternalReferenceNo(MagentoSetup."Gift Voucher Code Pattern", Rec."Voucher No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Gift Voucher", 'OnBeforeModifyEvent', '', true, true)]
    local procedure GiftVoucherOnModify(var Rec: Record "NPR Gift Voucher"; var xRec: Record "NPR Gift Voucher"; RunTrigger: Boolean)
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not RunTrigger then
            exit;
        if IsTemporary(Rec) then
            exit;
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        if (Rec."Expire Date" = 0D) and (xRec."Expire Date" <> Rec."Expire Date") then begin
            MagentoSetup.TestField("Gift Voucher Valid Period");
            Rec."Expire Date" := CalcDate(MagentoSetup."Gift Voucher Valid Period", Today);
        end;
        if (Rec."External Reference No." = '') and (MagentoSetup.Get) and (MagentoSetup."Gift Voucher Code Pattern" <> '') then
            Rec."External Reference No." := GenerateExternalReferenceNo(MagentoSetup."Gift Voucher Code Pattern", Rec."Voucher No.");
    end;

    local procedure IsTemporary(VariantRec: Variant): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(VariantRec);
        exit(RecRef.IsTemporary);
    end;
}