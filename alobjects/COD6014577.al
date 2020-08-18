codeunit 6014577 "Report - Tax Free Receipt"
{
    // Report - Tax Free Receipt
    //  Work started by Jerome Cader on 14-08-2013
    //  Implements the functionality of the Tax Free Receipt.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6014628.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Audit Roll".
    // 
    // NPR4.15/MMV/20150916 CASE 222579 Changed text constant company name from 'Tax Free Worldwide-Denmark ApS' to 'Premier Tax Free'
    //                                  and website/e-mail text constants.
    // 
    // NPR4.18/MMV/20160210 CASE 224257 Removed all code. Only used to set the printer in Object Output Selection now.
    //                                  all tax free logic is now handled in CU 6014477.
    // 
    // NPR5.23/MMV/20160427 CASE 237927 Restored object with changes to make it work in latest release,
    //                                  To be used as a fallback print whenever the new tax free web service fails.
    // NPR5.23/JDH /20160518 CASE 240916 Removed unused variables
    // NPR5.26/MMV /20160705 CASE 243285 Added support for newer offline barcode standard for use with faroe islands.
    //                                   Removed plainly deprecated code.
    //                                   Added missing fill on SaldoBarcode compared to latest 6.2 release.
    //                                   Removed overwrite on Saldo compared to latest 6.2 release.
    // NPR5.29/MMV /20161216 CASE 241549 Removed deprecated print/report code.
    // NPR5.30/MMV /20170131 CASE 261964 Added support for new tax free module.
    //                                   Fixed bug in barcode2 for faroe islands.
    // NPR5.36/TJ  /20170921 CASE 286283 Renamed variables/function with danish specific letter into english
    //                                   Removed unused variables
    // NPR5.40/MMV /20180116 CASE 293106 Refactored tax free module.
    // NPR5.43/JDH /20180702 CASE 321012 Removed references to Color and Size - they are legacy

    TableNo = "Audit Roll";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        AuditRoll.CopyFilters(Rec);
        GetRecords;

        //-NPR5.30 [261964]
        GetOfflineParameters(AuditRoll."Register No.");
        //+NPR5.30 [261964]


        Printer.SetFont('A11');

        for CurrPageNo := 1 to 1 do begin
          // 0. AuditRoll
          AuditRollOnPreDataItem();
          AuditRollOnAfterGetRecord();
          PrintAuditRoll();
            // 1. Integer
            PrintIntegerLoop;
          // 0. Integer
          PrintTaxFree();
        end;

        Printer.SetFont('A11');
        Printer.AddLine('');
        Printer.SetFont('Control');
        Printer.AddLine(Text10000);
    end;

    var
        Printer: Codeunit "RP Line Print Mgt.";
        AuditRoll: Record "Audit Roll";
        RetailConfiguration: Record "Retail Setup";
        CurrPageNo: Integer;
        LoopCounter: Record "Integer";
        Salesperson: Record "Salesperson/Purchaser";
        Item: Record Item;
        CompanyInfo: Record "Company Information";
        Saldo: Decimal;
        Betalt: Decimal;
        ReturAfrunding: Decimal;
        moms: Decimal;
        BonInfo: Code[50];
        BonDato: Date;
        Bontext: array [5] of Text[80];
        Retursalg: Boolean;
        FRV_STR_txt: Text[100];
        udbetaling: Boolean;
        udbetaling_check: Boolean;
        beskrvTXT: Text[200];
        BonInfo2: Text[50];
        kasse: Record Register;
        stregkode: Code[20];
        sidstebon: Code[10];
        SaleLinePOSCount: Integer;
        BonKopiTXT: Text[30];
        betalingsvalg: Record "Payment Type POS";
        Fastkurs1: Decimal;
        ReturEuro: Decimal;
        EuroIAlt: Text[30];
        AntalAprisTXT: Text[100];
        BonnrGavekort: Code[20];
        IndbetalTXT: Text[50];
        DebitorFound: Boolean;
        udbetalTXT: Text[200];
        IndbetalTXT2: Text[50];
        IndbetalTXT3: Text[50];
        flgUdbetal: Boolean;
        flgTilgodebevis: Boolean;
        flgIndbetal: Boolean;
        flgRetursalg: Boolean;
        flgGavekort: Boolean;
        flgNoCopy: Boolean;
        KundeKvitTXT: Text[50];
        SerieNrTxt: Text[50];
        VareEnhedTxt: Text[50];
        Gavekorterprintet: Boolean;
        Tilgodebeviserprintet: Boolean;
        LevVarenrTxt: Text[50];
        Item2: Record Item;
        DebNameTxt: Text[100];
        DebNoTxt: Text[100];
        DebAdrTxt: Text[100];
        DebPostTxt: Text[100];
        NummerTxt: Text[30];
        oererund: Decimal;
        rundbrugt: Boolean;
        netto: Decimal;
        beloeb: Decimal;
        thisReg: Record Register;
        BonLinjer: Record "Retail Comment" temporary;
        negSaldo: Boolean;
        util: Codeunit Utility;
        UnitPriceInclDiscountTxt: Text[60];
        Register: Record Register;
        BonInfo3: Text[30];
        paymentType: Record "Payment Type POS";
        faxText: Text[30];
        cvrText: Text[30];
        Barcode1: Text[30];
        Barcode2: Text[30];
        retailformcode: Codeunit "Retail Form Code";
        SaldoBarcode: Decimal;
        refund: Decimal;
        letterPrice: Text[50];
        creditNo: Code[100];
        "Credit Card Transaction": Record "EFT Receipt";
        flgCreditCard: Boolean;
        "Company Information": Record "Company Information";
        Salgslinie: Record "Audit Roll";
        "NP Retail Configuration": Record "Retail Setup";
        TaxFree: Record "Integer";
        AuditRollSalesLines: Record "Audit Roll";
        AuditRollPaymentLines: Record "Audit Roll";
        AuditRollSLCurrReportSKIP: Boolean;
        Text10600002: Label 'Sales Ticket Copy No.';
        Text10600003: Label 'Fax No.:';
        Text10600004: Label 'Teleph. No.:';
        Text10600006: Label 'Recommended Price:';
        Text10600007: Label 'Serial No.';
        Text10600012: Label '%2 - Bon %1/%4 - %3';
        Text10600016: Label 'Discount:';
        Text10600017: Label 'Customer';
        TextNetto: Label 'unit price incl/disc.:';
        Text10600018: Label 'Vendor item no.:';
        TotalDiscountTxt: Label 'Receipt discount';
        Text10600026: Label 'Payment';
        cName: Label 'Name:';
        cAddress: Label 'Address:';
        cPostalCode: Label 'Postal Code:';
        cCountry: Label 'Country:';
        cPasNo: Label 'Passport or ID no.:';
        cCredit: Label 'Credit card no.:';
        cRealCredit: Label 'Credit card no.:';
        Text10000: Label 'P';
        DescriptionTxt: Label 'Description';
        AmountTxt: Label 'Amount';
        TotalTxt: Label 'Total';
        TotalLCYTxt: Label 'Total (LCY)';
        IncludedVatTxt: Label 'Included VAT';
        TotalEuroTxt: Label 'Total Euro';
        TaxTxt311: Label 'For retail export scheme only.';
        TaxTxt312: Label 'This is not a valid invoice.';
        TaxTxt321: Label 'Can only be used ';
        TaxTxt322: Label 'for Tax Free Refund.';
        TaxTxt41: Label 'PLEASE NOTE! ALWAYS HAVE YOUR ';
        TaxTxt42: Label ' TAX-FREE FORMS STAMPED BY CUSTOMS';
        TaxTxt43: Label ' BEFORE LEAVING THE EU!';
        TaxTxt51: Label 'Customer Declaration';
        TaxTxt52: Label 'Customer Details';
        TaxTxt71: Label 'For a refund to your credit card, ';
        TaxTxt72: Label ' please write your full credit card number';
        TaxTxt91: Label 'Refund options';
        TaxTxt92: Label '[ ] To credit card';
        TaxTxt93: Label 'Please complete your credit card number';
        TaxTxt94: Label '[ ] Donation to SOS childrens villages';
        TaxTxt1011: Label 'I understand that, when I present this form to ';
        TaxTxt1012: Label 'customs, I am declaring that I am exporting all ';
        TaxTxt1013: Label ' the goods (listed) on this form from the EU.';
        TaxTxt1014: Label 'I will delete any good listed that I decide to';
        TaxTxt1015: Label 'leave in the EU BEFORE I PRESENT THIS FORM';
        TaxTxt1016: Label ' TO CUSTOMS';
        TaxTxt102: Label 'Sign Here:';
        TaxTxt111: Label 'Retailers Declaration';
        TaxTxt1121: Label 'The information on this form is correct.';
        TaxTxt1122: Label ' ';
        TaxTxt113: Label 'Retailer''s signature:';
        TaxTxt1141: Label 'IMPORTANT';
        TaxTxt1142: Label 'This form must be fully completed. You must ';
        TaxTxt1143: Label 'present the goods and the vat refund document';
        TaxTxt1144: Label ' to customs, when you leave the EU.';
        TaxTxt1145: Label ' NO GOODS = NO REFUNDS';
        TaxTxt1211: Label 'For official use at export ';
        TaxTxt1212: Label 'from the EU';
        TaxTxt122: Label 'Signature:';
        TaxTxt123: Label 'Custom stamp';
        TaxTxt1241: Label 'Warning: It is a serious offence to change this';
        TaxTxt1242: Label ' form and make an untrue declaration to';
        TaxTxt1243: Label ' Customs and Excise, if goods are not exported';
        TaxTxt1244: Label ' from EU.';
        LOOPCurrReport_SKIP: Boolean;
        ARollPLPriceExVAT: Label 'Price excl. VAT DKK';
        ARollPLVat: Label 'VAT DKK';
        ARollPLAdminFee: Label 'Admin Fee DKK';
        ARollPLRefund: Label 'Refund Amount DKK';
        ShowSection: Boolean;
        Customer: Record Customer;
        NPRetailConfSP: Label 'Salesperson:';
        MerchantID: Text;
        CountryCode: Text;
        VATNumber: Text;
        Error_MissingParameters: Label 'Missing parameters for handler %1 on tax free unit %2';

    procedure PrintAuditRoll()
    begin
        // Audit Roll, Header (1)
        Printer.SetFont('Control');
        Printer.AddLine('m');

        // Audit Roll, Header (2) - OnPreSection()
        if "NP Retail Configuration".Get() then;

        //-243285 [243285]
        // IF thisReg.GET( AuditRoll."Register No." ) THEN BEGIN
        // flgÅbenkasse := TRUE;
        // IF (AuditRoll."Copy No.") < 0 THEN BEGIN
        //  //IF NOT thisReg."Money drawer - open on special" THEN BEGIN
        //    AuditTemp.SETRANGE("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        //    AuditTemp.SETRANGE(Description);
        //    AuditTemp.SETRANGE("Sale Type");
        //    AuditTemp.SETRANGE("No.",'DAN');
        //    IF AuditTemp.FIND('-') THEN BEGIN
        //      AuditTemp.SETRANGE("No.",'K');
        //      AuditTemp.SETFILTER("Amount Including VAT",'<0');
        //      flgÅbenkasse := AuditTemp.FIND('-');
        //    END;// Find
        //  //END; // IF "Money drawer - open on special"
        // END; // IF Copy No. = 0
        // END; // IF GET Register
        // IF ({thisReg."Money drawer attached" AND} flgÅbenkasse) THEN BEGIN
        //  // Audit Roll, Header (2)
        //  Printer.SetFont('Control');
        //  Printer.AddLine(Text10600000);
        // END;

        // Audit Roll, Header (3)
        // Printer.SetFont('Control');
        // Printer.AddLine('a');
        //+243285 [243285]

        // Audit Roll, Header (4) - OnPreSection()
        if ("NP Retail Configuration"."Logo on Sales Ticket")  then begin
          // Audit Roll, Header (4)
          Printer.SetFont('Control');
          Printer.AddLine('h');
        end;

        // Audit Roll, Header (5) - OnPreSection()
        if kasse.Get(AuditRoll."Register No.")then ;

        if ("NP Retail Configuration"."Name on Sales Ticket") then begin
          // Audit Roll, Header (5)
          Printer.SetFont('B21');
          Printer.SetBold(true);
          Printer.AddTextField(1,0,kasse.Name);
        end;

        // Audit Roll, Header (6) - OnPreSection()
        if ("NP Retail Configuration"."Name on Sales Ticket") and (kasse."Name 2"<>'') then begin
          // Audit Roll, Header (6)
          Printer.SetFont('A11');
          Printer.SetBold(false);
          Printer.AddTextField(1,0,kasse."Name 2");
        end;

        // Audit Roll, Body (7) - OnPreSection()
        if (kasse."Fax No." <> '') then
            faxText := Text10600003 else
            faxText := '';

        if (kasse."VAT No." <> '') then
           cvrText := 'CVR:' else
           cvrText := '';

        BonDato := Salgslinie."Sale Date";

        if ((Salgslinie."Sale Type" = Salgslinie."Sale Type"::"Out payment") and (Salgslinie."Line No."=1))
        then udbetaling_check:=true;

        stregkode:=AuditRoll."Sales Ticket No.";

        if (Salgslinie."Copy No.">-1) and ("NP Retail Configuration"."Copy No. on Sales Ticket") then
          BonKopiTXT:=Text10600002+Format(Salgslinie."Copy No."+1)
        else BonKopiTXT:='';

        // Audit Roll, Body (7)
        Printer.SetFont('A11');
        Printer.SetBold(false);
        Printer.AddTextField(1,0,kasse.Address);
        Printer.AddTextField(1,0,kasse."Post Code"+' '+kasse.City);
        Printer.AddTextField(1,0,Text10600004+Format(kasse."Phone No."));
        Printer.AddTextField(2,2,faxText+Format(kasse."Fax No."));
        Printer.AddTextField(1,0,kasse."E-mail");
        Printer.AddTextField(1,0,kasse.Website);
        Printer.AddTextField(1,0,cvrText+Format(kasse."VAT No."));
    end;

    procedure PrintIntegerLoop()
    begin
        // L¢kke - Properties
        LoopCounter.SetCurrentKey(Number);
        //-243285 [243285]
        //LoopCounter.SETFILTER(Number, '1..2');
        LoopCounter.SetFilter(Number, '1');
        //+243285 [243285]

        if LoopCounter.FindSet then repeat

          LOOPCurrReport_SKIP := false;

          // L¢kke - OnAfterGetRecord()
          LoopCounterOnAfterGetRecord();

          if not LOOPCurrReport_SKIP then begin
            // 2. Company Information
            PrintCompanyInformation;

            // 2. Audit Roll
            PrintAuditRollSalesLines;

            // 2. Audit Roll
            PrintAuditRollPaymentLines;

            // 2. NP Retail Configuration
            PrintNPRetailConfiguration;


           //NewPagePerRecord
           Printer.SetFont('A11');
           Printer.AddLine('');

          end //IF NOT LOOPCurrReport_SKIP

          //Printer.SetFont('Control');
          //Printer.AddLine(Text10000);


        until LoopCounter.Next = 0;
    end;

    procedure PrintCompanyInformation()
    begin
        // Company Information - OnPreDataItem()
        oererund:=0;

        // Company Information - OnAfterGetRecord()
        "Company Information".CalcFields(Picture);
    end;

    procedure PrintAuditRollSLHeader()
    var
        LocalDeb: Record Customer;
        LocalContact: Record Contact;
    begin
        // Salgslinie, Header (1) - OnPreSection()
        ShowSection := false;
        if (Salgslinie."Customer No." <> '') and RetailConfiguration."Show Customer info on ticket" then begin
          if LocalDeb.Get(Salgslinie."Customer No.") then begin
            DebNameTxt := LocalDeb.Name;
            DebNoTxt   := LocalDeb."No.";
            DebAdrTxt  := LocalDeb.Address;
            DebPostTxt := LocalDeb."Post Code"+' '+LocalDeb.City;
            ShowSection := true;
          end else if LocalContact.Get( Salgslinie."Customer No." ) then begin
            DebNameTxt := LocalContact.Name;
            DebNoTxt   := LocalContact."No.";
            DebAdrTxt  := LocalContact.Address;
            DebPostTxt := LocalContact."Post Code"+' '+LocalContact.City;
            ShowSection := true;
          end;
        end;
        if ShowSection then begin
          Printer.SetFont('A11');
          Printer.SetBold(false);
          Printer.AddTextField(1,0,Text10600017 + ' ' + DebNoTxt);
          Printer.AddTextField(1,0,DebNameTxt);
          Printer.AddTextField(1,0,DebAdrTxt);
          Printer.AddTextField(1,0,DebPostTxt);
        end;

        //Salgslinie, Header (2)
        Printer.SetFont('B21');
        Printer.SetBold(false);
        Printer.AddTextField(1,0,DescriptionTxt);
        Printer.AddTextField(2,2,AmountTxt);
        Printer.AddTextField(3,2,TotalTxt);
    end;

    procedure PrintAuditRollSalesLines()
    begin
        //Salgslinie - Properties
        AuditRollSalesLines.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type","Line No.");
        AuditRollSalesLines.Ascending(true);

        AuditRollSalesLines.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
        AuditRollSalesLines.SetRange("Register No.", AuditRoll."Register No.");
        AuditRollSalesLines.SetRange("Posting Date", AuditRoll."Posting Date");

        // Salgslinie - OnPreDataItem()
        BonnrGavekort:='';

        if AuditRollSalesLines.FindSet then begin
          PrintAuditRollSLHeader();
        repeat
         AuditRollSLCurrReportSKIP := false;
         AuditRollSLOnAfterGetRecord();
         if not AuditRollSLCurrReportSKIP then begin

          // Salgslinie, Body (3) - OnPreSection()
          udbetalTXT:='';
          if (AuditRollSalesLines."Sale Type"=AuditRollSalesLines."Sale Type"::"Out payment") then begin
            flgUdbetal:=true;
            flgNoCopy:=true;
            udbetalTXT:=Text10600026;

            if not (AuditRollSalesLines."Sale Type"=AuditRollSalesLines."Sale Type"::"Out payment")
                                and (AuditRollSalesLines."No."=thisReg."Gift Voucher Discount Account") then begin
              Printer.SetFont('A21');
              Printer.SetBold(false);
              Printer.AddLine(udbetalTXT);
            end;
          end;

          // Salgslinie, Body (4) - OnPreSection()
          if (AuditRollSalesLines."Sale Type" <> AuditRollSalesLines."Sale Type"::Deposit)
                    and (AuditRollSalesLines."Sale Type" <> AuditRollSalesLines."Sale Type"::Comment) then begin
            if not( (AuditRollSalesLines."Sale Type"=AuditRollSalesLines."Sale Type"::"Out payment") and
             (AuditRollSalesLines."No."=thisReg."Gift Voucher Discount Account") ) then begin

              //-NPR5.43 [321012]
              //IF AuditRollSalesLines."Variant Code" <> '' THEN
              //  Design := STRSUBSTNO('%1/%2/%3',AuditRollSalesLines."No.",AuditRollSalesLines.Color,AuditRollSalesLines.Size)
              //ELSE
              //  Design := AuditRollSalesLines."No.";
              //+NPR5.43 [321012]

              if (AuditRollSalesLines."Sale Type"=AuditRollSalesLines."Sale Type"::"Out payment") then
                beskrvTXT:=Format(AuditRollSalesLines."No.")+' '+AuditRollSalesLines.Description
              else
                beskrvTXT:=AuditRollSalesLines.Description;

              if RetailConfiguration."Unit Price on Sales Ticket" and (AuditRollSalesLines.Quantity <> 0) then
                AntalAprisTXT:=Format(AuditRollSalesLines.Quantity)+' * ' +
                               Format((AuditRollSalesLines."Amount Including VAT"
                               +AuditRollSalesLines."Line Discount Amount") / AuditRollSalesLines.Quantity,
                                               0,'<Precision,2:2><Standard Format,0>')
              else
                AntalAprisTXT:=Format(AuditRollSalesLines.Quantity);

              if AuditRollSalesLines."Line Discount Amount" <> 0 then
                beloeb := AuditRollSalesLines."Amount Including VAT"+AuditRollSalesLines."Line Discount Amount"
              else
                beloeb := AuditRollSalesLines."Amount Including VAT";

              if not RetailConfiguration."Sales Ticket Item" then
                NummerTxt := ''
              else
                NummerTxt := AuditRollSalesLines."No.";

              Printer.SetFont('B11');
              Printer.SetBold(false);
              Printer.AddTextField(2, 0, beskrvTXT);
              Printer.AddTextField(1, 0, ' ' + NummerTxt);
              Printer.AddTextField(2, 2, AntalAprisTXT);
              Printer.AddDecimalField(3, 2, beloeb);
            end;
          end;

          // Salgslinie, Body (5) - OnPreSection()
          if (AuditRollSalesLines.Type = AuditRollSalesLines.Type::Item) and Item.Get(AuditRollSalesLines."No.") then begin
            if RetailConfiguration."Recommended Price" and (Item."Unit List Price">0) then begin
              Printer.SetFont('B11');
              Printer.SetBold(false);
              Printer.AddLine(beskrvTXT);
              Printer.AddTextField(1,0,' '+Text10600006);
              Printer.AddDecimalField(2,2,Item."Unit List Price");
            end;
          end;

          // Salgslinie, Body (6) - OnPreSection()
          netto := 0;

          if (AuditRollSalesLines.Quantity <>0) then
            netto:= (AuditRollSalesLines."Amount Including VAT") / AuditRollSalesLines.Quantity;

          UnitPriceInclDiscountTxt := '';

          if netto <> 0 then
            UnitPriceInclDiscountTxt := '( ' + TextNetto + ' ' + Format(netto,0,'<Precision,2:2><Standard Format,0>') + ' )';

          //-NPR3.0f
          if AuditRollSalesLines."Line Discount Amount" <>0 then begin
          //+NPR3.0f
            Printer.SetFont('B11');
            Printer.SetBold(false);
            Printer.AddLine(beskrvTXT);
            Printer.AddTextField(1,0,' '+UnitPriceInclDiscountTxt);
            Printer.AddTextField(2,1,Text10600016);
            Printer.AddDecimalField(3,2,-1*AuditRollSalesLines."Line Discount Amount");
          end;

          // Salgslinie, Body (7) - OnPreSection()
          if (AuditRollSalesLines."Serial No."<>'') or (AuditRollSalesLines."Serial No. not Created"<>'') then begin
            SerieNrTxt:=Text10600007+Format(AuditRollSalesLines."Serial No.");
            if AuditRollSalesLines."Serial No. not Created"<>'' then begin
              SerieNrTxt:='Serienr: '+Format(AuditRollSalesLines."Serial No. not Created");
            end;

            Printer.SetFont('B11');
            Printer.SetBold(false);
            Printer.AddLine(' '+SerieNrTxt);
          end;

          //-NPR5.23 [240916]
        //  // Salgslinie, Body (8) - OnPreSection()
        //  FRV_STR_txt:='';
        //  farvetxt:='';
        //  st¢rrelseTXT:='';
        //
        //  IF variant1.GET(AuditRollSalesLines."No.",AuditRollSalesLines.Color,AuditRollSalesLines.Size) THEN BEGIN
        //     IF (variant1."Description - Color"<>Text10600008) THEN BEGIN
        //       farvetxt:=Text10600009+FORMAT(variant1."Description - Color");
        //       mellemrum:=' ';
        //       END
        //     ELSE
        //       mellemrum:='';
        //     IF (variant1."Description - Size"<>'') THEN st¢rrelseTXT:=Text10600010+FORMAT(variant1."Description - Size");
        //     END;
        //
        //  FRV_STR_txt:=farvetxt+mellemrum+st¢rrelseTXT;
        //
        //  IF FRV_STR_txt<>'' THEN BEGIN
        //    Printer.SetFont('B11');
        //    Printer.SetBold(FALSE);
        //    Printer.AddLine(' '+FRV_STR_txt);
        //  END;
          //+NPR5.23 [240916]

          // Salgslinie, Body (9) - OnPreSection()
          VareEnhedTxt:='';
          if (Format(AuditRollSalesLines."Unit of Measure Code")<>'') and RetailConfiguration."Item Unit on Expeditions" then
            VareEnhedTxt:='Enhed: '+Format(AuditRollSalesLines."Unit of Measure Code");
          if VareEnhedTxt<>'' then begin
            Printer.SetFont('B11');
            Printer.SetBold(false);
            Printer.AddLine(' '+VareEnhedTxt);
          end;

          // Salgslinie, Body (10) - OnPreSection()
          LevVarenrTxt:='';
          if Item2.Get(AuditRollSalesLines."No.") then begin
            if (Format(Item2."Vendor Item No.")<>'') and RetailConfiguration."Show vendoe Itemno." then
              LevVarenrTxt := Text10600018 + Format(Item2."Vendor Item No.");
          end;
          if LevVarenrTxt<>'' then begin
            Printer.SetFont('B11');
            Printer.SetBold(false);
            Printer.AddLine(' '+LevVarenrTxt);
          end;

          // Salgslinie, Body (11) - OnPreSection()
          if AuditRollSalesLines."Sale Type" = AuditRollSalesLines."Sale Type"::Comment then begin
            Printer.SetFont('B11');
            Printer.SetBold(false);
            Printer.AddLine(AuditRollSalesLines.Description);
          end;

          // Salgslinie, Body (12) - OnPreSection()
          if (AuditRollSalesLines."Sale Type"=AuditRollSalesLines."Sale Type"::Deposit) and
             (AuditRollSalesLines."No."=thisReg."Gift Voucher Account") then begin
            Printer.SetFont('B11');
            Printer.SetBold(false);
            Printer.AddTextField(1,0,AuditRollSalesLines.Description+' '+Format(AuditRollSalesLines."Discount Code"));
            Printer.AddDecimalField(2,2,AuditRollSalesLines."Amount Including VAT");
          end;

          // Salgslinie, Body (13) - OnPreSection()
          if AuditRollSalesLines."Sale Type" = AuditRollSalesLines."Sale Type"::Deposit then begin
            Clear(Customer);

            if (AuditRollSalesLines."Sale Type" = AuditRollSalesLines."Sale Type"::Deposit) then begin
              udbetaling_check:=true;

              if Customer.Get(AuditRollSalesLines."No.") then begin
                DebitorFound:=true;
                flgIndbetal:=true;
                IndbetalTXT:='Indbetaling';
                IndbetalTXT2:='på konto '+Format(AuditRollSalesLines."No.");
                IndbetalTXT3:=Format(AuditRollSalesLines."Buffer Document Type")+' '+AuditRollSalesLines."Buffer ID";
              end

              else begin
                IndbetalTXT:='Indbetaling:';
                if flgTilgodebevis then begin
                 IndbetalTXT:='';
                 IndbetalTXT3:='Udstedt:';
                end;
                if flgGavekort=true then
                  IndbetalTXT:='';
              end;
            end;

            if flgTilgodebevis and flgRetursalg then
              IndbetalTXT:='Afregning:';

            if not ( (AuditRollSalesLines."Sale Type"=AuditRollSalesLines."Sale Type"::Deposit) and
               (AuditRollSalesLines."No."=thisReg."Gift Voucher Account") ) then begin
               if not ( (IndbetalTXT='') and (IndbetalTXT2='') and (IndbetalTXT3='') ) then begin
                 Printer.SetFont('B21');
                 Printer.SetBold(false);
                 Printer.AddTextField(1,0,IndbetalTXT);
                 Printer.SetFont('B11');
                 Printer.AddTextField(1,0,IndbetalTXT2);
                 Printer.AddTextField(1,0,IndbetalTXT3);
               end;
            end;
          end;

          // Salgslinie, Body (14) - OnPreSection()
          if AuditRollSalesLines."Sale Type" = AuditRollSalesLines."Sale Type"::Deposit then begin
            Clear(Customer);

            if (AuditRollSalesLines."Sale Type" = AuditRollSalesLines."Sale Type"::Deposit) then begin
              udbetaling_check:=true;

              if Customer.Get(AuditRollSalesLines."No.") then begin
                DebitorFound:=true;
                flgIndbetal:=true;
                IndbetalTXT:='Indbetaling';
                IndbetalTXT2:='på konto '+Format(AuditRollSalesLines."No.");
                IndbetalTXT3:=Format(AuditRollSalesLines."Buffer Document Type")+' '+AuditRollSalesLines."Buffer ID";
              end else begin
                IndbetalTXT:='Indbetaling:';
                if flgGavekort=true then
                  IndbetalTXT:='';
              end;
            end;

            if flgTilgodebevis and flgRetursalg then
              IndbetalTXT:='Afregning:';

            if not ( (AuditRollSalesLines."Sale Type"=AuditRollSalesLines."Sale Type"::Deposit) and
               (AuditRollSalesLines."No."=thisReg."Gift Voucher Account") ) then begin
              Printer.SetFont('B11');
              Printer.SetBold(false);
              Printer.AddTextField(1,0,AuditRollSalesLines.Description+' '+Format(AuditRollSalesLines."Credit voucher ref."));
              Printer.AddDecimalField(2,2,AuditRollSalesLines."Amount Including VAT");
            end;
          end;

          // Salgslinie, Body (15) - OnPreSection()
          if DebitorFound then begin
            Printer.SetFont('B11');
            Printer.SetBold(false);
            Printer.AddLine(Customer.Address);
            Printer.AddLine(Customer."Post Code"+' '+Customer.City);
          end;

         end;//IF NOT AuditRollSLCurrReportSKIP
        until AuditRollSalesLines.Next = 0;
          PrintAuditRollSLFooter();
        end;
        AuditRollSLOnPostDataItem();
    end;

    procedure PrintAuditRollSLFooter()
    var
        AuditRoll1: Record "Audit Roll";
    begin
        // Salgslinie, Footer (16) - OnPreSection()
        AuditRoll1.Reset;
        AuditRoll1.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type);
        AuditRoll1.SetRange("Register No.",AuditRoll."Register No.");
        AuditRoll1.SetRange("Sales Ticket No.",AuditRoll."Sales Ticket No.");
        AuditRoll1.SetRange("Sale Type",AuditRoll1."Sale Type"::Sale);
        AuditRoll1.CalcSums(Amount,"Amount Including VAT");
        Saldo :=  AuditRoll1."Amount Including VAT";
        moms := AuditRoll1."Amount Including VAT" - AuditRoll1.Amount;

        //-NPR5.26 [243285]
        SaldoBarcode := Saldo;
        //+NPR5.26 [243285]

        if not (Saldo=0) then begin
          if (Saldo<0) then
            negSaldo:=true
          else
            negSaldo:=false;
          Printer.SetFont('A11');//B21
          Printer.SetBold(true);
          Printer.AddLine('');
          Printer.AddTextField(1,0, TotalLCYTxt);
          Printer.AddDecimalField(2,2, Saldo);
        end;

        // Salgslinie, Footer (17) - OnPreSection()
        if (AuditRollSalesLines."Line Discount Amount" <>0) and (RetailConfiguration.SamletBonRabat) then begin
          Printer.SetFont('A11');
          Printer.SetBold(false);
          Printer.AddTextField(1,0,' '+TotalDiscountTxt);
          Printer.AddDecimalField(2,2,AuditRollSalesLines."Line Discount Amount");
        end;

        // Salgslinie, Footer (18) - OnPreSection()
        if (moms <> 0) or (Saldo = 0) then begin
          Printer.SetFont('A11');
          Printer.SetBold(false);
          Printer.AddTextField(1,0, ' ' +IncludedVatTxt);
          Printer.AddDecimalField(2,2,moms);
        end;

        // Salgslinie, Footer (19) - OnPreSection()
        if RetailConfiguration."Euro Exchange Rate" <> 0 then
          EuroIAlt := Format(Saldo/RetailConfiguration."Euro Exchange Rate",0,'<Precision,2:2><Standard Format,0>')
        else
          EuroIAlt := '';

        if RetailConfiguration."Euro on Sales Ticket" then begin
          if not (Saldo=0) then begin
            Printer.SetFont('A11');
            Printer.SetBold(true);
            Printer.AddTextField(1,0, ' ' + TotalEuroTxt);
            Printer.AddTextField(2,2, EuroIAlt);
          end;
        end;
    end;

    procedure PrintAuditRollPaymentLines()
    begin
        //Betalingslinie - Properties

        AuditRollPaymentLines.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type","Line No.");
        AuditRollPaymentLines.SetRange("Sale Type", AuditRollPaymentLines."Sale Type"::Payment);

        AuditRollPaymentLines.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
        AuditRollPaymentLines.SetRange("Register No.",AuditRoll."Register No.");
        AuditRollPaymentLines.SetRange("Posting Date", AuditRoll."Posting Date");

        if AuditRollPaymentLines.FindSet then begin
        repeat
          AuditRollPLOnAfterGetRecord();

        until AuditRollPaymentLines.Next = 0;
        PrintAuditRollPLFooter();
        end;
    end;

    procedure PrintAuditRollPLFooter()
    var
        AuditRoll1: Record "Audit Roll";
    begin
        // Betalingslinie, Footer (1)

        AuditRoll1.Reset;
        AuditRoll1.SetCurrentKey("Register No.","Sales Ticket No.","Sale Type",Type);
        AuditRoll1.SetRange("Register No.", AuditRoll."Register No.");
        AuditRoll1.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
        AuditRoll1.SetRange("Sale Type",AuditRoll1."Sale Type"::Payment);
        AuditRoll1.CalcSums(Amount,"Amount Including VAT");
        Saldo := AuditRoll1."Amount Including VAT" ;
        refund := "Calculate Refund Amount"(Saldo);

        Printer.SetFont('A11');
        Printer.SetBold(false);
        Printer.AddLine('');
        Printer.AddTextField(1,0,ARollPLPriceExVAT);
        Printer.AddDecimalField(2,2,Saldo - moms);
        Printer.AddTextField(1,0,ARollPLVat);
        Printer.AddDecimalField(2,2,moms);
        Printer.AddTextField(1,0,ARollPLAdminFee);
        Printer.AddDecimalField(2,2,moms - refund);
        Printer.AddLine('');
        Printer.AddTextField(1,0,ARollPLRefund);
        Printer.AddDecimalField(2,2,refund);
        Printer.AddTextField(1,0,letterPrice);
    end;

    procedure PrintNPRetailConfiguration()
    begin
        // NP Retail Configuration, Body (1) - OnPreSection()
        //IF NPK."Stregkode på bonudskrift" AND
        //  (Register."Receipt Printer Type"=Register."Receipt Printer Type"::"TM-T88") THEN
        //   CurrReport.SHOWOUTPUT(TRUE) ELSE
        //  CurrReport.SHOWOUTPUT(FALSE);
        // IF (NPK."Stregkode hvis manglende pris") AND
        // (Register."Receipt Printer Type"=Register."Receipt Printer Type"::"TM-T88") AND
        // (Saldo=0) THEN CurrReport.SHOWOUTPUT(TRUE) ELSE CurrReport.SHOWOUTPUT(FALSE);

        //++004
        //-NPR5.26 [243285]
        // IF FALSE THEN BEGIN
        //  Printer.AddBarcode('Barcode3', stregkode ,4);
        // END;
        //+NPR5.26 [243285]
        //--004
    end;

    procedure PrintTaxFree()
    begin

        // TaxFree - Properties
        TaxFree.SetCurrentKey(Number);
        TaxFree.Ascending(true);
        TaxFree.SetRange(Number,1);

        // TaxFree - OnPreDataItem()
        if Register.Get(AuditRoll."Register No.") then;

        if TaxFree.FindSet then repeat
          TaXfreeOnAfterGetRecord();

          // TaxFree, Body (1)
          Printer.SetFont('Control');
          Printer.AddLine('H');

          // TaxFree, Body (2)
          Printer.SetFont('B11');
          Printer.SetBold(false);

          //-NPR5.30 [261964]
          //CASE Register."Tax Free Country Code" OF
          case CountryCode of
          //-NPR5.30 [261964]
            '208' : //Denmark
              begin
                Printer.AddTextField(1,0,'This is a VAT form issued by:');
                Printer.AddTextField(1,0,'Premier Tax Free');
                Printer.AddTextField(1,0,'VAT no.: 29602492 ');
                Printer.AddTextField(1,0,'Rådhusstræde 3, 2. sal');
                Printer.AddTextField(1,0,'1466 K¢benhavn K');
                Printer.AddTextField(1,0,'Denmark');
                Printer.AddTextField(1,0,'TEL: +45 70277844');
                Printer.AddTextField(1,0,'FAX: +45 70277843');
                Printer.AddTextField(1,0,'E-mail: office.dk@premiertaxfree.com');
                Printer.AddTextField(1,0,'www.premiertaxfree.com');
              end;
            '234' : //Faroe Islands
              begin
                Printer.AddTextField(1,0,'This is a VAT form issued by:');
                Printer.AddTextField(1,0,'Tax Free Worldwide - Faroe Sp/f');
                Printer.AddTextField(1,0,'VAT no.: 5520 ');
                Printer.AddTextField(1,0,'Yviri Vid Strand 4');
                Printer.AddTextField(1,0,'100 Thorshavn');
                Printer.AddTextField(1,0,'Denmark');
                Printer.AddTextField(1,0,'TEL: +354 564 64 00');
                Printer.AddTextField(1,0,'E-mail: office.fo@premiertaxfree.com');
                Printer.AddTextField(1,0,'www.premiertaxfree.com');
              end;
          end;

          Printer.AddLine('');

          //TaxFree, Body (3)
          Printer.AddTextField(1,1,'  '+ TaxTxt311);
          Printer.AddTextField(1,1,'  '+ TaxTxt312);
          Printer.AddTextField(1,1,'  '+ TaxTxt321);
          Printer.AddTextField(1,1,'  '+ TaxTxt322);

          //TaxFree, Body (4)
          Printer.AddTextField(1,1,TaxTxt41);
          Printer.AddTextField(1,1,TaxTxt42);
          Printer.AddTextField(1,1,TaxTxt43);

          //TaxFree, Body (5)
          Printer.SetFont('B21');
          Printer.SetBold(true);
          Printer.AddTextField(1,1,TaxTxt51);
          Printer.AddTextField(1,1,TaxTxt52);
          Printer.AddLine('');

          //TaxFree, Body (6)
          Printer.SetFont('B11');//
          Printer.SetBold(false);
          Printer.SetPadChar('_');
          Printer.AddTextField(1,0,cName);
          Printer.AddLine('');

          Printer.SetPadChar('_');
          Printer.AddTextField(1,0,cAddress);
          Printer.AddLine('');

          Printer.SetPadChar('_');
          Printer.AddTextField(1,0,cPostalCode);
          Printer.AddLine('');

          Printer.SetPadChar('_');
          Printer.AddTextField(1,0,cCountry);
          Printer.AddLine('');

          Printer.SetPadChar('_');
          Printer.AddTextField(1,0,cPasNo);
          Printer.AddLine('');
          Printer.SetPadChar('');

          //TaxFree, Body (7) - OnPreSection()
          if false then begin
            Printer.SetFont('A11');
            Printer.SetBold(false);
            Printer.AddTextField(1,1,TaxTxt71);
            Printer.AddTextField(1,1,TaxTxt72);
            Printer.AddLine('');
            Printer.SetPadChar('_');
            Printer.AddTextField(1,0,cRealCredit);
            Printer.AddLine('');
            Printer.SetPadChar('');
          end;

          //TaxFree, Body (8) - OnPreSection()
          if flgCreditCard then begin
            Printer.SetFont('B11');
            Printer.SetBold(false);
            Printer.AddLine('');
            Printer.AddTextField(1,0,cCredit);
            Printer.AddTextField(2,2,creditNo);
            Printer.AddLine('');
          end;

          // TaxFree, Body (9)
          Printer.SetFont('B21');
          Printer.SetBold(true);
          Printer.AddTextField(1,1,TaxTxt91);
          Printer.AddLine('');
          Printer.SetFont('B11');
          Printer.SetBold(false);
          Printer.AddTextField(1,0,TaxTxt92);
          Printer.AddTextField(1,0,'  '+TaxTxt93);
          if creditNo <> '' then
            Printer.AddTextField(1,0,'  '+ConvertStr(creditNo, 'X', '_'))
          //-243285 [243285]
          else begin
            Printer.AddLine(' ');
            Printer.SetPadChar('_');
            Printer.AddLine(' ');
            Printer.SetPadChar('');
          end;
          //+243285 [243285]
          Printer.AddLine('');
          Printer.AddTextField(1,0,TaxTxt94);
          Printer.AddLine('');

          // TaxFree, Body (10)
          Printer.SetFont('B11');
          Printer.SetBold(false);
          Printer.AddTextField(1,1,TaxTxt1011);
          Printer.AddTextField(1,1,TaxTxt1012);
          Printer.AddTextField(1,1,TaxTxt1013);
          Printer.AddTextField(1,1,TaxTxt1014);
          Printer.AddTextField(1,1,TaxTxt1015);
          Printer.AddTextField(1,1,TaxTxt1016);
          Printer.SetPadChar('_');
          Printer.AddTextField(1,0,TaxTxt102);
          Printer.AddLine('');
          Printer.SetPadChar('');

          // TaxFree, Body (11)
          Printer.SetFont('B21');
          Printer.SetBold(true);
          Printer.AddTextField(1,1,TaxTxt111);
          Printer.AddLine('');
          Printer.SetFont('B11');
          Printer.SetBold(false);
          Printer.AddTextField(1,1,TaxTxt1121);
          Printer.AddTextField(1,1,TaxTxt1122);
          Printer.AddLine('');
          Printer.SetPadChar('_');
          Printer.AddTextField(1,0,TaxTxt113);
          Printer.AddLine('');
          Printer.SetPadChar('');
          Printer.AddLine('');
          Printer.AddTextField(1,1,TaxTxt1141);
          Printer.AddTextField(1,1,TaxTxt1142);
          Printer.AddTextField(1,1,TaxTxt1143);
          Printer.AddTextField(1,1,TaxTxt1144);
          Printer.AddTextField(1,1,TaxTxt1145);

          // TaxFree, Body (12)
          Printer.SetFont('B21');
          Printer.SetBold(true);
          Printer.AddTextField(1,1,TaxTxt1211);
          Printer.AddTextField(1,1,TaxTxt1212);
          Printer.AddLine('');
          Printer.SetFont('B11');
          Printer.SetBold(false);
          Printer.SetPadChar('_');
          Printer.AddTextField(1,0,TaxTxt122);
          Printer.AddLine('');
          Printer.SetPadChar('');
          Printer.AddLine('');
          Printer.AddTextField(1,1,TaxTxt123);
          Printer.AddLine('');
          Printer.AddLine('');
          Printer.AddLine('');
          Printer.AddLine('');
          Printer.AddTextField(1,1,TaxTxt1241);
          Printer.AddTextField(1,1,TaxTxt1242);
          Printer.AddTextField(1,1,TaxTxt1243);
          Printer.AddTextField(1,1,TaxTxt1244);
          Printer.AddLine('');

          // TaxFree, Body (13)
          Printer.AddBarcode('CODE39', Barcode1, 4);
          Printer.AddLine('');
          Printer.AddLine('');
          // TaxFree, Body (14)
          Printer.AddBarcode('CODE39', Barcode2, 4);
          Printer.AddLine('');
          Printer.AddLine('');


            // 1.NP Retail Configuration2()
            PrintNPRetailConfiguration2()

        until TaxFree.Next = 0;
    end;

    procedure PrintNPRetailConfiguration2()
    begin

        // NP Retail Configuration 2 - OnAfterGetRecord()
        //COMPRESSARRAY(BonInfo);

        // NP Retail Configuration 2, Body (1)
        Printer.SetFont('B11');
        Printer.SetBold(false);
        Printer.AddTextField(1,1,BonInfo);
        Printer.SetFont('B11');
        Printer.AddTextField(1,1,NPRetailConfSP+' '+ BonInfo2);
    end;

    procedure "--- Record Triggers ---"()
    begin
    end;

    procedure AuditRollOnPreDataItem()
    begin
        // Audit Roll - OnPreDataItem()
        RetailConfiguration.Get();
        Register.Get( retailformcode.FetchRegisterNumber );
        if thisReg.Get( AuditRoll."Register No." ) then ;
        GlobalLanguage := 1033;//ENU
    end;

    procedure AuditRollOnAfterGetRecord()
    begin
        // Audit Roll - OnAfterGetRecord()
        BonInfo :=StrSubstNo(Text10600012, AuditRoll."Sales Ticket No.",
        Format(AuditRoll."Sale Date"),Format(AuditRoll."Starting Time"), AuditRoll."Register No.");

        if RetailConfiguration."Salesperson on Sales Ticket" and
         Salesperson.Get(AuditRoll."Salesperson Code") then begin
          BonInfo2 := StrSubstNo(CopyStr(Salesperson.Name, 1,30))
          end
          else BonInfo2 := StrSubstNo(CopyStr(AuditRoll."Salesperson Code",1,30));
    end;

    procedure LoopCounterOnAfterGetRecord()
    begin
        // L¢kke - OnAfterGetRecord()

        //-243285 [243285]
        // CASE LoopCounter.Number OF
        // 1 : BEGIN
        //     END;
        // 2 : BEGIN
        //
        //     CLEAR(Saldo);
        //     CLEAR(revrulle1);
        //
        //     IF (AuditRoll."Receipt Type" = AuditRoll."Receipt Type"::"Negative receipt") OR
        //        (AuditRoll."Receipt Type" = AuditRoll."Receipt Type"::"Return items") OR
        //        (AuditRoll."Receipt Type" = AuditRoll."Receipt Type"::"Sales in negative receipt")
        //        AND NOT flgTilgodebevis
        //        //udbetaling_check OR
        //       // negSaldo OR
        //       // (NOT flgNoCopy)
        //       THEN BEGIN
        //          Register.GET( RetailFormCode.FetchRegisterNumber);
        //          Retursalg := TRUE;
        //          RapportValg.SETRANGE("Report Type",RapportValg."Report Type"::"Return receipt");
        //          RapportValg.SETFILTER("Report ID",'<>0');
        //          RapportValg.SETRANGE("Register No.", RetailFormCode.FetchRegisterNumber);
        //
        //          revrulle1 := AuditRoll;
        //          revrulle1.SETRECFILTER;
        //
        //          IF NOT RapportValg.FIND('-') THEN
        //            RapportValg.SETRANGE("Register No.");
        //
        //          IF RapportValg.FIND('-') AND NOT flgTilgodebevis THEN //BEGIN
        //          IF (FORMAT(RapportValg."Report ID") = LOOPCurrReport_OBJECTID) AND NOT flgTilgodebevis
        //            THEN ERROR(txtError)
        //           ELSE BEGIN
        //              REPEAT
        //                REPORT.RUNMODAL(RapportValg."Report ID", visAnfordring,FALSE,revrulle1);
        //              UNTIL RapportValg.NEXT = 0;
        //            END;
        //          EXIT;//CurrReport.QUIT
        //       END ELSE
        //         LOOPCurrReport_SKIP := TRUE;
        //   END;
        //END;
        //+243285 [243285]
    end;

    procedure AuditRollSLOnAfterGetRecord()
    var
        Kasse: Record Register;
    begin
        // Salgslinie - OnAfterGetRecord()
        with AuditRollSalesLines do begin

          if ("Sale Type"="Sale Type"::"Out payment") then begin
             Saldo := Saldo;// - Salgslinie."Amount Including VAT";
            "Unit Price":=-1*"Unit Price";
            flgUdbetal:=false;
            end

          else if (Salgslinie.Type=Type::Item) then Saldo := Saldo + Salgslinie."Amount Including VAT";

          if (Saldo <> 0) and (Salgslinie.Type = Salgslinie.Type::"G/L") then begin
             oererund:=Salgslinie."Amount Including VAT";
             AuditRollSLCurrReportSKIP := true;
          end;
          if (Salgslinie."Sale Type" = Salgslinie."Sale Type"::Deposit) and
             ((Salgslinie."Gift voucher ref." <> '') or (Salgslinie."Credit voucher ref."<>'')) and
             (LoopCounter.Number=1) then begin
             flgIndbetal := true;
        //-NPR5.29 [241549]
        //    IF Kasse.GET(Salgslinie."Register No.") THEN BEGIN
        //      IF (Salgslinie."No." = Kasse."Gift Voucher Account") AND
        //        Gavekort.GET(Salgslinie."Gift voucher ref.") AND NOT
        //        "NP Retail Configuration"."Gavekorts journal" THEN BEGIN
        //        Gavekort.FILTERGROUP(2);
        //        Gavekort.SETRANGE("No.",Gavekort."No.");
        //        Gavekort.FILTERGROUP(0);
        //        //Gavekort."Udskriv Gavekort"(FALSE,FALSE);
        //        flgGavekort:=TRUE;
        //        IF "NP Retail Configuration"."Copy Sales Ticket on Giftvo." THEN
        //          flgNoCopy:=FALSE
        //        ELSE flgNoCopy:=TRUE;
        //      END;
        //      IF (Salgslinie."No." = Kasse."Credit Voucher Account") AND
        //        Tilgodebevis.GET(Salgslinie."Credit voucher ref.") THEN BEGIN
        //        Tilgodebevis.FILTERGROUP(2);
        //        Tilgodebevis.SETRANGE("No.",Tilgodebevis."No.");
        //        Tilgodebevis.FILTERGROUP(0);
        //        //Tilgodebevis."Udskriv tilgodebevis"(FALSE,FALSE);
        //        flgTilgodebevis := TRUE;
        //        flgNoCopy:=TRUE;
        //      END;
        //    END;
        //+NPR5.29 [241549]
          end;

          if (Salgslinie."Sale Type" = Salgslinie."Sale Type"::Deposit) and
             (Salgslinie."No." = Kasse."Gift Voucher Account") then
             BonnrGavekort:="Sales Ticket No.";

          if Quantity<0 then flgRetursalg:=true;


        end;
    end;

    procedure AuditRollSLOnPostDataItem()
    begin
        // Salgslinie - OnPostDataItem()
        //-NPR5.29 [241549]
        // IF (RetailConfiguration."Gavekorts journal") AND
        //   (BonnrGavekort<>'') AND
        //   RetailConfiguration."Gavekorts journal" THEN BEGIN
        //     flgGavekort:=TRUE;
        //     flgNoCopy:=TRUE;
        //     Gavekort."Udskriv Gavekorts Journal"(BonnrGavekort);
        // END;
        //+NPR5.29 [241549]
    end;

    procedure AuditRollPLOnAfterGetRecord()
    var
        i: Integer;
        letterPriceTmp: Text[30];
        letterPriceChr: Text[1];
        letterZero: Label 'zero_';
        letterOne: Label 'one_';
        letterTwo: Label 'two_';
        letterThree: Label 'three_';
        letterFour: Label 'four_';
        letterFive: Label 'five_';
        letterSix: Label 'six_';
        letterSeven: Label 'seven_';
        letterEight: Label 'eight_';
        letterNine: Label 'nine_';
        letterComma: Label 'comma_';
    begin
        // Betalingslinie - OnAfterGetRecord()

        //-243285 [243285]
        //Saldo := AuditRollPaymentLines.Amount;
        //+243285 [243285]
        Clear(letterPrice);
        refund := "Calculate Refund Amount"(Saldo);
        letterPriceTmp := Format(refund, 0,'<Precision,2:2><Standard Format,1>');

        for i := 1 to StrLen(letterPriceTmp) do begin
          letterPriceChr := CopyStr(letterPriceTmp,i,1);
          case letterPriceChr of
           '0': letterPrice += letterZero;
           '1': letterPrice += letterOne;
           '2': letterPrice += letterTwo;
           '3': letterPrice += letterThree;
           '4': letterPrice += letterFour;
           '5': letterPrice += letterFive;
           '6': letterPrice += letterSix;
           '7': letterPrice += letterSeven;
           '8': letterPrice += letterEight;
           '9': letterPrice += letterNine;
          else  letterPrice += letterComma;
          end;
        end;

        letterPrice := DelStr(letterPrice, StrLen(letterPrice), 1);
    end;

    procedure TaXfreeOnAfterGetRecord()
    var
        utility: Codeunit Utility;
        str3: Text[30];
    begin
        Clear(Barcode1);
        Clear(Barcode2);

        //-NPR5.30 [261964]
        //CASE Register."Tax Free Country Code" OF
        case CountryCode of
        //+NPR5.30 [261964]
          '208' : // Denmark -> Print old danish barcode standard
            begin

              Barcode1 := 'DI' +
        //-NPR5.30 [261964]
        //                  COPYSTR(padstr2(FORMAT(Register."Tax Free Merchant ID"), 5, '0'),1,5) +
                          CopyStr(padstr2(Format(MerchantID), 5, '0'),1,5) +
        //+NPR5.30 [261964]
                          CopyStr(padstr2(Format(Register."Register No."),2,'0'),1,2);

              Barcode1 += CopyStr(padstr2(AuditRoll."Sales Ticket No.",5,'0'),1,5);
              Barcode2 := padstr2(DelChr(Format(SaldoBarcode, 0,'<Precision,2:2><Standard Format,2>'),'=',',.'), 8, '0');

              str3 := padstr2(Format(utility.GregorianDate2JulianDayNo(AuditRoll."Sale Date")),3,'0');
              str3 := Format(Date2DMY(AuditRoll."Sale Date",3) mod 10) + str3;

              Barcode2 += padstr2(str3, 4, '0');
              Barcode2 := CopyStr(padstr2(Format(calcChecksum(Barcode1 + Barcode2) mod 72),2,'0'),1,2) + Barcode2;
            end;
          '234' : // Faroe Islands
            begin
              Barcode1 := //Barcode version:
                          '2'  +
                          //Country Code ISO 3166-1:
        //-NPR5.30 [261964]
                          CopyStr(padstr2(Format(CountryCode),3,'0'),1,3) +
        //                  COPYSTR(padstr2(FORMAT(Register."Tax Free Country Code"),3,'0'),1,3) +
        //+NPR5.30 [261964]
                          //Sale Type:                    Single Sale, Cash Refund:
                          '1'  +
                          //Voucher Issuing system:       Premier Manual Handwritten Form:
                          '10' +
                          //Source back office indicator: AX:
                          '2'  +
                          //Tax Free Customer Number:
        //-NPR5.30 [261964]
                          CopyStr(padstr2(Format(MerchantID),6,'0'),1,6) +
        //                  COPYSTR(padstr2(FORMAT(Register."Tax Free Merchant ID"),6,'0'),1,6) +
        //+NPR5.30 [261964]
                          //Till ID:
                          CopyStr(padstr2(Format(Register."Register No."),2,'0'),1,2) +
                          //Our voucher no.:
                          CopyStr(padstr2(AuditRoll."Sales Ticket No.",8,'0'),1,8);

              Barcode2 := //2nd barcode indicator:
                          '0' +
                          //VAT Rate:
                          '1'  +
                          //Date:
        //-NPR5.30 [261964]
        //                  COPYSTR(FORMAT(DATE2DMY(TODAY,3)),4,1) + FORMAT(TODAY - DMY2DATE(1,1,DATE2DMY(TODAY,3))) +
                          CopyStr(Format(Date2DMY(Today,3)),4,1) + CopyStr(padstr2(Format(Today - DMY2Date(1,1,Date2DMY(Today,3))),3,'0'),1,3) +
        //+NPR5.30 [261964]
                          //Sale Price:
                          CopyStr(padstr2(DelChr(Format(SaldoBarcode, 0,'<Precision,2:2><Standard Format,2>'),'=',',.'),12,'0'),1,12) +
                          //Filler:
                          '0000';
        //-NPR5.30 [261964]
        //      Barcode2 += FORMAT((calcChecksum(Barcode1) + calcChecksum(Barcode2)) MOD 87);
              Barcode2 += CopyStr(padstr2(Format((calcChecksum(Barcode1) + calcChecksum(Barcode2)) mod 87),2,'0'),1,2);
        //+NPR5.30 [261964]
            end;
        end;

        "Credit Card Transaction".SetRange("Register No.",AuditRoll."Register No.");
        "Credit Card Transaction".SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
        "Credit Card Transaction".SetRange(Date, AuditRoll."Sale Date");
        "Credit Card Transaction".SetRange(Type, 3);
        if "Credit Card Transaction".Find('-') then begin
         flgCreditCard := true;
         creditNo := CopyStr("Credit Card Transaction".Text, 1, 16);
         creditNo := DelStr(creditNo, 5, 4);
         creditNo := InsStr(creditNo, ' xxxx ', 5);
         creditNo := InsStr(creditNo, ' ', 15);
        end;
    end;

    procedure "-- Init --"()
    begin
    end;

    procedure GetRecords()
    begin
        AuditRoll.FindSet;
        ResetGlobalVariables();

        // Report - OnPreReport()
        Gavekorterprintet       :=false;
        Tilgodebeviserprintet   :=false;

        udbetaling_check:=false;

        //Init flag variables
        flgUdbetal:=false;
        flgTilgodebevis:=false;
        flgIndbetal:=false;
        flgRetursalg:=false;
        flgGavekort:=false;
        flgNoCopy:=false;
    end;

    procedure ResetGlobalVariables()
    begin
        Saldo := 0;
        Betalt := 0;
        ReturAfrunding := 0;
        BonInfo := '';
        //-NPR5.43 [321012]
        //Design := '';
        //+NPR5.43 [321012]
        BonDato := 0D;
        Clear(Bontext);
        Retursalg := false;
        moms := 0;
        FRV_STR_txt := '';
        Clear(Item);
        udbetaling := false;
        udbetaling_check := false;
        beskrvTXT := '';
        BonInfo2 := '';
        stregkode := '';
        sidstebon := '';
        SaleLinePOSCount := 0;
        BonKopiTXT := '';
        Clear(betalingsvalg);
        Fastkurs1 := 0;
        ReturEuro := 0;
        EuroIAlt := '';
        AntalAprisTXT := '';
        BonnrGavekort := '';
        IndbetalTXT := '';
        DebitorFound := false;
        udbetalTXT := '';
        IndbetalTXT2 := '';
        IndbetalTXT3 := '';
        flgUdbetal := false;
        flgTilgodebevis := false;
        flgIndbetal := false;
        flgRetursalg := false;
        flgGavekort := false;
        flgNoCopy := false;
        KundeKvitTXT := '';
        SerieNrTxt := '';
        VareEnhedTxt := '';
        Gavekorterprintet := false;
        Tilgodebeviserprintet := false;
        LevVarenrTxt := '';
        DebNameTxt := '';
        DebNoTxt := '';
        DebAdrTxt := '';
        DebPostTxt := '';
        NummerTxt := '';
        oererund := 0;
        rundbrugt := false;
        netto := 0;
        Clear(CompanyInfo);
        beloeb := 0;
        Clear(BonLinjer);
        negSaldo := false;
        Clear(util);
        UnitPriceInclDiscountTxt := '';
        Clear(paymentType);
        BonInfo3 := '';
    end;

    local procedure GetOfflineParameters(POSUnitNo: Code[10])
    var
        TaxFreeUnit: Record "Tax Free POS Unit";
        tmpHandlerParameters: Record "Tax Free Handler Parameters" temporary;
        Variant: Variant;
    begin
        //-NPR5.30 [261964]
        TaxFreeUnit.Get(POSUnitNo);

        //-NPR5.40 [293106]
        // tmpHandlerParameters.Parameter := 'Merchant ID';
        // tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Text;
        // tmpHandlerParameters.INSERT;
        //
        // tmpHandlerParameters.Parameter := 'VAT Number';
        // tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Text;
        // tmpHandlerParameters.INSERT;
        //
        // tmpHandlerParameters.Parameter := 'Country Code';
        // tmpHandlerParameters."Data Type" := tmpHandlerParameters."Data Type"::Integer;
        // tmpHandlerParameters.INSERT;

        tmpHandlerParameters.AddParameter('Merchant ID', tmpHandlerParameters."Data Type"::Text);
        tmpHandlerParameters.AddParameter('VAT Number', tmpHandlerParameters."Data Type"::Text);
        tmpHandlerParameters.AddParameter('Country Code', tmpHandlerParameters."Data Type"::Integer);
        tmpHandlerParameters.AddParameter('Minimum Amount Limit', tmpHandlerParameters."Data Type"::Decimal);
        //+NPR5.40 [293106]

        tmpHandlerParameters.DeserializeParameterBLOB(TaxFreeUnit);

        if tmpHandlerParameters.TryGetParameterValue('Merchant ID', Variant) then
          MerchantID := Variant;

        if tmpHandlerParameters.TryGetParameterValue('VAT Number', Variant) then
          VATNumber := Variant;

        if tmpHandlerParameters.TryGetParameterValue('Country Code', Variant) then
          CountryCode := Format(Variant);

        if (StrLen(MerchantID) = 0) or (StrLen(VATNumber) = 0) or (StrLen(CountryCode) = 0) then
          Error(Error_MissingParameters, TaxFreeUnit."Handler ID", TaxFreeUnit."POS Unit No.");
        //+NPR5.30 [261964]
    end;

    procedure "-- Report Functions --"()
    begin
    end;

    procedure padstr2(str: Text;length: Integer;padString: Text[1]): Text
    var
        i: Integer;
        PaddedStr: Text;
    begin
        //-NPR5.26 [243285]
        //outStr := FORMAT(str);

        // FOR i := STRLEN(FORMAT(str)) TO lenght-1 DO
        //  outStr := padString+outStr;

        if StrLen(str) >= length then
          exit(str);

        PaddedStr := str;
        for i := StrLen(str) to length-1 do
          PaddedStr := padString + PaddedStr;

        exit(PaddedStr);
        //+NPR5.26 [243285]
    end;

    procedure calcChecksum(Value: Code[30]): BigInteger
    var
        CRC32: DotNet npNetCRC32;
        calcInt: BigInteger;
    begin
        //-NPR5.26 [243285]
        Evaluate(calcInt, CRC32.GetCRC32(Value));
        exit(calcInt);
        // calcValue := CRC32.GetCRC32(barcode1+barcode2);
        // IF EVALUATE(calcInt, calcValue) THEN
        //  EXIT(FORMAT(calcInt MOD 72))
        // ELSE
        //  //ERROR('Automation returnerede dårligt resultat. Kontakt dit Navision Kundecenter \fejl: %1\%2',calcValue,calcInt);
        //  //Removed error message. Caused errors in audit roll.
        //  EXIT('-1');
        //+NPR5.26 [243285]
    end;

    procedure "Calculate Refund Amount"(Saldo: Decimal) Refund: Decimal
    begin
        case Saldo of
              0..299   : Refund := 0;
            300..1000  : Refund := 12 / 100 * Saldo;
           1001..5000  : Refund := 13 / 100 * Saldo;
           5001..10000 : Refund := 14 / 100 * Saldo;
          10001..25000 : Refund := 15 / 100 * Saldo;
          25001..50000 : Refund := 17 / 100 * Saldo;
          else           Refund := 18 / 100 * Saldo;
        end;
    end;
}

