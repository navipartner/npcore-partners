codeunit 6014561 "Report - Gift Voucher"
{
    // Report - Gift Voucher
    //  Work started by Jerome Cader on 01-02-2013
    //  Implements the functionality of the gift voucher report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060106.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Gift Voucher".
    // 
    // NPR4.02/MMV/20150416 CASE 211666 Added some missing norwegian translations to text constants.
    // NPR4.11/MMV/20150508 CASE 205310 Added validity period
    // NPR4.11/MMV/20150617 CASE 205310 Replaced above change with new field 90
    // NPR5.26/MMV /20160916 CASE 249408 Moved control codes from captions to in-line strings.
    // NPR5.29/MMV /20161109 CASE 241549 Replaced hardcoded caption.
    // NPR5.40/TS  /20180305 CASE 304119 Added line External Reference No.

    TableNo = "Gift Voucher";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        Rec.SetRecFilter;
        GiftVoucher.CopyFilters(Rec);
        GetRecords;

        Printer.SetFont('A11');

        // 0. Integer
        for NoOfCopies := 0 to LoopCounter do begin
          // 1. Gift Voucher
          GiftVoucherOnAfterGetRec();
          for CurrPageNo := 1 to 1 do begin
            PrintHeader;
            PrintBody;
            PrintFooter;
          end;
        end;
    end;

    var
        Printer: Codeunit "RP Line Print Mgt.";
        GiftVoucher: Record "Gift Voucher";
        CurrPageNo: Integer;
        Text10600000: Label 'G';
        Text10600001: Label 'Telephone No.:';
        Text10600002: Label 'Fax No.:';
        Text10600003: Label 'CVR:';
        Text10600004: Label 'Gift Voucher:';
        Text10600005: Label 'Register';
        Text10600006: Label ' - Sales Ticket';
        Text10600007: Label 't';
        Text10600008: Label 'P';
        Text10600009: Label 'COPY';
        Text10600010: Label 'G';
        CompanyInformation: Record "Company Information";
        Register: Record Register;
        RetailConfiguration: Record "Retail Setup";
        Barcode: Code[20];
        Text10600011: Label 'h';
        Text10600012: Label 'E-mail: ';
        GiftVoucherTxt: Label 'Amount';
        KopiTXT: Text[30];
        LoopCounter: Integer;
        RetailFormCode: Codeunit "Retail Form Code";
        NoOfCopies: Integer;
        IssueForTxt: Label 'Issued for';
        InvalidWithoutCompTxt: Label 'Invalid without company stamp and signature.';
        Salesperson: Record "Salesperson/Purchaser";
        EkspedientTxt: Text[80];
        StampAndSignatureTxt: Label 'Stamp and Signature';
        ValidUntilTxt: Label 'Valid for %1 years';
        SalespersonTxt: Label 'Salesperson';
        WebshopCode: Label 'Webshop Code:';

    procedure GetRecords()
    begin
        //Report-OnInitReport
        CompanyInformation.Get;

        //Report-OnPreReport
        RetailConfiguration.Get;
        LoopCounter := 0;

        //Integer-OnPreDataItem
        Register.Get( RetailFormCode.FetchRegisterNumber );

        //Integer OnAfterGetRecord
        if RetailConfiguration."Copy of Gift Voucher etc." then
          LoopCounter := 1;

        GiftVoucher.FindSet;
    end;

    procedure GiftVoucherOnAfterGetRec()
    begin
        //GifTVoucher OnAfterGetRecord
        GiftVoucher."No. Printed" += 1;
        GiftVoucher.Modify();

        if ( GiftVoucher."No. Printed" > 1 ) and ( RetailConfiguration."Copy No. on Sales Ticket" ) then
          KopiTXT := Text10600009;
    end;

    procedure PrintHeader()
    begin
        Printer.SetFont('Control');
        //Gift Voucher, Header(1) - OnPreSection
        if (LoopCounter = 2) and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::"TM-T88") then
          //-NPR5.26 [249408]
          //Printer.AddLine(Text10600008);
          Printer.AddLine('P');
          //+NPR5.26 [249408]

        //Gift Voucher, Header(2) - OnPreSection
        if (RetailConfiguration."Logo on Sales Ticket") and (Register."Receipt Printer Type"=Register."Receipt Printer Type"::
        "TM-T88") then begin
          //-NPR5.26 [249408]
        //  Printer.AddLine(Text10600000);
        //  Printer.AddLine(Text10600011);
          Printer.AddLine('G');
          Printer.AddLine('h');
          //+NPR5.26 [249408]
        end;

        //Gift Voucher, Header(3) - OnPreSection
        if (LoopCounter = 2) and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::Samsung) then
          //-NPR5.26 [249408]
        //  Printer.AddLine(Text10600008);
          Printer.AddLine('P');
          //+NPR5.26 [249408]

        //Gift Voucher, Header(4) - OnPreSection
        if (RetailConfiguration."Logo on Sales Ticket") and (Register."Receipt Printer Type"=Register."Receipt Printer Type"::Samsung) then
          //-NPR5.26 [249408]
        //  Printer.AddLine(Text10600000);
          Printer.AddLine('G');
          //+NPR5.26 [249408]
    end;

    procedure PrintBody()
    begin
        //Gift Voucher, Body(5) - OnPreSection
        if Register.Get(GiftVoucher."Register No.") then;
        Printer.SetFont('B21');
        Printer.SetBold(true);
        if RetailConfiguration."Name on Sales Ticket" then
          Printer.AddLine(Register.Name);

        //Gift Voucher, Body(6) - OnPreSection
        Printer.SetFont('A11');
        Printer.SetBold(false);
        Printer.AddLine(Register.Address);
        Printer.AddLine(Register."Post Code" + ' ' + Register.City);
        Printer.AddLine(Text10600001+Format(Register."Phone No."));
        Printer.AddLine(Text10600012+Format(Register."E-mail"));
        Printer.AddLine(Text10600003+Format(Register."VAT No."));

        Printer.SetFont('B21');
        Printer.SetBold(true);
        Printer.AddLine('');
        Printer.AddTextField(1,0,Text10600004);
        Printer.AddTextField(2,2,GiftVoucher."No.");
        Printer.AddTextField(1,0,GiftVoucherTxt);
        Printer.AddDecimalField(2,2,GiftVoucher.Amount);
        //-NPR5.40
        Printer.AddLine(WebshopCode + ' ' + GiftVoucher."External Reference No.");
        //+NPR5.40
        //Gift Voucher, Body(7) - OnPreSection
        if KopiTXT <> '' then begin
          Printer.SetFont('B21');
          Printer.AddLine(KopiTXT);
        end;

        //Gift Voucher, Body(8) - OnPreSection
        if GiftVoucher.Name <> '' then begin
          Printer.SetFont('B21');
          Printer.AddLine('');
          Printer.SetFont('B11');
          Printer.SetPadChar('_');
          Printer.AddLine('');
          Printer.SetPadChar(' ');
          Printer.AddLine(IssueForTxt);
          Printer.SetFont('B21');
          Printer.AddLine('  ' + GiftVoucher.Name);
          Printer.AddLine('  ' + GiftVoucher.Address);
          Printer.AddLine('  ' + GiftVoucher."ZIP Code" + ' ' + GiftVoucher.City);
          Printer.SetPadChar('_');
          Printer.AddLine('');
          Printer.SetPadChar(' ');
        end;

        //Gift Voucher, Body(9) - OnPreSection
        Printer.SetFont('B11');
        Printer.AddLine('');
        //-NPR4.11
        if RetailConfiguration."Gift and Credit Valid Period" <> 0 then
          Printer.AddTextField(2,1,StrSubstNo(ValidUntilTxt,RetailConfiguration."Gift and Credit Valid Period"));
        //+NPR4.11
        Printer.AddTextField(2,1,InvalidWithoutCompTxt);
    end;

    procedure PrintFooter()
    begin
        //Gift Voucher, Footer(10) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
          Barcode := GiftVoucher."No."
        else Barcode := '';

        if StrLen(Barcode) = 13 then begin
          Printer.AddBarcode('Barcode3', Barcode ,4);
        end;

        //Gift Voucher, Footer(11) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
          Barcode := GiftVoucher."No."
        else Barcode := '';
        if StrLen(Barcode) <> 13 then begin
          Printer.AddBarcode('Barcode4', Barcode ,4);
        end;

        //Gift Voucher, Footer(12) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
          Barcode := GiftVoucher."No."
        else Barcode := '';

        if Salesperson.Get(GiftVoucher.Salesperson) then;

        if RetailConfiguration."Salesperson on Sales Ticket" then
        //-NPR5.29 [241549]
        //  EkspedientTxt := 'Ekspedient '+FORMAT(Salesperson.Name)
          EkspedientTxt := StrSubstNo('%1 %2', SalespersonTxt, Format(Salesperson.Name))
        //+NPR5.29 [241549]
        else EkspedientTxt:='';

        Printer.SetFont('B21');
        Printer.SetBold(true);
        Printer.AddLine('');
        Printer.AddLine('');
        Printer.AddTextField(2,1,StampAndSignatureTxt);

        Printer.AddLine('');
        Printer.AddLine('');
        Printer.AddLine('');
        Printer.AddLine('');
        Printer.AddLine('');
        Printer.AddLine('');

        Printer.SetFont('B11');
        Printer.SetBold(true);
        Printer.AddLine('');
        Printer.SetPadChar('.');
        Printer.AddLine('');
        Printer.SetPadChar(' ');

        Printer.AddTextField(1,0,StrSubstNo('%1',GiftVoucher."Issue Date" ));
        Printer.AddTextField(2,2,StrSubstNo('%1',
                    Text10600005 + GiftVoucher."Register No.") + Text10600006 + GiftVoucher."Sales Ticket No.");
        Printer.AddTextField(1,0,Format(Time));
        Printer.AddTextField(2,2,GiftVoucher."No.");

        Printer.AddTextField(2,1,EkspedientTxt);
        Printer.AddLine('');

        Printer.SetFont('Control');
        //-NPR5.26 [249408]
        // Printer.AddLine(Text10600008);
        Printer.AddLine('P');
        //+NPR5.26 [249408]
    end;
}

