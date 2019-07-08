codeunit 6014406 "Retail Sales Doc. Imp. Mgt."
{
    // Retail Sales Doc Imp. Mgt.
    //  Work started by Nicolai Esbensen.
    //  The purpose of the module is to provide functionality for importing sales
    //  documents to the POS.
    // 
    //  The Codeunit should only be invoked from the POS system the an active
    //  Sale POS record. All functionality can be invoked through the codeunit
    //  run method. The Parameters field of the Sale POS record functions as the
    //  function identifier.
    // 
    //  Current function identifiers and their purpose are listed below.
    // --------------------------------------------------------
    //  'IMPORT_SALESQUOTE'
    //   Imports a Sales Qoute into the active Sale on the register.
    // 
    //  'IMPORT_SALESINVOICE'
    //   Imports a Sales Invoice into the active Sale on the register.
    // 
    //  'IMPORT_SALESORDER'
    //   Imports a Sales Order into the active Sale on the register.
    // 
    //  'IMPORT_CREDITMEMO'
    //   Imports a Credite Memo into the active Sale on the register. All signs will be reversed.
    // 
    //  'IMPORT_RETURNORDER'
    //   Imports a Return Order into the active Sale on the register. All signs will be reversed.
    // 
    //  'IMPORT_SO_AMT'
    //  Imports the sales order amount to the POS
    // 
    //  'IMPORT_ORD_TYPE?xx'
    //  Set the "Order Type" for the sales documents to filter on
    // 
    // NPR4.14/RMT/20150826 CASE 216519 Added new meta trigger IMPORT_SO_AMT and IMPORT_ORD_TYPE?xx
    //                                     Parameter available for trigger
    // NPR5.32/ANEN /20170315  CASE 268218  Adding fcn. SetOrderType (global to be set from outside).
    // NPR5.32/ANEN /20170320  CASE 268218  Adding fcn. SetDeleteDocumentOnImport (global to be set from outside)
    //                                       and function to support it.
    // 
    // NPR5.34/JC  /20170620  CASE 279215 Only for open orders and new trigger IMPORT_SALESORDER_DEL
    // NPR5.40/TJ  /20180221  CASE 305414 Summing prepayment amounts when importing sales order
    // NPR5.48/MMV /20181113 CASE 300557 Added prepayment and helper functions.
    // NPR5.48/JDH /20181206 CASE 335967 Validating Unit of measure with correct value
    // NPR5.50/MMV /20190321 CASE 300557 Refactored.
    // NPR5.50/MMV /20190606 CASE 352473 Correct sign on return sales document amounts.

    TableNo = "Sale POS";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        OrderTypeText: Text;
    begin
        case true of
          StrPos(Parameters,'IMPORT_SALESQUOTE')>0:
            begin
              DocumentType := DocumentType::Quote;
              SalesDocumentToPOSLegacy(Rec, DocumentType);
             end;
          StrPos(Parameters,'IMPORT_SALESINVOICE')>0:
            begin
              DocumentType := DocumentType::Invoice;
              SalesDocumentToPOSLegacy(Rec, DocumentType);
            end;
          StrPos(Parameters,'IMPORT_SALESORDER_DEL')>0:
            begin
              DocumentType := DocumentType::Order;
              SetDeleteDocumentOnImport(true, false);
              SalesDocumentToPOSLegacy(Rec, DocumentType);
            end;
          StrPos(Parameters,'IMPORT_SALESORDER')>0:
            begin
              DocumentType := DocumentType::Order;
              SalesDocumentToPOSLegacy(Rec, DocumentType);
            end;
          StrPos(Parameters,'IMPORT_CREDITMEMO')>0:
            begin
              DocumentType := DocumentType::"Credit Memo";
              SalesDocumentToPOSLegacy(Rec, DocumentType);
            end;
          StrPos(Parameters,'IMPORT_RETURNORDER')>0:
            begin
              DocumentType := DocumentType::"Return Order";
              SalesDocumentToPOSLegacy(Rec, DocumentType);
            end;
          StrPos(Parameters,'IMPORT_SO_AMT')>0:
            begin
              DocumentType := DocumentType::Order;
              SalesDocumentAmountToPOSLegacy(Rec, DocumentType);
            end;
          StrPos(Parameters,'IMPORT_ORD_TYPE')>0:
            begin
              OrderTypeSet := true;
              OrderTypeText := CopyStr(Parameters,StrLen('IMPORT_ORD_TYPE?')+1);
              if OrderTypeText<>'' then
                Evaluate(OrderType,OrderTypeText)
              else
                OrderType := 0;
            end;
          else
            Error('')
        end;
    end;

    var
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        Text001: Label 'Remaining Amount for %1 %2';
        Text002: Label 'Received from %1 %2';
        OrderType: Integer;
        OrderTypeSet: Boolean;
        ERRORDERTYPE: Label 'Wrong Order Type. Order Type is set to %1. It must be one of %2, %3, %4.';
        DeleteDocumentOnImportToPOS: Boolean;
        ConfirmDeleteDocumentOnImportToPOS: Boolean;
        TextConfDocDelete: Label 'Do you want to delete existing %1 - %2 ?';
        TextMsgDocDelete: Label 'Please note that %1 %2 has been deleted';
        PREPAYMENT: Label 'Prepayment for %1 %2';
        ERR_DUPLICATE_DOCUMENT: Label 'Only one sales document can be processed per sale.';
        DOCUMENT_IMPORTED: Label '%1 %2 was imported in POS. The document has been deleted.';
        ERR_DOCUMENT_POSTED_LINE: Label '%1 %2 has partially posted lines. Aborting action.';

    procedure SalesDocumentToPOSLegacy(var SalePOS: Record "Sale POS";DocumentTypeIn: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SaleLinePOS: Record "Sale Line POS";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        SalesList: Page "Sales List";
        LineNo: Integer;
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
    begin
        //SalesDocumentToPOS
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,SalePOS.Date);
        if SaleLinePOS.FindLast then
          LineNo := SaleLinePOS."Line No." + 10000
        else
          LineNo := 10000;

        //-NPR5.48 [300557]
        // SaleLinePOS.SETFILTER("Buffer Document No.",'<>%1','');
        // IF SaleLinePOS.FINDSET THEN
        //  ERROR(ErrDoubleOrder);
        if DocumentIsAttachedToPOSSale(SalePOS) then
          Error(ERR_DUPLICATE_DOCUMENT);
        //+NPR5.48 [300557]

        SalesHeader.SetRange("Document Type",DocumentTypeIn);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);
        if OrderTypeSet then
          SalesHeader.SetRange("Order Type",OrderType);

        SalesList.SetTableView(SalesHeader);
        SalesList.LookupMode(true);
        if SalesList.RunModal <> ACTION::LookupOK then
          exit
        else
         SalesList.GetRecord(SalesHeader);

        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");

        if SalesHeader."Sell-to Customer No." <> '' then
          SalePOS.Validate("Customer No.",SalesHeader."Sell-to Customer No.");

        SalePOS."Sales Document Type" := SalesHeader."Document Type";
        SalePOS."Sales Document No."  := SalesHeader."No.";
        SalePOS.Validate("Price including VAT",SalesHeader."Prices Including VAT");
        SalePOS.Validate("Location Code", SalesHeader."Location Code");
        SalePOS.Modify;

        if SalesLine.FindSet then repeat
          SalesLine.TestField("Qty. Shipped Not Invoiced",0);
          SalesLine.TestField("Return Qty. Received",0);
          SaleLinePOS.Init;
          SaleLinePOS.Silent := true;
          SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
          SaleLinePOS.Validate("Sales Ticket No.", SalePOS."Sales Ticket No.");
          SaleLinePOS.Validate(Date,SalePOS.Date);

          case SalesLine.Type of
            SalesLine.Type::Item :
              begin
                SaleLinePOS.Type := SaleLinePOS.Type::Item;
                SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
              end;
            SalesLine.Type::" " :
              begin
                SaleLinePOS.Type        := SaleLinePOS.Type::Comment;
                SaleLinePOS.Description := SalesLine.Description;
              end;
          end;

          if SaleLinePOS.Type <> SaleLinePOS.Type::Comment then
            SaleLinePOS.Validate("No.",SalesLine."No.");

          SaleLinePOS.Description               := SalesLine.Description;
        //-NPR5.50 [300557]
        //  SaleLinePOS."Buffer Ref. No."         := SalesLine."Line No.";
        //  SaleLinePOS."Buffer Document Type"    := SalesLine."Document Type";
        //  SaleLinePOS."Buffer Document No."     := SalesLine."Document No.";
        //-NPR5.50 [300557]
          SaleLinePOS."Description 2"           := SalesLine."Description 2";
          SaleLinePOS."Variant Code"            := SalesLine."Variant Code";
          SaleLinePOS."Line No."                := LineNo;
          SaleLinePOS."Order No. from Web"      := SalesLine."Document No.";
          SaleLinePOS."Order Line No. from Web" := SalesLine."Line No.";

          if SaleLinePOS.Type = SaleLinePOS.Type::Item then
            //-NPR5.48 [335967]
            //SaleLinePOS.VALIDATE("Unit of Measure Code");
            SaleLinePOS.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
            //+NPR5.48 [335967]

          SaleLinePOS.Insert(true);
          SaleLinePOS.Silent := false;

          if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order",SalesHeader."Document Type"::"Credit Memo"] then
            SaleLinePOS.Validate(Quantity,-SalesLine.Quantity)
          else
            SaleLinePOS.Validate(Quantity,SalesLine.Quantity);

          SaleLinePOS.Validate("Unit Price",SalesLine."Unit Price");

          SaleLinePOS."Bin Code"      := SalesLine."Bin Code";
          SaleLinePOS."Location Code" := SalesLine."Location Code";
          SaleLinePOS."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
          SaleLinePOS."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";

          SaleLinePOS.Validate("Discount Type", SalesLine."Discount Type");
          SaleLinePOS.Validate("Discount Code", SalesLine."Discount Code");

          SaleLinePOS.Validate("Allow Line Discount", SalesLine."Allow Line Disc.");
          SaleLinePOS.Validate("Discount %", SalesLine."Line Discount %");
          SaleLinePOS.Validate("Discount Amount", SalesLine."Line Discount Amount");

          SaleLinePOS.Validate("Allow Invoice Discount", SalesLine."Allow Invoice Disc.");
          SaleLinePOS.Validate("Invoice Discount Amount", SalesLine."Inv. Discount Amount");
          SaleLinePOS.Modify;
          LineNo += 10000;
        until SalesLine.Next = 0;

        //-NPR5.32 [268218]
        if DeleteDocumentOnImportToPOS then begin
          if ConfirmDeleteDocumentOnImportToPOS then begin
            if Confirm(TextConfDocDelete, true, SalesHeader."Document Type", SalesHeader."No.") then  begin
              SalesHeader.Delete( true );
              SalePOS."Sales Document Type" := 0;
              SalePOS."Sales Document No."  := '';
              SalePOS.Modify;
            end;
          end else begin
            //-NPR5.34
            Message(StrSubstNo(TextMsgDocDelete, SalesHeader."Document Type", SalesHeader."No."));
            //+NPR5.34
            SalesHeader.Delete( true );
            SalePOS."Sales Document Type" := 0;
            SalePOS."Sales Document No."  := '';
            SalePOS.Modify;
          end;
        end;
        //+NPR5.32 [268218]
    end;

    procedure SalesDocumentAmountToPOSLegacy(var SalePOS: Record "Sale POS";DocumentTypeIn: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SaleLinePOS: Record "Sale Line POS";
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        SalesList: Page "Sales List";
        PaymentAmount: Decimal;
        LineNo: Integer;
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
        PrepaymentAmount: Decimal;
        ReceivedFromSaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR4.14
        SaleLinePOS.SetCurrentKey("Register No.","Sales Ticket No.","Line No.");
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast then
          LineNo := SaleLinePOS."Line No." + 10000
        else
          LineNo := 10000;

        //-NPR5.48 [300557]
        // SaleLinePOS.SETFILTER("Buffer Document No.",'<>%1','');
        // IF SaleLinePOS.FINDSET THEN
        //  ERROR(ErrDoubleOrder);
        if DocumentIsAttachedToPOSSale(SalePOS) then
          Error(ERR_DUPLICATE_DOCUMENT);
        //+NPR5.48 [300557]

        SalesHeader.SetRange("Document Type",DocumentTypeIn);
        if OrderTypeSet then
          SalesHeader.SetRange("Order Type",OrderType);
        SalesList.SetTableView(SalesHeader);
        SalesList.LookupMode(true);
        if SalesList.RunModal <> ACTION::LookupOK then
          exit
        else
         SalesList.GetRecord(SalesHeader);

        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");

        SalePOS.Validate("Customer No.",SalesHeader."Bill-to Customer No.");
        SalePOS."Sales Document Type" := SalesHeader."Document Type";
        SalePOS."Sales Document No."  := SalesHeader."No.";
        SalePOS.Validate("Price including VAT",SalesHeader."Prices Including VAT");
        SalePOS.Validate("Location Code", SalesHeader."Location Code");
        SalePOS.Modify;

        if SalesLine.FindSet then begin
          SaleLinePOS.Init;
          SaleLinePOS."Register No."     := SalePOS."Register No.";
          SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
          SaleLinePOS."Line No."         := LineNo;
          SaleLinePOS."Sale Type"        := SaleLinePOS."Sale Type"::Comment;
          SaleLinePOS.Type               := SaleLinePOS.Type::Comment;
          SaleLinePOS.Date               := SalePOS.Date;
          SaleLinePOS.Description := StrSubstNo(Text002,SalesHeader."Document Type",SalesHeader."No.") + ':';
          SaleLinePOS.Validate(Quantity,1);
          SaleLinePOS.Insert(true);
          //-NPR5.40 [305414]
          ReceivedFromSaleLinePOS := SaleLinePOS;
          //+NPR5.40 [305414]
          LineNo += 10000;
          repeat
            SalesLine.TestField("Qty. Shipped Not Invoiced",0);
            SalesLine.TestField("Return Qty. Received",0);
            SaleLinePOS.Init;
            SaleLinePOS.Silent := true;
            SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
            SaleLinePOS.Validate("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.Validate(Date,SalePOS.Date);
            SaleLinePOS.Type                      := SaleLinePOS.Type::Comment;
            SaleLinePOS.Description               := SalesLine.Description;
        //-NPR5.50 [300557]
        //    SaleLinePOS."Buffer Ref. No."         := SalesLine."Line No.";
        //    SaleLinePOS."Buffer Document Type"    := SalesLine."Document Type";
        //    SaleLinePOS."Buffer Document No."     := SalesLine."Document No.";
        //+NPR5.50 [300557]
            SaleLinePOS."Description 2"           := SalesLine."Description 2";
            SaleLinePOS."Variant Code"            := SalesLine."Variant Code";
            SaleLinePOS."Line No."                := LineNo;
            SaleLinePOS."Order No. from Web"      := SalesLine."Document No.";
            SaleLinePOS."Order Line No. from Web" := SalesLine."Line No.";
            SaleLinePOS.Validate(Quantity, SalesLine.Quantity);
            SaleLinePOS.Insert(true);
            SaleLinePOS.Type                      := SaleLinePOS.Type::Comment;
            SaleLinePOS.Silent := false;
            SaleLinePOS.Validate("Unit Price", SalesLine."Unit Price");
            SaleLinePOS."Bin Code"      := SalesLine."Bin Code";
            SaleLinePOS."Location Code" := SalesLine."Location Code";
            SaleLinePOS."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
            SaleLinePOS."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
            SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
            SaleLinePOS."Sales Document No." := SalesHeader."No.";
            SaleLinePOS.Modify;
            LineNo += 10000;
            PaymentAmount := PaymentAmount + (SalesLine."Amount Including VAT"-SalesLine."Prepmt. Amount Inv. Incl. VAT");
            //-NPR5.40 [305414]
            PrepaymentAmount += SalesLine."Prepmt. Amount Inv. Incl. VAT";
            //+NPR5.40 [305414]
          until SalesLine.Next = 0;
          //-NPR5.40 [305414]
          if PrepaymentAmount <> 0 then begin
            ReceivedFromSaleLinePOS.Validate("Unit Price",PrepaymentAmount);
            ReceivedFromSaleLinePOS.Modify(true);
          end;
          //+NPR5.40 [305414]
        end;

        if PaymentAmount<>0 then begin
          SaleLinePOS.Init;
          SaleLinePOS."Register No."     := SalePOS."Register No.";
          SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
          SaleLinePOS.Date               := SalePOS.Date;
          SaleLinePOS."Sale Type"        := SaleLinePOS."Sale Type"::Deposit;
          SaleLinePOS."Line No."         := SaleLinePOS."Line No."+1;
          SaleLinePOS.Type               := SaleLinePOS.Type::Customer;
          SaleLinePOS.Date               := SalePOS.Date;
          SaleLinePOS.Insert(true);
          SalePOS.Validate("Customer No.",SalesHeader."Bill-to Customer No.");
          SaleLinePOS.Validate(Quantity,1);
          SaleLinePOS.Validate( "No.",SalesHeader."Bill-to Customer No.");
          SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
          SaleLinePOS."Sales Document No." := SalesHeader."No.";
          SaleLinePOS."Sales Document Invoice" := true;
          SaleLinePOS."Sales Document Ship" := true;
          SaleLinePOS.Validate("Unit Price",PaymentAmount);
          SaleLinePOS.Description := StrSubstNo(Text001,SalesHeader."Document Type",SalesHeader."No.");
          SaleLinePOS.Modify(true);
        end;
        //+NPR4.14

        //-NPR5.32 [268218]
        if DeleteDocumentOnImportToPOS then begin
          if ConfirmDeleteDocumentOnImportToPOS then begin
            if Confirm(TextConfDocDelete, true, SalesHeader."Document Type", SalesHeader."No.") then SalesHeader.Delete( true );
          end else begin
            //-NPR5.34 [279215]
            Message(StrSubstNo(TextMsgDocDelete, SalesHeader."Document Type", SalesHeader."No."));
            //+NPR5.34
            SalesHeader.Delete( true );
          end;
        end;
        //+NPR5.32 [268218]
    end;

    procedure SalesDocumentToPOS(var POSSession: Codeunit "POS Session";var SalesHeader: Record "Sales Header")
    var
        SaleLinePOS: Record "Sale Line POS";
        SalesLine: Record "Sales Line";
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
    begin
        //-NPR5.50 [300557]
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
        SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");

        if DocumentIsAttachedToPOSSale(SalePOS) then
          Error(ERR_DUPLICATE_DOCUMENT);

        if DocumentIsPartiallyPosted(SalesHeader) then
          Error(ERR_DOCUMENT_POSTED_LINE, SalesHeader."Document Type", SalesHeader."No.");

        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetFilter(Type, '%1|%2', SalesLine.Type::Item, SalesLine.Type::" ");
        SalesLine.FindSet;

        repeat
          POSSaleLine.GetNewSaleLine(SaleLinePOS);

          SaleLinePOS.Silent := true;

          case SalesLine.Type of
            SalesLine.Type::Item :
              begin
                SaleLinePOS.Type := SaleLinePOS.Type::Item;
                SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
                SaleLinePOS.Validate("No.",SalesLine."No.");
                SaleLinePOS.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
              end;
            SalesLine.Type::" " :
              begin
                SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                SaleLinePOS.Description := SalesLine.Description;
              end;
          end;

          SaleLinePOS.Silent := false;

          SaleLinePOS.Description := SalesLine.Description;
          SaleLinePOS."Description 2" := SalesLine."Description 2";
          SaleLinePOS."Variant Code" := SalesLine."Variant Code";

          if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order",SalesHeader."Document Type"::"Credit Memo"] then
            SaleLinePOS.Validate(Quantity,-SalesLine.Quantity)
          else
            SaleLinePOS.Validate(Quantity,SalesLine.Quantity);

          SaleLinePOS.Validate("Unit Price", SalesLine."Unit Price");
          SaleLinePOS."Bin Code" := SalesLine."Bin Code";
          SaleLinePOS."Location Code" := SalesLine."Location Code";
          SaleLinePOS."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
          SaleLinePOS."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
          SaleLinePOS.Validate("Discount Type", SalesLine."Discount Type");
          SaleLinePOS.Validate("Discount Code", SalesLine."Discount Code");
          SaleLinePOS.Validate("Allow Line Discount", SalesLine."Allow Line Disc.");
          SaleLinePOS.Validate("Discount %", SalesLine."Line Discount %");
          SaleLinePOS.Validate("Discount Amount", SalesLine."Line Discount Amount");
          SaleLinePOS.Validate("Allow Invoice Discount", SalesLine."Allow Invoice Disc.");
          SaleLinePOS.Validate("Invoice Discount Amount", SalesLine."Inv. Discount Amount");

          SaleLinePOS.UpdateAmounts(SaleLinePOS);
          SaleLinePOS.Insert(true);
        until SalesLine.Next = 0;

        SalesHeader.Delete(true);
        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();

        Commit;

        Message(StrSubstNo(DOCUMENT_IMPORTED, SalesHeader."Document Type", SalesHeader."No."));
        //+NPR5.50 [300557]
    end;

    procedure SalesDocumentAmountToPOS(var POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";Invoice: Boolean;Ship: Boolean;Receive: Boolean;Print: Boolean;SyncPost: Boolean)
    var
        txtDeposit: Label 'Deposit';
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
        PaymentAmount: Decimal;
        SalesLine: Record "Sales Line";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.50 [300557]
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        if DocumentIsPartiallyPosted(SalesHeader) then
          Error(ERR_DOCUMENT_POSTED_LINE, SalesHeader."Document Type", SalesHeader."No.");

        if SalePOS."Customer No." <> '' then begin
          SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
          SalePOS.TestField("Customer No.", SalesHeader."Bill-to Customer No.");
        end else begin
          SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
          SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
          SalePOS.Modify(true);
          POSSale.RefreshCurrent();
        end;

        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.CalcSums("Amount Including VAT","Prepmt Amt to Deduct");
        PaymentAmount := SalesLine."Amount Including VAT" - SalesLine."Prepmt Amt to Deduct";

        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("No.", SalesHeader."Bill-to Customer No.");
        SaleLinePOS."Sales Document Type" := SalesHeader."Document Type";
        SaleLinePOS."Sales Document No." := SalesHeader."No.";
        SaleLinePOS."Sales Document Invoice" := Invoice;
        SaleLinePOS."Sales Document Ship" := Ship;
        SaleLinePOS."Sales Document Print" := Print;
        SaleLinePOS."Sales Document Receive" := Receive;
        SaleLinePOS."Sales Document Sync. Posting" := SyncPost;
        //-NPR5.50 [352473]
        //SaleLinePOS.VALIDATE("Unit Price", PaymentAmount);
        if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order",SalesHeader."Document Type"::"Credit Memo"] then
          SaleLinePOS.Validate("Unit Price", -PaymentAmount)
        else
          SaleLinePOS.Validate("Unit Price", PaymentAmount);
        //+NPR5.50 [352473]
        SaleLinePOS.Description := StrSubstNo(Text001, SalesHeader."Document Type", SalesHeader."No.");
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
        //+NPR5.50 [300557]
    end;

    procedure SetOrderType(OrderTypeOption: Option NotSet,"Order",Lending)
    begin

        case OrderTypeOption of
          OrderTypeOption::NotSet :
            begin
              OrderType := 0;
              OrderTypeSet := false;
            end;
          OrderTypeOption::Order :
            begin
              OrderType := 1;
              OrderTypeSet := true;
            end;
          OrderTypeOption::Lending :
            begin
              OrderType := 2;
              OrderTypeSet := true;
            end;
          else Error(ERRORDERTYPE, Format(OrderTypeOption), Format(OrderTypeOption::NotSet), Format(OrderTypeOption::Order), Format(OrderTypeOption::Lending) );
        end;
    end;

    procedure SetDeleteDocumentOnImport(SetDelete: Boolean;SetConfirm: Boolean)
    begin
        DeleteDocumentOnImportToPOS := SetDelete;
        ConfirmDeleteDocumentOnImportToPOS := SetConfirm;
    end;

    procedure SelectSalesDocument(TableView: Text;var SalesHeader: Record "Sales Header"): Boolean
    begin
        //-NPR5.48 [300557]
        if TableView <> '' then
          SalesHeader.SetView(TableView);

        exit(PAGE.RunModal(0, SalesHeader) = ACTION::LookupOK);
        //+NPR5.48 [300557]
    end;

    procedure DocumentIsAttachedToPOSSale(SalePOS: Record "Sale POS"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        //-NPR5.48 [300557]
        if SalePOS."Sales Document No." <> '' then
          exit(true);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Buffer Document No.", '<>%1', '');
        if not SaleLinePOS.IsEmpty then
          exit(true);

        SaleLinePOS.SetRange("Buffer Document No.");
        SaleLinePOS.SetFilter("Sales Document No.", '<>%1', '');
        if not SaleLinePOS.IsEmpty then
          exit(true);

        exit(false);
        //+NPR5.48 [300557]
    end;

    procedure DocumentIsPartiallyPosted(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        //-NPR5.50 [300557]
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");

        SalesLine.SetFilter("Qty. Invoiced (Base)", '<>%1', 0);
        if not SalesLine.IsEmpty then
          exit(true);
        SalesLine.SetRange("Qty. Invoiced (Base)");

        SalesLine.SetFilter("Qty. Shipped (Base)", '<>%1', 0);

        if not SalesLine.IsEmpty then
          exit(true);
        SalesLine.SetRange("Qty. Shipped (Base)");

        SalesLine.SetFilter("Return Qty. Received (Base)", '<>%1', 0);
        if not SalesLine.IsEmpty then
          exit(true);
        SalesLine.SetRange("Return Qty. Received (Base)");

        exit(false);
        //+NPR5.50 [300557]
    end;
}

