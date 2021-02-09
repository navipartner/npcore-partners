codeunit 6151416 "NPR Magento Pmt. Mgt."
{
    TableNo = "NPR Magento Payment Line";

    trigger OnRun()
    var
        NotInitialized: Label 'Codeunit 6151416 wasn''t initialized properly. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        case PaymentEventType of
            PaymentEventType::Capture:
                CapturePaymentEvent(PaymentGateway, Rec);
            PaymentEventType::Refund:
                RefundPaymentEvent(PaymentGateway, Rec);
            else
                Error(NotInitialized);
        end;
    end;

    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        PaymentEventType: Option " ",Capture,Refund;
        Text000: Label 'Error during Payment Capture:\%1';
        Text004: Label 'You may not invoice more than the paid amount %1.';
        Text005: Label 'Error during Payment Refund:\%1';
        Text006: Label 'Document not Found';

    procedure SetProcessingOptions(PaymentGatewayIn: Record "NPR Magento Payment Gateway"; PaymentEventTypeIn: Option " ",Capture,Refund)
    begin
        PaymentGateway := PaymentGatewayIn;
        PaymentEventType := PaymentEventTypeIn;
    end;

    //[EventSubscriber(ObjectType::Codeunit, 6620, 'OnAfterCopySalesDoc', '', true, true)]
    local procedure CopySalesDoc(FromDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo"; FromDocNo: Code[20]; IncludeHeader: Boolean; var ToSalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        PaymentLineBal: Record "NPR Magento Payment Line";
    begin
        if not (ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::"Return Order", ToSalesHeader."Document Type"::"Credit Memo"]) then
            exit;

        case FromDocType of
            FromDocType::Order:
                begin
                    PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
                    PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
                    PaymentLine.SetRange("Document No.", FromDocNo);
                end;
            FromDocType::Invoice:
                begin
                    PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
                    PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Invoice);
                    PaymentLine.SetRange("Document No.", FromDocNo);
                end;
            FromDocType::"Posted Invoice":
                begin
                    PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Invoice Header");
                    PaymentLine.SetRange("Document Type", 0);
                    PaymentLine.SetRange("Document No.", FromDocNo);
                end;
            else
                exit;
        end;
        if PaymentLine.IsEmpty then
            exit;

        PaymentLine.FindSet;
        repeat
            if PaymentLine2.Get(DATABASE::"Sales Header", ToSalesHeader."Document Type", ToSalesHeader."No.", PaymentLine."Line No.") then
                PaymentLine2.Delete;
            PaymentLine2.Init;
            PaymentLine2 := PaymentLine;
            PaymentLine2."Document Table No." := DATABASE::"Sales Header";
            PaymentLine2."Document Type" := ToSalesHeader."Document Type";
            PaymentLine2."Document No." := ToSalesHeader."No.";
            PaymentLine2.Insert(true);

            if (PaymentLine."Payment Type" = PaymentLine."Payment Type"::"Payment Method") and (PaymentLine."Account No." <> '') and (PaymentLine.Amount <> 0) then
                PaymentLineBal := PaymentLine;
        until PaymentLine.Next = 0;

        if not IncludeHeader then
            exit;
        if ToSalesHeader."Applies-to Doc. No." <> '' then
            exit;
        if ToSalesHeader."Applies-to ID" <> '' then
            exit;

        ToSalesHeader.Validate("Payment Method Code");
        if PaymentLineBal."Account No." <> '' then begin
            ToSalesHeader."Bal. Account Type" := PaymentLineBal."Account Type";
            ToSalesHeader."Bal. Account No." := PaymentLineBal."Account No.";
        end;
        ToSalesHeader.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure Cu80OnAfterPostSalesCrMemo(var SalesHeader: Record "Sales Header"; SalesCrMemoHdrNo: Code[20])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if SalesCrMemoHdrNo = '' then
            exit;
        if not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
            exit;
        if not HasMagentoPayment(DATABASE::"Sales Cr.Memo Header", Enum::"Sales Document Type".FromInteger(0), SalesCrMemoHeader."No.") then
            exit;

        RefundSalesCreditMemo(SalesCrMemoHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure Cu80OnAfterPostSalesInvoice(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesInvHdrNo: Code[20])
    begin
        if SalesInvHdrNo = '' then
            exit;

        PostMagentoPayment(SalesHeader, GenJnlPostLine, SalesInvHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostCommitSalesDoc', '', true, true)]
    local procedure Cu80OnBeforePostCommitSalesCrMemo(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; ModifyHeader: Boolean)
    begin
        if PreviewMode then
            exit;
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"]) then
            exit;
        if (not SalesHeader.Invoice) and (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order") then
            exit;
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        InsertRefundPaymentLines(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostCommitSalesDoc', '', true, true)]
    local procedure Cu80OnBeforePostCommitSalesInvoice(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; ModifyHeader: Boolean)
    begin
        if PreviewMode then
            exit;
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice]) then
            exit;
        if (not SalesHeader.Invoice) and (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then
            exit;
        AdjustPaymentAmount(SalesHeader);
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        InsertPaymentLines(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, true)]
    local procedure Cu80OnBeforePostSalesInvoice(var SalesHeader: Record "Sales Header")
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order]) then
            exit;
        if not SalesHeader.Invoice then
            exit;
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        SalesHeader."Bal. Account No." := '';
        CheckPayment(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', true, true)]
    procedure SalesHeaderOnDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        if Rec.IsTemporary then
            exit;
        if not HasMagentoPayment(DATABASE::"Sales Header", Rec."Document Type", Rec."No.") then
            exit;

        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", Rec."Document Type");
        PaymentLine.SetRange("Document No.", Rec."No.");
        if PaymentLine.IsEmpty then
            exit;

        if RunTrigger then begin
            PaymentLine.FindSet;
            repeat
                CancelPaymentLine(PaymentLine);
            until PaymentLine.Next = 0;
        end;

        PaymentLine.DeleteAll(true);
    end;

    local procedure CheckPayment(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentAmt: Decimal;
        TotalAmountInclVAT: Decimal;
    begin
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        if HasAllowAdjustAmount(SalesHeader) then
            exit;

        TotalAmountInclVAT := GetTotalAmountInclVat(SalesHeader);
        SalesHeader.CalcFields("NPR Magento Payment Amount");
        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        PaymentLine.CalcSums(Amount);
        PaymentAmt := PaymentLine.Amount;

        PaymentLine.SetRange(Amount);
        PaymentLine.SetFilter("Last Amount", '<>%1', 0);
        if not PaymentLine.IsEmpty then begin
            PaymentLine.FindSet;
            repeat
                if not LastPostingDocExists(PaymentLine) then
                    PaymentAmt += PaymentLine."Last Amount";
            until PaymentLine.Next = 0;
        end;
        if PaymentAmt < TotalAmountInclVAT then
            Error(Text004, PaymentAmt);

        OnCheckPayment(SalesHeader);
    end;

    local procedure HasAllowAdjustAmount(SalesHeader: Record "Sales Header"): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Allow Adjust Amount", true);
        exit(PaymentLine.FindFirst);
    end;

    local procedure HasMagentoPayment(DocTableNo: Integer; DocType: Enum "Sales Document Type"; DocNo: Code[20]): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DocTableNo);
        PaymentLine.SetRange("Document Type", DocType);
        PaymentLine.SetRange("Document No.", DocNo);
        exit(PaymentLine.FindFirst);
    end;

    local procedure HasOpenEntry(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if (PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header") or (PaymentLine."Document No." = '') then
            exit(false);
        if not SalesInvHeader.Get(PaymentLine."Document No.") then
            exit(false);

        CustLedgerEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date", "Currency Code");
        CustLedgerEntry.SetRange("Customer No.", SalesInvHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Positive, PaymentLine.Amount >= 0);
        CustLedgerEntry.SetRange("Document No.", SalesInvHeader."No.");
        exit(CustLedgerEntry.FindFirst);
    end;

    local procedure LastPostingDocExists(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if PaymentLine."Last Posting No." = '' then
            exit(false);
        if PaymentLine."Document Table No." <> DATABASE::"Sales Header" then
            exit(false);

        case PaymentLine."Document Type" of
            PaymentLine."Document Type"::Order, PaymentLine."Document Type"::Invoice:
                exit(SalesInvHeader.Get(PaymentLine."Last Posting No."));
            PaymentLine."Document Type"::"Return Order", PaymentLine."Document Type"::"Credit Memo":
                exit(SalesCrMemoHeader.Get(PaymentLine."Last Posting No."));
        end;

        exit(false);
    end;

    local procedure GetTotalAmountInclVat(var SalesHeader: Record "Sales Header") TotalAmountInclVAT: Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
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
        GeneralLedgerSetup.Get;
        TotalAmountInclVAT := Round(TotalAmountInclVAT, GeneralLedgerSetup."Amount Rounding Precision");
        exit(TotalAmountInclVAT);
    end;

    procedure ShowDocumentCard(PaymentLine: Record "NPR Magento Payment Line")
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        if not SetDocumentRecRef(PaymentLine, RecRef) then begin
            Message(Text006);
            exit;
        end;

        PageMgt.PageRun(RecRef);
    end;

    local procedure SetDocumentRecRef(PaymentLine: Record "NPR Magento Payment Line"; var RecRef: RecordRef): Boolean
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
    begin
        Clear(RecRef);
        RecRef.Open(PaymentLine."Document Table No.");
        KeyRef := RecRef.KeyIndex(1);
        case KeyRef.FieldCount of
            1:
                begin
                    FieldRef := KeyRef.FieldIndex(1);
                    FieldRef.SetRange(PaymentLine."Document No.");
                end;
            2:
                begin
                    FieldRef := KeyRef.FieldIndex(1);
                    FieldRef.SetRange(PaymentLine."Document Type");
                    FieldRef := KeyRef.FieldIndex(2);
                    FieldRef.SetRange(PaymentLine."Document No.");
                end;
            else
                exit(false);
        end;

        exit(RecRef.FindFirst);
    end;

    local procedure AdjustPaymentAmount(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdjustmentAmt: Decimal;
        TotalAmountInclVAT: Decimal;
    begin
        if not HasAllowAdjustAmount(SalesHeader) then
            exit;

        TotalAmountInclVAT := GetTotalAmountInclVat(SalesHeader);
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.CalcSums(Amount);
        if PaymentLine.Amount >= TotalAmountInclVAT then
            exit;

        AdjustmentAmt := TotalAmountInclVAT - PaymentLine.Amount;

        Clear(PaymentLine);
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Allow Adjust Amount", true);
        PaymentLine.FindFirst;
        PaymentLine.Amount += AdjustmentAmt;
        PaymentLine.Modify;
    end;

    procedure CapturePaymentLine(var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        MagentPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        ErrorText: Text;
    begin
        if PaymentLine."Date Captured" <> 0D then
            exit;

        if PaymentLine.Amount = 0 then begin
            PaymentLine."Date Captured" := Today;
            PaymentLine.Modify(true);
            exit;
        end;

        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;

        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        if PaymentGateway."Capture Codeunit Id" = 0 then
            exit;

        Commit;
        Clear(MagentPmtMgt);
        MagentPmtMgt.SetProcessingOptions(PaymentGateway, PaymentEventType::Capture);
        if not MagentPmtMgt.Run(PaymentLine) then begin
            ErrorText := GetLastErrorText;
            if ErrorText <> '' then
                Message(Text000, CopyStr(ErrorText, 1, 900));
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure CapturePaymentEvent(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
    end;

    procedure CaptureSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        if SalesInvoiceHeader."Order No." = '' then
            exit;

        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetRange("Date Captured", 0D);
        if PaymentLine.FindSet then
            repeat
                CapturePaymentLine(PaymentLine);
            until PaymentLine.Next = 0;
    end;

    local procedure InsertPaymentLines(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        OutstandingAmt: Decimal;
        PaymentAmt: Decimal;
        TotalAmountInclVAT: Decimal;
        DocNo: Code[20];
    begin
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        TotalAmountInclVAT := GetTotalAmountInclVat(SalesHeader);
        DocNo := SalesHeader."Posting No.";
        if DocNo = '' then begin
            NoSeriesMgt.SetNoSeriesLineFilter(NoSeriesLine, SalesHeader."Posting No. Series", 0D);
            NoSeriesLine.FindLast;
            DocNo := NoSeriesLine."Last No. Used";
        end;

        PaymentAmt := 0;
        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        if PaymentLine.FindSet(true) then
            repeat
                if not LastPostingDocExists(PaymentLine) then begin
                    PaymentLine.Amount += PaymentLine."Last Amount";
                    PaymentLine."Last Amount" := 0;
                    PaymentLine."Last Posting No." := '';
                end;
                if PaymentLine2.Get(DATABASE::"Sales Invoice Header", 0, DocNo, PaymentLine."Line No.") then
                    PaymentLine2.Delete;
                PaymentLine2.Init;
                PaymentLine2 := PaymentLine;
                PaymentLine2."Document Table No." := DATABASE::"Sales Invoice Header";
                PaymentLine2."Document Type" := Enum::"Sales Document Type".FromInteger(0);
                PaymentLine2."Document No." := DocNo;
                PaymentLine2."Posting Date" := SalesHeader."Posting Date";
                PaymentLine2.Insert;

                OutstandingAmt := TotalAmountInclVAT - PaymentAmt;
                if (PaymentLine."Payment Type" = PaymentLine."Payment Type"::"Payment Method") and (PaymentLine.Amount > OutstandingAmt) then begin
                    PaymentLine2.Amount := OutstandingAmt;
                    PaymentLine2.Modify;

                    PaymentLine.Amount := PaymentLine.Amount - OutstandingAmt;
                end else
                    PaymentLine.Amount := 0;
                PaymentLine."Last Amount" := PaymentLine2.Amount;
                PaymentLine."Last Posting No." := DocNo;
                PaymentLine.Modify;

                PaymentAmt += PaymentLine2.Amount;
            until (PaymentLine.Next = 0) or (PaymentAmt = TotalAmountInclVAT);
    end;

    local procedure PostMagentoPayment(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesInvHdrNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if not HasMagentoPayment(DATABASE::"Sales Invoice Header", Enum::"Sales Document Type".FromInteger(0), SalesInvHdrNo) then
            exit;

        SalesInvHeader.Get(SalesInvHdrNo);
        SalesInvHeader.CalcFields("Amount Including VAT");
        PostPaymentLines(SalesHeader, SalesInvHeader."No.", GenJnlPostLine);
        Commit;

        CaptureSalesInvoice(SalesInvHeader);
        Commit;

        OnAfterPostMagentoPayment(SalesInvHeader);
    end;

    procedure PostPaymentLine(var PaymentLine: Record "NPR Magento Payment Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if PaymentLine.Posted then
            exit;

        if PaymentLine.Amount = 0 then begin
            PaymentLine.Posted := true;
            PaymentLine.Modify(true);
            exit;
        end;

        PaymentLine.TestField("Account No.");
        if not HasOpenEntry(PaymentLine) then begin
            PaymentLine.Posted := true;
            PaymentLine.Modify;
            Commit;
            exit;
        end;

        OnBeforePostPaymentLine(PaymentLine);

        case PaymentLine."Document Table No." of
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvHeader.Get(PaymentLine."Document No.");
                    SetupGenJnlLineInvoice(SalesInvHeader, PaymentLine, GenJnlLine);
                end;
            else
                exit;
        end;

        GenJnlPostLine.RunWithCheck(GenJnlLine);
        PaymentLine.Posted := true;
        PaymentLine.Modify;
        Commit;
    end;

    local procedure PostPaymentLines(var SalesHeader: Record "Sales Header"; DocNo: Code[20]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice:
                begin
                    PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Invoice Header");
                    PaymentLine.SetRange("Document Type", 0);
                    PaymentLine.SetRange("Document No.", DocNo);
                    PaymentLine.SetFilter("Account No.", '<>%1', '');
                    if not PaymentLine.FindSet then
                        exit;
                    repeat
                        PostPaymentLine(PaymentLine, GenJnlPostLine);
                    until PaymentLine.Next = 0;
                end;
        end;
    end;

    local procedure SetupGenJnlLineInvoice(SalesInvHeader: Record "Sales Invoice Header"; PaymentLine: Record "NPR Magento Payment Line"; var GenJnlLine: Record "Gen. Journal Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        SourceCode: Code[10];
    begin
        PaymentLine.TestField("Document Table No.", DATABASE::"Sales Invoice Header");
        SalesInvHeader.TestField("No.", PaymentLine."Document No.");

        SourceCodeSetup.Get;
        SourceCode := SourceCodeSetup.Sales;

        GenJnlLine.Init;
        GenJnlLine."Posting Date" := PaymentLine."Posting Date";
        GenJnlLine."Document Date" := PaymentLine."Posting Date";
        GenJnlLine.Description := PaymentLine.Description;
        GenJnlLine."Shortcut Dimension 1 Code" := SalesInvHeader."Shortcut Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := SalesInvHeader."Shortcut Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := SalesInvHeader."Dimension Set ID";
        GenJnlLine."Reason Code" := SalesInvHeader."Reason Code";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", SalesInvHeader."Bill-to Customer No.");
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        if PaymentLine.Amount < 0 then
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
        GenJnlLine."Document No." := SalesInvHeader."No.";
        GenJnlLine."External Document No." := SalesInvHeader."External Document No.";
        case PaymentLine."Account Type" of
            PaymentLine."Account Type"::"G/L Account":
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            PaymentLine."Account Type"::"Bank Account":
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
        end;
        GenJnlLine.Validate("Bal. Account No.", PaymentLine."Account No.");
        GenJnlLine."Currency Code" := SalesInvHeader."Currency Code";
        GenJnlLine.Amount := -PaymentLine.Amount;
        GenJnlLine."Source Currency Code" := SalesInvHeader."Currency Code";
        GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
        GenJnlLine.Correction := SalesInvHeader.Correction;
        if SalesInvHeader."Currency Code" = '' then
            GenJnlLine."Currency Factor" := 1
        else
            GenJnlLine."Currency Factor" := SalesInvHeader."Currency Factor";
        GenJnlLine.Validate(Amount);
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
        if PaymentLine.Amount < 0 then
            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Payment;
        GenJnlLine."Applies-to Doc. No." := SalesInvHeader."No.";
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := SalesInvHeader."Bill-to Customer No.";
        GenJnlLine."Source Code" := SourceCode;
        GenJnlLine.Validate("Salespers./Purch. Code", SalesInvHeader."Salesperson Code");
        GenJnlLine."Allow Zero-Amount Posting" := true;
    end;

    local procedure InsertRefundPaymentLines(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        OutstandingAmt: Decimal;
        RefundAmt: Decimal;
        TotalAmountInclVAT: Decimal;
        DocNo: Code[20];
    begin
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        TotalAmountInclVAT := GetTotalAmountInclVat(SalesHeader);
        DocNo := SalesHeader."Posting No.";
        if DocNo = '' then begin
            NoSeriesMgt.SetNoSeriesLineFilter(NoSeriesLine, SalesHeader."Posting No. Series", 0D);
            NoSeriesLine.FindLast;
            DocNo := NoSeriesLine."Last No. Used";
        end;

        RefundAmt := 0;
        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        if PaymentLine.FindSet(true) then
            repeat
                if not LastPostingDocExists(PaymentLine) then begin
                    PaymentLine.Amount += PaymentLine."Last Amount";
                    PaymentLine."Last Amount" := 0;
                    PaymentLine."Last Posting No." := '';
                end;
                if PaymentLine2.Get(DATABASE::"Sales Cr.Memo Header", 0, DocNo, PaymentLine."Line No.") then
                    PaymentLine2.Delete;
                PaymentLine2.Init;
                PaymentLine2 := PaymentLine;
                PaymentLine2."Document Table No." := DATABASE::"Sales Cr.Memo Header";
                PaymentLine2."Document Type" := Enum::"Sales Document Type".FromInteger(0);
                PaymentLine2."Document No." := DocNo;
                PaymentLine2."Posting Date" := SalesHeader."Posting Date";
                PaymentLine2.Insert;

                OutstandingAmt := TotalAmountInclVAT - RefundAmt;
                if (PaymentLine."Payment Type" = PaymentLine."Payment Type"::"Payment Method") and (PaymentLine.Amount > OutstandingAmt) then begin
                    PaymentLine2.Amount := OutstandingAmt;
                    PaymentLine2.Modify;
                    PaymentLine.Amount := PaymentLine.Amount - OutstandingAmt;
                end else
                    PaymentLine.Amount := 0;
                PaymentLine."Last Amount" := PaymentLine2.Amount;
                PaymentLine."Last Posting No." := DocNo;
                PaymentLine.Modify;

                RefundAmt += PaymentLine2.Amount;
            until (PaymentLine.Next = 0) or (RefundAmt = TotalAmountInclVAT);
    end;

    local procedure RefundSalesCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if not HasMagentoPayment(DATABASE::"Sales Cr.Memo Header", Enum::"Sales Document Type".FromInteger(0), SalesCrMemoHeader."No.") then
            exit;

        RefundPaymentLines(SalesCrMemoHeader);
    end;

    procedure RefundPaymentLine(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        MagentPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        ErrorText: Text;
    begin
        if PaymentLine."Date Refunded" <> 0D then
            exit;
        if PaymentLine.Amount = 0 then begin
            PaymentLine."Date Refunded" := Today;
            PaymentLine.Modify(true);
            exit;
        end;
        if PaymentLine."Payment Gateway Code" = '' then
            exit;
        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;
        if PaymentGateway."Refund Codeunit Id" = 0 then
            exit;

        Commit;
        Clear(MagentPmtMgt);
        MagentPmtMgt.SetProcessingOptions(PaymentGateway, PaymentEventType::Refund);
        if not MagentPmtMgt.Run(PaymentLine) then begin
            ErrorText := GetLastErrorText;
            if ErrorText <> '' then
                Message(Text005, CopyStr(ErrorText, 1, 900));
        end;
    end;

    procedure RefundPaymentLines(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PrevRec: Text;
    begin
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetRange("Date Refunded", 0D);
        if PaymentLine.FindSet then
            repeat
                PrevRec := Format(PaymentLine);
                RefundPaymentLine(PaymentLine);
                if PrevRec <> Format(PaymentLine) then
                    Commit;
            until PaymentLine.Next = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure RefundPaymentEvent(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
    end;

    local procedure CancelPaymentLine(var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit;
        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;
        if PaymentLine.Amount = 0 then
            exit;
        if PaymentGateway."Cancel Codeunit Id" = 0 then
            exit;

        CancelPaymentEvent(PaymentGateway, PaymentLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure CancelPaymentEvent(PaymentGateway: Record "NPR Magento Payment Gateway"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPayment(SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentLine(var PaymentLine: Record "NPR Magento Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostMagentoPayment(SalesInvHeader: Record "Sales Invoice Header")
    begin
    end;
}