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
    begin
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

        POSEntryManagement.RecalculatePOSEntry(POSEntry, WasModified);
        POSEntry.Modify();

        if SaleCancelled then begin
            POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::CANCEL_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_CANCEL_SALE_END, '')
        end else begin
            POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::GRANDTOTAL, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
            POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::DIRECT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_DIRECT_SALE_END, '');
        end;

        OnAfterInsertPOSEntry(Rec, POSEntry);
    end;

    var
        ERR_NO_OPEN_UNIT: Label 'No open %1 could be found for %2 %3.';
        ERR_DOCUMENT_NO_CLASH: Label '%1 %2 has already been used by another %3';
        TXT_SALES_TICKET: Label 'Sales Ticket %1';
        TXT_DIRECT_SALE_END: Label 'POS Direct Sale Ended';
        TXT_CREDIT_SALE_END: Label 'POS Credit Sale Ended';
        TXT_CANCEL_SALE_END: Label 'POS Sale Cancelled';
        CANCEL_SALE: Label 'Sale was cancelled';

    local procedure CreateLines(var POSEntry: Record "NPR POS Entry"; var SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet() then begin
            repeat
                case SaleLinePOS."Sale Type" of
                    SaleLinePOS."Sale Type"::Sale,
                    SaleLinePOS."Sale Type"::Deposit:
                        begin
                            InsertPOSSaleLine(SalePOS, SaleLinePOS, POSEntry, false, POSSalesLine);
                            InsertPOSTaxAmount(SaleLinePOS.SystemId, POSEntry);
                        end;
                    SaleLinePOS."Sale Type"::"Out payment":
                        if SaleLinePOS.Type = SaleLinePOS.Type::"G/L Entry" then begin
                            InsertPOSSaleLine(SalePOS, SaleLinePOS, POSEntry, true, POSSalesLine);
                        end else
                            InsertPOSPaymentLine(SalePOS, SaleLinePOS, POSEntry, POSPaymentLine);
                    SaleLinePOS."Sale Type"::Comment:
                        ; //To-do Comments
                    SaleLinePOS."Sale Type"::"Debit Sale":
                        begin
                            InsertPOSSaleLine(SalePOS, SaleLinePOS, POSEntry, false, POSSalesLine);
                            InsertPOSTaxAmount(SaleLinePOS.SystemId, POSEntry);
                        end;
                    SaleLinePOS."Sale Type"::"Open/Close":
                        ; //To do Open / Close
                    SaleLinePOS."Sale Type"::Payment:
                        InsertPOSPaymentLine(SalePOS, SaleLinePOS, POSEntry, POSPaymentLine);
                end;
            until SaleLinePOS.Next() = 0;
        end;
    end;

    procedure CreatePOSEntryForCreatedSalesDocument(var SalePOS: Record "NPR POS Sale"; var SalesHeader: Record "Sales Header"; Posted: Boolean)
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        POSEntryManagement: Codeunit "NPR POS Entry Management";
        WasModified: Boolean;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        SalesHeaderLbl: Label '%1 %2', Locked = true;
    begin
        OnBeforeCreatePOSEntry(SalePOS);

        if not GetPOSPeriodRegister(SalePOS, POSPeriodRegister, true) then
            Error(ERR_NO_OPEN_UNIT, POSPeriodRegister.TableCaption, POSPeriodRegister.FieldCaption("POS Unit No."), SalePOS."Register No.");
        InsertPOSEntry(POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::"Credit Sale");
        CreateLines(POSEntry, SalePOS);

        POSEntryManagement.RecalculatePOSEntry(POSEntry, WasModified);

        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry."Sales Document Type" := SalesHeader."Document Type";
        POSEntry."Sales Document No." := SalesHeader."No.";

        POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntry, SalesHeader."Document Type", SalesHeader."No.");
        if Posted then
            SetPostedSalesDocInfo(POSEntry, SalesHeader);

        if POSEntry.Description = '' then
            POSEntry.Description := StrSubstNo(SalesHeaderLbl, SalesHeader."Document Type", SalesHeader."No.");
        POSEntry.Modify();

        POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::CREDIT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_CREDIT_SALE_END, '');

        OnAfterInsertPOSEntry(SalePOS, POSEntry);
    end;

    local procedure InsertPOSEntry(var POSPeriodRegister: Record "NPR POS Period Register"; var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry"; EntryType: Option)
    var
        Contact: Record Contact;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalespersonLbl: Label '%1: %2', Locked = true;
    begin
        POSEntry.Init();
        POSEntry."Entry No." := 0; //Autoincrement;
        POSEntry."POS Period Register No." := POSPeriodRegister."No.";
        POSEntry."POS Store Code" := SalePOS."POS Store Code";
        POSEntry."POS Unit No." := SalePOS."Register No.";
        POSEntry."Document No." := SalePOS."Sales Ticket No.";
        POSEntry."Entry Date" := SalePOS.Date;
        POSEntry."Entry Type" := EntryType;

        FiscalNoCheck(POSEntry, SalePOS);

        POSEntry."Salesperson Code" := SalePOS."Salesperson Code";
        if SalePOS."Customer Type" = SalePOS."Customer Type"::Ord then
            POSEntry."Customer No." := SalePOS."Customer No."
        else
            POSEntry."Contact No." := SalePOS."Customer No.";
        if SalePOS."Contact No." <> '' then
            if Contact.Get(CopyStr(SalePOS."Contact No.", 1, MaxStrLen(Contact."No."))) then
                POSEntry."Contact No." := Contact."No.";

        POSEntry."Event No." := SalePOS."Event No.";
        POSEntry."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
        POSEntry."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        POSEntry."Dimension Set ID" := SalePOS."Dimension Set ID";
        POSEntry.SystemId := SalePOS.SystemId;
        POSEntry."Starting Time" := SalePOS."Start Time";
        POSEntry."Ending Time" := Time;
        POSEntry."Posting Date" := SalePOS.Date;
        POSEntry."Document Date" := SalePOS.Date;
        POSEntry."Currency Code" := '';//All sales are in LCY for now (Payments can  be in FCY of course)
        POSEntry."Country/Region Code" := SalePOS."Country Code";
        POSEntry."Tax Area Code" := SalePOS."Tax Area Code";
        POSEntry."Prices Including VAT" := SalePOS."Prices Including VAT";
        POSEntry."NPRE Number of Guests" := SalePOS."NPRE Number of Guests";

        OnBeforeInsertPOSEntry(SalePOS, POSEntry);

        if POSEntry.Description = '' then begin
            case POSEntry."Entry Type" of
                POSEntry."Entry Type"::"Direct Sale":
                    POSEntry.Description := CopyStr(StrSubstNo(TXT_SALES_TICKET, POSEntry."Document No."), 1, MaxStrLen(POSEntry.Description));
                POSEntry."Entry Type"::Balancing:
                    begin
                        if (not SalespersonPurchaser.Get(SalePOS."Salesperson Code")) then
                            SalespersonPurchaser.Name := StrSubstNo(SalespersonLbl, SalespersonPurchaser.TableCaption, SalePOS."Salesperson Code");
                        POSEntry.Description := SalespersonPurchaser.Name;
                    end;

                POSEntry."Entry Type"::"Cancelled Sale":
                    begin
                        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                        if SaleLinePOS.FindFirst() and (SaleLinePOS.Description <> '') then
                            POSEntry.Description := SaleLinePOS.Description
                        else
                            POSEntry.Description := CANCEL_SALE;
                    end;
            end;
        end;

        POSEntry.Insert(false, true);
    end;

    local procedure InsertPOSSaleLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; ReverseSign: Boolean; var POSSalesLine: Record "NPR POS Entry Sales Line")
    var
        PricesIncludeTax: Boolean;
        POSEntrySalesDocLinkMgt: Codeunit "NPR POS Entry S.Doc. Link Mgt.";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSSalesLine.Init();
        POSSalesLine."POS Entry No." := POSEntry."Entry No.";
        POSSalesLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSSalesLine."Line No." := SaleLinePOS."Line No.";
        POSSalesLine.SetRecFilter();
        if not POSSalesLine.IsEmpty() then
            repeat
                POSSalesLine."Line No." := POSSalesLine."Line No." + 10000;
                POSSalesLine.SetRecFilter();
            until POSSalesLine.IsEmpty();

        POSSalesLine.Reset();

        POSSalesLine."POS Store Code" := SalePOS."POS Store Code";
        POSSalesLine."POS Unit No." := SaleLinePOS."Register No.";
        POSSalesLine."Document No." := SaleLinePOS."Sales Ticket No.";
        POSSalesLine."Customer No." := SalePOS."Customer No.";
        POSSalesLine."Salesperson Code" := SalePOS."Salesperson Code";

        case SaleLinePOS.Type of
            SaleLinePOS.Type::Item:
                POSSalesLine.Type := POSSalesLine.Type::Item;
            SaleLinePOS.Type::"G/L Entry":
                POSSalesLine.Type := POSSalesLine.Type::"G/L Account";
            else
                ;//Add silent error comment line
        end;

        case SaleLinePOS."Sale Type" of
            SaleLinePOS."Sale Type"::Deposit:
                if SaleLinePOS.Type = SaleLinePOS.Type::Customer then
                    POSSalesLine.Type := POSSalesLine.Type::Customer;

            SaleLinePOS."Sale Type"::"Out payment":
                //This is currently the only way to see the difference between a Rounding and a Payout line!
                if SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Rounding then
                    POSSalesLine.Type := POSSalesLine.Type::Rounding
                else
                    if SaleLinePOS."Gen. Posting Type" <> SaleLinePOS."Gen. Posting Type"::Purchase then
                        POSSalesLine.Type := POSSalesLine.Type::"G/L Account"
                    else
                        POSSalesLine.Type := POSSalesLine.Type::Payout;
        end;


        POSSalesLine."Exclude from Posting" := ExcludeFromPosting(SaleLinePOS);
        POSSalesLine."No." := SaleLinePOS."No.";
        POSSalesLine."Variant Code" := SaleLinePOS."Variant Code";
        POSSalesLine."Location Code" := SaleLinePOS."Location Code";
        POSSalesLine."Posting Group" := SaleLinePOS."Posting Group";
        POSSalesLine.Description := SaleLinePOS.Description;

        POSSalesLine."Gen. Posting Type" := SaleLinePOS."Gen. Posting Type";
        POSSalesLine."Gen. Bus. Posting Group" := SaleLinePOS."Gen. Bus. Posting Group";
        POSSalesLine."VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
        POSSalesLine."Gen. Prod. Posting Group" := SaleLinePOS."Gen. Prod. Posting Group";
        POSSalesLine."VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
        POSSalesLine."Tax Area Code" := SaleLinePOS."Tax Area Code";
        POSSalesLine."Tax Liable" := SaleLinePOS."Tax Liable";
        POSSalesLine."Tax Group Code" := SaleLinePOS."Tax Group Code";
        POSSalesLine."Use Tax" := SaleLinePOS."Use Tax";

        POSSalesLine."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        POSSalesLine.Quantity := SaleLinePOS.Quantity;
        POSSalesLine."Quantity (Base)" := SaleLinePOS."Quantity (Base)";
        POSSalesLine."Qty. per Unit of Measure" := SaleLinePOS."Qty. per Unit of Measure";
        POSSalesLine."Unit Price" := SaleLinePOS."Unit Price";
        POSSalesLine."Unit Cost (LCY)" := SaleLinePOS."Unit Cost (LCY)";
        POSSalesLine."Unit Cost" := SaleLinePOS."Unit Cost";
        POSSalesLine."VAT %" := SaleLinePOS."VAT %";
        POSSalesLine."VAT Identifier" := SaleLinePOS."VAT Identifier";
        POSSalesLine."VAT Calculation Type" := SaleLinePOS."VAT Calculation Type";

        POSSalesLine."Discount Type" := SaleLinePOS."Discount Type";
        POSSalesLine."Discount Code" := SaleLinePOS."Discount Code";
        POSSalesLine."Discount Authorised by" := SaleLinePOS."Discount Authorised by";

        POSSalesLine."Reason Code" := SaleLinePOS."Reason Code";
        POSSalesLine."Line Discount %" := SaleLinePOS."Discount %";

        PricesIncludeTax := SalePOS."Prices Including VAT";
        if PricesIncludeTax then begin
            POSSalesLine."Line Discount Amount Incl. VAT" := SaleLinePOS."Discount Amount";
            POSSalesLine."Line Discount Amount Excl. VAT" := SaleLinePOS."Discount Amount" / (1 + (SaleLinePOS."VAT %" / 100));
        end else begin
            POSSalesLine."Line Discount Amount Excl. VAT" := SaleLinePOS."Discount Amount";
            POSSalesLine."Line Discount Amount Incl. VAT" := (1 + (SaleLinePOS."VAT %" / 100)) * SaleLinePOS."Discount Amount";
        end;

        POSSalesLine."Amount Excl. VAT" := SaleLinePOS.Amount;
        POSSalesLine."Amount Incl. VAT" := SaleLinePOS."Amount Including VAT";
        POSSalesLine."VAT Base Amount" := SaleLinePOS."VAT Base Amount";
        POSSalesLine."Line Amount" := SaleLinePOS."Line Amount";

        if ((SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment")
          and (SaleLinePOS."Discount Type" <> SaleLinePOS."Discount Type"::Rounding)) then
            POSSalesLine."Line Amount" *= -1;

        POSSalesLine."Amount Excl. VAT (LCY)" := SaleLinePOS.Amount * POSEntry."Currency Factor";
        POSSalesLine."Amount Incl. VAT (LCY)" := SaleLinePOS."Amount Including VAT" * POSEntry."Currency Factor";

        POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := POSSalesLine."Line Discount Amount Excl. VAT" * POSEntry."Currency Factor";
        POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := POSSalesLine."Line Discount Amount Incl. VAT" * POSEntry."Currency Factor";

        POSSalesLine.SystemId := SaleLinePOS.SystemId;

        POSSalesLine."Item Category Code" := SaleLinePOS."Item Category Code";

        POSSalesLine."Serial No." := SaleLinePOS."Serial No.";
        POSSalesLine."Retail Serial No." := SaleLinePOS."Serial No. not Created";
        POSSalesLine."Return Reason Code" := SaleLinePOS."Return Reason Code";
        POSSalesLine."NPRE Seating Code" := SaleLinePOS."NPRE Seating Code";

        CreateRMAEntry(POSEntry, SalePOS, SaleLinePOS);

        if SaleLinePOS."Sales Document No." <> '' then begin
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.");
        end;

        if SaleLinePOS."Posted Sales Document No." <> '' then begin
            case SaleLinePOS."Posted Sales Document Type" of
                SaleLinePOS."Posted Sales Document Type"::INVOICE:
                    POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE, SaleLinePOS."Posted Sales Document No.");
                SaleLinePOS."Posted Sales Document Type"::CREDIT_MEMO:
                    POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, POSEntrySalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO, SaleLinePOS."Posted Sales Document No.");
            end;
        end;

        if SaleLinePOS."Delivered Sales Document No." <> '' then begin
            case SaleLinePOS."Delivered Sales Document Type" of
                SaleLinePOS."Delivered Sales Document Type"::SHIPMENT:
                    POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, POSEntrySalesDocLink."Sales Document Type"::SHIPMENT, SaleLinePOS."Delivered Sales Document No.");
                SaleLinePOS."Delivered Sales Document Type"::RETURN_RECEIPT:
                    POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, POSEntrySalesDocLink."Sales Document Type"::RETURN_RECEIPT, SaleLinePOS."Delivered Sales Document No.");
            end;
        end;

        POSSalesLine."Applies-to Doc. Type" := SaleLinePOS."Buffer Document Type";
        POSSalesLine."Applies-to Doc. No." := SaleLinePOS."Buffer Document No.";

        POSSalesLine."Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
        POSSalesLine."Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
        POSSalesLine."Dimension Set ID" := SaleLinePOS."Dimension Set ID";
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
        OnBeforeInsertPOSSalesLine(SalePOS, SaleLinePOS, POSEntry, POSSalesLine);
        POSSalesLine.Insert(false, true);
        OnAfterInsertPOSSalesLine(SalePOS, SaleLinePOS, POSEntry, POSSalesLine);
    end;

    local procedure InsertPOSPaymentLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSPaymentLine: Record "NPR POS Entry Payment Line")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        POSPaymentLine.Init();
        POSPaymentLine."POS Entry No." := POSEntry."Entry No.";
        POSPaymentLine."POS Period Register No." := POSEntry."POS Period Register No.";
        POSPaymentLine."Line No." := SaleLinePOS."Line No.";

        POSPaymentLine.SetRecFilter();
        if not POSPaymentLine.IsEmpty() then
            repeat
                POSPaymentLine."Line No." := POSPaymentLine."Line No." + 10000;
                POSPaymentLine.SetRecFilter();
            until POSPaymentLine.IsEmpty();
        POSPaymentLine.Reset();

        POSPaymentLine."POS Store Code" := SalePOS."POS Store Code";
        POSPaymentLine."POS Unit No." := SaleLinePOS."Register No.";
        POSPaymentLine."Document No." := SaleLinePOS."Sales Ticket No.";

