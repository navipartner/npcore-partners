codeunit 6151210 "NPR NpCs Post Document"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    TableNo = "NPR NpCs Document";

    trigger OnRun()
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        NpCsDocument := Rec;
        PostDocument(NpCsDocument);
        Rec := NpCsDocument;
    end;

    local procedure PostDocument(var NpCsDocument: Record "NPR NpCs Document")
    var
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        if SkipPosting(NpCsDocument) then
            exit;

        SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.");

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;

        if not Codeunit.Run(Codeunit::"Sales-Post", SalesHeader) then
            LogPosting(NpCsDocument, SalesHeader, GetLastErrorText);

        NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    local procedure LogPosting(NpCsDocument: Record "NPR NpCs Document"; SalesHeader: Record "Sales Header"; ErrorText: Text)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        LogMessage: Text;
        SalesDocPostedAsLbl: Label 'Sales %1 %2 posted to %3 %4';
        SalesDocPostFailedLbl: Label 'Sales %1 %2 posting error';
    begin
        if ErrorText = '' then
            LogMessage := StrSubstNo(SalesDocPostedAsLbl, SalesHeader."Document Type", SalesHeader."No.", NpCsDocument."Document Type", NpCsDocument."Document No.")
        else
            LogMessage := StrSubstNo(SalesDocPostFailedLbl, SalesHeader."Document Type", SalesHeader."No.");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, ErrorText <> '', ErrorText);
    end;

    local procedure SkipPosting(NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if NpCsDocument."Bill via" <> NpCsDocument."Bill via"::"Sales Document" then
            exit(true);

        if not NpCsDocument."Store Stock" then
            exit(true);

        exit(
            NpCsDocument."Document Type" in
                [NpCsDocument."Document Type"::Quote,
                 NpCsDocument."Document Type"::"Blanket Order",
                 NpCsDocument."Document Type"::"Posted Invoice",
                 NpCsDocument."Document Type"::"Posted Credit Memo"]);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, true)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        NpCsDocument: Record "NPR NpCs Document";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        if (SalesInvHdrNo = '') and (SalesCrMemoHdrNo = '') then
            exit;
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Document Type", SalesHeader."Document Type");
        NpCsDocument.SetRange("Document No.", SalesHeader."No.");
        if not NpCsDocument.FindFirst() then
            exit;
        if NpCsDocument."Bill via" = NpCsDocument."Bill via"::POS then
            exit;
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice:
                begin
                    NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Invoice";
                    NpCsDocument."Document No." := SalesInvHdrNo;
                end;
            SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo":
                begin
                    NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Credit Memo";
                    NpCsDocument."Document No." := SalesCrMemoHdrNo;
                end;
        end;

        if (NpCsDocument."Delivery Document Type" = NpCsDocument."Delivery Document Type"::"POS Entry") and (NpCsDocument."Delivery Document No." <> '') then
            if FindPOSEntry(POSEntry, NpCsDocument."Delivery Document No.") then
                if FindPOSEntrySalesLine(POSEntrySalesLine, SalesHeader, POSEntry."Entry No.") then
                    SetPostedSalesLineDocInfo(POSEntrySalesLine, SalesHeader);

        NpCsDocument.Modify(true);
        LogPosting(NpCsDocument, SalesHeader, '');
        Commit();
        NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    local procedure FindPOSEntry(var POSEntry: Record "NPR POS Entry"; DocumentNo: Code[20]): Boolean
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", DocumentNo);
        exit(POSEntry.FindFirst());
    end;

    local procedure FindPOSEntrySalesLine(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; SalesHeader: Record "Sales Header"; POSEntryNo: Integer): Boolean
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
        POSEntrySalesDocLink.SetRange("Sales Document Type", SalesHeader."Document Type");
        POSEntrySalesDocLink.SetRange("Sales Document No", SalesHeader."No.");
        POSEntrySalesDocLink.SetRange("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status"::"Not To Be Posted");
        if not POSEntrySalesDocLink.FindLast() then
            exit(false);

        exit(POSEntrySalesLine.Get(POSEntrySalesDocLink."POS Entry No.", POSEntrySalesDocLink."POS Entry Reference Line No."));
    end;

    local procedure SetPostedSalesLineDocInfo(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; SalesHeader: Record "Sales Header")
    begin
        if SalesHeader.Invoice then
            SetPostedSalesLineDocInfoForInvoicing(POSEntrySalesLine, SalesHeader);

        if SalesHeader.Ship then
            SetPostedSalesLineDocInfoForShipping(POSEntrySalesLine, SalesHeader);

        if SalesHeader.Receive then
            SetPostedSalesLineDocInfoForReceiving(POSEntrySalesLine, SalesHeader);
    end;

    local procedure SetPostedSalesLineDocInfoForInvoicing(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        PostedDocumentNo: Code[20];
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                begin
                    if SalesHeader."Last Posting No." <> '' then
                        PostedDocumentNo := SalesHeader."Last Posting No."
                    else
                        PostedDocumentNo := SalesHeader."No.";

                    if not POSEntrySalesDocLinkMgt.POSSalesLineSalesDocReferenceExists(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::POSTED_INVOICE, PostedDocumentNo) then
                        POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::POSTED_INVOICE, PostedDocumentNo);
                end;
            SalesHeader."Document Type"::Order:
                begin
                    PostedDocumentNo := SalesHeader."Last Posting No.";

                    if not POSEntrySalesDocLinkMgt.POSSalesLineSalesDocReferenceExists(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::POSTED_INVOICE, PostedDocumentNo) then
                        POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::POSTED_INVOICE, PostedDocumentNo);
                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    if SalesHeader."Last Posting No." <> '' then
                        PostedDocumentNo := SalesHeader."Last Posting No."
                    else
                        PostedDocumentNo := SalesHeader."No.";

                    if not POSEntrySalesDocLinkMgt.POSSalesLineSalesDocReferenceExists(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::POSTED_CREDIT_MEMO, PostedDocumentNo) then
                        POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::POSTED_CREDIT_MEMO, PostedDocumentNo);
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    PostedDocumentNo := SalesHeader."Last Posting No.";

                    if not POSEntrySalesDocLinkMgt.POSSalesLineSalesDocReferenceExists(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::POSTED_CREDIT_MEMO, PostedDocumentNo) then
                        POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::POSTED_CREDIT_MEMO, PostedDocumentNo);
                end;
        end;
    end;

    local procedure SetPostedSalesLineDocInfoForShipping(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
    begin
        if not POSEntrySalesDocLinkMgt.POSSalesLineSalesDocReferenceExists(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::SHIPMENT, SalesHeader."Last Shipping No.") then
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::SHIPMENT, SalesHeader."Last Shipping No.");
    end;

    local procedure SetPostedSalesLineDocInfoForReceiving(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
    begin
        if not POSEntrySalesDocLinkMgt.POSSalesLineSalesDocReferenceExists(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::RETURN_RECEIPT, SalesHeader."Last Return Receipt No.") then
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, Enum::"NPR POS Sales Document Type"::RETURN_RECEIPT, SalesHeader."Last Return Receipt No.");
    end;
}
