codeunit 6014566 "Report - Delivery Note"
{
    // Report - Return sales Ticket
    //  Work started by Jerome Cader on 29-03-2013
    //  Implements the functionality of the Delivery Note report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060110.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Sales Shipment Header".
    // 
    // NPR4.13/MMV/20150225 CASE 205001 Added control character for correct logo printing on all epson drivers.
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX Solution
    // NPR5.26/MMV /20160916 CASE 249408 Moved control codes from captions to in-line strings.
    // NPR5.29/MMV /20161122 CASE 258545 Updated call to standard NAV AddrFormat function.
    // NPR5.36/TJ  /20170906 CASE 286283 Renamed variables/function into english and into proper naming terminology
    //                                   Removed unused variables
    // NPR5.39/JDH /20180226 CASE        Danish Characters removed. Old commented code deleted

    TableNo = "Sales Shipment Header";

    trigger OnRun()
    begin
        RPLinePrintMgt.SetAutoLineBreak(true);
        SalesShipmentHeader.CopyFilters(Rec);
        GetRecords;
        RPLinePrintMgt.SetThreeColumnDistribution(0.25,0.5,0.25);

        RPLinePrintMgt.SetFont('A11');

        for CurrPageNo := 1 to 1 do begin
          // 0. Sales Shipment Header
          SalesSHeaderOnPreDataItem();
          SalesSHeaderOnAfterGetRecord();

          // 1. Integer
          PrintIntegerLoop;
        end;
    end;

    var
        RPLinePrintMgt: Codeunit "RP Line Print Mgt.";
        SalesShipmentHeader: Record "Sales Shipment Header";
        CurrPageNo: Integer;
        CopyLoop: Record "Integer";
        PageLoop: Record "Integer";
        SalesShipmentLine: Record "Sales Shipment Line";
        TotalLoop: Record "Integer";
        TotalLoop2: Record "Integer";
        CurrReportPAGENO: Integer;
        CurrReportLANGUAGE: Integer;
        Salesperson: Record "Salesperson/Purchaser";
        CompanyInformation: Record "Company Information";
        Register: Record Register;
        SalesShptPrinted: Codeunit "Sales Shpt.-Printed";
        BillToCustomerAddress: array [8] of Text[50];
        ShipToCustomerAddress: array [8] of Text[50];
        CompanyAddress: array [8] of Text[50];
        SalespersonText2: Text[20];
        ReferenceText2: Text[30];
        MoreLines: Boolean;
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        CopyText: Text[30];
        ShowBillToCustomerAddress: Boolean;
        FormatAdr: Codeunit "Format Address";
        ReferenceTxt: Text[30];
        ShowUnderType: Boolean;
        RetailSetup: Record "Retail Setup";
        Language: Record Language;
        CompanyInfo: Record "Company Information";
        SalesPurchPerson: Record "Salesperson/Purchaser";
        RespCenter: Record "Responsibility Center";
        CustAddr: array [8] of Text[50];
        ShipToAddr: array [8] of Text[50];
        CompanyAddr: array [8] of Text[50];
        SalesPersonText: Text[20];
        ReferenceText: Text[30];
        ShowCustAddr: Boolean;
        i: Integer;
        FormatAddr: Codeunit "Format Address";
        Text10600000: Label 'Sales Person';
        Text10600001: Label 'COPY';
        Text10600002: Label 'Delivery %1';
        Text10600003: Label 're:';
        Text10600004: Label 'Sales Person:';
        Text10600006: Label 'No.';
        Text10600007: Label 'Description';
        Text10600008: Label 'Quantity';
        Text10600009: Label 'Date:';
        Text10600010: Label 'Signature';
        Text000: Label 'Salesperson';

    procedure PrintHeader()
    begin
    end;

    procedure PrintBody()
    begin
    end;

    procedure PrintFooter()
    begin
    end;

    procedure PrintIntegerLoop()
    begin
        // CopyLoop - Properties
        CopyLoop.SetCurrentKey(Number);

        // CopyLoop - OnPreDataItem()
        NoOfCopies := 0;
        NoOfLoops := 1 + Abs(NoOfCopies);
        CopyText := '';
        ShowUnderType := false;
        CopyLoop.SetRange(Number,1,NoOfLoops);
        if CopyLoop.FindSet then
          repeat
            // CopyLoop - OnAfterGetRecord()
            if CopyLoop.Number > 1 then begin
              CopyText := Text10600001;
              ShowUnderType := true;
            end;
            CurrReportPAGENO := 1;

            // 2. Integer
            PrintIntegerPageLoop;

            //NewPagePerRecord
            RPLinePrintMgt.SetFont('A11');
            RPLinePrintMgt.AddLine('');

            RPLinePrintMgt.SetFont('Control');
            RPLinePrintMgt.AddLine('P');
          until CopyLoop.Next = 0;

        // CopyLoop - OnPostDataItem()
        SalesShptPrinted.Run(SalesShipmentHeader);
    end;

    procedure PrintIntegerPageLoop()
    begin
        // PageLoop - Properties
        PageLoop.SetCurrentKey(Number);
        PageLoop.SetRange(Number,1);

        if PageLoop.FindSet then repeat

          // PageLoop, Header (1) - OnPreSection()
          if RetailSetup."Logo on Sales Ticket" then begin
            RPLinePrintMgt.SetFont('Control');
            RPLinePrintMgt.AddLine('G');
            RPLinePrintMgt.AddLine('h');
          end;

          // PageLoop, Header (2) - OnPreSection()
          if RetailSetup."Name on Sales Ticket" then begin
            RPLinePrintMgt.SetFont('B21');
            RPLinePrintMgt.AddTextField(2,1,CompanyInformation.Name);
          end;

          // PageLoop, Header (3) - OnPreSection()
          if CompanyInformation.Address <> '' then begin
            RPLinePrintMgt.SetFont('A11');
            RPLinePrintMgt.AddTextField(1,0,CompanyInformation.Address);
            RPLinePrintMgt.AddTextField(1,0,CompanyInformation.City);
            RPLinePrintMgt.AddTextField(1,0,'Tlf: ' + Format(CompanyInformation."Phone No."));
            RPLinePrintMgt.AddTextField(2,0,'Fax: ' + Format(CompanyInformation."Fax No."));
            RPLinePrintMgt.AddTextField(1,0,'CVR: ' + Format(CompanyInformation."VAT Registration No."));
            RPLinePrintMgt.AddTextField(2,0,CompanyInformation."E-Mail");
          end;

          // PageLoop, Header (4)
          RPLinePrintMgt.SetFont('B21');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.SetUnderLine(true);
          RPLinePrintMgt.AddTextField(1,0,StrSubstNo(Text10600002,CopyText) + Format(SalesShipmentHeader."No.") + '/Ordre ' + Format(SalesShipmentHeader."Order No."));
          RPLinePrintMgt.SetUnderLine(false);

          // PageLoop, Header (5) - OnPreSection()
          if SalesShipmentHeader."Your Reference" <> '' then
            ReferenceTxt := Text10600003
          else
            ReferenceTxt := '';

          //Printer.SetFont('B21');
          RPLinePrintMgt.SetFont('A11');//Added
          RPLinePrintMgt.SetBold(true);//Added
          RPLinePrintMgt.AddTextField(1,0,'Leverings adresse:');
          RPLinePrintMgt.SetFont('A11');
          RPLinePrintMgt.SetBold(false);
          RPLinePrintMgt.AddLine('');
          RPLinePrintMgt.AddTextField(1,0,'Kunde: ' + SalesShipmentHeader."Sell-to Customer No.");
          RPLinePrintMgt.AddTextField(1,0,ShipToCustomerAddress[1]);
          RPLinePrintMgt.AddTextField(1,0,ShipToCustomerAddress[2]);
          RPLinePrintMgt.AddTextField(1,0,ShipToCustomerAddress[3]);
          RPLinePrintMgt.AddTextField(1,0,ShipToCustomerAddress[4]);
          RPLinePrintMgt.AddLine('');
          RPLinePrintMgt.AddTextField(1,0,Text10600004 + Salesperson.Name);
          RPLinePrintMgt.AddTextField(2,2,Text10600009 + Format(SalesShipmentHeader."Shipment Date"));
          RPLinePrintMgt.AddTextField(1,0,ReferenceTxt);
          RPLinePrintMgt.AddTextField(2,0,SalesShipmentHeader."Your Reference");
          RPLinePrintMgt.AddLine('');
          RPLinePrintMgt.SetUnderLine(true);
          RPLinePrintMgt.SetFont('B11');//Added
          RPLinePrintMgt.AddTextField(1,0,Text10600006);
          RPLinePrintMgt.AddTextField(2,0,Text10600007);
          RPLinePrintMgt.AddTextField(3,2,Text10600008);
          RPLinePrintMgt.SetUnderLine(false);

          // 3. Sales Shipment Line
          PrintSalesShipmentLine;

          // 3.Integer
          PrintIntegerTotal;

          // 3.Integer
          PrintIntegerTotal2;
        until PageLoop.Next = 0;
    end;

    procedure PrintSalesShipmentLine()
    begin
        // Sales Shipment Line - Properties
        SalesShipmentLine.SetCurrentKey("Document No.","Line No.");
        SalesShipmentLine.SetRange("Document No.",SalesShipmentHeader."No.");

        // Sales Shipment Line - OnPreDataItem()
        MoreLines := SalesShipmentLine.Find('+');
        while MoreLines and (SalesShipmentLine.Description = '') and (SalesShipmentLine."No." = '')
                           and (SalesShipmentLine.Quantity = 0) do
          MoreLines := SalesShipmentLine.Next(-1) <> 0;
        if MoreLines then begin
          SalesShipmentLine.SetRange("Line No.",0,SalesShipmentLine."Line No.");
          if SalesShipmentLine.FindSet then
            repeat
              // Sales Shipment Line, Body (1) - OnPreSection()
              if SalesShipmentLine.Type = SalesShipmentLine.Type::" " then begin
                RPLinePrintMgt.SetFont('B11');
                RPLinePrintMgt.AddTextField(2,0,SalesShipmentLine.Description);
              end;

              // Sales Shipment Line, Body (2) - OnPreSection()
              if SalesShipmentLine.Type = SalesShipmentLine.Type::"G/L Account" then begin
                RPLinePrintMgt.SetFont('B11');
                RPLinePrintMgt.AddTextField(2,0,SalesShipmentLine.Description);
                RPLinePrintMgt.AddDecimalField(3,2,SalesShipmentLine.Quantity);
              end;

              // Sales Shipment Line, Body (3) - OnPreSection()
              if SalesShipmentLine.Type = SalesShipmentLine.Type::Item then begin
                RPLinePrintMgt.SetFont('B11');
                RPLinePrintMgt.AddTextField(1,0,SalesShipmentLine."No.");
                RPLinePrintMgt.AddTextField(2,0,SalesShipmentLine.Description);
                RPLinePrintMgt.AddDecimalField(3,2,SalesShipmentLine.Quantity);
              end;

            until SalesShipmentLine.Next = 0;
        end;
    end;

    procedure PrintIntegerTotal()
    begin
        // Total - Properties
        TotalLoop.SetRange(Number,1);

        // Total, Body (1) - OnPreSection()
        if RetailSetup."Bar Code on Sales Ticket Print" then begin
          if TotalLoop.FindSet then
            repeat
              RPLinePrintMgt.AddBarcode('Barcode4',SalesShipmentHeader."No.",4);
              // Total, Body (2)
              RPLinePrintMgt.SetFont('A11');
              RPLinePrintMgt.AddLine('');
              RPLinePrintMgt.AddLine('');
              RPLinePrintMgt.AddLine('');
              RPLinePrintMgt.AddLine('');
              RPLinePrintMgt.SetPadChar('-');
              RPLinePrintMgt.AddLine('');
              RPLinePrintMgt.SetPadChar(' ');
              RPLinePrintMgt.AddTextField(2,1,Text10600010);
            until TotalLoop.Next = 0;
        end;
    end;

    procedure PrintIntegerTotal2()
    begin
        // Total2 - Properties
        TotalLoop2.SetRange(Number,1);

        // Total2 - OnPreDataItem()
        if ShowBillToCustomerAddress then begin
          if TotalLoop2.FindSet then
            repeat
            until TotalLoop2.Next = 0;
        end;
    end;

    procedure SalesSHeaderOnPreDataItem()
    var
        RetailFormCode: Codeunit "Retail Form Code";
    begin
        // Sales Shipment Header - OnPreDataItem()
        Register.Get(RetailFormCode.FetchRegisterNumber);
        CompanyInformation.Get;
        FormatAdr.Company(CompanyAddress,CompanyInformation);
    end;

    procedure SalesSHeaderOnAfterGetRecord()
    begin
        // Sales Shipment Header - OnAfterGetRecord()
        if SalesShipmentHeader."Salesperson Code" = '' then begin
          Salesperson.Init;
          SalespersonText2 := '';
        end else begin
          Salesperson.Get(SalesShipmentHeader."Salesperson Code");
          SalespersonText2 := Text10600000;
        end;
        if SalesShipmentHeader."Your Reference" = '' then
          ReferenceText2 := ''
        else
          ReferenceText2 := SalesShipmentHeader.FieldCaption("Your Reference");
        FormatAdr.SalesShptShipTo(ShipToCustomerAddress,SalesShipmentHeader);

        //-NPR5.29 [258545]
        ShowBillToCustomerAddress := FormatAdr.SalesShptBillTo(BillToCustomerAddress,ShipToCustomerAddress,SalesShipmentHeader);

        // FormatAdr.SalesShptBillTo(BillToCustomerAddress,SalesShipmentHeader);
        // ShowBillToCustomerAddress := SalesShipmentHeader."Bill-to Customer No." <> SalesShipmentHeader."Sell-to Customer No.";
        // FOR i := 1 TO ARRAYLEN(BillToCustomerAddress) DO
        //   IF BillToCustomerAddress[i] <> ShipToCustomerAddress[i] THEN
        //     ShowBillToCustomerAddress := TRUE;
        //+NPR5.29 [258545]
        CurrReportLANGUAGE := Language.GetLanguageID(SalesShipmentHeader."Language Code");

        CompanyInfo.Get;
        if RespCenter.Get(SalesShipmentHeader."Responsibility Center") then begin
          FormatAddr.RespCenter(CompanyAddr,RespCenter);
          CompanyInfo."Phone No." := RespCenter."Phone No.";
          CompanyInfo."Fax No." := RespCenter."Fax No.";
        end else begin
          FormatAddr.Company(CompanyAddr,CompanyInfo);
        end;

        if SalesShipmentHeader."Salesperson Code" = '' then begin
          SalesPurchPerson.Init;
          SalesPersonText := '';
        end else begin
          SalesPurchPerson.Get(SalesShipmentHeader."Salesperson Code");
          SalesPersonText := Text000;
        end;
        if SalesShipmentHeader."Your Reference" = '' then
          ReferenceText := ''
        else
          ReferenceText := SalesShipmentHeader.FieldCaption("Your Reference");
        FormatAddr.SalesShptShipTo(ShipToAddr,SalesShipmentHeader);

        //-NPR5.29 [258545]
        ShowCustAddr := FormatAddr.SalesShptBillTo(CustAddr,ShipToAddr,SalesShipmentHeader);
        // FormatAddr.SalesShptBillTo(CustAddr,SalesShipmentHeader);
        // ShowCustAddr := SalesShipmentHeader."Bill-to Customer No." <> SalesShipmentHeader."Sell-to Customer No.";
        // FOR i := 1 TO ARRAYLEN(CustAddr) DO
        //  IF CustAddr[i] <> ShipToAddr[i] THEN
        //    ShowCustAddr := TRUE;
        //+NPR5.29 [258545]
    end;

    procedure GetRecords()
    begin
        SalesShipmentHeader.FindSet;

        // Report - OnInitReport()
        NoOfCopies := 0;
        if RetailSetup.Get() then;
    end;
}

