codeunit 6150614 "NPR POS Create Entry"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        WasModified: Boolean;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        SaleCancelled: Boolean;
        POSSaleMediaInfo: Record "NPR POS Sale Media Info";
        POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        Clear(GlobalPOSEntry);
        ValidateSaleHeader(Rec);

        OnBeforeCreatePOSEntry(Rec);

        if not GetPOSPeriodRegister(Rec, POSPeriodRegister, true) then
            Error(ERR_NO_OPEN_UNIT, POSPeriodRegister.TableCaption, POSPeriodRegister.FieldCaption("POS Unit No."), Rec."Register No.");

        SaleCancelled := IsCancelledSale(Rec);
        if SaleCancelled then begin
            InsertPOSEntry(POSPeriodRegister, Rec, POSEntry, POSEntry."Entry Type"::"Cancelled Sale");
            POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
            POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        end else begin
            InsertPOSEntry(POSPeriodRegister, Rec, POSEntry, POSEntry."Entry Type"::"Direct Sale");
        end;

        CreateLines(POSEntry, Rec);

        UpdatePostSaleDocumentStatus(POSEntry, SaleCancelled);
        if POSEntry."Entry Type" = POSEntry."Entry Type"::"Direct Sale" then
            if POSAsyncPostingMgt.AsyncPostingEnabled() then
                CreateBufferLines(POSEntry, Rec);

        POSEntryManagement.RecalculatePOSEntry(POSEntry, WasModified);
        POSEntry.Modify();

        if SaleCancelled then begin
            POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::CANCEL_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_CANCEL_SALE_END, '')
        end else begin
            POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::GRANDTOTAL, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
            POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::DIRECT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_DIRECT_SALE_END, '');
        end;

        POSSaleMediaInfo.TransferEntriesToPOSEntryMediaInfo(Rec, POSEntry, true);

        OnAfterInsertPOSEntry(Rec, POSEntry);
        GlobalPOSEntry := POSEntry;
    end;

    var
        GlobalPOSEntry: Record "NPR POS Entry";
        ERR_NO_OPEN_UNIT: Label 'No open %1 could be found for %2 %3.';
        ERR_DOCUMENT_NO_CLASH: Label '%1 %2 has already been used by another %3';
        TXT_SALES_TICKET: Label 'Sales Ticket %1';
        TXT_DIRECT_SALE_END: Label 'POS Direct Sale Ended';
        TXT_CREDIT_SALE_END: Label 'POS Credit Sale Ended';
        TXT_CANCEL_SALE_END: Label 'POS Sale Cancelled';
        CANCEL_SALE: Label 'Sale was cancelled';

    local procedure CreateLines(var POSEntry: Record "NPR POS Entry"; var POSSale: Record "NPR POS Sale")
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        if POSSaleLine.FindSet() then begin
            repeat
                case POSSaleLine."Line Type" of
                    POSSaleLine."Line Type"::Item,
                    POSSaleLine."Line Type"::"Item Category",
                    POSSaleLine."Line Type"::"BOM List",
                    POSSaleLine."Line Type"::"Customer Deposit",
                    POSSaleLine."Line Type"::"Issue Voucher":
                        begin
                            InsertPOSSaleLine(POSSale, POSSaleLine, POSEntry, false, POSEntrySalesLine);
                            InsertPOSTaxAmount(POSSaleLine.SystemId, POSEntry);
                        end;
                    POSSaleLine."Line Type"::Rounding:
                        begin
                            InsertPOSSaleLine(POSSale, POSSaleLine, POSEntry, true, POSEntrySalesLine);
                            InsertPOSTaxAmountReverseSign(POSSaleLine.SystemId, POSEntry);
                        end;
                    POSSaleLine."Line Type"::"GL Payment":
                        begin
                            InsertPOSSaleLine(POSSale, POSSaleLine, POSEntry, false, POSEntrySalesLine);
                            InsertPOSTaxAmountReverseSign(POSSaleLine.SystemId, POSEntry);
                        end;
                    POSSaleLine."Line Type"::"POS Payment":
                        InsertPOSPaymentLine(POSSale, POSSaleLine, POSEntry, POSEntryPaymentLine);
                    POSSaleLine."Line Type"::Comment:
                        InsertPOSSaleLine(POSSale, POSSaleLine, POSEntry, false, POSEntrySalesLine);
                end;
            until POSSaleLine.Next() = 0;
        end;
    end;

    local procedure CreateBufferLines(var POSEntry: Record "NPR POS Entry"; var POSSale: Record "NPR POS Sale")
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetFilter("Sales Document No.", '<>%1', '');
        POSSaleLine.SetRange("Sales Document Post", POSSaleLine."Sales Document Post"::Asynchronous);
        if POSSaleLine.FindSet() then begin
            repeat
                case POSSaleLine."Line Type" of
                    POSSaleLine."Line Type"::"Customer Deposit":
                        InsertBufferPOSSaleLine(POSSaleLine, POSEntry);
                end
            until POSSaleLine.Next() = 0;
        end;
    end;

    internal procedure UpdatePostSaleDocumentStatus(var POSEntry: Record "NPR POS Entry"; SaleCancelled: Boolean)
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.SetCurrentKey("POS Entry No.", "Post Sales Document Status");
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        if SaleCancelled then begin
            POSEntrySalesDocLink.ModifyAll("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status"::"Not To Be Posted");
        end else begin
            POSEntrySalesDocLink.SetRange("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status"::Unposted);
            if not POSEntrySalesDocLink.IsEmpty() then
                POSEntry."Post Sales Document Status" := POSEntry."Post Sales Document Status"::Unposted;
        end;

    end;

    internal procedure CreatePOSEntryForCreatedSalesDocument(var POSSale: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header"; Posted: Boolean; AsyncPosting: Boolean; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        WasModified: Boolean;
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        SalesHeaderLbl: Label '%1 %2', Locked = true;
    begin
        Clear(GlobalPOSEntry);
        OnBeforeCreatePOSEntry(POSSale);

        if not GetPOSPeriodRegister(POSSale, POSPeriodRegister, true) then
            Error(ERR_NO_OPEN_UNIT, POSPeriodRegister.TableCaption, POSPeriodRegister.FieldCaption("POS Unit No."), POSSale."Register No.");
        InsertPOSEntry(POSPeriodRegister, POSSale, POSEntry, POSEntry."Entry Type"::"Credit Sale");
        CreateLines(POSEntry, POSSale);

        POSEntryManagement.RecalculatePOSEntry(POSEntry, WasModified);

        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry."Sales Document Type" := SalesHeader."Document Type";
        POSEntry."Sales Document No." := SalesHeader."No.";

        if AsyncPosting then begin
            POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReferenceAsyncPosting(POSEntry, SalesHeader."Document Type", SalesHeader."No.", ReadyToBePosted(SalesHeader), Print, Send, Pdf2Nav);
            if POSAsyncPosting.ReadyToBePosted(SalesHeader) then begin
                POSEntry."Post Sales Document Status" := POSEntry."Post Sales Document Status"::Unposted;
                POSAsyncPosting.InsertPOSEntrySalesLineHeaderRelation(POSEntry, SalesHeader);
            end;
        end else
            POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntry, SalesHeader."Document Type", SalesHeader."No.");

        if Posted then
            SetPostedSalesDocInfo(POSEntry, SalesHeader);

        if POSEntry.Description = '' then
            POSEntry.Description := StrSubstNo(SalesHeaderLbl, SalesHeader."Document Type", SalesHeader."No.");

        POSEntry.Modify();

        POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::CREDIT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_CREDIT_SALE_END, '');

        OnAfterInsertPOSEntry(POSSale, POSEntry);
        GlobalPOSEntry := POSEntry;
    end;

    local procedure InsertPOSEntry(var POSPeriodRegister: Record "NPR POS Period Register"; var POSSale: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry"; EntryType: Option)
    var
        Contact: Record Contact;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSSaleLine: Record "NPR POS Sale Line";
        SalespersonLbl: Label '%1: %2', Locked = true;
    begin
        POSEntry.Init();
        POSEntry."Entry No." := 0; //Autoincrement;
        POSEntry."POS Period Register No." := POSPeriodRegister."No.";
        POSEntry."POS Store Code" := POSSale."POS Store Code";
        POSEntry."POS Unit No." := POSSale."Register No.";
        POSEntry."Document No." := POSSale."Sales Ticket No.";
        POSEntry."Entry Date" := POSSale.Date;
        POSEntry."Entry Type" := EntryType;

        FiscalNoCheck(POSEntry, POSSale);

        POSEntry."Salesperson Code" := POSSale."Salesperson Code";
        POSEntry."Customer No." := POSSale."Customer No.";
        if POSSale."Contact No." <> '' then
            if Contact.Get(CopyStr(POSSale."Contact No.", 1, MaxStrLen(Contact."No."))) then
                POSEntry."Contact No." := Contact."No.";
        AssignRelatedCustomerNoForContact(POSEntry, POSSale);

        POSEntry."Event No." := POSSale."Event No.";
        POSEntry."Shortcut Dimension 1 Code" := POSSale."Shortcut Dimension 1 Code";
        POSEntry."Shortcut Dimension 2 Code" := POSSale."Shortcut Dimension 2 Code";
        POSEntry."Dimension Set ID" := POSSale."Dimension Set ID";
        POSEntry.SystemId := POSSale.SystemId;
        POSEntry."Starting Time" := POSSale."Start Time";
        POSEntry."Ending Time" := Time;
        POSEntry."Posting Date" := POSSale.Date;
        POSEntry."Document Date" := POSSale.Date;
        POSEntry."Currency Code" := '';//All sales are in LCY for now (Payments can  be in FCY of course)
        POSEntry."Country/Region Code" := POSSale."Country Code";
        POSEntry."Tax Area Code" := POSSale."Tax Area Code";
        POSEntry."Prices Including VAT" := POSSale."Prices Including VAT";
        POSEntry."NPRE Number of Guests" := POSSale."NPRE Number of Guests";
        POSEntry."External Document No." := POSSale."External Document No.";
        POSEntry."Responsibility Center" := POSSale."Responsibility Center";
        POSEntry."Sales Channel" := POSSale."Sales Channel";

        OnBeforeInsertPOSEntry(POSSale, POSEntry);

        if POSEntry.Description = '' then begin
            case POSEntry."Entry Type" of
                POSEntry."Entry Type"::"Direct Sale":
                    POSEntry.Description := CopyStr(StrSubstNo(TXT_SALES_TICKET, POSEntry."Document No."), 1, MaxStrLen(POSEntry.Description));
                POSEntry."Entry Type"::Balancing:
                    begin
                        if (not SalespersonPurchaser.Get(POSSale."Salesperson Code")) then
                            SalespersonPurchaser.Name := StrSubstNo(SalespersonLbl, SalespersonPurchaser.TableCaption, POSSale."Salesperson Code");
                        POSEntry.Description := SalespersonPurchaser.Name;
                    end;

                POSEntry."Entry Type"::"Cancelled Sale":
                    begin
                        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
                        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
                        if POSSaleLine.FindFirst() and (POSSaleLine.Description <> '') then
                            POSEntry.Description := POSSaleLine.Description
                        else
                            POSEntry.Description := CANCEL_SALE;
                    end;
            end;
        end;

        POSEntry.Insert(false, true);
    end;

    local procedure InsertPOSSaleLine(POSSale: Record "NPR POS Sale"; POSSaleLine: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; ReverseSign: Boolean; var POSEntrySalesLine: Record "NPR POS Entry Sales Line")
    var
        PricesIncludeTax: Boolean;
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        POSEntrySalesLine.Reset();
        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";
        if POSEntrySalesLine.Find() then begin
            POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSEntrySalesLine.FindLast();
            POSEntrySalesLine."Line No." := POSEntrySalesLine."Line No." + 10000;
            POSEntrySalesLine.SetRange("POS Entry No.");
        end;

        POSEntrySalesLine.Init();
        POSEntrySalesLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSEntrySalesLine."POS Store Code" := POSSale."POS Store Code";
        POSEntrySalesLine."POS Unit No." := POSSaleLine."Register No.";
        POSEntrySalesLine."Document No." := POSSaleLine."Sales Ticket No.";
        POSEntrySalesLine."Customer No." := POSSale."Customer No.";
        POSEntrySalesLine."Salesperson Code" := POSSale."Salesperson Code";
        POSEntrySalesLine."Responsibility Center" := POSSaleLine."Responsibility Center";

        case POSSaleLine."Line Type" of
            POSSaleLine."Line Type"::Item:
                POSEntrySalesLine.Type := POSEntrySalesLine.Type::Item;
            POSSaleLine."Line Type"::"Customer Deposit":
                POSEntrySalesLine.Type := POSEntrySalesLine.Type::Customer;
            POSSaleLine."Line Type"::"Issue Voucher":
                POSEntrySalesLine.Type := POSEntrySalesLine.Type::Voucher;
            POSSaleLine."Line Type"::Rounding:
                POSEntrySalesLine.Type := POSEntrySalesLine.Type::Rounding;
            POSSaleLine."Line Type"::"GL Payment":
                if POSSaleLine."Gen. Posting Type" <> POSSaleLine."Gen. Posting Type"::Purchase then
                    POSEntrySalesLine.Type := POSEntrySalesLine.Type::"G/L Account"
                else
                    POSEntrySalesLine.Type := POSEntrySalesLine.Type::Payout;
            POSSaleLine."Line Type"::Comment:
                POSEntrySalesLine.Type := POSEntrySalesLine.Type::Comment;
        end;
        POSEntrySalesLine."Exclude from Posting" := ExcludeFromPosting(POSSaleLine);
        POSEntrySalesLine."Voucher Category" := POSSaleLine."Voucher Category";
        POSEntrySalesLine."No." := POSSaleLine."No.";
        POSEntrySalesLine."Variant Code" := POSSaleLine."Variant Code";
        POSEntrySalesLine."Location Code" := POSSaleLine."Location Code";
        POSEntrySalesLine."Bin Code" := POSSaleLine."Bin Code";
        POSEntrySalesLine."Posting Group" := POSSaleLine."Posting Group";
        POSEntrySalesLine.Description := POSSaleLine.Description;
        POSEntrySalesLine."Description 2" := POSSaleLine."Description 2";

        POSEntrySalesLine."Gen. Posting Type" := POSSaleLine."Gen. Posting Type";
        POSEntrySalesLine."Gen. Bus. Posting Group" := POSSaleLine."Gen. Bus. Posting Group";
        POSEntrySalesLine."VAT Bus. Posting Group" := POSSaleLine."VAT Bus. Posting Group";
        POSEntrySalesLine."Gen. Prod. Posting Group" := POSSaleLine."Gen. Prod. Posting Group";
        POSEntrySalesLine."VAT Prod. Posting Group" := POSSaleLine."VAT Prod. Posting Group";
        POSEntrySalesLine."Tax Area Code" := POSSaleLine."Tax Area Code";
        POSEntrySalesLine."Tax Liable" := POSSaleLine."Tax Liable";
        POSEntrySalesLine."Tax Group Code" := POSSaleLine."Tax Group Code";
        POSEntrySalesLine."Use Tax" := POSSaleLine."Use Tax";

        POSEntrySalesLine."Unit of Measure Code" := POSSaleLine."Unit of Measure Code";
        POSEntrySalesLine.Quantity := POSSaleLine.Quantity;
        POSEntrySalesLine."Quantity (Base)" := POSSaleLine."Quantity (Base)";
        POSEntrySalesLine."Qty. per Unit of Measure" := POSSaleLine."Qty. per Unit of Measure";
        POSEntrySalesLine."Unit Price" := POSSaleLine."Unit Price";
        POSEntrySalesLine."Unit Cost (LCY)" := POSSaleLine."Unit Cost (LCY)";
        POSEntrySalesLine."Unit Cost" := POSSaleLine."Unit Cost";
        POSEntrySalesLine."VAT %" := POSSaleLine."VAT %";
        POSEntrySalesLine."VAT Identifier" := POSSaleLine."VAT Identifier";
        POSEntrySalesLine."VAT Calculation Type" := POSSaleLine."VAT Calculation Type";

        POSEntrySalesLine."Discount Type" := POSSaleLine."Discount Type";
        POSEntrySalesLine."Discount Code" := POSSaleLine."Discount Code";
        POSEntrySalesLine."Discount Authorised by" := POSSaleLine."Discount Authorised by";

        POSEntrySalesLine."Reason Code" := POSSaleLine."Reason Code";
        POSEntrySalesLine."Line Discount %" := POSSaleLine."Discount %";

        PricesIncludeTax := POSSale."Prices Including VAT";
        if PricesIncludeTax then begin
            POSEntrySalesLine."Line Discount Amount Incl. VAT" := POSSaleLine."Discount Amount";
            POSEntrySalesLine."Line Discount Amount Excl. VAT" := POSSaleLine."Discount Amount" / (1 + (POSSaleLine."VAT %" / 100));
        end else begin
            POSEntrySalesLine."Line Discount Amount Excl. VAT" := POSSaleLine."Discount Amount";
            POSEntrySalesLine."Line Discount Amount Incl. VAT" := (1 + (POSSaleLine."VAT %" / 100)) * POSSaleLine."Discount Amount";
        end;

        POSEntrySalesLine."Amount Excl. VAT" := POSSaleLine.Amount;
        POSEntrySalesLine."Amount Incl. VAT" := POSSaleLine."Amount Including VAT";
        POSEntrySalesLine."VAT Base Amount" := POSSaleLine."VAT Base Amount";
        POSEntrySalesLine."Line Amount" := POSSaleLine."Line Amount";

        POSEntrySalesLine."Amount Excl. VAT (LCY)" := POSSaleLine.Amount * POSEntry."Currency Factor";
        POSEntrySalesLine."Amount Incl. VAT (LCY)" := POSSaleLine."Amount Including VAT" * POSEntry."Currency Factor";

        POSEntrySalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := POSEntrySalesLine."Line Discount Amount Excl. VAT" * POSEntry."Currency Factor";
        POSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := POSEntrySalesLine."Line Discount Amount Incl. VAT" * POSEntry."Currency Factor";

        POSEntrySalesLine.SystemId := POSSaleLine.SystemId;

        POSEntrySalesLine."Item Category Code" := POSSaleLine."Item Category Code";

        POSEntrySalesLine."Serial No." := POSSaleLine."Serial No.";
        POSEntrySalesLine."Lot No." := POSSaleLine."Lot No.";
        POSEntrySalesLine."Retail Serial No." := POSSaleLine."Serial No. not Created";
        POSEntrySalesLine."Return Reason Code" := POSSaleLine."Return Reason Code";
        POSEntrySalesLine."NPRE Seating Code" := POSSaleLine."NPRE Seating Code";
        POSEntrySalesLine."Orig.POS Entry S.Line SystemId" := POSSaleLine."Orig.POS Entry S.Line SystemId";
        POSEntrySalesLine."Copy Description" := POSSaleLine."Copy Description";

        CreateRMAEntry(POSEntry, POSSale, POSSaleLine);
        if POSSaleLine."Sales Document No." <> '' then
            if POSSaleLine."Sales Document Post" <> POSSaleLine."Sales Document Post"::Asynchronous then
                POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSSaleLine."Sales Document Type", POSSaleLine."Sales Document No.", POSAsyncPosting.GetInvoiceType(POSSaleLine))
            else
                POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReferenceAsyncPost(POSEntrySalesLine, POSSaleLine."Sales Document Type", POSSaleLine."Sales Document No.", POSAsyncPosting.GetInvoiceType(POSSaleLine), POSSaleLine."Sales Document Print",
                    POSSaleLine."Sales Document Send", POSSaleLine."Sales Document Pdf2Nav", POSSaleLine."Sales Doc. Prepay Is Percent", POSSaleLine."Sales Document Delete");

        if POSSaleLine."Posted Sales Document No." <> '' then begin
            case POSSaleLine."Posted Sales Document Type" of
                POSSaleLine."Posted Sales Document Type"::INVOICE:
                    POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE, POSSaleLine."Posted Sales Document No.", POSAsyncPosting.GetInvoiceType(POSSaleLine));
                POSSaleLine."Posted Sales Document Type"::CREDIT_MEMO:
                    POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSEntrySalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO, POSSaleLine."Posted Sales Document No.", POSAsyncPosting.GetInvoiceType(POSSaleLine));
            end;
        end;

        if POSSaleLine."Delivered Sales Document No." <> '' then begin
            case POSSaleLine."Delivered Sales Document Type" of
                POSSaleLine."Delivered Sales Document Type"::SHIPMENT:
                    POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSEntrySalesDocLink."Sales Document Type"::SHIPMENT, POSSaleLine."Delivered Sales Document No.", POSAsyncPosting.GetInvoiceType(POSSaleLine));
                POSSaleLine."Delivered Sales Document Type"::RETURN_RECEIPT:
                    POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSEntrySalesLine, POSEntrySalesDocLink."Sales Document Type"::RETURN_RECEIPT, POSSaleLine."Delivered Sales Document No.", POSAsyncPosting.GetInvoiceType(POSSaleLine));
            end;
        end;

        POSEntrySalesLine."Applies-to Doc. Type" := POSSaleLine."Buffer Document Type";
        POSEntrySalesLine."Applies-to Doc. No." := POSSaleLine."Buffer Document No.";

        POSEntrySalesLine."Shortcut Dimension 1 Code" := POSSaleLine."Shortcut Dimension 1 Code";
        POSEntrySalesLine."Shortcut Dimension 2 Code" := POSSaleLine."Shortcut Dimension 2 Code";
        POSEntrySalesLine."Dimension Set ID" := POSSaleLine."Dimension Set ID";
        if ReverseSign then begin
            POSEntrySalesLine.Quantity := -POSEntrySalesLine.Quantity;
            POSEntrySalesLine."Line Discount Amount Excl. VAT" := -POSEntrySalesLine."Line Discount Amount Excl. VAT";
            POSEntrySalesLine."Line Discount Amount Incl. VAT" := -POSEntrySalesLine."Line Discount Amount Incl. VAT";
            POSEntrySalesLine."Amount Excl. VAT" := -POSEntrySalesLine."Amount Excl. VAT";
            POSEntrySalesLine."Amount Incl. VAT" := -POSEntrySalesLine."Amount Incl. VAT";
            POSEntrySalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := -POSEntrySalesLine."Line Dsc. Amt. Excl. VAT (LCY)";
            POSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := -POSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)";

            POSEntrySalesLine."Amount Excl. VAT (LCY)" := -POSEntrySalesLine."Amount Excl. VAT (LCY)";
            POSEntrySalesLine."Amount Incl. VAT (LCY)" := -POSEntrySalesLine."Amount Incl. VAT (LCY)";
            POSEntrySalesLine."VAT Base Amount" := -POSEntrySalesLine."VAT Base Amount";
            POSEntrySalesLine."Quantity (Base)" := -POSEntrySalesLine."Quantity (Base)";
            POSEntrySalesLine."VAT Difference" := -POSEntrySalesLine."VAT Difference";
        end;
        POSEntrySalesLine."POS Sale Line Created At" := POSSaleLine."Created At";
        POSEntrySalesLine."Return Sale Sales Ticket No." := POSSaleLine."Return Sale Sales Ticket No.";
        OnBeforeInsertPOSSalesLine(POSSale, POSSaleLine, POSEntry, POSEntrySalesLine);
        POSEntrySalesLine.Insert(false, true);
        OnAfterInsertPOSSalesLine(POSSale, POSSaleLine, POSEntry, POSEntrySalesLine);
    end;

    local procedure InsertBufferPOSSaleLine(POSSaleLine: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry")
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSEntrySalesDocLink2: Record "NPR POS Entry Sales Doc. Link";
        BufferPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        POSEntrySalesDocLink.SetCurrentKey("POS Entry No.", "Sales Document Type", "Orig. Sales Document No.", "Orig. Sales Document Type");
        POSEntrySalesDocLink.SetFilter("Orig. Sales Document No.", POSSaleLine."Sales Document No.");
        POSEntrySalesDocLink.SetRange("Orig. Sales Document Type", POSSaleLine."Sales Document Type");
        if not POSEntrySalesDocLink.FindFirst() then
            exit;
        //Find previous non-items entries for same order
        POSEntrySalesDocLink2.SetCurrentKey("POS Entry No.");
        POSEntrySalesDocLink2.SetAscending("POS Entry No.", false);
        POSEntrySalesDocLink2.SetRange("Orig. Sales Document No.", POSEntrySalesDocLink."Orig. Sales Document No.");
        POSEntrySalesDocLink2.SetRange("Orig. Sales Document Type", POSEntrySalesDocLink."Orig. Sales Document Type");
        POSEntrySalesDocLink2.SetFilter("POS Entry No.", '<%1', POSEntry."Entry No.");
        if POSEntrySalesDocLink2.FindFirst() then begin
            POSEntrySalesLine.SetRange("POS Entry No.", POSEntrySalesDocLink2."POS Entry No.");
            POSEntrySalesLine.SetFilter(Type, '<>%1', POSEntrySalesLine.Type::Item);
            if POSEntrySalesLine.FindSet() then
                repeat
                    BufferPOSEntrySalesLine.Reset();
                    BufferPOSEntrySalesLine.Init();
                    BufferPOSEntrySalesLine.TransferFields(POSEntrySalesLine);
                    InitBufferPOSEntrySalesLine(BufferPOSEntrySalesLine, POSEntry);
                    BufferPOSEntrySalesLine.Insert();
                until POSEntrySalesLine.Next() = 0;
        end;
        //items fetched from sale document
        if POSSaleLine."Sales Document Post" = POSSaleLine."Sales Document Post"::Posted then begin//posted in meantime in BC
            if POSSaleLine."Sales Document Ship" or
                POSSaleLine."Sales Document Receive" or
                 POSSaleLine."Sales Document Invoice" then
                if POSSaleLine."Posted Sales Document No." <> '' then begin
                    if POSSaleLine."Posted Sales Document Type" = POSSaleLine."Posted Sales Document Type"::INVOICE then begin
                        if SalesInvoiceHeader.Get(POSSaleLine."Posted Sales Document No.") then
                            InsertItemLines(POSEntry, SalesInvoiceHeader);
                    end else
                        if SalesCrMemoHeader.Get(POSSaleLine."Posted Sales Document No.") then
                            InsertItemLines(POSEntry, SalesCrMemoHeader);
                end;
            if POSSaleLine."Sales Document Prepayment" or
            POSSaleLine."Sales Document Prepay. Refund" then
                if POSEntrySalesDocLink."Sales Document Type" = POSEntrySalesDocLink."Sales Document Type"::ORDER then
                    if SalesHeader.Get(SalesHeader."Document Type"::Order, POSSaleLine."Sales Document No.") then
                        InsertItemLines(POSSaleLine, POSEntry, SalesHeader);

        end else begin
            if POSSaleLine."Sales Document No." <> '' then
                if SalesHeader.Get(POSSaleLine."Sales Document Type", POSSaleLine."Sales Document No.") then
                    InsertItemLines(POSSaleLine, POSEntry, SalesHeader);
        end;
    end;


    local procedure GetLastPOSEntrySaleLineLineNo(POSEntry: Record "NPR POS Entry"): Integer
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSEntrySalesLine.FindLast() then
            exit(POSEntrySalesLine."Line No." + 10000)
        else
            exit(10000)
    end;

    local procedure InitBufferPOSEntrySalesLine(var DummyPOSEntrySalesLine: Record "NPR POS Entry Sales Line"; POSEntry: Record "NPR POS Entry")
    begin
        DummyPOSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        DummyPOSEntrySalesLine."Line No." := GetLastPOSEntrySaleLineLineNo(POSEntry);
        DummyPOSEntrySalesLine."POS Period Register No." := POSEntry."POS Period Register No.";
        DummyPOSEntrySalesLine."Exclude from Posting" := true;
        DummyPOSEntrySalesLine."POS Store Code" := POSEntry."POS Store Code";
        DummyPOSEntrySalesLine."POS Unit No." := POSEntry."POS Unit No.";
        DummyPOSEntrySalesLine."Document No." := POSEntry."Document No.";
        DummyPOSEntrySalesLine."Customer No." := POSEntry."Customer No.";
        DummyPOSEntrySalesLine."Salesperson Code" := POSEntry."Salesperson Code";
    end;

    local procedure InsertItemLines(POSEntry: Record "NPR POS Entry"; SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        BufferPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        PricesIncludeTax: Boolean;
        ItemTrackingDocManagement: Codeunit "Item Tracking Doc. Management";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
    begin
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter(Type, '=%1', SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SetFilter(Quantity, '<>%1', 0);
        if SalesInvoiceLine.FindSet() then
            repeat
                BufferPOSEntrySalesLine.Reset();
                BufferPOSEntrySalesLine.Init();
                InitBufferPOSEntrySalesLine(BufferPOSEntrySalesLine, POSEntry);
                BufferPOSEntrySalesLine.Insert();

                BufferPOSEntrySalesLine.Type := BufferPOSEntrySalesLine.Type::Item;
                BufferPOSEntrySalesLine."Responsibility Center" := SalesInvoiceLine."Responsibility Center";
                BufferPOSEntrySalesLine."No." := SalesInvoiceLine."No.";
                BufferPOSEntrySalesLine."Variant Code" := SalesInvoiceLine."Variant Code";
                BufferPOSEntrySalesLine."Location Code" := SalesInvoiceLine."Location Code";
                BufferPOSEntrySalesLine."Bin Code" := SalesInvoiceLine."Bin Code";
                BufferPOSEntrySalesLine."Posting Group" := SalesInvoiceLine."Posting Group";
                BufferPOSEntrySalesLine.Description := SalesInvoiceLine.Description;
                BufferPOSEntrySalesLine."Description 2" := SalesInvoiceLine."Description 2";
                BufferPOSEntrySalesLine."Gen. Bus. Posting Group" := SalesInvoiceLine."Gen. Bus. Posting Group";
                BufferPOSEntrySalesLine."VAT Bus. Posting Group" := SalesInvoiceLine."VAT Bus. Posting Group";
                BufferPOSEntrySalesLine."Gen. Prod. Posting Group" := SalesInvoiceLine."Gen. Prod. Posting Group";
                BufferPOSEntrySalesLine."VAT Prod. Posting Group" := SalesInvoiceLine."VAT Prod. Posting Group";
                BufferPOSEntrySalesLine."Tax Area Code" := SalesInvoiceLine."Tax Area Code";
                BufferPOSEntrySalesLine."Tax Liable" := SalesInvoiceLine."Tax Liable";
                BufferPOSEntrySalesLine."Tax Group Code" := SalesInvoiceLine."Tax Group Code";
                BufferPOSEntrySalesLine."Unit of Measure Code" := SalesInvoiceLine."Unit of Measure Code";
                BufferPOSEntrySalesLine."Qty. per Unit of Measure" := SalesInvoiceLine."Qty. per Unit of Measure";
                BufferPOSEntrySalesLine."Unit Price" := SalesInvoiceLine."Unit Price";
                BufferPOSEntrySalesLine."Unit Cost (LCY)" := SalesInvoiceLine."Unit Cost (LCY)";
                BufferPOSEntrySalesLine."Unit Cost" := SalesInvoiceLine."Unit Cost";
                BufferPOSEntrySalesLine."VAT %" := SalesInvoiceLine."VAT %";
                BufferPOSEntrySalesLine."VAT Identifier" := SalesInvoiceLine."VAT Identifier";
                BufferPOSEntrySalesLine."VAT Calculation Type" := SalesInvoiceLine."VAT Calculation Type";

                PricesIncludeTax := SalesInvoiceHeader."Prices Including VAT";
                if PricesIncludeTax then begin
                    BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" := SalesInvoiceLine."Line Discount Amount";
                    BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" := SalesInvoiceLine."Line Discount Amount" / (1 + (SalesInvoiceLine."VAT %" / 100));
                end else begin
                    BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" := SalesInvoiceLine."Line Discount Amount";
                    BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" := (1 + (SalesInvoiceLine."VAT %" / 100)) * SalesInvoiceLine."Line Discount Amount";
                end;

                BufferPOSEntrySalesLine."Line Amount" := SalesInvoiceLine."Line Amount";
                BufferPOSEntrySalesLine."Amount Excl. VAT (LCY)" := SalesInvoiceLine.Amount * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Amount Incl. VAT (LCY)" := SalesInvoiceLine."Amount Including VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Item Category Code" := SalesInvoiceLine."Item Category Code";
                ItemTrackingDocManagement.RetrieveEntriesFromPostedInvoice(TempItemLedgEntry, SalesInvoiceLine.RowID1());
                BufferPOSEntrySalesLine."Serial No." := TempItemLedgEntry."Serial No.";

                BufferPOSEntrySalesLine."Return Reason Code" := SalesInvoiceLine."Return Reason Code";
                BufferPOSEntrySalesLine.Quantity := SalesInvoiceLine.Quantity;
                BufferPOSEntrySalesLine."Line Discount %" := SalesInvoiceLine."Line Discount %";
                BufferPOSEntrySalesLine."Dimension Set ID" := SalesInvoiceLine."Dimension Set ID";
                BufferPOSEntrySalesLine."Amount Excl. VAT" := SalesInvoiceLine.Amount;
                BufferPOSEntrySalesLine."Amount Incl. VAT" := SalesInvoiceLine."Amount Including VAT";
                BufferPOSEntrySalesLine."VAT Base Amount" := SalesInvoiceLine."VAT Base Amount";
                BufferPOSEntrySalesLine."Quantity (Base)" := SalesInvoiceLine."Quantity (Base)";
                BufferPOSEntrySalesLine."VAT Difference" := SalesInvoiceLine."VAT Difference";
                BufferPOSEntrySalesLine.Modify();

            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure InsertItemLines(POSEntry: Record "NPR POS Entry"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        BufferPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        PricesIncludeTax: Boolean;
        ItemTrackingDocManagement: Codeunit "Item Tracking Doc. Management";
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
    begin
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Type, '=%1', SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.SetFilter(Quantity, '<>%1', 0);
        if SalesCrMemoLine.FindSet() then
            repeat
                BufferPOSEntrySalesLine.Reset();
                BufferPOSEntrySalesLine.Init();
                InitBufferPOSEntrySalesLine(BufferPOSEntrySalesLine, POSEntry);
                BufferPOSEntrySalesLine.Insert();

                BufferPOSEntrySalesLine.Type := BufferPOSEntrySalesLine.Type::Item;
                BufferPOSEntrySalesLine."Responsibility Center" := SalesCrMemoLine."Responsibility Center";
                BufferPOSEntrySalesLine."No." := SalesCrMemoLine."No.";
                BufferPOSEntrySalesLine."Variant Code" := SalesCrMemoLine."Variant Code";
                BufferPOSEntrySalesLine."Location Code" := SalesCrMemoLine."Location Code";
                BufferPOSEntrySalesLine."Bin Code" := SalesCrMemoLine."Bin Code";
                BufferPOSEntrySalesLine."Posting Group" := SalesCrMemoLine."Posting Group";
                BufferPOSEntrySalesLine.Description := SalesCrMemoLine.Description;
                BufferPOSEntrySalesLine."Description 2" := SalesCrMemoLine."Description 2";
                BufferPOSEntrySalesLine."Gen. Bus. Posting Group" := SalesCrMemoLine."Gen. Bus. Posting Group";
                BufferPOSEntrySalesLine."VAT Bus. Posting Group" := SalesCrMemoLine."VAT Bus. Posting Group";
                BufferPOSEntrySalesLine."Gen. Prod. Posting Group" := SalesCrMemoLine."Gen. Prod. Posting Group";
                BufferPOSEntrySalesLine."VAT Prod. Posting Group" := SalesCrMemoLine."VAT Prod. Posting Group";
                BufferPOSEntrySalesLine."Tax Area Code" := SalesCrMemoLine."Tax Area Code";
                BufferPOSEntrySalesLine."Tax Liable" := SalesCrMemoLine."Tax Liable";
                BufferPOSEntrySalesLine."Tax Group Code" := SalesCrMemoLine."Tax Group Code";
                BufferPOSEntrySalesLine."Unit of Measure Code" := SalesCrMemoLine."Unit of Measure Code";
                BufferPOSEntrySalesLine."Qty. per Unit of Measure" := SalesCrMemoLine."Qty. per Unit of Measure";
                BufferPOSEntrySalesLine."Unit Price" := SalesCrMemoLine."Unit Price";
                BufferPOSEntrySalesLine."Unit Cost (LCY)" := SalesCrMemoLine."Unit Cost (LCY)";
                BufferPOSEntrySalesLine."Unit Cost" := SalesCrMemoLine."Unit Cost";
                BufferPOSEntrySalesLine."VAT %" := SalesCrMemoLine."VAT %";
                BufferPOSEntrySalesLine."VAT Identifier" := SalesCrMemoLine."VAT Identifier";
                BufferPOSEntrySalesLine."VAT Calculation Type" := SalesCrMemoLine."VAT Calculation Type";

                PricesIncludeTax := SalesCrMemoHeader."Prices Including VAT";
                if PricesIncludeTax then begin
                    BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" := SalesCrMemoLine."Line Discount Amount";
                    BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" := SalesCrMemoLine."Line Discount Amount" / (1 + (SalesCrMemoLine."VAT %" / 100));
                end else begin
                    BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" := SalesCrMemoLine."Line Discount Amount";
                    BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" := (1 + (SalesCrMemoLine."VAT %" / 100)) * SalesCrMemoLine."Line Discount Amount";
                end;

                BufferPOSEntrySalesLine."Line Amount" := SalesCrMemoLine."Line Amount";
                BufferPOSEntrySalesLine."Amount Excl. VAT (LCY)" := SalesCrMemoLine.Amount * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Amount Incl. VAT (LCY)" := SalesCrMemoLine."Amount Including VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Item Category Code" := SalesCrMemoLine."Item Category Code";
                ItemTrackingDocManagement.RetrieveEntriesFromPostedInvoice(TempItemLedgEntry, SalesCrMemoLine.RowID1());
                BufferPOSEntrySalesLine."Serial No." := TempItemLedgEntry."Serial No.";
                BufferPOSEntrySalesLine."Return Reason Code" := SalesCrMemoLine."Return Reason Code";
                BufferPOSEntrySalesLine.Quantity := SalesCrMemoLine.Quantity;
                BufferPOSEntrySalesLine."Line Discount %" := SalesCrMemoLine."Line Discount %";
                BufferPOSEntrySalesLine."Dimension Set ID" := SalesCrMemoLine."Dimension Set ID";
                BufferPOSEntrySalesLine."Amount Excl. VAT" := SalesCrMemoLine.Amount;
                BufferPOSEntrySalesLine."Amount Incl. VAT" := SalesCrMemoLine."Amount Including VAT";
                BufferPOSEntrySalesLine."VAT Base Amount" := SalesCrMemoLine."VAT Base Amount";
                BufferPOSEntrySalesLine."Quantity (Base)" := SalesCrMemoLine."Quantity (Base)";
                BufferPOSEntrySalesLine."VAT Difference" := SalesCrMemoLine."VAT Difference";
                BufferPOSEntrySalesLine.Modify();

            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure InsertItemLines(POSSaleLine: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        PricesIncludeTax: Boolean;
        ReservationEntry: Record "Reservation Entry";
        BufferPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '=%1', SalesLine.Type::Item);
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        if SalesLine.FindSet() then
            repeat
                BufferPOSEntrySalesLine.Reset();
                BufferPOSEntrySalesLine.Init();
                InitBufferPOSEntrySalesLine(BufferPOSEntrySalesLine, POSEntry);
                BufferPOSEntrySalesLine.Insert();

                BufferPOSEntrySalesLine.Type := BufferPOSEntrySalesLine.Type::Item;
                BufferPOSEntrySalesLine."Responsibility Center" := SalesLine."Responsibility Center";
                BufferPOSEntrySalesLine."No." := SalesLine."No.";
                BufferPOSEntrySalesLine."Variant Code" := SalesLine."Variant Code";
                BufferPOSEntrySalesLine."Location Code" := SalesLine."Location Code";
                BufferPOSEntrySalesLine."Bin Code" := SalesLine."Bin Code";
                BufferPOSEntrySalesLine."Posting Group" := SalesLine."Posting Group";
                BufferPOSEntrySalesLine.Description := SalesLine.Description;
                BufferPOSEntrySalesLine."Description 2" := SalesLine."Description 2";
                BufferPOSEntrySalesLine."Gen. Bus. Posting Group" := SalesLine."Gen. Bus. Posting Group";
                BufferPOSEntrySalesLine."VAT Bus. Posting Group" := SalesLine."VAT Bus. Posting Group";
                BufferPOSEntrySalesLine."Gen. Prod. Posting Group" := SalesLine."Gen. Prod. Posting Group";
                BufferPOSEntrySalesLine."VAT Prod. Posting Group" := SalesLine."VAT Prod. Posting Group";
                BufferPOSEntrySalesLine."Tax Area Code" := SalesLine."Tax Area Code";
                BufferPOSEntrySalesLine."Tax Liable" := SalesLine."Tax Liable";
                BufferPOSEntrySalesLine."Tax Group Code" := SalesLine."Tax Group Code";
                BufferPOSEntrySalesLine."Dimension Set ID" := SalesLine."Dimension Set ID";
                BufferPOSEntrySalesLine."Unit of Measure Code" := SalesLine."Unit of Measure Code";
                BufferPOSEntrySalesLine."Qty. per Unit of Measure" := SalesLine."Qty. per Unit of Measure";
                BufferPOSEntrySalesLine."Unit Price" := SalesLine."Unit Price";
                BufferPOSEntrySalesLine."Unit Cost (LCY)" := SalesLine."Unit Cost (LCY)";
                BufferPOSEntrySalesLine."Unit Cost" := SalesLine."Unit Cost";
                BufferPOSEntrySalesLine."VAT %" := SalesLine."VAT %";
                BufferPOSEntrySalesLine."VAT Identifier" := SalesLine."VAT Identifier";
                BufferPOSEntrySalesLine."VAT Calculation Type" := SalesLine."VAT Calculation Type";

                PricesIncludeTax := SalesHeader."Prices Including VAT";
                if PricesIncludeTax then begin
                    BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" := SalesLine."Line Discount Amount";
                    BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" := SalesLine."Line Discount Amount" / (1 + (SalesLine."VAT %" / 100));
                end else begin
                    BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" := SalesLine."Line Discount Amount";
                    BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" := (1 + (SalesLine."VAT %" / 100)) * SalesLine."Line Discount Amount";
                end;

                BufferPOSEntrySalesLine."Line Amount" := SalesLine."Line Amount";
                BufferPOSEntrySalesLine."Amount Excl. VAT (LCY)" := SalesLine.Amount * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Amount Incl. VAT (LCY)" := SalesLine."Amount Including VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" * POSEntry."Currency Factor";
                BufferPOSEntrySalesLine."Item Category Code" := SalesLine."Item Category Code";

                ReservationEntry.SetRange("Item No.", SalesLine."No.");
                ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
                ReservationEntry.SetRange("Source Type", Database::"Sales Line");
                ReservationEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
                ReservationEntry.SetRange("Source Subtype", SalesLine."Document Type");
                if ReservationEntry.FindFirst() then
                    BufferPOSEntrySalesLine."Serial No." := ReservationEntry."Serial No.";

                BufferPOSEntrySalesLine."Return Reason Code" := SalesLine."Return Reason Code";
                BufferPOSEntrySalesLine.Quantity := SalesLine.Quantity;
                BufferPOSEntrySalesLine."Line Discount %" := SalesLine."Line Discount %";
                BufferPOSEntrySalesLine."Line Discount Amount Excl. VAT" := SalesLine."Line Discount Amount";
                BufferPOSEntrySalesLine."Line Discount Amount Incl. VAT" := SalesLine."Line Discount Amount";
                BufferPOSEntrySalesLine."Amount Excl. VAT" := SalesLine.Amount;
                BufferPOSEntrySalesLine."Amount Incl. VAT" := SalesLine."Amount Including VAT";
                BufferPOSEntrySalesLine."VAT Base Amount" := SalesLine."VAT Base Amount";
                BufferPOSEntrySalesLine."Quantity (Base)" := SalesLine."Quantity (Base)";
                BufferPOSEntrySalesLine."VAT Difference" := SalesLine."VAT Difference";
                BufferPOSEntrySalesLine.Modify();

                POSAsyncPostingMgt.InsertPOSEntrySalesLineRelation(POSSaleLine, POSEntry, SalesLine, BufferPOSEntrySalesLine);
            until SalesLine.Next() = 0;
    end;

    local procedure InsertPOSPaymentLine(POSSale: Record "NPR POS Sale"; POSSaleLine: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSEntryPaymentLine: Record "NPR POS Entry Payment Line")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSEntryPaymentLine.Init();
        POSEntryPaymentLine."POS Entry No." := POSEntry."Entry No.";
        POSEntryPaymentLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSEntryPaymentLine."Line No." := POSSaleLine."Line No.";

        POSEntryPaymentLine.SetRecFilter();
        if not POSEntryPaymentLine.IsEmpty() then
            repeat
                POSEntryPaymentLine."Line No." := POSEntryPaymentLine."Line No." + 10000;
                POSEntryPaymentLine.SetRecFilter();
            until POSEntryPaymentLine.IsEmpty();
        POSEntryPaymentLine.Reset();

        POSEntryPaymentLine."POS Store Code" := POSSale."POS Store Code";
        POSEntryPaymentLine."POS Unit No." := POSSaleLine."Register No.";
        POSEntryPaymentLine."Document No." := POSSaleLine."Sales Ticket No.";
        POSEntryPaymentLine."Responsibility Center" := POSSaleLine."Responsibility Center";

#pragma warning disable AA0139
        if (not POSPaymentMethod.Get(POSSaleLine."No.")) then
            POSPaymentMethod.Init();
        POSEntryPaymentLine."POS Payment Method Code" := POSSaleLine."No.";
#pragma warning restore

        POSEntryPaymentLine."Voucher Category" := POSSaleLine."Voucher Category";
        POSEntryPaymentLine."POS Payment Bin Code" := SelectUnitBin(POSEntryPaymentLine."POS Unit No.");

        POSEntryPaymentLine.Description := POSSaleLine.Description;
        if POSSaleLine."Currency Amount" <> 0 then begin
            POSEntryPaymentLine.Amount := POSSaleLine."Currency Amount";
            POSEntryPaymentLine."Payment Amount" := POSSaleLine."Currency Amount";
        end else begin
            POSEntryPaymentLine.Amount := POSSaleLine."Amount Including VAT";
            POSEntryPaymentLine."Payment Amount" := POSSaleLine."Amount Including VAT";
        end;
        POSEntryPaymentLine."Amount (LCY)" := POSSaleLine."Amount Including VAT";
        POSEntryPaymentLine."Amount (Sales Currency)" := POSSaleLine."Amount Including VAT"; //Sales Currency is always LCY for now
        POSEntryPaymentLine."Currency Code" := POSPaymentMethod."Currency Code";

        POSEntryPaymentLine.EFT := POSSaleLine."EFT Approved";
        POSEntryPaymentLine.SystemId := POSSaleLine.SystemId;

        POSEntryPaymentLine."Shortcut Dimension 1 Code" := POSSaleLine."Shortcut Dimension 1 Code";
        POSEntryPaymentLine."Shortcut Dimension 2 Code" := POSSaleLine."Shortcut Dimension 2 Code";
        POSEntryPaymentLine."Dimension Set ID" := POSSaleLine."Dimension Set ID";

        POSEntryPaymentLine."VAT Base Amount (LCY)" := POSSaleLine."Amount Including VAT";
        if (POSSaleLine."VAT Base Amount" <> 0) then begin
            POSEntryPaymentLine."VAT Amount (LCY)" := POSSaleLine."Amount Including VAT" - POSSaleLine."VAT Base Amount";
            POSEntryPaymentLine."VAT Base Amount (LCY)" := POSSaleLine."VAT Base Amount";
        end;

        POSEntryPaymentLine."VAT Bus. Posting Group" := POSSaleLine."VAT Bus. Posting Group";
        POSEntryPaymentLine."VAT Prod. Posting Group" := POSSaleLine."VAT Prod. Posting Group";
        POSEntryPaymentLine."POS Payment Line Created At" := POSSaleLine."Created At";
        CreatePaymentLineBinEntry(POSEntryPaymentLine);

        OnBeforeInsertPOSPaymentLine(POSSale, POSSaleLine, POSEntry, POSEntryPaymentLine);

        POSEntryPaymentLine.Insert(false, true);
        OnAfterInsertPOSPaymentLine(POSSale, POSSaleLine, POSEntry, POSEntryPaymentLine);
    end;

    local procedure InsertPOSBalancingLine(PaymentBinEntryNo: Integer; POSEntry: Record "NPR POS Entry"; LineNo: Integer; IsBinTransfer: Boolean)
    var
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSBinEntry: Record "NPR POS Bin Entry";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Difference: Decimal;
        POSBalancingLineDescriptionLbl: Label '%1: %2 - %3', Locked = true;
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin

        PaymentBinCheckpoint.Get(PaymentBinEntryNo);

        POSBalancingLine.Init();
        POSBalancingLine."POS Entry No." := POSEntry."Entry No.";
        POSBalancingLine."Line No." := LineNo;
        POSBalancingLine.Description := StrSubstNo(POSBalancingLineDescriptionLbl, POSEntry.TableCaption, POSEntry."Entry No.", PaymentBinCheckpoint."Payment Method No.");

        POSBalancingLine."POS Bin Checkpoint Entry No." := PaymentBinCheckpoint."Entry No.";
        POSBalancingLine."POS Period Register No." := POSEntry."POS Period Register No.";

        POSBalancingLine."POS Store Code" := POSEntry."POS Store Code";
        POSBalancingLine."POS Unit No." := POSEntry."POS Unit No.";
        POSBalancingLine."Document No." := POSEntry."Document No.";
        POSBalancingLine."Shortcut Dimension 1 Code" := POSEntry."Shortcut Dimension 1 Code";
        POSBalancingLine."Shortcut Dimension 2 Code" := POSEntry."Shortcut Dimension 2 Code";
        POSBalancingLine."Dimension Set ID" := POSEntry."Dimension Set ID";

        POSBalancingLine."POS Payment Bin Code" := PaymentBinCheckpoint."Payment Bin No.";
        POSBalancingLine."POS Payment Method Code" := PaymentBinCheckpoint."Payment Method No.";

        POSBalancingLine."Currency Code" := PaymentBinCheckpoint."Currency Code";
        if (POSPaymentMethod.Get(PaymentBinCheckpoint."Payment Method No.")) then
            POSBalancingLine."Currency Code" := POSPaymentMethod."Currency Code";

        POSBalancingLine."Calculated Amount" := PaymentBinCheckpoint."Calculated Amount Incl. Float" - PaymentBinCheckpoint."New Float Amount";
        POSBalancingLine."Balanced Amount" := PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."New Float Amount";
        POSBalancingLine."Balanced Diff. Amount" := PaymentBinCheckpoint."Calculated Amount Incl. Float" - PaymentBinCheckpoint."Counted Amount Incl. Float";
        POSBalancingLine."New Float Amount" := PaymentBinCheckpoint."New Float Amount";

        // Update CP Entry with Calculated amount (reveresed)
        POSBinEntry.Get(PaymentBinCheckpoint."Checkpoint Bin Entry No.");

        POSBinEntry."Bin Checkpoint Entry No." := PaymentBinCheckpoint."Entry No.";
        POSBinEntry."Transaction Currency Code" := PaymentBinCheckpoint."Currency Code";
        POSBinEntry."Transaction Amount" := PaymentBinCheckpoint."Calculated Amount Incl. Float" * -1;
        CalculateTransactionAmountLCY(POSBinEntry);
        POSBinEntry.Comment := 'Calculated Bin Content';

        POSBinEntry."POS Store Code" := POSEntry."POS Store Code";
        POSBinEntry.Modify();

        // At this point the BIN sum should be zero
        // Confirming the different adjustments and counted, transfers etc
        InsertBinAdjustment(POSBinEntry, PaymentBinCheckpoint."Calculated Amount Incl. Float", 'Expected Count');

        // Difference will be negative when we are missing money
        Difference := (PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."Calculated Amount Incl. Float");
        if ((Difference <> 0) and (PaymentBinCheckpoint.Comment <> '')) then
            InsertBinDifference(POSBinEntry, (PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."Calculated Amount Incl. Float"), PaymentBinCheckpoint.Comment);

        // Move to a different bin instruction ("The safe")
        if (PaymentBinCheckpoint."Move to Bin Amount" <> 0) then begin
            if (PaymentBinCheckpoint."Move to Bin Reference" = '') then begin
                PaymentBinCheckpoint."Move to Bin Reference" := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(PaymentBinCheckpoint."Move to Bin Reference"));
                PaymentBinCheckpoint.Modify();
            end;
            PaymentBinCheckpoint.TestField("Move to Bin Code");
            POSBalancingLine."Move-To Bin Code" := PaymentBinCheckpoint."Move to Bin Code";
            POSBalancingLine."Move-To Bin Amount" := PaymentBinCheckpoint."Move to Bin Amount";
            POSBalancingLine."Move-To Reference" := PaymentBinCheckpoint."Move to Bin Reference";
            InsertBinTransfer(POSBinEntry,
                PaymentBinCheckpoint."Move to Bin Code", PaymentBinCheckpoint."Move to Bin Amount", PaymentBinCheckpoint."Move to Bin Reference",
                PaymentBinCheckpoint."Transfer IN", false);
        end;

        // Move to a different bin instruction (The "BANK")
        if (PaymentBinCheckpoint."Bank Deposit Amount" <> 0) then begin
            if (PaymentBinCheckpoint."Bank Deposit Reference" = '') then begin
                PaymentBinCheckpoint."Bank Deposit Reference" := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(PaymentBinCheckpoint."Bank Deposit Reference"));
                PaymentBinCheckpoint.Modify();
            end;
            PaymentBinCheckpoint.TestField("Bank Deposit Bin Code");
            POSBalancingLine."Deposit-To Bin Code" := PaymentBinCheckpoint."Bank Deposit Bin Code";
            POSBalancingLine."Deposit-To Bin Amount" := PaymentBinCheckpoint."Bank Deposit Amount";
            POSBalancingLine."Deposit-To Reference" := PaymentBinCheckpoint."Bank Deposit Reference";
            InsertBinTransfer(POSBinEntry,
                PaymentBinCheckpoint."Bank Deposit Bin Code", PaymentBinCheckpoint."Bank Deposit Amount", PaymentBinCheckpoint."Bank Deposit Reference",
                PaymentBinCheckpoint."Transfer IN", true);
        end;

        // When doing bin transfer we dont want to recalculate the float as it upset the EOD counting
        if (not IsBinTransfer) then begin
            // This is to remove the calculated float and get bin sum to zero. counted - transfers
            InsertBinAdjustment(POSBinEntry,
              (PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."Bank Deposit Amount" - PaymentBinCheckpoint."Move to Bin Amount") * -1,
              'Calculated Float');

            // At this point Bin Sum is zero
            // Adjust up with the current float amount
            InsertFloatEntry(POSBinEntry, PaymentBinCheckpoint."New Float Amount", 'New Float');
        end;

        OnBeforeInsertPOSBalanceLine(PaymentBinCheckpoint, POSEntry, POSBalancingLine);
        POSBalancingLine.Insert();
    end;

    internal procedure InsertBinTransfer(CheckpointEntry: Record "NPR POS Bin Entry"; BalancingBinNo: Code[10]; TransactionAmount: Decimal; Reference: Text[50]; TransferIn: Boolean; BankTransfer: Boolean)
    var
        POSBinEntry: Record "NPR POS Bin Entry";
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        // Primary bin (POS unit)
        POSBinEntry.Init();
        POSBinEntry.TransferFields(CheckpointEntry);
        POSBinEntry."Entry No." := 0;
        if TransferIn then begin
            if BankTransfer then
                POSBinEntry.Type := POSBinEntry.Type::BANK_TRANSFER_IN
            else
                POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_IN;
        end else begin
            if BankTransfer then
                POSBinEntry.Type := POSBinEntry.Type::BANK_TRANSFER_OUT
            else
                POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_OUT;
        end;
        POSBinEntry."External Transaction No." := Reference;
        POSBinEntry.Comment := CopyStr(Format(POSBinEntry.Type), 1, MaxStrLen(POSBinEntry.Comment));
        POSBinEntry."Transaction Amount" := -TransactionAmount;
        CalculateTransactionAmountLCY(POSBinEntry);
        POSBinEntry.Insert();

        // Balancing bin (safe or bank or other POS)
        POSBinEntry."Entry No." := 0;
        POSBinEntry."Payment Bin No." := BalancingBinNo;
        if TransferIn then begin
            if BankTransfer then
                POSBinEntry.Type := POSBinEntry.Type::BANK_TRANSFER_OUT
            else
                POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_OUT;
        end else begin
            if BankTransfer then
                POSBinEntry.Type := POSBinEntry.Type::BANK_TRANSFER_IN
            else
                POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_IN;
        end;
        if not BankTransfer then begin
            POSPaymentBin.Get(POSBinEntry."Payment Bin No.");
            POSBinEntry."POS Unit No." := POSPaymentBin."Attached to POS Unit No.";
            POSBinEntry."Register No." := POSPaymentBin."Attached to POS Unit No.";
        end;
        POSBinEntry."Transaction Amount" := -POSBinEntry."Transaction Amount";
        POSBinEntry."Transaction Amount (LCY)" := -POSBinEntry."Transaction Amount (LCY)";
        POSBinEntry.Insert();
    end;

    internal procedure InsertBinAdjustment(CheckpointBinEntry: Record "NPR POS Bin Entry"; TransactionAmount: Decimal; Comment: Text[50])
    var
        POSBinEntry: Record "NPR POS Bin Entry";
    begin

        // Adjustment to bin
        POSBinEntry.Init();
        POSBinEntry.TransferFields(CheckpointBinEntry);
        POSBinEntry."Entry No." := 0;

        POSBinEntry.Type := POSBinEntry.Type::ADJUSTMENT;
        POSBinEntry."Transaction Amount" := TransactionAmount;
        CalculateTransactionAmountLCY(POSBinEntry);
        POSBinEntry.Comment := Comment;

        POSBinEntry.Insert();
    end;

    local procedure InsertBinDifference(CheckpointBinEntry: Record "NPR POS Bin Entry"; TransactionAmount: Decimal; Comment: Text[50])
    var
        POSBinEntry: Record "NPR POS Bin Entry";
    begin

        // Adjustment to bin
        POSBinEntry.Init();
        POSBinEntry.TransferFields(CheckpointBinEntry);
        POSBinEntry."Entry No." := 0;

        POSBinEntry.Type := POSBinEntry.Type::DIFFERENCE;
        POSBinEntry."Transaction Amount" := TransactionAmount;
        CalculateTransactionAmountLCY(POSBinEntry);
        POSBinEntry.Comment := Comment;

        OnBeforeInsertBinDifference(POSBinEntry);

        POSBinEntry.Insert();

        OnAfterInsertBinDifference(POSBinEntry);
    end;

    local procedure InsertFloatEntry(CheckpointBinEntry: Record "NPR POS Bin Entry"; TransactionAmount: Decimal; Comment: Text[50])
    var
        POSBinEntry: Record "NPR POS Bin Entry";
    begin

        // Adjustment to bin
        POSBinEntry.Init();
        POSBinEntry.TransferFields(CheckpointBinEntry);
        POSBinEntry."Entry No." := 0;

        POSBinEntry.Type := POSBinEntry.Type::FLOAT;
        POSBinEntry."Transaction Amount" := TransactionAmount;
        CalculateTransactionAmountLCY(POSBinEntry);
        POSBinEntry.Comment := Comment;

        POSBinEntry.Insert();
    end;

    procedure InsertUnitOpenEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Login (With Open)');

        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::UNIT_OPEN, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SIGN_IN, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
    end;

    internal procedure InsertUnitLoginEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin

        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Login');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SIGN_IN, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
    end;

    procedure InsertUnitCloseBeginEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Close (Balancing Begin)');
    end;

    procedure InsertUnitCloseEndEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Close (Balancing End)');
    end;

    internal procedure InsertUnitLogoutEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Logout');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SIGN_OUT, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
    end;

    internal procedure InsertUnitLockEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Lock');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::UNIT_LOCK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");

    end;

    internal procedure InsertUnitUnlockEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Unlock');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::UNIT_UNLOCK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");

    end;

    internal procedure InsertParkSaleEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Park Sale');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SALE_PARK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
    end;

    internal procedure InsertParkedSaleRetrievalEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]; ParkedSalesTicketNo: Code[20]; NewSalesTicketNo: Code[20]) EntryNo: Integer
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        LoadQuoteMsg: Label 'Parked sales ticket No. %1 loaded as ticket No. %2';
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Retrieve Parked Sale');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntryExtended(
          POSEntry.RecordId, POSAuditLog."Action Type"::SALE_LOAD, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.",
          StrSubstNo(LoadQuoteMsg, ParkedSalesTicketNo, NewSalesTicketNo), '');

    end;

    internal procedure InsertResumeSaleEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]; UnfinishedTicketNo: Code[20]; NewSalesTicketNo: Code[20]) EntryNo: Integer
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        ResumeSaleMsg: Label 'Unfinished sales ticket No. %1 resumed as ticket No. %2';
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
    begin

        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Resume Sale');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntryExtended(
          POSEntry.RecordId, POSAuditLog."Action Type"::SALE_LOAD, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.",
          StrSubstNo(ResumeSaleMsg, UnfinishedTicketNo, NewSalesTicketNo), '');
    end;

    internal procedure InsertTransferLocation(POSUnitNo: Code[10]; SalespersonCode: Code[20]; OldDocumentNo: Code[20]; NewDocumentNo: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
        SystemEventLbl: Label '[System Event] %1 transferred to location receipt %2', Locked = true;
    begin
        CreatePOSSystemEntry(POSUnitNo, SalespersonCode, CopyStr(StrSubstNo(SystemEventLbl, OldDocumentNo, NewDocumentNo), 1, MaxStrLen(POSEntry.Description)));

    end;

    local procedure CreatePOSSystemEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]; Description: Text[100]): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSPeriodRegister: Record "NPR POS Period Register";
    begin
        Clear(GlobalPOSEntry);
        if (not GetPOSPeriodRegisterForPOSUnit(POSUnitNo, POSPeriodRegister, false)) then
            Error(ERR_NO_OPEN_UNIT, POSPeriodRegister.TableCaption, POSPeriodRegister.FieldCaption("POS Unit No."), POSUnitNo);

        POSEntry.Init();
        POSEntry."Entry No." := 0;
        POSEntry."Entry Type" := POSEntry."Entry Type"::Other;
        POSEntry."System Entry" := true;

        POSEntry."POS Period Register No." := POSPeriodRegister."No.";
        POSEntry."POS Store Code" := GetStoreNoForUnitNo(POSUnitNo);
        POSEntry."POS Unit No." := POSUnitNo;
        POSEntry."Responsibility Center" := GetResponsibilityCenterForStoreCode(POSEntry."POS Store Code");

        POSEntry."Entry Date" := Today();
        POSEntry."Starting Time" := Time;
        POSEntry."Ending Time" := Time;
        POSEntry."Salesperson Code" := SalespersonCode;

        POSEntry.Description := Description;
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";

        POSEntry.Insert();

        GlobalPOSEntry := POSEntry;

        exit(POSEntry."Entry No.");
    end;

    local procedure CreatePaymentLineBinEntry(POSEntryPaymentLine: Record "NPR POS Entry Payment Line")
    var
        POSBinEntry: Record "NPR POS Bin Entry";
    begin

        POSBinEntry."Entry No." := 0;
        POSBinEntry."POS Entry No." := POSEntryPaymentLine."POS Entry No.";
        POSBinEntry."POS Payment Line No." := POSEntryPaymentLine."Line No.";
        POSBinEntry."Created At" := CurrentDateTime();

        POSBinEntry.Type := POSBinEntry.Type::INPAYMENT;
        if (POSEntryPaymentLine.Amount < 0) then
            POSBinEntry.Type := POSBinEntry.Type::OUTPAYMENT;

        POSBinEntry."Payment Bin No." := POSEntryPaymentLine."POS Payment Bin Code";
        POSBinEntry."Payment Method Code" := POSEntryPaymentLine."POS Payment Method Code";

        POSBinEntry."POS Store Code" := POSEntryPaymentLine."POS Store Code";
        POSBinEntry."POS Unit No." := POSEntryPaymentLine."POS Unit No.";

        POSBinEntry."Transaction Date" := Today();
        POSBinEntry."Transaction Time" := Time;
        POSBinEntry."Transaction Amount" := POSEntryPaymentLine.Amount;
        POSBinEntry."Transaction Currency Code" := POSEntryPaymentLine."Currency Code";
        POSBinEntry."Transaction Amount (LCY)" := POSEntryPaymentLine."Amount (LCY)";

        //- Legacy
        POSBinEntry."Payment Type Code" := POSEntryPaymentLine."POS Payment Method Code";
        POSBinEntry."Register No." := POSEntryPaymentLine."POS Unit No.";
        //+ Legacy

        POSBinEntry.Insert();
    end;

    local procedure CalculateTransactionAmountLCY(var POSBinEntry: Record "NPR POS Bin Entry")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        CurrExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
    begin

        POSBinEntry."Transaction Amount (LCY)" := POSBinEntry."Transaction Amount";

        if POSBinEntry."Transaction Amount" = 0 then
            exit;

        if POSBinEntry."Transaction Currency Code" = '' then
            exit;

        if not POSPaymentMethod.Get(POSBinEntry."Payment Type Code") then
            exit;

        if POSPaymentMethod."Use Stand. Exc. Rate for Bal." then begin
            Currency.Get(POSBinEntry."Transaction Currency Code");
            POSBinEntry."Transaction Amount (LCY)" := CurrExchRate.ExchangeAmtFCYToLCY(POSBinEntry."Transaction Date", POSBinEntry."Transaction Currency Code", POSBinEntry."Transaction Amount",
                                                       1 / CurrExchRate.ExchangeRate(POSBinEntry."Transaction Date", POSBinEntry."Transaction Currency Code"));
            if Currency."Amount Rounding Precision" <> 0 then
                POSBinEntry."Transaction Amount (LCY)" := Round(POSBinEntry."Transaction Amount (LCY)", Currency."Amount Rounding Precision", Currency.InvoiceRoundingDirection());
        end else begin
            if POSPaymentMethod."Fixed Rate" <> 0 then
                POSBinEntry."Transaction Amount (LCY)" := POSBinEntry."Transaction Amount" * POSPaymentMethod."Fixed Rate" / 100;
            if POSPaymentMethod."Rounding Precision" <> 0 then
                POSBinEntry."Transaction Amount (LCY)" := Round(POSBinEntry."Transaction Amount (LCY)", POSPaymentMethod."Rounding Precision", POSPaymentMethod.GetRoundingType());
        end;
    end;

    local procedure GetPOSPeriodRegister(var SalePOS: Record "NPR POS Sale"; var POSPeriodRegister: Record "NPR POS Period Register"; CheckOpen: Boolean): Boolean
    begin
        exit(GetPOSPeriodRegisterForPOSUnit(SalePOS."Register No.", POSPeriodRegister, CheckOpen));
    end;

    local procedure GetPOSPeriodRegisterForPOSUnit(POSUnitNo: Code[10]; var POSPeriodRegister: Record "NPR POS Period Register"; CheckOpen: Boolean): Boolean
    begin
        POSPeriodRegister.Reset();
        POSPeriodRegister.SetCurrentKey("POS Unit No.");
        POSPeriodRegister.SetRange("POS Unit No.", POSUnitNo);
        if not POSPeriodRegister.FindLast() then
            exit(false);
        if CheckOpen then
            if POSPeriodRegister.Status <> POSPeriodRegister.Status::OPEN then
                exit(false);
        exit(true);
    end;

    internal procedure CreateBalancingEntryAndLines(var SalePOS: Record "NPR POS Sale"; IntermediateEndOfDay: Boolean; WorkshiftEntryNo: Integer) EntryNo: Integer
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSEntry: Record "NPR POS Entry";
        LineNo: Integer;
        PaymentBinCheckpointUpdate: Record "NPR POS Payment Bin Checkp.";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        BinTransferPost: Codeunit "NPR BinTransferPost";
        SalespersonPurchaserLbl: Label '%1: %2', Locked = true;
        PaymentBinCheckpointQuery: Query "NPR WorkshiftPaymentCheckpoint";
    begin

        PaymentBinCheckpointQuery.SetFilter(WorkshiftCheckpointEntryNo, '=%1', WorkshiftEntryNo);
        PaymentBinCheckpointQuery.SetFilter(Status, '=%1', PaymentBinCheckpoint.Status::WIP);
        PaymentBinCheckpointQuery.SetFilter(IncludeInCounting, '<>%1', PaymentBinCheckpoint."Include In Counting"::NO);
        PaymentBinCheckpointQuery.Open();
        if (PaymentBinCheckpointQuery.Read()) then
            exit(0); // Still work to do before counting is completed

        PaymentBinCheckpointQuery.Close();
        PaymentBinCheckpointQuery.SetFilter(Status, '=%1', PaymentBinCheckpoint.Status::READY);
        PaymentBinCheckpointQuery.Open();
        if (not PaymentBinCheckpointQuery.Read()) then
            exit(0); // Nothing is ready to post

        GetPOSPeriodRegister(SalePOS, POSPeriodRegister, false);

        POSEntry.Init();

        POSWorkshiftCheckpoint.Get(WorkshiftEntryNo);
        case POSWorkshiftCheckpoint.Type of
            POSWorkshiftCheckpoint.Type::XREPORT:
                begin
                    InsertPOSEntry(POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::Other);
                    POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
                    POSEntry."System Entry" := true;
                    IntermediateEndOfDay := true;
                    POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
                    POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
                    POSEntry.Description := '[System Event] Intermediate End of Day.';
                end;

            POSWorkshiftCheckpoint.Type::ZREPORT:
                begin
                    InsertPOSEntry(POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::Balancing);
                    if (not SalespersonPurchaser.Get(SalePOS."Salesperson Code")) then
                        SalespersonPurchaser.Name := StrSubstNo(SalespersonPurchaserLbl, SalespersonPurchaser.TableCaption, SalePOS."Salesperson Code");
                    POSEntry.Description := SalespersonPurchaser.Name;
                end;

            POSWorkshiftCheckpoint.Type::TRANSFER:
                begin
                    InsertPOSEntry(POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::Other);
                    POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
                    POSEntry.Description := 'Bin Transfer';
                    POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
                    IntermediateEndOfDay := true;
                end;

            else
                exit;
        end;

        POSEntry.Modify();

        POSWorkshiftCheckpoint.Get(WorkshiftEntryNo);
        POSWorkshiftCheckpoint.Open := IntermediateEndOfDay;
        POSWorkshiftCheckpoint."POS Entry No." := POSEntry."Entry No.";
        POSWorkshiftCheckpoint.Modify();

        if (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT) then begin
            POSWorkshiftCheckpoint.Reset();
            POSWorkshiftCheckpoint.SetCurrentKey("Consolidated With Entry No.");
            POSWorkshiftCheckpoint.SetFilter("Consolidated With Entry No.", '=%1', WorkshiftEntryNo);
            if (POSWorkshiftCheckpoint.FindSet()) then begin
                repeat
                    POSWorkshiftCheckpoint.Open := false;
                    POSWorkshiftCheckpoint.Modify();
                until (POSWorkshiftCheckpoint.Next() = 0);
            end;
        end;

        LineNo := 10000;
        repeat
            InsertPOSBalancingLine(PaymentBinCheckpointQuery.EntryNo, POSEntry, LineNo, (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::TRANSFER));
            LineNo += 10000;
            PaymentBinCheckpointUpdate.Get(PaymentBinCheckpointQuery.EntryNo);
            PaymentBinCheckpointUpdate.Status := PaymentBinCheckpointUpdate.Status::TRANSFERED;
            PaymentBinCheckpointUpdate.Modify();

            BinTransferPost.MoveBinTransferJnlToPostedEntries(PaymentBinCheckpointUpdate."Bin Transfer Journal Entry No.", POSEntry."Document No.");
            BinTransferPost.MoveBinTransferJnlToPostedEntries(PaymentBinCheckpointUpdate."Bin Transf. Jnl. Entry (Bank)", POSEntry."Document No.");
        until (not PaymentBinCheckpointQuery.Read());

        exit(POSEntry."Entry No.");
    end;

    local procedure CreateRMAEntry(POSEntry: Record "NPR POS Entry"; SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        PosRmaLine: Record "NPR POS RMA Line";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        RMAEntryLbl: Label '%1|%2|%3', Locked = true;
    begin
        if (SaleLinePOS."Return Sale Sales Ticket No." = '') then
            exit;

        if (SaleLinePOS.Quantity >= 0) then
            exit;

        if (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item) then
            exit;

        // Only referenced return sales
        PosRmaLine."Entry No." := 0;
        PosRmaLine."POS Entry No." := POSEntry."Entry No.";

        PosRmaLine."Sales Ticket No." := SaleLinePOS."Return Sale Sales Ticket No.";
        PosRmaLine."Return Ticket No." := SaleLinePOS."Sales Ticket No.";
        PosRmaLine."Return Line No." := SaleLinePOS."Line No.";

        PosRmaLine."Returned Item No." := SaleLinePOS."No.";
        PosRmaLine."Returned Quantity" := SaleLinePOS.Quantity;

        PosRmaLine."Return Reason Code" := SaleLinePOS."Return Reason Code";
        PosRmaLine.Insert();

        OnAfterInsertRmaEntry(PosRmaLine, POSEntry, SalePOS, SaleLinePOS);

        POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId(), POSAuditLog."Action Type"::ITEM_RMA, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", '',
          StrSubstNo(RMAEntryLbl, PosRmaLine."Return Line No.", PosRmaLine."Sales Ticket No.", PosRmaLine."Return Reason Code"));

    end;

    local procedure GetStoreNoForUnitNo(POSUnitNo: Code[10]): Code[10]
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSUnit.Get(POSUnitNo)) then
            exit(POSUnit."POS Store Code");
    end;

    local procedure GetResponsibilityCenterForStoreCode(POSStoreCode: Code[10]): Code[10]
    var
        POSStore: Record "NPR POS Store";
    begin
        if POSStore.Get(POSStoreCode) then
            exit(POSStore."Responsibility Center");
    end;


    local procedure SelectUnitBin(UnitNo: Code[10]): Code[10]
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(UnitNo);

        exit(POSUnit."Default POS Payment Bin");
    end;

    procedure IsCancelledSale(SalePOS: Record "NPR POS Sale"): Boolean
    begin
        exit(SalePOS."Header Type" = SalePOS."Header Type"::Cancelled);
    end;

    local procedure IsUniqueDocumentNo(SalePOS: Record "NPR POS Sale"): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        exit(POSEntry.IsEmpty());
    end;

    local procedure ValidateSaleHeader(SalePOS: Record "NPR POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        SalePOS.TestField("Sales Ticket No.");
        if not IsUniqueDocumentNo(SalePOS) then
            Error(ERR_DOCUMENT_NO_CLASH, POSEntry.FieldCaption("Document No."), SalePOS."Sales Ticket No.", POSEntry.TableCaption);
    end;

    local procedure FiscalNoCheck(var POSEntry: Record "NPR POS Entry"; SalePOS: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin

        POSUnit.Get(POSEntry."POS Unit No.");
        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then begin
            FillFiscalNo(POSEntry, '', SalePOS.Date);
            exit;
        end;

        case POSEntry."Entry Type" of
            POSEntry."Entry Type"::"Direct Sale":
                FillFiscalNo(POSEntry, POSAuditProfile."Sale Fiscal No. Series", SalePOS.Date);

            POSEntry."Entry Type"::"Cancelled Sale":
                if POSAuditProfile."Fill Sale Fiscal No. On" = POSAuditProfile."Fill Sale Fiscal No. On"::All then
                    FillFiscalNo(POSEntry, POSAuditProfile."Sale Fiscal No. Series", SalePOS.Date);

            POSEntry."Entry Type"::"Credit Sale":
                FillFiscalNo(POSEntry, POSAuditProfile."Credit Sale Fiscal No. Series", SalePOS.Date);

            POSEntry."Entry Type"::Balancing:
                FillFiscalNo(POSEntry, POSAuditProfile."Balancing Fiscal No. Series", SalePOS.Date);
        end;

    end;

    local procedure FillFiscalNo(var POSEntry: Record "NPR POS Entry"; NoSeriesCode: Code[20]; NoSeriesDate: Date)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
    begin

        if NoSeriesCode = '' then begin
            POSEntry."Fiscal No." := POSEntry."Document No.";

            POSUnit.Get(POSEntry."POS Unit No.");
            POSUnit.TestField("POS Audit Profile");
            POSAuditProfile.Get(POSUnit."POS Audit Profile");
            POSEntry."Fiscal No. Series" := POSAuditProfile."Sales Ticket No. Series";

        end else begin
            POSEntry."Fiscal No." := NoSeriesManagement.GetNextNo(NoSeriesCode, NoSeriesDate, true);
            POSEntry."Fiscal No. Series" := NoSeriesCode;
        end;

    end;

    local procedure SetPostedSalesDocInfo(var POSEntry: Record "NPR POS Entry"; var SalesHeader: Record "Sales Header")
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
            if POSEntry.Description = '' then
                POSEntry.Description := StrSubstNo(POSEntryDescLbl, POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
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

        if POSEntry.Description = '' then
            POSEntry.Description := StrSubstNo(POSEntryDescLbl, POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);

    end;

    internal procedure ExcludeFromPosting(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    begin
        exit(SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Comment]);
    end;

    internal procedure ReadyToBePosted(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(SalesHeader.Ship or SalesHeader.Invoice or SalesHeader.Receive);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePOSEntry(var SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSEntry(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSEntryFromExternalPOSSale(var ExtSalePOS: Record "NPR External POS Sale"; var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSEntryFromExternalPOSSale(var ExtSalePOS: Record "NPR External POS Sale"; var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSSalesLineFromExternalPOSSale(ExtSalePOS: Record "NPR External POS Sale"; ExtSaleLinePOS: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSSalesLineFromExternalPOSSale(ExtSalePOS: Record "NPR External POS Sale"; ExtSaleLinePOS: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSPaymentLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSPaymentLine: Record "NPR POS Entry Payment Line")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSPaymentLineFromExternalPOSSale(ExtSalePOS: Record "NPR External POS Sale"; SaleLinePOS: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSPaymentLine: Record "NPR POS Entry Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSPaymentLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; POSPaymentLine: Record "NPR POS Entry Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSPaymentLineFromExternalPOSSale(ExtSalePOS: Record "NPR External POS Sale"; SaleLinePOS: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry"; POSPaymentLine: Record "NPR POS Entry Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSBalanceLine(POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp."; POSEntry: Record "NPR POS Entry"; var POSBalancingLine: Record "NPR POS Balancing Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRmaEntry(POSRMALine: Record "NPR POS RMA Line"; POSEntry: Record "NPR POS Entry"; SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertRmaEntryFromExternalPOSSale(POSRMALine: Record "NPR POS RMA Line"; POSEntry: Record "NPR POS Entry"; ExtSalePOS: Record "NPR External POS Sale"; ExtSaleLinePOS: Record "NPR External POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePOSEntryFromExternalPOSSale(var ExtSalePOS: Record "NPR External POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertBinDifference(var POSBinEntry: Record "NPR POS Bin Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertBinDifference(var POSBinEntry: Record "NPR POS Bin Entry")
    begin
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', true, true)]
    local procedure OnNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        POSEntry: Record "NPR POS Entry";
        POSPeriodRegister: Record "NPR POS Period Register";
        RecordCount: Integer;
    begin
        if (POSEntry.ReadPermission) then begin
            if not (POSEntry.SetCurrentKey(POSEntry."Document No.")) then;
            POSEntry.Reset();
            POSEntry.SetFilter("Document No.", DocNoFilter);
            POSEntry.SetFilter("Posting Date", PostingDateFilter);
            RecordCount := InsertIntoDocEntry(DocumentEntry, Database::"NPR POS Entry", 0, CopyStr(DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count());

            if (RecordCount = 0) then begin
                if not (POSEntry.SetCurrentKey(POSEntry."Fiscal No.")) then;
                POSEntry.Reset();
                POSEntry.SetFilter("Fiscal No.", DocNoFilter);
                POSEntry.SetFilter("Posting Date", PostingDateFilter);
                RecordCount := InsertIntoDocEntry(DocumentEntry, Database::"NPR POS Entry", 1, CopyStr(DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count());
            end;

            if (RecordCount = 0) then begin
                POSPeriodRegister.SetFilter("Document No.", DocNoFilter);
                if (POSPeriodRegister.FindFirst()) then begin
                    POSEntry.Reset();
                    POSEntry.SetCurrentKey("POS Period Register No.");
                    POSEntry.SetFilter("POS Period Register No.", '=%1', POSPeriodRegister."No.");
                    POSEntry.SetFilter("System Entry", '=%1', false);
                    RecordCount := InsertIntoDocEntry(DocumentEntry, Database::"NPR POS Entry", 2, CopyStr(DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count());
                end;
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', true, true)]
    local procedure OnNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        POSPeriodRegister: Record "NPR POS Period Register";
        TempDocumentEntry: Record "Document Entry" temporary;
    begin

        if (TableID = Database::"NPR POS Entry") then begin

            OnNavigateFindRecords(TempDocumentEntry, DocNoFilter, PostingDateFilter);

#if BC17 
            if (TempDocumentEntry."Document Type" = 0) then begin
#else
            if (TempDocumentEntry."Document Type".AsInteger() = 0) then begin
#endif
                if not (POSEntry.SetCurrentKey(POSEntry."Document No.")) then;
                POSEntry.SetFilter("Document No.", TempDocumentEntry."Document No.");
            end;

#if BC17 
            if (TempDocumentEntry."Document Type" = 1) then begin
#else
            if (TempDocumentEntry."Document Type".AsInteger() = 1) then begin
#endif
                POSEntry.SetCurrentKey("Fiscal No.");
                POSEntry.SetFilter("Fiscal No.", TempDocumentEntry."Document No.");
            end;

#if BC17 
            if (TempDocumentEntry."Document Type" = 2) then begin
#else
            if (TempDocumentEntry."Document Type".AsInteger() = 2) then begin
#endif
                POSPeriodRegister.SetFilter("Document No.", TempDocumentEntry."Document No.");
                if (POSPeriodRegister.FindFirst()) then begin
                    POSEntry.SetFilter("POS Period Register No.", '=%1', POSPeriodRegister."No.");
                    POSEntry.SetFilter("System Entry", '=%1', false);
                end;
            end;

            if (TempDocumentEntry."No. of Records" = 1) then
                Page.Run(Page::"NPR POS Entry List", POSEntry)
            else
                Page.Run(0, POSEntry);

        end;
    end;

    local procedure InsertIntoDocEntry(var DocumentEntry: Record "Document Entry" temporary; DocTableID: Integer; DocType: Integer; DocNoFilter: Code[20]; DocTableName: Text; DocNoOfRecords: Integer): Integer
    begin
        if (DocNoOfRecords = 0) then
            exit(DocNoOfRecords);

        DocumentEntry.Init();
        DocumentEntry."Entry No." := DocumentEntry."Entry No." + 1;
        DocumentEntry."Table ID" := DocTableID;
#if BC17         
        DocumentEntry."Document Type" := DocType;
#else        
        DocumentEntry."Document Type" := "Document Entry Document Type".FromInteger(DocType);
#endif
        DocumentEntry."Document No." := DocNoFilter;
        DocumentEntry."Table Name" := CopyStr(DocTableName, 1, MaxStrLen(DocumentEntry."Table Name"));
        DocumentEntry."No. of Records" := DocNoOfRecords;
        DocumentEntry.Insert();

        exit(DocNoOfRecords);
    end;

    local procedure InsertPOSTaxAmount(SystemId: Guid; POSEntry: Record "NPR POS Entry")
    var
        POSEntryTaxCalc: Codeunit "NPR POS Entry Tax Calc.";
    begin
        POSEntryTaxCalc.PostPOSTaxAmountCalculation(POSEntry."Entry No.", SystemId);
    end;

    local procedure InsertPOSTaxAmountReverseSign(SystemId: Guid; POSEntry: Record "NPR POS Entry")
    var
        POSEntryTaxCalc: Codeunit "NPR POS Entry Tax Calc.";
    begin
        POSEntryTaxCalc.PostPOSTaxAmountCalculationReverseSign(POSEntry."Entry No.", SystemId);
    end;

    internal procedure GetCreatedPOSEntry(var POSEntryOut: Record "NPR POS Entry")
    begin
        POSEntryOut := GlobalPOSEntry;
    end;
    #region External POS Sale
    internal procedure CreatePOSEntryFromExternalPOSSale(var ExtPOSSale: Record "NPR External POS Sale")
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        POSAuditLog: Record "NPR POS Audit Log";
        POSUnit: Record "NPR POS Unit";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSUnitManager: Codeunit "NPR POS Manage POS Unit";
        ExtSaleCancelled: Boolean;
        WasModified: Boolean;
    begin
        Clear(GlobalPOSEntry);
        ValidateSaleHeaderExt(ExtPOSSale);

        OnBeforeCreatePOSEntryFromExternalPOSSale(ExtPOSSale);

        if not GetPOSPeriodRegisterExt(ExtPOSSale, POSPeriodRegister, true) then begin
            POSUnit.Get(ExtPOSSale."Register No.");
            POSUnitManager.OpenPOSUnit(POSUnit);
        end;

        ExtSaleCancelled := IsCancelledSaleExt(ExtPOSSale);

        if ExtSaleCancelled then begin
            InsertPOSEntryExt(POSPeriodRegister, ExtPOSSale, POSEntry, POSEntry."Entry Type"::"Cancelled Sale");
            POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
            POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        end else begin
            InsertPOSEntryExt(POSPeriodRegister, ExtPOSSale, POSEntry, POSEntry."Entry Type"::"Direct Sale");
        end;

        CreateLinesExt(POSEntry, ExtPOSSale);

        POSEntryManagement.RecalculatePOSEntry(POSEntry, WasModified);
        POSEntry.Modify();

        if ExtSaleCancelled then begin
            POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::CANCEL_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_CANCEL_SALE_END, '')
        end else begin
            POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::GRANDTOTAL, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
            POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::DIRECT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_DIRECT_SALE_END, '');
        end;

        OnAfterInsertPOSEntryFromExternalPOSSale(ExtPOSSale, POSEntry);
        GlobalPOSEntry := POSEntry;

        ExtPOSSale."Converted To POS Entry" := true;
        ExtPOSSale."POS Entry System Id" := POSEntry.SystemId;
        ExtPOSSale."Has Conversion Error" := false;
        ExtPOSSale."Last Conversion Error Message" := '';
        ExtPOSSale.Modify();
    end;

    local procedure IsUniqueDocumentNoExt(ExtSalePOS: Record "NPR External POS Sale"): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Document No.", ExtSalePOS."Sales Ticket No.");
        exit(POSEntry.IsEmpty());
    end;

    local procedure ValidateSaleHeaderExt(ExtSalePOS: Record "NPR External POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
    begin
        ExtSalePOS.TestField("Sales Ticket No.");
        ExtSalePOS.TestField("POS Store Code");
        ExtSalePOS.TestField("Register No.");
        if not IsUniqueDocumentNoExt(ExtSalePOS) then
            Error(ERR_DOCUMENT_NO_CLASH, POSEntry.FieldCaption("Document No."), ExtSalePOS."Sales Ticket No.", POSEntry.TableCaption);
    end;

    local procedure GetPOSPeriodRegisterExt(var ExtSalePOS: Record "NPR External POS Sale"; var POSPeriodRegister: Record "NPR POS Period Register"; CheckOpen: Boolean): Boolean
    begin
        exit(GetPOSPeriodRegisterForPOSUnit(ExtSalePOS."Register No.", POSPeriodRegister, CheckOpen));
    end;

    local procedure IsCancelledSaleExt(ExtSalePOS: Record "NPR External POS Sale"): Boolean
    begin
        exit(ExtSalePOS."Header Type" = ExtSalePOS."Header Type"::Cancelled);
    end;

    local procedure InsertPOSEntryExt(var POSPeriodRegister: Record "NPR POS Period Register"; var ExtSalePOS: Record "NPR External POS Sale"; var POSEntry: Record "NPR POS Entry"; EntryType: Option)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalespersonLbl: Label '%1: %2', Locked = true;
    begin
        POSEntry.Init();
        POSEntry."Entry No." := 0; //Autoincrement;
        POSEntry."POS Period Register No." := POSPeriodRegister."No.";
        POSEntry."POS Store Code" := ExtSalePOS."POS Store Code";
        POSEntry."POS Unit No." := ExtSalePOS."Register No.";
        POSEntry."Document No." := ExtSalePOS."Sales Ticket No.";
        POSEntry."Entry Date" := ExtSalePOS.Date;
        POSEntry."Entry Type" := EntryType;

        FiscalNoCheckExt(POSEntry, ExtSalePOS);

        POSEntry."Salesperson Code" := ExtSalePOS."Salesperson Code";
        POSEntry."Customer No." := ExtSalePOS."Customer No.";

        POSEntry."Event No." := ExtSalePOS."Event No.";
        POSEntry."Shortcut Dimension 1 Code" := ExtSalePOS."Shortcut Dimension 1 Code";
        POSEntry."Shortcut Dimension 2 Code" := ExtSalePOS."Shortcut Dimension 2 Code";
        POSEntry."Dimension Set ID" := ExtSalePOS."Dimension Set ID";
        POSEntry.SystemId := ExtSalePOS.SystemId;
        POSEntry."Starting Time" := ExtSalePOS."Start Time";
        POSEntry."Ending Time" := Time;
        POSEntry."Posting Date" := ExtSalePOS.Date;
        POSEntry."Document Date" := ExtSalePOS.Date;
        POSEntry."Currency Code" := '';//All sales are in LCY for now (Payments can  be in FCY of course)
        POSEntry."Country/Region Code" := ExtSalePOS."Country Code";
        POSEntry."Tax Area Code" := ExtSalePOS."Tax Area Code";
        POSEntry."Prices Including VAT" := ExtSalePOS."Prices Including VAT";
        POSEntry."External Document No." := ExtSalePOS."External Document No.";
        POSEntry."Sales Channel" := ExtSalePOS."Sales Channel";

        OnBeforeInsertPOSEntryFromExternalPOSSale(ExtSalePOS, POSEntry);

        if POSEntry.Description = '' then begin
            case POSEntry."Entry Type" of
                POSEntry."Entry Type"::"Direct Sale":
                    POSEntry.Description := CopyStr(StrSubstNo(TXT_SALES_TICKET, POSEntry."Document No."), 1, MaxStrLen(POSEntry.Description));
                POSEntry."Entry Type"::Balancing:
                    begin
                        if (not SalespersonPurchaser.Get(ExtSalePOS."Salesperson Code")) then
                            SalespersonPurchaser.Name := StrSubstNo(SalespersonLbl, SalespersonPurchaser.TableCaption, ExtSalePOS."Salesperson Code");
                        POSEntry.Description := SalespersonPurchaser.Name;
                    end;

                POSEntry."Entry Type"::"Cancelled Sale":
                    begin
                        SaleLinePOS.SetRange("Register No.", ExtSalePOS."Register No.");
                        SaleLinePOS.SetRange("Sales Ticket No.", ExtSalePOS."Sales Ticket No.");
                        if SaleLinePOS.FindFirst() and (SaleLinePOS.Description <> '') then
                            POSEntry.Description := SaleLinePOS.Description
                        else
                            POSEntry.Description := CANCEL_SALE;
                    end;
            end;
        end;

        POSEntry.Insert(false, true);
    end;

    local procedure FiscalNoCheckExt(var POSEntry: Record "NPR POS Entry"; ExtSalePOS: Record "NPR External POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin

        POSUnit.Get(POSEntry."POS Unit No.");
        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then begin
            FillFiscalNo(POSEntry, '', ExtSalePOS.Date);
            exit;
        end;

        case POSEntry."Entry Type" of
            POSEntry."Entry Type"::"Direct Sale":
                FillFiscalNo(POSEntry, POSAuditProfile."Sale Fiscal No. Series", ExtSalePOS.Date);

            POSEntry."Entry Type"::"Cancelled Sale":
                if POSAuditProfile."Fill Sale Fiscal No. On" = POSAuditProfile."Fill Sale Fiscal No. On"::All then
                    FillFiscalNo(POSEntry, POSAuditProfile."Sale Fiscal No. Series", ExtSalePOS.Date);

            POSEntry."Entry Type"::"Credit Sale":
                FillFiscalNo(POSEntry, POSAuditProfile."Credit Sale Fiscal No. Series", ExtSalePOS.Date);

            POSEntry."Entry Type"::Balancing:
                FillFiscalNo(POSEntry, POSAuditProfile."Balancing Fiscal No. Series", ExtSalePOS.Date);
        end;

    end;

    local procedure CreateLinesExt(var POSEntry: Record "NPR POS Entry"; var ExtSalePOS: Record "NPR External POS Sale")
    var
        ExtSaleLinePOS: Record "NPR External POS Sale Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
    begin
        ExtSaleLinePOS.SetRange("External POS Sale Entry No.", ExtSalePOS."Entry No.");
        if ExtSaleLinePOS.FindSet() then begin
            repeat
                case ExtSaleLinePOS."Line Type" of
                    ExtSaleLinePOS."Line Type"::Item,
                    ExtSaleLinePOS."Line Type"::"Item Category",
                    ExtSaleLinePOS."Line Type"::"BOM List",
                    ExtSaleLinePOS."Line Type"::"Customer Deposit",
                    ExtSaleLinePOS."Line Type"::"Issue Voucher":
                        begin
                            InsertPOSSaleLineExt(ExtSalePOS, ExtSaleLinePOS, POSEntry, false, POSSalesLine);
                            InsertPOSTaxAmountExt(POSEntryTaxLine, ExtSaleLinePOS, POSEntry)
                        end;
                    ExtSaleLinePOS."Line Type"::Rounding:
                        begin
                            InsertPOSSaleLineExt(ExtSalePOS, ExtSaleLinePOS, POSEntry, false, POSSalesLine);
                        end;
                    ExtSaleLinePOS."Line Type"::"GL Payment":
                        begin
                            InsertPOSSaleLineExt(ExtSalePOS, ExtSaleLinePOS, POSEntry, true, POSSalesLine);
                        end;
                    ExtSaleLinePOS."Line Type"::"POS Payment":
                        InsertPOSPaymentLineExt(ExtSalePOS, ExtSaleLinePOS, POSEntry, POSPaymentLine);
                    ExtSaleLinePOS."Line Type"::Comment:
                        InsertPOSSaleLineExt(ExtSalePOS, ExtSaleLinePOS, POSEntry, false, POSSalesLine);
                end;
            until ExtSaleLinePOS.Next() = 0;
        end;
    end;

    local procedure InsertPOSTaxAmountExt(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; ExtPOSSaleLine: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry")
    var
        POSEntryTaxCalcExt: Codeunit "NPR External POS Tax Calc";
    begin
        POSEntryTaxCalcExt.PostExternalPOSSalesLineTaxAmount(POSEntryTaxLine, ExtPOSSaleLine, POSEntry);
    end;

    local procedure InsertPOSSaleLineExt(ExtSalePOS: Record "NPR External POS Sale"; ExtSaleLinePOS: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry"; ReverseSign: Boolean; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        PricesIncludeTax: Boolean;
    begin
        POSSalesLine.Init();
        POSSalesLine."POS Entry No." := POSEntry."Entry No.";
        POSSalesLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSSalesLine."Line No." := ExtSaleLinePOS."Line No.";
        POSSalesLine.SetRecFilter();
        if not POSSalesLine.IsEmpty() then
            repeat
                POSSalesLine."Line No." := POSSalesLine."Line No." + 10000;
                POSSalesLine.SetRecFilter();
            until POSSalesLine.IsEmpty();

        POSSalesLine.Reset();

        POSSalesLine."POS Store Code" := ExtSalePOS."POS Store Code";
        POSSalesLine."POS Unit No." := ExtSaleLinePOS."Register No.";
        POSSalesLine."Document No." := ExtSaleLinePOS."Sales Ticket No.";
        POSSalesLine."Customer No." := ExtSalePOS."Customer No.";
        POSSalesLine."Salesperson Code" := ExtSalePOS."Salesperson Code";

        case ExtSaleLinePOS."Line Type" of
            ExtSaleLinePOS."Line Type"::Item:
                POSSalesLine.Type := POSSalesLine.Type::Item;
            ExtSaleLinePOS."Line Type"::"Customer Deposit":
                POSSalesLine.Type := POSSalesLine.Type::Customer;
            ExtSaleLinePOS."Line Type"::Rounding:
                POSSalesLine.Type := POSSalesLine.Type::Rounding;
            ExtSaleLinePOS."Line Type"::"GL Payment":
                begin
                    if ExtSaleLinePOS."Gen. Posting Type" <> ExtSaleLinePOS."Gen. Posting Type"::Purchase then
                        POSSalesLine.Type := POSSalesLine.Type::"G/L Account"
                    else
                        POSSalesLine.Type := POSSalesLine.Type::Payout;
                end;
        end;


        POSSalesLine."Exclude from Posting" := ExcludeFromPostingExt(ExtSaleLinePOS);
        POSSalesLine."No." := ExtSaleLinePOS."No.";
        POSSalesLine."Variant Code" := ExtSaleLinePOS."Variant Code";
        POSSalesLine."Location Code" := ExtSaleLinePOS."Location Code";
        POSSalesLine."Posting Group" := ExtSaleLinePOS."Posting Group";
        POSSalesLine.Description := ExtSaleLinePOS.Description;

        POSSalesLine."Gen. Posting Type" := ExtSaleLinePOS."Gen. Posting Type";
        POSSalesLine."Gen. Bus. Posting Group" := ExtSaleLinePOS."Gen. Bus. Posting Group";
        POSSalesLine."VAT Bus. Posting Group" := ExtSaleLinePOS."VAT Bus. Posting Group";
        POSSalesLine."Gen. Prod. Posting Group" := ExtSaleLinePOS."Gen. Prod. Posting Group";
        POSSalesLine."VAT Prod. Posting Group" := ExtSaleLinePOS."VAT Prod. Posting Group";
        POSSalesLine."Tax Area Code" := ExtSaleLinePOS."Tax Area Code";
        POSSalesLine."Tax Liable" := ExtSaleLinePOS."Tax Liable";
        POSSalesLine."Tax Group Code" := ExtSaleLinePOS."Tax Group Code";
        POSSalesLine."Use Tax" := ExtSaleLinePOS."Use Tax";

        POSSalesLine."Unit of Measure Code" := ExtSaleLinePOS."Unit of Measure Code";
        POSSalesLine.Quantity := ExtSaleLinePOS.Quantity;
        POSSalesLine."Quantity (Base)" := ExtSaleLinePOS."Quantity (Base)";
        POSSalesLine."Qty. per Unit of Measure" := ExtSaleLinePOS."Qty. per Unit of Measure";
        POSSalesLine."Unit Price" := ExtSaleLinePOS."Unit Price";
        POSSalesLine."Unit Cost (LCY)" := ExtSaleLinePOS."Unit Cost (LCY)";
        POSSalesLine."Unit Cost" := ExtSaleLinePOS."Unit Cost";
        POSSalesLine."VAT %" := ExtSaleLinePOS."VAT %";
        POSSalesLine."VAT Identifier" := ExtSaleLinePOS."VAT Identifier";
        POSSalesLine."VAT Calculation Type" := ExtSaleLinePOS."VAT Calculation Type";

        POSSalesLine."Discount Type" := ExtSaleLinePOS."Discount Type";
        POSSalesLine."Discount Authorised by" := ExtSalePOS."User ID";

        POSSalesLine."Reason Code" := ExtSaleLinePOS."Reason Code";
        POSSalesLine."Line Discount %" := ExtSaleLinePOS."Discount %";

        PricesIncludeTax := ExtSalePOS."Prices Including VAT";
        if PricesIncludeTax then begin
            POSSalesLine."Line Discount Amount Incl. VAT" := ExtSaleLinePOS."Discount Amount";
            POSSalesLine."Line Discount Amount Excl. VAT" := ExtSaleLinePOS."Discount Amount" / (1 + (ExtSaleLinePOS."VAT %" / 100));
        end else begin
            POSSalesLine."Line Discount Amount Excl. VAT" := ExtSaleLinePOS."Discount Amount";
            POSSalesLine."Line Discount Amount Incl. VAT" := (1 + (ExtSaleLinePOS."VAT %" / 100)) * ExtSaleLinePOS."Discount Amount";
        end;

        POSSalesLine."Amount Excl. VAT" := ExtSaleLinePOS.Amount;
        POSSalesLine."Amount Incl. VAT" := ExtSaleLinePOS."Amount Including VAT";
        POSSalesLine."VAT Base Amount" := ExtSaleLinePOS."VAT Base Amount";
        POSSalesLine."Line Amount" := ExtSaleLinePOS."Line Amount";

        if ExtSaleLinePOS."Line Type" = ExtSaleLinePOS."Line Type"::"GL Payment" then
            POSSalesLine."Line Amount" *= -1;

        POSSalesLine."Amount Excl. VAT (LCY)" := ExtSaleLinePOS.Amount * POSEntry."Currency Factor";
        POSSalesLine."Amount Incl. VAT (LCY)" := ExtSaleLinePOS."Amount Including VAT" * POSEntry."Currency Factor";

        POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := POSSalesLine."Line Discount Amount Excl. VAT" * POSEntry."Currency Factor";
        POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := POSSalesLine."Line Discount Amount Incl. VAT" * POSEntry."Currency Factor";

        POSSalesLine.SystemId := ExtSaleLinePOS.SystemId;

        POSSalesLine."Item Category Code" := ExtSaleLinePOS."Item Category Code";

        POSSalesLine."Serial No." := ExtSaleLinePOS."Serial No.";
        POSSalesLine."Return Reason Code" := ExtSaleLinePOS."Return Reason Code";

        CreateRMAEntryExt(POSEntry, ExtSalePOS, ExtSaleLinePOS);

        POSSalesLine."Shortcut Dimension 1 Code" := ExtSaleLinePOS."Shortcut Dimension 1 Code";
        POSSalesLine."Shortcut Dimension 2 Code" := ExtSaleLinePOS."Shortcut Dimension 2 Code";
        POSSalesLine."Dimension Set ID" := ExtSaleLinePOS."Dimension Set ID";
        if ReverseSign then begin
            POSSalesLine.Quantity := -POSSalesLine.Quantity;
            POSSalesLine."Line Discount Amount Excl. VAT" := -POSSalesLine."Line Discount Amount Excl. VAT";
            POSSalesLine."Line Discount Amount Incl. VAT" := -POSSalesLine."Line Discount Amount Incl. VAT";
            POSSalesLine."Amount Excl. VAT" := -POSSalesLine."Amount Excl. VAT";
            POSSalesLine."Amount Incl. VAT" := -POSSalesLine."Amount Incl. VAT";
            POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := -POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)";
            POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := -POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)";

            POSSalesLine."Amount Excl. VAT (LCY)" := -POSSalesLine."Amount Excl. VAT (LCY)";
            POSSalesLine."Amount Incl. VAT (LCY)" := -POSSalesLine."Amount Incl. VAT (LCY)";
            POSSalesLine."VAT Base Amount" := -POSSalesLine."VAT Base Amount";
            POSSalesLine."Quantity (Base)" := -POSSalesLine."Quantity (Base)";
            POSSalesLine."VAT Difference" := -POSSalesLine."VAT Difference";
        end;
        OnBeforeInsertPOSSalesLineFromExternalPOSSale(ExtSalePOS, ExtSaleLinePOS, POSEntry, POSSalesLine);
        POSSalesLine.Insert(false, true);
        OnAfterInsertPOSSalesLineFromExternalPOSSale(ExtSalePOS, ExtSaleLinePOS, POSEntry, POSSalesLine);
    end;

    internal procedure ExcludeFromPostingExt(ExtSaleLinePOS: Record "NPR External POS Sale Line"): Boolean
    begin
        exit(ExtSaleLinePOS."Line Type" in [ExtSaleLinePOS."Line Type"::Comment]);
    end;

    local procedure InsertPOSPaymentLineExt(ExtSalePOS: Record "NPR External POS Sale"; ExtSaleLinePOS: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSPaymentLine: Record "NPR POS Entry Payment Line")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSPaymentLine.Init();
        POSPaymentLine."POS Entry No." := POSEntry."Entry No.";
        POSPaymentLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSPaymentLine."Line No." := ExtSaleLinePOS."Line No.";

        POSPaymentLine.SetRecFilter();
        if not POSPaymentLine.IsEmpty() then
            repeat
                POSPaymentLine."Line No." := POSPaymentLine."Line No." + 10000;
                POSPaymentLine.SetRecFilter();
            until POSPaymentLine.IsEmpty();
        POSPaymentLine.Reset();

        POSPaymentLine."POS Store Code" := ExtSalePOS."POS Store Code";
        POSPaymentLine."POS Unit No." := ExtSaleLinePOS."Register No.";
        POSPaymentLine."Document No." := ExtSaleLinePOS."Sales Ticket No.";

#pragma warning disable AA0139
        if (not POSPaymentMethod.Get(ExtSaleLinePOS."No.")) then
            POSPaymentMethod.Init();
        POSPaymentLine."POS Payment Method Code" := ExtSaleLinePOS."No.";
#pragma warning restore

        POSPaymentLine."POS Payment Bin Code" := SelectUnitBin(POSPaymentLine."POS Unit No.");

        POSPaymentLine.Description := ExtSaleLinePOS.Description;
        if ExtSaleLinePOS."Currency Amount" <> 0 then begin
            POSPaymentLine.Amount := ExtSaleLinePOS."Currency Amount";
            POSPaymentLine."Payment Amount" := ExtSaleLinePOS."Currency Amount";
        end else begin
            POSPaymentLine.Amount := ExtSaleLinePOS."Amount Including VAT";
            POSPaymentLine."Payment Amount" := ExtSaleLinePOS."Amount Including VAT";
        end;
        POSPaymentLine."Amount (LCY)" := ExtSaleLinePOS."Amount Including VAT";
        POSPaymentLine."Amount (Sales Currency)" := ExtSaleLinePOS."Amount Including VAT"; //Sales Currency is always LCY for now
        POSPaymentLine."Currency Code" := POSPaymentMethod."Currency Code";

        POSPaymentLine.SystemId := ExtSaleLinePOS.SystemId;

        POSPaymentLine."Shortcut Dimension 1 Code" := ExtSaleLinePOS."Shortcut Dimension 1 Code";
        POSPaymentLine."Shortcut Dimension 2 Code" := ExtSaleLinePOS."Shortcut Dimension 2 Code";
        POSPaymentLine."Dimension Set ID" := ExtSaleLinePOS."Dimension Set ID";

        POSPaymentLine."VAT Base Amount (LCY)" := ExtSaleLinePOS."Amount Including VAT";
        if (ExtSaleLinePOS."VAT Base Amount" <> 0) then begin
            POSPaymentLine."VAT Amount (LCY)" := ExtSaleLinePOS."Amount Including VAT" - ExtSaleLinePOS."VAT Base Amount";
            POSPaymentLine."VAT Base Amount (LCY)" := ExtSaleLinePOS."VAT Base Amount";
        end;

        POSPaymentLine."VAT Bus. Posting Group" := ExtSaleLinePOS."VAT Bus. Posting Group";
        POSPaymentLine."VAT Prod. Posting Group" := ExtSaleLinePOS."VAT Prod. Posting Group";

        CreatePaymentLineBinEntry(POSPaymentLine);

        OnBeforeInsertPOSPaymentLineFromExternalPOSSale(ExtSalePOS, ExtSaleLinePOS, POSEntry, POSPaymentLine);
        POSPaymentLine.Insert(false, true);
        OnAfterInsertPOSPaymentLineFromExternalPOSSale(ExtSalePOS, ExtSaleLinePOS, POSEntry, POSPaymentLine);
    end;

    local procedure CreateRMAEntryExt(POSEntry: Record "NPR POS Entry"; ExtSalePOS: Record "NPR External POS Sale"; ExtSaleLinePOS: Record "NPR External POS Sale Line")
    var
        PosRmaLine: Record "NPR POS RMA Line";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        RMAEntryLbl: Label '%1|%2|%3', Locked = true;
    begin
        if (ExtSaleLinePOS."Return Sale Sales Ticket No." = '') then
            exit;

        if (ExtSaleLinePOS.Quantity >= 0) then
            exit;

        if (ExtSaleLinePOS."Line Type" <> ExtSaleLinePOS."Line Type"::Item) then
            exit;

        // Only referenced return sales
        PosRmaLine."Entry No." := 0;
        PosRmaLine."POS Entry No." := POSEntry."Entry No.";

        PosRmaLine."Sales Ticket No." := ExtSaleLinePOS."Return Sale Sales Ticket No.";
        PosRmaLine."Return Ticket No." := ExtSaleLinePOS."Sales Ticket No.";
        PosRmaLine."Return Line No." := ExtSaleLinePOS."Line No.";

        PosRmaLine."Returned Item No." := ExtSaleLinePOS."No.";
        PosRmaLine."Returned Quantity" := ExtSaleLinePOS.Quantity;

        PosRmaLine."Return Reason Code" := ExtSaleLinePOS."Return Reason Code";
        PosRmaLine.Insert();

        OnAfterInsertRmaEntryFromExternalPOSSale(PosRmaLine, POSEntry, ExtSalePOS, ExtSaleLinePOS);

        POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId(), POSAuditLog."Action Type"::ITEM_RMA, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", '',
          StrSubstNo(RMAEntryLbl, PosRmaLine."Return Line No.", PosRmaLine."Sales Ticket No.", PosRmaLine."Return Reason Code"));

    end;

    local procedure AssignRelatedCustomerNoForContact(var POSEntry: Record "NPR POS Entry"; SalePOS: Record "NPR POS Sale")
    var
        MarketingSetup: Record "Marketing Setup";
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
    begin
        if not MarketingSetup.Get() then
            exit;
        if SalePOS."Contact No." = '' then
            exit;
        if not Contact.Get(CopyStr(SalePOS."Contact No.", 1, MaxStrLen(Contact."No."))) then
            exit;
        if not POSEntryNavigation.HasBusinessRelation("Contact Business Relation Link To Table"::Customer, MarketingSetup."Bus. Rel. Code for Customers", Contact) then
            exit;

        ContBusRel.Reset();
        if (Contact."Company No." = '') or (Contact."Company No." = Contact."No.") then
            ContBusRel.SetRange("Contact No.", Contact."No.")
        else
            ContBusRel.SetFilter("Contact No.", '%1|%2', Contact."No.", Contact."Company No.");
        ContBusRel.SetFilter("No.", '<>''''');
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);

        if ContBusRel.IsEmpty() then
            exit;
        ContBusRel.FindFirst();
        POSEntry."Customer No." := ContBusRel."No.";
    end;
    #endregion
}
