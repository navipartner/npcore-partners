codeunit 6014563 "NPR Report - Credit Voucher"
{
    // Report -Credit Voucher
    //  Work started by Jerome Cader on 07-03-2013
    //  Implements the functionality of the Credit voucher report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060107.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Credit Voucher".
    // 
    // NPR4.11/MMV/20150225 CASE 205001 Added control character for correct logo printing on all epson drivers.
    // NPR4.11/MMV/20150508 CASE 205310 Added validity period
    // NPR4.11/MMV/20150617 CASE 205310 Replaced above change with new field 90
    // NPR5.26/MMV /20160916 CASE 249408 Moved control codes from captions to in-line strings.
    // NPR5.27/MMV /20161024 CASE 256097 Replaced hardcoded caption.

    TableNo = "NPR Credit Voucher";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        Rec.SetRecFilter;
        CreditVoucher.CopyFilters(Rec);
        GetRecords;

        Printer.SetFont('A11');

        // 0. Integer
        for NoOfCopies := 0 to LoopCounter do begin
            // 1. Credit Voucher
            CreditVoucherOnAfterGetRec();
            for CurrPageNo := 1 to 1 do begin
                PrintHeader;
                PrintBody;
                PrintFooter;
            end;
        end;
    end;

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";
        CreditVoucher: Record "NPR Credit Voucher";
        CurrPageNo: Integer;
        Text10600000: Label 'G';
        Text10600001: Label 'CVR:';
        Text10600002: Label 'Telephone No.:';
        Text10600003: Label 'Fax No.:';
        Text10600004: Label 'Credit Voucher:';
        Text10600005: Label 'Register';
        Text10600006: Label ' - Sales Ticket';
        Text10600007: Label 't';
        Text10600008: Label 'P';
        Text10600009: Label 'COPY';
        Text10600010: Label 'A';
        CompanyInformation: Record "Company Information";
        Register: Record "NPR Register";
        RetailConfiguration: Record "NPR Retail Setup";
        Barcode: Code[20];
        Text10600011: Label 'h';
        CreditVoucherTxt: Label 'Amount';
        KopiTXT: Text[30];
        LoopCounter: Integer;
        RetailFormCode: Codeunit "NPR Retail Form Code";
        NoOfCopies: Integer;
        IssueForTxt: Label 'Issued for';
        InvalidWithoutCompTxt: Label 'Invalid without company stamp and signature.';
        Salesperson: Record "Salesperson/Purchaser";
        EkspedientTxt: Text[80];
        StampAndSignatureTxt: Label 'Stamp and Signature';
        CanOnlyBeRedeTxt: Label 'Can only be redeemed when purchasing items';
        NoteCreditVoucherTxt1: Label 'NOTE: THE CREDIT VOUCHER MUST';
        NoteCreditVoucherTxt2: Label 'BE SHOWN AT PURCHASE SITE. WE ARE NOT RESPONSIBLE';
        NoteCreditVoucherTxt3: Label 'ANY LOSSES';
        ValidUntilTxt: Label 'Valid for %1 years';
        SalespersonTxt: Label 'Salesperson';

    procedure GetRecords()
    begin
        //Report-OnInitReport
        CompanyInformation.Get;
        RetailConfiguration.Get;
        LoopCounter := 0;

        //Integer-OnPreDataItem
        Register.Get(RetailFormCode.FetchRegisterNumber);

        //Integer OnAfterGetRecord
        if RetailConfiguration."Copy of Gift Voucher etc." then
            LoopCounter := 1;

        CreditVoucher.FindSet;
    end;

    procedure CreditVoucherOnAfterGetRec()
    begin
        //CreditVoucher OnAfterGetRecord
        CreditVoucher."No. Printed" += 1;
        CreditVoucher.Modify();
        if (CreditVoucher."No. Printed" > 1) and (RetailConfiguration."Copy No. on Sales Ticket") then
            KopiTXT := Text10600009;
    end;

    procedure PrintHeader()
    begin
        Printer.SetFont('Control');
        //Credit Voucher, Header(1) - OnPreSection
        if (LoopCounter = 2) and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::Samsung) then
            //-NPR5.26 [249408]
            //Printer.AddLine(Text10600008);
            Printer.AddLine('P');
        //+NPR5.26 [249408]

        //Credit Voucher, Header(2) - OnPreSection
        if (RetailConfiguration."Logo on Sales Ticket") and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::Samsung)
        then
            //-NPR5.26 [249408]
            //Printer.AddLine(Text10600000);
            Printer.AddLine('G');
        //+NPR5.26 [249408]

        //Credit Voucher, Header(3) - OnPreSection
        if (LoopCounter = 2) and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::"TM-T88") then
            Printer.AddLine(Text10600008);

        //Credit Voucher, Header(4) - OnPreSection
        if (RetailConfiguration."Logo on Sales Ticket") and (Register."Receipt Printer Type" = Register."Receipt Printer Type"::
        "TM-T88") then begin
            //-NPR5.26 [249408]
            //  Printer.AddLine(Text10600000);
            //  Printer.AddLine(Text10600011);
            Printer.AddLine('G');
            Printer.AddLine('h');
            //+NPR5.26 [249408]
        end;
    end;

    procedure PrintBody()
    begin
        //Credit Voucher, Body(5) - OnPreSection
        if Register.Get(CreditVoucher."Register No.") then;
        Printer.SetFont('B21');
        Printer.AddLine(Register.Name);

        Printer.SetFont('A11');
        Printer.SetBold(false);
        Printer.AddLine(Register.Address);
        Printer.AddLine(Register."Post Code" + ' ' + Register.City);
        Printer.AddTextField(1, 0, Text10600002);
        Printer.AddTextField(2, 2, Format(Register."Phone No."));
        Printer.AddTextField(1, 0, Text10600003);
        Printer.AddTextField(2, 2, Format(Register."Fax No."));
        Printer.AddLine(Text10600001 + Format(Register."VAT No."));

        Printer.SetFont('B21');
        Printer.SetBold(true);
        Printer.AddLine('');
        Printer.AddTextField(1, 0, Text10600004);
        Printer.AddTextField(2, 2, CreditVoucher."No.");
        Printer.AddTextField(1, 0, CreditVoucherTxt);
        Printer.AddDecimalField(2, 2, CreditVoucher.Amount);

        //Credit Voucher, Body(6) - OnPreSection
        if KopiTXT <> '' then begin
            Printer.SetFont('B21');
            Printer.AddLine(KopiTXT);
        end;

        //Credit Voucher, Body(7) - OnPreSection
        if CreditVoucher.Name <> '' then begin
            Printer.SetFont('B21');
            Printer.AddLine('');
            Printer.SetFont('B11');
            Printer.SetPadChar('_');
            Printer.AddLine('');
            Printer.SetPadChar(' ');
            Printer.AddLine(IssueForTxt);
            Printer.SetFont('B21');
            Printer.AddLine('  ' + CreditVoucher.Name);
            Printer.AddLine('  ' + CreditVoucher.Address);
            Printer.AddLine('  ' + CreditVoucher."Post Code" + ' ' + CreditVoucher.City);
            Printer.SetPadChar('_');
            Printer.AddLine('');
            Printer.SetPadChar(' ');
        end;

        //Credit Voucher, Body(8) - OnPreSection
        Printer.SetFont('B11');
        Printer.AddLine('');
        //-NPR4.11
        if RetailConfiguration."Gift and Credit Valid Period" <> 0 then
            Printer.AddTextField(2, 1, StrSubstNo(ValidUntilTxt, RetailConfiguration."Gift and Credit Valid Period"));
        //+NPR4.11
        Printer.AddTextField(2, 1, InvalidWithoutCompTxt);
        Printer.AddTextField(2, 1, CanOnlyBeRedeTxt);
        Printer.AddLine('');
        Printer.AddTextField(2, 1, NoteCreditVoucherTxt1);
        Printer.AddTextField(2, 1, NoteCreditVoucherTxt2);
        Printer.AddTextField(2, 1, NoteCreditVoucherTxt3);
    end;

    procedure PrintFooter()
    begin
        //Credit Voucher, Footer(9) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
            Barcode := CreditVoucher."No."
        else
            Barcode := '';

        if StrLen(Barcode) = 13 then begin
            Printer.AddBarcode('Barcode3', Barcode, 4);
        end;

        //Credit Voucher, Footer(10) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
            Barcode := CreditVoucher."No."
        else
            Barcode := '';
        if StrLen(Barcode) <> 13 then begin
            Printer.AddBarcode('Barcode4', Barcode, 4);
        end;

        //Credit Voucher, Footer(11) - OnPreSection
        if RetailConfiguration."Bar Code on Sales Ticket Print" then
            Barcode := CreditVoucher."No."
        else
            Barcode := '';

        if Salesperson.Get(CreditVoucher.Salesperson) then;

        if RetailConfiguration."Salesperson on Sales Ticket" then
            //-NPR5.27 [256097]
            EkspedientTxt := SalespersonTxt + ' ' + Format(Salesperson.Name)
        //EkspedientTxt := 'Ekspedient '+FORMAT(Salesperson.Name)
        //+NPR5.27 [256097]
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

        Printer.AddTextField(1, 0, StrSubstNo('%1', CreditVoucher."Issue Date"));
        Printer.AddTextField(2, 2, StrSubstNo('%1',
                    Text10600005 + CreditVoucher."Register No.") + Text10600006 + CreditVoucher."Sales Ticket No.");
        Printer.AddTextField(1, 0, Format(Time));
        Printer.AddTextField(2, 2, CreditVoucher."No.");

        Printer.AddTextField(2, 1, EkspedientTxt);
        Printer.AddLine('');

        Printer.SetFont('Control');
        //-NPR5.26 [249408]
        //Printer.AddLine(Text10600008);
        Printer.AddLine('P');
        //+NPR5.26 [249408]
    end;
}

