codeunit 6014567 "Report - Debet Receipt"
{
    // Report - Debet Receipt
    //  Work started by Jerome Cader on 02-04-2013
    //  Implements the functionality of the Debet Receipt report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060111.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Audit Roll".
    // 
    // 
    // NPR4.13/MMV/20150225 CASE 205001 Added control character for correct logo printing on all epson drivers.
    //                                  Fixed bug with comments printing twice (The second line was meant for >40 character comments).
    //                                  Fixed bug with filtering on Audit Roll Detail lines.
    //                                  Fixed bug in PrintRegister so the 2nd print has a logo as well.
    // VRT1.01/MMV/20150522 CASE 204723 Added variety code from CU 6014560 and removed old. Renamed som old variables to work.
    // NPR4.10/MMV/20150416 CASE 211666 Added lookup in General Ledger Setup for the currency code text instead of hardcode to 'DKK'.
    //                                  Added missing norwegian translation to text constant.
    // NPR4.10/MMV/20150611 CASE 216060 Changed customer signing text constants.
    // NPR5.26/MMV /20160916 CASE 249408 Moved control codes from captions to in-line strings.
    // NPR5.27/MMV /20161024 CASE 256102 Conditional reg. no. print.
    // NPR5.29/MMV /20161128 CASE 258787 Fixed variant description being printed to many times.
    //                                   Shop header info like the normal sales receipt.
    // NPR5.30/BHR /20170208 CASE 265676 Removed size on variable BonInfo to prevent error for different translation
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption

    TableNo = "Audit Roll";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        AuditRoll.CopyFilters(Rec);
        GetRecords;

        Printer.SetFont('A11');
        Printer.SetBold(false);

        for CurrPageNo := 1 to 1 do begin
          // 0. AuditRoll
          AuditRollOnAfterGetRecord();
          // 1. Integer
          PrintIntegerLoop;
        end;
    end;

    var
        Printer: Codeunit "RP Line Print Mgt.";
        AuditRoll: Record "Audit Roll";
        RetailConfiguration: Record "Retail Setup";
        CurrPageNo: Integer;
        LoopCounter: Record "Integer";
        RetailFormCode: Codeunit "Retail Form Code";
        NoOfCopies: Integer;
        Salesperson: Record "Salesperson/Purchaser";
        "/--------": Integer;
        "NP Retail Configuration": Record "Retail Setup";
        flg2ndLoop: Boolean;
        VariantDescription: Text[50];
        BonInfo: Text;
        BonInfo2: Text[50];
        QuantityAmountTxt: Text[50];
        ColorSizeTxt: Text[50];
        Text0000: Label 'A';
        Text0001: Label 'G';
        Text0002: Label 'Telephone: ';
        Text0003: Label 'Fax: ';
        Text0004: Label 'VAT: ';
        Text0005: Label 'No.';
        Text0006: Label 'Description';
        Text0007: Label 'Quantity';
        Text0008: Label 'Amount';
        Text0009: Label '%2 - Sales Ticket %1/%4 - %3';
        Text0010: Label 'Salesperson: %1';
        Text0011: Label 'Customer signing:';
        Text0012: Label 'Signature';
        Text0013: Label 'Customer: ';
        Text0014: Label 'Account no.: ';
        Text0015: Label 'Reg.:';
        Text0016: Label 'Invoice: ';
        Text0017: Label 'Lev. ';
        Text0018: Label 'Credit Memo invoice';
        Text0019: Label 'Return order';
        Text0020: Label 'P';
        Text0021: Label 'Reference:';
        Text0022: Label 'Att.: ';
        Text0023: Label 'Posted invoice: ';
        "/---------": Integer;
        Register: Record Register;
        Customer: Record Customer;
        AuditRollPayment: Record "Audit Roll";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        AuditRollPayment2: Record "Audit Roll";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        AuditRollSale: Record "Audit Roll";
        AuditRollDetails: Record "Audit Roll";
        NoTxt: Label 'No.';
        DescriptionTxt: Label 'Description';
        QuantityTxt: Label 'Quantity';
        AmountTxt: Label 'Amount';
        IaltInclVATTxt: Label 'Total %1 incl. VAT';
        VATTxt: Label 'VAT';
        IaltexVATTxt: Label 'Total %1 ex. VAT';
        LineDiscountPctTxt: Label 'Line Discount pct.';
        LineDiscountAmtTxt: Label 'Line Discount Amount';

    procedure PrintIntegerLoop()
    begin
        // Integer - Properties
        LoopCounter.SetCurrentKey(Number);
        LoopCounter.SetFilter(Number, '1..2');

        if LoopCounter.FindSet then repeat
          // Integer - OnAfterGetRecord()
          if LoopCounter.Number = 2 then
            flg2ndLoop := true
          else
            flg2ndLoop := false;

            // 2.Register
            PrintRegister;

            // 2.Customer
            PrintCustomer;

            // 2. Audit Roll
            PrintAuditRollSale;

          Printer.SetFont('Control');
          //-NPR5.26 [249408]
          //Printer.AddLine(Text0020);
          Printer.AddLine('P');
          //+NPR5.26 [249408]

        until LoopCounter.Next = 0;
    end;

    procedure PrintRegister()
    begin
        // Register - Properties
        //-NPR5.29 [258787]
        // Register.SETCURRENTKEY("Register No.");
        // Register.SETRANGE("Register No.", AuditRoll."Register No.");
        if not Register.Get(AuditRoll."Register No.") then
          exit;
        //+NPR5.29 [258787]

        Printer.SetFont('Control');
        //-NPR5.29 [258787]
        //IF Register.FINDSET THEN REPEAT
        //+NPR5.29 [258787]

        if Register."Money drawer attached" and Register."Money drawer - open on special" and
        (Register."Receipt Printer Type" = Register."Receipt Printer Type"::Samsung) then begin
          Printer.AddLine('A');
        end;

        if "NP Retail Configuration"."Logo on Sales Ticket" and (Register."Receipt Printer Type"=
        Register."Receipt Printer Type"::Samsung) then begin
          Printer.AddLine('G');
        end;

        if Register."Money drawer attached" and Register."Money drawer - open on special" and
        (Register."Receipt Printer Type" = Register."Receipt Printer Type"::"TM-T88") then begin
          Printer.AddLine('A');
        end;

        if "NP Retail Configuration"."Logo on Sales Ticket" and (Register."Receipt Printer Type"=
        Register."Receipt Printer Type"::"TM-T88") then begin
          Printer.AddLine('G');
          Printer.AddLine('h');
        end;

        Printer.SetFont('A11');
        //-NPR5.29 [258787]
        Printer.AddLine(Register.Name);
        if StrLen(Register."Name 2") > 0 then
          Printer.AddLine(Register."Name 2");
        Printer.AddLine(Register.Address);
        Printer.AddLine(Register."Post Code" + ' ' + Register.City);
        if StrLen(Register."Phone No.") > 0 then
          Printer.AddLine(Register.FieldCaption("Phone No.") + ' ' + Register."Phone No.");
        if StrLen(Register."Bank Registration No.") > 0 then
          Printer.AddTextField(1,0, Text0015 + Register."Bank Registration No.");
        if StrLen(Register."Bank Account No.") > 0 then
          Printer.AddTextField(2,0, Text0014 + Register."Bank Account No.");
        if StrLen(Register."VAT No.") > 0 then
          Printer.AddLine(Register.FieldCaption("VAT No.") + ' ' + Register."VAT No.");
        if StrLen(Register."E-mail") > 0 then
          Printer.AddLine(Register.FieldCaption("E-mail") + ' ' + Register."E-mail");
        if StrLen(Register.Website) > 0 then
          Printer.AddLine(Register.Website);

        // Printer.AddTextField(1,0,Register.Name);
        // Printer.AddTextField(1,0,Register.Address);
        // Printer.AddTextField(1,0,Register."Post Code"+' ' + Register.City);
        // Printer.AddTextField(1,0,Text0002+Register.Telephone);
        // //-NPR5.27 [256102]
        // IF STRLEN(Register."Bank Registration No.") > 0 THEN
        //  Printer.AddTextField(1,0,Text0015+Register."Bank Registration No.");
        // //+NPR5.27 [256102]
        // Printer.AddTextField(2,0,Text0014+Register."Bank Account No.");
        // Printer.AddTextField(1,0,Text0003+Register.Fax);
        // Printer.AddTextField(1,0,Text0004+Register."VAT No.");

        //UNTIL Register.NEXT = 0;
        //+NPR5.29 [258787]
    end;

    procedure PrintCustomer()
    begin
        // Customer - Properties
        Customer.SetCurrentKey("No.");
        Customer.SetRange("No.", AuditRoll."Customer No.");

        if Customer.FindSet then repeat
        // Customer, Body (1)
        Printer.SetPadChar('_');
        Printer.AddLine('');
        Printer.SetPadChar(' ');

        // Customer, Body (2)
        Printer.SetFont('A11');
        Printer.AddTextField(1,0,Text0013+Customer."No.");
        Printer.AddTextField(1,0,Customer.Name);
        Printer.AddTextField(1,0,Customer.Address);
        Printer.AddTextField(1,0,Customer."Post Code"+' '+Customer.City);

        // Customer, Body (3) - OnPreSection()
        if AuditRoll.Reference<>'' then begin
          Printer.AddTextField(1,0,Text0021+AuditRoll.Reference);
        end;

          // 3 Audit Roll
          PrintAuditRollPayment;

          // 3 Audit Roll
          PrintAuditRollPayment2;

        until Customer.Next = 0;

        Printer.AddLine('');
    end;

    procedure PrintAuditRollPayment()
    begin
        // Audit Roll Payment - Properties
        AuditRollPayment.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date");
        AuditRollPayment.Ascending(true);
        AuditRollPayment.SetRange(Type, AuditRollPayment.Type::Comment);
        AuditRollPayment.SetRange("Sale Type", AuditRollPayment."Sale Type"::"Debit Sale");

        AuditRollPayment.SetRange("Register No.", AuditRoll."Register No.");
        AuditRollPayment.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");

        if AuditRollPayment.FindSet then begin //MaxIteration = 1

          ARPaymentOnAfterGetRecord;

            // 4 Sales Header
            PrintSalesHeader;

            // 4 Sales Invoice Header
            PrintSalesInvoiceHeader;

            // 4 Sales Shipment Header
            PrintSalesShipmentHeader;

            // 4 Return Receipt Header
            PrintReturnReceiptHeader;

        end;
    end;

    procedure PrintSalesHeader()
    begin
        // Sales Header - Properties
        SalesHeader.SetCurrentKey("Document Type","No.");
        SalesHeader.SetRange("No.", AuditRollPayment."Allocated No.");

        if SalesHeader.FindSet then repeat
          // Sales Header, Body (1)
          Printer.SetFont('A11');
          Printer.AddTextField(1,0,Format(SalesHeader."Document Type")+': '+Format(SalesHeader."No."));
          Printer.AddTextField(1,0,Text0021 + SalesHeader."Your Reference");
          Printer.AddTextField(1,0,Text0022 + SalesHeader."Bill-to Contact");
        until SalesHeader.Next = 0;
    end;

    procedure PrintSalesInvoiceHeader()
    begin
        // Sales Invoice Header - Properties
        SalesInvoiceHeader.SetCurrentKey("No.");
        SalesInvoiceHeader.SetRange("Sales Ticket No.", AuditRollPayment."Sales Ticket No.");

        if SalesInvoiceHeader.FindSet then repeat
          // Sales Invoice Header, Body (1)
          Printer.SetFont('A11');
          Printer.AddTextField(1,0,Text0023 + Format(SalesInvoiceHeader."No."));
          Printer.AddTextField(1,0,Text0021 + SalesInvoiceHeader."Your Reference");
          Printer.AddTextField(1,0,Text0022 + SalesInvoiceHeader."Bill-to Contact");
        until SalesInvoiceHeader.Next = 0 ;
    end;

    procedure PrintSalesShipmentHeader()
    begin
        // Sales Shipment Header - Properties
        SalesShipmentHeader.SetCurrentKey("No.");
        SalesShipmentHeader.SetRange("Sales Ticket No.", AuditRollPayment."Sales Ticket No.");

        if SalesShipmentHeader.FindSet then repeat
          // Sales Shipment Header, Body (1)
          Printer.SetFont('A11');
          Printer.AddTextField(1,0,Text0017+Format(SalesShipmentHeader."No."));
          Printer.AddTextField(1,0,Text0022+SalesShipmentHeader."Your Reference");
        until SalesShipmentHeader.Next = 0;
    end;

    procedure PrintReturnReceiptHeader()
    begin
        // Return Receipt Header - Properties
        ReturnReceiptHeader.SetCurrentKey("No.");
        ReturnReceiptHeader.SetRange("Sales Ticket No.", AuditRollPayment."Sales Ticket No.");

        if ReturnReceiptHeader.FindSet then repeat
          // Return Receipt Header, Body (1)
          Printer.SetFont('A11');
          Printer.AddTextField(1,0,Text0019+Format(ReturnReceiptHeader."No."));
          Printer.AddTextField(1,0,Text0022+ReturnReceiptHeader."Your Reference");
        until ReturnReceiptHeader.Next = 0;
    end;

    procedure PrintAuditRollPayment2()
    begin
        // Audit Roll Payment 2 - Properties
        AuditRollPayment2.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date");
        AuditRollPayment2.Ascending(true);
        AuditRollPayment2.SetRange(Type, AuditRollPayment2.Type::"Debit Sale");
        AuditRollPayment2.SetRange("Sale Type", AuditRollPayment2."Sale Type"::Comment);

        AuditRollPayment2.SetRange("Register No.", AuditRoll."Register No.");
        AuditRollPayment2.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");

        if AuditRollPayment2.FindSet then repeat

            // 4 Sales Cr.Memo Header
            PrintSalesCrMemoHeader;
        until AuditRollPayment2.Next = 0;
    end;

    procedure PrintSalesCrMemoHeader()
    begin
        // Sales Cr.Memo Header - Properties
        SalesCrMemoHeader.SetCurrentKey("No.");
        SalesCrMemoHeader.SetRange("Sales Ticket No.", AuditRollPayment2."Sales Ticket No.");

        if SalesCrMemoHeader.FindSet then repeat
          // Sales Cr.Memo Header, Body (1)
          Printer.SetFont('A11');
          Printer.AddTextField(1,0,Text0018+Format(SalesCrMemoHeader."No."));
          Printer.AddTextField(1,0,Text0022+SalesCrMemoHeader."Your Reference");
        until SalesCrMemoHeader.Next = 0;
    end;

    procedure PrintAuditRollSale()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
    begin
        // Audit Roll Sale - Properties
        AuditRollSale.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type,"No.");
        AuditRollSale.SetRange("Register No.", AuditRoll."Register No.");
        AuditRollSale.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");

        if AuditRollSale.FindSet then begin
          // Audit Roll Sale, Header (1)
          Printer.AddTextField(1,0, NoTxt);
          Printer.AddTextField(2,2, ' ' + QuantityTxt);
          Printer.AddTextField(3,2, ' ' + AmountTxt);

          Printer.SetPadChar('_');
          Printer.AddLine('');
          Printer.SetPadChar(' ');

        repeat

          // 3 Audit Roll
          PrintAuditRollDetails;

        until AuditRollSale.Next = 0;
          AuditRollSale.CalcSums("Amount Including VAT", Amount);

          // Audit Roll Sale, Footer (2)
          Printer.SetFont('B21');
          Printer.SetBold(true);
          //-NPR4.10
          //Printer.AddTextField(1,0, IaltDKKInclVATTxt);
          if GeneralLedgerSetup.Get then
            CurrencyCode := GeneralLedgerSetup."LCY Code";
          Printer.AddTextField(1,0, StrSubstNo(IaltInclVATTxt,CurrencyCode));
          //+NPR4.10
          Printer.AddDecimalField(2,2, AuditRollSale."Amount Including VAT");
          Printer.SetFont('A11');
          Printer.SetBold(false);
          Printer.AddTextField(1,0, VATTxt);
          Printer.AddDecimalField(2,2, AuditRollSale."Amount Including VAT" - AuditRollSale.Amount);
          //-NPR4.10
          //Printer.AddTextField(1,0, IaltDKKexVATTxt);
          Printer.AddTextField(1,0, StrSubstNo(IaltexVATTxt,CurrencyCode));
          //+NPR4.10
          Printer.AddDecimalField(2,2, AuditRollSale.Amount);
          Printer.AddLine('');

          // Audit Roll Sale, Footer (3) - OnPreSection()
          if flg2ndLoop then begin
            Printer.SetFont('A11');
            Printer.SetBold(false);
            Printer.AddTextField(1,1, Text0011);
            Printer.AddLine('');
            Printer.AddLine('');
            Printer.SetPadChar('.');
            Printer.AddLine('');
            Printer.SetPadChar(' ');
            Printer.AddTextField(1,1, Text0012);
          end;

          // Audit Roll Sale, Footer (4)
          Printer.SetFont('A11');
          Printer.SetBold(false);
          Printer.AddLine('');
          Printer.AddTextField(1,1, BonInfo);
          Printer.AddTextField(1,1, BonInfo2);
        end;
    end;

    procedure PrintAuditRollDetails()
    begin
        // Audit Roll Details - Properties

        AuditRollDetails.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date");
        AuditRollDetails.SetRange("Register No.", AuditRollSale."Register No.");
        AuditRollDetails.SetRange("Sales Ticket No.", AuditRollSale."Sales Ticket No.");
        //-NPR4.13
        //AuditRollDetails.SETFILTER("Sale Type",'%1',AuditRollSale."Sale Type"::Salg);
        AuditRollDetails.SetRange("Sale Type", AuditRollSale."Sale Type");
        //+NPR4.13
        AuditRollDetails.SetRange("Line No.", AuditRollSale."Line No.");

        if AuditRollDetails.FindSet then repeat
          ARDetailsOnAfterGetRecord();
          // Audit Roll Details, Body (1) - OnPreSection()
          if (AuditRollDetails.Type <> AuditRollDetails.Type::Comment)
                   and (AuditRollDetails."Sale Type"<> AuditRollDetails."Sale Type"::Comment) then begin

            Printer.SetFont('A11');
            Printer.SetBold(false);
            Printer.AddTextField(1,0, AuditRollDetails.Description);
            Printer.AddTextField(1,0, AuditRollDetails."No.");
            Printer.AddTextField(2,2, QuantityAmountTxt);
            Printer.AddDecimalField(3,2, AuditRollDetails."Amount Including VAT");

          end;


          // Audit Roll Details, Body (2) - OnPreSection()
          if ((AuditRollDetails.Type = AuditRollDetails.Type::Comment)
             or (AuditRollDetails."Sale Type" = AuditRollDetails."Sale Type"::Comment))
               and (AuditRollDetails.Description <> '') then begin
            Printer.AddTextField(1,0,CopyStr(AuditRollDetails.Description,1,40));
          end;


           // Audit Roll Details, Body (3) - OnPreSection()
           //-NPR4.13
           if ((AuditRollDetails.Type = AuditRollDetails.Type::Comment)
           //       OR (AuditRollDetails."Sale Type" = AuditRollDetails."Sale Type"::Bemærkning) AND
             or (AuditRollDetails."Sale Type" = AuditRollDetails."Sale Type"::Comment))
             and (StrLen(AuditRollDetails.Description)>40) then begin
             Printer.AddTextField(1,0,CopyStr(AuditRollDetails.Description,1,41));
           end;
           //+NPR4.13

          // Audit Roll Details, Body (4) - OnPreSection()
          if "NP Retail Configuration"."Description 2 on receipt"
                                   and (AuditRollDetails."Description 2"<>'') then begin
            Printer.AddTextField(1,0, ' ' + AuditRollDetails."Description 2");
          end;

          // Audit Roll Details, Body (5) - OnPreSection()
          if VariantDescription <> '' then begin
            Printer.AddTextField(1,0, ' ' + VariantDescription);
          end;

          // Audit Roll Details, Body (6) - OnPreSection()
          //-VRT1.01
          //IF ColorSizeTxt<>'' THEN BEGIN
          //  Printer.AddTextField(1,0, ' ' + ColorSizeTxt);
          //END;
          //+VRT1.01

          // Audit Roll Details, Body (7) - OnPreSection()
          if (AuditRollDetails."Line Discount Amount"<>0) and (not "NP Retail Configuration".SamletBonRabat) then begin
            Printer.AddTextField(1,0, ' ' + LineDiscountPctTxt);
            Printer.AddTextField(2,0, Format(AuditRollDetails."Line Discount %",0,'<Precision,2:2><Standard Format,0>')+'%');
            Printer.AddTextField(1,0, ' ' + LineDiscountAmtTxt);
            Printer.AddDecimalField(2,0, AuditRollDetails."Line Discount Amount");
          end;

          Printer.AddLine('');
        until AuditRollDetails.Next = 0;
    end;

    procedure "--- Record Triggers ---"()
    begin
    end;

    procedure AuditRollOnAfterGetRecord()
    var
        "Salesperson/Purchaser": Record "Salesperson/Purchaser";
    begin
        // Audit Roll - OnAfterGetRecord()
        BonInfo :=StrSubstNo(Text0009,AuditRoll."Sales Ticket No.",
                                Format(AuditRoll."Sale Date"),Format(AuditRoll."Closing Time"),AuditRoll."Register No.");

        if "NP Retail Configuration"."Salesperson on Sales Ticket" and
         "Salesperson/Purchaser".Get(AuditRoll."Salesperson Code") then
          BonInfo2 := StrSubstNo(Text0010,CopyStr("Salesperson/Purchaser".Name, 1,30))
        else
          BonInfo2 := StrSubstNo(Text0010,CopyStr(AuditRoll."Salesperson Code",1,30));
    end;

    procedure ARPaymentOnAfterGetRecord()
    begin
        // Audit Roll Payment - OnAfterGetRecord()
        "NP Retail Configuration".Get();
    end;

    procedure ARDetailsOnAfterGetRecord()
    var
        ItemVariant: Record "Item Variant";
    begin
        // Audit Roll Details - OnAfterGetRecord()

        if "NP Retail Configuration"."Unit Price on Sales Ticket" and (AuditRollDetails.Quantity <> 0) then
          QuantityAmountTxt := Format(AuditRollDetails.Quantity)+' * '+
          Format((AuditRollDetails."Amount Including VAT"+AuditRollDetails."Line Discount Amount") / AuditRollDetails.Quantity,
                    0,'<Precision,2:2><Standard Format,0>')
        else
          QuantityAmountTxt := Format(AuditRollDetails.Quantity);

        with AuditRollDetails do begin
          //Variety
          if ItemVariant.Get("No.", "Variant Code") and
             ((ItemVariant."Variety 1" <> '') or
              (ItemVariant."Variety 2" <> '') or
              (ItemVariant."Variety 3" <> '') or
              (ItemVariant."Variety 4" <> '')) then begin
            VariantDescription := ItemVariant.Description;
          end;
        end;

        //-NPR5.29 [258787]
        // IF VariantDescription = '' THEN
        //  VariantDescription := ColorDesc + SizeDesc;
        //
        // IF VariantDescription <> '' THEN
        //  Printer.AddLine(VariantDescription);
        //+NPR5.29 [258787]
    end;

    procedure "-- Init --"()
    begin
    end;

    procedure GetRecords()
    begin
        AuditRoll.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type,"No.");
        AuditRoll.FindSet;

        // Report - OnPreReport()
        "NP Retail Configuration".Get();
    end;
}