#pragma warning disable AA0139
        if (not POSPaymentMethod.Get(SaleLinePOS."No.")) then
            POSPaymentMethod.Init();
        POSPaymentLine."POS Payment Method Code" := SaleLinePOS."No.";
#pragma warning restore

        POSPaymentLine."POS Payment Bin Code" := SelectUnitBin(POSPaymentLine."POS Unit No.");

        POSPaymentLine.Description := SaleLinePOS.Description;
        if SaleLinePOS."Currency Amount" <> 0 then begin
            POSPaymentLine.Amount := SaleLinePOS."Currency Amount";
            POSPaymentLine."Payment Amount" := SaleLinePOS."Currency Amount";
        end else begin
            POSPaymentLine.Amount := SaleLinePOS."Amount Including VAT";
            POSPaymentLine."Payment Amount" := SaleLinePOS."Amount Including VAT";
        end;
        POSPaymentLine."Amount (LCY)" := SaleLinePOS."Amount Including VAT";
        POSPaymentLine."Amount (Sales Currency)" := SaleLinePOS."Amount Including VAT"; //Sales Currency is always LCY for now
        POSPaymentLine."Currency Code" := POSPaymentMethod."Currency Code";

        POSPaymentLine.EFT := SaleLinePOS."EFT Approved";
        POSPaymentLine.SystemId := SaleLinePOS.SystemId;

        POSPaymentLine."Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
        POSPaymentLine."Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
        POSPaymentLine."Dimension Set ID" := SaleLinePOS."Dimension Set ID";

        POSPaymentLine."VAT Base Amount (LCY)" := SaleLinePOS."Amount Including VAT";
        if (SaleLinePOS."VAT Base Amount" <> 0) then begin
            POSPaymentLine."VAT Amount (LCY)" := SaleLinePOS."Amount Including VAT" - SaleLinePOS."VAT Base Amount";
            POSPaymentLine."VAT Base Amount (LCY)" := SaleLinePOS."VAT Base Amount";
        end;

        POSPaymentLine."VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
        POSPaymentLine."VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";

        CreatePaymentLineBinEntry(POSPaymentLine);

        OnBeforeInsertPOSPaymentLine(SalePOS, SaleLinePOS, POSEntry, POSPaymentLine);

        POSPaymentLine.Insert(false, true);
        OnAfterInsertPOSPaymentLine(SalePOS, SaleLinePOS, POSEntry, POSPaymentLine);
    end;

    local procedure InsertPOSBalancingLine(PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp."; POSEntry: Record "NPR POS Entry"; LineNo: Integer; IsBinTransfer: Boolean)
    var
        POSBalancingLine: Record "NPR POS Balancing Line";
        POSBinEntry: Record "NPR POS Bin Entry";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Difference: Decimal;
        POSBalancingLineDescriptionLbl: Label '%1: %2 - %3', Locked = true;
    begin

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
                PaymentBinCheckpoint."Move to Bin Reference" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
                PaymentBinCheckpoint.Modify();
            end;
            PaymentBinCheckpoint.TestField("Move to Bin Code");
            POSBalancingLine."Move-To Bin Code" := PaymentBinCheckpoint."Move to Bin Code";
            POSBalancingLine."Move-To Bin Amount" := PaymentBinCheckpoint."Move to Bin Amount";
            POSBalancingLine."Move-To Reference" := PaymentBinCheckpoint."Move to Bin Reference";
            InsertBinTransfer(POSBinEntry,
              PaymentBinCheckpoint."Move to Bin Code",
              PaymentBinCheckpoint."Move to Bin Amount",
              PaymentBinCheckpoint."Move to Bin Reference");
        end;

        // Move to a different bin instruction (The "BANK")
        if (PaymentBinCheckpoint."Bank Deposit Amount" <> 0) then begin
            if (PaymentBinCheckpoint."Bank Deposit Reference" = '') then begin
                PaymentBinCheckpoint."Bank Deposit Reference" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
                PaymentBinCheckpoint.Modify();
            end;
            PaymentBinCheckpoint.TestField("Bank Deposit Bin Code");
            POSBalancingLine."Deposit-To Bin Code" := PaymentBinCheckpoint."Bank Deposit Bin Code";
            POSBalancingLine."Deposit-To Bin Amount" := PaymentBinCheckpoint."Bank Deposit Amount";
            POSBalancingLine."Deposit-To Reference" := PaymentBinCheckpoint."Bank Deposit Reference";
            InsertBankTransfer(POSBinEntry,
              PaymentBinCheckpoint."Bank Deposit Bin Code",
              PaymentBinCheckpoint."Bank Deposit Amount",
              PaymentBinCheckpoint."Bank Deposit Reference");
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

    local procedure InsertBinTransfer(CheckpointEntry: Record "NPR POS Bin Entry"; TargetBinNo: Code[10]; TransactionAmount: Decimal; Reference: Text[50])
    var
        POSBinEntry: Record "NPR POS Bin Entry";
    begin

        // Withdrawl from source bin
        POSBinEntry.Init();
        POSBinEntry.TransferFields(CheckpointEntry);
        POSBinEntry."Entry No." := 0;
        POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_OUT;

        POSBinEntry."External Transaction No." := Reference;
        POSBinEntry.Comment := 'Transfer';
        POSBinEntry."Transaction Amount" := -1 * TransactionAmount;
        CalculateTransactionAmountLCY(POSBinEntry);

        POSBinEntry.Insert();

        // Deposit to target bin
        POSBinEntry."Entry No." := 0;
        POSBinEntry."Payment Bin No." := TargetBinNo;
        POSBinEntry.Type := POSBinEntry.Type::BIN_TRANSFER_IN;

        POSBinEntry."Transaction Amount" *= -1;
        POSBinEntry."Transaction Amount (LCY)" *= -1;

        POSBinEntry.Insert();
    end;

    local procedure InsertBankTransfer(CheckpointEntry: Record "NPR POS Bin Entry"; TargetBinNo: Code[10]; TransactionAmount: Decimal; Reference: Text[50])
    var
        POSBinEntry: Record "NPR POS Bin Entry";
    begin

        // Withdrawl from source bin
        POSBinEntry.Init();
        POSBinEntry.TransferFields(CheckpointEntry);
        POSBinEntry."Entry No." := 0;
        POSBinEntry.Type := POSBinEntry.Type::BANK_TRANSFER_OUT;

        POSBinEntry."External Transaction No." := Reference;
        POSBinEntry.Comment := 'Bank Transfer';
        POSBinEntry."Transaction Amount" := -1 * TransactionAmount;
        CalculateTransactionAmountLCY(POSBinEntry);

        POSBinEntry.Insert();

        // Deposit to target bin
        POSBinEntry."Entry No." := 0;
        POSBinEntry."Payment Bin No." := TargetBinNo;
        POSBinEntry.Type := POSBinEntry.Type::BANK_TRANSFER_IN;

        POSBinEntry."Transaction Amount" *= -1;
        POSBinEntry."Transaction Amount (LCY)" *= -1;

        POSBinEntry.Insert();
    end;

    local procedure InsertBinAdjustment(CheckpointBinEntry: Record "NPR POS Bin Entry"; TransactionAmount: Decimal; Comment: Text[50])
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

        POSBinEntry.Insert();
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

    procedure InsertUnitLoginEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
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

    procedure InsertUnitLogoutEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Logout');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SIGN_OUT, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
    end;

    procedure InsertUnitLockEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Lock');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::UNIT_LOCK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");

    end;

    procedure InsertUnitUnlockEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Unlock');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::UNIT_UNLOCK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");

    end;

    procedure InsertBinOpenEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20])
    begin
        CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Bin Open');
    end;

    procedure InsertParkSaleEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Park Sale');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SALE_PARK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
    end;

    procedure InsertParkedSaleRetrievalEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]; ParkedSalesTicketNo: Code[20]; NewSalesTicketNo: Code[20]) EntryNo: Integer
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

    procedure InsertResumeSaleEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]; UnfinishedTicketNo: Code[20]; NewSalesTicketNo: Code[20]) EntryNo: Integer
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

    procedure InsertTransferLocation(POSUnitNo: Code[10]; SalespersonCode: Code[20]; OldDocumentNo: Code[20]; NewDocumentNo: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
        SystemEventLbl: Label '[System Event] %1 transferred to location receipt %2', Locked = true;
    begin
        CreatePOSSystemEntry(POSUnitNo, SalespersonCode, CopyStr(StrSubstNo(SystemEventLbl, OldDocumentNo, NewDocumentNo), 1, MaxStrLen(POSEntry.Description)));

    end;

    local procedure CreatePOSSystemEntry(POSUnitNo: Code[10]; SalespersonCode: Code[20]; Description: Text[80]): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSPeriodRegister: Record "NPR POS Period Register";
    begin

        if (not GetPOSPeriodRegisterForPOSUnit(POSUnitNo, POSPeriodRegister, false)) then
            Error(ERR_NO_OPEN_UNIT, POSPeriodRegister.TableCaption, POSPeriodRegister.FieldCaption("POS Unit No."), POSUnitNo);

        POSEntry.Init();
        POSEntry."Entry No." := 0;
        POSEntry."Entry Type" := POSEntry."Entry Type"::Other;
        POSEntry."System Entry" := true;

        POSEntry."POS Period Register No." := POSPeriodRegister."No.";
        POSEntry."POS Store Code" := GetStoreNoForUnitNo(POSUnitNo);
        POSEntry."POS Unit No." := POSUnitNo;

        POSEntry."Entry Date" := Today();
        POSEntry."Starting Time" := Time;
        POSEntry."Ending Time" := Time;
        POSEntry."Salesperson Code" := SalespersonCode;

        POSEntry.Description := Description;
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";

        POSEntry.Insert();

        exit(POSEntry."Entry No.");
    end;

    local procedure CreatePaymentLineBinEntry(POSPaymentLine: Record "NPR POS Entry Payment Line")
    var
        POSBinEntry: Record "NPR POS Bin Entry";
    begin

        POSBinEntry."Entry No." := 0;
        POSBinEntry."POS Entry No." := POSPaymentLine."POS Entry No.";
        POSBinEntry."POS Payment Line No." := POSPaymentLine."Line No.";
        POSBinEntry."Created At" := CurrentDateTime();

        POSBinEntry.Type := POSBinEntry.Type::INPAYMENT;
        if (POSPaymentLine.Amount < 0) then
            POSBinEntry.Type := POSBinEntry.Type::OUTPAYMENT;

        POSBinEntry."Payment Bin No." := POSPaymentLine."POS Payment Bin Code";
        POSBinEntry."Payment Method Code" := POSPaymentLine."POS Payment Method Code";

        POSBinEntry."POS Store Code" := POSPaymentLine."POS Store Code";
        POSBinEntry."POS Unit No." := POSPaymentLine."POS Unit No.";

        POSBinEntry."Transaction Date" := Today();
        POSBinEntry."Transaction Time" := Time;
        POSBinEntry."Transaction Amount" := POSPaymentLine.Amount;
        POSBinEntry."Transaction Currency Code" := POSPaymentLine."Currency Code";
        POSBinEntry."Transaction Amount (LCY)" := POSPaymentLine."Amount (LCY)";

        //- Legacy
        POSBinEntry."Payment Type Code" := POSPaymentLine."POS Payment Method Code";
        POSBinEntry."Register No." := POSPaymentLine."POS Unit No.";
        //+ Legacy

        POSBinEntry.Insert();
    end;

    local procedure CalculateTransactionAmountLCY(var POSBinEntry: Record "NPR POS Bin Entry")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin

        POSBinEntry."Transaction Amount (LCY)" := POSBinEntry."Transaction Amount";

        if (POSBinEntry."Transaction Amount" = 0) then
            exit;

        if (POSBinEntry."Transaction Currency Code" = '') then
            exit;

        // ** Legacy Way
        if not POSPaymentMethod.Get(POSBinEntry."Payment Type Code") then
            exit;

        if (POSPaymentMethod."Fixed Rate" <> 0) then
            POSBinEntry."Transaction Amount (LCY)" := POSBinEntry."Transaction Amount" * POSPaymentMethod."Fixed Rate" / 100;

        if (POSPaymentMethod."Rounding Precision" = 0) then
            exit;

        POSBinEntry."Transaction Amount (LCY)" := Round(POSBinEntry."Transaction Amount (LCY)", POSPaymentMethod."Rounding Precision", POSPaymentMethod.GetRoundingType());
        exit;

        // ** End Legacy

        // ** Future way
        // IF (NOT Currency.Get() (CurrencyCode)) THEN
        //  EXIT;
        //
        // EXIT (ROUND (CurrExchRate.ExchangeAmtFCYToLCY (TransactionDate, CurrencyCode, Amount,
        //                                               1 / CurrExchRate.ExchangeRate (TransactionDate, CurrencyCode))));
    end;

    local procedure GetPOSPeriodRegister(var SalePOS: Record "NPR POS Sale"; var POSPeriodRegister: Record "NPR POS Period Register"; CheckOpen: Boolean): Boolean
    begin
        exit(GetPOSPeriodRegisterForPOSUnit(SalePOS."Register No.", POSPeriodRegister, CheckOpen));
    end;

    local procedure GetPOSPeriodRegisterForPOSUnit(POSUnitNo: Code[10]; var POSPeriodRegister: Record "NPR POS Period Register"; CheckOpen: Boolean): Boolean
    begin
        POSPeriodRegister.Reset();
        POSPeriodRegister.SetRange("POS Unit No.", POSUnitNo);
        if not POSPeriodRegister.FindLast() then
            exit(false);
        if CheckOpen then
            if POSPeriodRegister.Status <> POSPeriodRegister.Status::OPEN then
                exit(false);
        exit(true);
    end;

    procedure CreateBalancingEntryAndLines(var SalePOS: Record "NPR POS Sale"; IntermediateEndOfDay: Boolean; WorkshiftEntryNo: Integer) EntryNo: Integer
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        PaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
        POSEntry: Record "NPR POS Entry";
        LineNo: Integer;
        PaymentBinCheckpointUpdate: Record "NPR POS Payment Bin Checkp.";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalespersonPurchaserLbl: Label '%1: %2', Locked = true;
    begin

        PaymentBinCheckpoint.SetFilter("Workshift Checkpoint Entry No.", '=%1', WorkshiftEntryNo);
        PaymentBinCheckpoint.SetFilter(Status, '=%1', PaymentBinCheckpoint.Status::WIP);
        PaymentBinCheckpoint.SetFilter("Include In Counting", '<>%1', PaymentBinCheckpoint."Include In Counting"::NO);

        if (not PaymentBinCheckpoint.IsEmpty()) then
            exit(0); // Still work to do before counting is completed

        PaymentBinCheckpoint.SetFilter(Status, '=%1', PaymentBinCheckpoint.Status::READY);
        if (PaymentBinCheckpoint.IsEmpty()) then
            exit(0); // Nothing is ready to post

        PaymentBinCheckpoint.FindSet();

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
            if (not POSWorkshiftCheckpoint.IsEmpty()) then
                POSWorkshiftCheckpoint.ModifyAll(Open, false);
        end;

        LineNo := 10000;
        repeat
            InsertPOSBalancingLine(PaymentBinCheckpoint, POSEntry, LineNo, (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::TRANSFER));

            LineNo += 10000;
            PaymentBinCheckpointUpdate.Get(PaymentBinCheckpoint."Entry No.");
            PaymentBinCheckpointUpdate.Status := PaymentBinCheckpointUpdate.Status::TRANSFERED;
            PaymentBinCheckpointUpdate.Modify();

        until (PaymentBinCheckpoint.Next() = 0);

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

        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) then
            exit;

        if (SaleLinePOS."Sale Type" <> SaleLinePOS."Sale Type"::Sale) then
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

        if (POSUnit.Get(POSUnitNo)) then;

        exit(POSUnit."POS Store Code");
    end;


    local procedure SelectUnitBin(UnitNo: Code[10]): Code[10]
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(UnitNo);

        exit(POSUnit."Default POS Payment Bin");
    end;

    local procedure IsCancelledSale(SalePOS: Record "NPR POS Sale"): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin

        if SalePOS."Sale type" = SalePOS."Sale type"::Annullment then
            exit(true);

        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Comment);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Cancelled);
        exit(not SaleLinePOS.IsEmpty());

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

    procedure ExcludeFromPosting(SaleLinePOS: Record "NPR POS Sale Line"): Boolean
    begin
        if SaleLinePOS.Type in [SaleLinePOS.Type::Comment] then
            exit(true);

        exit(SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::Comment, SaleLinePOS."Sale Type"::"Debit Sale", SaleLinePOS."Sale Type"::"Open/Close"]);
    end;

    local procedure "--"()
    begin
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
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSSalesLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSSalesLine: Record "NPR POS Entry Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSPaymentLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; var POSPaymentLine: Record "NPR POS Entry Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSPaymentLine(SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line"; POSEntry: Record "NPR POS Entry"; POSPaymentLine: Record "NPR POS Entry Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSBalanceLine(POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp."; POSEntry: Record "NPR POS Entry"; var POSBalancingLine: Record "NPR POS Balancing Line")
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnAfterInsertRmaEntry(POSRMALine: Record "NPR POS RMA Line"; POSEntry: Record "NPR POS Entry"; SalePOS: Record "NPR POS Sale"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateFindRecords', '', true, true)]
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
            RecordCount := InsertIntoDocEntry(DocumentEntry, DATABASE::"NPR POS Entry", 0, CopyStr(DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count());

            if (RecordCount = 0) then begin
                if not (POSEntry.SetCurrentKey(POSEntry."Fiscal No.")) then;
                POSEntry.Reset();
                POSEntry.SetFilter("Fiscal No.", DocNoFilter);
                POSEntry.SetFilter("Posting Date", PostingDateFilter);
                RecordCount := InsertIntoDocEntry(DocumentEntry, DATABASE::"NPR POS Entry", 1, CopyStr(DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count());
            end;

            if (RecordCount = 0) then begin
                POSPeriodRegister.SetFilter("Document No.", DocNoFilter);
                if (POSPeriodRegister.FindFirst()) then begin
                    POSEntry.Reset();
                    POSEntry.SetFilter("POS Period Register No.", '=%1', POSPeriodRegister."No.");
                    POSEntry.SetFilter("System Entry", '=%1', false);
                    RecordCount := InsertIntoDocEntry(DocumentEntry, DATABASE::"NPR POS Entry", 2, CopyStr(DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count());
                end;
            end;
        end;

    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateShowRecords', '', true, true)]
    local procedure OnNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean)
    var
        POSEntry: Record "NPR POS Entry";
        POSPeriodRegister: Record "NPR POS Period Register";
        DocumentEntry: Record "Document Entry" temporary;
    begin

        if (TableID = DATABASE::"NPR POS Entry") then begin

            OnNavigateFindRecords(DocumentEntry, DocNoFilter, PostingDateFilter);

#if BC17 
            if (DocumentEntry."Document Type" = 0) then begin
#else
            if (DocumentEntry."Document Type".AsInteger() = 0) then begin
#endif
                if not (POSEntry.SetCurrentKey(POSEntry."Document No.")) then;
                POSEntry.SetFilter("Document No.", DocumentEntry."Document No.");
            end;

#if BC17 
            if (DocumentEntry."Document Type" = 1) then begin
#else
            if (DocumentEntry."Document Type".AsInteger() = 2) then begin
#endif
                if not (POSEntry.SetCurrentKey(POSEntry."Fiscal No.")) then;
                POSEntry.SetFilter("Fiscal No.", DocumentEntry."Document No.");
            end;

#if BC17 
            if (DocumentEntry."Document Type" = 2) then begin
#else
            if (DocumentEntry."Document Type".AsInteger() = 2) then begin
#endif
                POSPeriodRegister.SetFilter("Document No.", DocumentEntry."Document No.");
                if (POSPeriodRegister.FindFirst()) then begin
                    POSEntry.SetFilter("POS Period Register No.", '=%1', POSPeriodRegister."No.");
                    POSEntry.SetFilter("System Entry", '=%1', false);
                end;
            end;

            if (DocumentEntry."No. of Records" = 1) then
                PAGE.Run(PAGE::"NPR POS Entry List", POSEntry)
            else
                PAGE.Run(0, POSEntry);

        end;
    end;

    local procedure InsertIntoDocEntry(var DocumentEntry: Record "Document Entry" temporary; DocTableID: Integer; DocType: Integer; DocNoFilter: Code[20]; DocTableName: Text[1024]; DocNoOfRecords: Integer): Integer
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
        POSEntryTaxCalc: codeunit "NPR POS Entry Tax Calc.";
    begin
        POSEntryTaxCalc.PostPOSTaxAmountCalculation(POSEntry."Entry No.", SystemId);
    end;
}

