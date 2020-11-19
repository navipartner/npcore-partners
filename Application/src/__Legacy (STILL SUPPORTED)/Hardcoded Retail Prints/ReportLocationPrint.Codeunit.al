codeunit 6014573 "NPR Report: Location Print"
{
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
                if SaleLinePOS.IsEmpty then
                    exit;

                PrintHeader();
                if SaleLinePOS.FindSet then
                    repeat
                        PrintLine();
                    until SaleLinePOS.Next = 0;

                PrintTotals();

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
        LocationTxt: Label 'Location';

    local procedure PrintHeader()
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if RetailSetup."Logo on Sales Ticket" then begin
            Printer.SetFont('Control');
            Printer.AddLine('G');
            Printer.AddLine('h');
        end;

        Printer.SetFont('A11');
        if POSSession.IsActiveSession(POSFrontEnd) then begin
            POSFrontEnd.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            POSSetup.GetPOSStore(POSStore);
        end else begin
            if POSUnit.get(Register."Register No.") then
                POSStore.get(POSUnit."POS Store Code");
        end;
        Printer.AddLine(POSStore.Name);
        if POSStore."Name 2" <> '' then
            Printer.AddLine(POSStore."Name 2");
        Printer.AddLine(POSStore.Address);
        Printer.AddLine(POSStore."Post Code" + ' ' + POSStore.City);
        if POSStore."Phone No." <> '' then
            Printer.AddLine(POSStore.FieldCaption("Phone No.") + ' ' + POSStore."Phone No.");
        if Register."VAT No." <> '' then
            Printer.AddLine(Register.FieldCaption("VAT No.") + ' ' + Register."VAT No.");
        if POSStore."E-mail" <> '' then
            Printer.AddLine(POSStore.FieldCaption("E-mail") + ' ' + POSStore."E-mail");
        if POSStore."Home Page" <> '' then
            Printer.AddLine(POSStore."Home Page");

        Printer.SetPadChar(' ');
        Printer.AddLine('');

        Printer.SetBold(true);
        Printer.AddTextField(1, 0, LinesDescription);
        Printer.AddTextField(2, 2, LinesQuantity);
        Printer.AddTextField(3, 2, LinesAmount);
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

            if ("Sale Type" = "Sale Type"::Sale) and (Type = Type::Item) and Item.Get("No.") then begin
                PrintItemAmountLine();
                PrintItemInfo(Item);
            end;

            if ("Discount Amount" <> 0) and RetailSetup."Unit Price on Sales Ticket" and (Quantity <> 0) then begin
                Printer.AddTextField(1, 0, Prefixspace + LinesUnitPriceInclDisc);
                Printer.AddDecimalField(2, 2, ("Amount Including VAT" / Quantity));
                Printer.AddTextField(3, 2, '');
            end;

            if ("Discount %" <> 0) and (RetailSetup."Show Discount Percent") then begin
                Printer.AddTextField(1, 0, '');
                Printer.AddTextField(2, 2, Format("Discount %", 0, '<Precision,2:2><Standard Format,0>') + '%');
                Printer.AddTextField(3, 0, '');
            end;

            if ("Unit of Measure Code" <> '') and RetailSetup."Item Unit on Expeditions" then begin
                Printer.AddTextField(1, 0, Prefixspace + UnitTxt);
                Printer.AddTextField(2, 2, "Unit of Measure Code");
                Printer.AddTextField(3, 2, '');
            end;

            if "Serial No." <> '' then begin
                Printer.AddTextField(1, 0, LinesSerialNo);
                Printer.AddTextField(2, 2, "Serial No.");
                Printer.AddTextField(3, 2, '');
            end;

            if "Serial No. not Created" <> '' then begin
                Printer.AddTextField(1, 0, LinesSerialNo);
                Printer.AddTextField(2, 2, "Serial No. not Created");
                Printer.AddTextField(3, 2, '');
            end;

            PrintLineVariantDesc();

            if RetailSetup."Receipt - Show Variant code" and ("Variant Code" <> '') then begin
                Printer.AddTextField(1, 0, FieldCaption("Variant Code"));
                Printer.AddTextField(2, 2, "Variant Code");
                Printer.AddTextField(3, 2, '');
            end;
        end;
    end;

    local procedure PrintTotals()
    var
        SaleLinePOS2: Record "NPR Sale Line POS";
        TotalInclVAT: Decimal;
        TotalVAT: Decimal;
        TotalExclVAT: Decimal;
        RetailFormCode: Codeunit "NPR Retail Form Code";
        GLSetup: Record "General Ledger Setup";
        CurrencyCode: Text;
    begin
        if (SalePOS."Register No." <> '') and (SalePOS."Sales Ticket No." <> '') then begin
            with SaleLinePOS2 do begin
                SetCurrentKey("Discount Type");
                SetRange("Register No.", SalePOS."Register No.");
                SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

                SetFilter("Sale Type", '%1|%2', "Sale Type"::Sale, "Sale Type"::Deposit);
                CalcSums("Amount Including VAT");
                CalcSums(Amount);
                TotalExclVAT := Amount;
                TotalInclVAT := "Amount Including VAT";
                TotalVAT := TotalInclVAT - TotalExclVAT;

                SetFilter("Sale Type", '%1', "Sale Type"::"Out payment");
                SetFilter("Discount Type", '<>%1', "Discount Type"::Rounding);
                CalcSums("Amount Including VAT");
                TotalInclVAT := TotalInclVAT - "Amount Including VAT";
            end;

            if TotalInclVAT > 0 then begin
                Printer.AddLine('');

                Printer.SetBold(true);
                if GLSetup.Get() then
                    CurrencyCode := GLSetup."LCY Code";
                Printer.AddTextField(1, 0, TotalTxt + ' ' + CurrencyCode);
                Printer.AddDecimalField(2, 2, TotalInclVAT);
                Printer.SetBold(false);

                if TotalVAT <> 0 then begin
                    Printer.AddTextField(1, 0, TotalVATTxt);
                    Printer.AddDecimalField(2, 2, TotalVAT);
                end;

                if RetailSetup."Euro on Sales Ticket" and (RetailSetup."Euro Exchange Rate" <> 0) then begin
                    Printer.AddTextField(1, 0, TotalEuroTxt);
                    Printer.AddDecimalField(2, 2, TotalInclVAT / RetailSetup."Euro Exchange Rate");
                end;
            end;
        end;
    end;

    local procedure PrintFooter()
    var
        TempRetailComments: Record "NPR Retail Comment" temporary;
        Utility: Codeunit "NPR Utility";
        BonInfoTxt: Text;
        BonInfoTxt2: Text;
        Salesperson: Record "Salesperson/Purchaser";
        POSCustomerLocation: Record "NPR POS Customer Location";
    begin
        Printer.SetFont('A11');
        Printer.AddLine('');

        Utility.GetTicketText(TempRetailComments, Register);
        if TempRetailComments.FindSet then
            repeat
                Printer.AddTextField(1, 1, TempRetailComments.Comment)
until TempRetailComments.Next = 0;

        Printer.SetFont('A11');
        BonInfoTxt := StrSubstNo(Text10600012, SalePOS."Sales Ticket No.",
                                 Format(Today), Format(Time), SalePOS."Register No.");

        if RetailSetup."Salesperson on Sales Ticket" and
           Salesperson.Get(SalePOS."Salesperson Code") then begin
            BonInfoTxt2 := Text0009 + StrSubstNo(CopyStr(Salesperson.Name, 1, 30))
        end else
            BonInfoTxt2 := Text0009 + StrSubstNo(CopyStr(SalePOS."Salesperson Code", 1, 30));

        Printer.AddLine('');
        Printer.AddTextField(1, 1, BonInfoTxt);
        Printer.AddTextField(1, 1, BonInfoTxt2);
        if (SalePOS."Customer Location No." <> '') and POSCustomerLocation.Get(SalePOS."Customer Location No.") then
            Printer.AddTextField(1, 1, POSCustomerLocation.Description);

        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;

    //Aux

    local procedure PrintItemAmountLine()
    var
        QuantityAmountDesc: Text[30];
        Item: Record Item;
    begin
        with SaleLinePOS do begin
            if RetailSetup."Unit Price on Sales Ticket" and (Quantity <> 0) then
                QuantityAmountDesc := Format(Quantity) + ' * ' +
                                      Format(("Amount Including VAT" + "Discount Amount") /
                                              Quantity, 0, '<Precision,2:2><Standard Format,0>')
            else
                QuantityAmountDesc := Format(Quantity);

            if (Type = Type::Item) and RetailSetup."Sales Ticket Item" then
                Printer.AddTextField(1, 0, Prefixspace + "No.")
            else
                Printer.AddTextField(1, 0, '');

            Printer.AddTextField(2, 2, QuantityAmountDesc);
            Printer.AddDecimalField(3, 2, "Amount Including VAT");
        end;
    end;

    local procedure PrintItemInfo(var Item: Record Item)
    var
        AttributeManagement: Codeunit "NPR Attribute Management";
        AttributeArray: array[40] of Text[100];
        i: Integer;
        AttributeText: Text;
    begin
        with Item do begin
            //Print the first four item attributes with content
            if RetailSetup."Print Attributes On Receipt" then begin
                AttributeManagement.GetMasterDataAttributeValue(AttributeArray, 27, Item."No.");
                CompressArray(AttributeArray);

                i := 1;
                repeat
                    if AttributeArray[i] <> '' then
                        AttributeText += Prefixspace + AttributeArray[i];
                    i += 1;
                until i > 4;

                if AttributeText <> '' then
                    Printer.AddLine(AttributeText);
            end;

            if ("Unit List Price" <> 0) and RetailSetup."Recommended Price" then begin
                Printer.AddTextField(1, 0, Prefixspace + ItemInfoUnitListPrice);
                Printer.AddDecimalField(2, 2, Item."Unit List Price");
                Printer.AddTextField(3, 2, '');
            end;
        end;
    end;

    procedure PrintLineVariantDesc()
    var
        VariantDesc: Text[50];
        Text10600008: Label 'NO COLOR CODE';
        Text10600009: Label 'Color:';
        Text10600010: Label 'Size:';
        ItemVariant: Record "Item Variant";
    begin
        with SaleLinePOS do begin
            if ItemVariant.Get("No.", "Variant Code") and
               ((ItemVariant."NPR Variety 1" <> '') or
                (ItemVariant."NPR Variety 2" <> '') or
                (ItemVariant."NPR Variety 3" <> '') or
                (ItemVariant."NPR Variety 4" <> '')) then
                VariantDesc := ItemVariant.Description
        end;

        if VariantDesc <> '' then
            Printer.AddLine(VariantDesc);
    end;
}

