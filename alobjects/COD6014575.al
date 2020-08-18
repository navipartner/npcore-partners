codeunit 6014575 "Report - Kitchen Receipt"
{
    // NPR5.22/MMV/20160419 CASE 238800 Renamed CU from "Receipt Print Reservation 16" to "Report - Kitchen Receipt"
    // NPR5.23/MMV/20160512 CASE 238800 Changed COPYFILTERS to COPY.
    // NPR5.23/JDH /20160517 CASE 240916 Removed reference to old VariaX Solution
    // NPR5.23/MMV /20160608 CASE 238800 Changed layout.
    // NPR5.29/MMV /20161031 CASE 256817 Fixed font error for footer.
    // NPR5.36/KENU/20170914 CASE 289197 Show quantity when Debit Sales
    // NPR5.41/JDH /20180426 CASE 312644  Added indirect permissions to table Audit roll

    Permissions = TableData "Audit Roll"=rimd;
    TableNo = "Audit Roll";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        //-NPR5.23 [238800]
        //AuditRoll.COPYFILTERS(Rec);
        AuditRoll.Copy(Rec);
        //+NPR5.23 [238800]
        GetRecords;


        Printer.SetBold(false);
        Printer.SetFont('A11');

        //-NPR5.23 [238800]
        Printer.SetTwoColumnDistribution(0.25,0.75);
        PrintLines(tmpAuditRollSaleInclComments);
        //PrintLines(AuditRollSale);
        //PrintBarCode;
        //+NPR5.23 [238800]
        PrintFooter;
    end;

    var
        Printer: Codeunit "RP Line Print Mgt.";
        Text0003: Label 'Staff Purchase';
        Text0004: Label 'Paid';
        Text0005: Label 'Current balance';
        Text0006: Label 'Name';
        Text0007: Label 'Address';
        Text0008: Label 'Signature';
        Text0009: Label 'Sales person: ';
        AuditRoll: Record "Audit Roll";
        AuditRollSale: Record "Audit Roll";
        AuditRollComments: Record "Audit Roll";
        tmpAuditRollSaleInclComments: Record "Audit Roll" temporary;
        Item: Record Item;
        Register: Record Register;
        RetailConfiguration: Record "Retail Setup";
        Salesperson: Record "Salesperson/Purchaser";
        CurrPageNo: Integer;
        Text10600012: Label '%2 - Bon %1/%4 - %3';
        HeaderReceiptCopy: Label 'Receipt copy no.';
        PrefixSpace: Label '  ';
        "--- Audit Roll Sales ---": Label '--- Audit Roll Sales ---';
        LinesDescription: Label 'Description';
        LinesQuantity: Label 'Quantity';
        LinesAmount: Label 'Amount';
        LinesUnitPriceInclDisc: Label 'Unit Price w. Disc. ';
        LinesSerialNo: Label 'Serial No.';
        ItemInfoUnitListPrice: Label 'Unit List Price :';
        ItemInfoVendorNo: Label 'Vend. Item No.:';
        "--- Sale Line Totals ---": Label '--- Sale Line Totals ---';
        Total: Label 'Total';
        TotalDiscount: Label 'Total Discount';
        TotalVAT: Label 'VAT Amount';
        TotalEuro: Label 'Total euro';
        TotalSettlement: Label 'Settlement';
        TotalItems: Label 'Total items sold';
        "-- Audit Roll Payment --": Label '-- Audit Roll Payment --';
        PaymentRounding: Label 'Rounding';
        PaymentReference: Label 'Reference';
        UnitTxt: Label 'Unit:';
        DepositTxt: Label 'Deposit:';
        IssuedTxt: Label 'Issued:';

    procedure PrintLines(var AuditRoll: Record "Audit Roll")
    begin
        Printer.SetBold(true);
        //-NPR5.23 [238800]
        // Printer.AddTextField(1,0,LinesDescription);
        // Printer.AddTextField(2,2,LinesQuantity);
        Printer.AddTextField(1,0,LinesQuantity);
        Printer.AddTextField(2,2,LinesDescription);
        //+NPR5.23 [238800]
        Printer.NewLine;
        Printer.SetBold(false);

        AuditRoll.SetCurrentKey("Sales Ticket No.","Line No.");
        //-NPR5.23 [238800]
        // IF AuditRollSale.FINDSET THEN REPEAT
        //  PrintLine(AuditRollSale);
        if AuditRoll.FindSet then repeat
          PrintLine(AuditRoll)
        //+NPR5.23 [238800]
        until AuditRoll.Next = 0;


        Printer.AddLine('');
    end;

    procedure PrintLine(var AuditRoll: Record "Audit Roll")
    begin
        with AuditRoll do begin
        //-NPR5.23 [238800]
          if ("Sale Type" = "Sale Type"::Comment) then
            Printer.SetFont('A21')
          else
            Printer.SetFont('A11');

          //-NPR5.36
          //IF (Type = Type::Item) AND ("Sale Type" = "Sale Type"::Sale) THEN
          if (Type = Type::Item) and (("Sale Type" = "Sale Type"::Sale) or ("Sale Type" = "Sale Type"::"Debit Sale")) then
            Printer.AddTextField(1,0,Format(Quantity));
          //+NPR5.36

          Printer.SetBold(true);
          Printer.AddTextField(2,2,CopyStr(Description,1,30));
          if StrLen(Description) > 30 then
            Printer.AddTextField(2,2,(CopyStr(Description,31,30)));

          Printer.AddLine(' ');
          Printer.SetBold(false);

        //  Printer.AddLine(COPYSTR(Description,1,40));
        //  IF STRLEN(Description) > 40 THEN
        //    Printer.AddLine(COPYSTR(Description,41,40));
        //
        //  IF ("Sale Type" = "Sale Type"::Bemærkning) THEN
        //    EXIT;
        //
        //
        //  IF RetailConfiguration."Description 2 on receipt" AND ("Description 2" <> '') THEN
        //    Printer.AddLine("Description 2");

        //  IF (Type = Type::Item) THEN
        //    PrintItemAmountLine(AuditRoll);
        //
        //
        //  IF (Unit <> '') AND RetailConfiguration."Item Unit on Expeditions" THEN BEGIN
        //    Printer.AddTextField(1,0,PrefixSpace+UnitTxt);
        //    Printer.AddTextField(2,2,Unit);
        //    Printer.AddTextField(3,2,'');
        //  END;
        //
        //  IF "Serial No." <> '' THEN BEGIN
        //    Printer.AddTextField(1,0,LinesSerialNo);
        //    Printer.AddTextField(2,2,"Serial No.");
        //    Printer.AddTextField(3,2,'');
        //  END;
        //
        //  IF "Serial No. not Created" <> '' THEN BEGIN
        //    Printer.AddTextField(1,0,LinesSerialNo);
        //    Printer.AddTextField(2,2,"Serial No. not Created");
        //    Printer.AddTextField(3,2,'');
        //  END;
        //
        //  IF RetailConfiguration."Receipt - Show Variant code" AND ("Variant Code" <> '') THEN BEGIN
        //    Printer.AddTextField(1,0,FIELDCAPTION("Variant Code"));
        //    Printer.AddTextField(2,2,"Variant Code");
        //    Printer.AddTextField(3,2,'');
        //  END;
        //+NPR5.23 [238800]
        end;
    end;

    procedure PrintFooter()
    var
        TempRetailComments: Record "Retail Comment" temporary;
        Utility: Codeunit Utility;
        Text10600019: Label 'Ticket for payoyt';
        Text10600020: Label 'Ticket for  cash receipt';
        BonInfoTxt: Text[100];
        BonInfoTxt2: Text[100];
    begin
        //-NPR5.29 [256817]
        Printer.SetFont('A11');
        //+NPR5.29 [256817]
        Printer.AddLine('');

        BonInfoTxt := StrSubstNo(Text10600012,AuditRoll."Sales Ticket No.",
                                 Format(AuditRoll."Sale Date"),Format(AuditRoll."Closing Time"),AuditRoll."Register No.");

        if RetailConfiguration."Salesperson on Sales Ticket" and
           Salesperson.Get(AuditRoll."Salesperson Code") then begin
          BonInfoTxt2 := Text0009 + StrSubstNo(CopyStr(Salesperson.Name, 1,30))
        end else
          BonInfoTxt2 := Text0009 + StrSubstNo(CopyStr(AuditRoll."Salesperson Code",1,30));

        Printer.AddLine('');
        Printer.AddTextField(1,1,BonInfoTxt);
        Printer.AddTextField(1,1,BonInfoTxt2);

        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;

    procedure "-- Init --"()
    begin
    end;

    procedure GetRecords()
    begin
        AuditRoll.FindSet;
          //-NPR5.23 [238800]
          //AuditRollSale.COPYFILTERS(AuditRoll);
          AuditRollSale.Copy(AuditRoll);
          //AuditRollSale.SETFILTER("Sale Type",'%1|%2|%3',
          AuditRollSale.SetFilter("Sale Type",'%1|%2',
          //+NPR5.23 [238800]
                                              AuditRollSale."Sale Type"::Sale,
          //-NPR5.23 [238800]
          //                                    AuditRollSale."Sale Type"::Bemærkning,
          //+NPR5.23 [238800]
                                              AuditRollSale."Sale Type"::"Debit Sale");
          //-NPR5.23 [238800]
          AuditRollComments.SetRange("Register No.", AuditRoll."Register No.");
          AuditRollComments.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
          AuditRollComments.SetRange("Sale Type", AuditRollComments."Sale Type"::Comment);

          BuildAuditRollTmpBuffer(AuditRollSale, AuditRollComments, tmpAuditRollSaleInclComments);
          //+NPR5.23 [238800]

        Register.Get(AuditRoll."Register No.");
        RetailConfiguration.Get;
    end;

    local procedure BuildAuditRollTmpBuffer(var AuditRollSale: Record "Audit Roll";var AuditRollComments: Record "Audit Roll";var tmpAuditRollBufferOut: Record "Audit Roll" temporary)
    begin
        //-NPR5.23 [238800]
        if AuditRollSale.FindSet then repeat
          tmpAuditRollBufferOut.Init;
          tmpAuditRollBufferOut := AuditRollSale;
          tmpAuditRollBufferOut.Insert;
        until AuditRollSale.Next = 0;

        if AuditRollComments.FindSet then repeat
          tmpAuditRollBufferOut.Init;
          tmpAuditRollBufferOut := AuditRollComments;
          tmpAuditRollBufferOut.Insert;
        until AuditRollComments.Next = 0;
        //+NPR5.23 [238800]
    end;
}

