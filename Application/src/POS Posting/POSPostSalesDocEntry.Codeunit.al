codeunit 6184928 "NPR POS Post Sales Doc.Entry"
{
    Access = Internal;
    TableNo = "NPR POS Entry Sales Doc. Link";

    Permissions = tabledata "NPR POS Entry" = r,
                  tabledata "NPR POS Entry Sales Doc. Link" = rm,
                  tabledata "NPR POS Entry Sales Line" = rm;

    trigger OnRun()
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink := Rec;
        POSEntrySalesDocLink.LockTable();
        POSEntrySalesDocLink.Find();
        if not (POSEntrySalesDocLink."Post Sales Document Status" in [POSEntrySalesDocLink."Post Sales Document Status"::Unposted, POSEntrySalesDocLink."Post Sales Document Status"::"Error while Posting"]) then
            exit;

        if SalesDocumentExist(POSEntrySalesDocLink) then begin
            CheckIfPreviousTransactionsWerePosted(POSEntrySalesDocLink);
            case POSEntrySalesDocLink."Post Sales Invoice Type" of
                POSEntrySalesDocLink."Post Sales Invoice Type"::Prepayment:
                    PostPrepayment(POSEntrySalesDocLink);
                POSEntrySalesDocLink."Post Sales Invoice Type"::"Prepayment Refund":
                    PostPrepaymentRefund(POSEntrySalesDocLink);
                POSEntrySalesDocLink."Post Sales Invoice Type"::Order:
                    PostDocument(POSEntrySalesDocLink);
            end;
        end;

        //either manually posted or deleted status should be changed to be filter out
        POSEntrySalesDocLink."Post Sales Document Status" := POSEntrySalesDocLink."Post Sales Document Status"::Posted;
        POSEntrySalesDocLink.Modify();
    end;

    local procedure CheckIfPreviousTransactionsWerePosted(var POSEntrySalesDocLinkIn: Record "NPR POS Entry Sales Doc. Link")
    var
        POSEntrySalesDocLink2: Record "NPR POS Entry Sales Doc. Link";
        PostingErrorMsg: label 'There are previous transactions linked with same Sale Document that hasn''t been posted';
    begin
        if POSEntrySalesDocLinkIn."Orig. Sales Document No." = '' then
            exit;
        POSEntrySalesDocLink2.SetCurrentKey("Orig. Sales Document No.", "POS Entry No.", "Orig. Sales Document Type", "Post Sales Document Status");
        POSEntrySalesDocLink2.SetRange("Orig. Sales Document No.", POSEntrySalesDocLinkIn."Orig. Sales Document No.");
        POSEntrySalesDocLink2.SetRange("Orig. Sales Document Type", POSEntrySalesDocLinkIn."Orig. Sales Document Type");
        POSEntrySalesDocLink2.SetFilter("POS Entry No.", '<%1', POSEntrySalesDocLinkIn."POS Entry No.");
        POSEntrySalesDocLink2.SetFilter("Post Sales Document Status", '%1|%2', POSEntrySalesDocLink2."Post Sales Document Status"::"Error while Posting", POSEntrySalesDocLink2."Post Sales Document Status"::Unposted);
        if not POSEntrySalesDocLink2.IsEmpty then
            Error(PostingErrorMsg);
    end;

    local procedure PostPrepayment(var POSEntrySalesDocLinkIn: Record "NPR POS Entry Sales Doc. Link")
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        SalesHeader: Record "Sales Header";
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        InvoiceType: Enum "NPR Post Sales Posting Type";
    begin
        SalesHeader.Get(POSEntrySalesDocLinkIn."Sales Document Type", POSEntrySalesDocLinkIn."Sales Document No");
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        UpdateDates(SalesHeader);
        ValidateSalesDocument(SalesHeader, InvoiceType::Prepayment, POSEntrySalesDocLinkIn);

        SalesPostPrepayments.Invoice(SalesHeader);

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntrySalesDocLinkIn."POS Entry No.");
        POSEntrySalesLine.SetRange("Line No.", POSEntrySalesDocLinkIn."POS Entry Reference Line No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Customer);
        if POSEntrySalesLine.FindFirst() then begin
            POSEntrySalesLine."Applies-to Doc. Type" := POSEntrySalesLine."Applies-to Doc. Type"::Invoice;
            POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."Last Prepayment No.";
            POSEntrySalesLine.Modify();
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSEntrySalesDocLinkIn."Sales Document Type"::POSTED_INVOICE, POSEntrySalesLine."Applies-to Doc. No.", InvoiceType::Prepayment);
        end;

        if POSEntrySalesDocLinkIn."Sales Document Print" then
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 1);

        if POSEntrySalesDocLinkIn."Sales Document Send" then
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 1);

        if POSEntrySalesDocLinkIn."Sales Document Pdf2Nav" then
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 1);

        if POSEntrySalesDocLinkIn."Sales Document Delete" then
            SalesHeader.Delete(true);
    end;

    local procedure PostPrepaymentRefund(var POSEntrySalesDocLinkIn: Record "NPR POS Entry Sales Doc. Link")
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        SalesHeader: Record "Sales Header";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        InvoiceType: Enum "NPR Post Sales Posting Type";
    begin
        SalesHeader.Get(POSEntrySalesDocLinkIn."Sales Document Type", POSEntrySalesDocLinkIn."Sales Document No");
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        UpdateDates(SalesHeader);
        ValidateSalesDocument(SalesHeader, InvoiceType::"Prepayment Refund", POSEntrySalesDocLinkIn);

        SalesPostPrepayments.CreditMemo(SalesHeader);

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntrySalesDocLinkIn."POS Entry No.");
        POSEntrySalesLine.SetRange("Line No.", POSEntrySalesDocLinkIn."POS Entry Reference Line No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Customer);
        if POSEntrySalesLine.FindFirst() then begin
            POSEntrySalesLine."Applies-to Doc. Type" := POSEntrySalesLine."Applies-to Doc. Type"::"Credit Memo";
            POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."Last Prepmt. Cr. Memo No.";
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSEntrySalesDocLinkIn."Sales Document Type"::POSTED_CREDIT_MEMO, POSEntrySalesLine."Applies-to Doc. No.", InvoiceType::"Prepayment Refund");
        end;

        if POSEntrySalesDocLinkIn."Sales Document Print" then
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 2);

        if POSEntrySalesDocLinkIn."Sales Document Send" then
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 2);

        if POSEntrySalesDocLinkIn."Sales Document Pdf2Nav" then
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 2);

        if POSEntrySalesDocLinkIn."Sales Document Delete" then
            SalesHeader.Delete(true);
    end;

    local procedure PostDocument(var POSEntrySalesDocLinkIn: Record "NPR POS Entry Sales Doc. Link"): Boolean
    var
        SalesPost: Codeunit "Sales-Post";
        SalesHeader: Record "Sales Header";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSSalesDocumentOutputMgt: Codeunit "NPR POS Sales Doc. Output Mgt.";
        InvoiceType: Enum "NPR Post Sales Posting Type";
    begin
        if not (POSEntrySalesDocLinkIn."Sales Document Type" in [POSEntrySalesDocLinkIn."Sales Document Type"::INVOICE, POSEntrySalesDocLinkIn."Sales Document Type"::ORDER, POSEntrySalesDocLinkIn."Sales Document Type"::CREDIT_MEMO, POSEntrySalesDocLinkIn."Sales Document Type"::RETURN_ORDER]) then
            POSEntrySalesDocLinkIn.FieldError("Sales Document Type");

        SalesHeader.Get(POSEntrySalesDocLinkIn."Sales Document Type", POSEntrySalesDocLinkIn."Sales Document No");
        UpdateDates(SalesHeader);
        ValidateSalesDocument(SalesHeader, InvoiceType::Order, POSEntrySalesDocLinkIn);

        SalesPost.Run(SalesHeader);

        IF POSEntrySalesDocLinkIn."POS Entry Reference Type" = POSEntrySalesDocLinkIn."POS Entry Reference Type"::HEADER then
            SetPostedSalesHeaderDocInfo(SalesHeader, POSEntrySalesDocLinkIn)
        else begin
            POSEntrySalesLine.SetRange("POS Entry No.", POSEntrySalesDocLinkIn."POS Entry No.");
            POSEntrySalesLine.SetRange("Line No.", POSEntrySalesDocLinkIn."POS Entry Reference Line No.");
            POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Customer);
            if POSEntrySalesLine.FindFirst() then begin
                SetPostedSalesLineDocInfo(POSEntrySalesLine, SalesHeader);
                POSEntrySalesLine.Modify();
            END;
        end;

        if POSEntrySalesDocLinkIn."Sales Document Print" then
            POSSalesDocumentOutputMgt.PrintDocument(SalesHeader, 0);

        if POSEntrySalesDocLinkIn."Sales Document Send" then
            POSSalesDocumentOutputMgt.SendDocument(SalesHeader, 0);

        if POSEntrySalesDocLinkIn."Sales Document Pdf2Nav" then
            POSSalesDocumentOutputMgt.SendPdf2NavDocument(SalesHeader, 0);
    end;

    local procedure ValidateSalesDocument(SalesHeader: record "Sales Header"; InvoiceType: Enum "NPR Post Sales Posting Type"; POSEntrySalesDocLinkIn: Record "NPR POS Entry Sales Doc. Link")
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        case InvoiceType of
            InvoiceType::Prepayment:
                begin
                    //multiple prepayments can be made on one order.
                    //Using pos entry sale line to validate individual prepayments
                    POSEntrySalesLine.Get(POSEntrySalesDocLinkIn."POS Entry No.", POSEntrySalesDocLinkIn."POS Entry Reference Line No.");
                    ValidatePrepayment(SalesHeader, POSEntrySalesLine);
                end;
            InvoiceType::"Prepayment Refund":
                begin
                    //multiple prepayments can be made on one order.
                    ValidatePrepaymentRefund(SalesHeader);
                end;
            InvoiceType::Order:
                ValidateOrder(SalesHeader, POSEntrySalesDocLinkIn);
        end;
    end;

    local procedure ValidatePrepayment(var SalesHeaderIn: Record "Sales Header"; var POSEntrySalesLineIn: Record "NPR POS Entry Sales Line")
    var
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
    begin
        POSPrepaymentMgt.SetPrepaymentAmountToPayInclVAT(SalesHeaderin, POSEntrySalesLineIn."Amount Incl. VAT");
    end;

    local procedure ValidatePrepaymentRefund(SalesHeaderIn: Record "Sales Header")
    var
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
        NO_PREPAYMENT: Label '%1 %2 has no refundable prepayments!';
    begin
        if POSPrepaymentMgt.GetPrepaymentAmountToDeductInclVAT(SalesHeaderIn) <= 0 then
            Error(NO_PREPAYMENT, SalesHeaderIn."Document Type", SalesHeaderIn."No.");
    end;

    local procedure ValidateOrder(SalesHeaderIn: Record "Sales Header"; POSEntrySalesDocLinkIn: Record "NPR POS Entry Sales Doc. Link")
    var
        SalesLine: Record "Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySLineRelation: Record "NPR POS Entry S.Line Relation";
    begin
        POSEntrySLineRelation.SetCurrentKey("Sale Document No.", "Sale Document Type", "Sale Line No.", "POS Entry Reference Line No.");
        POSEntrySLineRelation.SetRange("POS Entry No.", POSEntrySalesDocLinkIn."POS Entry No.");
        POSEntrySLineRelation.SetRange("POS Entry Reference Line No.", POSEntrySalesDocLinkIn."POS Entry Reference Line No.");
        POSEntrySLineRelation.SetRange("Sale Document No.", SalesHeaderIn."No.");
        POSEntrySLineRelation.SetRange(Enabled, true);
        if POSEntrySLineRelation.FindSet() then
            repeat
                POSEntrySalesLine.Get(POSEntrySLineRelation."POS Entry No.", POSEntrySLineRelation."POS Entry Buff.Sales Line No.");
                SalesLine.Get(POSEntrySLineRelation."Sale Document Type", POSEntrySLineRelation."Sale Document No.", POSEntrySLineRelation."Sale Line No.");

                SalesLine.TestField("No.", POSEntrySalesLine."No.");
                case SalesHeaderIn."Document Type" of
                    "Sales Document Type"::Order:
                        begin
                            SalesLine.TestField(Quantity, POSEntrySalesLine.Quantity);
                            SalesLine.TestField("Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT");
                        end;
                    "Sales Document Type"::"Credit Memo",
                    "Sales Document Type"::"Return Order":
                        begin
                            SalesLine.TestField(Quantity, -POSEntrySalesLine.Quantity);
                            SalesLine.TestField("Amount Including VAT", -POSEntrySalesLine."Amount Incl. VAT");
                        end;
                end;
                SalesLine.TestField("Variant Code", POSEntrySalesLine."Variant Code");
                SalesLine.TestField("Line Discount %", POSEntrySalesLine."Line Discount %");
                SalesLine.TestField("Unit Price", POSEntrySalesLine."Unit Price");

                SalesLine.TestField("Qty. to Invoice", POSEntrySLineRelation."Qty. to Invoice");
                SalesLine.TestField("Qty. to Ship", POSEntrySLineRelation."Qty. to Ship");
                SalesLine.TestField("Return Qty. to Receive", POSEntrySLineRelation."Return Qty. to Receive");
            until POSEntrySLineRelation.Next() = 0;
    end;

    local procedure SetPostedSalesLineDocInfo(var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        POSSalesDocumentType: Enum "NPR POS Sales Document Type";
        InvoiceType: Enum "NPR Post Sales Posting Type";
    begin
        if SalesHeader.Invoice then begin
            case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Invoice:
                    begin
                        if SalesHeader."Last Posting No." <> '' then
                            POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."Last Posting No."
                        else
                            POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."No.";
                        POSEntrySalesLine."Applies-to Doc. Type" := POSEntrySalesLine."Applies-to Doc. Type"::Invoice;

                        POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSalesDocumentType::POSTED_INVOICE, POSEntrySalesLine."Applies-to Doc. No.", InvoiceType::" ");
                    end;
                SalesHeader."Document Type"::Order:
                    begin
                        POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."Last Posting No.";
                        POSEntrySalesLine."Applies-to Doc. Type" := POSEntrySalesLine."Applies-to Doc. Type"::Invoice;
                        POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSalesDocumentType::POSTED_INVOICE, POSEntrySalesLine."Applies-to Doc. No.", InvoiceType::" ");
                    end;
                SalesHeader."Document Type"::"Credit Memo":
                    begin
                        if SalesHeader."Last Posting No." <> '' then
                            POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."Last Posting No."
                        else
                            POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."No.";
                        POSEntrySalesLine."Applies-to Doc. Type" := POSEntrySalesLine."Applies-to Doc. Type"::"Credit Memo";
                        POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSalesDocumentType::POSTED_CREDIT_MEMO, POSEntrySalesLine."Applies-to Doc. No.", InvoiceType::" ");
                    end;
                SalesHeader."Document Type"::"Return Order":
                    begin
                        POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."Last Posting No.";
                        POSEntrySalesLine."Applies-to Doc. Type" := POSEntrySalesLine."Applies-to Doc. Type"::"Credit Memo";
                        POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSalesDocumentType::POSTED_CREDIT_MEMO, POSEntrySalesLine."Applies-to Doc. No.", InvoiceType::" ");
                    end;
            end;
        end;

        if SalesHeader.Ship then
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSalesDocumentType::SHIPMENT, SalesHeader."Last Shipping No.", InvoiceType::" ");
        if SalesHeader.Receive then
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSalesDocumentType::RETURN_RECEIPT, SalesHeader."Last Return Receipt No.", InvoiceType::" ");
    end;

    local procedure SetPostedSalesHeaderDocInfo(var SalesHeader: Record "Sales Header"; POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link")
    var
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        PostedDocumentNo: Code[20];
        POSEntryDescLbl: Label '%1 %2', Locked = true;
    begin
        if not (SalesHeader.Ship or SalesHeader.Invoice or SalesHeader.Receive) then
            exit;

        if SalesHeader.Ship and (SalesHeader."Last Shipping No." <> '') then begin
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::SHIPMENT;
            PostedDocumentNo := SalesHeader."Last Shipping No.";
            POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntrySalesDocLink."POS Entry No.", POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
        end;

        if SalesHeader.Receive and (SalesHeader."Last Return Receipt No." <> '') then begin
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::RETURN_RECEIPT;
            PostedDocumentNo := SalesHeader."Last Return Receipt No.";
            POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntrySalesDocLink."POS Entry No.", POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
        end;

        if SalesHeader.Invoice then begin
            case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Invoice:
                    begin
                        POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE;
                        if SalesHeader."Last Posting No." <> '' then
                            PostedDocumentNo := SalesHeader."Last Posting No."
                        else
                            PostedDocumentNo := SalesHeader."No.";
                    end;
                SalesHeader."Document Type"::Order:
                    begin
                        POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE;
                        PostedDocumentNo := SalesHeader."Last Posting No.";
                    end;
                SalesHeader."Document Type"::"Credit Memo":
                    begin
                        POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO;
                        if SalesHeader."Last Posting No." <> '' then
                            PostedDocumentNo := SalesHeader."Last Posting No."
                        else
                            PostedDocumentNo := SalesHeader."No.";
                    end;
                SalesHeader."Document Type"::"Return Order":
                    begin
                        POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO;
                        PostedDocumentNo := SalesHeader."Last Posting No.";
                    end;
            end;

            POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntrySalesDocLink."POS Entry No.", POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
        end;

        _PosEntryDescription := StrSubstNo(POSEntryDescLbl, POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
    end;

    local procedure SalesDocumentExist(POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link"): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        exit(SalesHeader.Get(POSEntrySalesDocLink."Sales Document Type", POSEntrySalesDocLink."Sales Document No"));
    end;

    internal procedure GetPosEntryDescription(): Text
    begin
        exit(_PosEntryDescription);
    end;

    internal procedure SetPostingDate(NewReplacePostingDate: Boolean; NewReplaceDocumentDate: Boolean; NewPostingDate: Date)
    begin
        _ReplaceDates := true;
        _ReplacePostingDate := NewReplacePostingDate;
        _ReplaceDocumentDate := NewReplaceDocumentDate;
        _PostingDate := NewPostingDate;
    end;

    local procedure UpdateDates(var SalesHeader: Record "Sales Header")
    begin
        if not _ReplaceDates or (_PostingDate = 0D) then
            exit;
        if _ReplacePostingDate or (SalesHeader."Posting Date" = 0D) then begin
            SalesHeader."Posting Date" := _PostingDate;
            SalesHeader.Validate("Currency Code");
        end;
        if _ReplaceDocumentDate or (SalesHeader."Document Date" = 0D) then
            SalesHeader.Validate("Document Date", _PostingDate);
    end;

    var
        _PosEntryDescription: Text;
        _PostingDate: Date;
        _ReplaceDates: Boolean;
        _ReplaceDocumentDate: Boolean;
        _ReplacePostingDate: Boolean;
}
