codeunit 6014561 "NPR Report - Gift Voucher"
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

    TableNo = "NPR Gift Voucher";

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
        Printer: Codeunit "NPR RP Line Print Mgt.";
        GiftVoucher: Record "NPR Gift Voucher";
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
        Register: Record "NPR Register";
        RetailConfiguration: Record "NPR Retail Setup";
        Barcode: Code[20];
        Text10600011: Label 'h';
        Text10600012: Label 'E-mail: ';
        GiftVoucherTxt: Label 'Amount';
        KopiTXT: Text[30];
        LoopCounter: Integer;
        RetailFormCode: Codeunit "NPR Retail Form Code";
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
        Register.Get(RetailFormCode.FetchRegisterNumber);

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

        if (GiftVoucher."No. Printed" > 1) and (RetailConfiguration."Copy No. on Sales Ticket") then
            KopiTXT := Text10600009;
    end;

    procedure PrintHeader()
    begin
        Printer.SetFont('Control');
        //Gift Voucher, Header(1) - OnPreSection
        if (LoopCounter = 2) and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::"TM-T88") then
            Printer.AddLine('P');

        //Gift Voucher, Header(2) - OnPreSection
        if (RetailConfiguration."Logo on Sales Ticket") and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::
        "TM-T88") then begin
            Printer.AddLine('G');
            Printer.AddLine('h');
        end;

        //Gift Voucher, Header(3) - OnPreSection
        if (LoopCounter = 2) and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::Samsung) then
            Printer.AddLine('P');

        //Gift Voucher, Header(4) - OnPreSection
        if (RetailConfiguration."Logo on Sales Ticket") and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::Samsung) then
            //-NPR5.26 [249408]
            //  Printer.AddLine(Text10600000);
            Printer.AddLine('G');
        //+NPR5.26 [249408]
    end;

    procedure PrintBody()
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        //Gift Voucher, Body(5) - OnPreSection
        if Register.Get(GiftVoucher."Register No.") then;
        Printer.SetFont('B21');
        Printer.SetBold(true);
        if POSSession.IsActiveSession(POSFrontEnd) then begin
            POSFrontEnd.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            POSSetup.GetPOSStore(POSStore);
        end else begin
            if POSUnit.get(Register."Register No.") then
                POSStore.get(POSUnit."POS Store Code");
        end;
        if RetailConfiguration."Name on Sales Ticket" then
            Printer.AddLine(POSStore.Name);

        //Gift Voucher, Body(6) - OnPreSection
        Printer.SetFont('A11');
        Printer.SetBold(false);

        Printer.AddLine(POSStore.Address);
        Printer.AddLine(POSStore."Post Code" + ' ' + POSStore.City);
        Printer.AddLine(Text10600001 + Format(POSStore."Phone No."));
        Printer.AddLine(Text10600012 + Format(POSStore."E-mail"));

        Printer.SetFont('B21');
        Printer.SetBold(true);
        Printer.AddLine('');
        Printer.AddTextField(1, 0, Text10600004);
        Printer.AddTextField(2, 2, GiftVoucher."No.");
        Printer.AddTextField(1, 0, GiftVoucherTxt);
        Printer.AddDecimalField(2, 2, GiftVoucher.Amount);
        Printer.AddLine(WebshopCode + ' ' + GiftVoucher."External Reference No.");
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
        if RetailConfiguration."Gift and Credit Valid Period" <> 0 then
            Printer.AddTextField(2, 1, StrSubstNo(ValidUntilTxt, RetailConfiguration."Gift and Credit Valid Period"));
        Printer.AddTextField(2, 1, InvalidWithoutCompTxt);
    end;

    procedure PrintFooter()
    begin
        //Gift Voucher, Footer(10) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
            Barcode := GiftVoucher."No."
        else
            Barcode := '';

        if StrLen(Barcode) = 13 then begin
            Printer.AddBarcode('Barcode3', Barcode, 4);
        end;

        //Gift Voucher, Footer(11) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
            Barcode := GiftVoucher."No."
        else
            Barcode := '';
        if StrLen(Barcode) <> 13 then begin
            Printer.AddBarcode('Barcode4', Barcode, 4);
        end;

        //Gift Voucher, Footer(12) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
            Barcode := GiftVoucher."No."
        else
            Barcode := '';

        if Salesperson.Get(GiftVoucher."Salesperson Code") then;

        if RetailConfiguration."Salesperson on Sales Ticket" then
            EkspedientTxt := StrSubstNo('%1 %2', SalespersonTxt, Format(Salesperson.Name))
        else
            EkspedientTxt := '';

        Printer.SetFont('B21');
        Printer.SetBold(true);
        Printer.AddLine('');
        Printer.AddLine('');
        Printer.AddTextField(2, 1, StampAndSignatureTxt);

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

        Printer.AddTextField(1, 0, StrSubstNo('%1', GiftVoucher."Issue Date"));
        Printer.AddTextField(2, 2, StrSubstNo('%1',
                    Text10600005 + GiftVoucher."Register No.") + Text10600006 + GiftVoucher."Sales Ticket No.");
        Printer.AddTextField(1, 0, Format(Time));
        Printer.AddTextField(2, 2, GiftVoucher."No.");

        Printer.AddTextField(2, 1, EkspedientTxt);
        Printer.AddLine('');

        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;
}

