report 6014410 "Sales Ticket A4"
{
    // NPR4.14/TR/20150805 CASE 218865 Report build on Sales Ticket design in codeunit 6014560.
    // NPR4.14/RMT/20150715  CASE 216519 Added
    // NPR5.23/JDH /20160513 CASE 240916 Removed old VariaX Solution
    // NPR5.29/JLK /20161221 CASE 261538 Removed hardcoded Item in RDLC
    // NPR5.49/BHR /20190207 CASE 343119 Correct report as per OMA
    // NPR5.51/MITH/20190626 CASE 355048 Changed the variable to use for calculating totals.
    // NPR5.51/ZESO/20190704 CASE 357511 Display summary of different VAT%, Added DataItem Audit Roll Group VAT Totals
    // NPR5.51/ANPA/20190711 CASE 359431 Changed the length of email in layout, split amount and price into two values, space added between serial no and next line,
    //                                   space between serial no. and text and removed "show customer info on ticket" parameter.
    //                                   Split quantity and price into two columns.
    // NPR5.51/ANPA/20190722 CASE 362537 Always showing discount
    // NPR5.52/ANPA/20191009  CASE 359431 Added DiscountTxt value
    // NPR5.52/ANPA/20191004  CASE 371523 Added Sales Type as parameter
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles
    DefaultLayout = RDLC;
    RDLCLayout = './Sales Ticket A4.rdlc';

    Caption = 'Sales Ticket A4';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Audit Roll";"Audit Roll")
        {
            column(Picture_CompanyInformation;CompanyInformation.Picture)
            {
            }
            column(RegisterNo_AuditRoll;"Audit Roll"."Register No.")
            {
            }
            column(SalesTicketNo_AuditRoll;"Audit Roll"."Sales Ticket No.")
            {
            }
            column(SaleDate_AuditRoll;AuditRollSale."Sale Date")
            {
            }
            column(CopyNo_AuditRoll;"Audit Roll"."Copy No.")
            {
            }
            column(Name_SalespersonPurchaser;SalespersonPurchaser.Name)
            {
            }
            column(RegisterNo_Register;Register."Register No.")
            {
            }
            column(Name_Register;Register.Name)
            {
            }
            column(Addres_Register;Register.Address)
            {
            }
            column(City_Register;Register.City)
            {
            }
            column(PostCode_Register;Register."Post Code")
            {
            }
            column(Telephone_Register;Register."Phone No.")
            {
            }
            column(Email_Register;Register."E-mail")
            {
            }
            column(Website_Register;Register.Website)
            {
            }
            column(VATNo_Register;Register."VAT No.")
            {
            }
            column(ContactNo;ContactNo)
            {
            }
            column(ContactName;ContactName)
            {
            }
            column(ContactAddress;ContactAddress)
            {
            }
            column(ContactCity;ContactCity)
            {
            }
            column(ContactPostCode;ContactPostCode)
            {
            }
            column(TotalVAT_;varTotalVat)
            {
            }
            dataitem(AuditRollSale;"Audit Roll")
            {
                DataItemLink = "Register No."=FIELD("Register No."),"Sales Ticket No."=FIELD("Sales Ticket No.");
                DataItemTableView = SORTING("Sales Ticket No.","Line No.") WHERE("Sale Type"=FILTER(Sale|"Out payment"|Deposit|Comment|"Debit Sale"));
                column(LineNo_AuditRollSale;"Line No.")
                {
                }
                column(Type_AuditRollSale;Type)
                {
                }
                column(SaleType_AuditRollSale;AuditRollSale."Sale Type")
                {
                }
                column(AmountLine;AmountLine)
                {
                }
                column(DescriptionLine;DescriptionLine)
                {
                }
                column(DescriptionLine2;DescriptionLine2)
                {
                }
                column(ItemInfo;ItemInfo)
                {
                }
                column(ItemNo;ItemNo)
                {
                }
                column(LineDiscountPctNew;LineDiscountPctNew)
                {
                }
                column(LineDiscountPct;LineDiscountPct)
                {
                }
                column(LineDiscountAmount;LineDiscountAmount)
                {
                }
                column(QuantityAmountLine;QuantityAmountLine)
                {
                }
                column(QuantityLine;QuantityLine)
                {
                }
                column(SerialNo_AuditrollSale;"Serial No.")
                {
                }
                column(SerialNoNotCreate_AuditRollSale;"Serial No. not Created")
                {
                }
                column(SeriealNoTxt;SerialNoTxt)
                {
                }
                column(ShowOutPayment;ShowOutPayment)
                {
                }
                column(ShowDeposit;ShowDeposit)
                {
                }
                column(VariantDesc;VariantDesc)
                {
                }
                column(UnitPriceExclDiscountLine;UnitPriceExclDiscountLine)
                {
                }
                column(UnitPriceInlcDiscountLine;UnitPriceInlcDiscountLine)
                {
                }
                column(IsItem;IsItem)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ResetVariables;
                    AuditRollSalesOnAfterGetRecord(AuditRollSale);
                    DescriptionLine := Description;
                    if (Type = Type::Customer) or ((Type = Type::"G/L") and not ("No." = Register."Credit Voucher Account")) then begin
                      AmountLine := "Amount Including VAT";
                    end else if (Type = Type::Comment) and ("Sales Document No." <> '') and ("Unit Price" <> 0) then begin
                      //-NPR5.51 [359431]
                      //QuantityLine := FORMAT(Quantity) + ' * ' + FORMAT("Unit Price",0,'<Precision,2:2><Standard Format,0>');
                      QuantityLine := Format(Quantity);
                      UnitPriceExclDiscountLine := Format("Unit Price",0,'<Precision,2:2><Standard Format,0>');
                      //+NPR5.51 [359431]
                    end;

                    if RetailSetup."Description 2 on receipt" and ("Description 2" <> '') then
                      DescriptionLine2 := "Description 2";

                    if ("Audit Roll"."Amount Including VAT" <> 0) and (Type = Type::Item) then begin
                    //-NPR5.51 [359431]
                      //IF RetailSetup."Unit Price on Sales Ticket" AND (Quantity <> 0) THEN
                      if RetailSetup."Unit Price on Sales Ticket" and (Quantity <> 0) then begin

                        //QuantityAmountLine := FORMAT(Quantity) + ' * ' +
                                               //FORMAT(("Amount Including VAT" + "Line Discount Amount") /
                                                      //Quantity,0,'<Precision,2:2><Standard Format,0>')
                        QuantityLine := Format(Quantity);
                        UnitPriceExclDiscountLine := Format(("Amount Including VAT" + "Line Discount Amount") /
                                                      Quantity,0,'<Precision,2:2><Standard Format,0>');
                        end
                        //+NPR5.51 [359431]
                      else
                        //-NPR5.51 [359431]
                        //QuantityAmountLine := FORMAT(Quantity);
                        QuantityLine := Format(Quantity);
                        //+NPR5.51 [359431]

                      if (Type = Type::Item) then
                        ItemNo := "No.";
                      AmountLine := "Amount Including VAT";
                    end;

                    if ("Sale Type" = "Sale Type"::Sale) and  (Type = Type::Item) and Item.Get("No.") then begin
                      if (Item."Unit List Price" <> 0) and RetailSetup."Recommended Price" then begin
                        ItemInfo := StrSubstNo(Text0002,Item."Unit List Price");
                      end;

                      if (RetailSetup."Show vendoe Itemno.") and (Item."Vendor Item No." <> '') then begin
                        ItemInfo := StrSubstNo(Text0003,Item."Vendor Item No.");
                      end;
                    end;

                    if ("Line Discount Amount" <> 0) and RetailSetup."Unit Price on Sales Ticket" and (Quantity <> 0) then begin
                      UnitPriceInlcDiscountLine := "Amount Including VAT" / Quantity;
                    end;

                    //-362537 [362537]
                    //IF ("Line Discount %" <> 0) AND (RetailSetup."Show Discount Percent") THEN BEGIN
                    if ("Line Discount %" <> 0) then begin
                      LineDiscountPct := AuditRollSale."Line Discount %";
                      LineDiscountPctNew := '-' + Format(AuditRollSale."Line Discount %",0,'<Precision,2:2><Standard Format,0>') + '%';
                      LineDiscountAmount := '-' + Format(AuditRollSale."Line Discount Amount", 0, '<Precision,2:2><Standard Format,0>');

                    end;
                    //+362537 [362537]

                    PrintLineVariantDesc(AuditRollSale);

                    if RetailSetup."Receipt - Show Variant code" and ("Variant Code" <> '') then
                      VariantCode := "Variant Code";

                    ShowOutPayment := "Sale Type" = "Sale Type"::"Out payment";
                    ShowDeposit := "Sale Type" = "Sale Type"::Deposit;

                    //+NPR5.29
                    Clear(IsItem);
                    if Type = Type::Item then
                      IsItem := true;
                    //-NPR5.29
                end;
            }
            dataitem(AuditRollFinance;"Audit Roll")
            {
                DataItemLink = "Register No."=FIELD("Register No."),"Sales Ticket No."=FIELD("Sales Ticket No.");
                DataItemTableView = SORTING("Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date") WHERE("Sale Type"=FILTER(Deposit),Type=FILTER("G/L"));
                column(LineNo_AuditRollFinance;"Line No.")
                {
                }
                column(FinansDescriptionLine;FinansDescriptionLine)
                {
                }
                column(AmountIncludingVAT_AuditRollFinance;"Amount Including VAT")
                {
                }

                trigger OnAfterGetRecord()
                var
                    PaymentTypePOS: Record "Payment Type POS";
                begin
                    if ("Sale Type" = "Sale Type"::Deposit) then begin
                      PaymentTypePOS.SetRange("G/L Account No.","No.");
                      PaymentTypePOS.SetFilter("Processing Type", '%1|%2', PaymentTypePOS."Processing Type"::"Gift Voucher", PaymentTypePOS."Processing Type"::"Credit Voucher");

                      FlagCustomerPayment := PaymentTypePOS.IsEmpty;

                    //TODO
                    //  IF FlagCustomerFound AND NOT FlagGiftVoucher THEN BEGIN
                    //    Printer.AddLine(Text10600026);
                    //    Printer.AddLine(Text10600027 + ' ' + FORMAT("No."));
                    //    Printer.AddLine(FORMAT("Buffer Document Type")+' '+"Buffer ID");
                    //  END ELSE BEGIN
                    //    IF NOT FlagCreditVoucher AND NOT (FlagGiftVoucher) THEN
                    //      Printer.AddLine('Indbetaling:');
                    //    IF FlagCreditVoucher AND NOT (FlagGiftVoucher) THEN BEGIN
                    //      Printer.AddLine('Udstedt:');
                    //    END;
                    //  END;
                    end;
                    //TODO

                    if ("Sale Type" = "Sale Type"::Deposit) and not FlagGiftVoucher then
                      FinansDescriptionLine := Description + ' ' + Format("Credit voucher ref.");
                end;
            }
            dataitem(AuditRollPayment;"Audit Roll")
            {
                DataItemLink = "Register No."=FIELD("Register No."),"Sales Ticket No."=FIELD("Sales Ticket No.");
                DataItemTableView = SORTING("Register No.","Sales Ticket No.","Sale Type","Line No.","No.","Sale Date") WHERE("Sale Type"=FILTER(Payment));
                column(LineNo_AuditRollPayment;"Line No.")
                {
                }
                column(AmountPaymentLine;AmountPaymentLine)
                {
                }
                column(DescriptionPaymentLine;DescriptionPaymentLine)
                {
                }

                trigger OnAfterGetRecord()
                var
                    PaymentTypePOS: Record "Payment Type POS";
                begin
                    if PaymentTypePOS.Get("No.") then begin
                      case PaymentTypePOS."Processing Type" of
                        PaymentTypePOS."Processing Type"::"Foreign Currency" :
                          begin
                            DescriptionPaymentLine := Description;
                            AmountPaymentLine := "Currency Amount";
                          end;
                        PaymentTypePOS."Processing Type"::"Terminal Card",
                        PaymentTypePOS."Processing Type"::EFT :
                          begin
                            DescriptionPaymentLine := Description;
                            AmountPaymentLine := "Amount Including VAT";
                          end;
                        else begin
                          DescriptionPaymentLine := Description;
                          AmountPaymentLine := "Amount Including VAT";
                        end;
                      end;
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    CalcSums("Amount Including VAT");
                    ShowAmountInclVatPayment := false;
                    ShowAdditionalInfo := false;
                    if FlagCustomerPayment and (Customer."No." <> '') then begin
                        Customer.CalcFields(Balance);
                        ShowAmountInclVatPayment := true;
                        if ("No. Printed" = 0) and RetailSetup."Post Customer Payment imme." and not FlagDepositPayment then begin
                          ShowAdditionalInfo := true;
                        end;
                    end;
                end;
            }
            dataitem("Audit Roll Group VAT Totals";"NPR - TEMP Buffer")
            {
                UseTemporary = true;
                column(BTWPerc;"Audit Roll Group VAT Totals"."Code 1")
                {
                }
                column(BTWAmount;"Audit Roll Group VAT Totals"."Decimal 1")
                {
                }
                column(BTWExcl;"Audit Roll Group VAT Totals"."Decimal 2")
                {
                }
                column(BTWInc;"Audit Roll Group VAT Totals"."Decimal 3")
                {
                }
            }

            trigger OnAfterGetRecord()
            var
                QueryVATTotals: Query "VAT Totals";
                varLineNo: Integer;
            begin
                Register.Get("Audit Roll"."Register No.");
                //-NPR5.53 [371955]
                POSUnit.Get("Register No.");
                POSSetup.SetPOSUnit(POSUnit);
                //+NPR5.53 [371955]
                RetailSetup.Get;
                if SalespersonPurchaser.Get("Audit Roll"."Salesperson Code") then;
                Clear(AuditRollTotals);
                AuditRollTotals."Amount Including VAT" := 0;
                AuditRollTotals.Amount := 0;
                AuditRollTotals."Line Discount Amount" := 0;

                //-NPR5.51 [359431]
                //IF Customer.GET("Customer No.") AND  (RetailSetup."Show Customer info on ticket") AND ("Customer Type" = "Customer Type"::"Ord.") THEN
                if Customer.Get("Customer No.") and ("Customer Type" = "Customer Type"::"Ord.") then
                //+NPR5.51 [359431]
                  PrintCustomerInfo
                //-NPR5.51 [359431]
                //ELSE IF Contact.GET("Customer No.") AND  (RetailSetup."Show Customer info on ticket") AND ("Customer Type" = "Customer Type"::Cash) THEN
                else if Contact.Get("Customer No.") and ("Customer Type" = "Customer Type"::Cash) then
                //+NPR5.51 [359431]
                  PrintContactInfo
                else if Customer.Get("Customer No.") and ("Customer Type" = "Customer Type"::"Ord.") then
                  PrintStaffSaleInfo;

                AuditRollFinance.CopyFilters("Audit Roll");
                AuditRollFinance.SetFilter("Sale Type",'%1',AuditRollFinance."Sale Type"::Deposit);
                AuditRollFinance.SetFilter(Type,'%1',AuditRollFinance.Type::"G/L");
                SetGiftCreditVoucherFlags;
                Clear(AuditRollFinance);

                //-NPR5.51 [357511]
                if not "Audit Roll Group VAT Totals".FindFirst then begin
                  "Audit Roll Group VAT Totals".DeleteAll;
                  varLineNo := 1;
                  QueryVATTotals.SetFilter(Sales_Ticket_No,'%1',"Audit Roll"."Sales Ticket No.");
                  QueryVATTotals.Open;
                  while QueryVATTotals.Read do begin
                    if QueryVATTotals.VAT <> 0 then begin
                      "Audit Roll Group VAT Totals".Init;
                      "Audit Roll Group VAT Totals".Template := 'REP6014410';
                      "Audit Roll Group VAT Totals"."Line No." := varLineNo;
                      "Audit Roll Group VAT Totals"."Code 1" := Format(QueryVATTotals.VAT);
                      "Audit Roll Group VAT Totals"."Decimal 1" := QueryVATTotals.Sum_Amount_Including_VAT - QueryVATTotals.Sum_Amount;
                      "Audit Roll Group VAT Totals"."Decimal 2" := QueryVATTotals.Sum_Amount;
                      "Audit Roll Group VAT Totals"."Decimal 3" := QueryVATTotals.Sum_Amount_Including_VAT;
                      "Audit Roll Group VAT Totals".Insert;
                      varTotalVat += (QueryVATTotals.Sum_Amount_Including_VAT - QueryVATTotals.Sum_Amount);
                      varLineNo +=1;
                    end;
                  end;
                end;
                //+NPR5.51 [357511]
            end;
        }
        dataitem("Integer";"Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
            column(Number_Integer;Integer.Number)
            {
            }
            column(LCYCode_GeneralLedgerSetup;StrSubstNo(Total,GeneralLedgerSetup."LCY Code"))
            {
            }
            column(AmountIncludingVAT_AuditRollTotals;AuditRollTotals."Amount Including VAT")
            {
            }
            column(TotalDiscount;TotalDiscount)
            {
            }
            column(SamletBonRabat_RetailSetup;RetailSetup.SamletBonRabat)
            {
            }
            column(ShowDiscountPercent_RetailSetup;RetailSetup."Show Discount Percent")
            {
            }
            column(TotalDiscountPct;TotalDiscountPct)
            {
            }
            column(LineDiscountAmount_AuditRollTotals;AuditRollTotals."Line Discount Amount")
            {
            }
            column(Amount_AuditRollTotals;AuditRollTotals.Amount)
            {
            }
            column(TotalVAT;TotalVAT)
            {
            }
            column(TotalVATAmount;AuditRollTotals."Amount Including VAT" - AuditRollTotals.Amount)
            {
            }
            column(EuroOnSalesTicket_RetailSetup;RetailSetup."Euro on Sales Ticket")
            {
            }
            column(TotalEuro;TotalEuro)
            {
            }
            column(TotalEuroAmount;TotalEuroAmount)
            {
            }
            column(SubCurrencyGL;SubCurrencyGL)
            {
            }
            column(Reference_AuditRoll;"Audit Roll".Reference)
            {
            }
            column(AmountIncludingVAT_AuditRollPayment;AuditRollPayment."Amount Including VAT")
            {
            }
            column(Balance_Customer;Customer.Balance)
            {
            }
            column(BalanceBefore_Customer;Customer.Balance - AuditRollPayment."Amount Including VAT")
            {
            }
            column(ShowAmountInclVatPayment;ShowAmountInclVatPayment)
            {
            }
            column(ShowAdditionalInfo;ShowAdditionalInfo)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if GeneralLedgerSetup.Get then;

                if (AuditRollTotals."Line Discount Amount" + AuditRollTotals."Amount Including VAT") <> 0 then
                  TotalDiscountPct := Format(Round((AuditRollTotals."Line Discount Amount" * 100) / (AuditRollTotals."Line Discount Amount" + AuditRollTotals."Amount Including VAT"),0.1) ) + ' %';

                if RetailSetup."Euro Exchange Rate" <> 0 then
                  TotalEuroAmount := AuditRollTotals."Amount Including VAT" / RetailSetup."Euro Exchange Rate";
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
        ContactNo_Lbl = 'Customer No. ';
        Telephone_Lbl = 'Telephone';
        Email_Lbl = 'E-mail';
        Website_Lbl = 'Website';
        VATNo_Lbl = 'VAT No.';
        SalesTicket_Lbl = 'Sales Ticket No.';
        SalesPerson_Lbl = 'Sales Person';
        SaleDate_Lbl = 'Sales Date';
        Description_Lbl = 'Description';
        No_Lbl = 'No.';
        Qty_Lbl = 'Quantity';
        UnitPrice_Lbl = 'Unit Price';
        Amount_Lbl = 'Amount';
        PriceInclDisc_Lbl = 'Price Incl. Discount';
        TextBalBefore = 'Balance before ';
        TextBalCurrent = 'Current balance';
        PaymentRounding_Lbl = 'Rounding';
        PaymentReference_Lbl = 'Reference';
        Payment_Lbl = 'Payment';
        Saldo_Lbl = 'Current balance';
        Page_Lbl = 'Page ';
        ReceiptCopy_Lbl = 'Receipt Copy no.';
        Payed_Lbl = 'Paid';
        BalanceBefore_Lbl = 'Balance before ';
        CurrentBalance_Lbl = 'Current balance';
        BTWPerc_Lbl = 'BTW %';
        BTWAmount_Lbl = 'BTW Amount';
        BTWExcl_Lbl = 'Excl.';
        BTWIncl_Lbl = 'Incl.';
        TotalBTW_Lbl = 'Total BTW';
        Discount_Lbl = 'Discount';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);
    end;

    var
        AuditRollTotals: Record "Audit Roll" temporary;
        CompanyInformation: Record "Company Information";
        Contact: Record Contact;
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Item: Record Item;
        POSUnit: Record "POS Unit";
        Register: Record Register;
        RetailSetup: Record "Retail Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSSetup: Codeunit "POS Setup";
        ContactNo: Text;
        ContactName: Text;
        ContactAddress: Text;
        ContactCity: Text;
        ContactPostCode: Text;
        Text0001: Label 'Staff Purchase';
        Text0002: Label 'Unit List Price : %1';
        Text0003: Label 'Vend. Item No.: %1';
        AmountLine: Decimal;
        DescriptionLine: Text;
        DescriptionLine2: Text;
        ItemInfo: Text;
        ItemInfo2: Text;
        ItemNo: Text;
        LineDiscountAmount: Text;
        LineDiscountPct: Decimal;
        LineDiscountPctNew: Text;
        QuantityAmountLine: Text;
        QuantityLine: Text;
        ShowOutPayment: Boolean;
        ShowDeposit: Boolean;
        UnitPriceInlcDiscountLine: Decimal;
        VariantCode: Text;
        FinansDescriptionLine: Text;
        DescriptionPaymentLine: Text;
        AmountPaymentLine: Decimal;
        ShowAmountInclVatPayment: Boolean;
        ShowAdditionalInfo: Boolean;
        VariantDesc: Text[50];
        FlagCreditVoucher: Boolean;
        FlagCustomerPayment: Boolean;
        FlagReturnSale: Boolean;
        FlagGiftVoucher: Boolean;
        FlagOutPayment: Boolean;
        FlagDepositPayment: Boolean;
        SubCurrencyGL: Decimal;
        Total: Label 'Total %1';
        TotalDiscount: Label 'Total Discount';
        TotalVAT: Label 'VAT Amount';
        TotalEuro: Label 'Total euro';
        SerialNoTxt: Label 'Serial No.';
        TotalDiscountPct: Text;
        TotalEuroAmount: Decimal;
        IsItem: Boolean;
        UnitPriceExclDiscountLine: Text;
        varTotalVat: Decimal;

    local procedure "--ContactInfo"()
    begin
    end;

    procedure PrintCustomerInfo()
    begin
        ContactNo := Customer."No.";
        ContactName := Customer.Name;
        ContactAddress := Customer.Address;
        ContactPostCode := Customer."Post Code";
        ContactCity := Customer.City;
    end;

    procedure PrintContactInfo()
    begin
        ContactNo := Customer."No.";
        ContactName := Contact.Name;
        ContactAddress := Contact.Address;
        ContactPostCode := Contact."Post Code";
        //-NPR5.29
        //ContactCity := Customer.City;
        ContactCity := Contact.City;
        //-NPR5.29
    end;

    procedure PrintStaffSaleInfo()
    begin
        if (Customer."Customer Price Group" = RetailSetup."Staff Price Group") or
           (Customer."Customer Disc. Group" = RetailSetup."Staff Disc. Group") then begin
          ContactNo := Text0001;
          ContactName := Customer.Name;
          ContactAddress := Customer."No.";
          ContactPostCode := '';
          ContactCity := '';
        end;
    end;

    procedure PrintLineVariantDesc(AuditRoll: Record "Audit Roll")
    var
        ItemVariant: Record "Item Variant";
    begin
        //-NPR5.23 [240916]
        // ColorDesc := '';
        // VariantDesc := '';
        // SizeDesc := '';
        //+NPR5.23 [240916]

        with AuditRoll do begin
          //Variety
          if ItemVariant.Get("No.", "Variant Code") and
             ((ItemVariant."Variety 1" <> '') or
              (ItemVariant."Variety 2" <> '') or
              (ItemVariant."Variety 3" <> '') or
              (ItemVariant."Variety 4" <> '')) then begin
            VariantDesc := ItemVariant.Description;
          end;
          //-NPR5.23 [240916]
        //   ELSE IF VarianceSetUp.GET("No.",Color,Size) THEN BEGIN
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
        //  END;
        //+NPR5.23 [240916]

        end;

        //-NPR5.23 [240916]
        // IF VariantDesc = '' THEN
        //  VariantDesc := ColorDesc + SizeDesc;
        //+NPR5.23 [240916]
    end;

    local procedure ResetVariables()
    begin
        AmountLine := 0;
        DescriptionLine := '';
        DescriptionLine2 := '';
        ItemInfo := '';
        ItemInfo2 := '';
        ItemNo := '';
        // -362537 [362537]
        LineDiscountPct := 0;
        LineDiscountPctNew := '';
        LineDiscountAmount := '';
        // +362537 [362537]
        QuantityAmountLine := '';
        QuantityLine := '';
        UnitPriceInlcDiscountLine := 0;
        VariantCode := '';
    end;

    procedure "--AuxFunctions--"()
    begin
    end;

    local procedure CalcSaleLineTotals(var AuditRoll: Record "Audit Roll")
    begin
        //-NPR5.51
        //AuditRollTotals."Amount Including VAT" += "Audit Roll"."Amount Including VAT";
        //AuditRollTotals.Amount += "Audit Roll".Amount;
        //AuditRollTotals."Line Discount Amount" += "Audit Roll"."Line Discount Amount";
        AuditRollTotals."Amount Including VAT" += AuditRoll."Amount Including VAT";
        AuditRollTotals.Amount += AuditRoll.Amount;
        AuditRollTotals."Line Discount Amount" += AuditRoll."Line Discount Amount";
        //+NPR5.51
    end;

    procedure AuditRollSalesOnAfterGetRecord(var AuditRollSales: Record "Audit Roll") DoNotSkip: Boolean
    begin
        with AuditRollSales do begin
          DoNotSkip := true;
          if (Type = Type::Item) and Item.Get("No.") and Item."No Print on Reciept" then
             exit(false);

          //IF ("Amount Including VAT" <> 0) AND (Type = Type::"G/L") AND ("No." = Register.Rounding) THEN BEGIN  //NPR5.53 [371955]-revoked
          if ("Amount Including VAT" <> 0) and (Type = Type::"G/L") and ("No." = POSSetup.RoundingAccount(true)) then begin  //NPR5.53 [371955]
            SubCurrencyGL := "Amount Including VAT";
            exit(false);
          end;

         //* If there is a returned item, display the return receipt *
          if Quantity < 0 then
            FlagReturnSale := true;

          //* If payout. use negative amount *
          if "Sale Type" = "Sale Type"::"Out payment" then begin
            "Unit Price"           *= -1;
            "Amount Including VAT" *= -1;
            Amount                 *= -1;
            FlagOutPayment         := true;
          end;

          //* If pay-in. Set the flag *
          if ("Sale Type" = "Sale Type"::Deposit) and (Type = Type::Customer) then begin
            FlagCustomerPayment := true;
            if "Sales Document Prepayment" then
              SetDepositPaymentFlag;
          end;
        end;

        CalcSaleLineTotals(AuditRollSales);
    end;

    local procedure "--FlagFunctions"()
    begin
    end;

    local procedure SetGiftCreditVoucherFlags()
    var
        GiftVoucher: Record "Gift Voucher";
        CreditVoucher: Record "Credit Voucher";
    begin
        with AuditRollFinance do
          if FindSet then repeat
            FlagGiftVoucher   := ("No." = Register."Gift Voucher Account")   and GiftVoucher.Get("Gift voucher ref.");
            FlagCreditVoucher := ("No." = Register."Credit Voucher Account") and CreditVoucher.Get("Credit voucher ref.");
          until (Next = 0) or (FlagGiftVoucher and FlagCreditVoucher);
    end;

    local procedure SetDepositPaymentFlag()
    var
        AuditRoll2: Record "Audit Roll";
    begin
        //-NPR4.14
        AuditRoll2.CopyFilters("Audit Roll");
        AuditRoll2.SetRange("Sale Type", AuditRoll2."Sale Type"::Deposit);
        AuditRoll2.SetRange(Type, AuditRoll2.Type::Customer);

        FlagDepositPayment := true;
        if AuditRoll2.FindSet then repeat
          //IF NOT AuditRoll2."Sales Document Prepayment" THEN
          if (AuditRoll2."Sales Document No." = '') then
            FlagDepositPayment := false;
        until (AuditRoll2.Next = 0) or (not FlagDepositPayment);
        //+NPR4.14
    end;
}

