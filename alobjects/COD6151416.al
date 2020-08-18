codeunit 6151416 "Magento Pmt. Mgt."
{
    // MAG1.00/MHA /20150113  CASE 199932 Refactored object from Web Integration
    // MAG1.03/MHA /20150113  CASE 199932 Renamed codeunit from Magento Payment Mgt. to be inluded in NaviConnect
    // MAG1.20/TR  /20150902  CASE 219645 Modifed to handle Capture of Sales Inv. Header.
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/TS  /20160902  CASE 250446 Added CALCFIELDS for Naviconnect Payment Amount.
    // MAG2.01/MHA /20160914  CASE 242550 Check on Magento Enabled removed in HasMagentoPayment()
    // MAG2.01/BHR /20160921  CASE 251964 fix to handle rollback of Orders
    // MAG2.01/MHA /20160929  CASE 242551 Sales Header Capture Enabled
    // MAG2.01/MHA /20161006  CASE 253877 Cr.Memo Payment Added and changed Capture to NavEvent
    // MAG2.01/MHA /20161031  CASE 256733 Added Functions ShowDocumentCard() and SetDocumentRecRef()
    // MAG2.02/MHA /20170221  CASE 264986 Amount (LCY) is calculated by VALIDATE(Amount)
    // MAG2.02/MHA /20170222  CASE 264711 Added fields "Last Amount" and "Last Posting No." in case Posting has failed after transfer of Payment Lines
    // MAG2.03/MHA /20170314  CASE 268154 Lines with Amount = 0 should not be included in HasMagentoPayment()
    // MAG2.03/MHA /20170315  CASE 267729 Added function CopySalesDoc()
    // MAG2.04/MHA /20170504  CASE 258635 Posting only applies to Orders and Invoices for now
    // MAG2.05/MHA /20170530  CASE 278054 Changed PostPaymentLine() back to Not be a Try-function
    // MAG2.05/MHA /20170712  CASE 283588 Added "Allow Adjust Payment Amount" functionality in CheckPayment() and Cu80OnBeforePostCommitSalesInvoice()
    // MAG2.06/MHA /20170816  CASE 284557 Check on SalesHeader.Invoice should only be performed for orders
    // MAG2.07/MHA /20170912  CASE 289527 Renamed function HasOpenInvoiceEntry() to HasOpenEntry() to account for Refunds
    // MAG2.16/MHA /20181002  CASE 330552 Added Round in GetTotalAmountInclVat()
    // MAG2.17/MHA /20180920  CASE 302179 Added publisher functions OnCheckPayment(), OnBeforePostPaymentLine(), OnAfterPostMagentoPayment()
    // MAG2.21/MHA /20190523  CASE 355176 Error during Payment Capture/Refund should not result in Hard Error
    // MAG2.26/MHA /20200428  CASE 401902 Zero amount lines should be ignored in InsertPaymentLines()
    // MAG2.26/MHA /20200522  CASE 384262 Added validation to Bal. Account No. in SetupGenJnlLineInvoice() to init proper VAT Posting Setup
    // NPR5.55/MHA /20200605  CASE 402013 Added Delete trigger to SalesHeaderOnDelete()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Error during Payment Capture:\%1';
        Text001: Label 'Aborted by user.';
        Text002: Label 'The return code %1 was revieced with the message: \%2 \Wish to continue?';
        Text003: Label 'The response must contain %1!';
        Text004: Label 'You may not invoice more than the paid amount %1.';
        Text005: Label 'Error during Payment Refund:\%1';
        Text006: Label 'Document not Found';

    local procedure "--- Subscribers"()
    begin
    end;

    //[EventSubscriber(ObjectType::Codeunit, 6620, 'OnAfterCopySalesDoc', '', true, true)]
    local procedure CopySalesDoc(FromDocType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Shipment","Posted Invoice","Posted Return Receipt","Posted Credit Memo"; FromDocNo: Code[20]; IncludeHeader: Boolean; var ToSalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "Magento Payment Line";
        PaymentLine2: Record "Magento Payment Line";
        PaymentLineBal: Record "Magento Payment Line";
    begin
        //-MAG2.03 [267729]
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
        //+MAG2.03 [267729]
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure Cu80OnAfterPostSalesCrMemo(var SalesHeader: Record "Sales Header"; SalesCrMemoHdrNo: Code[20])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        //-MAG2.01 [253877]
        if SalesCrMemoHdrNo = '' then
            exit;
        if not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
            exit;
        if not HasMagentoPayment(DATABASE::"Sales Cr.Memo Header", 0, SalesCrMemoHeader."No.") then
            exit;

        RefundSalesCreditMemo(SalesCrMemoHeader);
        //+MAG2.01 [253877]
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure Cu80OnAfterPostSalesInvoice(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesInvHdrNo: Code[20])
    begin
        if SalesInvHdrNo = '' then
            exit;

        PostMagentoPayment(SalesHeader, GenJnlPostLine, SalesInvHdrNo);
        //-MAG2.17 [302179]
        //ActivateAndMailGiftVouchers(SalesHeader);
        //+MAG2.17 [302179]
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostCommitSalesDoc', '', true, true)]
    local procedure Cu80OnBeforePostCommitSalesCrMemo(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; ModifyHeader: Boolean)
    begin
        //-MAG2.01 [253877]
        if PreviewMode then
            exit;
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo"]) then
            exit;
        //-MAG2.06 [284557]
        //IF NOT SalesHeader.Invoice THEN
        //  EXIT;
        if (not SalesHeader.Invoice) and (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order") then
            exit;
        //+MAG2.06 [284557]
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        InsertRefundPaymentLines(SalesHeader);
        //+MAG2.01 [253877]
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostCommitSalesDoc', '', true, true)]
    local procedure Cu80OnBeforePostCommitSalesInvoice(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PreviewMode: Boolean; ModifyHeader: Boolean)
    begin
        //-MAG2.01 [253877]
        if PreviewMode then
            exit;
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice]) then
            exit;
        //+MAG2.01 [253877]
        //-MAG2.06 [284557]
        //IF NOT SalesHeader.Invoice THEN
        //  EXIT;
        if (not SalesHeader.Invoice) and (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then
            exit;
        //+MAG2.06 [284557]
        //-MAG2.05 [283588]
        AdjustPaymentAmount(SalesHeader);
        //+MAG2.05 [283588]
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        InsertPaymentLines(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', true, true)]
    local procedure Cu80OnBeforePostSalesInvoice(var SalesHeader: Record "Sales Header")
    begin
        //-MAG2.03 [267729]
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order]) then
            exit;
        //+MAG2.03 [267729]
        if not SalesHeader.Invoice then
            exit;
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        SalesHeader."Bal. Account No." := '';
        CheckPayment(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterDeleteEvent', '', true, true)]
    procedure SalesHeaderOnDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        PaymentLine: Record "Magento Payment Line";
    begin
        //-MAG2.02 [2664711]
        //IF NOT RunTrigger THEN
        //  EXIT;
        if Rec.IsTemporary then
            exit;
        //+MAG2.02 [2664711]
        if not HasMagentoPayment(DATABASE::"Sales Header", Rec."Document Type", Rec."No.") then
            exit;

        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", Rec."Document Type");
        PaymentLine.SetRange("Document No.", Rec."No.");
        //-MAG2.01 [253877]
        //-MAG2.02 [2664711]
        //IF NOT PaymentLine.FINDSET THEN
        //  EXIT;
        //
        //REPEAT
        //  CancelPaymentLine(PaymentLine);
        //UNTIL PaymentLine.NEXT = 0;
        if PaymentLine.IsEmpty then
            exit;

        if RunTrigger then begin
            PaymentLine.FindSet;
            repeat
                CancelPaymentLine(PaymentLine);
            until PaymentLine.Next = 0;
        end;
        //+MAG2.02 [2664711]

        //+MAG2.01 [253877]
        //-NPR5.55 [402013]
        PaymentLine.DeleteAll(true);
        //+NPR5.55 [402013]
    end;

    local procedure "--- Checks"()
    begin
    end;

    local procedure CheckPayment(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "Magento Payment Line";
        PaymentAmt: Decimal;
        TotalAmountInclVAT: Decimal;
    begin
        if not HasMagentoPayment(DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        //-MAG2.05 [283588]
        if HasAllowAdjustAmount(SalesHeader) then
            exit;
        //+MAG2.05 [283588]

        TotalAmountInclVAT := GetTotalAmountInclVat(SalesHeader);
        //-MAG2.01 [250446]
        SalesHeader.CalcFields("Magento Payment Amount");
        //+MAG2.01 [250446]
        //-MAG2.02 [264711]
        //IF SalesHeader."Magento Payment Amount" < TotalAmountInclVAT THEN
        //  ERROR(Text004,SalesHeader."Magento Payment Amount");
        PaymentLine.Reset;
        //-MAG2.05 [283588]
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        //+MAG2.05 [283588]
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
        //+MAG2.02 [264711]

        //-MAG2.17 [302179]
        // PaymentLine.RESET;
        // PaymentLine.SETRANGE("Document Type",SalesHeader."Document Type");
        // PaymentLine.SETRANGE("Document No.",SalesHeader."No.");
        // PaymentLine.SETFILTER("Account No.",'<>%1','');
        // PaymentLine.SETFILTER(Amount,'<>%1',0);
        // PaymentLine.SETRANGE("Payment Type",PaymentLine."Payment Type"::Voucher);
        // IF PaymentLine.FINDFIRST AND (SalesHeader."Magento Payment Amount" <> TotalAmountInclVAT) THEN
        //  ERROR(Text005);
        //
        //MagentoGiftVoucherMgt.CheckVoucherPayment(SalesHeader);
        OnCheckPayment(SalesHeader);
        //+MAG2.17 [302179]
    end;

    local procedure HasAllowAdjustAmount(SalesHeader: Record "Sales Header"): Boolean
    var
        PaymentLine: Record "Magento Payment Line";
    begin
        //-MAG2.05 [283588]
        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Allow Adjust Amount", true);
        exit(PaymentLine.FindFirst);
        //+MAG2.05 [283588]
    end;

    local procedure HasMagentoPayment(DocTableNo: Integer; DocType: Option; DocNo: Code[20]): Boolean
    var
        PaymentLine: Record "Magento Payment Line";
    begin
        //-MAG2.01 [242550]
        //IF NOT MagentoEnabled THEN
        //  EXIT(FALSE);
        //+MAG2.01 [242550]

        PaymentLine.Reset;
        PaymentLine.SetRange("Document Table No.", DocTableNo);
        PaymentLine.SetRange("Document Type", DocType);
        PaymentLine.SetRange("Document No.", DocNo);
        //-MAG2.26 [401902]
        // //-MAG2.03 [268154]
        // PaymentLine.SETFILTER(Amount,'<>%1',0);
        // //+MAG2.03 [268154]
        //+MAG2.26 [401902]
        exit(PaymentLine.FindFirst);
    end;

    local procedure HasOpenEntry(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        //-MAG2.01 [256733]
        if (PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header") or (PaymentLine."Document No." = '') then
            exit(false);
        if not SalesInvHeader.Get(PaymentLine."Document No.") then
            exit(false);

        CustLedgerEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date", "Currency Code");
        CustLedgerEntry.SetRange("Customer No.", SalesInvHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        //-MAG2.07 [289527]
        //CustLedgerEntry.SETRANGE("Document Type",CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Positive, PaymentLine.Amount >= 0);
        //+MAG2.07 [289527]
        CustLedgerEntry.SetRange("Document No.", SalesInvHeader."No.");
        exit(CustLedgerEntry.FindFirst);
        //+MAG2.01 [256733]
    end;

    local procedure LastPostingDocExists(PaymentLine: Record "Magento Payment Line"): Boolean
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        //-MAG2.02 [264711]
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
        //+MAG2.02 [264711]
    end;

    local procedure "--- Aux"()
    begin
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
        //-MAG2.16 [330552]
        GeneralLedgerSetup.Get;
        TotalAmountInclVAT := Round(TotalAmountInclVAT, GeneralLedgerSetup."Amount Rounding Precision");
        //+MAG2.16 [330552]
        exit(TotalAmountInclVAT);
    end;

    local procedure "--- Document"()
    begin
    end;

    procedure ShowDocumentCard(PaymentLine: Record "Magento Payment Line")
    var
        PageMgt: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        //-MAG2.01 [256733]
        if not SetDocumentRecRef(PaymentLine, RecRef) then begin
            Message(Text006);
            exit;
        end;

        PageMgt.PageRun(RecRef);
        //+MAG2.01 [256733]
    end;

    local procedure SetDocumentRecRef(PaymentLine: Record "Magento Payment Line"; var RecRef: RecordRef): Boolean
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
    begin
        //-MAG2.01 [256733]
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
        //+MAG2.01 [256733]
    end;

    local procedure "--- Invoice Payment"()
    begin
    end;

    local procedure AdjustPaymentAmount(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "Magento Payment Line";
        AdjustmentAmt: Decimal;
        TotalAmountInclVAT: Decimal;
    begin
        //-MAG2.05 [283588]
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
        //+MAG2.05 [283588]
    end;

    procedure CapturePaymentLine(var PaymentLine: Record "Magento Payment Line")
    var
        PaymentGateway: Record "Magento Payment Gateway";
        ErrorText: Text;
    begin
        if PaymentLine."Date Captured" <> 0D then
            exit;

        //-MAG2.26 [401902]
        if PaymentLine.Amount = 0 then begin
          PaymentLine."Date Captured" := Today;
          PaymentLine.Modify(true);
          exit;
        end;
        //+MAG2.26 [401902]

        //-MAG2.01 [242551]
        //IF PaymentLine."Document Table No." <> DATABASE::"Sales Invoice Header" THEN
        //  EXIT;
        if not (PaymentLine."Document Table No." in [DATABASE::"Sales Header", DATABASE::"Sales Invoice Header"]) then
            exit;
        //+MAG2.01 [242551]

        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        if PaymentGateway."Capture Codeunit Id" = 0 then
            exit;

        //-MAG2.21 [355176]
        // CapturePaymentEvent(PaymentGateway,PaymentLine);
        // COMMIT;
        asserterror
        begin
            CapturePaymentEvent(PaymentGateway, PaymentLine);
            Commit;
            Error('');
        end;
        ErrorText := GetLastErrorText;
        if ErrorText <> '' then
            Message(Text000, CopyStr(ErrorText, 1, 900));
        //+MAG2.21 [355176]
    end;

    [IntegrationEvent(false, false)]
    local procedure CapturePaymentEvent(PaymentGateway: Record "Magento Payment Gateway"; var PaymentLine: Record "Magento Payment Line")
    begin
    end;

    procedure CaptureSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        PaymentLine: Record "Magento Payment Line";
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        if SalesInvoiceHeader."Order No." = '' then
            exit;

        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        //-MAG2.26 [401902]
        //PaymentLine.SETFILTER(Amount,'<>%1',0);
        //+MAG2.26 [401902]
        PaymentLine.SetRange("Date Captured", 0D);
        if PaymentLine.FindSet then
            repeat
                CapturePaymentLine(PaymentLine);
            until PaymentLine.Next = 0;
    end;

    local procedure InsertPaymentLines(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "Magento Payment Line";
        PaymentLine2: Record "Magento Payment Line";
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

        with SalesHeader do begin
            //-MAG2.01 [250446]
            //CALCFIELDS("Magento Payment Amount");
            //+MAG2.01 [250446]

            PaymentAmt := 0;
            PaymentLine.Reset;
            PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
            PaymentLine.SetRange("Document Type", "Document Type");
            PaymentLine.SetRange("Document No.", "No.");
          //-MAG2.26 [401902]
          PaymentLine.SetFilter(Amount,'<>%1',0);
          //+MAG2.26 [401902]
            if PaymentLine.FindSet(true) then
                repeat
                    //-MAG2.02 [264711]
                    if not LastPostingDocExists(PaymentLine) then begin
                        PaymentLine.Amount += PaymentLine."Last Amount";
                        PaymentLine."Last Amount" := 0;
                        PaymentLine."Last Posting No." := '';
                    end;
                    //+MAG2.02 [264711]
                    //-MAG2.01 [251964]
                    if PaymentLine2.Get(DATABASE::"Sales Invoice Header", 0, DocNo, PaymentLine."Line No.") then
                        PaymentLine2.Delete;
                    //+MAG2.01 [251964]
                    PaymentLine2.Init;
                    PaymentLine2 := PaymentLine;
                    PaymentLine2."Document Table No." := DATABASE::"Sales Invoice Header";
                    PaymentLine2."Document Type" := 0;
                    PaymentLine2."Document No." := DocNo;
                    PaymentLine2."Posting Date" := "Posting Date";
                    PaymentLine2.Insert;

                    OutstandingAmt := TotalAmountInclVAT - PaymentAmt;
                    if (PaymentLine."Payment Type" = PaymentLine."Payment Type"::"Payment Method") and (PaymentLine.Amount > OutstandingAmt) then begin
                        PaymentLine2.Amount := OutstandingAmt;
                        PaymentLine2.Modify;

                        PaymentLine.Amount := PaymentLine.Amount - OutstandingAmt;
                        //-MAG2.02 [264711]
                        //  PaymentLine.MODIFY;
                        //END ELSE
                        //  PaymentLine.DELETE;
                    end else
                        PaymentLine.Amount := 0;
                    PaymentLine."Last Amount" := PaymentLine2.Amount;
                    PaymentLine."Last Posting No." := DocNo;
                    PaymentLine.Modify;
                    //+MAG2.02 [264711]

                    PaymentAmt += PaymentLine2.Amount;
                until (PaymentLine.Next = 0) or (PaymentAmt = TotalAmountInclVAT);
        end;
    end;

    local procedure PostMagentoPayment(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesInvHdrNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if not HasMagentoPayment(DATABASE::"Sales Invoice Header", 0, SalesInvHdrNo) then
            exit;

        SalesInvHeader.Get(SalesInvHdrNo);
        SalesInvHeader.CalcFields("Amount Including VAT");
        PostPaymentLines(SalesHeader, SalesInvHeader."No.", GenJnlPostLine);
        Commit;

        //-MAG2.01 [253877]
        //CaptureSalesInvHeader(SalesInvHeader);
        CaptureSalesInvoice(SalesInvHeader);
        //+MAG2.01 [253877]
        Commit;

        //-MAG2.17 [302179]
        OnAfterPostMagentoPayment(SalesInvHeader);
        //+MAG2.17 [302179]
    end;

    procedure PostPaymentLine(var PaymentLine: Record "Magento Payment Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        GenJnlLine: Record "Gen. Journal Line";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if PaymentLine.Posted then
            exit;

        //-MAG2.26 [401902]
        if PaymentLine.Amount = 0 then begin
          PaymentLine.Posted := true;
          PaymentLine.Modify(true);
          exit;
        end;
        //+MAG2.26 [401902]

        //-MAG2.01 [256733]
        PaymentLine.TestField("Account No.");
        //-MAG2.07 [289527]
        //IF NOT HasOpenInvoiceEntry(PaymentLine) THEN BEGIN
        if not HasOpenEntry(PaymentLine) then begin
            //+MAG2.07 [289527]
            PaymentLine.Posted := true;
            PaymentLine.Modify;
            Commit;
            exit;
        end;
        //+MAG2.01 [256733]

        //-MAG2.17 [302179]
        OnBeforePostPaymentLine(PaymentLine);
        //+MAG2.17 [302179]

        case PaymentLine."Document Table No." of
            DATABASE::"Sales Invoice Header":
                begin
                    SalesInvHeader.Get(PaymentLine."Document No.");
                    //-MAG2.17 [302179]
                    //MagentoGiftVoucherMgt.PostVoucherPayment(PaymentLine,SalesInvHeader);
                    //+MAG2.17 [302179]
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
        PaymentLine: Record "Magento Payment Line";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice:
                begin
                    PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Invoice Header");
                    PaymentLine.SetRange("Document Type", 0);
                    PaymentLine.SetRange("Document No.", DocNo);
                    PaymentLine.SetFilter("Account No.", '<>%1', '');
              //-MAG2.26 [401902]
              // PaymentLine.SETFILTER(Amount,'<>%1',0);
              //+MAG2.26 [401902]
                    if not PaymentLine.FindSet then
                        exit;
                    repeat
                        //-MAG2.05 [278054]
                        ////-MAG2.01 [256733]
                        ////PostPaymentLine(PaymentLine,GenJnlPostLine);
                        //IF NOT PostPaymentLine(PaymentLine,GenJnlPostLine) THEN
                        //  MESSAGE(GETLASTERRORTEXT);
                        ////+MAG2.01 [256733]
                        PostPaymentLine(PaymentLine, GenJnlPostLine);
                        //+MAG2.05 [278054]
                    until PaymentLine.Next = 0;
                end;
        end;
    end;

    local procedure SetupGenJnlLineInvoice(SalesInvHeader: Record "Sales Invoice Header"; PaymentLine: Record "Magento Payment Line"; var GenJnlLine: Record "Gen. Journal Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        SourceCode: Code[10];
    begin
        PaymentLine.TestField("Document Table No.", DATABASE::"Sales Invoice Header");
        SalesInvHeader.TestField("No.", PaymentLine."Document No.");

        SourceCodeSetup.Get;
        SourceCode := SourceCodeSetup.Sales;

        with SalesInvHeader do begin
            GenJnlLine.Init;
            GenJnlLine."Posting Date" := PaymentLine."Posting Date";
            GenJnlLine."Document Date" := PaymentLine."Posting Date";
            GenJnlLine.Description := PaymentLine.Description;
            GenJnlLine."Shortcut Dimension 1 Code" := "Shortcut Dimension 1 Code";
            GenJnlLine."Shortcut Dimension 2 Code" := "Shortcut Dimension 2 Code";
            GenJnlLine."Dimension Set ID" := "Dimension Set ID";
            GenJnlLine."Reason Code" := "Reason Code";
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
          //-MAG2.26 [384262]
          GenJnlLine.Validate("Account No.","Bill-to Customer No.");
          //+MAG2.26 [384262]
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
            if PaymentLine.Amount < 0 then
                GenJnlLine."Document Type" := GenJnlLine."Document Type"::Refund;
            GenJnlLine."Document No." := "No.";
            GenJnlLine."External Document No." := "External Document No.";
            case PaymentLine."Account Type" of
                PaymentLine."Account Type"::"G/L Account":
                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
                PaymentLine."Account Type"::"Bank Account":
                    GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
            end;
          //-MAG2.26 [384262]
          GenJnlLine.Validate("Bal. Account No.",PaymentLine."Account No.");
          //+MAG2.26 [384262]
            GenJnlLine."Currency Code" := "Currency Code";
            GenJnlLine.Amount := -PaymentLine.Amount;
            GenJnlLine."Source Currency Code" := "Currency Code";
            GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
            GenJnlLine.Correction := Correction;
            //-MAG2.02 [264986]
            //GenJnlLine."Amount (LCY)" := -PaymentLine.Amount;
            //+MAG2.02 [264986]
            if "Currency Code" = '' then
                GenJnlLine."Currency Factor" := 1
            else
                GenJnlLine."Currency Factor" := "Currency Factor";
            //-MAG2.02 [264986]
            GenJnlLine.Validate(Amount);
            //+MAG2.02 [264986]
            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
            if PaymentLine.Amount < 0 then
                GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Payment;
            GenJnlLine."Applies-to Doc. No." := "No.";
            GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
            GenJnlLine."Source No." := "Bill-to Customer No.";
            GenJnlLine."Source Code" := SourceCode;
            GenJnlLine."Salespers./Purch. Code" := "Salesperson Code";
            GenJnlLine."Allow Zero-Amount Posting" := true;
        end;
    end;

    local procedure "--- Refund Payment"()
    begin
    end;

    local procedure InsertRefundPaymentLines(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "Magento Payment Line";
        PaymentLine2: Record "Magento Payment Line";
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

        with SalesHeader do begin
            RefundAmt := 0;
            PaymentLine.Reset;
            PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
            PaymentLine.SetRange("Document Type", "Document Type");
            PaymentLine.SetRange("Document No.", "No.");
          //-MAG2.26 [401902]
          PaymentLine.SetFilter(Amount,'<>%1',0);
          //+MAG2.26 [401902]
            if PaymentLine.FindSet(true) then
                repeat
                    //-MAG2.02 [264711]
                    if not LastPostingDocExists(PaymentLine) then begin
                        PaymentLine.Amount += PaymentLine."Last Amount";
                        PaymentLine."Last Amount" := 0;
                        PaymentLine."Last Posting No." := '';
                    end;
                    //+MAG2.02 [264711]
                    if PaymentLine2.Get(DATABASE::"Sales Cr.Memo Header", 0, DocNo, PaymentLine."Line No.") then
                        PaymentLine2.Delete;
                    PaymentLine2.Init;
                    PaymentLine2 := PaymentLine;
                    PaymentLine2."Document Table No." := DATABASE::"Sales Cr.Memo Header";
                    PaymentLine2."Document Type" := 0;
                    PaymentLine2."Document No." := DocNo;
                    PaymentLine2."Posting Date" := "Posting Date";
                    PaymentLine2.Insert;

                    OutstandingAmt := TotalAmountInclVAT - RefundAmt;
                    if (PaymentLine."Payment Type" = PaymentLine."Payment Type"::"Payment Method") and (PaymentLine.Amount > OutstandingAmt) then begin
                        PaymentLine2.Amount := OutstandingAmt;
                        PaymentLine2.Modify;
                        PaymentLine.Amount := PaymentLine.Amount - OutstandingAmt;
                        //-MAG2.02 [264711]
                        //  PaymentLine.MODIFY;
                        //END ELSE
                        //  PaymentLine.DELETE;
                    end else
                        PaymentLine.Amount := 0;
                    PaymentLine."Last Amount" := PaymentLine2.Amount;
                    PaymentLine."Last Posting No." := DocNo;
                    PaymentLine.Modify;
                    //+MAG2.02 [264711]

                    RefundAmt += PaymentLine2.Amount;
                until (PaymentLine.Next = 0) or (RefundAmt = TotalAmountInclVAT);
        end;
    end;

    local procedure RefundSalesCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if not HasMagentoPayment(DATABASE::"Sales Cr.Memo Header", 0, SalesCrMemoHeader."No.") then
            exit;

        RefundPaymentLines(SalesCrMemoHeader);
    end;

    procedure RefundPaymentLine(PaymentLine: Record "Magento Payment Line")
    var
        PaymentGateway: Record "Magento Payment Gateway";
        ErrorText: Text;
    begin
        if PaymentLine."Date Refunded" <> 0D then
            exit;
        //-MAG2.26 [401902]
        if PaymentLine.Amount = 0 then begin
          PaymentLine."Date Refunded" := Today;
          PaymentLine.Modify(true);
          exit;
        end;
        //+MAG2.26 [401902]
        if PaymentLine."Payment Gateway Code" = '' then
            exit;
        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;
        if PaymentGateway."Refund Codeunit Id" = 0 then
            exit;

        //-MAG2.21 [355176]
        // RefundPaymentEvent(PaymentGateway,PaymentLine);
        asserterror
        begin
            RefundPaymentEvent(PaymentGateway, PaymentLine);
            Commit;
            Error('');
        end;
        ErrorText := GetLastErrorText;
        if ErrorText <> '' then
            Message(Text005, CopyStr(ErrorText, 1, 900));
        //+MAG2.21 [355176]
    end;

    procedure RefundPaymentLines(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        PaymentLine: Record "Magento Payment Line";
        PrevRec: Text;
    begin
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        //-MAG2.26 [401902]
        //PaymentLine.SETFILTER(Amount,'<>%1',0);
        //+MAG2.26 [401902]
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
    local procedure RefundPaymentEvent(PaymentGateway: Record "Magento Payment Gateway"; var PaymentLine: Record "Magento Payment Line")
    begin
    end;

    local procedure "--- Cancel Payment"()
    begin
    end;

    local procedure CancelPaymentLine(var PaymentLine: Record "Magento Payment Line")
    var
        PaymentGateway: Record "Magento Payment Gateway";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit;
        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;
        //-MAG2.26 [401902]
        if PaymentLine.Amount = 0 then
          exit;
        //+MAG2.26 [401902]
        if PaymentGateway."Cancel Codeunit Id" = 0 then
            exit;

        CancelPaymentEvent(PaymentGateway, PaymentLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure CancelPaymentEvent(PaymentGateway: Record "Magento Payment Gateway"; var PaymentLine: Record "Magento Payment Line")
    begin
    end;

    local procedure "--- Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPayment(SalesHeader: Record "Sales Header")
    begin
        //-MAG2.17 [302179]
        //+MAG2.17 [302179]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentLine(var PaymentLine: Record "Magento Payment Line")
    begin
        //-MAG2.17 [302179]
        //+MAG2.17 [302179]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostMagentoPayment(SalesInvHeader: Record "Sales Invoice Header")
    begin
        //-MAG2.17 [302179]
        //+MAG2.17 [302179]
    end;
}

