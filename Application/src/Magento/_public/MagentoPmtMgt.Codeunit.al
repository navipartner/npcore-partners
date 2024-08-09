codeunit 6151416 "NPR Magento Pmt. Mgt."
{
    TableNo = "NPR Magento Payment Line";

    trigger OnRun()
    var
        NotInitialized: Label 'Codeunit 6151416 wasn''t initialized properly. This is a programming bug, not a user error. Please contact system vendor.';
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        PGInteractionLog: Record "NPR PG Interaction Log Entry";
        Request: Record "NPR PG Payment Request";
        Response: Record "NPR PG Payment Response";
        TryCapturePayment: Codeunit "NPR PG Try Capture Payment";
        TryRefundPayment: Codeunit "NPR PG Try Refund Payment";
        TryCancelPayment: Codeunit "NPR PG Try Cancel Payment";
        Success: Boolean;
        PrevRec: Text;
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        if (not (_PaymentEventType in [_PaymentEventType::Capture, _PaymentEventType::Refund, _PaymentEventType::Cancel])) then
            Error(NotInitialized);

        case _PaymentEventType of
            _PaymentEventType::Capture:
                LogMgt.LogCaptureStart(PGInteractionLog, Rec.SystemId);
            _PaymentEventType::Refund:
                LogMgt.LogRefundStart(PGInteractionLog, Rec.SystemId);
            _PaymentEventType::Cancel:
                LogMgt.LogCancelStart(PGInteractionLog, Rec.SystemId);
        end;

        Commit();

        PaymentLine := Rec;

        PaymentLine.ToRequest(Request);

        ClearLastError();
        case _PaymentEventType of
            _PaymentEventType::Capture:
                begin
                    TryCapturePayment.SetParameters(Request, Response);
                    Success := TryCapturePayment.Run(PaymentLine);
                    TryCapturePayment.GetParameters(Request, Response);
                end;
            _PaymentEventType::Refund:
                begin
                    TryRefundPayment.SetParameters(Request, Response);
                    Success := TryRefundPayment.Run(PaymentLine);
                    TryRefundPayment.GetParameters(Request, Response);
                end;
            _PaymentEventType::Cancel:
                begin
                    TryCancelPayment.SetParameters(Request, Response);
                    Success := TryCancelPayment.Run(PaymentLine);
                    TryCancelPayment.GetParameters(Request, Response);
                end;
        end;

        LogMgt.LogOperationFinished(PGInteractionLog, Request, Response, Success, GetLastErrorText());

        Commit();

        PrevRec := Format(PaymentLine);

        if (Response."Response Success") then
            case _PaymentEventType of
                _PaymentEventType::Capture:
                    begin
                        if (Response."Response Operation Id" <> '') then
#pragma warning disable AA0139
                            PaymentLine."Charge ID" := Response."Response Operation Id";
#pragma warning restore AA0139
                        PaymentLine."Date Captured" := Today();
                    end;
                _PaymentEventType::Refund:
                    PaymentLine."Date Refunded" := Today();
                _PaymentEventType::Cancel:
                    begin
                        PaymentLine."Date Canceled" := Today();
                        if PaymentLine."Date Captured" = 0D then begin
                            PaymentLine.Amount := 0;
                            PaymentLine."Requested Amount" := PaymentLine.Amount;
                        end;
                    end;
            end;

        OnAfterProcessingPaymentLine(PaymentLine, _PaymentEventType, Response);
        if (PrevRec <> Format(PaymentLine)) then
            PaymentLine.Modify(true);

        Commit();

        Rec := PaymentLine;

        if (not Success) then
            Error(ErrorDuringOperationErr, GetLastErrorText());
    end;

    var
        _PaymentEventType: Option " ",Capture,Refund,Cancel;
        Text000: Label 'Error during Payment Capture:\%1', Comment = '%1 = error message';
        Text004: Label 'You may not invoice more than the paid amount %1.', Comment = '%1 = Paid Amount';
        Text005: Label 'Error during Payment Refund:\%1', Comment = '%1 = error message';
        Text006: Label 'Document not Found';
        ErrorDuringOperationErr: Label 'An error occurred during the payment operation. Error message:\\%1', Comment = '%1 = error message';

    procedure SetProcessingOptions(PaymentEventTypeIn: Option " ",Capture,Refund,Cancel)
    begin
        _PaymentEventType := PaymentEventTypeIn;
    end;

    #region Base app subscribers
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesDocument', '', true, true)]
    local procedure CopySalesDoc(FromDocumentType: Option; FromDocumentNo: Code[20]; IncludeHeader: Boolean; var ToSalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        PaymentLineBal: Record "NPR Magento Payment Line";
    begin
        if not IncludeHeader then
            exit;
        if not ToSalesHeader.IsCreditDocType() then
            exit;

        case "Sales Document Type From".FromInteger(FromDocumentType) of
            "Sales Document Type From"::Order:
                begin
                    PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
                    PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
                    PaymentLine.SetRange("Document No.", FromDocumentNo);
                end;
            "Sales Document Type From"::Invoice:
                begin
                    PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
                    PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Invoice);
                    PaymentLine.SetRange("Document No.", FromDocumentNo);
                end;
            "Sales Document Type From"::"Posted Invoice":
                begin
                    PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
                    PaymentLine.SetRange("Document Type", 0);
                    PaymentLine.SetRange("Document No.", FromDocumentNo);
                end;
            else
                exit;
        end;
        if PaymentLine.IsEmpty() then
            exit;

        PaymentLine.FindSet();
        repeat
            if PaymentLine2.Get(Database::"Sales Header", ToSalesHeader."Document Type", ToSalesHeader."No.", PaymentLine."Line No.") then
                PaymentLine2.Delete();
            PaymentLine2.Init();
            PaymentLine2 := PaymentLine;
            PaymentLine2."Document Table No." := Database::"Sales Header";
            PaymentLine2."Document Type" := ToSalesHeader."Document Type";
            PaymentLine2."Document No." := ToSalesHeader."No.";
            PaymentLine2.Posted := false;
            PaymentLine2."Last Amount" := 0;
            PaymentLine2."Posting Date" := ToSalesHeader."Posting Date";
            PaymentLine2.Insert(true);

            if (PaymentLine."Payment Type" = PaymentLine."Payment Type"::"Payment Method") and (PaymentLine."Account No." <> '') and (PaymentLine.Amount <> 0) then
                PaymentLineBal := PaymentLine;
        until PaymentLine.Next() = 0;

        if (ToSalesHeader."Applies-to Doc. No." <> '') or (ToSalesHeader."Applies-to ID" <> '') then
            exit;

        ToSalesHeader.Validate("Payment Method Code");
        if PaymentLineBal."Account No." <> '' then begin
            ToSalesHeader."Bal. Account Type" := PaymentLineBal."Account Type";
            ToSalesHeader."Bal. Account No." := PaymentLineBal."Account No.";
        end;
        ToSalesHeader.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterDeleteEvent', '', true, true)]
    local procedure SalesHeaderOnDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        MagentoPmtAdyenMgt: Codeunit "NPR Magento Pmt. Adyen Mgt.";
    begin
        if Rec.IsTemporary then
            exit;
        if not HasMagentoPayment(Database::"Sales Header", Rec."Document Type", Rec."No.") then
            exit;

        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", Rec."Document Type");
        PaymentLine.SetRange("Document No.", Rec."No.");
        if PaymentLine.IsEmpty then
            exit;

        if RunTrigger then
            if not Rec.IsCreditDocType() then begin
                PaymentLine.FindSet();
                repeat
                    MagentoPmtAdyenMgt.CheckUnproccesedWebhook(PaymentLine);
                    CancelPaymentLine(PaymentLine);
                    MagentoPmtAdyenMgt.SetShowCancelMsg(false);
                    MagentoPmtAdyenMgt.CancelPayByLink(PaymentLine);
                until PaymentLine.Next() = 0;
            end;

        PaymentLine.DeleteAll(true);
    end;
    #endregion

    #region Helper functions
    local procedure CheckPayment(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentAmt: Decimal;
        TotalAmountInclVAT: Decimal;
    begin
        if not HasMagentoPayment(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        if HasAllowAdjustAmount(SalesHeader) then
            exit;

        TotalAmountInclVAT := GetTotalAmountInclVat(SalesHeader);
        SalesHeader.CalcFields("NPR Magento Payment Amount");
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        PaymentLine.CalcSums(Amount);
        PaymentAmt := PaymentLine.Amount;

        PaymentLine.SetRange(Amount);
        PaymentLine.SetFilter("Last Amount", '<>%1', 0);
        if not PaymentLine.IsEmpty then begin
            PaymentLine.FindSet();
            repeat
                if not LastPostingDocExists(PaymentLine) then
                    PaymentAmt += PaymentLine."Last Amount";
            until PaymentLine.Next() = 0;
        end;
        if PaymentAmt < TotalAmountInclVAT then
            Error(Text004, PaymentAmt);

        OnCheckPayment(SalesHeader);
    end;

    internal procedure OpenMagentPaymentLinesFromSalesHeader(SalesHeade: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document No.", SalesHeade."No.");
        PaymentLine.SetRange("Document Type", SalesHeade."Document Type");
        Page.Run(0, PaymentLine);
    end;

    internal procedure OpenMagentPaymentLinesFromSalesCreditMemoHeader(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        Page.Run(0, PaymentLine);
    end;

    local procedure HasAllowAdjustAmount(SalesHeader: Record "Sales Header"): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Allow Adjust Amount", true);
        exit(PaymentLine.FindFirst());
    end;

    local procedure HasMagentoPayment(DocTableNo: Integer; DocType: Enum "Sales Document Type"; DocNo: Code[20]): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", DocTableNo);
        PaymentLine.SetRange("Document Type", DocType);
        PaymentLine.SetRange("Document No.", DocNo);
        exit(PaymentLine.FindFirst());
    end;

    local procedure HasOpenEntry(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if (PaymentLine."Document Table No." <> Database::"Sales Invoice Header") or (PaymentLine."Document No." = '') then
            exit(false);
        if not SalesInvHeader.Get(PaymentLine."Document No.") then
            exit(false);

        CustLedgerEntry.SetCurrentKey("Customer No.", Open, Positive, "Due Date", "Currency Code");
        CustLedgerEntry.SetRange("Customer No.", SalesInvHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Positive, PaymentLine.Amount >= 0);
        CustLedgerEntry.SetRange("Document No.", SalesInvHeader."No.");
        exit(CustLedgerEntry.FindFirst());
    end;

    local procedure LastPostingDocExists(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if PaymentLine."Last Posting No." = '' then
            exit(false);
        if PaymentLine."Document Table No." <> Database::"Sales Header" then
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
        TempVATAmountLine.DeleteAll();
        TempSalesLine.DeleteAll();
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 1);
        TempSalesLine.CalcVATAmountLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TotalAmountInclVAT := TempVATAmountLine.GetTotalAmountInclVAT();
        GeneralLedgerSetup.Get();
        TotalAmountInclVAT := Round(TotalAmountInclVAT, GeneralLedgerSetup."Amount Rounding Precision");
        exit(TotalAmountInclVAT);
    end;

    internal procedure ShowDocumentCard(PaymentLine: Record "NPR Magento Payment Line")
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

        exit(RecRef.FindFirst());
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
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.CalcSums(Amount);
        if PaymentLine.Amount >= TotalAmountInclVAT then
            exit;

        AdjustmentAmt := TotalAmountInclVAT - PaymentLine.Amount;

        Clear(PaymentLine);
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Allow Adjust Amount", true);
        PaymentLine.FindFirst();
        PaymentLine.Amount += AdjustmentAmt;
        PaymentLine.Modify();
    end;

    internal procedure GetMagentoPaymentLineLastLineNo(TableNo: Integer; SalesDocumentType: Enum "Sales Document Type"; SalesDocumentNo: Code[20]) LastLineNo: Integer;
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("Document Table No.", TableNo);
        MagentoPaymentLine.SetRange("Document Type", SalesDocumentType);
        MagentoPaymentLine.SetRange("Document No.", SalesDocumentNo);
        MagentoPaymentLine.SetLoadFields("Document Table No.", "Document Type", "Document Table No.", "Line No.");
        if not MagentoPaymentLine.FindLast() then
            exit;

        LastLineNo := MagentoPaymentLine."Line No."
    end;
    #endregion

    #region Sales Doc posting
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLines', '', true, false)]
    local procedure InsertRefundPaymentLinesSalesCrMemo(var SalesHeader: Record "Sales Header")
    begin
        if not SalesHeader.IsCreditDocType() then
            exit;
        if (not SalesHeader.Invoice) and (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order") then
            exit;
        if not HasMagentoPayment(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        InsertRefundPaymentLines(SalesHeader);
    end;

    local procedure InsertRefundPaymentLines(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
#IF NOT BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
#ENDIF
        OutstandingAmt: Decimal;
        RefundAmt: Decimal;
        TotalAmountInclVAT: Decimal;
        DocNo: Code[20];
    begin
        if not HasMagentoPayment(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        TotalAmountInclVAT := GetTotalAmountInclVat(SalesHeader);
        DocNo := SalesHeader."Posting No.";
        if DocNo = '' then begin
            NoSeriesMgt.SetNoSeriesLineFilter(NoSeriesLine, SalesHeader."Posting No. Series", 0D);
            NoSeriesLine.FindLast();
            DocNo := NoSeriesLine."Last No. Used";
        end;

        RefundAmt := 0;
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange(Posted, false);
        PaymentLine.SetFilter(Amount, '<>%1', 0);
        if PaymentLine.FindSet(true) then
            repeat
                if not LastPostingDocExists(PaymentLine) then begin
                    PaymentLine.Amount += PaymentLine."Last Amount";
                    PaymentLine."Last Amount" := 0;
                    PaymentLine."Last Posting No." := '';
                end;
                if PaymentLine2.Get(Database::"Sales Cr.Memo Header", 0, DocNo, PaymentLine."Line No.") then
                    PaymentLine2.Delete();
                PaymentLine2.Init();
                PaymentLine2 := PaymentLine;
                PaymentLine2."Document Table No." := Database::"Sales Cr.Memo Header";
                PaymentLine2."Document Type" := Enum::"Sales Document Type".FromInteger(0);
                PaymentLine2."Document No." := DocNo;
                PaymentLine2."Posting Date" := SalesHeader."Posting Date";
                PaymentLine2.Insert();
#IF NOT BC17
                SpfyAssignedIDMgt.CopyAssignedShopifyID(PaymentLine.RecordId(), PaymentLine2.RecordId(), "NPR Spfy ID Type"::"Entry ID");
#ENDIF

                OutstandingAmt := TotalAmountInclVAT - RefundAmt;
                if (PaymentLine."Payment Type" = PaymentLine."Payment Type"::"Payment Method") and (PaymentLine.Amount > OutstandingAmt) then begin
                    PaymentLine2.Amount := OutstandingAmt;
                    PaymentLine2.Modify();
                    PaymentLine.Amount := PaymentLine.Amount - OutstandingAmt;
                end else
                    PaymentLine.Amount := 0;
                PaymentLine."Last Amount" := PaymentLine2.Amount;
                PaymentLine."Last Posting No." := DocNo;
                PaymentLine.Posted := PaymentLine.Amount = 0;
                PaymentLine.Modify();

                RefundAmt += PaymentLine2.Amount;
            until (PaymentLine.Next() = 0) or (RefundAmt = TotalAmountInclVAT);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLines', '', true, false)]
    local procedure InsertPaymentLinesSalesInvoice(var SalesHeader: Record "Sales Header")
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice]) then
            exit;
        if (not SalesHeader.Invoice) and (SalesHeader."Document Type" = SalesHeader."Document Type"::Order) then
            exit;
        AdjustPaymentAmount(SalesHeader);
        if not HasMagentoPayment(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        InsertPaymentLines(SalesHeader);
    end;

    local procedure InsertPaymentLines(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
#IF NOT BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
#ENDIF
        OutstandingAmt: Decimal;
        PaymentAmt: Decimal;
        TotalAmountInclVAT: Decimal;
        DocNo: Code[20];
    begin
        if not HasMagentoPayment(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        TotalAmountInclVAT := GetTotalAmountInclVat(SalesHeader);
        DocNo := SalesHeader."Posting No.";
        if DocNo = '' then begin
            NoSeriesMgt.SetNoSeriesLineFilter(NoSeriesLine, SalesHeader."Posting No. Series", 0D);
            NoSeriesLine.FindLast();
            DocNo := NoSeriesLine."Last No. Used";
        end;

        PaymentAmt := 0;
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
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
                if PaymentLine2.Get(Database::"Sales Invoice Header", 0, DocNo, PaymentLine."Line No.") then
                    PaymentLine2.Delete();
                PaymentLine2.Init();
                PaymentLine2 := PaymentLine;
                PaymentLine2."Document Table No." := Database::"Sales Invoice Header";
                PaymentLine2."Document Type" := Enum::"Sales Document Type".FromInteger(0);
                PaymentLine2."Document No." := DocNo;
                PaymentLine2."Posting Date" := SalesHeader."Posting Date";
                PaymentLine2.Insert();
#IF NOT BC17
                SpfyAssignedIDMgt.CopyAssignedShopifyID(PaymentLine.RecordId(), PaymentLine2.RecordId(), "NPR Spfy ID Type"::"Entry ID");
#ENDIF

                OutstandingAmt := TotalAmountInclVAT - PaymentAmt;
                if (PaymentLine."Payment Type" = PaymentLine."Payment Type"::"Payment Method") and (PaymentLine.Amount > OutstandingAmt) then begin
                    PaymentLine2.Amount := OutstandingAmt;
                    PaymentLine2.Modify();

                    PaymentLine.Amount := PaymentLine.Amount - OutstandingAmt;
                end else
                    PaymentLine.Amount := 0;
                PaymentLine."Last Amount" := PaymentLine2.Amount;
                PaymentLine."Last Posting No." := DocNo;
                PaymentLine.Modify();

                PaymentAmt += PaymentLine2.Amount;
            until (PaymentLine.Next() = 0) or (PaymentAmt = TotalAmountInclVAT);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', true, true)]
    local procedure Cu80OnBeforePostSalesInvoice(var SalesHeader: Record "Sales Header")
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order]) then
            exit;
        if not SalesHeader.Invoice then
            exit;
        if not HasMagentoPayment(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.") then
            exit;

        SalesHeader."Bal. Account No." := '';
        CheckPayment(SalesHeader);
    end;
    #endregion

    #region Posting payment lines
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure Cu80OnAfterPostSalesInvoice(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesInvHdrNo: Code[20])
    begin
        if SalesInvHdrNo = '' then
            exit;

        PostMagentoPayment(SalesHeader, GenJnlPostLine, SalesInvHdrNo);
    end;

    local procedure PostMagentoPayment(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesInvHdrNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        if not HasMagentoPayment(Database::"Sales Invoice Header", Enum::"Sales Document Type".FromInteger(0), SalesInvHdrNo) then
            exit;

        SalesInvHeader.Get(SalesInvHdrNo);
        SalesInvHeader.CalcFields("Amount Including VAT");
        PostPaymentLines(SalesHeader, SalesInvHeader."No.", GenJnlPostLine);
        Commit();

        CaptureSalesInvoice(SalesInvHeader);
        Commit();

        OnAfterPostMagentoPayment(SalesInvHeader);
    end;

    internal procedure PostPaymentLine(var PaymentLine: Record "NPR Magento Payment Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
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
            PaymentLine.Modify();
            Commit();
            exit;
        end;

        OnBeforePostPaymentLine(PaymentLine);

        case PaymentLine."Document Table No." of
            Database::"Sales Invoice Header":
                begin
                    SalesInvHeader.Get(PaymentLine."Document No.");
                    SetupGenJnlLineInvoice(SalesInvHeader, PaymentLine, GenJnlLine);
                end;
            else
                exit;
        end;

        GenJnlPostLine.RunWithCheck(GenJnlLine);
        PaymentLine.Posted := true;
        PaymentLine.Modify();
        InsertPostingLog(PaymentLine, true);
        Commit();
    end;

    procedure InsertPostingLog(var MagentoPaymentLine: Record "NPR Magento Payment Line"; Success: Boolean)
    var
        PGPostingLogEntry: Record "NPR PG Posting Log Entry";
    begin
        PGPostingLogEntry.Init();
        PGPostingLogEntry."Payment Line System Id" := MagentoPaymentLine.SystemId;
        PGPostingLogEntry.Success := Success;
        if not Success then
            PGPostingLogEntry."Error Description" := CopyStr(GetLastErrorText(), 1, MaxStrLen(PGPostingLogEntry."Error Description"));
        PGPostingLogEntry."Posting Timestamp" := CurrentDateTime();
        PGPostingLogEntry.Insert();
    end;

    local procedure PostPaymentLines(var SalesHeader: Record "Sales Header"; DocNo: Code[20]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice:
                begin
                    PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
                    PaymentLine.SetRange("Document Type", 0);
                    PaymentLine.SetRange("Document No.", DocNo);
                    PaymentLine.SetFilter("Account No.", '<>%1', '');
                    if not PaymentLine.FindSet() then
                        exit;
                    repeat
                        PostPaymentLine(PaymentLine, GenJnlPostLine);
                    until PaymentLine.Next() = 0;
                end;
        end;
    end;

    local procedure SetupGenJnlLineInvoice(SalesInvHeader: Record "Sales Invoice Header"; PaymentLine: Record "NPR Magento Payment Line"; var GenJnlLine: Record "Gen. Journal Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        SourceCode: Code[10];
    begin
        PaymentLine.TestField("Document Table No.", Database::"Sales Invoice Header");
        SalesInvHeader.TestField("No.", PaymentLine."Document No.");

        SourceCodeSetup.Get();
        SourceCode := SourceCodeSetup.Sales;

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PaymentLine."Posting Date";
        GenJnlLine."Document Date" := PaymentLine."Posting Date";
        GenJnlLine.Description := PaymentLine.Description;
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
        GenJnlLine."Shortcut Dimension 1 Code" := SalesInvHeader."Shortcut Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := SalesInvHeader."Shortcut Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := SalesInvHeader."Dimension Set ID";
    end;


    #endregion

    #region Capture
    internal procedure CapturePaymentLine(var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        MagentPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        ErrorText: Text;
    begin
        if PaymentLine."Date Captured" <> 0D then
            exit;

        if PaymentLine.Amount = 0 then begin
            PaymentLine."Date Captured" := Today();
            PaymentLine.Modify(true);
            exit;
        end;

        if not (PaymentLine."Document Table No." in [Database::"Sales Header", Database::"Sales Invoice Header"]) then
            exit;

        if (not PaymentGateway.Get(PaymentLine."Payment Gateway Code")) then
            exit;

        if (not PaymentGateway."Enable Capture") then
            exit;

        PaymentGateway.EnsureIntegrationTypeSelected();

        Commit();
        Clear(MagentPmtMgt);
        MagentPmtMgt.SetProcessingOptions(_PaymentEventType::Capture);
        if (not MagentPmtMgt.Run(PaymentLine)) then begin
            ErrorText := GetLastErrorText();
            if ErrorText <> '' then
                Message(Text000, CopyStr(ErrorText, 1, 900));
        end;
    end;

    internal procedure CaptureSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetRange("Date Captured", 0D);
        if PaymentLine.FindSet() then
            repeat
                CapturePaymentLine(PaymentLine);
            until PaymentLine.Next() = 0;
    end;

    internal procedure CaptureSalesHeader(SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
        SalesHeaderCannotBeCreditType: Label 'Only Sales Headers that are not of credit type can be captured.';
    begin
        if (SalesHeader.IsCreditDocType()) then
            Error(SalesHeaderCannotBeCreditType);

        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetRange("Date Captured", 0D);
        if (PaymentLine.FindSet(true)) then
            repeat
                PaymentLine2 := PaymentLine;
                CapturePaymentLine(PaymentLine2);
            until PaymentLine.Next() = 0;
    end;
    #endregion

    #region Refund
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', true, true)]
    local procedure Cu80OnAfterPostSalesCrMemo(var SalesHeader: Record "Sales Header"; SalesCrMemoHdrNo: Code[20])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if SalesCrMemoHdrNo = '' then
            exit;
        if not SalesCrMemoHeader.Get(SalesCrMemoHdrNo) then
            exit;
        if not HasMagentoPayment(Database::"Sales Cr.Memo Header", Enum::"Sales Document Type".FromInteger(0), SalesCrMemoHeader."No.") then
            exit;

        RefundSalesCreditMemo(SalesCrMemoHeader);
    end;

    internal procedure RefundSalesCreditMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if not HasMagentoPayment(Database::"Sales Cr.Memo Header", Enum::"Sales Document Type".FromInteger(0), SalesCrMemoHeader."No.") then
            exit;

        RefundPaymentLines(SalesCrMemoHeader);
    end;

    internal procedure RefundSalesHeader(SalesHeader: Record "Sales Header")
    var
        SalesHeaderMustBeCreditType: Label 'Only Sales Headers that are of the credit type can be refunded.';
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLine2: Record "NPR Magento Payment Line";
    begin
        if (not SalesHeader.IsCreditDocType()) then
            Error(SalesHeaderMustBeCreditType);

        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetRange("Date Refunded", 0D);
        if (PaymentLine.FindSet(true)) then
            repeat
                PaymentLine2 := PaymentLine;
                RefundPaymentLine(PaymentLine2);
            until PaymentLine.Next() = 0;
    end;

    internal procedure RefundPaymentLine(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        MagentPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        ErrorText: Text;
    begin
        if PaymentLine."Date Refunded" <> 0D then
            exit;
        if PaymentLine.Amount = 0 then begin
            PaymentLine."Date Refunded" := Today();
            PaymentLine.Modify(true);
            exit;
        end;

        if PaymentLine."Payment Gateway Code" = '' then
            exit;

        if (not PaymentGateway.Get(PaymentLine."Payment Gateway Code")) then
            exit;

        if (not PaymentGateway."Enable Refund") then
            exit;

        PaymentGateway.EnsureIntegrationTypeSelected();

        Commit();
        Clear(MagentPmtMgt);
        MagentPmtMgt.SetProcessingOptions(_PaymentEventType::Refund);
        if (not MagentPmtMgt.Run(PaymentLine)) then begin
            ErrorText := GetLastErrorText();
            if ErrorText <> '' then
                Message(Text005, CopyStr(ErrorText, 1, 900));
        end;
    end;

    internal procedure RefundPaymentLines(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PrevRec: Text;
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.SetFilter("Payment Gateway Code", '<>%1', '');
        PaymentLine.SetRange("Date Refunded", 0D);
        if PaymentLine.FindSet() then
            repeat
                PrevRec := Format(PaymentLine);
                RefundPaymentLine(PaymentLine);
                if PrevRec <> Format(PaymentLine) then
                    Commit();
            until PaymentLine.Next() = 0;
    end;
    #endregion

    #region Cancel
    procedure CancelPaymentLine(var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        ErrorText: Text;
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit;
        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;
        if PaymentLine.Amount = 0 then begin
            exit;
        end;
        if (not PaymentGateway."Enable Cancel") then
            exit;

        PaymentGateway.EnsureIntegrationTypeSelected();

        Commit();
        Clear(MagentoPmtMgt);
        MagentoPmtMgt.SetProcessingOptions(_PaymentEventType::Cancel);
        if (not MagentoPmtMgt.Run(PaymentLine)) then begin
            ErrorText := GetLastErrorText();
            if (ErrorText <> '') then
                Message(Text000, CopyStr(ErrorText, 1, 900));
        end;
    end;
    #endregion

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

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessingPaymentLine(var PaymentLine: Record "NPR Magento Payment Line"; PaymentEventType: Option " ",Capture,Refund,Cancel; Response: Record "NPR PG Payment Response")
    begin
    end;
}
