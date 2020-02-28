codeunit 6014560 "Report - Sales Ticket"
{
    // Report - Sales Ticket.
    //  Work started by Nicolai Esbensen.
    //  Adjusted by Mikkel Vilhelmsen.
    //  Implements the functionality of the sales ticket report.
    //  Fills a temp buffer using the CU "Line Print Buffer Mgt.".
    // 
    //  Only functionlity for extending the Sales Ticket Print should
    //  be put here. Nothing else.
    // 
    //  The individual functions reprensents sections in the report with
    //  ID 6060104.
    // 
    //  The function GetRecords, applies table filters to the necesarry data
    //  elements of the report, base on the codeunits run argument Rec: Record "Audit Roll".
    // 
    // NPR4.21/JHL/20160322 CASE 222417 Added CleanCash information
    // NPR5.25/MMV /20160627 CASE 245033 Print all customer/GL payments as sale lines (like gift vouchers) instead of under the body.
    //                                   Print account no. on payments when not gift/credit voucher.
    //                                   Removed old version comments.
    //                                   Simplified printed VAT as difference between amount incl. VAT & amount (Same as 6.2 & older reports).
    // NPR5.26/JHL/20160916 CASE 244106 Print CleanCash information through Event, in CU 6184500
    // NPR5.27/TSA/20160923  CASE 253316 Fixed a performance issue to validate drawer opening
    // NPR5.33/ANEN/20170427 CASE 273989 Extending to 40 attributes
    // NPR5.34/KENU/20170726 CASE 284023 Removed all "PrefixSpace", using '  ' instead
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles

    TableNo = "Audit Roll";

    trigger OnRun()
    begin
        Printer.SetAutoLineBreak(true);
        AuditRoll.CopyFilters(Rec);
        GetRecords;

        SetOpenDrawer;

        SetGiftCreditVoucherFlags;

        for CurrPageNo := 1 to 2 do begin
          if (CurrPageNo = 2) and (not (FlagReturnSale and (RetailConfiguration."Return Receipt Positive Amount" or (AuditRollTotals."Amount Including VAT" < 0))))
                              and (not FlagCustomerPayment) and (not FlagOutPayment)
                              and (not ((FlagGiftVoucher or FlagCreditVoucher) and RetailConfiguration."Copy Sales Ticket on Giftvo.")) then
            exit;

          Printer.SetBold(false);
          Printer.SetFont('A11');

          PrintHeader;
          if Customer.Get(AuditRoll."Customer No.") and
             (RetailConfiguration."Show Customer info on ticket") and
             (AuditRoll."Customer Type" = AuditRoll."Customer Type"::"Ord.") then
            PrintCustomerInfo
          else if Contact.Get(AuditRoll."Customer No.") and
             RetailConfiguration."Show Customer info on ticket" and
            (AuditRoll."Customer Type" = AuditRoll."Customer Type"::Cash) then
            PrintContactInfo
          else if Customer.Get(AuditRoll."Customer No.") and
            (AuditRoll."Customer Type" = AuditRoll."Customer Type"::"Ord.") then
            PrintStaffSaleInfo;

          Clear(CustomerPaymentAmount);
          Clear(AuditRollTotals);

          PrintLines(AuditRollSale);
          PrintTotals(AuditRollTotals);
          PrintAuditRollFinance;
          PrintAuditRollPayments;
          PrintBarCode;
          PrintFooter;
        end;
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
        AuditRollFinance: Record "Audit Roll";
        AuditRollPayment: Record "Audit Roll";
        Contact: Record Contact;
        Customer: Record Customer;
        Item: Record Item;
        POSUnit: Record "POS Unit";
        Register: Record Register;
        RetailConfiguration: Record "Retail Setup";
        Salesperson: Record "Salesperson/Purchaser";
        POSSetup: Codeunit "POS Setup";
        CurrPageNo: Integer;
        Text10600012: Label '%2 - Bon %1/%4 - %3';
        HeaderReceiptCopy: Label '*** COPY ***';
        PrefixSpace: Label '  ';
        "--- Audit Roll Sales ---": Label '--- Audit Roll Sales ---';
        LinesDescription: Label 'Description';
        LinesQuantity: Label 'Quantity';
        LinesAmount: Label 'Amount';
        "--- Flags ---": Integer;
        FlagCreditVoucher: Boolean;
        FlagCustomerPayment: Boolean;
        FlagReturnSale: Boolean;
        FlagGiftVoucher: Boolean;
        FlagCustomerFound: Boolean;
        FlagOutPayment: Boolean;
        FlagOpenDrawer: Boolean;
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
        "--- Globals ---": Integer;
        SubCurrencyGL: Decimal;
        TotalItems: Label 'Total items sold';
        "-- Audit Roll Payment --": Label '-- Audit Roll Payment --';
        PaymentRounding: Label 'Rounding';
        PaymentReference: Label 'Reference';
        AuditRollTotals: Record "Audit Roll" temporary;
        FlagDepositPayment: Boolean;
        UnitTxt: Label 'Unit:';
        CustomerPaymentAmount: Decimal;
        DepositTxt: Label 'Deposit:';
        IssuedTxt: Label 'Issued:';

    procedure PrintHeader()
    begin
        Printer.SetThreeColumnDistribution(0.465,0.35,0.235);

        Printer.SetFont('Control');

        if RetailConfiguration."Logo on Sales Ticket" then begin
          Printer.AddLine('G');
          Printer.AddLine('h');
        end;

        if FlagOpenDrawer and (CurrPageNo = 1) then
          Printer.AddLine('A');

        Printer.SetFont('A11');
        Printer.AddLine(Register.Name);
        if Register."Name 2" <> '' then
          Printer.AddLine(Register."Name 2");
        Printer.AddLine(Register.Address);
        Printer.AddLine(Register."Post Code" + ' ' + Register.City);
        if Register."Phone No." <> '' then
          Printer.AddLine(Register.FieldCaption("Phone No.") + ' ' + Register."Phone No.");
        if  Register."VAT No." <> '' then
          Printer.AddLine(Register.FieldCaption("VAT No.") + ' ' + Register."VAT No.");
        if Register."E-mail" <> '' then
          Printer.AddLine(Register.FieldCaption("E-mail") + ' ' + Register."E-mail");
        if Register.Website <> '' then
          Printer.AddLine(Register.Website);

        if (AuditRoll."No. Printed" > 0) and RetailConfiguration."Copy No. on Sales Ticket" then begin
          Printer.SetBold(true);
          Printer.AddLine(HeaderReceiptCopy + ' ' + Format(AuditRoll."No. Printed"));
          Printer.SetBold(false);
        end;

        Printer.AddLine('');
    end;

    procedure PrintCustomerInfo()
    begin
        Printer.AddLine(Customer.FieldCaption("No.") + ' ' + Customer."No.");
        Printer.AddLine(Customer.Name);
        Printer.AddLine(Customer.Address);
        Printer.AddLine(Customer."Post Code" + ' ' + Customer.City);
        Printer.AddLine('');
    end;

    procedure PrintContactInfo()
    begin
        Printer.AddLine(Contact.FieldCaption("No.") + ' ' + Contact."No.");
        Printer.AddLine(Contact.Name);
        Printer.AddLine(Contact.Address);
        Printer.AddLine(Contact."Post Code" + ' ' + Contact.City);
        Printer.AddLine('');
    end;

    procedure PrintStaffSaleInfo()
    begin
        if (Customer."Customer Price Group" = RetailConfiguration."Staff Price Group") or
           (Customer."Customer Disc. Group" = RetailConfiguration."Staff Disc. Group") then begin
          Printer.AddTextField(1,0,Text0003);
          Printer.AddTextField(2,0,Customer.Name);
          Printer.AddTextField(3,0,Customer."No.");
          Printer.AddLine('');
        end;
    end;

    procedure PrintLines(var AuditRoll: Record "Audit Roll")
    begin
        Printer.SetBold(true);
        Printer.AddTextField(1,0,LinesDescription);
        Printer.AddTextField(2,2,LinesQuantity);
        Printer.AddTextField(3,2,LinesAmount);
        Printer.NewLine;
        Printer.SetBold(false);

        AuditRoll.SetCurrentKey("Sales Ticket No.","Line No.");
        if AuditRollSale.FindSet then repeat
          if AuditRollSalesOnAfterGetRecord(AuditRollSale) then
            PrintLine(AuditRollSale);
        until AuditRoll.Next = 0;

        Printer.AddLine('');
    end;

    procedure PrintLine(var AuditRoll: Record "Audit Roll")
    begin
        with AuditRoll do begin
          //-NPR5.25 [245033]
          //IF (Type = Type::Customer) OR ((Type = Type::"G/L") AND NOT ("No." = Register."Credit Voucher Account")) THEN BEGIN
          if (Type = Type::Customer) or ((Type = Type::"G/L") and ("No." in [ Register."Credit Voucher Account", Register."Gift Voucher Account" ])) then begin
            if "No." = Register."Credit Voucher Account" then
              Description += ' - ' + "Credit voucher ref.";
          //+NPR5.25 [245033]
            if StrLen(Description) > 20 then
              Printer.AddLine(Description)
            else
              Printer.AddTextField(1,0,Description);
            Printer.AddDecimalField(2,2,"Amount Including VAT");
          //-NPR5.25 [245033]
          end else if (Type = Type::Customer) or (Type = Type::"G/L") then begin
            Printer.AddLine(Description);
            Printer.AddTextField(1,0,'  '+"No.");
            Printer.AddDecimalField(2,2,"Amount Including VAT");
          //+NPR5.25 [245033]
          end else if (Type = Type::Comment) and ("Sales Document No." <> '') and ("Unit Price" <> 0) then begin
            if StrLen(Description) > 20 then
              Printer.AddLine(Description)
            else
              Printer.AddTextField(1,0,Description);
            Printer.AddTextField(2,2,Format(Quantity) + ' * ' + Format("Unit Price",0,'<Precision,2:2><Standard Format,0>'));
            Printer.AddTextField(3,2,'');
          end else begin
            Printer.AddLine(CopyStr(Description,1,40));
            if StrLen(Description) > 40 then
              Printer.AddLine(CopyStr(Description,41,40));
          end;

          if RetailConfiguration."Description 2 on receipt" and ("Description 2" <> '') then
            Printer.AddLine("Description 2");

          if Type = Type::Item then
            PrintItemAmountLine(AuditRoll);

          if ("Sale Type" = "Sale Type"::Sale) and
             (Type        = Type::Item) and Item.Get("No.") then
            PrintItemInfo(Item);

          if ("Line Discount Amount" <> 0) and RetailConfiguration."Unit Price on Sales Ticket" and (Quantity <> 0) then begin
            Printer.AddTextField(1,0,'  '+LinesUnitPriceInclDisc);
            Printer.AddDecimalField(2,2,("Amount Including VAT" / Quantity));
            Printer.AddTextField(3,2,'');
          end;

          if ("Line Discount %" <>0) and (RetailConfiguration."Show Discount Percent") then begin
            Printer.AddTextField(1,0,'');
            Printer.AddTextField(2,2,Format(AuditRoll."Line Discount %",0,'<Precision,2:2><Standard Format,0>') + '%');
            Printer.AddTextField(3,0,'');
          end;

          if ("Unit of Measure Code" <> '') and RetailConfiguration."Item Unit on Expeditions" then begin
            Printer.AddTextField(1,0,'  '+UnitTxt);
            Printer.AddTextField(2,2,"Unit of Measure Code");
            Printer.AddTextField(3,2,'');
          end;

          if "Serial No." <> '' then begin
            Printer.AddTextField(1,0,LinesSerialNo);
            Printer.AddTextField(2,2,"Serial No.");
            Printer.AddTextField(3,2,'');
          end;

          if "Serial No. not Created" <> '' then begin
            Printer.AddTextField(1,0,LinesSerialNo);
            Printer.AddTextField(2,2,"Serial No. not Created");
            Printer.AddTextField(3,2,'');
          end;

          PrintLineVariantDesc(AuditRoll);

          if RetailConfiguration."Receipt - Show Variant code" and ("Variant Code" <> '') then begin
            Printer.AddTextField(1,0,FieldCaption("Variant Code"));
            Printer.AddTextField(2,2,"Variant Code");
            Printer.AddTextField(3,2,'');
          end;
        end;
    end;

    procedure PrintItemAmountLine(var AuditRoll: Record "Audit Roll")
    var
        QuantityAmountDesc: Text[30];
    begin
        with AuditRoll do begin
          if RetailConfiguration."Unit Price on Sales Ticket" and (Quantity <> 0) then
            QuantityAmountDesc := Format(Quantity)+ ' * '+
                                  Format(("Amount Including VAT"+"Line Discount Amount") /
                                          Quantity,0,'<Precision,2:2><Standard Format,0>')
          else
            QuantityAmountDesc := Format(Quantity);

          if (Type = Type::Item) and RetailConfiguration."Sales Ticket Item" then
            Printer.AddTextField(1,0,'  '+"No.")
          else if ("Sale Type" = "Sale Type"::Sale) and (Type = Type::Item) and Item.Get("No.") and RetailConfiguration."Show vendoe Itemno." then
            Printer.AddTextField(1,0,'  '+Item."Vendor Item No.")
          else
            Printer.AddTextField(1,0,'');

          Printer.AddTextField(2,2,QuantityAmountDesc);
          Printer.AddDecimalField(3,2,"Amount Including VAT");
        end;
    end;

    procedure PrintItemInfo(var Item: Record Item)
    var
        AttributeManagement: Codeunit "NPR Attribute Management";
        AttributeArray: array [40] of Text[100];
        i: Integer;
        AttributeText: Text;
    begin
        with Item do begin
          if RetailConfiguration."Print Attributes On Receipt" then begin
            AttributeManagement.GetMasterDataAttributeValue(AttributeArray, 27, Item."No.");
            CompressArray(AttributeArray);

            i := 1;
            repeat
              if AttributeArray[i] <> '' then
                AttributeText += '  ' + AttributeArray[i];
              i += 1;
            until i > 4;

            if AttributeText <> '' then
              Printer.AddLine(AttributeText);
          end;

          if ("Unit List Price" <> 0) and RetailConfiguration."Recommended Price" then begin
            Printer.AddTextField(1,0,'  '+ItemInfoUnitListPrice);
            Printer.AddDecimalField(2,2,Item."Unit List Price");
            Printer.AddTextField(3,2,'');
          end;

          if (RetailConfiguration."Show vendoe Itemno.") and ("Vendor Item No."<>'') and RetailConfiguration."Sales Ticket Item" then begin
            Printer.AddTextField(1,0,'  '+ItemInfoVendorNo);
            Printer.AddTextField(2,2,Item."Vendor Item No.");
            Printer.AddTextField(3,2,'');
          end;
        end;
    end;

    procedure PrintLineVariantDesc(AuditRoll: Record "Audit Roll")
    var
        ColorDesc: Text[50];
        VariantDesc: Text[50];
        SizeDesc: Text[50];
        Text10600008: Label 'NO COLOR CODE';
        Text10600009: Label 'Color:';
        Text10600010: Label 'Size:';
        ItemVariant: Record "Item Variant";
    begin
        with AuditRoll do begin
          //Variety
          if ItemVariant.Get("No.", "Variant Code") and
             ((ItemVariant."Variety 1" <> '') or
              (ItemVariant."Variety 2" <> '') or
              (ItemVariant."Variety 3" <> '') or
              (ItemVariant."Variety 4" <> '')) then begin
            VariantDesc := ItemVariant.Description;
          //-NPR5.23 [240916]
        //  END ELSE IF VarianceSetUp.GET("No.",Color,Size) THEN BEGIN
        //  //Color/Size
        //    IF (VarianceSetUp."Description - Color" <> Text10600008) THEN
        //      ColorDesc := Text10600009 + FORMAT(VarianceSetUp."Description - Color") + ' ';
        //    IF (VarianceSetUp."Description - Size"<>'') THEN
        //      SizeDesc  := Text10600010 + FORMAT(VarianceSetUp."Description - Size");
        //  END ELSE IF VariaXConfiguration.GET() THEN BEGIN
        //  //VariaX
        //    IF VariaXDimCombination.GET("Variant Code","No.",VariaXConfiguration."Color Dimension") THEN BEGIN
        //      VariaXDimCombination.CALCFIELDS(Description);
        //      ColorDesc := Text10600009 + FORMAT(VariaXDimCombination.Description) + ' ';
        //    END;
        //    IF VariaXDimCombination.GET("Variant Code","No.",VariaXConfiguration."Size Dimension") THEN BEGIN
        //      VariaXDimCombination.CALCFIELDS(Description);
        //      SizeDesc := Text10600010 + FORMAT(VariaXDimCombination.Description);
        //    END;
          //+NPR5.23 [240916]
          end;
        end;

        if VariantDesc = '' then
          VariantDesc := ColorDesc + SizeDesc;

        if VariantDesc <> '' then
          Printer.AddLine(VariantDesc);
    end;

    procedure PrintTotals(var AuditRoll: Record "Audit Roll")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
        TotalQuantity: Decimal;
    begin
        if RetailConfiguration."Print Total Item Quantity" then begin
          if AuditRollSale.FindSet then repeat
            if (AuditRollSale."Sale Type" = AuditRollSale."Sale Type"::Sale) and (AuditRollSale.Type = AuditRollSale.Type::Item) and (AuditRollSale.Quantity > 0) then
              TotalQuantity += AuditRollSale.Quantity;
          until AuditRollSale.Next = 0;
          if TotalQuantity > 0 then begin
            Printer.AddTextField(1,0,TotalItems);
            Printer.AddTextField(2,2,Format(TotalQuantity));
            Printer.AddTextField(3,2,'');
          end;
        end;

        with AuditRoll do begin
          //-NPR5.25 [245033]
          //IF "Amount Including VAT" <> 0 THEN BEGIN
          //+NPR5.25 [245033]
          Printer.SetBold(true);
          if GeneralLedgerSetup.Get then
            CurrencyCode := GeneralLedgerSetup."LCY Code";
          Printer.AddTextField(1,0,Total + ' ' + CurrencyCode);
          Printer.AddDecimalField(2,2,"Amount Including VAT");
          Printer.SetBold(false);

          if ("Line Discount Amount" <> 0) and (RetailConfiguration.SamletBonRabat) and
              not RetailConfiguration."Show Discount Percent" then begin
            Printer.AddTextField(1,0,TotalDiscount);
            Printer.AddDecimalField(2,2,"Line Discount Amount");
          end;

          if ("Line Discount Amount" <> 0) and (RetailConfiguration.SamletBonRabat) and
              RetailConfiguration."Show Discount Percent" then begin
            Printer.AddTextField(1,0,TotalDiscount);
            Printer.AddTextField(2,2,Format(Round(("Line Discount Amount"*100)/("Line Discount Amount"+"Amount Including VAT"),0.1)) +' %');
            Printer.AddDecimalField(3,2,"Line Discount Amount");
          end;

          //-NPR5.25 [245033]
        //  IF "VAT Base Amount" <> 0 THEN BEGIN
        //    Printer.AddTextField(1,0,TotalVAT);
        //    Printer.AddDecimalField(2,2,"VAT Base Amount");
        //  IF ("Amount Including VAT" - Amount) <> 0 THEN BEGIN
            Printer.AddTextField(1,0,TotalVAT);
            Printer.AddDecimalField(2,2,("Amount Including VAT" - Amount));
        //  END;
          //+NPR5.25 [245033]

          //-NPR5.25 [245033]
          //IF RetailConfiguration."Euro on Sales Ticket" AND ("Amount Including VAT" <> 0) THEN BEGIN
          if RetailConfiguration."Euro on Sales Ticket" and ("Amount Including VAT" <> 0) and (RetailConfiguration."Euro Exchange Rate" <> 0) then begin
          //+NPR5.25 [245033]
            Printer.AddTextField(1,0,TotalEuro);
            Printer.AddDecimalField(2,2,"Amount Including VAT"/RetailConfiguration."Euro Exchange Rate");
          end;

          //-NPR5.25 [245033]
          if "Amount Including VAT" <> 0 then begin
          //+NPR5.25 [245033]
            Printer.SetBold(true);
            Printer.AddLine(TotalSettlement);
            Printer.SetBold(false);
          end;
        end;
    end;

    procedure PrintAuditRollFinance()
    var
        Text10600026: Label 'Payment';
        Text10600027: Label 'on account';
        Text10600028: Label 'settlement';
        VATTotal: Decimal;
        PaymentTypePOS: Record "Payment Type POS";
    begin
        with AuditRollFinance do begin
          if FindSet then repeat
            if ("Sale Type" = "Sale Type"::Deposit) then begin

              PaymentTypePOS.SetRange("G/L Account No.","No.");
              PaymentTypePOS.SetFilter("Processing Type", '%1|%2', PaymentTypePOS."Processing Type"::"Gift Voucher", PaymentTypePOS."Processing Type"::"Credit Voucher");

              FlagCustomerPayment := PaymentTypePOS.IsEmpty;
              //-NPR5.25 [245033]
        //      IF NOT FlagCreditVoucher AND NOT (FlagGiftVoucher) THEN
        //        Printer.AddLine(DepositTxt);

        //      IF FlagCreditVoucher AND NOT (FlagGiftVoucher) THEN BEGIN
        //        Printer.AddLine(IssuedTxt);
        //      END;
              //+NPR5.25 [245033]
            end;

            //-NPR5.25 [245033]
        //    IF ("Sale Type" = "Sale Type"::Indbetaling) AND NOT FlagGiftVoucher THEN BEGIN
        //      Printer.AddTextField(1, 0, Description + ' ' + FORMAT("Credit voucher ref."));
        //      Printer.AddDecimalField(1, 2, "Amount Including VAT");
        //    END;
            //+NPR5.25 [245033]
          until Next = 0;
        end;
    end;

    procedure PrintAuditRollPayments()
    var
        PaymentTypePOS: Record "Payment Type POS";
        TextBalBefore: Label 'Balance before ';
        TextBalCurrent: Label 'Current balance';
    begin
        with AuditRollPayment do begin
          if FindSet then repeat
            if PaymentTypePOS.Get("No.") then begin
              case PaymentTypePOS."Processing Type" of
                PaymentTypePOS."Processing Type"::"Foreign Currency" :
                  begin
                    Printer.AddTextField(1,0,Description);
                    Printer.AddDecimalField(2,2,"Currency Amount");
                  end;
                PaymentTypePOS."Processing Type"::"Terminal Card",
                PaymentTypePOS."Processing Type"::EFT :
                  begin
                    Printer.AddTextField(1,0,Description);
                    Printer.AddDecimalField(2,2,"Amount Including VAT");
                    Printer.AddLine('');
                  end;
                else begin
                  if StrLen(Description) > 20 then
                    Printer.AddLine(Description)
                  else
                    Printer.AddTextField(1,0,Description);
                  Printer.AddDecimalField(2,2,"Amount Including VAT");
                end;
              end;
            end;
          until Next = 0;

          CalcSums("Amount Including VAT");

          if SubCurrencyGL <> 0 then begin
            Printer.AddTextField(1,0,PaymentRounding);
            Printer.AddDecimalField(2,2,SubCurrencyGL);
          end;

          if Reference <> '' then begin
            Printer.AddTextField(1,0,PaymentReference);
            Printer.AddTextField(2,2,Reference);
          end;

          if FlagCustomerPayment and (Customer."No." <> '') and (CustomerPaymentAmount <> 0) then begin
              Printer.SetPadChar('_');
              Printer.AddLine('');
              Printer.SetPadChar('');
              Customer.CalcFields(Balance);

              Printer.AddTextField(1,0,Text0004);
              Printer.AddDecimalField(2,2,CustomerPaymentAmount);
              if ("No. Printed" = 0) and RetailConfiguration."Post Customer Payment imme." and not FlagDepositPayment then begin
                Printer.AddTextField(1,0,TextBalBefore);
                Printer.AddDecimalField(2,2,Customer.Balance);

                Printer.AddTextField(1,0,Text0005);
                Printer.AddDecimalField(2,2,Customer.Balance - CustomerPaymentAmount);
              end;
          end;
        end;
    end;

    procedure PrintBarCode()
    begin
        if (RetailConfiguration."Bar Code on Sales Ticket Print")
          and (Register."Receipt Printer Type"=Register."Receipt Printer Type"::Samsung) then begin
            Error('NOT IMPLEMENTED!');
        end;

        if RetailConfiguration."Bar Code on Sales Ticket Print"
          and (Register."Receipt Printer Type"=Register."Receipt Printer Type"::"TM-T88") then begin
            Printer.AddBarcode('Code39',AuditRoll."Sales Ticket No.",4);
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
        Printer.AddLine('');

        Utility.GetTicketText(TempRetailComments, Register);
        if TempRetailComments.FindSet then repeat
          Printer.AddTextField(1,1,TempRetailComments.Comment)
        until TempRetailComments.Next = 0;

        Printer.NewLine;

        if (CurrPageNo = 2) and (FlagReturnSale) and (not FlagCreditVoucher) then begin
          Printer.AddLine('');
          Printer.SetPadChar('_');
          Printer.AddLine(Text0006);
          Printer.SetPadChar('');
          Printer.NewLine;
          Printer.AddLine('');
          Printer.SetPadChar('_');
          Printer.AddLine(Text0007);
          Printer.SetPadChar('');
          Printer.NewLine;
          Printer.AddLine('');
          Printer.SetPadChar('_');
          Printer.AddLine('');
          Printer.SetPadChar('');
        end;

        if ((FlagCreditVoucher or FlagCustomerPayment or FlagGiftVoucher) and (CurrPageNo = 2)) or
           ((CurrPageNo = 1) and FlagOutPayment) or
           ((FlagReturnSale) and (RetailConfiguration."Signature for Return") and (CurrPageNo = 2)) then begin
          if FlagCustomerPayment then
            Printer.AddTextField(1, 1, Text10600020)
          else
            Printer.AddTextField(1, 1, Text10600019);

          Printer.AddDateField(1, 2, Today);
          Printer.AddLine('');
          Printer.AddLine('');
          Printer.SetPadChar('-');
          Printer.AddLine('');
          Printer.SetPadChar('');
        end;

        // Info Footer Text
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

        //-NPR5.26
        //PrintCleanCash;
        OnPrintCleanCash(Printer, AuditRoll);
        //+NPR5.26

        Printer.SetFont('Control');
        Printer.AddLine('P');
    end;

    procedure "--- Record Triggers ---"()
    begin
    end;

    procedure AuditRollSalesOnAfterGetRecord(var AuditRollSales: Record "Audit Roll") DoNotSkip: Boolean
    begin
        with AuditRollSales do begin
          DoNotSkip := true;
          if (Type = Type::Item) and Item.Get("No.") and Item."No Print on Reciept" then
             exit(false);

          //IF ("Amount Including VAT" <> 0) AND (Type = Type::"G/L") AND ("No." = Register.Rounding) THEN BEGIN  //#[371955]-revoked
          if ("Amount Including VAT" <> 0) and (Type = Type::"G/L") and ("No." = POSSetup.RoundingAccount(true)) then begin  //NPR5.53 [371955]
            SubCurrencyGL := "Amount Including VAT";
            exit(false);
          end;

          if Quantity < 0 then
            FlagReturnSale := true;

          if "Sale Type" = "Sale Type"::"Out payment" then begin
            "Unit Price"           *= -1;
            "Amount Including VAT" *= -1;
            Amount                 *= -1;
            FlagOutPayment         := true;
          end;

          if ("Sale Type" = "Sale Type"::Deposit) and (Type = Type::Customer) then begin
            FlagCustomerPayment := true;
            if "Sales Document Prepayment" then
              SetDepositPaymentFlag;
          end;
        end;

        CalcSaleLineTotals(AuditRollSales);
    end;

    procedure AuditRollSalesOnPostDataItem(var AuditRollSales: Record "Audit Roll")
    begin
    end;

    procedure "-- Init --"()
    begin
    end;

    procedure GetRecords()
    begin
        AuditRoll.FindSet;
          AuditRollSale.CopyFilters(AuditRoll);
          AuditRollSale.SetFilter("Sale Type",'%1|%2|%3|%4|%5',
                                              AuditRollSale."Sale Type"::Sale,
                                              AuditRollSale."Sale Type"::"Out payment",
                                              AuditRollSale."Sale Type"::Deposit,
                                              AuditRollSale."Sale Type"::Comment,
                                              AuditRollSale."Sale Type"::"Debit Sale");

          AuditRollFinance.CopyFilters(AuditRoll);
          AuditRollFinance.SetFilter("Sale Type",'%1',AuditRollFinance."Sale Type"::Deposit);
          AuditRollFinance.SetFilter(Type,'%1',AuditRollFinance.Type::"G/L");

          AuditRollPayment.CopyFilters(AuditRoll);
          AuditRollPayment.SetRange("Sale Type",AuditRollPayment."Sale Type"::Payment);

        Register.Get(AuditRoll."Register No.");
        RetailConfiguration.Get;
        //-NPR5.53 [371955]
        POSUnit.Get(AuditRoll."Register No.");
        POSSetup.SetPOSUnit(POSUnit);
        //+NPR5.53 [371955]
    end;

    procedure "-- Aux functions --"()
    begin
    end;

    local procedure CalcSaleLineTotals(var "Audit Roll": Record "Audit Roll")
    begin
        with "Audit Roll" do begin
          AuditRollTotals."Amount Including VAT" += "Amount Including VAT";
          AuditRollTotals.Amount                 += Amount;
          AuditRollTotals."Line Discount Amount" += "Line Discount Amount";

          //-NPR5.25 [245033]
        //  IF Type = Type::Item THEN
        //    AuditRollTotals."VAT Base Amount"    += ("Amount Including VAT" - Amount);
          //+NPR5.25 [245033]

          if ("Sale Type" = "Sale Type"::Deposit) and not ((Type = Type::"G/L") and ("No." in [Register."Credit Voucher Account", Register."Gift Voucher Account"])) then
            CustomerPaymentAmount += "Amount Including VAT";
        end;
    end;

    local procedure SetOpenDrawer()
    var
        AuditRoll2: Record "Audit Roll";
        PaymentTypePos: Record "Payment Type POS";
    begin
        FlagOpenDrawer := true;

        if not Register."Money drawer - open on special" then begin
          FlagOpenDrawer := false;
          if AuditRoll."No. Printed" < 1 then begin
            AuditRoll2.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
            AuditRoll2.SetRange(Description);
            AuditRoll2.SetRange("Sale Type");
            PaymentTypePos.SetFilter("Processing Type",'%1|%2',
                                     PaymentTypePos."Processing Type"::Cash,
                                     PaymentTypePos."Processing Type"::"Foreign Currency");
            if PaymentTypePos.FindSet then repeat
              AuditRoll2.SetRange("No.",PaymentTypePos."No.");
              //-NPR5.27 [253316]
              //IF AuditRoll2.COUNT > 0 THEN
              //  FlagOpenDrawer := TRUE;
              FlagOpenDrawer := not AuditRoll2.IsEmpty ();
              //-NPR5.27 [253316]
            until (PaymentTypePos.Next = 0) or FlagOpenDrawer;
          end;
        end;
    end;

    local procedure SetGiftCreditVoucherFlags()
    var
        GiftVoucher: Record "Gift Voucher";
        CreditVoucher: Record "Credit Voucher";
    begin
        with AuditRollFinance do
          if FindSet then repeat
            FlagGiftVoucher   := ("No." = Register."Gift Voucher Account")   and GiftVoucher.Get(AuditRollFinance."Gift voucher ref.");
            FlagCreditVoucher := ("No." = Register."Credit Voucher Account") and CreditVoucher.Get(AuditRollFinance."Credit voucher ref.");
          until (Next = 0) or (FlagGiftVoucher and FlagCreditVoucher);
    end;

    local procedure SetDepositPaymentFlag()
    var
        AuditRoll2: Record "Audit Roll";
    begin
        AuditRoll2.CopyFilters(AuditRoll);
        AuditRoll2.SetRange("Sale Type", AuditRoll2."Sale Type"::Deposit);
        AuditRoll2.SetRange(Type, AuditRoll2.Type::Customer);

        FlagDepositPayment := true;
        if AuditRoll2.FindSet then repeat
          if (AuditRoll2."Sales Document No." = '') then
            FlagDepositPayment := false;
        until (AuditRoll2.Next = 0) or (FlagDepositPayment = false);
    end;

    local procedure PrintCleanCash()
    var
        CleanCashWrapper: Codeunit "CleanCash Wrapper";
        AuditRollCleanCash: Record "Audit Roll";
        Lines: Integer;
        i: Integer;
        ReceiptNo: Code[10];
        SerialNo: Text[30];
        ControlCode: Text[100];
        CopySerialNo: Text[30];
        CopyControlCode: Text[100];
        txtReceiptNo: Label 'Receipt No.';
        txtSerialNo: Label 'Serial No.';
        txtControlCode: Label 'Control Code';
    begin
        //-NPR5.26
        /*
        AuditRollCleanCash.COPY(AuditRoll);
        IF AuditRollCleanCash.FINDFIRST THEN
          IF CleanCashWrapper.InitCleanCashData(AuditRollCleanCash) THEN BEGIN
            Lines := CleanCashWrapper.GetLines();
            FOR i := 1 TO Lines DO BEGIN
              CleanCashWrapper.GetCleanCashInformation(ReceiptNo, SerialNo, ControlCode, CopySerialNo, CopyControlCode);
              Printer.NewLine;
              Printer.AddLine(txtReceiptNo);
              Printer.AddLine(ReceiptNo);
              Printer.NewLine;
              Printer.AddLine(txtSerialNo);
              IF CopySerialNo = '' THEN
                Printer.AddLine(SerialNo)
              ELSE
                Printer.AddLine(CopySerialNo);
              Printer.NewLine;
              Printer.AddLine(txtControlCode);
              IF CopySerialNo = '' THEN BEGIN
                Printer.AddLine(COPYSTR(ControlCode,1,30));
                Printer.AddLine(COPYSTR(ControlCode,31,60));
              END ELSE BEGIN
                Printer.AddLine(COPYSTR(CopyControlCode,1,30));
                Printer.AddLine(COPYSTR(CopyControlCode,31,60));
              END;
        
            END;
          END;
        */
        //+NPR5.26

    end;

    [IntegrationEvent(false, false)]
    local procedure OnPrintCleanCash(var LinePrintMgt: Codeunit "RP Line Print Mgt.";var AuditRoll: Record "Audit Roll")
    begin
        //-NPR5.26
        //+NPR5.26
    end;
}

