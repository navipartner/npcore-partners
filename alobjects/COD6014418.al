codeunit 6014418 "Retail Sales Code"
{
    // NPR3.2s - 14.12.06 Nies. DIBS Tilbagef�rsel, ved tilbagef�rsel af bon.
    // NPR4.10/RMT/20150107 Case 203282 - Set silent for reverse audit info
    // NPR4.10/RMT/20150115 Case 203078 - Change function ReverseSalesTicket to insert "Sale Line POS" before reversing
    //                                   (as is done in nyeste62)
    // NPR4.04/JDH/20150427  CASE 212229 Removed references to old Variant solution "Color Size"
    // NPR4.10/BHR/20150430  CASE 211670 CHANGE FILTER SO AS TO REVERSE GIFT VOUCHERS AS WELL
    // NPR4.14/MMV/20150825  CASE 221045 Removed potential call to CU 6014435 with AuditRoll, since it will always fail if hit.
    //                                   Added FINDFIRST to Revrulle.
    // NPR4.16/JDH/20151030  CASE 212229 Removed remaining references to old Variant solution "Color Size"
    // NPR4.18/MMV/20160122  CASE 231871 Added support for creating gift/credit vouchers as payment in ReverseSalesTicket()
    // NPR5.20/BR/20160229 CASE 231481 Added support for reversing Pepper transactions
    // NPR5.18/BR/2016030 CASE 231871 Changed code to update to 90
    // NPR5.22/MMV/20160421 CASE 237314 Added support for Report Printer Interface & Retail Report Selection Mgt.
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX solution
    // NPR5.30/BHR /20171403  CASE 268750 Correct description
    // NPR5.31/MHA /20170502  CASE 262904 UdpakTilbeh�r() should not trigger on Temporary Tables
    // NPR5.35/BR  /20170823  CASE 284379 Add support for Cashback
    // NPR5.36/TJ  /20170915  CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                    Removed unused variables
    // NPR5.38/MHA /20180105  CASE 301053 Add ConstValue to Text Constants ErrNoLines and ErrLines
    // NPR5.40/TJ  /20180319  CASE 307717 Replaced hardcoded dates with DMY2DATE structure
    // NPR5.40/JDH /20180330 CASE 309516 Removed function "UpdateContact. It wasnt used
    // NPR5.41/THRO/20180409 CASE 310100 Keep original Description
    // NPR5.45/MHA /20180821 CASE 324395 SaleLinePOS."Unit Price (LCY)" Renamed to "Unit Cost (LCY)"
    // NPR5.46/MMV /20181001 CASE 290734 EFT Framework refactoring
    // NPR5.50/TSA /20190502 CASE 342090 Added UpdateAmounts to ReverseSalesTicket2() function
    // NPR5.52/ALPO/20191009 CASE 372122 Incorrect discount % handling when reversing sale return

    TableNo = "Audit Roll";

    trigger OnRun()
    var
        AuditRoll: Record "Audit Roll";
        ReportSelections: Record "Report Selections";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReportType: Integer;
        PrintStd: Boolean;
        PrintRetail: Boolean;
        TxtMenu: Label 'No print,Navision invoice/Cr. Memo,Debit ticket,Both prints';
        RetailSetup: Record "Retail Setup";
        Customer: Record Customer;
        RetailReportSelectionMgt: Codeunit "Retail Report Selection Mgt.";
        ReportPrinterInterface: Codeunit "Report Printer Interface";
        RecRef: RecordRef;
        ReportSelectionRetail: Record "Report Selection Retail";
    begin
        //OnRun
        //Udskriv Gavekort. Kaldes fra CU 6014435 - funktion "Overf�rTilFaktura" og "LavKreditnota".
        RetailSetup.Get;
        Customer.Get("Customer No.");

        if RetailSetup."Faktura udskrifts valg" then begin
          case StrMenu(TxtMenu) of
           1:
             exit;
           2:
             PrintStd := true;
           3:
             PrintRetail := true;
           4:
             begin
               PrintStd := true;
               PrintRetail := true;
             end;
          end;
        end else begin
          PrintRetail := true;
        end;

        AuditRoll.Copy(Rec);
        //-NPR4.14
        AuditRoll.FindFirst;
        //+NPR4.14

        if PrintStd then begin
          case AuditRoll."Document Type" of
            AuditRoll."Document Type"::Order:
              begin
                SalesShipmentHeader."No." := AuditRoll."Document No.";
                SalesShipmentHeader.SetRecFilter;
                ReportType := ReportSelections.Usage::"S.Shipment";
              end;
            AuditRoll."Document Type"::Invoice:
              begin
                SalesInvoiceHeader."No." := AuditRoll."Document No.";
                SalesInvoiceHeader.SetRecFilter;
                ReportType := ReportSelections.Usage::"S.Invoice";
              end;
            AuditRoll."Document Type"::"Credit Memo":
              begin
                SalesCrMemoHeader."No." := AuditRoll."Document No.";
                SalesCrMemoHeader.SetRecFilter;
                ReportType := ReportSelections.Usage::"S.Cr.Memo";
              end;
            AuditRoll."Document Type"::"Return Order":
              begin
                ReturnReceiptHeader."No." := AuditRoll."Document No.";
                ReturnReceiptHeader.SetRecFilter;
                ReportType := ReportSelections.Usage::"S.Ret.Rcpt.";
              end;
          end;

          ReportSelections.Reset;
          ReportSelections.SetRange(Usage,ReportType);
          ReportSelections.Find('-');
          repeat
            ReportSelections.TestField("Report ID");
            case ReportType of
              ReportSelections.Usage::"S.Invoice":
                begin
                  if not RetailSetup."Receipt for Debit Sale" then
                    exit;
                  if Customer."Sales invoice Report No." = 0 then
                    //-NPR5.22
                    ReportPrinterInterface.RunReport(ReportSelections."Report ID",false,false,SalesInvoiceHeader)
                    //REPORT.RUN(RapportValg."Report ID",FALSE,FALSE,SalgFaktHoved)
                    //+NPR5.22
                  else
                    //-NPR5.22
                    ReportPrinterInterface.RunReport(Customer."Sales invoice Report No.",false,false,SalesInvoiceHeader);
                    //REPORT.RUN(Customer."Sales invoice Report No.",FALSE,FALSE,SalgFaktHoved);
                    //+NPR5.22
                end;
              ReportSelections.Usage::"S.Shipment":
                begin
                  if not RetailSetup."Navision Shipment Note" then
                    exit;
                  //-NPR5.22
                  ReportPrinterInterface.RunReport(ReportSelections."Report ID",false,false,SalesShipmentHeader);
                  //REPORT.RUN(RapportValg."Report ID",FALSE,FALSE,SalgLevHoved);
                  //+NPR5.22
                end;
              ReportSelections.Usage::"S.Cr.Memo":
                begin
                  if not RetailSetup."Navision Creditnote" then
                    exit;
                  //-NPR5.22
                  ReportPrinterInterface.RunReport(ReportSelections."Report ID",false,false,SalesCrMemoHeader);
                  //REPORT.RUN(RapportValg."Report ID",FALSE,FALSE,SalgKrNotaHoved);
                  //+NPR5.22
                end;
              ReportSelections.Usage::"S.Ret.Rcpt.":
                begin
                  if not RetailSetup."Navision Shipment Note" then
                    exit;
                  //-NPR5.22
                  ReportPrinterInterface.RunReport(ReportSelections."Report ID",false,false,ReturnReceiptHeader);
                  //REPORT.RUN(RapportValg."Report ID",FALSE,FALSE,Salgreturhoved);
                  //+NPR5.22
                end;
            end;
          until ReportSelections.Next = 0;
        end;

        if PrintRetail then begin
        //-NPR5.22
          RecRef.GetTable(AuditRoll);
          RetailReportSelectionMgt.SetRegisterNo("Register No.");
          RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Customer Sales Receipt");
        //  RapportvalgRetail.SETRANGE("Report Type",RapportvalgRetail."Report Type"::"Debet kvittering");
        //  RapportvalgRetail.SETFILTER("Report ID",'<>0');
        //  RapportvalgRetail.SETRANGE( "Register No.", "Register No." );
        //  IF NOT RapportvalgRetail.FIND('-') THEN
        //    RapportvalgRetail.SETRANGE( "Register No." );
        //  IF RapportvalgRetail.FIND('-') THEN REPEAT
        //    REPORT.RUN( RapportvalgRetail."Report ID", FALSE, FALSE, Revrulle );
        //  UNTIL RapportvalgRetail.NEXT=0;
        //
        //  // Test For Codeunit
        //  RapportvalgRetail.SETRANGE("Data Port ID");
        //  RapportvalgRetail.SETRANGE("Report ID");
        //  RapportvalgRetail.SETFILTER("Codeunit ID",'<>0');
        //  IF NOT RapportvalgRetail.FIND('-') THEN
        //    RapportvalgRetail.SETRANGE("Register No.", '');
        //
        //  IF RapportvalgRetail.FIND('-') THEN REPEAT
        //    Table := Revrulle;
        //    LinePrintBuffer.ProcessPrint(RapportvalgRetail."Codeunit ID", Table);
        //  UNTIL RapportvalgRetail.NEXT = 0;
        //+NPR5.22
        end

        //-NPR4.14
        //ELSE
        //  CODEUNIT.RUN(CODEUNIT::"Retail Form Code", Rec);
        //+NPR4.14
    end;

    var
        Text00001: Label 'There allready exists lines in the sales. Please delete the lines to fetch and customize the return sale.';
        ErrNoLines: Label 'No lines to reverse.';
        ErrLines: Label 'Sale already has lines.';
        ErrGiftVoucherStatus: Label 'Giftvoucher no. %1 can not be %2';
        ErrTerminalApproved: Label 'The Sales Ticket must not contain any Terminal Payments';
        TextConfimDibsDeb: Label 'There are %1 related DIBS-Payments to ticket %2. Do you wish to refund the money to the customer?';
        TextDibsDebError: Label 'Couldt not refund the requested amount. Try again later.';

    procedure Sale2SalePOS(var SalePOS: Record "Sale POS";var SalesHeader: Record "Sales Header" temporary)
    var
        SaleLinePOS: Record "Sale Line POS";
        SalesLine: Record "Sales Line";
        SalesHeader2: Record "Sales Header";
        SalesLookup: Page "Sales List";
        LineNo: Integer;
        ErrDoubleOrder: Label 'Error. Only one sales order can be processed per sale.';
    begin
        //Sale2Eksp
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,SalePOS.Date);
        if SaleLinePOS.Find('+') then
          LineNo := SaleLinePOS."Line No." + 10000
        else
          LineNo := 10000;
        
        SaleLinePOS.SetFilter("Buffer Document No.",'<>%1','');
        if SaleLinePOS.FindSet then
          Error(ErrDoubleOrder);
        
        SalesHeader2.SetRange("Document Type",SalesHeader2."Document Type"::Order);
        
        SalesLookup.SetTableView(SalesHeader2);
        SalesLookup.LookupMode(true);
        if SalesLookup.RunModal <> ACTION::LookupOK then
          exit
        else
          SalesLookup.GetRecord(SalesHeader2);
        
        SalesLine.SetRange("Document Type",SalesHeader2."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader2."No.");
        
        if SalesHeader2."Sell-to Customer No." <> '' then
          SalePOS.Validate("Customer No.",SalesHeader2."Sell-to Customer No.");
        
        SalesHeader.Copy(SalesHeader2);
        
        SalePOS.Validate(SalePOS."Prices Including VAT",SalesHeader2."Prices Including VAT");
        SalePOS.Validate("Location Code",SalesHeader2."Location Code");
        SalePOS.Modify;
        
        if SalesLine.Find('-') then
          repeat
            SaleLinePOS.Init;
            SaleLinePOS.Silent := true;
            SaleLinePOS.Validate("Register No.",SalePOS."Register No.");
            SaleLinePOS.Validate("Sales Ticket No.",SalePOS."Sales Ticket No.");
            SaleLinePOS.Validate(Date,SalePOS.Date);
            case SalesLine.Type of
              SalesLine.Type::Item:
                begin
                  SaleLinePOS.Type := SaleLinePOS.Type::Item;
                  SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
                end;
              SalesLine.Type::" ":
                begin
                  SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                  SaleLinePOS.Description := SalesLine.Description;
                  //+001
                  if CompanyName = 'Wabiwabi' then begin
                    SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Comment;
                    SaleLinePOS."No." := '*';
                  end;
                  //-001
                end;
            end;
            if SaleLinePOS.Type <> SaleLinePOS.Type::Comment then
              SaleLinePOS.Validate("No.",SalesLine."No.");
            SaleLinePOS.Description := SalesLine.Description;
            SaleLinePOS."Buffer Ref. No." := SalesLine."Line No.";
            SaleLinePOS."Buffer Document Type" := SalesLine."Document Type";
            SaleLinePOS."Buffer Document No." := SalesLine."Document No.";
            SaleLinePOS."Description 2" := SalesLine."Description 2";
            SaleLinePOS."Variant Code" := SalesLine."Variant Code";
            SaleLinePOS."Line No." := LineNo;
            SaleLinePOS."Order No. from Web" := SalesLine."Document No.";
            SaleLinePOS."Order Line No. from Web" := SalesLine."Line No.";
        
            SaleLinePOS.Validate("Price Includes VAT",SalesHeader2."Prices Including VAT");
            SaleLinePOS.Validate("VAT %",SalesLine."VAT %");
            if SaleLinePOS.Type = SaleLinePOS.Type::Item then
              SaleLinePOS.Validate("Unit of Measure Code");
            SaleLinePOS.Insert(true);
            SaleLinePOS.Silent := false;
            SaleLinePOS.Validate(Quantity,SalesLine.Quantity);
            SaleLinePOS.Validate("Unit Price",SalesLine."Unit Price");
            SaleLinePOS."Bin Code" := SalesLine."Bin Code";
            TestAndSet(SaleLinePOS."Location Code",SalesLine."Location Code");
            TestAndSet(SaleLinePOS."Shortcut Dimension 1 Code",SalesLine."Shortcut Dimension 1 Code");
            TestAndSet(SaleLinePOS."Shortcut Dimension 2 Code",SalesLine."Shortcut Dimension 2 Code" );
            SaleLinePOS.Modify;
            LineNo += 10000;
          until SalesLine.Next = 0;
        
        /* HANDLE DEPOSIT ------------------------------------------------------------- */
        /*
        CustLedgerEntry.SETRANGE("Document Type",CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SETRANGE(Open,FALSE);
        CustLedgerEntry.CALCSUMS("Closed by Amount");
        
        IF CustLedgerEntry."Closed by Amount" > 0 THEN BEGIN
          EkspLine.INIT;
          EkspLine."Register No."              := Eksp."Register No.";
          EkspLine."Sales Ticket No."          := Eksp."Sales Ticket No.";
          EkspLine.Date                        := Eksp.Date;
          EkspLine.Type                        := EkspLine.Type::Customer;
          EkspLine."Sale Type"                 := EkspLine."Sale Type"::Deposit;
          EkspLine."Line No."                  := LineNo;
          EkspLine.VALIDATE("No.", Eksp."Customer No.");
          EkspLine."Location Code"             := Eksp."Location Code";
          EkspLine."Shortcut Dimension 1 Code" := Eksp."Shortcut Dimension 1 Code";
          EkspLine."Shortcut Dimension 2 Code" := Eksp."Shortcut Dimension 2 Code";
          EkspLine."Price Includes VAT"       := TRUE;   //always VAT?
          EkspLine.VALIDATE(Quantity, 1);
          EkspLine.VALIDATE("Unit Price", CustLedgerEntry."Closed by Amount");
          EkspLine.Description                 := txtDeposit;
          EkspLine.INSERT(TRUE);
        END;
        */

    end;

    procedure ExtractAccessory(SaleLinePOS: Record "Sale Line POS";Force: Boolean): Boolean
    var
        SaleLinePOS2: Record "Sale Line POS";
        Register: Record Register;
        Item: Record Item;
        InputDialog: Page "Input Dialog";
        Quantity2: Decimal;
        AccessorySparePartLineNo: Integer;
        Return: Boolean;
        txtQuantity: Label 'Quantity of Item %1';
        AccessorySparePart: Record "Accessory/Spare Part";
        RetailSetup: Record "Retail Setup";
    begin
        //UdpakTilbeh�r
        //-002
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Customer;
        Return := false;
        RetailSetup.Get;
        Register.Get(SaleLinePOS."Register No.");
        with SaleLinePOS do begin
          AccessorySparePart.Reset;
          AccessorySparePart.SetRange(Type,AccessorySparePart.Type::Accessory);
          AccessorySparePart.SetRange(Code,"No.");
          AccessorySparePartLineNo := 0;
          if AccessorySparePart.Find('-') then
            repeat
              Return := true;
              if AccessorySparePart."Add Extra Line Automatically" or Force then begin
                AccessorySparePartLineNo := AccessorySparePartLineNo + 1;
                SaleLinePOS2.Copy(SaleLinePOS);
                SaleLinePOS2."Line No." := "Line No." + 100 * AccessorySparePartLineNo;
                SaleLinePOS2.Init;
                SaleLinePOS2.Accessory := true;
                SaleLinePOS2."Main Item No." := "No.";
                SaleLinePOS2."Item group accessory" := false;
                SaleLinePOS2."Accessories Item Group No." := '';
                SaleLinePOS2.Insert(true);
                SaleLinePOS2.Validate("No.",AccessorySparePart."Item No.");

                //-NPR4.16
                //Vare.GET( Ekspeditionslinie."No." );
                //IF (Vare."Size Group" <> '') AND npc."Pop-up (Color-Size)" THEN BEGIN
                //  COMMIT;
                //  Ekspeditionslinie.ColorSizePopUp( Ekspeditionslinie );
                //  Ekspeditionslinie.VALIDATE( "No." );
                //END;
                //+NPR4.16

                if AccessorySparePart."Quantity in Dialogue" then begin
                  InputDialog.SetInput(1,Quantity2,StrSubstNo(txtQuantity,AccessorySparePart."Item No."));
                  if InputDialog.RunModal = ACTION::OK then
                    InputDialog.InputDecimal(1,Quantity2)
                  else
                    Quantity2 := AccessorySparePart.Quantity;

                  SaleLinePOS2.Validate(Quantity,Quantity2);
                end else begin
                  if AccessorySparePart."Per unit" then
                    SaleLinePOS2.Validate(Quantity,AccessorySparePart.Quantity * SaleLinePOS.Quantity)
                  else
                    SaleLinePOS2.Validate(Quantity,AccessorySparePart.Quantity);
                end;

                if AccessorySparePart."Use Alt. Price" then begin
                  if AccessorySparePart."Show Discount" then begin
                    SaleLinePOS2.Validate("Amount Including VAT",AccessorySparePart."Alt. Price");
                  end else begin
                    if SaleLinePOS2."Price Includes VAT" then
                      SaleLinePOS2.Validate("Unit Price",AccessorySparePart."Alt. Price")
                    else
                      SaleLinePOS2.Validate("Unit Price",SaleLinePOS2."Unit Price" / (1 + SaleLinePOS2."VAT %" / 100));
                  end;
                end;
                SaleLinePOS2.Modify;
              end;
            until AccessorySparePart.Next = 0;

          if Item.Get(SaleLinePOS."Item Group" ) and (SaleLinePOS."Item Group" <> SaleLinePOS."No." ) and not Return then begin
            AccessorySparePart.Reset;
            AccessorySparePart.SetRange(Type,AccessorySparePart.Type::Accessory);
            AccessorySparePart.SetRange(Code,Item."No.");
            if AccessorySparePart.Find('-') then
              repeat
                Return := true;
                if AccessorySparePart."Add Extra Line Automatically" or Force then begin
                  AccessorySparePartLineNo := AccessorySparePartLineNo + 1;
                  SaleLinePOS2.Copy(SaleLinePOS);
                  SaleLinePOS2."Line No." := "Line No." + 100 * AccessorySparePartLineNo;
                  SaleLinePOS2.Init;
                  SaleLinePOS2.Accessory := true;
                  SaleLinePOS2."Main Item No." := "No.";
                  SaleLinePOS2."Item group accessory" := true;
                  SaleLinePOS2."Accessories Item Group No." := Item."No.";
                  SaleLinePOS2.Insert(true);
                  SaleLinePOS2.Validate("No.",AccessorySparePart."Item No.");
                  SaleLinePOS2.Validate(Quantity,AccessorySparePart.Quantity);
                  if AccessorySparePart."Use Alt. Price" then begin
                    if AccessorySparePart."Show Discount" then begin
                      SaleLinePOS2.Validate("Amount Including VAT",AccessorySparePart."Alt. Price");
                    end else begin
                      if SaleLinePOS2."Price Includes VAT" then
                        SaleLinePOS2.Validate("Unit Price",AccessorySparePart."Alt. Price")
                      else
                        SaleLinePOS2.Validate("Unit Price",SaleLinePOS2."Unit Price" / ((100 + SaleLinePOS2."VAT %") / 100));
                    end;
                  end;
                  SaleLinePOS2.Modify;
                end;
              until AccessorySparePart.Next = 0;
          end;
          exit(Return);
        end;
        //+002
    end;

    procedure ExtractCombination(var SaleLinePOS: Record "Sale Line POS"): Decimal
    begin
        //UdpakKombination
        //ERROR('NOT IMPLEMENTED');
        /*
        CLEAR( KombinationForm );
        Kombination.RESET;
        Kombination.SETRANGE( "Main Item", Linie."No." );
        IF NOT Kombination.FIND('-') THEN
          EXIT( 0 );
        KombinationForm.LOOKUPMODE := TRUE;
        KombinationForm.SETTABLEVIEW( Kombination );
        IF NOT ( KombinationForm.RUNMODAL = ACTION::LookupOK ) THEN
          EXIT( 0 );
        
        KombinationForm.GETRECORD( Kombination );
        
        Kombinationlinie.SETRANGE( "Combination No.", Kombination."Combination No." );
        Kombinationlinie.SETRANGE( "Main Item No.", Kombination."Main Item" );
        Kombinationlinie.SETFILTER( Quantity, '>=1' );
        nKombiLinie := 0;
        RabatPct := 0;
        Vare.GET( Linie."No." );
        //-NPR4.16
        //nSamletPris := Linie.FindVareSalgspris( Vare, Linie.Color, Linie.Size, Linie ) * Linie.Quantity;
        nSamletPris := Linie.FindVareSalgspris(Vare, '', '', Linie) * Linie.Quantity;
        //+NPR4.16
        Linie."Discount Type" := Linie."Discount Type"::Combination;
        Linie."Discount Code" := Kombination."Combination No.";
        WITH Linie DO BEGIN
          "Combination No." := Kombination."Combination No.";
          IF NOT Kombinationlinie.FIND('-') THEN
            ERROR( ErrNoKombLines );
          REPEAT
            Vare.GET( Kombinationlinie."Item No." );
            nKombiLinie := nKombiLinie + 1;
            Ekspeditionslinie."Register No." := Linie."Register No.";
            Ekspeditionslinie."Sales Ticket No." := Linie."Sales Ticket No.";
            Ekspeditionslinie.Date := Linie.Date;
            Ekspeditionslinie."Sale Type" := Ekspeditionslinie."Sale Type"::Sale;
            Ekspeditionslinie.Type := Ekspeditionslinie.Type::Item;
            Ekspeditionslinie."Line No." := "Line No." + 100 * nKombiLinie;
            Ekspeditionslinie.VALIDATE( "No.", Vare."No." );
            Ekspeditionslinie.VALIDATE( Quantity, Kombinationlinie.Quantity );
            Ekspeditionslinie."Combination Item" := TRUE;
            Ekspeditionslinie."Main Item No." := "No.";
            Ekspeditionslinie."Combination No." := Kombination."Combination No.";
            Ekspeditionslinie.INSERT;
            nSamletPris += Ekspeditionslinie."Unit Price" * Ekspeditionslinie.Quantity;
          UNTIL Kombinationlinie.NEXT = 0;
          nKombiLinie := 0;
          RabatPct := 100 - Kombination."Combination Price" / nSamletPris * 100;
          Kombinationlinie.FIND('-');
          REPEAT
            nKombiLinie := nKombiLinie + 1;
            Ekspeditionslinie.GET( "Register No.", "Sales Ticket No.", Date, "Sale Type", "Line No." + 100 * nKombiLinie );
            Vare.GET( Ekspeditionslinie."No." );
        
            Ekspeditionslinie."Discount Type" := Ekspeditionslinie."Discount Type"::Combination;
            Ekspeditionslinie."Discount Code" := Kombination."Combination No.";
            Ekspeditionslinie."Discount %" := RabatPct;
            Ekspeditionslinie.HentBel�b( Ekspeditionslinie, Vare, Ekspeditionslinie."Unit Price" );
            Ekspeditionslinie.MODIFY;
          UNTIL Kombinationlinie.NEXT = 0;
        END;
        Linie."Discount %" := RabatPct;
        Linie."Discount Amount"  := Linie."Unit Price" * Linie.Quantity * RabatPct / 100;
        Linie.HentBel�b( Linie, Vare, Linie."Unit Price" );
        Linie.MODIFY;
        EXIT( RabatPct );
        */

    end;

    procedure ReverseSalesTicket2(var SalePOS: Record "Sale POS";SalesTicketNo: Code[20])
    var
        AuditRoll: Record "Audit Roll";
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOS2: Record "Sale Line POS";
        Register: Record Register;
        PaymentTypePOS: Record "Payment Type POS";
        RetailFormCode: Codeunit "Retail Form Code";
        VoucherNo: Text[100];
    begin
        //-NPR4.18
        //-NPR4.10
        //AuditRoll.SETRANGE("Sales Ticket No.",SalesTicketNo);
        //AuditRoll.SETRANGE("Sale Type",AuditRoll."Sale Type"::Salg);
        //AuditRoll.SETRANGE(Type,AuditRoll.Type::Item);

        AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type,AuditRoll.Type::Item);

        //AuditRoll.SETRANGE("Sales Ticket No.",SalesTicketNo);
        //AuditRoll.SETFILTER("Sale Type",'%1|%2', AuditRoll."Sale Type"::Salg,AuditRoll."Sale Type"::Indbetaling);
        //AuditRoll.SETFILTER(Type,'%1|%2',AuditRoll.Type::Item,AuditRoll.Type::"G/L");

        //+NPR4.10
        //+NPR4.18
        SaleLinePOS2.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        if SaleLinePOS2.FindFirst then
          Error(Text00001);

        if AuditRoll.FindSet(false,false) then
          repeat
            SaleLinePOS.Init;
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Type := SaleLinePOS.Type::Item;
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
            //-NPR4.10
            //ReverseAuditInfoToSalesLine(SaleLinePOS, AuditRoll);
            //SaleLinePOS."Line No."         := AuditRoll."Line No.";
            //SaleLinePOS.INSERT(TRUE);
            SaleLinePOS."Line No." := AuditRoll."Line No.";
            SaleLinePOS.Insert(true);
            ReverseAuditInfoToSalesLine(SaleLinePOS,AuditRoll);

            //-NPR5.50 [342090]
            SaleLinePOS.UpdateAmounts (SaleLinePOS);
            //+NPR5.50 [342090]

            SaleLinePOS.Modify(true);
            //+NPR4.10
          until AuditRoll.Next = 0;

        //-NPR4.18
        //Handle Gift/Credit vouchers by creating payment lines with them
        Register.Get(SalePOS."Register No.");
        AuditRoll.SetRange("Sales Ticket No.",SalesTicketNo);
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Deposit);
        AuditRoll.SetRange(Type,AuditRoll.Type::"G/L");
        AuditRoll.SetFilter("No.",'%1|%2',Register."Gift Voucher Account",Register."Credit Voucher Account");
        if AuditRoll.FindSet then
          repeat
            if AuditRoll."Gift voucher ref." <> '' then
              PaymentTypePOS.SetRange(PaymentTypePOS."Processing Type",PaymentTypePOS."Processing Type"::"Gift Voucher");
            if AuditRoll."Credit voucher ref." <> '' then
              PaymentTypePOS.SetRange(PaymentTypePOS."Processing Type",PaymentTypePOS."Processing Type"::"Credit Voucher");
            PaymentTypePOS.FindFirst;

            SaleLinePOS.Init;
            SaleLinePOS."Register No." := SalePOS."Register No.";
            SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
            SaleLinePOS.Date := SalePOS.Date;
            SaleLinePOS.Type := SaleLinePOS.Type::Payment;
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Payment;
            SaleLinePOS."Line No." := AuditRoll."Line No.";
            SaleLinePOS.Validate("No.",PaymentTypePOS."No.");
            SaleLinePOS.Insert(true);

            //-NPR5.18
            //RetailFormCode.InitTS(TRUE,'');
            RetailFormCode.InitTS(true,0);
            //+NPR5.18
            if AuditRoll."Gift voucher ref." <> '' then begin
              VoucherNo := AuditRoll."Gift voucher ref.";
              RetailFormCode.GiftVoucherLookup(SaleLinePOS,VoucherNo);
            end;
            if AuditRoll."Credit voucher ref." <> '' then begin
              VoucherNo := AuditRoll."Credit voucher ref.";
              RetailFormCode.CreditVoucherLookup(SaleLinePOS,VoucherNo);
            end;

            SaleLinePOS.Modify(true);
          until AuditRoll.Next = 0;
        //+NPR4.18
    end;

    procedure ReverseAuditInfoToSalesLine(var SaleLinePOS: Record "Sale Line POS";AuditRoll: Record "Audit Roll")
    var
        RetailSetup: Record "Retail Setup";
        NPRDimMgt: Codeunit NPRDimensionManagement;
    begin
        //-NPR4.10
        SaleLinePOS.Silent := true;
        //+NPR4.10
        SaleLinePOS.Validate("No.",AuditRoll."No.");
        //-NPR5.41 [310100]
        SaleLinePOS.Description := AuditRoll.Description;
        SaleLinePOS."Description 2" := AuditRoll."Description 2";
        //+NPR5.41 [310100]

        if SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale then
          SaleLinePOS.Validate(Quantity,-AuditRoll.Quantity);

        SaleLinePOS."VAT %" := AuditRoll."VAT %";
        //SaleLinePOS."Discount %" := AuditRoll."Line Discount %";  //NPR5.52 [372122]-revoked
        SaleLinePOS."Discount %" := Abs(AuditRoll."Line Discount %");  //NPR5.52 [372122]
        SaleLinePOS."Discount Amount" := -AuditRoll."Line Discount Amount";
        SaleLinePOS."External Document No." := AuditRoll."Sales Ticket No.";
        SaleLinePOS.Amount := -AuditRoll.Amount;
        SaleLinePOS."Currency Amount" := -AuditRoll."Currency Amount";
        SaleLinePOS."Amount Including VAT" := -AuditRoll."Amount Including VAT";
        SaleLinePOS."Serial No." := AuditRoll."Serial No.";
        //-NPR4.16
        //SaleLinePOS.Color                   := AuditRoll.Color;
        //SaleLinePOS.Size                    := AuditRoll.Size;
        //+NPR4.16
        SaleLinePOS."Discount Type" := AuditRoll."Discount Type";
        SaleLinePOS."Discount Code" := AuditRoll."Discount Code";
        SaleLinePOS."Gen. Bus. Posting Group" := AuditRoll."Gen. Bus. Posting Group";
        SaleLinePOS."Gen. Prod. Posting Group" := AuditRoll."Gen. Prod. Posting Group";
        SaleLinePOS."VAT Bus. Posting Group" := AuditRoll."VAT Bus. Posting Group";
        SaleLinePOS."VAT Prod. Posting Group" := AuditRoll."VAT Prod. Posting Group";
        //-NPR5.45 [324395]
        //SaleLinePOS."Unit Price (LCY)" := AuditRoll."Unit Cost (LCY)";
        SaleLinePOS."Unit Cost (LCY)" := AuditRoll."Unit Cost (LCY)";
        //+NPR5.45 [324395]
        SaleLinePOS.Cost := -AuditRoll.Cost;
        SaleLinePOS."Unit Cost" :=  AuditRoll."Unit Cost";
        SaleLinePOS."Unit Price" := AuditRoll."Unit Price";
        SaleLinePOS."VAT Base Amount" := -AuditRoll."VAT Base Amount";
        SaleLinePOS."Item Group" := AuditRoll."Item Group";
        SaleLinePOS."Vendor No." := AuditRoll.Vendor;
        SaleLinePOS.Internal := AuditRoll.Internal;
        SaleLinePOS."Variant Code" := AuditRoll."Variant Code";
        SaleLinePOS."System-Created Entry" := AuditRoll."System-Created Entry";
        SaleLinePOS."Shortcut Dimension 1 Code" := AuditRoll."Department Code";
        SaleLinePOS."Serial No. not Created" := AuditRoll."Serial No. not Created";
        SaleLinePOS."Foreign No." := AuditRoll."Fremmed nummer";

        if AuditRoll."Gift voucher ref." <> '' then begin
          SaleLinePOS."Gift Voucher Ref." := AuditRoll."Gift voucher ref.";
          SaleLinePOS."Discount Code" := AuditRoll."Gift voucher ref.";
        end;

        if AuditRoll."Credit voucher ref." <> '' then begin
          SaleLinePOS."Credit voucher ref." := AuditRoll."Credit voucher ref.";
          SaleLinePOS."Discount Code" := AuditRoll."Credit voucher ref.";
        end;

        SaleLinePOS.Validate("Shortcut Dimension 1 Code",AuditRoll."Shortcut Dimension 1 Code");
        SaleLinePOS.Validate("Shortcut Dimension 2 Code",AuditRoll."Shortcut Dimension 2 Code");

        RetailSetup.Get;
        if RetailSetup."Use Adv. dimensions" then
          NPRDimMgt.CopyAuditRollDimToSaleLinePOSDim(AuditRoll,SaleLinePOS);
    end;

    procedure ReverseSalesTicket(var SalePOS: Record "Sale POS") ReturnValue: Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
        GiftVoucher: Record "Gift Voucher";
        PaymentTypePOS: Record "Payment Type POS";
        AuditRoll: Record "Audit Roll";
        AuditRollList: Page "Audit Roll";
        GiftCertOnTicket: Boolean;
        CreditCardTransaction: Record "Credit Card Transaction";
        DibsTransID: Text[30];
        OrderID: Text[30];
        Amount: Decimal;
        TempDibsTrans: Record "Retail List" temporary;
        AmountArr: array [10] of Decimal;
        AmountItt: Integer;
        EntryNo: Integer;
        GlobalSalePOS: Record "Global Sale POS";
        RetailSetup: Record "Retail Setup";
        IsEANCode: Boolean;
        IsCashLine: Boolean;
        PepperTransactionRequest: Record "EFT Transaction Request";
    begin
        //Tilbagef�rBon
        RetailSetup.Get;
        IsEANCode := false;
        ReturnValue := false;

        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date,Today);
        AuditRoll.Reset;
        AuditRoll.SetFilter(Type,'<> %1 & <> %2',AuditRoll.Type::"Open/Close",AuditRoll.Type::Cancelled);

        //006-
        if SalePOS."Retursalg Bonnummer" = '' then begin
          Clear(AuditRollList);
          AuditRollList.LookupMode := true;
          AuditRollList.SetTableView(AuditRoll);
          if not (AuditRollList.RunModal = ACTION::LookupOK) then
            exit(false)
          else
            ReturnValue := true;
          AuditRollList.GetRecord(AuditRoll);
        end else begin
          if (StrLen(SalePOS."Retursalg Bonnummer") = 13)
             and (CopyStr(SalePOS."Retursalg Bonnummer",1,2) = RetailSetup."EAN Prefix Exhange Label") then begin
            Evaluate(EntryNo,CopyStr(SalePOS."Retursalg Bonnummer",3,10));
            if GlobalSalePOS.Get(EntryNo) then begin
              GlobalSalePOS."Returning Company Name" := CompanyName;
              GlobalSalePOS.Modify;
              AuditRoll.ChangeCompany(GlobalSalePOS."Company Name");
              AuditRoll.SetFilter("Sales Ticket No.",'=%1',GlobalSalePOS."Sales Ticket No.");
              AuditRoll.SetRange(AuditRoll.Type,AuditRoll.Type::Item);
              if GlobalSalePOS."Audit Roll Line No." <> 0 then
                AuditRoll.SetRange("Line No.",GlobalSalePOS."Audit Roll Line No.");

              IsEANCode := true;
            end;
          end else
            AuditRoll.SetFilter("Sales Ticket No.",'=%1',SalePOS."Retursalg Bonnummer");

          if not AuditRoll.Find('-') then
            exit(false)
          else
            ReturnValue := true;

        end;

        AuditRoll.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        AuditRoll.SetRange("Cash Terminal Approved",true);
        if AuditRoll.Find('-') then begin
        //+NPR3.2s
          if (AuditRoll."Reverseing Sales Ticket No." = '' ) and (AuditRoll."Reversed by Sales Ticket No." = '') then
            if (not IsEANCode) or (IsEANCode and (GlobalSalePOS."Audit Roll Line No." <> 0) and
              (GlobalSalePOS."Audit Roll Line No." = AuditRoll."Line No.") and (AuditRoll.Type = AuditRoll.Type::Item))
              or (IsEANCode and (GlobalSalePOS."Audit Roll Line No." <> 0) and (AuditRoll.Type <> AuditRoll.Type::Item))
              or (IsEANCode and (GlobalSalePOS."Audit Roll Line No." = 0) ) then begin

              //-NPR5.20
              PepperTransactionRequest.Reset;
              PepperTransactionRequest.SetCurrentKey("Sales Ticket No.");
              PepperTransactionRequest.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
              PepperTransactionRequest.SetRange("Processing Type",PepperTransactionRequest."Processing Type"::PAYMENT);
              PepperTransactionRequest.SetRange(Successful,true);
              PepperTransactionRequest.SetRange(Reversed,false);
              if PepperTransactionRequest.IsEmpty then begin
              //+NPR5.20
                CreditCardTransaction.Reset;
                if IsEANCode then
                  CreditCardTransaction.ChangeCompany(GlobalSalePOS."Company Name");
                CreditCardTransaction.FilterGroup := 2;
                CreditCardTransaction.SetCurrentKey("Register No.","Sales Ticket No.",Date);
                CreditCardTransaction.SetRange("Register No.",AuditRoll."Register No.");
                CreditCardTransaction.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
                CreditCardTransaction.SetRange(Date,AuditRoll."Sale Date");
                CreditCardTransaction.SetFilter(Text,'TransID:*|OrderID:*');
                CreditCardTransaction.FilterGroup := 0;
                AmountItt := 1;
                if CreditCardTransaction.Find('-') then begin
                  repeat
                    OrderID := CopyStr(CreditCardTransaction.Text,10,StrLen(CreditCardTransaction.Text)-9);
                    CreditCardTransaction.Next;
                    Amount := AuditRoll."Amount Including VAT";
                    DibsTransID := CopyStr(CreditCardTransaction.Text,10,StrLen(CreditCardTransaction.Text)-9);
                    // Inds�t info i tmp records.
                    Evaluate(TempDibsTrans.Number,DibsTransID);
                    TempDibsTrans.Choice := OrderID;
                    TempDibsTrans.Insert;
                    AmountArr[AmountItt] := Amount;
                    AmountItt += 1;
                  until CreditCardTransaction.Next = 0;
                  if Confirm(StrSubstNo(TextConfimDibsDeb,AmountItt-1,AuditRoll."Sales Ticket No.")) then begin
                    AmountItt := 1;
                    if TempDibsTrans.Find('-') then
                      repeat
                        Error(TextDibsDebError);
                        AmountItt += 1;
                      until TempDibsTrans.Next = 0;
                  end else
                    Error(ErrTerminalApproved);
                end else
                  Error(ErrTerminalApproved);
                end;
              //-NPR5.20
              end;
              //+NPR5.20
            end;

        AuditRoll.SetRange("Cash Terminal Approved");

        GiftCertOnTicket := false;
        if AuditRoll.Find('-') then begin
          SalePOS.Validate("Customer Type",AuditRoll."Customer Type");
          SalePOS.Validate("Customer No.",AuditRoll."Customer No.");
          ModifyAnnulmentSalePOS(SalePOS,AuditRoll);
          repeat
            IsCashLine := false;
            SaleLinePOS.Reset;
            SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange(Date, Today);
            SaleLinePOS.SetRange("Line No.",AuditRoll."Line No.");
            if SaleLinePOS.FindFirst then
              Error(ErrLines);

            if (AuditRoll."Sale Type" = AuditRoll."Sale Type"::Payment) then
              IsCashLine := PaymentTypePOS.Get(AuditRoll."No.") and
                            (PaymentTypePOS."Processing Type" = PaymentTypePOS."Processing Type"::Cash);

            if (AuditRoll."Reverseing Sales Ticket No." = '' ) and (AuditRoll."Reversed by Sales Ticket No." = '') and not IsCashLine then
              if (not IsEANCode) or (IsEANCode and (GlobalSalePOS."Audit Roll Line No." <> 0) and
                (GlobalSalePOS."Audit Roll Line No." = AuditRoll."Line No.") and (AuditRoll.Type = AuditRoll.Type::Item))
                or (IsEANCode and (GlobalSalePOS."Audit Roll Line No." <> 0) and (AuditRoll.Type <> AuditRoll.Type::Item))
                or (IsEANCode and (GlobalSalePOS."Audit Roll Line No." = 0)) then begin
                if AuditRoll."Sale Type" = AuditRoll."Sale Type"::Deposit then begin
                  if AuditRoll.LineIsGiftCert then begin
                    if IsEANCode then
                      GiftVoucher.ChangeCompany(GlobalSalePOS."Company Name");

                    if GiftVoucher.Get(AuditRoll."Gift voucher ref.") then begin
                      if GiftVoucher.Status = GiftVoucher.Status::Cashed then
                        Error(ErrGiftVoucherStatus,GiftVoucher."No.",GiftVoucher.Status);
                      InsertAnnulmentLine(SalePOS,AuditRoll);
                      GiftCertOnTicket := true;
                    end;
                  end else if AuditRoll.LineIsGiftCertDisc then begin
                    if GiftCertOnTicket then begin
                      InsertAnnulmentLine(SalePOS,AuditRoll);
                      GiftCertOnTicket := false;
                    end;
                  end else if AuditRoll.LineIsReceivable then begin
                    InsertAnnulmentLine(SalePOS,AuditRoll);
                  end;
                end else begin
                  if AuditRoll."No." <> '' then
                    InsertAnnulmentLine(SalePOS,AuditRoll);
                end;
              end;
          until AuditRoll.Next = 0;
        end else
          Error(ErrNoLines);

        // Inds�tter returbetalinger kontant
        AuditRoll.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type);
        AuditRoll.SetRange(Type,AuditRoll.Type::Payment);
        AuditRoll.SetRange("Sale Type",AuditRoll."Sale Type"::Payment);
        PaymentTypePOS.SetRange(Status,PaymentTypePOS.Status::Active);
        PaymentTypePOS.SetRange("Processing Type",PaymentTypePOS."Processing Type"::Cash);
        SalePOS."Saved Sale" := true;
        SalePOS.Modify;
        Commit;
        if PaymentTypePOS.Find('-') then
          repeat
            AuditRoll.SetRange("No.",PaymentTypePOS."No.");
            if AuditRoll.Find('-') then begin
              AuditRoll.CalcSums("Amount Including VAT");
              InsertAnnulmentLine(SalePOS,AuditRoll)
            end;
          until PaymentTypePOS.Next = 0;
    end;

    procedure ModifyAnnulmentSalePOS(var SalePOS: Record "Sale POS";var AuditRoll: Record "Audit Roll")
    begin
        //ModifyTilbF�rEkspHoved
        SalePOS.Validate("Customer Type",AuditRoll."Customer Type");
        SalePOS.Validate("Customer No.",AuditRoll."Customer No.");
        SalePOS.Validate("Location Code",AuditRoll.Lokationskode);
        //Sale.VALIDATE("Department Code",Revisionsrulle."Department Code");
        SalePOS.Validate("Shortcut Dimension 1 Code",AuditRoll."Shortcut Dimension 1 Code");
        SalePOS.Validate("Shortcut Dimension 2 Code",AuditRoll."Shortcut Dimension 2 Code");
        SalePOS.Validate(Kontankundenr,AuditRoll."Cash Customer No.");
        SalePOS.Validate("Sale type",AuditRoll."Receipt Type");
        SalePOS.Validate("Salesperson Code",AuditRoll."Salesperson Code");

        SalePOS."Retail Document Type" := AuditRoll."Retail Document Type";
        SalePOS."Retail Document No." := AuditRoll."Retail Document No.";
        SalePOS."Non-editable sale" := true;
        SalePOS."Sale type" := SalePOS."Sale type"::Annullment;
        SalePOS.Modify;
    end;

    procedure InsertAnnulmentLine(var SalePOS: Record "Sale POS";var AuditRoll: Record "Audit Roll")
    var
        SaleLinePOS: Record "Sale Line POS";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        Item: Record Item;
        GLAccount: Record "G/L Account";
        GiftVoucher: Record "Gift Voucher";
        CreditVoucher: Record "Credit Voucher";
        PepperTransactionRequest: Record "EFT Transaction Request";
        PepperProtocol: Codeunit "Pepper Protocol";
        CCTrans: Record "Credit Card Transaction";
        Register: Record Register;
        AmountItt: Integer;
        TextRefundMandatory: Label 'There are %1 related Card payments to ticket %2. To process the cancellation all Card payments must be reversed or cancelled.';
    begin
        //Inserttilbf�rlinje
        SaleLinePOS.Init;
        SaleLinePOS."Register No." := SalePOS."Register No.";
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS.Date := Today;
        SaleLinePOS."Sale Type" := AuditRoll."Sale Type";
        SaleLinePOS.ForceApris := true;
        if AuditRoll.Type = AuditRoll.Type::"Debit Sale" then
          if AuditRoll."No." <> '' then            // Bem�rkning
            if AuditRoll."No." <> '*' then begin   // Bem�rkning
              if AuditRoll."Sale Type" = AuditRoll."Sale Type"::Comment then
                if AuditRoll.Type = AuditRoll.Type::"Debit Sale" then begin
                  SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
                  SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                  if GLAccount.Get(AuditRoll."No.") then
                    SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
                  if Item.Get(AuditRoll."No.") then
                    SaleLinePOS.Type := SaleLinePOS.Type::Item;
                  if (AuditRoll."Gift voucher ref." <> '') or (AuditRoll."Credit voucher ref." <> '') then begin
                    SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
                    SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
                  end;
                end;
            end;
        SaleLinePOS."Line No." := AuditRoll."Line No.";
        SaleLinePOS.Insert;

        case AuditRoll.Type of
          AuditRoll.Type::Item:
            begin
              SaleLinePOS.Type := SaleLinePOS.Type::Item;
              ItemUnitofMeasure.Reset;
              ItemUnitofMeasure.SetRange("Item No.",AuditRoll."No.");
              ItemUnitofMeasure.SetRange(Code,AuditRoll."Unit of Measure Code");
              if ItemUnitofMeasure.Find('-') then
                SaleLinePOS.Validate("Quantity (Base)",ItemUnitofMeasure."Qty. per Unit of Measure" * -AuditRoll.Quantity)
              else
                SaleLinePOS.Validate("Quantity (Base)",-AuditRoll.Quantity);
            end;
          AuditRoll.Type::Customer:
            SaleLinePOS.Type := SaleLinePOS.Type::Customer;
          AuditRoll.Type::"G/L":
            SaleLinePOS.Type := SaleLinePOS.Type::"G/L Entry";
          AuditRoll.Type::"Open/Close":
            SaleLinePOS.Type := SaleLinePOS.Type::"Open/Close";
          AuditRoll.Type::Payment:
            SaleLinePOS.Type := SaleLinePOS.Type::Payment;
          AuditRoll.Type::Comment:
            SaleLinePOS.Type := SaleLinePOS.Type::Comment;
          AuditRoll.Type::"Debit Sale":
            begin
              if AuditRoll."Sale Type" = AuditRoll."Sale Type"::Comment then
                if AuditRoll."No." = '' then begin  // Bem�rkning
                  AuditRoll."No." := '*';
                  SaleLinePOS.Type := SaleLinePOS.Type::Comment;
                end;
            end;
        end;

        case AuditRoll."Sale Type" of
          AuditRoll."Sale Type"::Payment:
            SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Payment;
          AuditRoll."Sale Type"::"Gift Voucher":
            begin
              if GiftVoucher.Get(AuditRoll."Gift voucher ref.") then begin
                GiftVoucher.Status := GiftVoucher.Status::Cancelled;
                GiftVoucher.Modify;
              end;
            end;
          AuditRoll."Sale Type"::"Credit Voucher":
            begin
              if CreditVoucher.Get(AuditRoll."Credit voucher ref.") then begin
                CreditVoucher.Status := CreditVoucher.Status::Cancelled;
                CreditVoucher.Modify;
              end;
            end;
        end;

        SaleLinePOS.Silent := true;
        SaleLinePOS.Validate("No.",AuditRoll."No.");

        if (AuditRoll."No." <> '*') and (AuditRoll.Type <> AuditRoll.Type::Payment) and (AuditRoll."Unit of Measure Code" <> '') then
          SaleLinePOS.Validate("Unit of Measure Code",AuditRoll."Unit of Measure Code");
        SaleLinePOS."Posting Group" := AuditRoll."Posting Group";
        SaleLinePOS."Qty. Discount Code" := AuditRoll."Qty. Discount Code";
        //-NPR5.30 [268750]
        //Ekspeditionslinie.Description := STRSUBSTNO( txtTilbagef�rt, RevRulle.Description, Sale."Salesperson Code" );
        SaleLinePOS.Description := AuditRoll.Description;
        //+NPR5.30 [268750]
        if (AuditRoll."No." <> '*') and (AuditRoll.Type <> AuditRoll.Type::Payment) then begin
          SaleLinePOS.Silent := true;
          SaleLinePOS.Validate(Quantity,-AuditRoll.Quantity);
          SaleLinePOS.Silent := false;
        end;

        // Reverse sales infor into the salesline
        ReverseAuditInfoToSalesLine(SaleLinePOS,AuditRoll);

        //Reverse Pepper Credit Card Payment
        //-NPR5.20
        if SaleLinePOS.Type = SaleLinePOS.Type::Payment then begin
          PepperTransactionRequest.Reset;
          PepperTransactionRequest.SetCurrentKey("Sales Ticket No.");
          PepperTransactionRequest.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
          PepperTransactionRequest.SetRange("Processing Type",PepperTransactionRequest."Processing Type"::PAYMENT);
          PepperTransactionRequest.SetRange(Successful,true);
          PepperTransactionRequest.SetRange(Reversed,false);
          AmountItt := PepperTransactionRequest.Count;
          if AmountItt > 0 then begin
        //-NPR5.46 [290734]
            Error(TextRefundMandatory, AmountItt, AuditRoll."Sales Ticket No.");
        //    IF CONFIRM(STRSUBSTNO(TextConfirmTerminal,AmountItt,AuditRoll."Sales Ticket No.")) THEN BEGIN
        //      IF PepperTransactionRequest.FINDLAST THEN
        //        REPEAT
        //          PepperProtocol.InitializeProtocol();
        //          //-NPR5.35 [284379]
        //          //IF NOT PepperProtocol.Init(PepperTransactionRequest."Amount Output", Ekspeditionslinie,
        //          IF NOT PepperProtocol.Init(PepperTransactionRequest."Amount Output",PepperTransactionRequest."Cashback Amount",SaleLinePOS,
        //          //+NPR5.35 [284379]
        //            0,0,FALSE)
        //          THEN BEGIN
        //            ERROR(TextRefundError);
        //          END;
        //          PepperProtocol.SetReverseTransactionRequestEntryNo(PepperTransactionRequest."Entry No.");
        //          PepperProtocol.SetTransaction(4);
        //          COMMIT;
        //          IF NOT PepperProtocol.SendTransaction THEN
        //            ERROR(TextRefundError);
        //          SaleLinePOS."Amount Including VAT" := -PepperProtocol.GetCapturedAmount;
        //          SaleLinePOS.VALIDATE("Currency Amount",-PepperProtocol.GetCapturedAmount);
        //          SaleLinePOS."Cash Terminal Approved" := TRUE;
        //          COMMIT;
        //          CCTrans.RESET;
        //          CCTrans.SETCURRENTKEY("Register No.","Sales Ticket No.",Type);
        //          CCTrans.SETRANGE("Register No.",SaleLinePOS."Register No.");
        //          CCTrans.SETRANGE("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        //          CCTrans.SETRANGE(Type, 0);
        //          CCTrans.SETRANGE("No. Printed", 0);
        //          IF (NOT Register."Terminal Auto Print") AND (NOT CCTrans.ISEMPTY) THEN BEGIN
        //            CCTrans.PrintTerminalReceipt(FALSE);
        //          END;
        //        UNTIL PepperTransactionRequest.NEXT(-1) = 0;
        //    END ELSE
        //      ERROR(TextRefundMandatory);
        //+NPR5.46 [290734]
          end;
        end;

        //+NPR5.20

        // Sporing af tilbagef�rsel s� betalingstyper kan genfindes og �bnes under bogf�ring
        SaleLinePOS."Return Sale Register No." := AuditRoll."Register No.";
        SaleLinePOS."Return Sale Sales Ticket No." := AuditRoll."Sales Ticket No.";
        SaleLinePOS."Return Sales Sales Type" := AuditRoll."Sale Type";
        SaleLinePOS."Return Sale Line No." := AuditRoll."Line No.";
        SaleLinePOS."Return Sale No." := AuditRoll."No.";
        SaleLinePOS."Return Sales Sales Date" := AuditRoll."Sale Date";
        if AuditRoll."No." <> '*' then begin
          SaleLinePOS.Silent := true;
          //Ekspeditionslinie.VALIDATE( "Unit Price", RevRulle."Unit Price" );
          SaleLinePOS.Silent := true;
        end;
        SaleLinePOS.Modify;
    end;

    procedure CheckPostingDateAllowed(TestDate: Date): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        PostingAllowedFrom: Date;
        PostingAllowedTo: Date;
    begin
        //CheckBogfDatoTilladt
        GeneralLedgerSetup.Get;
        if UserId <> '' then
          if UserSetup.Get(UserId) then begin
            PostingAllowedFrom := UserSetup."Allow Posting From";
            PostingAllowedTo := UserSetup."Allow Posting To";
          end;
        if (PostingAllowedFrom = 0D) and (PostingAllowedTo = 0D) then begin
          PostingAllowedFrom := GeneralLedgerSetup."Allow Posting From";
          PostingAllowedTo := GeneralLedgerSetup."Allow Posting To";
        end;
        if PostingAllowedTo = 0D then
          //-NPR5.40 [307717]
          //PostingAllowedTo := 31129999D;
          PostingAllowedTo := DMY2Date(31,12,9999);
          //+NPR5.40 [307717]
        if (TestDate < PostingAllowedFrom) or (TestDate > PostingAllowedTo) then
          exit(false)
        else
          exit(true);
    end;

    procedure EditPostingDateAllowed(UserIDCode: Code[20];Date2: Date)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
    begin
        //EditBogfDatoTilladt
        if UserIDCode <> '' then begin
          if UserSetup.Get(UserIDCode) then begin
            if UserSetup."Allow Posting From" > Date2 then begin
              UserSetup."Allow Posting From" := Date2;
              UserSetup.Modify(true);
            end;
            if UserSetup."Allow Posting To" < Date2 then begin
              UserSetup."Allow Posting To" := Date2;
              UserSetup.Modify(true);
            end;
          end;
        end;

        GeneralLedgerSetup.Get;
        if GeneralLedgerSetup."Allow Posting From" > Date2 then begin
          GeneralLedgerSetup."Allow Posting From" := Date2;
          GeneralLedgerSetup.Modify(true);
        end;
        if GeneralLedgerSetup."Allow Posting To" < Date2 then begin
          GeneralLedgerSetup."Allow Posting To" := Date2;
          GeneralLedgerSetup.Modify(true);
        end;
    end;

    procedure TestAndSet(var ToCode: Code[20];FromCode: Code[20])
    begin
        if FromCode <> '' then
          ToCode := FromCode;
    end;
}

