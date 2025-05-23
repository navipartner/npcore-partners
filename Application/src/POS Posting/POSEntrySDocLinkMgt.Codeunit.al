﻿codeunit 6151007 "NPR POS Entry S.Doc. Link Mgt."
{
    Access = Internal;
    procedure InsertPOSEntrySalesDocReference(POSEntryNo: Integer; SalesDocType: Enum "NPR POS Sales Document Type"; SalesDocNo: Code[20])
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init();
        POSEntrySalesDocLink."POS Entry No." := POSEntryNo;
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::HEADER;
        POSEntrySalesDocLink."POS Entry Reference Line No." := 0;
        POSEntrySalesDocLink."Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocNo;
        POSEntrySalesDocLink."Orig. Sales Document No." := SalesDocNo;
        POSEntrySalesDocLink."Orig. Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Post Sales Document Status" := POSEntrySalesDocLink."Post Sales Document Status"::"Not To Be Posted";
        POSEntrySalesDocLink.Insert();
    end;

    procedure InsertPOSEntrySalesDocReferenceAsyncPosting(POSEntryNo: Integer; SalesDocType: Enum "NPR POS Sales Document Type"; SalesDocNo: Code[20]; ReadyToBePostedIn: Boolean; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean)
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init();
        POSEntrySalesDocLink."POS Entry No." := POSEntryNo;
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::HEADER;
        POSEntrySalesDocLink."POS Entry Reference Line No." := 0;
        POSEntrySalesDocLink."Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocNo;
        POSEntrySalesDocLink."Orig. Sales Document No." := SalesDocNo;
        POSEntrySalesDocLink."Orig. Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document Print" := Print;
        POSEntrySalesDocLink."Sales Document Send" := Send;
        POSEntrySalesDocLink."Sales Document Pdf2Nav" := Pdf2Nav;
        case POSEntrySalesDocLink."Sales Document Type" of
            POSEntrySalesDocLink."Sales Document Type"::CREDIT_MEMO,
            POSEntrySalesDocLink."Sales Document Type"::INVOICE,
            POSEntrySalesDocLink."Sales Document Type"::RETURN_ORDER,
            POSEntrySalesDocLink."Sales Document Type"::ORDER:
                begin
                    POSEntrySalesDocLink."Post Sales Invoice Type" := POSEntrySalesDocLink."Post Sales Invoice Type"::Order;
                    if ReadyToBePostedIn then
                        POSEntrySalesDocLink."Post Sales Document Status" := POSEntrySalesDocLink."Post Sales Document Status"::Unposted;
                    POSEntrySalesDocLink."Post Sales Invoice Type" := POSEntrySalesDocLink."Post Sales Invoice Type"::Order;
                end;
        END;
        POSEntrySalesDocLink.Insert();
    end;

    procedure InsertPOSSalesLineSalesDocReference(POSSalesLine: Record "NPR POS Entry Sales Line"; SalesDocType: Enum "NPR POS Sales Document Type"; SalesDocNo: Code[20]; InvoiceType: Enum "NPR Post Sales Posting Type")
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init();
        POSEntrySalesDocLink."POS Entry No." := POSSalesLine."POS Entry No.";
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE;
        POSEntrySalesDocLink."POS Entry Reference Line No." := POSSalesLine."Line No.";
        POSEntrySalesDocLink."Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocNo;
        POSEntrySalesDocLink."Post Sales Invoice Type" := InvoiceType;
        if POSEntrySalesDocLink."Sales Document Type" in
           [POSEntrySalesDocLink."Sales Document Type"::POSTED_ASSEMBLY_ORDER,
            POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE,
            POSEntrySalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO,
            POSEntrySalesDocLink."Sales Document Type"::SHIPMENT,
            POSEntrySalesDocLink."Sales Document Type"::RETURN_RECEIPT]
        then
            POSEntrySalesDocLink."Post Sales Document Status" := POSEntrySalesDocLink."Post Sales Document Status"::Posted;
        POSEntrySalesDocLink.Insert();
    end;

    procedure POSSalesLineSalesDocReferenceExists(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; SalesDocumentType: Enum "NPR POS Sales Document Type"; SalesDocumentNo: Code[20]): Boolean
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        exit(POSEntrySalesDocLink.Get(POSEntrySalesLine."POS Entry No.", POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE, POSEntrySalesLine."Line No.", SalesDocumentType, SalesDocumentNo));
    end;

    procedure InsertPOSSalesLineSalesDocReference(POSEntrySalesLine: Record "NPR POS Entry Sales Line"; SalesDocumentType: Enum "NPR POS Sales Document Type"; SalesDocumentNo: Code[20])
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init();
        POSEntrySalesDocLink."POS Entry No." := POSEntrySalesLine."POS Entry No.";
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE;
        POSEntrySalesDocLink."POS Entry Reference Line No." := POSEntrySalesLine."Line No.";
        POSEntrySalesDocLink."Sales Document Type" := SalesDocumentType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocumentNo;
        POSEntrySalesDocLink.Insert();
    end;

    procedure InsertPOSSalesLineSalesDocReferenceAsyncPost(POSSalesLine: Record "NPR POS Entry Sales Line"; SalesDocType: Enum "NPR POS Sales Document Type"; SalesDocNo: Code[20]; InvoiceType: Enum "NPR Post Sales Posting Type"; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean; IsPrepayPerc: Boolean; DeleteAfter: Boolean)
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.Init();
        POSEntrySalesDocLink."POS Entry No." := POSSalesLine."POS Entry No.";
        POSEntrySalesDocLink."POS Entry Reference Type" := POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE;
        POSEntrySalesDocLink."POS Entry Reference Line No." := POSSalesLine."Line No.";
        POSEntrySalesDocLink."Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Sales Document No" := SalesDocNo;
        POSEntrySalesDocLink."Sales Document Print" := Print;
        POSEntrySalesDocLink."Sales Document Send" := Send;
        POSEntrySalesDocLink."Sales Document Pdf2Nav" := Pdf2Nav;
        POSEntrySalesDocLink."Sales Document Delete" := DeleteAfter;
        POSEntrySalesDocLink."Orig. Sales Document No." := SalesDocNo;
        POSEntrySalesDocLink."Orig. Sales Document Type" := SalesDocType;
        POSEntrySalesDocLink."Post Sales Document Status" := POSEntrySalesDocLink."Post Sales Document Status"::Unposted;
        POSEntrySalesDocLink."Post Sales Invoice Type" := InvoiceType;
        POSEntrySalesDocLink.Insert();
    end;
}