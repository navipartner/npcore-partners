codeunit 6151381 "NPR POS Post Sales Doc.Entries"
{
    Access = Internal;
    TableNo = "NPR POS Entry";
    Permissions = tabledata "NPR POS Entry" = rm,
                  tabledata "NPR POS Entry Sales Doc. Link" = rm,
                  tabledata "NPR POS Entry Sales Line" = rm;

    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        OnBeforePostPOSEntry(Rec);

        POSEntry := Rec;

        if GenJnlCheckLine.DateNotAllowed(POSEntry."Posting Date") then
            POSEntry.FieldError("Posting Date", TextDateNotAllowed);

        CheckPostingrestrictions(POSEntry);

        POSEntrySalesDocLink.Reset();
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesDocLink.SetRange("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status"::Unposted, POSEntrySalesDocLink."Post Sales Document Status"::"Error while Posting");
        if POSEntrySalesDocLink.FindSet() then
            repeat
                if SalesDocumentExist(POSEntrySalesDocLink) then begin
                    POSEntrySalesDocLink."Post Sales Document Status" := POSEntrySalesDocLink."Post Sales Document Status"::"Error while Posting";
                    POSEntrySalesDocLink.Modify();
                    Commit();

                    CheckIfPreviousTransactionsWerePosted(POSEntrySalesDocLink);
                    case POSEntrySalesDocLink."Post Sales Invoice Type" of
                        POSEntrySalesDocLink."Post Sales Invoice Type"::Prepayment:
                            PostPrepayment(POSEntrySalesDocLink);
                        POSEntrySalesDocLink."Post Sales Invoice Type"::"Prepayment Refund":
                            PostPrepaymentRefund(POSEntrySalesDocLink);
                        POSEntrySalesDocLink."Post Sales Invoice Type"::Order:
                            PostDocument(POSEntrySalesDocLink, POSEntry);
                    end;
                end;
                //either manually posted or deleted status should be changed to be filter out
                POSEntrySalesDocLink."Post Sales Document Status" := POSEntrySalesDocLink."Post Sales Document Status"::Posted;
                POSEntrySalesDocLink.Modify();
                Commit();

            until POSEntrySalesDocLink.Next() = 0;

        OnAfterPostPOSEntry(Rec);
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
        ValidateSalesDocument(SalesHeader, InvoiceType::Prepayment, POSEntrySalesDocLinkIn);

        SalesPostPrepayments.Invoice(SalesHeader);

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntrySalesDocLinkIn."POS Entry No.");
        POSEntrySalesLine.SetRange("Line No.", POSEntrySalesDocLinkIn."POS Entry Reference Line No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Customer);
        if POSEntrySalesLine.FindFirst() then begin
            POSEntrySalesLine."Applies-to Doc. Type" := POSEntrySalesLine."Applies-to Doc. Type"::Invoice;
            POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."Last Prepayment No.";
            POSEntrySalesLine.Modify();
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSEntrySalesDocLinkIn."Sales Document Type"::POSTED_INVOICE, POSEntrySalesLine."Applies-to Doc. No.", InvoiceType::" ");
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
        ValidateSalesDocument(SalesHeader, InvoiceType::"Prepayment Refund", POSEntrySalesDocLinkIn);

        SalesPostPrepayments.CreditMemo(SalesHeader);

        POSEntrySalesLine.SetRange("POS Entry No.", POSEntrySalesDocLinkIn."POS Entry No.");
        POSEntrySalesLine.SetRange("Line No.", POSEntrySalesDocLinkIn."POS Entry Reference Line No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Customer);
        if POSEntrySalesLine.FindFirst() then begin
            POSEntrySalesLine."Applies-to Doc. Type" := POSEntrySalesLine."Applies-to Doc. Type"::"Credit Memo";
            POSEntrySalesLine."Applies-to Doc. No." := SalesHeader."Last Prepmt. Cr. Memo No.";
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSEntrySalesDocLinkIn."Sales Document Type"::POSTED_CREDIT_MEMO, POSEntrySalesLine."Applies-to Doc. No.", InvoiceType::" ");
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

    local procedure PostDocument(var POSEntrySalesDocLinkIn: Record "NPR POS Entry Sales Doc. Link"; var POSEntry: Record "NPR POS Entry"): Boolean
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

        ValidateSalesDocument(SalesHeader, InvoiceType::Order, POSEntrySalesDocLinkIn);

        SalesPost.Run(SalesHeader);

        IF POSEntrySalesDocLinkIn."POS Entry Reference Type" = POSEntrySalesDocLinkIn."POS Entry Reference Type"::HEADER THEN begin
            SetPostedSalesHeaderDocInfo(POSEntry, SalesHeader);
        end ELSE BEGIN
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
                //multiple or partial payments can be made on one order.
                ValidateOrder(SalesHeader, POSEntrySalesLine, POSEntrySalesDocLinkIn)

        end;
    end;

    var
        TextCustomerBlocked: Label 'Customer is blocked.';
        TextDateNotAllowed: Label 'is not within your range of allowed posting dates.';

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

    local procedure ValidateOrder(SalesHeaderIn: Record "Sales Header"; var POSEntrySalesLineIn: Record "NPR POS Entry Sales Line"; POSEntrySalesDocLinkIn: Record "NPR POS Entry Sales Doc. Link")
    var
        SalesLine: Record "Sales Line";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.SetCurrentKey("Orig. Sales Document No.", "Orig. Sales Document Type");
        POSEntrySalesDocLink.SetRange("Orig. Sales Document No.", POSEntrySalesDocLinkIn."Orig. Sales Document No.");
        POSEntrySalesDocLink.SetRange("Orig. Sales Document Type", POSEntrySalesDocLinkIn."Orig. Sales Document Type");
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkIn."POS Entry Reference Type"::HEADER);
        if POSEntrySalesDocLink.FindFirst() then begin
            POSEntrySalesLineIn.SetRange("POS Entry No.", POSEntrySalesDocLink."POS Entry No.");
            POSEntrySalesLineIn.FindSet();
            repeat
                SalesLine.Get(SalesHeaderIn."Document Type", SalesHeaderIn."No.", POSEntrySalesLineIn."Line No.");
                SalesLine.TestField("No.", POSEntrySalesLineIn."No.");
                case SalesHeaderIn."Document Type" of
                    "Sales Document Type"::Order:
                        begin
                            SalesLinE.TestField(Quantity, POSEntrySalesLineIn.Quantity);
                            SalesLine.TestField("Amount Including VAT", POSEntrySalesLineIn."Amount Incl. VAT");
                        end;
                    "Sales Document Type"::"Credit Memo",
                    "Sales Document Type"::"Return Order":
                        begin
                            SalesLine.TestField(Quantity, -POSEntrySalesLineIn.Quantity);
                            SalesLine.TestField("Amount Including VAT", -POSEntrySalesLineIn."Amount Incl. VAT");
                        end;
                end;
                SalesLine.TestField("Variant Code", POSEntrySalesLineIn."Variant Code");
                SalesLine.TestField("Line Discount %", POSEntrySalesLineIn."Line Discount %");
                SalesLine.TestField("Unit Cost", POSEntrySalesLineIn."Unit Cost");

            until POSEntrySalesLineIn.Next() = 0;

        end;
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

        if SalesHeader.Ship then begin
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSalesDocumentType::SHIPMENT, SalesHeader."Last Shipping No.", InvoiceType::" ");

        end;
        if SalesHeader.Receive then begin
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSalesDocumentType::RETURN_RECEIPT, SalesHeader."Last Return Receipt No.", InvoiceType::" ");

        end;
    end;

    local procedure SetPostedSalesHeaderDocInfo(var POSEntry: Record "NPR POS Entry"; var SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        PostedDocumentNo: Code[20];
        POSEntryDescLbl: Label '%1 %2', Locked = true;
    begin

        if not (SalesHeader.Ship or SalesHeader.Invoice or SalesHeader.Receive) then
            exit;

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

            POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntry, POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
        end;

        if SalesHeader.Ship then begin
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::SHIPMENT;
            PostedDocumentNo := SalesHeader."Last Shipping No.";
            POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntry, POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
        end;

        if SalesHeader.Receive then begin
            POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::RETURN_RECEIPT;
            PostedDocumentNo := SalesHeader."Last Return Receipt No.";
            POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntry, POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
        end;

        if POSEntry.Description = '' then begin
            POSEntry.Description := StrSubstNo(POSEntryDescLbl, POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
            POSEntry.Modify();
        end;
    end;

    local procedure CheckPostingrestrictions(POSEntryToCheck: Record "NPR POS Entry")
    var
        Customer: Record Customer;
    begin
        OnCheckPostingRestrictions(POSEntryToCheck);
        if POSEntryToCheck."Customer No." <> '' then begin
            Customer.Get(POSEntryToCheck."Customer No.");
            if Customer.Blocked = Customer.Blocked::All then
                Error(TextCustomerBlocked);
        end;
    end;

    local procedure SalesDocumentExist(POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link"): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        exit(SalesHeader.Get(POSEntrySalesDocLink."Sales Document Type", POSEntrySalesDocLink."Sales Document No"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingRestrictions(var POSEntry: Record "NPR POS Entry")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPOSEntry(var POSEntry: Record "NPR POS Entry")
    begin
    end;
}


