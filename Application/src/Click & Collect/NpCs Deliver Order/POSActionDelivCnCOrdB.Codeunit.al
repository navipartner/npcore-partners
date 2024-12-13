codeunit 6060069 "NPR POSAction Deliv. CnC Ord.B"
{
    Access = Internal;

    var
        EmptyLinesOnDocumentErr: Label 'Document ''%1'' has no lines to deliver.', Comment = '%1=NpCsDocument."Reference No."';
        SalesLineTypeNotSupportedErr: Label 'Supported types are %1, %2 and %3.', Comment = '%1=SalesLine.Type::"";%2=SalesLine.Type::Item;%3=SalesLine.Type::"G/L Account"';

    procedure FindAndConfirmDoc(var NpCsDocument: Record "NPR NpCs Document"; ReferenceNo: Text; LocationFilter: Text; SortingParam: Integer; ConfirmInvDiscAmt: Boolean; OpenDocument: Boolean): Boolean
    begin
        if not FindDocument(ReferenceNo, LocationFilter, SortingParam, NpCsDocument) then
            exit(false);

        if not ConfirmDocumentStatus(NpCsDocument) then
            exit(false);

        if not ConfirmOpenDocument(NpCsDocument, ConfirmInvDiscAmt, OpenDocument) then
            exit(false);
        exit(true);
    end;

    local procedure ConfirmOpenDocument(NpCsDocument: Record "NPR NpCs Document"; ConfirmInvDiscAmt: Boolean; OpenDocument: Boolean): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        PageMgt: Codeunit "Page Management";
    begin
        if ConfirmInvDiscAmt then begin
            SalesLine.SetRange("Document Type", NpCsDocument."Document Type");
            SalesLine.SetRange("Document No.", NpCsDocument."Document No.");
            SalesLine.SetFilter("Inv. Discount Amount", '>%1', 0);
            SalesLine.CalcSums("Inv. Discount Amount");
            if SalesLine."Inv. Discount Amount" > 0 then begin
                if not Confirm(SalesDocImpMgt.GetImportInvDiscAmtQst()) then
                    exit;
            end;
        end;
        if OpenDocument then begin
            SalesHeader."Document Type" := NpCsDocument."Document Type";
            SalesHeader."No." := NpCsDocument."Document No.";
            SalesHeader.SetRecFilter();
            exit(Page.RunModal(PageMgt.GetPageID(SalesHeader), SalesHeader) = Action::LookupOK);
        end;
        exit(true);
    end;

    local procedure ConfirmDocumentStatus(NpCsDocument: Record "NPR NpCs Document") Confirmed: Boolean
    var
        DeliveryStatusQst: Label 'Delivery Status is ''%1''.\Continue delivering %2 %3?', Comment = '%1=NpCsDocument."Processing Status";%2=NpCsDocument."Document Type";%3=NpCsDocument."Reference No."';
        ProcessingStatusQst: Label 'Processing Status is ''%1''.\Continue delivering %2 %3?', Comment = '%1=NpCsDocument."Processing Status";%2=NpCsDocument."Document Type";%3=NpCsDocument."Reference No."';
    begin
        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Ready then
            exit(true);

        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::" " then begin
            Confirmed := Confirm(ProcessingStatusQst, false, NpCsDocument."Processing Status", NpCsDocument."Document Type", NpCsDocument."Reference No.");
            exit(Confirmed);
        end;

        Confirmed := Confirm(DeliveryStatusQst, false, NpCsDocument."Delivery Status", NpCsDocument."Document Type", NpCsDocument."Reference No.");
        exit(Confirmed);
    end;

    local procedure FindDocument(ReferenceNo: Text; LocationFilter: Text; SortingParam: Integer; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if FindDocumentFromInput(ReferenceNo, NpCsDocument) then
            exit(true);

        if SelectDocument(LocationFilter, SortingParam, NpCsDocument) then
            exit(true);

        exit(false);
    end;

    local procedure FindDocumentFromInput(ReferenceNo: Text; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if ReferenceNo = '' then
            exit(false);

        NpCsDocument.SetRange("Reference No.", ReferenceNo);
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        exit(NpCsDocument.FindFirst());
    end;

    local procedure SelectDocument(LocationFilter: Text; SortingParam: Integer; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        Sorting: Option "Entry No.","Reference No.","Delivery expires at";
    begin
        Clear(NpCsDocument);
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Ready);
        if LocationFilter <> '' then
            NpCsDocument.SetFilter("Location Code", LocationFilter);
        case SortingParam of
            Sorting::"Entry No.":
                begin
                    NpCsDocument.SetCurrentKey("Entry No.");
                end;
            Sorting::"Reference No.":
                begin
                    NpCsDocument.SetCurrentKey("Reference No.");
                end;
            Sorting::"Delivery expires at":
                begin
                    NpCsDocument.SetCurrentKey("Delivery expires at");
                end;
        end;
        if Page.RunModal(Page::"NPR NpCs Coll. Store Orders", NpCsDocument) = Action::LookupOK then
            exit(true);

        exit(false);
    end;

    procedure DeliverOrder(DeliverText: Text; POSSession: Codeunit "NPR POS Session"; NpCsDocument: Record "NPR NpCs Document")
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempNpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon" temporary;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        RemainingAmount: Decimal;
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, NpCsDocument."Document No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        NpCsPOSActionEvents.OnDeliverOrderFilterSalesLine(NpCsDocument, SalesHeader, SalesLine);
        if SalesLine.IsEmpty() then
            Error(EmptyLinesOnDocumentErr, NpCsDocument."Reference No.");

        SalesLine.SetFilter(Type, '%1|%2|%3', SalesLine.Type::" ", SalesLine.Type::"G/L Account", SalesLine.Type::Item);
        if SalesLine.IsEmpty() then
            Error(SalesLineTypeNotSupportedErr, SalesLine.Type::" ", SalesLine.Type::"G/L Account", SalesLine.Type::Item);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");
        end else begin
            SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();
        end;

        POSSession.GetSaleLine(POSSaleLine);
        if (NpCsDocument."Bill via" = NpCsDocument."Bill via"::POS) then
            if not DocumentCanBeImportedOnPOS(NpCsDocument, SalesHeader) then begin
                NpCsDocument."Bill via" := NpCsDocument."Bill via"::"Sales Document";
                NpCsDocument.Modify();
            end;
        if (NpCsDocument."Bill via" = NpCsDocument."Bill via"::POS) then begin
            InsertDeliveryCommentLine(DeliverText, NpCsDocument, POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
            SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No.");
            SaleLinePOS.SetRecFilter();
            SalesDocImpMgt.SalesDocumentToPOSCustom(POSSession, SalesHeader, TempNpDcSaleLinePOSCoupon, false, false);
            SaleLinePOS.SetFilter("Line No.", '>%1', SaleLinePOS."Line No.");
            if SaleLinePOS.FindSet() then
                repeat
                    InsertPOSReference(NpCsDocument, SaleLinePOS);
                until SaleLinePOS.Next() = 0;
        end else begin

            InsertDeliveryCommentLine(DeliverText, NpCsDocument, POSSaleLine);

            POSSaleLine.GetNewSaleLine(SaleLinePOS);
            RemainingAmount := SalesDocImpMgt.GetTotalAmountToBeInvoiced(SalesHeader);
            if RemainingAmount > 0 then begin
                SalesHeader.CalcFields("NPR Magento Payment Amount");
                RemainingAmount -= SalesHeader."NPR Magento Payment Amount";
                if RemainingAmount < 0 then
                    RemainingAmount := 0;
            end;
            POSSalesDocumentPost := POSSalesDocumentPost::No;

            SalesDocImpMgt.SalesDocumentPaymentAmountToPOSSaleLine(RemainingAmount, SaleLinePOS, SalesHeader, false, false, POSSalesDocumentPost);
            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            POSSaleLine.InsertLineRaw(SaleLinePOS, false);
            InsertPOSReference(NpCsDocument, SaleLinePOS);
        end;
    end;

    procedure DeliverPostedInvoice(ConfirmInvDiscAmt: Boolean; DeliverText: Text; POSSession: Codeunit "NPR POS Session"; NpCsDocument: Record "NPR NpCs Document")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesInvLine: Record "Sales Invoice Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        RemainingAmount: Decimal;
    begin
        SalesInvHeader.Get(NpCsDocument."Document No.");
        POSSession.GetSaleLine(POSSaleLine);
        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.IsEmpty() then
            Error(EmptyLinesOnDocumentErr, NpCsDocument."Reference No.");

        SalesInvLine.SetFilter(Type, '%1|%2|%3', SalesInvLine.Type::" ", SalesInvLine.Type::"G/L Account", SalesInvLine.Type::Item);
        if SalesInvLine.IsEmpty() then
            Error(SalesLineTypeNotSupportedErr, SalesInvLine.Type::" ", SalesInvLine.Type::"G/L Account", SalesInvLine.Type::Item);

        if ConfirmInvDiscAmt then begin
            SalesInvLine.SetFilter("Inv. Discount Amount", '>%1', 0);
            SalesInvLine.CalcSums("Inv. Discount Amount");
            if SalesInvLine."Inv. Discount Amount" > 0 then begin
                if not Confirm(SalesDocImpMgt.GetImportInvDiscAmtQst()) then
                    exit;
            end;
        end;
        InsertDeliveryCommentLine(DeliverText, NpCsDocument, POSSaleLine);

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        RemainingAmount := SalesDocImpMgt.GetTotalAmountToBeInvoiced(SalesInvHeader);
        SalesDocImpMgt.SalesDocumentPaymentAmountToPOSSaleLine(RemainingAmount, SaleLinePOS, SalesInvHeader, false, false, true);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        InsertPOSReference(NpCsDocument, SaleLinePOS);

    end;

    procedure InsertDeliveryCommentLine(DeliverText: Text; NpCsDocument: Record "NPR NpCs Document"; POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.";
        SaleLinePOS: Record "NPR POS Sale Line";
        DeliveryLbl: Label 'Collect %1 %2', Comment = '%1=NpCsDocument."Document Type";%2=NpCsDocument."Reference No."';
        FoundDeliverReferenceErr: Label 'Collect Reference No. %3 (%1 %2) is already being delivery on current sale', Comment = '%1=NpCsDocument."Document Type";%2=NpCsDocument."Document No.";%3=NpCsDocument."Reference No."';
        DeliveryText: Text;
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        NpCsSaleLinePOSReference.SetRange("Register No.", SaleLinePOS."Register No.");
        NpCsSaleLinePOSReference.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        NpCsSaleLinePOSReference.SetRange("Document Type", NpCsDocument."Document Type");
        NpCsSaleLinePOSReference.SetRange("Document No.", NpCsDocument."Document No.");
        if not NpCsSaleLinePOSReference.IsEmpty() then
            Error(FoundDeliverReferenceErr, NpCsDocument."Document Type", NpCsDocument."Document No.", NpCsDocument."Reference No.");

        DeliveryText := StrSubstNo(DeliverText, NpCsDocument."Document Type", NpCsDocument."Reference No.");
        if DeliveryText = '' then
            DeliveryText := StrSubstNo(DeliveryLbl, NpCsDocument."Document Type", NpCsDocument."Reference No.");
        SaleLinePOS.Init();
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
        SaleLinePOS."No." := '*';
        SaleLinePOS.Description := CopyStr(DeliveryText, 1, MaxStrLen(SaleLinePOS.Description));
        POSSaleLine.InsertLine(SaleLinePOS);

        InsertPOSReference(NpCsDocument, SaleLinePOS);
    end;

    procedure InsertPOSReference(NpCsDocument: Record "NPR NpCs Document"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        NpCsSaleLinePOSReference: Record "NPR NpCs Sale Line POS Ref.";
    begin
        if NpCsSaleLinePOSReference.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS."Sale Type", SaleLinePOS.Date, SaleLinePOS."Line No.") then
            NpCsSaleLinePOSReference.Delete();
        NpCsSaleLinePOSReference.Init();
        NpCsSaleLinePOSReference."Register No." := SaleLinePOS."Register No.";
        NpCsSaleLinePOSReference."Sales Ticket No." := SaleLinePOS."Sales Ticket No.";
        NpCsSaleLinePOSReference."Sale Date" := SaleLinePOS.Date;
        NpCsSaleLinePOSReference."Sale Line No." := SaleLinePOS."Line No.";
        NpCsSaleLinePOSReference."Collect Document Entry No." := NpCsDocument."Entry No.";
        NpCsSaleLinePOSReference."Document No." := NpCsDocument."Document No.";
        NpCsSaleLinePOSReference."Document Type" := NpCsDocument."Document Type";
        NpCsSaleLinePOSReference.Insert();
    end;

    local procedure DocumentCanBeImportedOnPOS(NpCsDocument: Record "NPR NpCs Document"; SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if NpCsDocument."Prepaid Amount" <> 0 then
            exit(false);
        if SalesDocImpMgt.DocumentIsPartiallyPosted(SalesHeader) then
            exit(false);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("Prepmt Amt to Deduct", '<>0');
        exit(SalesLine.IsEmpty);
    end;

    procedure DeliverDocument(EntryNo: Integer; DeliverText: Text; ConfirmInvDiscAmt: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        POSSession: Codeunit "NPR POS Session";
        IsHandled: Boolean;
    begin
        NpCsDocument.Get(EntryNo);
        NpCsPOSActionEvents.OnBeforeDeliverDocument(POSSession, NpCsDocument, DeliverText, IsHandled);
        if IsHandled then
            exit;

        case NpCsDocument."Document Type" of
            NpCsDocument."Document Type"::Order:
                begin
                    DeliverOrder(DeliverText, POSSession, NpCsDocument);
                end;
            NpCsDocument."Document Type"::"Posted Invoice":
                begin
                    DeliverPostedInvoice(ConfirmInvDiscAmt, DeliverText, POSSession, NpCsDocument);
                end;
        end;
    end;
}