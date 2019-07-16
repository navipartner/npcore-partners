codeunit 6151410 "Magento Gift Voucher Mgt."
{
    // MAG1.03/TS  /20150202  CASE 201682 Refactored Object
    // MAG1.04/TS  /20150206  CASE 201682 Adding Gift Voucher Functions
    // MAG1.17/MHA /20150615  CASE 216142 Magento related setup moved to Magento Setup and Added Print functions
    // MAG1.19/TR  /20150721  CASE 218821 Currency Code added to both Credit Voucher and Gift Voucher.
    // MAG1.19/MHA /20150804  CASE 219761 Gift Voucher functions should only be executed if Magento Gift Voucher is enabled
    // MAG1.20/TR  /20150805  CASE 219911 Function call corrected from CreditVoucherReport to GiftVoucherReport
    // MAG1.20/TR  /20150813  CASE 218819 Function ActivateAndMailGiftVouchersSalesOrder added.
    //   - Parameters changed in ActivateGiftVouchers,ActivateCreditVouchers,EmailGiftVouchers and EmailCreditVouchers from Sales Invoice Header to "Order No." (code value).
    //   - All Activate functions use the variable code instead of SalesInvoiceHeader."Order No."
    //   - ActivateAndMailGiftVouchers call the activate and email functions with order no. instead of sales invoice header.
    // MAG1.21/MHA /20150722  CASE 227150 Embedded String functions
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA /20170106  CASE 257315 Corrected TempBlob reference for DrawBarcode in GiftVoucherToTempBlob() and CreditVoucherToTempBlob()
    // MAG2.09/MHA /20171211  CASE 292576 Added "Voucher Number Format" in GiftVoucherToTempBlob() and CreditVoucherToTempBlob()
    // MAG2.17/MHA /20181122  CASE 302179 Magento Integration
    // MAG2.22/MHA /20190617  CASE 357825 Resolution should be preserved after resize


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Gift Voucher Bitmap is missing in Magento Setup';
        Text001: Label 'Error in code pattern %1';
        Text002: Label 'Gift Voucher %1 has already been cashed on date %2';
        Text003: Label 'The Payment Amount exceeds the amount on Gift Voucher %1\  - Payment Amount: %3\ - Gift Voucher Amount: %2';
        Text004: Label 'Credit Voucher %1 has already been cashed on date %2';
        Text005: Label 'The Payment Amount exceeds the amount on Credit Voucher %1\  - Payment Amount: %3\ - Credit Voucher Amount: %2';
        Text006: Label 'Invalid Web Code!\No Giftvoucher or Creditvoucher with Web Code %1';
        Text007: Label 'Orders paid with Gift Voucher and/or Credit Voucher may not be partially invoiced nor adjusted.';

    local procedure "--- Activation"()
    begin
    end;

    local procedure ActivateGiftVoucher(var GiftVoucher: Record "Gift Voucher")
    var
        MagentoSetup: Record "Magento Setup";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        GiftVoucher.Status := GiftVoucher.Status::Open;
        GiftVoucher.Modify(true);
    end;

    procedure ActivateCreditVoucher(var CreditVoucher: Record "Credit Voucher")
    var
        MagentoSetup: Record "Magento Setup";
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;
        CreditVoucher.Status := CreditVoucher.Status::Open;
        CreditVoucher.Modify(true);
    end;

    procedure DeactivateVouchers(ExternalReferenceNo: Code[30]; ExternalVoucherNo: Code[10])
    var
        MagentoSetup: Record "Magento Setup";
        GiftVoucher: Record "Gift Voucher";
    begin
        //-MAG2.00
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        GiftVoucher.SetRange("External Reference No.", ExternalReferenceNo);
        GiftVoucher.SetRange("External Gift Voucher No.", ExternalVoucherNo);
        if GiftVoucher.FindFirst then begin
            GiftVoucher.Status := GiftVoucher.Status::Cashed;
            GiftVoucher.Modify(true);
        end;
        //+MAG2.00
    end;

    procedure ActivateAndMailGiftVouchers(ExternalOrderNo: Code[20]; EMail: Text[250])
    var
        CreditVoucher: Record "Credit Voucher";
        GiftVoucher: Record "Gift Voucher";
        TempCreditVoucher: Record "Credit Voucher" temporary;
        MagentoSetup: Record "Magento Setup";
        TempGiftVoucher: Record "Gift Voucher" temporary;
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

    local procedure FindGiftVouchers(ExternalOrderNo: Code[50]; var TempGiftVoucher: Record "Gift Voucher" temporary): Boolean
    var
        GiftVoucher: Record "Gift Voucher";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempGiftVoucher);
        if not RecRef.IsTemporary then
            exit(false);
        TempGiftVoucher.DeleteAll;

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Order No.", ExternalOrderNo);
        if SalesHeader.FindSet then
            repeat
                //-MAG2.00
                GiftVoucher.SetRange("Sales Order No.", SalesHeader."No.");
                //+MAG2.00
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

        SalesInvHeader.SetRange("External Order No.", ExternalOrderNo);
        SalesInvHeader.SetFilter("Order No.", '<>%1', '');
        if SalesInvHeader.FindSet then
            repeat
                //-MAG2.00
                GiftVoucher.SetRange("Sales Order No.", SalesInvHeader."Order No.");
                //+MAG2.00
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

    local procedure FindCreditVouchers(ExternalOrderNo: Code[50]; var TempCreditVoucher: Record "Credit Voucher" temporary): Boolean
    var
        CreditVoucher: Record "Credit Voucher";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempCreditVoucher);
        if not RecRef.IsTemporary then
            exit(false);
        TempCreditVoucher.DeleteAll;

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("External Order No.", ExternalOrderNo);
        if SalesHeader.FindSet then
            repeat
                //-MAG2.00
                CreditVoucher.SetRange("Sales Order No.", SalesHeader."No.");
                //+MAG2.00
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

        SalesInvHeader.SetRange("External Order No.", ExternalOrderNo);
        SalesInvHeader.SetFilter("Order No.", '<>%1', '');
        if SalesInvHeader.FindSet then
            repeat
                //-MAG2.00
                CreditVoucher.SetRange("Sales Order No.", SalesInvHeader."Order No.");
                //+MAG2.00
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

    procedure "--- Posting"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'OnCheckPayment', '', true, true)]
    local procedure OnCheckPayment(SalesHeader: Record "Sales Header")
    begin
        //-MAG2.17 [302179]
        if SalesHeader.IsTemporary then
            exit;

        CheckVoucherPayment(SalesHeader);
        //+MAG2.17 [302179]
    end;

    local procedure CheckCreditVoucherPayment(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        CreditVoucher: Record "Credit Voucher";
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

    local procedure CheckGiftVoucherPayment(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        GiftVoucher: Record "Gift Voucher";
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
        MagentoSetup: Record "Magento Setup";
        PaymentLine: Record "Magento Payment Line";
        VoucherFound: Boolean;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
        //-MAG2.17 [302179]
        PaymentLine.SetFilter("Source Table No.", '%1|%2', DATABASE::"Credit Voucher", DATABASE::"Gift Voucher");
        //+MAG2.17 [302179]
        PaymentLine.SetFilter(Amount, '>%1', 0);
        if not PaymentLine.FindSet then
            exit;

        repeat
            //-MAG2.17 [302179]
            case PaymentLine."Source Table No." of
                DATABASE::"Credit Voucher":
                    VoucherFound := CheckCreditVoucherPayment(PaymentLine);
                DATABASE::"Gift Voucher":
                    VoucherFound := CheckGiftVoucherPayment(PaymentLine);
                else
                    VoucherFound := false;
            end;
            //+MAG2.17 [302179]
            if not VoucherFound then
                Error(StrSubstNo(Text006, PaymentLine."No."));
        until PaymentLine.Next = 0;

        //-MAG2.17 [302179]
        PaymentLine.Reset;
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter("Account No.", '<>%1', '');
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::Voucher);
        if PaymentLine.FindFirst and (SalesHeader."Magento Payment Amount" <> GetTotalAmountInclVat(SalesHeader)) then
            Error(Text007);
        //+MAG2.17 [302179]
    end;

    local procedure GetTotalAmountInclVat(var SalesHeader: Record "Sales Header") TotalAmountInclVAT: Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        //-MAG2.17 [302179]
        Clear(TempSalesLine);
        Clear(SalesPost);
        TempVATAmountLine.DeleteAll;
        TempSalesLine.DeleteAll;
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 1);
        TempSalesLine.CalcVATAmountLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TotalAmountInclVAT := TempVATAmountLine.GetTotalAmountInclVAT();
        exit(TotalAmountInclVAT);
        //+MAG2.17 [302179]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'OnBeforePostPaymentLine', '', true, true)]
    local procedure OnBeforePostPaymentLine(var PaymentLine: Record "Magento Payment Line")
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        //-MAG2.17 [302179]
        if PaymentLine.IsTemporary then
            exit;

        if PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header" then
            exit;
        if PaymentLine."Payment Type" <> PaymentLine."Payment Type"::Voucher then
            exit;
        if not SalesInvHeader.Get(PaymentLine."Document No.") then
            exit;

        PostVoucherPayment(PaymentLine, SalesInvHeader);
        //+MAG2.17 [302179]
    end;

    procedure PostVoucherPayment(PaymentLine: Record "Magento Payment Line"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CreditVoucher: Record "Credit Voucher";
        GiftVoucher: Record "Gift Voucher";
        MagentoSetup: Record "Magento Setup";
        VoucherAmount: Decimal;
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
            VoucherAmount := GiftVoucher.Amount;
            GiftVoucher.Amount := 0;
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
            VoucherAmount := CreditVoucher.Amount;
            CreditVoucher.Amount := 0;
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

    [EventSubscriber(ObjectType::Codeunit, 6151416, 'OnAfterPostMagentoPayment', '', true, true)]
    local procedure OnAfterPostMagentoPayment(SalesInvHeader: Record "Sales Invoice Header")
    var
        Customer: Record Customer;
        MagentoSetup: Record "Magento Setup";
        MagentoGiftVoucherMgt: Codeunit "Magento Gift Voucher Mgt.";
    begin
        //-MAG2.17 [302179]
        if SalesInvHeader.IsTemporary then
            exit;
        if SalesInvHeader."External Order No." = '' then
            exit;
        if not (MagentoSetup.Get and MagentoSetup."Magento Enabled") then
            exit;
        if not MagentoSetup."Gift Voucher Enabled" then
            exit;
        if MagentoSetup."Gift Voucher Activation" <> MagentoSetup."Gift Voucher Activation"::OnPosting then
            exit;

        if Customer.Get(SalesInvHeader."Sell-to Customer No.") then;
        ActivateAndMailGiftVouchers(SalesInvHeader."External Order No.", Customer."E-Mail");
        //+MAG2.17 [302179]
    end;

    procedure "--- ExternalReferenceNo"()
    begin
    end;

    procedure GenerateExternalReferenceNo(GeneratePattern: Text[30]; VoucherNo: Code[20]) ExternalReferenceNo: Code[30]
    var
        MagentoSetup: Record "Magento Setup";
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
        CreditVoucher: Record "Credit Voucher";
        GiftVoucher: Record "Gift Voucher";
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

    procedure "--- E-mail"()
    begin
    end;

    procedure EmailGiftVoucher(var GiftVoucher: Record "Gift Voucher"; EMail: Text[250])
    var
        MagentoSetup: Record "Magento Setup";
        EmailManagement: Codeunit "E-mail Management";
        RecRef: RecordRef;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;

        RecRef.GetTable(GiftVoucher);
        EmailManagement.SendReport(MagentoSetup."Gift Voucher Report", RecRef, EMail, true);
    end;

    procedure EmailCreditVoucher(var CreditVoucher: Record "Credit Voucher"; EMail: Text[250])
    var
        MagentoSetup: Record "Magento Setup";
        EmailManagement: Codeunit "E-mail Management";
        RecRef: RecordRef;
    begin
        if not (MagentoSetup.Get and MagentoSetup."Gift Voucher Enabled") then
            exit;
        RecRef.GetTable(CreditVoucher);
        EmailManagement.SendReport(MagentoSetup."Credit Voucher Report", RecRef, EMail, true);
    end;

    local procedure "--- Event Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014408, 'OnBeforeInsertEvent', '', true, true)]
    local procedure CreditVoucherOnInsert(var Rec: Record "Credit Voucher"; RunTrigger: Boolean)
    var
        MagentoSetup: Record "Magento Setup";
    begin
        //-MAG2.00
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
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 6014408, 'OnBeforeModifyEvent', '', true, true)]
    local procedure CreditVoucherOnModify(var Rec: Record "Credit Voucher"; var xRec: Record "Credit Voucher"; RunTrigger: Boolean)
    var
        MagentoSetup: Record "Magento Setup";
    begin
        //-MAG2.00
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
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 6014409, 'OnBeforeInsertEvent', '', true, true)]
    local procedure GiftVoucherOnInsert(var Rec: Record "Gift Voucher"; RunTrigger: Boolean)
    var
        MagentoSetup: Record "Magento Setup";
    begin
        //-MAG2.00
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
        //+MAG2.00
    end;

    [EventSubscriber(ObjectType::Table, 6014409, 'OnBeforeModifyEvent', '', true, true)]
    local procedure GiftVoucherOnModify(var Rec: Record "Gift Voucher"; var xRec: Record "Gift Voucher"; RunTrigger: Boolean)
    var
        MagentoSetup: Record "Magento Setup";
    begin
        //-MAG2.00
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
        //+MAG2.00
    end;

    local procedure IsTemporary(VariantRec: Variant): Boolean
    var
        RecRef: RecordRef;
    begin
        //-MAG2.00
        RecRef.GetTable(VariantRec);
        exit(RecRef.IsTemporary);
        //+MAG2.00
    end;

    procedure "--- Print"()
    begin
    end;

    procedure GiftVoucherToTempBlob(var GiftVoucher: Record "Gift Voucher"; var TempBlob: Record TempBlob temporary)
    var
        MagentoSetup: Record "Magento Setup";
        TempBlob2: Record TempBlob temporary;
        MagentoGenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
        Bitmap: DotNet npNetBitmap;
        BitmapBarcode: DotNet npNetBitmap;
        Graphics: DotNet npNetGraphics;
        ImageFormat: DotNet npNetImageFormat;
        InStream: InStream;
        OutStream: OutStream;
        GiftVoucherMessage: Text;
        SetupPath: Text;
        NewHeight: Integer;
        NewWidth: Integer;
        Ratio: Decimal;
        Ratio2: Decimal;
        Language: Integer;
        VoucherAmount: Text;
        VoucherDate: Text;
        XDpi: Integer;
        YDpi: Integer;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Gift Voucher Bitmap".HasValue then
            Error(Text000);

        //-MAG2.00
        MagentoSetup.CalcFields("Generic Setup", "Gift Voucher Bitmap");
        TempBlob2.Blob := MagentoSetup."Generic Setup";
        //+MAG2.00
        MagentoSetup."Gift Voucher Bitmap".CreateInStream(InStream);
        Bitmap := Bitmap.Bitmap(InStream);
        Graphics := Graphics.FromImage(Bitmap);
        SetupPath := MagentoGenericSetupMgt."ElementName.GiftVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.CustomerName";
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, Format(GiftVoucher.Name));

        SetupPath := MagentoGenericSetupMgt."ElementName.GiftVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.Amount";
        //-MAG2.09 [292576]
        VoucherAmount := Format(GiftVoucher.Amount);
        if MagentoSetup."Voucher Number Format" <> '' then
            VoucherAmount := Format(GiftVoucher.Amount, 0, MagentoSetup."Voucher Number Format");
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, VoucherAmount);
        //+MAG2.09 [292576]
        SetupPath := MagentoGenericSetupMgt."ElementName.GiftVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.CurrencyCode";
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, Format(GiftVoucher."Currency Code"));

        SetupPath := MagentoGenericSetupMgt."ElementName.GiftVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.WebCode";
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, GiftVoucher."External Reference No.");

        SetupPath := MagentoGenericSetupMgt."ElementName.GiftVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.ExpiryDate";
        //-MAG2.09 [292576]
        VoucherDate := Format(GiftVoucher."Expire Date");
        if MagentoSetup."Voucher Date Format" <> '' then
            VoucherDate := Format(GiftVoucher."Expire Date", 0, MagentoSetup."Voucher Date Format");
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, VoucherDate);
        //+MAG2.09 [292576]

        if GiftVoucher."Gift Voucher Message".HasValue then begin
            GiftVoucher.CalcFields("Gift Voucher Message");
            GiftVoucher."Gift Voucher Message".CreateInStream(InStream);
            InStream.ReadText(GiftVoucherMessage);
            SetupPath := MagentoGenericSetupMgt."ElementName.GiftVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.Message";
            MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, GiftVoucherMessage);
        end;

        SetupPath := MagentoGenericSetupMgt."ElementName.GiftVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.Barcode";
        //-MAG2.01 [257315]
        MagentoGenericSetupMgt.DrawBarcode(Graphics, TempBlob2, SetupPath, Format(GiftVoucher."No."), Bitmap, BitmapBarcode);
        //+MAG2.01 [257315]

        Ratio := 794 / Bitmap.Width;
        Ratio2 := 1122 / Bitmap.Height;
        if Ratio > Ratio2 then
            Ratio := Ratio2;
        if Ratio < 1 then begin
            //-MAG2.22 [357825]
            XDpi := Bitmap.HorizontalResolution;
            YDpi := Bitmap.VerticalResolution;
            //+MAG2.22 [357825]
            NewWidth := Round(Bitmap.Width * Ratio, 1, '<');
            NewHeight := Round(Bitmap.Height * Ratio, 1, '<');
            Bitmap := Bitmap.Bitmap(Bitmap, NewWidth, NewHeight);
            //-MAG2.22 [357825]
            Bitmap.SetResolution(XDpi, YDpi);
            //+MAG2.22 [357825]
        end;
        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(OutStream);
        Bitmap.Save(OutStream, ImageFormat.Png);
    end;

    procedure CreditVoucherToTempBlob(var CreditVoucher: Record "Credit Voucher"; var TempBlob: Record TempBlob temporary)
    var
        MagentoSetup: Record "Magento Setup";
        TempBlob2: Record TempBlob temporary;
        MagentoGenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
        Bitmap: DotNet npNetBitmap;
        BitmapBarcode: DotNet npNetBitmap;
        Graphics: DotNet npNetGraphics;
        ImageFormat: DotNet npNetImageFormat;
        InStream: InStream;
        OutStream: OutStream;
        SetupPath: Text;
        NewHeight: Integer;
        NewWidth: Integer;
        Ratio: Decimal;
        Ratio2: Decimal;
        VoucherAmount: Text;
        VoucherDate: Text;
        XDpi: Integer;
        YDpi: Integer;
    begin
        MagentoSetup.Get;
        if not MagentoSetup."Credit Voucher Bitmap".HasValue then
            Error(Text000);

        //-MAG2.00
        //MagentoSetup.CALCFIELDS("Credit Voucher Bitmap");
        MagentoSetup.CalcFields("Generic Setup", "Credit Voucher Bitmap");
        TempBlob2.Blob := MagentoSetup."Generic Setup";
        //+MAG2.00
        MagentoSetup."Credit Voucher Bitmap".CreateInStream(InStream);
        Bitmap := Bitmap.Bitmap(InStream);
        Graphics := Graphics.FromImage(Bitmap);

        SetupPath := MagentoGenericSetupMgt."ElementName.CreditVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.CustomerName";
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, Format(CreditVoucher.Name));

        SetupPath := MagentoGenericSetupMgt."ElementName.CreditVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.Amount";
        //-MAG2.09 [292576]
        //MagentoGenericSetupMgt.DrawText(TempBlob2,Graphics,SetupPath,FORMAT(CreditVoucher.Amount));
        VoucherAmount := Format(CreditVoucher.Amount);
        if MagentoSetup."Voucher Number Format" <> '' then
            VoucherAmount := Format(CreditVoucher.Amount, 0, MagentoSetup."Voucher Number Format");
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, VoucherAmount);
        //+MAG2.09 [292576]

        SetupPath := MagentoGenericSetupMgt."ElementName.CreditVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.CurrencyCode";
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, Format(CreditVoucher."Currency Code"));

        SetupPath := MagentoGenericSetupMgt."ElementName.CreditVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.WebCode";
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, CreditVoucher."External Reference No.");

        SetupPath := MagentoGenericSetupMgt."ElementName.CreditVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.ExpiryDate";
        //-MAG2.09 [292576]
        //MagentoGenericSetupMgt.DrawText(TempBlob2,Graphics,SetupPath,FORMAT(CreditVoucher."Expire Date"));
        VoucherDate := Format(CreditVoucher."Expire Date");
        if MagentoSetup."Voucher Date Format" <> '' then
            VoucherDate := Format(CreditVoucher."Expire Date", 0, MagentoSetup."Voucher Date Format");
        MagentoGenericSetupMgt.DrawText(TempBlob2, Graphics, SetupPath, VoucherDate);
        //+MAG2.09 [292576]

        SetupPath := MagentoGenericSetupMgt."ElementName.CreditVoucherReport" + '/' + MagentoGenericSetupMgt."ElementName.Barcode";
        //-MAG2.01 [257315]
        //MagentoGenericSetupMgt.DrawBarcode(Graphics,TempBlob,SetupPath,FORMAT(CreditVoucher."No."),Bitmap,BitmapBarcode);
        MagentoGenericSetupMgt.DrawBarcode(Graphics, TempBlob2, SetupPath, Format(CreditVoucher."No."), Bitmap, BitmapBarcode);
        //+MAG2.01 [257315]

        Ratio := 794 / Bitmap.Width;
        Ratio2 := 1122 / Bitmap.Height;
        if Ratio > Ratio2 then
            Ratio := Ratio2;
        if Ratio < 1 then begin
            //-MAG2.22 [357825]
            XDpi := Bitmap.HorizontalResolution;
            YDpi := Bitmap.VerticalResolution;
            //+MAG2.22 [357825]
            NewWidth := Round(Bitmap.Width * Ratio, 1, '<');
            NewHeight := Round(Bitmap.Height * Ratio, 1, '<');
            Bitmap := Bitmap.Bitmap(Bitmap, NewWidth, NewHeight);
            //-MAG2.22 [357825]
            Bitmap.SetResolution(XDpi, YDpi);
            //+MAG2.22 [357825]
        end;

        TempBlob.DeleteAll;
        TempBlob.Init;
        TempBlob.Blob.CreateOutStream(OutStream);
        Bitmap.Save(OutStream, ImageFormat.Png);
    end;
}

