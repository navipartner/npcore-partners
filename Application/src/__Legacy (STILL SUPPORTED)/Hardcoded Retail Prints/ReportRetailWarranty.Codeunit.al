codeunit 6014576 "NPR Report: Retail Warranty"
{
    // Report - Retail Warranty
    //  Work started by Jerome Cader on 08-08-2013
    //  Implements the functionality of the Retail Warranty IV report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060102.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Sale Line POS".
    // 
    // NPR5.26/MMV /20160916 CASE 249408 Moved control codes from captions to in-line strings.
    // NPR5.33/MMV /20170630 CASE 280196 Removed old code preventing compile.
    // NPR5.37/TJ  /20171018 CASE 286283 Translated variables with danish specific letters into english
    // NPR5.51/AlST/20190620 CASE 356129 allow for automatic printing of warranty on pos line creation
    // NPR5.52/AlST/20191024 CASE 373793 focus on appropriate line for printing workflow
    // NPR5.55/MMV /20200504 CASE 395393 Moved workflow step to separate object.

    TableNo = "NPR Sale Line POS";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        SaleLinePOS.CopyFilters(Rec);
        GetRecords;
        Printer.SetThreeColumnDistribution(0.5, 0.25, 0.25);

        Printer.SetFont('A11');
        CurrReport_SKIP := false;

        for CurrPageNo := 1 to 1 do begin
            // 0. Sales Line POS
            SaleLinePOSOnPreDataItem();
            repeat
                SaleLinePOSOnAfterGetRecord();
                PrintBody;
            until (SaleLinePOS.Next = 0) or CurrReport_SKIP;
            PrintFooter;
        end;
    end;

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";
        RetailConfiguration: Record "NPR Retail Setup";
        CompanyInformation: Record "Company Information";
        SaleLinePOS: Record "NPR Sale Line POS";
        CurrPageNo: Integer;
        CopyLoop: Record "Integer";
        PageLoop: Record "Integer";
        CurrReport_SKIP: Boolean;
        "/----": Integer;
        Ombtxt: Text[30];
        DatoUd: Date;
        KodePris: Text[30];
        KommaKodePris: Text[20];
        CurrencySubunitPart: Text[30];
        KrDel: Text[30];
        Month: Text[30];
        Year: Text[30];
        CodePriceLength: Integer;
        VGrp: Text[30];
        Vare: Record Item;
        Pos: Integer;
        Tegn: Text[1];
        Fyldetegn: Text[30];
        receipt_register: Record "NPR Register";
        utility: Codeunit "NPR Utility";
        VN: Record Item;
        eksp: Record "NPR Sale POS";
        cust: Record Customer;
        Register: Record "NPR Register";
        "/+----": Integer;
        Text0000: Label 'A';
        Text0001: Label 'G';
        Text0002: Label 'P';
        Text10600001: Label 'G';
        TextNoCust: Label 'Customer must be typed in the sale';
        Text10600002: Label 'P';
        Text10600003: Label 'Register %1 does not exist';
        DateTxt: Label 'Date';
        TelephoneTxt: Label 'Telephone';
        ClaimProofTxt: Label 'Claim Proof';
        SalesofGoodActTxt: Label 'Sales of Good Act ';
        ReTxt: Label 'Re.';
        SerialNoTxt: Label 'Serial No.';
        NotesTxt1: Label 'Is given 2 year guarantee in accordance with current law.';
        NotesTxt11: Label 'Is given 2 year guarantee ';
        NotesTxt12: Label ' in accordance with current law.';
        NotesTxt2: Label 'The warranty covers: Manufacturing and material defects identified by the unit normal consumption.';
        NotesTxt21: Label 'The warranty covers: Manufacturing ';
        NotesTxt22: Label ' and material defects identified ';
        NotesTxt23: Label ' by the unit normal consumption.';
        NotesTxt3: Label 'The warranty does not cover: Defects or damages directly or indirectly caused by misuse, poor maintenance (eg lack of descaling the coffee maker entries) violence or interference by other than the factory authorized repair shop.';
        NotesTxt31: Label 'The warranty does not cover: Defects or damages ';
        NotesTxt311: Label 'The warranty does not cover: ';
        NotesTxt312: Label ' Defects or damages ';
        NotesTxt32: Label ' directly or indirectly caused by misuse, ';
        NotesTxt321: Label ' directly or indirectly caused ';
        NotesTxt322: Label ' by misuse, ';
        NotesTxt33: Label ' poor maintenance (eg lack of ';
        NotesTxt34: Label ' descaling the coffee maker entries) ';
        NotesTxt35: Label ' violence or interference by other ';
        NotesTxt36: Label ' other than the factory authorized repair shop.';
        NotesTxt4: Label 'This certificate replaces any. accompanying guarantee / warranty certificate from the supplier.';
        NotesTxt41: Label 'This certificate replaces any. accompanying ';
        NotesTxt42: Label ' guarantee / warranty certificate';
        NotesTxt43: Label ' from the supplier.';
        WarrantyPrintCaption: Label 'Auto printing of the warranty for this item has failed with the error: %1';

    procedure PrintBody()
    begin
        // Sale Line POS, Body (1)
        Printer.SetFont('A11');
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, receipt_register.Name);

        Printer.SetBold(false);
        Printer.AddTextField(1, 0, receipt_register.Address);
        Printer.AddTextField(2, 1, DateTxt);
        Printer.AddDateField(3, 2, DatoUd);
        Printer.AddTextField(1, 0, receipt_register."Post Code" + ' ' + receipt_register.City);
        Printer.AddTextField(1, 0, TelephoneTxt);
        Printer.AddTextField(2, 0, receipt_register."Phone No.");
        Printer.AddLine('');

        Printer.SetFont('A21');
        Printer.SetBold(true);
        Printer.AddTextField(1, 0, ClaimProofTxt);
        Printer.AddTextField(1, 0, SalesofGoodActTxt);
        Printer.AddLine('');

        Printer.SetFont('B21');
        Printer.SetBold(false);
        Printer.AddTextField(1, 0, ReTxt);
        Printer.AddTextField(1, 0, Vare.Description);


        // Sale Line POS, Body (2)
        if RetailConfiguration."Description 2 on receipt" then begin
            Printer.AddTextField(1, 0, Vare."Description 2");
        end;

        // Sale Line POS, Body (3)
        Printer.SetFont('A11');
        Printer.SetBold(false);
        Printer.AddTextField(1, 0, 'Bonnr. ' + SaleLinePOS."Sales Ticket No.");
        Printer.AddTextField(2, 2, KommaKodePris);

        // Sale Line POS, Body (4)
        if SaleLinePOS."Serial No." <> '' then begin
            Printer.AddLine('');
            Printer.AddTextField(1, 0, SerialNoTxt);
            Printer.AddTextField(2, 0, SaleLinePOS."Serial No.");
        end;

        // Sale Line POS, Body (5)
        if RetailConfiguration."Bar Code on Sales Ticket Print" then begin
            Printer.AddBarcode('Barcode3', SaleLinePOS."No.", 4);
        end;

        // Sale Line POS, Body (6)
        Printer.SetFont('A11');
        Printer.SetBold(false);
        Printer.AddLine('');
        Printer.AddTextField(1, 0, NotesTxt11);
        Printer.AddTextField(1, 0, NotesTxt12);
        Printer.AddLine('');
        Printer.AddTextField(1, 0, NotesTxt21);
        Printer.AddTextField(1, 0, NotesTxt22);
        Printer.AddTextField(1, 0, NotesTxt23);
        Printer.AddLine('');
        Printer.AddTextField(1, 0, NotesTxt311);
        Printer.AddTextField(1, 0, NotesTxt312);
        Printer.AddTextField(1, 0, NotesTxt321);
        Printer.AddTextField(1, 0, NotesTxt322);
        Printer.AddTextField(1, 0, NotesTxt33);
        Printer.AddTextField(1, 0, NotesTxt34);
        Printer.AddTextField(1, 0, NotesTxt35);
        Printer.AddTextField(1, 0, NotesTxt36);
        Printer.AddLine('');
        Printer.AddTextField(1, 0, NotesTxt41);
        Printer.AddTextField(1, 0, NotesTxt42);
        Printer.AddTextField(1, 0, NotesTxt43);
        Printer.AddLine('');


        Printer.AddTextField(1, 1, RetailConfiguration."Sales Ticket Line Text1");
        Printer.AddTextField(1, 1, RetailConfiguration."Sales Ticket Line Text2");
        Printer.AddTextField(1, 1, RetailConfiguration."Sales Ticket Line Text3");
        Printer.AddTextField(1, 1, RetailConfiguration."Sales Ticket Line Text6");
        Printer.AddTextField(1, 1, RetailConfiguration."Sales Ticket Line Text7");
    end;

    procedure PrintFooter()
    begin
        Printer.SetFont('Control');
        //-NPR5.26 [249408]
        //Printer.AddLine(Text0002);
        Printer.AddLine('P');
        //+NPR5.26 [249408]
    end;

    procedure "--- Record Triggers ---"()
    begin
    end;

    procedure SaleLinePOSOnPreDataItem()
    var
        RetailFormCode: Codeunit "NPR Retail Form Code";
    begin
        // Sale Line POS - OnPreDataItem()
        Register.Get(RetailFormCode.FetchRegisterNumber);
    end;

    procedure SaleLinePOSOnAfterGetRecord()
    begin
        // Sale Line POS - OnAfterGetRecord()
        //-E2
        //-NPR5.33 [280196]
        // VN.SETRANGE("No.", SaleLinePOS."No.");
        // IF VN.FIND('-') THEN
        //  IF VN."Type Retail" = 'OVERDRAG' THEN BEGIN
        //    eksp.SETRANGE("Register No.", SaleLinePOS."Register No.");
        //    eksp.SETRANGE("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        //    IF eksp.FIND('-') THEN BEGIN
        //      IF (eksp."Customer No." <> '') AND cust.GET(eksp."Customer No.") THEN BEGIN
        //        cust.SETRANGE("No.",eksp."Customer No.");
        //        REPORT.RUNMODAL(52000, FALSE, TRUE, cust);
        //      END
        //      ELSE
        //        ERROR(TextNoCust);
        //    END;
        //  CurrReport_SKIP := TRUE;
        //  END;
        //+NPR5.33 [280196]

        if not CurrReport_SKIP then begin
            if not receipt_register.Get(SaleLinePOS."Register No.") then Error(Text10600003, SaleLinePOS."Register No.");

            if SaleLinePOS."No." = '*' then CurrReport_SKIP := true;
            if not CurrReport_SKIP then begin

                if Vare.Get(SaleLinePOS."No.") then;

                if Date2DMY(SaleLinePOS.Date, 2) = 11 then
                    DatoUd := CalcDate('LM+24D', SaleLinePOS.Date)
                else begin
                    if (Date2DMY(SaleLinePOS.Date, 2) = 12) and (Date2DMY(SaleLinePOS.Date, 1) < 25) then
                        DatoUd := CalcDate('LM-30D+23D', SaleLinePOS.Date)
                    else
                        DatoUd := SaleLinePOS.Date;
                end;

                //Slet ekstra blanke tegn i beskrivelse
                if StrPos(SaleLinePOS.Description, ' ') <> 0 then
                    repeat
                        SaleLinePOS.Description := CopyStr(SaleLinePOS.Description, 1, StrPos(SaleLinePOS.Description, ' ') - 1)
                                           + CopyStr(SaleLinePOS.Description, StrPos(SaleLinePOS.Description, ' ') + 1);
                    until StrPos(SaleLinePOS.Description, ' ') = 0;

                //"Beregner" kodepris udefra "K¢bspris kodeord"
                if RetailConfiguration."Purchace Price Code" <> '' then begin
                    //-NOK1.0
                    //KodePris :=DELCHR(FORMAT(ROUND(100*Amount/Quantity,1),12),'=','.');
                    KodePris := DelChr(Format(Round(100 * SaleLinePOS."Amount Including VAT" / SaleLinePOS.Quantity, 1), 12), '=', '.');
                    //+NPK1.0
                    KommaKodePris := ConvertStr(KodePris, '0123456789', RetailConfiguration."Purchace Price Code");
                end
                //"Beregner" kodepris, når "K¢bspris kodeord" er blankt
                else begin
                    if SaleLinePOS.Quantity <> 0 then
                        KodePris := DelChr(DelChr(Format(Round(100 * SaleLinePOS."Amount Including VAT" / SaleLinePOS.Quantity, 1), 12), '=', '.'));
                    CodePriceLength := StrLen(KodePris);
                    CurrencySubunitPart := Format(CopyStr(KodePris, CodePriceLength - 1));
                    if CurrencySubunitPart = '00' then
                        CurrencySubunitPart := '11';
                    KrDel := DelChr(Format(CopyStr(KodePris, 1, CodePriceLength - 2)));
                    if CodePriceLength > 5 then
                        KrDel := DelStr(KrDel, 1, CodePriceLength - 5)
                    else
                        KrDel := '0' + KrDel;
                    Month := Format(Round((Date2DMY(SaleLinePOS.Date, 2)) / 3, 1, '>'));

                    Year := Format(CopyStr(Format(Date2DMY(SaleLinePOS.Date, 3)), 4));
                    VGrp := DelChr(Vare."NPR Item Group", '=', '.');
                    VGrp := VGrp + '000';
                    KommaKodePris := CopyStr(VGrp, 1, 3) + CurrencySubunitPart + KrDel;
                end;

            end;//IF NOT CurrReport_SKIP THEN BEGIN
        end;//IF NOT CurrReport_SKIP THEN BEGIN
    end;

    procedure "-- Init --"()
    begin
    end;

    procedure GetRecords()
    begin
        SaleLinePOS.FindSet;

        // Report - OnInitReport()
        RetailConfiguration.Get;
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);
    end;
}

