codeunit 6150614 "POS Create Entry"
{
    // NPR5.33/AP/20170601  CASE 262628  Create POS Entries
    // NPR5.33/AP/20170627  CASE 279558  Added event publishers
    // NPR5.36/BR/20170703  CASE 279551  Added extra fields
    // NPR5.36/TSA /20170713 CASE 282251 Refactored slightly, removing globals, change signature on local procedures, adding the line to the publisher, removing var access to immutable data
    // NPR5.36/TSA /20170713 CASE 282251 Added function for inserting balancing entries
    // NPR5.36/BR  /20170731 CASE 279552 Added integration with POS Ledger Register and POS Tax Lines
    // NPR5.36/BR  /20170911 CASE 279552 Calulate discount and VAT correctly
    // NPR5.36/TSA /20170919 CASE 282251 Completing the balancing functionality
    // NPR5.36/BR  /20170911 CASE 279552 Added multicurrency support
    // NPR5.37/BR  /20171016 CASE 293227 Added Rounding support
    // NPR5.37/BR  /20171017 CASE 293711 Change and Outpayment support
    // NPR5.37/BR  /20171020 CASE 294052 Fix error when inserting SalesLines
    // NPR5.37/BR  /20171024 CASE 294311 Added Create POS Posting Setup
    // NPR5.37/BR  /20171024 CASE 294362 Added support for Creating Sales Orders
    // NPR5.38/BR  /20171108 CASE 294718 Added fields Applies-to Doc. Type and Applies-to Doc. No.
    // NPR5.38/BR  /20171108 CASE 294720 Added field External Doc. No.
    // NPR5.38/TSA /20171123 CASE 297087 Added supporting functions for non-financial transactions
    // NPR5.38/BR  /20171214 CASE 299888 Renamed from POSPeriodRegister to POSPeriodRegister
    // NPR5.38/BR  /20180111 CASE 301600 Set System Entries to Not to be posted
    // NPR5.38/BR  /20180119 CASE 302766 Added Gift Voucher and Credit Voucher links
    // NPR5.38/BR  /20180119 CASE 302767 Bugfix for the automatica creation of Posting Setup
    // NPR5.38/BR  /20180122 CASE 302693 Added support for Payout
    // NPR5.38/BR  /20180124 CASE 302761 Added function InsertTransferLocation
    // NPR5.39/BR  /20180129 CASE 302803 Added fix for Discount Amount calculation
    // NPR5.39/BR  /20180208 CASE 302803 Handle extra type Rounding
    // NPR5.39/BR  /20180221 CASE 305795 Split Payout from Discount
    // NPR5.39/MHA /20180214 CASE 305139 Added "Discount Authorised by" in InsertPOSSaleLine()
    // NPR5.40/TSA /20180228 CASE 306581 Marking the workshift checkpoint as closed when transfered to pos entry.
    // NPR5.40/TSA /20180228 CASE 306581 Added Entry No as return value to CreateBalancingEntryAndLines();
    // NPR5.40/MMV /20180228 CASE 308457 Moved fiscal no. inside end sale transaction.
    // NPR5.40/TSA /20180301 CASE 306858 Added the Payment Bin Entries for payments
    // NPR5.40/TSA /20180306 CASE 307267 Added SelectUnitBin()
    // NPR5.40/MMV /20180328 CASE 276562 Fill sale totals and tax information for entry type debit sale.
    //                                   Removed redundant tax calculation on entry create.
    // NPR5.41/MMV /20180418 CASE 311309 Fill out VAT info.
    // NPR5.41/TSA /20180424 CASE 312575 Added transfer for "Item Category Code" and "Product Group Code"
    // NPR5.43/TSA /20180427 CASE 311964 Changed the balancing function to accept bin transfers and having them posted with reseting counters for z-report
    // NPR5.43/TSA /20180604 CASE 311964 Added new types to the differentiate transfer direction
    // NPR5.43/TSA /20180614 CASE 318660 Added Discount % transfer
    // NPR5.44/MHA /20180705 CASE 321231 Added "Reason Code" to POS Sales Line transfer
    // NPR5.45/TSA /20180726 CASE 322769 Added filter for "include in counting"
    // NPR5.45/MHA /20180821 CASE 324395 SaleLinePOS."Unit Price (LCY)" Renamed to "Unit Cost (LCY)"
    // NPR5.48/JDH /20181121 CASE 335967 Qty. per unit of measure and Line Amount transferred
    // NPR5.48/MMV /20181026 CASE 318028 POS auditing features and refactored entry type logic.
    // NPR5.48/TSA /20181127 CASE 336921 Added return value for entryno created for InsertUnitOpenEntry(), InsertUnitCloseEndEntry() and InsertUnitCloseBeginEntry ()
    // NPR5.48/TSA /20190207 CASE 345292 Made an exception for field Line Amount when its an Out Payment
    // NPR5.48/TSA /20190208 CASE 343578 Added support for creating entry lines in contexts of a debet sale (reversing an invoice from the POS)
    // NPR5.49/TSA /20190317 CASE 348458 Consolidation entries (related to z-report) are marked as open=false when corresponding z-report is posted
    // NPR5.49/TSA /20190319 CASE 342090 Added RMA Support - CreateRMAEntry()
    // NPR5.50/MHA /20190622 CASE 337539 Added "Retail ID" in InsertPOSEntry() and InsertPOSSaleLine()
    // NPR5.50/MMV /20190320 CASE 300557 Improved sales doc. references.
    // NPR5.50/TSA /20190520 CASE 354832 Added reversal of preliminary VAT
    // NPR5.51/MMV /20190617 CASE 356076 Set cancelled sale posting to not be posted for better clarity.
    //                                   Write to POS Audit Log for additional system events.
    //                                   Removed undocumented code in CreatePOSSystemEntry()
    // NPR5.51/MHA /20190718 CASE 362329 Added "Exclude from Posting" on POS Sales Lines in InsertPOSSaleLine()
    // NPR5.52/TSA /20190925 CASE 369231 Assign "Retail Serial No." value
    // NPR5.52/TSA /20190904 CASE 367393 Added implementation of Navigate for POS Entry
    // NPR5.52/ALPO/20191030 CASE 374750 Set "Exclude from Posting" on POS Sales Lines to TRUE for Credit Sales transactions
    // NPR5.53/ALPO/20191022 CASE 373743 Field "Sales Ticket Series" moved from "Cash Register" to "POS Audit Profile"
    // NPR5.53/ALPO/20191105 CASE 376035 Save active event on Sale POS and POS Entry
    // NPR5.53/ALPO/20191204 CASE 379729 Total amounts were not calculated on POS Entry for Credit Sales and Credit Memos
    // NPR5.53/ALPO/20200108 CASE 380918 Post Seating Code and Number of Guests to POS Entries (for further sales analysis breakedown)
    // NPR5.53/MMV /20200108 CASE 373453 Support for storing links to posted documents when unposted document fields are blank.
    // NPR5.54/TJ  /20200211 CASE 347209 Cancelled sale gets a similar description as on Audit Roll
    // NPR5.54/MMV /20200220 CASE 391871 Added field "Retail ID" for payment lines.
    // NPR5.55/TSA /20200228 CASE 393569 Added a publisher when RMA lines are created.
    // NPR5.55/ALPO/20200720 CASE 391678 Use description for cancalled sales from sale line pos; Log resume sale and parked sale retrieval

    TableNo = "Sale POS";

    trigger OnRun()
    var
        POSEntry: Record "POS Entry";
        POSPeriodRegister: Record "POS Period Register";
        POSTaxCalculation: Codeunit "POS Tax Calculation";
        POSEntryManagement: Codeunit "POS Entry Management";
        WasModified: Boolean;
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
        SaleCancelled: Boolean;
    begin
        ValidateSaleHeader(Rec);

        OnBeforeCreatePOSEntry(Rec);

        if not GetPOSPeriodRegister(Rec,POSPeriodRegister,true) then
          Error(ERR_NO_OPEN_UNIT,POSPeriodRegister.TableCaption,POSPeriodRegister.FieldCaption("POS Unit No."),Rec."Register No.");

        SaleCancelled := IsCancelledSale(Rec);
        if SaleCancelled then begin
          InsertPOSEntry(POSPeriodRegister, Rec, POSEntry, POSEntry."Entry Type"::"Cancelled Sale");
        //-NPR5.51 [356076]
          POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
          POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        //+NPR5.51 [356076]
        end else begin
          InsertPOSEntry(POSPeriodRegister, Rec, POSEntry, POSEntry."Entry Type"::"Direct Sale");
        end;

        CreateLines(POSEntry,Rec);

        POSEntryManagement.RecalculatePOSEntry(POSEntry,WasModified);
        POSEntry.Modify;

        if SaleCancelled then begin
          POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::CANCEL_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_CANCEL_SALE_END, '')
        end else begin
        //-NPR5.51 [356076]
          POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::GRANDTOTAL, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        //+NPR5.51 [356076]
          POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::DIRECT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_DIRECT_SALE_END, '');
        end;

        OnAfterInsertPOSEntry(Rec,POSEntry);
    end;

    var
        ERR_NO_OPEN_UNIT: Label 'No open %1 could be found for %2 %3.';
        ERR_DOCUMENT_NO_CLASH: Label '%1 %2 has already been used by another %3';
        TXT_SALES_TICKET: Label 'Sales Ticket %1';
        TXT_DIRECT_SALE_END: Label 'POS Direct Sale Ended';
        TXT_CREDIT_SALE_END: Label 'POS Credit Sale Ended';
        TXT_CANCEL_SALE_END: Label 'POS Sale Cancelled';
        CANCEL_SALE: Label 'Sale was cancelled';

    local procedure CreateLines(var POSEntry: Record "POS Entry";var SalePOS: Record "Sale POS")
    var
        SaleLinePOS: Record "Sale Line POS";
        POSSalesLine: Record "POS Sales Line";
        POSPaymentLine: Record "POS Payment Line";
    begin
        //-NPR5.37 [294362]
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindSet then begin
          repeat
            case SaleLinePOS."Sale Type" of
              SaleLinePOS."Sale Type"::Sale,
              SaleLinePOS."Sale Type"::"Gift Voucher",
              SaleLinePOS."Sale Type"::"Credit Voucher",
              SaleLinePOS."Sale Type"::Deposit:
                InsertPOSSaleLine(SalePOS,SaleLinePOS, POSEntry, false, POSSalesLine);
              SaleLinePOS."Sale Type"::"Out payment":
                if SaleLinePOS.Type = SaleLinePOS.Type::"G/L Entry" then
                  InsertPOSSaleLine(SalePOS,SaleLinePOS, POSEntry, true, POSSalesLine)
                else
                  InsertPOSPaymentLine(SalePOS,SaleLinePOS, POSEntry, POSPaymentLine);
              SaleLinePOS."Sale Type"::Comment:
                ; //To-do Comments
              SaleLinePOS."Sale Type"::"Debit Sale":
                //-NPR5.48 [343578]
                //; //To do Debit sales
                // reversing an invoice from POS f.ex.
                InsertPOSSaleLine(SalePOS,SaleLinePOS, POSEntry, false, POSSalesLine);
                //+NPR5.48 [343578]
              SaleLinePOS."Sale Type"::"Open/Close":
                ; //To do Open / Close
              SaleLinePOS."Sale Type"::Payment:
                InsertPOSPaymentLine(SalePOS,SaleLinePOS, POSEntry, POSPaymentLine);
            end;
          until SaleLinePOS.Next = 0;
        end;
        //+NPR5.37 [294362]
    end;

    procedure CreatePOSEntryForCreatedSalesDocument(var SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header";Posted: Boolean)
    var
        POSPeriodRegister: Record "POS Period Register";
        POSEntry: Record "POS Entry";
        POSCreateEntry: Codeunit "POS Create Entry";
        POSEntryManagement: Codeunit "POS Entry Management";
        WasModified: Boolean;
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
        POSEntrySalesDocLinkMgt: Codeunit "POS Entry Sales Doc. Link Mgt.";
    begin
        //-NPR5.37 [294362]
        OnBeforeCreatePOSEntry(SalePOS);

        if not GetPOSPeriodRegister(SalePOS,POSPeriodRegister,true) then
          Error(ERR_NO_OPEN_UNIT,POSPeriodRegister.TableCaption,POSPeriodRegister.FieldCaption("POS Unit No."),SalePOS."Register No.");
        InsertPOSEntry(POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::"Credit Sale");
        CreateLines(POSEntry,SalePOS);

        POSEntryManagement.RecalculatePOSEntry(POSEntry,WasModified);

        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry."Sales Document Type" := SalesHeader."Document Type";
        POSEntry."Sales Document No." := SalesHeader."No.";
        //-NPR5.50 [300557]
        POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntry, SalesHeader."Document Type", SalesHeader."No.");
        if Posted then
          SetPostedSalesDocInfo(POSEntry, SalesHeader);
        //+NPR5.50 [300557]
        if POSEntry.Description =  '' then
          POSEntry.Description := StrSubstNo('%1 %2',SalesHeader."Document Type",SalesHeader."No.");
        POSEntry.Modify;

        //-NPR5.48 [318028]
        POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::CREDIT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", TXT_CREDIT_SALE_END, '');
        //+NPR5.48 [318028]

        OnAfterInsertPOSEntry(SalePOS,POSEntry);
    end;

    local procedure InsertPOSEntry(var POSPeriodRegister: Record "POS Period Register";var SalePOS: Record "Sale POS";var POSEntry: Record "POS Entry";EntryType: Option)
    var
        Contact: Record Contact;
        POSAuditRollIntegration: Codeunit "POS-Audit Roll Integration";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SaleLinePOS: Record "Sale Line POS";
    begin
        POSEntry.Init;
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
          if Contact.Get(CopyStr(SalePOS."Contact No.",1,MaxStrLen(Contact."No."))) then
            POSEntry."Contact No." := Contact."No.";
        POSEntry."Event No." := SalePOS."Event No.";  //NPR5.53 [376035]

        POSEntry."Shortcut Dimension 1 Code" := SalePOS."Shortcut Dimension 1 Code";
        POSEntry."Shortcut Dimension 2 Code" := SalePOS."Shortcut Dimension 2 Code";
        POSEntry."Dimension Set ID" := SalePOS."Dimension Set ID";
        POSEntry."POS Sale ID" := SalePOS."POS Sale ID";
        //-NPR5.50 [337539]
        POSEntry."Retail ID" := SalePOS."Retail ID";
        //+NPR5.50 [337539]
        //-NPR5.36 [279551]
        POSEntry."Starting Time" := SalePOS."Start Time";
        POSEntry."Ending Time" := Time;
        POSEntry."Posting Date" := SalePOS.Date;
        POSEntry."Document Date" := SalePOS.Date;
        POSEntry."Currency Code" := '';//All sales are in LCY for now (Payments can  be in FCY of course)
        //POSEntry."Customer Posting Group" := ;
        POSEntry."Country/Region Code" := SalePOS."Country Code";
        //POSEntry."Transaction Type" := ;
        //POSEntry."Transport Method" := ;
        //POSEntry."Exit Point" := ;
        POSEntry."Tax Area Code" := SalePOS."Tax Area Code";
        //POSEntry."Transaction Specification" := ;
        POSEntry."Prices Including VAT" := SalePOS."Prices Including VAT";
        //POSEntry."Reason Code" := ;
        //+NPR5.36 [279551]
        //-NPR5.40 [276562]
        //-NPR5.37 [294362]
        // IF POSEntry."Entry Type" = POSEntry."Entry Type"::Debitsale THEN BEGIN
        //  POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
        //  POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        // END;
        //+NPR5.37 [294362]
        //+NPR5.40 [276562]
        POSEntry."NPRE Number of Guests" := SalePOS."NPRE Number of Guests";  //NPR5.53 [380918]
        OnBeforeInsertPOSEntry(SalePOS,POSEntry);
        //-NPR5.38 [302693]
        if POSEntry.Description = '' then begin
          case POSEntry."Entry Type" of
            POSEntry."Entry Type"::"Direct Sale" :
              POSEntry.Description := CopyStr(StrSubstNo(TXT_SALES_TICKET,POSEntry."Document No."),1,MaxStrLen(POSEntry.Description));
            POSEntry."Entry Type"::Balancing :
              begin
                if (not SalespersonPurchaser.Get (SalePOS."Salesperson Code")) then
                  SalespersonPurchaser.Name := StrSubstNo ('%1: %2', SalespersonPurchaser.TableCaption, SalePOS."Salesperson Code");
                POSEntry.Description := SalespersonPurchaser.Name;
              end;
            //-NPR5.54 [347209]
            POSEntry."Entry Type"::"Cancelled Sale": begin  //NPR5.55 [391678] (BEGIN added)
              //-NPR5.55 [391678]
              SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
              SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
              if SaleLinePOS.FindFirst and (SaleLinePOS.Description <> '') then
                POSEntry.Description := SaleLinePOS.Description
              else
              //+NPR5.55 [391678]
                POSEntry.Description := CANCEL_SALE;
            end;  //NPR5.55 [391678]
            //+NPR5.54 [347209]
          end;
        end;
        //+NPR5.38 [302963]
        POSEntry.Insert;

        POSAuditRollIntegration.InsertAuditRollEntryLinkFromPOSEntry(POSEntry);
    end;

    local procedure InsertPOSSaleLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";POSEntry: Record "POS Entry";ReverseSign: Boolean;var POSSalesLine: Record "POS Sales Line")
    var
        POSSalesLine2: Record "POS Sales Line";
        GiftVoucher: Record "Gift Voucher";
        CreditVoucher: Record "Credit Voucher";
        PricesIncludeTax: Boolean;
        POSEntrySalesDocLinkMgt: Codeunit "POS Entry Sales Doc. Link Mgt.";
        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
    begin
        with POSSalesLine do begin
          Init;
          "POS Entry No." := POSEntry."Entry No.";
          "POS Period Register No." := POSEntry."POS Period Register No.";
          "Line No." := SaleLinePOS."Line No.";
          //-NPR5.37 [294052]
          SetRecFilter;
          if not IsEmpty then repeat
            "Line No." := "Line No." + 10000; //Ensure the line no. is not already taken
            SetRecFilter;
          until IsEmpty;
          Reset;
          //+NPR5.37 [294052]
          "POS Store Code" := SalePOS."POS Store Code";
          "POS Unit No." := SaleLinePOS."Register No.";
          "Document No." := SaleLinePOS."Sales Ticket No.";
          "Customer No." := SalePOS."Customer No.";
          "Salesperson Code" := SalePOS."Salesperson Code";

          case SaleLinePOS.Type of
            SaleLinePOS.Type::Item:
              Type := Type::Item;
            SaleLinePOS.Type::"G/L Entry":
              Type := Type::"G/L Account";
            else
              ;//Add silent error comment line
          end;
          case SaleLinePOS."Sale Type" of
            SaleLinePOS."Sale Type"::"Gift Voucher",
            //-NPR5.38 [294719]
            //SaleLinePOS."Sale Type"::"Out payment",  //Marked as Voucher because no VAT
            //+NPR5.38 [294719]
            SaleLinePOS."Sale Type"::"Credit Voucher":
              Type := Type::Voucher;
            SaleLinePOS."Sale Type"::Deposit:
              if SaleLinePOS.Type = SaleLinePOS.Type::Customer then
                Type := Type::Customer
              else
                Type := Type::Voucher;      //Marked as Voucher because no VA
            //-NPR5.38 [294719]
            SaleLinePOS."Sale Type"::"Out payment":
              //-NPR5.38 [302693]
              //Type := Type::"G/L Account";
              //-NPR5.39 [302803]
              //This is currently the only way to see the difference between a Rounding and a Payout line!
              if SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Rounding then
                Type := Type::Rounding
              else
              //+NPR5.39 [302803]
                //-NPR5.39 [305795]
                if SaleLinePOS."Gen. Posting Type" <> SaleLinePOS."Gen. Posting Type"::Purchase then
                  Type := Type::"G/L Account"
                else
                //+NPR5.39 [305795]
                  Type := Type::Payout;
              //+NPR5.38 [302693]
            //+NPR5.38 [294719]

          end;
          //-NPR5.51 [362329]
          "Exclude from Posting" := ExcludeFromPosting(SaleLinePOS);
          //+NPR5.51 [362329]
          //-NPR5.53 [379729]-revoked
        //  //-NPR5.52 [374750]
        //  IF NOT "Exclude from Posting" THEN
        //    "Exclude from Posting" := POSEntry."Entry Type" = POSEntry."Entry Type"::"Credit Sale";
        //  //+NPR5.52 [374750]
          //+NPR5.53 [379729]-revoked

          "No." := SaleLinePOS."No.";
          "Variant Code" := SaleLinePOS."Variant Code";
          "Location Code" := SaleLinePOS."Location Code";
          "Posting Group" := SaleLinePOS."Posting Group";
          Description := SaleLinePOS.Description;
          //Description 2?

          "Gen. Posting Type" := SaleLinePOS."Gen. Posting Type";
          "Gen. Bus. Posting Group" := SaleLinePOS."Gen. Bus. Posting Group";
          "VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
          "Gen. Prod. Posting Group" := SaleLinePOS."Gen. Prod. Posting Group";
          "VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
          "Tax Area Code" := SaleLinePOS."Tax Area Code";
          "Tax Liable" := SaleLinePOS."Tax Liable";
          "Tax Group Code" := SaleLinePOS."Tax Group Code";
          "Use Tax" := SaleLinePOS."Use Tax";

          "Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
          Quantity := SaleLinePOS.Quantity;
          "Quantity (Base)" := SaleLinePOS."Quantity (Base)";
          //-NPR5.48 [335967]
          "Qty. per Unit of Measure" := SaleLinePOS."Qty. per Unit of Measure";
          //+NPR5.48 [335967]

          "Unit Price" := SaleLinePOS."Unit Price";
          //-NPR5.45 [324395]
          //"Unit Cost (LCY)" := SaleLinePOS."Unit Price (LCY)"; //TODO: Needs renaming here.
          "Unit Cost (LCY)" := SaleLinePOS."Unit Cost (LCY)";
          //+NPR5.45 [324395]
          "Unit Cost" := SaleLinePOS."Unit Cost";
          "VAT %" := SaleLinePOS."VAT %";
          //-NPR5.41 [311309]
          "VAT Identifier" := SaleLinePOS."VAT Identifier";
          "VAT Calculation Type" := SaleLinePOS."VAT Calculation Type";
          //+NPR5.41 [311309]
          "Discount Type" := SaleLinePOS."Discount Type";
          "Discount Code" := SaleLinePOS."Discount Code";

          //-NPR5.39 [305139]
          "Discount Authorised by" := SaleLinePOS."Discount Authorised by";
          //+NPR5.39 [305139]
          //-NPR5.44 [321231]
          "Reason Code" := SaleLinePOS."Reason Code";
          //+NPR5.44 [321231]

          //-NPR5.43 [318660]
          "Line Discount %" := SaleLinePOS."Discount %";
          //+NPR5.43 [318660]

          //-NPR5.36 [279552]
          //"Line Discount Amount Excl. VAT" := SaleLinePOS."Discount %";
          //"Line Discount Amount Incl. VAT" := SaleLinePOS."Discount Amount";
          PricesIncludeTax := SalePOS."Prices Including VAT";
          if (SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::"Gift Voucher"]) then
            PricesIncludeTax := true;
          if PricesIncludeTax then begin
            "Line Discount Amount Incl. VAT" := SaleLinePOS."Discount Amount";
            "Line Discount Amount Excl. VAT" := SaleLinePOS."Discount Amount" / (1 + (SaleLinePOS."VAT %"/100)) ;
          end else begin
            "Line Discount Amount Excl. VAT" := SaleLinePOS."Discount Amount";
            "Line Discount Amount Incl. VAT" := (1 + (SaleLinePOS."VAT %"/100)) * SaleLinePOS."Discount Amount";
          end;
          //+NPR5.36 [279552]
          "Amount Excl. VAT" := SaleLinePOS.Amount;
          "Amount Incl. VAT" := SaleLinePOS."Amount Including VAT";
          "VAT Base Amount" := SaleLinePOS."VAT Base Amount";
          //-NPR5.48 [335967]
          "Line Amount" := SaleLinePOS."Line Amount";
          //+NPR5.48 [335967]

          //-NPR5.48 [338181]
          if ((SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment")
            and (SaleLinePOS."Discount Type" <> SaleLinePOS."Discount Type"::Rounding)) then
            "Line Amount" *= -1;
          //+NPR5.48 [338181]

          "Amount Excl. VAT (LCY)" := SaleLinePOS.Amount * POSEntry."Currency Factor";
          "Amount Incl. VAT (LCY)" := SaleLinePOS."Amount Including VAT" * POSEntry."Currency Factor";

          //-NPR5.39 [302803]
          "Line Dsc. Amt. Excl. VAT (LCY)" := "Line Discount Amount Excl. VAT" * POSEntry."Currency Factor";
          "Line Dsc. Amt. Incl. VAT (LCY)" := "Line Discount Amount Incl. VAT" * POSEntry."Currency Factor";
          //+NPR5.39 [302803]

          "Orig. POS Sale ID" := SaleLinePOS."Orig. POS Sale ID";
          "Orig. POS Line No." := SaleLinePOS."Orig. POS Line No.";
          //-NPR5.50 [337539]
          "Retail ID" := SaleLinePOS."Retail ID";
          //+NPR5.50 [337539]

          //TODO: Implement these and consider Item Group
          //-NPR5.41 [312575]
          POSSalesLine."Item Category Code" := SaleLinePOS."Item Category Code";
          POSSalesLine."Product Group Code" := SaleLinePOS."Product Group Code";
          //+NPR5.41 [312575]
          //POSSalesLine.Nonstock :=
          //POSSalesLine."BOM Item No." :=
          "Serial No." := SaleLinePOS."Serial No.";
          //-NPR5.52 [369231]
          "Retail Serial No." := SaleLinePOS."Serial No. not Created";
          //+NPR5.52 [369231]
          "Return Reason Code" := SaleLinePOS."Return Reason Code";
          "NPRE Seating Code" := SaleLinePOS."NPRE Seating Code";  //NPR5.53 [380918]
          //-NPR5.49 [342090]
          CreateRMAEntry (POSEntry, SalePOS, SaleLinePOS);
          //+NPR5.49 [342090]

          //-NPR5.50 [300557]
        //-NPR5.53 [373453]
          if SaleLinePOS."Sales Document No." <> '' then begin
            POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.");
          end;

          if SaleLinePOS."Posted Sales Document No." <> '' then begin
            case SaleLinePOS."Posted Sales Document Type" of
              SaleLinePOS."Posted Sales Document Type"::INVOICE :
                POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE, SaleLinePOS."Posted Sales Document No.");
              SaleLinePOS."Posted Sales Document Type"::CREDIT_MEMO :
                POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, POSEntrySalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO, SaleLinePOS."Posted Sales Document No.");
            end;
          end;

          if SaleLinePOS."Delivered Sales Document No." <> '' then begin
            case SaleLinePOS."Delivered Sales Document Type" of
              SaleLinePOS."Delivered Sales Document Type"::SHIPMENT :
                POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, POSEntrySalesDocLink."Sales Document Type"::SHIPMENT, SaleLinePOS."Delivered Sales Document No.");
              SaleLinePOS."Delivered Sales Document Type"::RETURN_RECEIPT :
                POSEntrySalesDocLinkMgt.InsertPOSSalesLineSalesDocReference(POSSalesLine, POSEntrySalesDocLink."Sales Document Type"::RETURN_RECEIPT, SaleLinePOS."Delivered Sales Document No.");
            end;
          end;
        //+NPR5.53 [373453]

          "Applies-to Doc. Type" := SaleLinePOS."Buffer Document Type";
          "Applies-to Doc. No." := SaleLinePOS."Buffer Document No.";
          //+NPR5.50 [300557]

          "Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
          "Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
          "Dimension Set ID" := SaleLinePOS."Dimension Set ID";

          //-NPR5.37 [293227]
          //-NPR5.38 [302693]
          if (SaleLinePOS."Sale Type" =  SaleLinePOS."Sale Type"::"Out payment") and
              (SaleLinePOS.Amount = 0) and (SaleLinePOS."Amount Including VAT" <> 0) then begin
              "Amount Excl. VAT" :=  "Amount Incl. VAT" /  (1 + ("VAT %"/100)) ;
              "Amount Excl. VAT (LCY)" := "Amount Incl. VAT (LCY)" / (1 + ("VAT %"/100)) ;
        //      //"Amount Incl. VAT" := SaleLinePOS.Quantity * SaleLinePOS."Unit Price";//remove
        //      //"Amount Incl. VAT (LCY)" := SaleLinePOS.Quantity * SaleLinePOS."Unit Price";
           end;
          //-NPR5.38 [302693]
          //-NPR5.37 [293227]

          if ReverseSign then begin
            Quantity := - Quantity;
            "Line Discount Amount Excl. VAT" := - "Line Discount Amount Excl. VAT";
            "Line Discount Amount Incl. VAT" := - "Line Discount Amount Incl. VAT";
            "Amount Excl. VAT" := - "Amount Excl. VAT";
            "Amount Incl. VAT" := - "Amount Incl. VAT";
            "Line Dsc. Amt. Excl. VAT (LCY)" := - "Line Dsc. Amt. Excl. VAT (LCY)";
            "Line Dsc. Amt. Incl. VAT (LCY)" := - "Line Dsc. Amt. Incl. VAT (LCY)";
            "Amount Excl. VAT (LCY)" := - "Amount Excl. VAT (LCY)";
            "Amount Incl. VAT (LCY)" := - "Amount Incl. VAT (LCY)";
            "VAT Base Amount" := - "VAT Base Amount";
            "Quantity (Base)" := - "Quantity (Base)";
            "VAT Difference" := - "VAT Difference";
          end;

          //-NPR5.38 [302766]
          if SaleLinePOS."Gift Voucher Ref." <> '' then begin
            GiftVoucher.Get(SaleLinePOS."Gift Voucher Ref.");
            GiftVoucher.CreateFromPOSSalesLine(POSSalesLine);
            GiftVoucher.Modify;
          end;
          if SaleLinePOS."Credit voucher ref." <> '' then begin
            CreditVoucher.Get(SaleLinePOS."Credit voucher ref.");
            CreditVoucher.CreateFromPOSSalesLine(POSSalesLine);
            CreditVoucher.Modify;
          end;
          //+NPR5.38 [302766]

          OnBeforeInsertPOSSalesLine(SalePOS,SaleLinePOS,POSEntry, POSSalesLine);
          Insert;
        end;
        OnAfterInsertPOSSalesLine(SalePOS,SaleLinePOS,POSEntry, POSSalesLine);
    end;

    local procedure InsertPOSPaymentLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";POSEntry: Record "POS Entry";var POSPaymentLine: Record "POS Payment Line")
    var
        POSPaymentMethod: Record "POS Payment Method";
        GiftVoucher: Record "Gift Voucher";
        CreditVoucher: Record "Credit Voucher";
    begin
        with POSPaymentLine do begin
          Init;
          "POS Entry No." := POSEntry."Entry No.";
          "POS Period Register No." := POSEntry."POS Period Register No.";
          "Line No." := SaleLinePOS."Line No.";
          //-NPR5.37 [294052]
          SetRecFilter;
          if not IsEmpty then repeat
            "Line No." := "Line No." + 10000; //Ensure the line no. is not already taken
            SetRecFilter;
          until IsEmpty;
          Reset;
          //+NPR5.37 [294052]
          "POS Store Code" := SalePOS."POS Store Code";
          "POS Unit No." := SaleLinePOS."Register No.";
          "Document No." := SaleLinePOS."Sales Ticket No.";
        //  CASE SaleLinePOS.Type OF
        //    SaleLinePOS.Type::Payment:
        //      BEGIN
                if not POSPaymentMethod.Get(SaleLinePOS."No.") then
                  CreatePOSPaymentMethod(SaleLinePOS,POSPaymentMethod);
                "POS Payment Method Code" := POSPaymentMethod.Code;
        //      END;
        //    ELSE
        //      ;//Add silent error comment line
        //  END;

          //-NPR5.40 [307267]
          //"POS Payment Bin Code" := "POS Unit No."; //POS Unit = POS Payment Bin default for now
          "POS Payment Bin Code" := SelectUnitBin ("POS Unit No.");
          //+NPR5.40 [307267]

        //-NPR5.54 [391871]
          "Retail ID" := SaleLinePOS."Retail ID";
        //+NPR5.54 [391871]

          Description := SaleLinePOS.Description;
          if SaleLinePOS."Currency Amount" <> 0 then begin
            Amount := SaleLinePOS."Currency Amount";
            "Payment Amount" := SaleLinePOS."Currency Amount";
          end else begin
            Amount := SaleLinePOS."Amount Including VAT";
            "Payment Amount" := SaleLinePOS."Amount Including VAT";
          end;
          "Amount (LCY)" := SaleLinePOS."Amount Including VAT";
          "Amount (Sales Currency)" := SaleLinePOS."Amount Including VAT"; //Sales Currency is always LCY for now
          "Currency Code" := POSPaymentMethod."Currency Code";


          "Orig. POS Sale ID" := SaleLinePOS."Orig. POS Sale ID";
          "Orig. POS Line No." := SaleLinePOS."Orig. POS Line No.";
          EFT := SaleLinePOS."EFT Approved";

          "Shortcut Dimension 1 Code" := SaleLinePOS."Shortcut Dimension 1 Code";
          "Shortcut Dimension 2 Code" := SaleLinePOS."Shortcut Dimension 2 Code";
          "Dimension Set ID" := SaleLinePOS."Dimension Set ID";
          //-NPR5.38 [294718]
          "Applies-to Doc. Type" := SaleLinePOS."Buffer Document Type";
          "Applies-to Doc. No." := SaleLinePOS."Buffer Document No.";
          //+NPR5.38 [294718]

          //-NPR5.38 [294720]
          "External Document No." := SaleLinePOS."External Document No.";
          //+NPR5.38 [294720]

          //-NPR5.37 [293711]
        //  IF SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::"Out payment" THEN BEGIN
        //    Amount := - Amount;
        //    "Amount (LCY)":= -"Amount (LCY)";
        //    "Payment Amount" := -"Payment Amount";
        //    "Amount (Sales Currency)" := - "Amount (Sales Currency)";
        //  END;
          //-NPR5.37 [293711]

          //-NPR5.38 [302766]
          if SaleLinePOS."Gift Voucher Ref." <> '' then begin
            GiftVoucher.Get(SaleLinePOS."Gift Voucher Ref.");
            GiftVoucher.LinkToPOSPaymentLine(POSPaymentLine);
            GiftVoucher.Modify;
          end;
          if SaleLinePOS."Credit voucher ref." <> '' then begin
            CreditVoucher.Get(SaleLinePOS."Credit voucher ref.");
            CreditVoucher.LinkToPOSPaymentLine(POSPaymentLine);
            CreditVoucher.Modify;
          end;
          //+NPR5.38 [302766]

          //-NPR5.50 [354832]
          "VAT Base Amount (LCY)"  := SaleLinePOS."Amount Including VAT";
          if (SaleLinePOS."VAT Base Amount" <> 0) then begin
            "VAT Amount (LCY)" := SaleLinePOS."Amount Including VAT" - SaleLinePOS."VAT Base Amount";
            "VAT Base Amount (LCY)" := SaleLinePOS."VAT Base Amount";
          end;

          "VAT Bus. Posting Group" := SaleLinePOS."VAT Bus. Posting Group";
          "VAT Prod. Posting Group" := SaleLinePOS."VAT Prod. Posting Group";
          //+NPR5.50 [354832]

          //-NPR5.40 [306858]
          CreatePaymentLineBinEntry (POSPaymentLine);
          //+NPR5.40 [306858]

          OnBeforeInsertPOSPaymentLine(SalePOS,SaleLinePOS,POSEntry, POSPaymentLine);
          Insert;
        end;
        OnAfterInsertPOSPaymentLine(SalePOS,SaleLinePOS,POSEntry, POSPaymentLine);
    end;

    local procedure InsertPOSBalancingLine(PaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";POSEntry: Record "POS Entry";var LineNo: Integer;IsBinTransfer: Boolean)
    var
        POSBalancingLine: Record "POS Balancing Line";
        POSPaymentBin: Record "POS Payment Bin";
        POSBinEntry: Record "POS Bin Entry";
        POSPaymentMethod: Record "POS Payment Method";
        Difference: Decimal;
    begin

        POSBalancingLine.Init ();
        POSBalancingLine."POS Entry No." := POSEntry."Entry No.";
        POSBalancingLine."Line No." := LineNo;
        POSBalancingLine.Description := StrSubstNo ('%1: %2 - %3', POSEntry.TableCaption, POSEntry."Entry No.", PaymentBinCheckpoint."Payment Method No.");

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
        if (POSPaymentMethod.Get (PaymentBinCheckpoint."Payment Method No.")) then
          POSBalancingLine."Currency Code" := POSPaymentMethod."Currency Code";

        POSBalancingLine."Calculated Amount" := PaymentBinCheckpoint."Calculated Amount Incl. Float" - PaymentBinCheckpoint."New Float Amount";
        POSBalancingLine."Balanced Amount" := PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."New Float Amount";
        POSBalancingLine."Balanced Diff. Amount" := PaymentBinCheckpoint."Calculated Amount Incl. Float" - PaymentBinCheckpoint."Counted Amount Incl. Float";
        POSBalancingLine."New Float Amount" := PaymentBinCheckpoint."New Float Amount";

        // TODO
        // POSBalancingLine."Calculated Quantity"
        // POSBalancingLine."Balanced Quantity"
        // POSBalancingLine."Balanced Diff. Quantity"
        // POSBalancingLine."Deposited Quantity"
        // POSBalancingLine."Closing Quantity"

        // Update CP Entry with Calculated amount (reveresed)
        POSBinEntry.Get (PaymentBinCheckpoint."Checkpoint Bin Entry No.");

        POSBinEntry."Bin Checkpoint Entry No." := PaymentBinCheckpoint."Entry No.";
        POSBinEntry."Transaction Currency Code" := PaymentBinCheckpoint."Currency Code";
        POSBinEntry."Transaction Amount" := PaymentBinCheckpoint."Calculated Amount Incl. Float" * -1;
        CalculateTransactionAmountLCY (POSBinEntry);
        POSBinEntry.Comment := 'Calculated Bin Content';

        //-NPR5.43 [311964]
        POSBinEntry."POS Store Code" := POSEntry."POS Store Code";
        //+NPR5.43 [311964]

        POSBinEntry.Modify ();
        // At this point the BIN sum should be zero

        // Confirming the different adjustments and counted, transfers etc
        InsertBinAdjustment (POSBinEntry, PaymentBinCheckpoint."Calculated Amount Incl. Float", 'Expected Count');

        // Difference will be negative when we are missing money
        Difference := (PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."Calculated Amount Incl. Float");
        if ((Difference <> 0) and (PaymentBinCheckpoint.Comment <> '')) then
          InsertBinDifference (POSBinEntry, (PaymentBinCheckpoint."Counted Amount Incl. Float" - PaymentBinCheckpoint."Calculated Amount Incl. Float"), PaymentBinCheckpoint.Comment);

        // Move to a different bin instruction ("The safe")
        if (PaymentBinCheckpoint."Move to Bin Amount" <> 0) then begin
          if (PaymentBinCheckpoint."Move to Bin Reference" = '') then begin
            PaymentBinCheckpoint."Move to Bin Reference" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
            PaymentBinCheckpoint.Modify ();
          end;
          PaymentBinCheckpoint.TestField ("Move to Bin Code");
          POSBalancingLine."Move-To Bin Code" := PaymentBinCheckpoint."Move to Bin Code";
          POSBalancingLine."Move-To Bin Amount" := PaymentBinCheckpoint."Move to Bin Amount";
          POSBalancingLine."Move-To Reference" := PaymentBinCheckpoint."Move to Bin Reference";
          InsertBinTransfer (POSBinEntry,
            PaymentBinCheckpoint."Move to Bin Code",
            PaymentBinCheckpoint."Move to Bin Amount",
            PaymentBinCheckpoint."Move to Bin Reference");
        end;

        // Move to a different bin instruction (The "BANK")
        if (PaymentBinCheckpoint."Bank Deposit Amount" <> 0) then begin
          if (PaymentBinCheckpoint."Bank Deposit Reference" = '') then begin
            PaymentBinCheckpoint."Bank Deposit Reference" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
            PaymentBinCheckpoint.Modify ();
          end;
          PaymentBinCheckpoint.TestField ("Bank Deposit Bin Code");
          POSBalancingLine."Deposit-To Bin Code" := PaymentBinCheckpoint."Bank Deposit Bin Code";
          POSBalancingLine."Deposit-To Bin Amount" := PaymentBinCheckpoint."Bank Deposit Amount";
          POSBalancingLine."Deposit-To Reference" := PaymentBinCheckpoint."Bank Deposit Reference";
          InsertBankTransfer (POSBinEntry,
            PaymentBinCheckpoint."Bank Deposit Bin Code",
            PaymentBinCheckpoint."Bank Deposit Amount",
            PaymentBinCheckpoint."Bank Deposit Reference");
        end;

        //-NPR5.43 [311964] When doing bin transfer we dont want to recalculate the float as it upset the EOD counting
        if (not IsBinTransfer) then begin
          // This is to remove the calculated float and get bin sum to zero. counted - transfers
          InsertBinAdjustment (POSBinEntry,
            (PaymentBinCheckpoint."Counted Amount Incl. Float"  - PaymentBinCheckpoint."Bank Deposit Amount" - PaymentBinCheckpoint."Move to Bin Amount") * -1,
            'Calculated Float');
          // At this point Bin Sum is zero

          // Adjust up with the current float amount
          InsertFloatEntry (POSBinEntry, PaymentBinCheckpoint."New Float Amount", 'New Float');
        end;

        OnBeforeInsertPOSBalanceLine (PaymentBinCheckpoint, POSEntry, POSBalancingLine);
        POSBalancingLine.Insert ();
    end;

    local procedure InsertBinTransfer(CheckpointEntry: Record "POS Bin Entry";TargetBinNo: Code[20];TransactionAmount: Decimal;Reference: Text[50])
    var
        POSBinEntry: Record "POS Bin Entry";
    begin

        // Withdrawl from source bin
        POSBinEntry.Init;
        POSBinEntry.TransferFields (CheckpointEntry);
        POSBinEntry."Entry No." := 0;

        //-NPR5.43 [311964]
        //POSBinEntry.Type  := POSBinEntry.Type::BIN_TRANSFER;
        POSBinEntry.Type  := POSBinEntry.Type::BIN_TRANSFER_OUT;
        //+NPR5.43 [311964]

        POSBinEntry."External Transaction No." := Reference;
        POSBinEntry.Comment := 'Transfer';
        POSBinEntry."Transaction Amount" := -1 * TransactionAmount;
        CalculateTransactionAmountLCY (POSBinEntry);

        POSBinEntry.Insert ();

        // Deposit to target bin
        POSBinEntry."Entry No." := 0;
        POSBinEntry."Payment Bin No." := TargetBinNo;
        //-NPR5.43 [311964]
        POSBinEntry.Type  := POSBinEntry.Type::BIN_TRANSFER_IN;
        //+NPR5.43 [311964]

        POSBinEntry."Transaction Amount" *= -1;
        POSBinEntry."Transaction Amount (LCY)" *= -1;

        POSBinEntry.Insert ();
    end;

    local procedure InsertBankTransfer(CheckpointEntry: Record "POS Bin Entry";TargetBinNo: Code[20];TransactionAmount: Decimal;Reference: Text[50])
    var
        POSBinEntry: Record "POS Bin Entry";
    begin

        POSBinEntry.Init;
        POSBinEntry.TransferFields (CheckpointEntry);
        POSBinEntry."Entry No." := 0;

        //-NPR5.43 [311964]
        //POSBinEntry.Type  := POSBinEntry.Type::BANK_TRANSFER;
        POSBinEntry.Type  := POSBinEntry.Type::BANK_TRANSFER_OUT;
        //+NPR5.43 [311964]

        POSBinEntry."External Transaction No." := Reference;
        POSBinEntry.Comment := 'Bank Transfer';
        POSBinEntry."Transaction Amount" := -1 * TransactionAmount;
        CalculateTransactionAmountLCY (POSBinEntry);

        POSBinEntry.Insert ();

        // Deposit to target bin
        POSBinEntry."Entry No." := 0;
        POSBinEntry."Payment Bin No." := TargetBinNo;
        //-NPR5.43 [311964]
        //POSBinEntry.Type  := POSBinEntry.Type::BANK_TRANSFER;
        POSBinEntry.Type  := POSBinEntry.Type::BANK_TRANSFER_IN;
        //+NPR5.43 [311964]

        POSBinEntry."Transaction Amount" *= -1;
        POSBinEntry."Transaction Amount (LCY)" *= -1;

        POSBinEntry.Insert ();
    end;

    local procedure InsertBinAdjustment(CheckpointBinEntry: Record "POS Bin Entry";TransactionAmount: Decimal;Comment: Text[50])
    var
        POSBinEntry: Record "POS Bin Entry";
    begin

        // Adjustment to bin
        POSBinEntry.Init;
        POSBinEntry.TransferFields (CheckpointBinEntry);
        POSBinEntry."Entry No." := 0;

        POSBinEntry.Type  := POSBinEntry.Type::ADJUSTMENT;
        POSBinEntry."Transaction Amount" := TransactionAmount;
        CalculateTransactionAmountLCY (POSBinEntry);
        POSBinEntry.Comment := Comment;

        POSBinEntry.Insert ();
    end;

    local procedure InsertBinDifference(CheckpointBinEntry: Record "POS Bin Entry";TransactionAmount: Decimal;Comment: Text[50])
    var
        POSBinEntry: Record "POS Bin Entry";
    begin

        // Adjustment to bin
        POSBinEntry.Init;
        POSBinEntry.TransferFields (CheckpointBinEntry);
        POSBinEntry."Entry No." := 0;

        POSBinEntry.Type  := POSBinEntry.Type::DIFFERENCE;
        POSBinEntry."Transaction Amount" := TransactionAmount;
        CalculateTransactionAmountLCY (POSBinEntry);
        POSBinEntry.Comment := Comment;

        POSBinEntry.Insert ();
    end;

    local procedure InsertFloatEntry(CheckpointBinEntry: Record "POS Bin Entry";TransactionAmount: Decimal;Comment: Text[50])
    var
        POSBinEntry: Record "POS Bin Entry";
    begin

        // Adjustment to bin
        if not IsActivated then
          exit;
        POSBinEntry.Init;
        POSBinEntry.TransferFields (CheckpointBinEntry);
        POSBinEntry."Entry No." := 0;

        POSBinEntry.Type  := POSBinEntry.Type::FLOAT;
        POSBinEntry."Transaction Amount" := TransactionAmount;
        CalculateTransactionAmountLCY (POSBinEntry);
        POSBinEntry.Comment := Comment;

        POSBinEntry.Insert ();
    end;

    procedure InsertUnitOpenEntry(POSUnitNo: Code[10];SalespersonCode: Code[10]) EntryNo: Integer
    var
        POSEntry: Record "POS Entry";
        POSLedgerRegister: Record "POS Period Register";
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
    begin
        if (not IsActivated) then
          exit (0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Login (With Open)');
        //-NPR5.51 [356076]
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::UNIT_OPEN, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SIGN_IN, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        //+NPR5.51 [356076]
    end;

    procedure InsertUnitLoginEntry(POSUnitNo: Code[10];SalespersonCode: Code[10]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.51 [356076]
        // IF IsActivated THEN
        //  CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Login');

        if (not IsActivated) then
          exit (0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Login');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SIGN_IN, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        //+NPR5.51 [356076]
    end;

    procedure InsertUnitCloseBeginEntry(POSUnitNo: Code[10];SalespersonCode: Code[10]) EntryNo: Integer
    begin
        if (not IsActivated) then
          exit (0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Close (Balancing Begin)');
    end;

    procedure InsertUnitCloseEndEntry(POSUnitNo: Code[10];SalespersonCode: Code[10]) EntryNo: Integer
    begin
        if (not IsActivated) then
          exit (0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Close (Balancing End)');
    end;

    procedure InsertUnitLogoutEntry(POSUnitNo: Code[10];SalespersonCode: Code[10]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.51 [356076]
        // IF IsActivated THEN
        //  CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Logout');

        if (not IsActivated) then
          exit (0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Logout');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SIGN_OUT, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        //+NPR5.51 [356076]
    end;

    procedure InsertUnitLockEntry(POSUnitNo: Code[10];SalespersonCode: Code[10]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.51 [356076]
        // IF IsActivated THEN
        //  CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Lock');

        if (not IsActivated) then
          exit (0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Lock');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::UNIT_LOCK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        //+NPR5.51 [356076]
    end;

    procedure InsertUnitUnlockEntry(POSUnitNo: Code[10];SalespersonCode: Code[10]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.51 [356076]
        // IF IsActivated THEN
        //  CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Unlock');

        if (not IsActivated) then
          exit (0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Unlock');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::UNIT_UNLOCK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        //+NPR5.51 [356076]
    end;

    procedure InsertBinOpenEntry(POSUnitNo: Code[10];SalespersonCode: Code[10])
    begin

        //-NPR5.38 [297087]
        if IsActivated then
          CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Bin Open');
    end;

    procedure InsertParkSaleEntry(POSUnitNo: Code[10];SalespersonCode: Code[10]) EntryNo: Integer
    var
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.51 [356076]
        // IF IsActivated THEN
        //  CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Park Sale');

        if (not IsActivated) then
          exit (0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Park Sale');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::SALE_PARK, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        //+NPR5.51 [356076]
    end;

    procedure InsertParkedSaleRetrievalEntry(POSUnitNo: Code[10];SalespersonCode: Code[10];ParkedSalesTicketNo: Code[20];NewSalesTicketNo: Code[20]) EntryNo: Integer
    var
        POSAuditLog: Record "POS Audit Log";
        POSEntry: Record "POS Entry";
        LoadQuoteMsg: Label 'Parked sales ticket No. %1 loaded as ticket No. %2';
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
    begin
        //-NPR5.55 [391678]
        if not IsActivated then
          exit(0);

        EntryNo := CreatePOSSystemEntry(POSUnitNo, SalespersonCode, '[System Event] Unit Retrieve Parked Sale');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntryExtended(
          POSEntry.RecordId, POSAuditLog."Action Type"::SALE_LOAD, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.",
          StrSubstNo(LoadQuoteMsg, ParkedSalesTicketNo, NewSalesTicketNo), '');
        //+NPR5.55 [391678]
    end;

    procedure InsertResumeSaleEntry(POSUnitNo: Code[10];SalespersonCode: Code[10];UnfinishedTicketNo: Code[20];NewSalesTicketNo: Code[20]) EntryNo: Integer
    var
        POSAuditLog: Record "POS Audit Log";
        POSEntry: Record "POS Entry";
        ResumeSaleMsg: Label 'Unfinished sales ticket No. %1 resumed as ticket No. %2';
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
    begin
        //-NPR5.55 [391678]
        if not IsActivated then
          exit(0);

        EntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, '[System Event] Unit Resume Sale');
        POSEntry.Get(EntryNo);
        POSAuditLogMgt.CreateEntryExtended(
          POSEntry.RecordId, POSAuditLog."Action Type"::SALE_LOAD, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.",
          StrSubstNo(ResumeSaleMsg, UnfinishedTicketNo, NewSalesTicketNo), '');
        //+NPR5.55 [391678]
    end;

    procedure InsertTransferLocation(POSUnitNo: Code[10];SalespersonCode: Code[10];OldDocumentNo: Code[20];NewDocumentNo: Code[20])
    var
        POSEntry: Record "POS Entry";
        CreatedEntryNo: Integer;
    begin

        //-NPR5.38 [302761]
        if IsActivated then
          CreatedEntryNo := CreatePOSSystemEntry (POSUnitNo, SalespersonCode, CopyStr(StrSubstNo('[System Event] %1 transferred to location receipt %2',OldDocumentNo,NewDocumentNo),1,MaxStrLen(POSEntry.Description)));
    end;

    local procedure CreatePOSSystemEntry(POSUnitNo: Code[10];SalespersonCode: Code[10];Description: Text[80]) EntryNo: Integer
    var
        POSEntry: Record "POS Entry";
        POSPeriodRegister: Record "POS Period Register";
    begin

        if (not GetPOSPeriodRegisterForPOSUnit (POSUnitNo, POSPeriodRegister, false)) then
          Error (ERR_NO_OPEN_UNIT, POSPeriodRegister.TableCaption, POSPeriodRegister.FieldCaption("POS Unit No."), POSUnitNo);

        POSEntry.Init;
        POSEntry."Entry No." := 0;
        POSEntry."Entry Type" := POSEntry."Entry Type"::Other;
        POSEntry."System Entry" := true;

        POSEntry."POS Period Register No." := POSPeriodRegister."No.";
        POSEntry."POS Store Code" := GetStoreNoForUnitNo (POSUnitNo);
        POSEntry."POS Unit No." := POSUnitNo;

        POSEntry."Entry Date" := Today;
        POSEntry."Starting Time" := Time;
        POSEntry."Ending Time" := Time;
        POSEntry."Salesperson Code" := SalespersonCode;

        POSEntry.Description := Description;
        POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";

        POSEntry.Insert ();

        exit (POSEntry."Entry No.");
    end;

    local procedure CreatePaymentLineBinEntry(POSPaymentLine: Record "POS Payment Line")
    var
        POSBinEntry: Record "POS Bin Entry";
    begin

        //-NPR5.40 [306858]
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

        //POSBinEntry."Accounting Period Code" := POSPaymentLine."POS Period Register No.";
        POSBinEntry."Transaction Date" := Today;
        POSBinEntry."Transaction Time" := Time;
        POSBinEntry."Transaction Amount" := POSPaymentLine.Amount;
        POSBinEntry."Transaction Currency Code" := POSPaymentLine."Currency Code";
        POSBinEntry."Transaction Amount (LCY)" := POSPaymentLine."Amount (LCY)";

        //- Legacy
        POSBinEntry."Payment Type Code" := POSPaymentLine."POS Payment Method Code";
        POSBinEntry."Register No." := POSPaymentLine."POS Unit No.";
        //+ Legacy

        POSBinEntry.Insert ();
        //+NPR5.40 [306858]
    end;

    local procedure CalculateTransactionAmountLCY(var POSBinEntry: Record "POS Bin Entry")
    var
        Currency: Record Currency;
        CurrencyFactor: Decimal;
        CurrExchRate: Record "Currency Exchange Rate";
        PaymentTypePOS: Record "Payment Type POS";
    begin

        POSBinEntry."Transaction Amount (LCY)" := POSBinEntry."Transaction Amount";

        if (POSBinEntry."Transaction Amount" = 0) then
          exit;

        if (POSBinEntry."Transaction Currency Code" = '') then
          exit;

        // ** Legacy Way
        if (not PaymentTypePOS.Get (POSBinEntry."Payment Type Code")) then
          exit;

        if (PaymentTypePOS."Fixed Rate" <> 0) then
          POSBinEntry."Transaction Amount (LCY)" := POSBinEntry."Transaction Amount" * PaymentTypePOS."Fixed Rate" / 100;

        if (PaymentTypePOS."Rounding Precision" = 0) then
          exit;

        POSBinEntry."Transaction Amount (LCY)" := Round (POSBinEntry."Transaction Amount (LCY)", PaymentTypePOS."Rounding Precision", '=');
        exit;

        // ** End Legacy

        // ** Future way
        // IF (NOT Currency.GET (CurrencyCode)) THEN
        //  EXIT;
        //
        // EXIT (ROUND (CurrExchRate.ExchangeAmtFCYToLCY (TransactionDate, CurrencyCode, Amount,
        //                                               1 / CurrExchRate.ExchangeRate (TransactionDate, CurrencyCode))));
    end;

    local procedure GetPOSPeriodRegister(var SalePOS: Record "Sale POS";var POSPeriodRegister: Record "POS Period Register";CheckOpen: Boolean): Boolean
    begin

        //-NPR5.38 [297087]
        exit (GetPOSPeriodRegisterForPOSUnit (SalePOS."Register No.", POSPeriodRegister, CheckOpen));

        // POSPeriodRegister.RESET;
        // POSPeriodRegister.SETRANGE("POS Unit No.",SalePOS."Register No.");
        // IF NOT POSPeriodRegister.FINDLAST THEN
        //  EXIT(FALSE);
        // IF CheckOpen THEN
        //  IF POSPeriodRegister.Status <> POSPeriodRegister.Status::OPEN THEN
        //    EXIT(FALSE);
        // EXIT(TRUE);
        //+NPR5.38 [297087]
    end;

    local procedure GetPOSPeriodRegisterForPOSUnit(var POSUnitNo: Code[10];var POSPeriodRegister: Record "POS Period Register";CheckOpen: Boolean): Boolean
    var
        POSOpenPOSUnit: Codeunit "POS Manage POS Unit";
    begin
        POSPeriodRegister.Reset;
        POSPeriodRegister.SetRange("POS Unit No.",POSUnitNo);
        if not POSPeriodRegister.FindLast then
          exit(false);
        if CheckOpen then
          if POSPeriodRegister.Status <> POSPeriodRegister.Status::OPEN then
            exit(false);
        exit(true);
    end;

    procedure CreateBalancingEntryAndLines(var SalePOS: Record "Sale POS";IntermediateEndOfDay: Boolean;WorkshiftEntryNo: Integer) EntryNo: Integer
    var
        POSPeriodRegister: Record "POS Period Register";
        PaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
        POSEntry: Record "POS Entry";
        LineNo: Integer;
        PaymentBinCheckpointUpdate: Record "POS Payment Bin Checkpoint";
        POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin

        PaymentBinCheckpoint.SetFilter ("Workshift Checkpoint Entry No.", '=%1', WorkshiftEntryNo);
        PaymentBinCheckpoint.SetFilter (Status, '=%1', PaymentBinCheckpoint.Status::WIP);
        //-NPR5.45 [322769]
        PaymentBinCheckpoint.SetFilter ("Include In Counting", '<>%1', PaymentBinCheckpoint."Include In Counting"::NO);
        //-NPR5.45 [322769]
        if (not PaymentBinCheckpoint.IsEmpty ()) then
          exit (0); // Still work to do before counting is completed

        PaymentBinCheckpoint.SetFilter (Status, '=%1', PaymentBinCheckpoint.Status::READY);
        if (PaymentBinCheckpoint.IsEmpty ()) then
          exit (0); // Nothing is ready to post

        PaymentBinCheckpoint.FindSet ();

        GetPOSPeriodRegister (SalePOS, POSPeriodRegister, false);

        //-NPR5.40 [306581] - refactored
        POSEntry.Init;

        //-NPR5.43 [311964]
        POSWorkshiftCheckpoint.Get (WorkshiftEntryNo);
        case POSWorkshiftCheckpoint.Type of
          POSWorkshiftCheckpoint.Type::XREPORT :
            begin
              InsertPOSEntry (POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::Other);
              POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
              POSEntry."System Entry" := true;
              IntermediateEndOfDay := true;
              POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
              POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
              POSEntry.Description := '[System Event] Intermediate End of Day.';
            end;

          POSWorkshiftCheckpoint.Type::ZREPORT :
            begin
              InsertPOSEntry (POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::Balancing);
              if (not SalespersonPurchaser.Get (SalePOS."Salesperson Code")) then
                SalespersonPurchaser.Name := StrSubstNo ('%1: %2', SalespersonPurchaser.TableCaption, SalePOS."Salesperson Code");
              POSEntry.Description := SalespersonPurchaser.Name;
            end;

          POSWorkshiftCheckpoint.Type::TRANSFER :
            begin
              InsertPOSEntry (POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::Other);
              POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
              POSEntry.Description := 'Bin Transfer';
              POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
              IntermediateEndOfDay := true;
            end;

          else
            exit;
        end;

        // xxxx
        // InsertPOSEntry (POSPeriodRegister, SalePOS, POSEntry, POSEntry."Entry Type"::Other);
        //
        // IF (IntermediateEndOfDay) THEN BEGIN
        //  POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
        //  POSEntry."System Entry" := TRUE;
        //  POSEntry."Post Entry Status" := POSEntry."Post Entry Status"::"Not To Be Posted";
        //  POSEntry."Post Item Entry Status" := POSEntry."Post Item Entry Status"::"Not To Be Posted";
        //  POSEntry.Description := '[System Event] Intermediate End of Day.';
        // END;
        //
        // IF (NOT IntermediateEndOfDay) THEN BEGIN
        //  POSEntry."Entry Type" := POSEntry."Entry Type"::Balancing;
        //  IF (NOT SalespersonPurchaser.GET (SalePOS."Salesperson Code")) THEN
        //    SalespersonPurchaser.Name := STRSUBSTNO ('%1: %2', SalespersonPurchaser.TABLECAPTION, SalePOS."Salesperson Code");
        //  POSEntry.Description := SalespersonPurchaser.Name;
        // END;
        //+NPR5.43 [311964]

        POSEntry.Modify ();

        POSWorkshiftCheckpoint.Get (WorkshiftEntryNo);
        POSWorkshiftCheckpoint.Open := IntermediateEndOfDay;
        POSWorkshiftCheckpoint."POS Entry No." := POSEntry."Entry No.";
        POSWorkshiftCheckpoint.Modify ();
        //+NPR5.40 [306581]

        //-NPR5.49 [348458]
        if (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::ZREPORT) then begin
          POSWorkshiftCheckpoint.Reset ();
          POSWorkshiftCheckpoint.SetFilter ("Consolidated With Entry No.", '=%1', WorkshiftEntryNo);
          if (not POSWorkshiftCheckpoint.IsEmpty ()) then
            POSWorkshiftCheckpoint.ModifyAll (Open, false);
        end;
        //+NPR5.49 [348458]

        LineNo := 10000;
        repeat
          //-NPR5.43 [311964]
          //InsertPOSBalancingLine (PaymentBinCheckpoint, POSEntry, LineNo);
          InsertPOSBalancingLine (PaymentBinCheckpoint, POSEntry, LineNo, (POSWorkshiftCheckpoint.Type = POSWorkshiftCheckpoint.Type::TRANSFER));
          //+NPR5.43 [311964]
          LineNo += 10000;
          PaymentBinCheckpointUpdate.Get (PaymentBinCheckpoint."Entry No.");
          PaymentBinCheckpointUpdate.Status := PaymentBinCheckpointUpdate.Status::TRANSFERED;
          PaymentBinCheckpointUpdate.Modify ();
        until (PaymentBinCheckpoint.Next () = 0);

        exit (POSEntry."Entry No.");
    end;

    local procedure CreatePOSPaymentMethod(var SaleLinePOS: Record "Sale Line POS";var POSPaymentMethod: Record "POS Payment Method"): Integer
    var
        PaymentTypePOS: Record "Payment Type POS";
        Currency: Record Currency;
    begin
        POSPaymentMethod.Init;
        POSPaymentMethod.Validate(Code,SaleLinePOS."No.");
        if not PaymentTypePOS.Get(SaleLinePOS."No.") then
          exit;
        case PaymentTypePOS."Processing Type" of
        //   ,Cash,Terminal Card,Manual Card,Other Credit Cards,Credit Voucher,Gift Voucher,Cash Terminal,Foreign Currency,Foreign Credit Voucher,Foreign Gift Voucher,
          //Debit sale,Invoice,Finance Agreement,Payout,DIBS,Point Card
          PaymentTypePOS."Processing Type"::" ":;
          PaymentTypePOS."Processing Type"::Cash:
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::CASH);
          PaymentTypePOS."Processing Type"::"Terminal Card" :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::EFT);
          PaymentTypePOS."Processing Type"::"Manual Card" :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::EFT);
          PaymentTypePOS."Processing Type"::"Other Credit Cards" :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::EFT);
          PaymentTypePOS."Processing Type"::"Credit Voucher" :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::VOUCHER);
          PaymentTypePOS."Processing Type"::"Gift Voucher" :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::VOUCHER);
          PaymentTypePOS."Processing Type"::EFT :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::EFT);
          PaymentTypePOS."Processing Type"::"Foreign Currency":
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::CASH);
          PaymentTypePOS."Processing Type"::"Foreign Credit Voucher"  :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::VOUCHER);
          PaymentTypePOS."Processing Type"::"Foreign Gift Voucher" :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::VOUCHER);
          PaymentTypePOS."Processing Type"::"Debit sale" :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::CUSTOMER);
          PaymentTypePOS."Processing Type"::Invoice :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::CUSTOMER);
          PaymentTypePOS."Processing Type"::"Finance Agreement" :
            ;//???  //POSPaymentMethod.VALIDATE("Processing Type",POSPaymentMethod."Processing Type"::VOUCHER);
          PaymentTypePOS."Processing Type"::Payout :
            POSPaymentMethod.Validate("Processing Type",POSPaymentMethod."Processing Type"::PAYOUT);
          PaymentTypePOS."Processing Type"::DIBS :
            ;//???  //POSPaymentMethod.VALIDATE("Processing Type",POSPaymentMethod."Processing Type"::VOUCHER);
          PaymentTypePOS."Processing Type"::"Point Card" :
            ;//???  //POSPaymentMethod.VALIDATE("Processing Type",POSPaymentMethod."Processing Type"::VOUCHER);
        end;
        if (PaymentTypePOS."Fixed Rate" <> 0) and (PaymentTypePOS."Fixed Rate" <> 1) then begin
          Clear(Currency);
          Currency.Init;
          if not Currency.Get(PaymentTypePOS."No.") then begin
            if not Currency.Get(CopyStr(PaymentTypePOS."No.",1,3)) then begin
              if not Currency.Get(CopyStr(PaymentTypePOS."No.",1,2)) then begin
                Currency.Init;
                Currency.Validate(Code,PaymentTypePOS."No.");
                Currency.Validate(Description,CopyStr(PaymentTypePOS.Description,1,MaxStrLen(Currency.Description)));
                Currency.Insert(true);
              end;
            end;
          end;
          POSPaymentMethod.Validate("Currency Code",Currency.Code);
        end;
        POSPaymentMethod."Rounding Precision" := POSPaymentMethod."Rounding Precision";
        POSPaymentMethod.Insert(true);

        //-NPR5.37 [294311]
        CreatePOSPostingSetup(POSPaymentMethod);
        //+NPR5.37 [294311]
    end;

    local procedure CreatePOSPostingSetup(var POSPaymentMethod: Record "POS Payment Method")
    var
        PaymentTypePOS: Record "Payment Type POS";
        POSPostingSetup: Record "POS Posting Setup";
        Register: Record Register;
        POSStore: Record "POS Store";
    begin
        //-NPR5.37 [294311]
        if not PaymentTypePOS.Get(POSPaymentMethod.Code) then
          exit;
        POSPostingSetup.Init;
        POSPostingSetup."POS Store Code" := '';
        POSPostingSetup."POS Payment Method Code" := POSPaymentMethod.Code;
        POSPostingSetup."POS Payment Bin Code" := '';
        case PaymentTypePOS."Account Type" of
          PaymentTypePOS."Account Type"::Bank :
            begin
              POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"Bank Account";
              POSPostingSetup."Account No." := PaymentTypePOS."Bank Acc. No.";
            end;
          PaymentTypePOS."Account Type"::Customer :
            begin
              POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::Customer;
              POSPostingSetup."Account No." := PaymentTypePOS."Customer No.";
            end;
          PaymentTypePOS."Account Type"::"G/L Account" :
            begin
              POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"G/L Account";
              POSPostingSetup."Account No." := PaymentTypePOS."G/L Account No.";
            end;
        end;
        if not POSPostingSetup.Find then
           POSPostingSetup.Insert(true);

        if Register.FindSet then repeat;
          if POSStore.Get(Register."Register No.") then begin
            POSPostingSetup."POS Store Code" := POSStore.Code;
            POSPostingSetup."Difference Account Type" :=  POSPostingSetup."Difference Account Type"::"G/L Account";
            POSPostingSetup."Difference Acc. No." := Register."Difference Account";
            POSPostingSetup."Difference Acc. No. (Neg)" := Register."Difference Account - Neg.";
            if not POSPostingSetup.Find then
              POSPostingSetup.Insert(true);
          end;
        //-NPR5.38 [302767]
        //UNTIL POSPostingSetup.NEXT  = 0;
        until Register.Next  = 0;
        //+NPR5.38 [302767]
        //+NPR5.37 [294311]
    end;

    local procedure CreateRMAEntry(POSEntry: Record "POS Entry";SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS")
    var
        PosRmaLine: Record "POS RMA Line";
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        POSAuditLog: Record "POS Audit Log";
    begin

        //-NPR5.49 [342090]
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
        PosRmaLine.Insert ();
        //+NPR5.49 [342090]

        //-NPR5.55 [393569]
        OnAfterInsertRmaEntry (PosRmaLine, POSEntry, SalePOS, SaleLinePOS);
        //+NPR5.55 [393569]

        //-NPR5.51 [356076]
        POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::ITEM_RMA, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", '',
          StrSubstNo('%1|%2|%3', PosRmaLine."Return Line No.", PosRmaLine."Sales Ticket No.", PosRmaLine."Return Reason Code"));
        //+NPR5.51 [356076]
    end;

    local procedure GetStoreNoForUnitNo(POSUnitNo: Code[10]): Code[10]
    var
        POSUnit: Record "POS Unit";
    begin

        if (POSUnit.Get (POSUnitNo)) then ;

        exit (POSUnit."POS Store Code");
    end;

    local procedure IsActivated(): Boolean
    var
        NPRetailSetup: Record "NP Retail Setup";
    begin

        //-NPR5.38 [297087]
        if not NPRetailSetup.Find then
          exit(false);
        exit(NPRetailSetup."Advanced POS Entries Activated");
    end;

    local procedure SelectUnitBin(UnitNo: Code[10]) BinNo: Code[10]
    var
        POSUnit: Record "POS Unit";
        POSUnittoBinRelation: Record "POS Unit to Bin Relation";
    begin

        POSUnit.Get (UnitNo);

        // TODO: Consider the UnitToBinRelation
        exit (POSUnit."Default POS Payment Bin");
    end;

    local procedure IsCancelledSale(SalePOS: Record "Sale POS"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.48 [318028]
        if SalePOS."Sale type" = SalePOS."Sale type"::Annullment then
          exit(true);
        //+NPR5.48 [318028]

        //-NPR5.40 [308457]
        SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Comment);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Cancelled);
        exit(not SaleLinePOS.IsEmpty);
        //+NPR5.40 [308457]
    end;

    local procedure IsUniqueDocumentNo(SalePOS: Record "Sale POS"): Boolean
    var
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.48 [318028]
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        exit(POSEntry.IsEmpty);
        //+NPR5.48 [318028]
    end;

    local procedure ValidateSaleHeader(SalePOS: Record "Sale POS")
    var
        POSEntry: Record "POS Entry";
    begin
        //-NPR5.48 [318028]
        SalePOS.TestField("Sales Ticket No.");
        if not IsUniqueDocumentNo(SalePOS) then
          Error(ERR_DOCUMENT_NO_CLASH, POSEntry.FieldCaption("Document No."), SalePOS."Sales Ticket No.", POSEntry.TableCaption);
        //+NPR5.48 [318028]
    end;

    local procedure FiscalNoCheck(var POSEntry: Record "POS Entry";SalePOS: Record "Sale POS")
    var
        POSUnit: Record "POS Unit";
        POSAuditProfile: Record "POS Audit Profile";
    begin
        //-NPR5.48 [318028]
        POSUnit.Get(POSEntry."POS Unit No.");
        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then begin
          FillFiscalNo(POSEntry, '', SalePOS.Date);
          exit;
        end;

        case POSEntry."Entry Type" of
          POSEntry."Entry Type"::"Direct Sale" :
            FillFiscalNo(POSEntry, POSAuditProfile."Sale Fiscal No. Series", SalePOS.Date);

          POSEntry."Entry Type"::"Cancelled Sale" :
            if POSAuditProfile."Fill Sale Fiscal No. On" = POSAuditProfile."Fill Sale Fiscal No. On"::All then
              FillFiscalNo(POSEntry, POSAuditProfile."Sale Fiscal No. Series", SalePOS.Date);

          POSEntry."Entry Type"::"Credit Sale" :
            FillFiscalNo(POSEntry, POSAuditProfile."Credit Sale Fiscal No. Series", SalePOS.Date);

          POSEntry."Entry Type"::Balancing :
            FillFiscalNo(POSEntry, POSAuditProfile."Balancing Fiscal No. Series", SalePOS.Date);
        end;
        //+NPR5.48 [318028]
    end;

    local procedure FillFiscalNo(var POSEntry: Record "POS Entry";NoSeriesCode: Code[10];NoSeriesDate: Date)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        POSAuditProfile: Record "POS Audit Profile";
        POSUnit: Record "POS Unit";
    begin
        //-NPR5.40 [308457]
        //-NPR5.48 [318028]
        // IF NoSeriesCode = '' THEN
        //  POSEntry."Fiscal No." := POSEntry."Document No."
        // ELSE
        //  POSEntry."Fiscal No." := NoSeriesManagement.GetNextNo(NoSeriesCode,NoSeriesDate,TRUE);
        if NoSeriesCode = '' then begin
          POSEntry."Fiscal No." := POSEntry."Document No.";
          //-NPR5.53 [373743]-revoked
          //Register.GET(POSEntry."POS Unit No.");
          //POSEntry."Fiscal No. Series" := Register."Sales Ticket Series";
          //+NPR5.53 [373743]-revoked
          //-NPR5.53 [373743]
          POSUnit.Get(POSEntry."POS Unit No.");
          POSUnit.TestField("POS Audit Profile");
          POSAuditProfile.Get(POSUnit."POS Audit Profile");
          POSEntry."Fiscal No. Series" := POSAuditProfile."Sales Ticket No. Series";
          //+NPR5.53 [373743]
        end else begin
          POSEntry."Fiscal No." := NoSeriesManagement.GetNextNo(NoSeriesCode,NoSeriesDate,true);
          POSEntry."Fiscal No. Series" := NoSeriesCode;
        end;
        //+NPR5.48 [318028]
        //+NPR5.40 [308457]
    end;

    local procedure SetPostedSalesDocInfo(var POSEntry: Record "POS Entry";var SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLinkMgt: Codeunit "POS Entry Sales Doc. Link Mgt.";
        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
        PostedDocumentNo: Code[20];
    begin
        //-NPR5.50 [300557]
        if not (SalesHeader.Ship or SalesHeader.Invoice or SalesHeader.Receive) then
          exit;

        if SalesHeader.Invoice then begin
          case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice :
              begin
                POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE;
                if SalesHeader."Last Posting No." <> '' then
                  PostedDocumentNo := SalesHeader."Last Posting No."
                else
                  PostedDocumentNo := SalesHeader."No.";
              end;
            SalesHeader."Document Type"::Order :
              begin
                POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE;
                PostedDocumentNo := SalesHeader."Last Posting No.";
              end;
            SalesHeader."Document Type"::"Credit Memo" :
              begin
                POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO;
                if SalesHeader."Last Posting No." <> '' then
                  PostedDocumentNo := SalesHeader."Last Posting No."
                else
                  PostedDocumentNo := SalesHeader."No.";
              end;
            SalesHeader."Document Type"::"Return Order" :
              begin
                POSEntrySalesDocLink."Sales Document Type" := POSEntrySalesDocLink."Sales Document Type"::POSTED_CREDIT_MEMO;
                PostedDocumentNo := SalesHeader."Last Posting No.";
              end;
          end;

          POSEntrySalesDocLinkMgt.InsertPOSEntrySalesDocReference(POSEntry, POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
          if POSEntry.Description = '' then
            POSEntry.Description := StrSubstNo('%1 %2', POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
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
          POSEntry.Description := StrSubstNo('%1 %2', POSEntrySalesDocLink."Sales Document Type", PostedDocumentNo);
        //+NPR5.50 [300557]
    end;

    procedure ExcludeFromPosting(SaleLinePOS: Record "Sale Line POS"): Boolean
    begin
        //-NPR5.51 [362329]
        if SaleLinePOS.Type in [SaleLinePOS.Type::Comment] then
          exit(true);

        exit(SaleLinePOS."Sale Type" in [SaleLinePOS."Sale Type"::Comment,SaleLinePOS."Sale Type"::"Debit Sale",SaleLinePOS."Sale Type"::"Open/Close"]);
        //+NPR5.51 [362329]
    end;

    local procedure "--"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePOSEntry(var SalePOS: Record "Sale POS")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSEntry(var SalePOS: Record "Sale POS";var POSEntry: Record "POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "Sale POS";var POSEntry: Record "POS Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSSalesLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";POSEntry: Record "POS Entry";var POSSalesLine: Record "POS Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSSalesLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";POSEntry: Record "POS Entry";var POSSalesLine: Record "POS Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSPaymentLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";POSEntry: Record "POS Entry";var POSPaymentLine: Record "POS Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPOSPaymentLine(SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS";POSEntry: Record "POS Entry";POSPaymentLine: Record "POS Payment Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPOSBalanceLine(POSPaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";POSEntry: Record "POS Entry";var POSBalancingLine: Record "POS Balancing Line")
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnAfterInsertRmaEntry(POSRMALine: Record "POS RMA Line";POSEntry: Record "POS Entry";SalePOS: Record "Sale POS";SaleLinePOS: Record "Sale Line POS")
    begin
        //-+NPR5.55 [393569]
    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateFindRecords', '', true, true)]
    local procedure OnNavigateFindRecords(var DocumentEntry: Record "Document Entry";DocNoFilter: Text;PostingDateFilter: Text)
    var
        POSEntry: Record "POS Entry";
        POSPeriodRegister: Record "POS Period Register";
        RecordCount: Integer;
    begin

        //-#NPR5.52 [367393]
        if (POSEntry.ReadPermission) then begin
          if not (POSEntry.SetCurrentKey (POSEntry."Document No."))  then ;
          POSEntry.Reset;
          POSEntry.SetFilter ("Document No.", DocNoFilter);
          POSEntry.SetFilter ("Posting Date", PostingDateFilter);
          RecordCount := InsertIntoDocEntry (DocumentEntry, DATABASE::"POS Entry", 0, CopyStr (DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count ());

          if (RecordCount = 0) then begin
            if not (POSEntry.SetCurrentKey (POSEntry."Fiscal No."))  then ;
            POSEntry.Reset;
            POSEntry.SetFilter ("Fiscal No.", DocNoFilter);
            POSEntry.SetFilter ("Posting Date", PostingDateFilter);
            RecordCount := InsertIntoDocEntry (DocumentEntry, DATABASE::"POS Entry", 1, CopyStr (DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count ());
          end;

          if (RecordCount = 0) then begin
            POSPeriodRegister.SetFilter ("Document No.", DocNoFilter);
            if (POSPeriodRegister.FindFirst ()) then begin
              POSEntry.Reset;
              POSEntry.SetFilter ("POS Period Register No.", '=%1', POSPeriodRegister."No.");
              POSEntry.SetFilter ("System Entry", '=%1', false);
              RecordCount := InsertIntoDocEntry (DocumentEntry, DATABASE::"POS Entry", 2, CopyStr (DocNoFilter, 1, 20), POSEntry.TableCaption, POSEntry.Count ());
            end;
          end;
        end;
        //+#NPR5.52 [367393]
    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateShowRecords', '', true, true)]
    local procedure OnNavigateShowRecords(TableID: Integer;DocNoFilter: Text;PostingDateFilter: Text;ItemTrackingSearch: Boolean)
    var
        POSEntry: Record "POS Entry";
        POSPeriodRegister: Record "POS Period Register";
        DocumentEntry: Record "Document Entry" temporary;
    begin

        //-#NPR5.52 [367393]
        if (TableID = DATABASE::"POS Entry") then begin

          OnNavigateFindRecords (DocumentEntry, DocNoFilter, PostingDateFilter);

          if (DocumentEntry."Document Type" = 0) then begin
            if not (POSEntry.SetCurrentKey (POSEntry."Document No."))  then ;
            POSEntry.SetFilter ("Document No.", DocumentEntry."Document No.");
          end;

          if (DocumentEntry."Document Type" = 1) then begin
            if not (POSEntry.SetCurrentKey (POSEntry."Fiscal No."))  then ;
            POSEntry.SetFilter ("Fiscal No.", DocumentEntry."Document No.");
          end;

          if (DocumentEntry."Document Type" = 2) then begin
            POSPeriodRegister.SetFilter ("Document No.", DocumentEntry."Document No.");
            if (POSPeriodRegister.FindFirst ()) then begin
              POSEntry.SetFilter ("POS Period Register No.", '=%1', POSPeriodRegister."No.");
              POSEntry.SetFilter ("System Entry", '=%1', false);
            end;
          end;

          if (DocumentEntry."No. of Records" = 1) then
            PAGE.Run (PAGE::"POS Entry List", POSEntry)
          else
            PAGE.Run (0, POSEntry);

        end;
        //+#NPR5.52 [367393]
    end;

    local procedure InsertIntoDocEntry(var DocumentEntry: Record "Document Entry" temporary;DocTableID: Integer;DocType: Integer;DocNoFilter: Code[20];DocTableName: Text[1024];DocNoOfRecords: Integer): Integer
    begin

        //-#NPR5.52 [367393]
        if (DocNoOfRecords = 0) then
          exit (DocNoOfRecords);

        with DocumentEntry do begin
          Init;
          "Entry No." := "Entry No." + 1;
          "Table ID" := DocTableID;
          "Document Type" := DocType;
          "Document No." := DocNoFilter;
          "Table Name" := CopyStr(DocTableName,1,MaxStrLen("Table Name"));
          "No. of Records" := DocNoOfRecords;
          Insert;
        end;

        exit (DocNoOfRecords);
        //+#NPR5.52 [367393]
    end;
}

