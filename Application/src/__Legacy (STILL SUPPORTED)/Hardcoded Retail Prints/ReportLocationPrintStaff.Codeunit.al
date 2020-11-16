codeunit 6014574 "NPR Report: Loc. Print Staff"
{
    // NPR5.22/MMV/20160408 CASE 232067 Renamed CU from "Receipt Print Reservation 15" to "Report - Location Print Staff"

    TableNo = "NPR Sale POS";

    trigger OnRun()
    begin
        SalePOS.CopyFilters(Rec);

        RetailSetup.Get();

        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.465, 0.35, 0.235);
        Prefixspace := ' ';

        if SalePOS.FindSet then
            repeat
                Register.Get(SalePOS."Register No.");

                SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
                SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
                SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
                //SaleLinePOS.SETFILTER("Customer Location No.", '=%1', '');  //If Customer Location No. has already been filled then the lines should not be reprinted.
                if SaleLinePOS.IsEmpty then
                    exit;

                PrintHeader();
                if SaleLinePOS.FindSet then
                    repeat
                        PrintLine();
                    until SaleLinePOS.Next = 0;

                PrintFooter();
            until SalePOS.Next = 0;
    end;

    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        Printer: Codeunit "NPR RP Line Print Mgt.";
        RetailSetup: Record "NPR Retail Setup";
        Register: Record "NPR Register";
        Prefixspace: Text;
        LinesUnitPriceInclDisc: Label 'Unit Price w. Disc. ';
        LinesSerialNo: Label 'Serial No.';
        ItemInfoUnitListPrice: Label 'Unit List Price :';
        UnitTxt: Label 'Unit:';
        Text10600012: Label '%2 - Bon %1/%4 - %3';
        TotalTxt: Label 'Total';
        TotalVATTxt: Label 'VAT Amount';
        TotalEuroTxt: Label 'Total euro';
        Text0009: Label 'Sales person: ';
        LinesDescription: Label 'Description';
        LinesQuantity: Label 'Quantity';
        LinesAmount: Label 'Amount';
        LocationTransferTxt: Label 'Transferred from %1 to %2';

    local procedure PrintHeader()
    var
        BonInfoTxt: Text;
        BonInfoTxt2: Text;
        Salesperson: Record "Salesperson/Purchaser";
        POSCustomerLocationTo: Record "NPR POS Customer Location";
        POSCustomerLocationFrom: Record "NPR POS Customer Location";
        SaleLinePOS2: Record "NPR Sale Line POS";
    begin
        Printer.SetFont('A11');
        Printer.SetBold(true);
        if (SalePOS."Customer Location No." <> '') and POSCustomerLocationTo.Get(SalePOS."Customer Location No.") then begin
            SaleLinePOS2.CopyFilters(SaleLinePOS);
            SaleLinePOS2.SetFilter("Customer Location No.", '<>%1&<>%2', SalePOS."Customer Location No.", '');
            if SaleLinePOS2.FindFirst and POSCustomerLocationFrom.Get(SaleLinePOS2."Customer Location No.") then
                Printer.AddTextField(1, 1, StrSubstNo(LocationTransferTxt, POSCustomerLocationFrom.Description, POSCustomerLocationTo.Description))
            else
                Printer.AddTextField(1, 1, POSCustomerLocationTo.Description);
        end;

        BonInfoTxt := StrSubstNo(Text10600012, SalePOS."Sales Ticket No.", Format(Today), Format(Time), SalePOS."Register No.");

        if Salesperson.Get(SalePOS."Salesperson Code") then
            BonInfoTxt2 := Text0009 + StrSubstNo(CopyStr(Salesperson.Name, 1, 30))
        else
            BonInfoTxt2 := Text0009 + StrSubstNo(CopyStr(SalePOS."Salesperson Code", 1, 30));

        Printer.AddTextField(1, 1, BonInfoTxt);
        Printer.AddTextField(1, 1, BonInfoTxt2);
        Printer.SetBold(false);
        Printer.AddLine('');

        Printer.SetBold(true);
        Printer.AddTextField(1, 0, LinesDescription);
        Printer.AddTextField(2, 2, LinesQuantity);
        //Printer.AddTextField(3,2,LinesAmount);
        Printer.NewLine;
        Printer.SetBold(false);
    end;

    local procedure PrintLine()
    var
        Item: Record Item;
    begin
        with SaleLinePOS do begin
            Printer.AddLine(CopyStr(Description, 1, 40));
            if StrLen(Description) > 40 then
                Printer.AddLine(CopyStr(Description, 41, 40));

            if Type = Type::Item then
                PrintItemAmountLine();
        end;
    end;

    local procedure PrintFooter()
    begin
        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure PrintItemAmountLine()
    var
        QuantityAmountDesc: Text[30];
        Item: Record Item;
    begin
        with SaleLinePOS do begin
            //  IF RetailSetup."Unit Price on Sales Ticket" AND (Quantity <> 0) THEN
            //    QuantityAmountDesc := FORMAT(Quantity)+ ' * '+
            //                          FORMAT(("Amount Including VAT"+"Discount Amount") /
            //                                  Quantity,0,'<Precision,2:2><Standard Format,0>')
            //  ELSE
            QuantityAmountDesc := Format(Quantity);

            if (Type = Type::Item) then
                Printer.AddTextField(1, 0, Prefixspace + "No.");

            Printer.AddTextField(2, 2, QuantityAmountDesc);
            //Printer.AddDecimalField(3,2,"Amount Including VAT");
        end;
    end;

    local procedure PrintLocationLine()
    begin
    end;
}

