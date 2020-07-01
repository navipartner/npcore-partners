report 6014563 "Receipt A5 - No Addr."
{
    // NPR4.16/KN/20151009 CASE 220371   Created report based on report from Klarlund
    // NPR4.16/KN/20151112 CASE 225533   Changed layout in report footer a tiny bit.
    // NPR4.18/KN/20151120 CASE 227187   Receipt text now taken from Register settings
    //                                   Calculations of total amount of Sales lines and total VAT amount changed.
    // NPR4.18/KN/20151210 CASE 227187   Added pager numbers to footer. Only shown if the total number of pages is more than 1.
    // NPR5.23/JDH /20160517 CASE 240916 Removed old VariaX Solution
    // NPR5.38/JLK /20180124  CASE 300892 Corrected AL Error on Blank Text Constants
    // NPR5.53/ALPO/20191024 CASE 371955 Rounding related fields moved to POS Posting Profiles
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Receipt A5 - No Addr..rdlc';

    Caption = 'Receipt A5';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Audit Roll"; "Audit Roll")
        {
            MaxIteration = 1;
            column(SalesTicketNoTxt_AuditRoll; StrSubstNo(Text000, "Sales Ticket No."))
            {
            }
            column(SalesPersonText; SalesPersonText)
            {
            }
            column(SaleDate_AuditRoll; StrSubstNo(Text002, "Sale Date"))
            {
            }
            column(AmountInclVat_AuditRoll; "Amount Including VAT")
            {
            }
            column(Reference_AuditRoll; Reference)
            {
            }
            column(GuideNo; GuideNo)
            {
            }
            column(ShowGuideNo; ShowGuideNo)
            {
            }
            column(Amount_AuditRoll; Amount)
            {
                IncludeCaption = true;
            }
            column(ReceiptInfoText; ReceiptInfoText)
            {
            }
            column(EuroExchangeRate_NPRetailConfig; NPRetailConfig."Euro Exchange Rate")
            {
            }
            column(EuroOnSalesTicket_NPRetailConfig; NPRetailConfig."Euro on Sales Ticket")
            {
            }
            column(BarcodeOnReceipt_NPRetailConfig; NPRetailConfig."Bar Code on Sales Ticket Print")
            {
            }
            column(ItemUnitOnExpeditions_NPRetailConfig; NPRetailConfig."Item Unit on Expeditions")
            {
            }
            column(Desc2OnReceipt_NPRetailConfig; NPRetailConfig."Description 2 on receipt")
            {
            }
            column(RecommendedPrice_NPRetailConfig; NPRetailConfig."Recommended Price")
            {
            }
            column(ShowVendorItemNo_NPRetailConfig; NPRetailConfig."Show vendoe Itemno.")
            {
            }
            column(Barcode; BlobBuffer."Buffer 1")
            {
            }
            dataitem(CommentLoop; "Integer")
            {
                column(RetailComments; TempRetailComment.Comment)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    //-NPR4.18
                    if Number = 1 then
                        TempRetailComment.FindFirst
                    else
                        TempRetailComment.Next;
                    //-NPR4.18
                end;

                trigger OnPreDataItem()
                begin
                    //-NPR4.18
                    SetRange(Number, 1, TempRetailComment.Count());
                    //-NPR4.18
                end;
            }
            dataitem("Gift/credit voucher"; "Audit Roll")
            {
                DataItemLink = "Register No." = FIELD("Register No."), "Sales Ticket No." = FIELD("Sales Ticket No.");
                DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date") ORDER(Ascending) WHERE("Sale Type" = FILTER(Deposit), Type = FILTER("G/L"));
                dataitem("G/L Account"; Register)
                {
                    DataItemLink = "Register No." = FIELD("Register No.");
                    DataItemTableView = SORTING("Register No.") ORDER(Ascending);
                }
                dataitem("Gift Voucher Type"; "Payment Type POS")
                {
                    DataItemLink = "G/L Account No." = FIELD("No.");
                    DataItemTableView = SORTING("Processing Type") ORDER(Ascending) WHERE("Processing Type" = CONST("Gift Voucher"));
                    dataitem("Gift Voucher"; "Gift Voucher")
                    {
                        DataItemLink = "Sales Ticket No." = FIELD("Sales Ticket No."), "No." = FIELD("Gift voucher ref.");
                        DataItemLinkReference = "Gift/credit voucher";
                        DataItemTableView = SORTING("Sales Ticket No.") ORDER(Ascending);

                        trigger OnAfterGetRecord()
                        begin
                            flgGavekort := true;
                        end;
                    }
                }
                dataitem("Credit Voucher Type"; "Payment Type POS")
                {
                    DataItemLink = "G/L Account No." = FIELD("No.");
                    DataItemTableView = SORTING("Processing Type") ORDER(Ascending) WHERE("Processing Type" = CONST("Credit Voucher"));
                    dataitem("Credit Voucher"; "Credit Voucher")
                    {
                        DataItemLink = "Sales Ticket No." = FIELD("Sales Ticket No."), "No." = FIELD("Credit voucher ref.");
                        DataItemLinkReference = "Gift/credit voucher";
                        DataItemTableView = SORTING("Sales Ticket No.");

                        trigger OnAfterGetRecord()
                        begin
                            flgTilgodebevis := true;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    flgIndbetal := true;
                end;
            }
            dataitem(Pageloop; "Integer")
            {
                DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
                dataitem(Register; Register)
                {
                    DataItemLink = "Register No." = FIELD("Register No.");
                    DataItemLinkReference = "Audit Roll";
                    DataItemTableView = SORTING("Register No.") ORDER(Ascending);

                    trigger OnAfterGetRecord()
                    var
                        PrintersRegisterCode: Code[10];
                    begin
                        PrintersRegisterCode := "Retail Form Code".FetchRegisterNumber();
                        if not PrintersRegister.Get(PrintersRegisterCode) then
                            PrintersRegister.Get(Register."Register No.");
                    end;
                }
                dataitem(Customer; Customer)
                {
                    CalcFields = "Balance (LCY)";
                    DataItemLink = "No." = FIELD("Customer No.");
                    DataItemLinkReference = "Audit Roll";
                    DataItemTableView = SORTING("No.") ORDER(Ascending);

                    trigger OnAfterGetRecord()
                    begin
                        flgDebitorFound := true;

                        if PrintCommAddress then begin
                            i := 0;
                            for i := 1 to ArrayLen(NameAndAddress) do
                                CustInf[i] := NameAndAddress[i];
                        end else begin
                            CustInf[1] := "No.";
                            CustInf[2] := Name;
                            CustInf[3] := Address;
                            CustInf[4] := StrSubstNo(Text003, "Post Code", City);
                        end;
                    end;
                }
                dataitem(Contact; Contact)
                {
                    DataItemLink = "No." = FIELD("Customer No.");
                    DataItemLinkReference = "Audit Roll";
                    DataItemTableView = SORTING("No.") ORDER(Ascending);
                }
                dataitem("Staff sale"; "Audit Roll")
                {
                    DataItemLink = "Register No." = FIELD("Register No."), "Sales Ticket No." = FIELD("Sales Ticket No."), "Line No." = FIELD("Line No.");
                    DataItemLinkReference = "Audit Roll";
                    DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date") ORDER(Ascending) WHERE("Customer Type" = FILTER("Ord."));
                    dataitem(Staff; Customer)
                    {
                        DataItemLink = "No." = FIELD("Customer No.");
                        DataItemTableView = SORTING("No.") ORDER(Ascending);
                    }
                }
                dataitem("Audit Roll Sale"; "Audit Roll")
                {
                    DataItemLink = "Register No." = FIELD("Register No."), "Sales Ticket No." = FIELD("Sales Ticket No.");
                    DataItemLinkReference = "Audit Roll";
                    DataItemTableView = SORTING("Sales Ticket No.", "Line No.") ORDER(Ascending) WHERE("Sale Type" = FILTER(Sale | "Out payment" | Deposit | Comment | "Debit Sale"));
                    column(LoopValue; LoopValue)
                    {
                    }
                    column(TypeAuditRolSale; TypeAuditRolSale)
                    {
                    }
                    column(SaleTypeAuditRolSale; SaleTypeAuditRolSale)
                    {
                    }
                    column(Description_AuditRollSale; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(SalesTicketNo_AuditrollSale; "Sales Ticket No.")
                    {
                    }
                    column(Description2_AuditRollSale; "Description 2")
                    {
                    }
                    column(No_AuditRollSale; "No.")
                    {
                    }
                    column(Quantity_AuditRollSale; Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(Type_AuditRollSale; Type)
                    {
                    }
                    column(SaleType_AuditRollSale; "Sale Type")
                    {
                    }
                    column(LineDiscAmount_AuditRollSale; "Line Discount Amount")
                    {
                    }
                    column(AmountInclVAT_AuditRollSale; "Amount Including VAT")
                    {
                    }
                    column(Amount_AuditRollSale; Amount)
                    {
                    }
                    column(Unit_AuditRollSale; "Unit of Measure Code")
                    {
                    }
                    column(SerialNo_AudtiRollSale; "Serial No.")
                    {
                    }
                    column(TotalVatAmount; TotalVatAmount)
                    {
                    }
                    column(TotalAmountInclVat; TotalAmountInclVat)
                    {
                    }
                    dataitem("Audit Roll Payment"; "Audit Roll")
                    {
                        DataItemLink = "Register No." = FIELD("Register No."), "Sales Ticket No." = FIELD("Sales Ticket No.");
                        DataItemLinkReference = "Audit Roll";
                        DataItemTableView = SORTING("Sales Ticket No.", "Line No.") ORDER(Ascending) WHERE("Sale Type" = FILTER(Payment));
                        column(LineNo_AuditRollPayment; "Line No.")
                        {
                        }
                        column(AmountInclVAT_AuditRollPayment; "Amount Including VAT")
                        {
                        }
                        column(Amount_AuditRollPayment; Amount)
                        {
                        }
                        column(Description_AuditRollPayment; Description)
                        {
                        }
                        column(CreditVoucherRef_AuditRollPayment; "Credit voucher ref.")
                        {
                        }
                    }
                    dataitem(Item; Item)
                    {
                        DataItemLink = "No." = FIELD("No.");
                        column(No_Item; Item."No.")
                        {
                        }
                        column(UnitListPrice_Item; "Unit List Price")
                        {
                        }
                        column(VendorItemNo_Item; "Vendor Item No.")
                        {
                        }
                    }
                    dataitem("Audit Roll Sale Details"; "Audit Roll")
                    {
                        DataItemLink = "Register No." = FIELD("Register No."), "Sales Ticket No." = FIELD("Sales Ticket No."), "Sale Type" = FIELD("Sale Type"), "Line No." = FIELD("Line No.");
                        DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date");
                        column(flgGavekort; flgGavekort)
                        {
                        }
                        column(SalesTicketNo_AuditRollSaleDetails; "Sales Ticket No.")
                        {
                        }
                        column(LineNo_AuditrollSaleDetails; "Line No.")
                        {
                        }
                        column(LineDiscountAmount_AuditRollSaleDetails; "Line Discount Amount")
                        {
                        }
                        column(UnitPriceOnSales_NPRetailConfig; NPRetailConfig."Unit Price on Sales Ticket")
                        {
                        }
                        column(AmountInclVAT_AuditRollSaleDetails; "Amount Including VAT")
                        {
                        }
                        column(Quantity_AuditRollSaleDetails; Quantity)
                        {
                        }
                        column(ShowDiscountPct_NPRetailConfig; NPRetailConfig."Show Discount Percent")
                        {
                        }
                        column(ShowVariantCode_NPRetailConfig; NPRetailConfig."Receipt - Show Variant code")
                        {
                        }
                        column(UnitPrice_AuditRollSalesDetails; "Unit Price")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if NPRetailConfig."Unit Price on Sales Ticket" and (Quantity <> 0) then
                                QuantityAmountTxt := Format(Quantity) + ' * ' +
                                Format(("Amount Including VAT" + "Line Discount Amount") / Quantity, 0, '<Precision,2:2><Standard Format,0>')
                            else
                                QuantityAmountTxt := Format(Quantity);
                            //-NPR5.23 [240916]
                            // IF "Variance Set Up".GET("No.",Color,Size) THEN BEGIN
                            // IF ("Variance Set Up"."Description - Color"<>Text10600008) THEN BEGIN
                            //   ColorTxt:=Text10600009+FORMAT("Variance Set Up"."Description - Color")+' ';
                            // END;
                            // IF ("Variance Set Up"."Description - Size"<>'') THEN
                            //   SizeTxt:=Text10600010+FORMAT("Variance Set Up"."Description - Size");
                            // END ELSE IF "VariaX Configuration".GET() THEN BEGIN
                            //  IF "VariaX Dim. Combination".GET("Variant Code","No.","VariaX Configuration"."Color Dimension") THEN BEGIN
                            //    "VariaX Dim. Combination".CALCFIELDS(Description);
                            //    IF "VariaX Dim. Combination".Description <> '' THEN
                            //      ColorTxt := Text10600009+FORMAT("VariaX Dim. Combination".Description)+' ';
                            //  END;
                            //  IF "VariaX Dim. Combination".GET("Variant Code","No.","VariaX Configuration"."Size Dimension") THEN BEGIN
                            //    "VariaX Dim. Combination".CALCFIELDS(Description);
                            //    IF "VariaX Dim. Combination".Description <> '' THEN
                            //      SizeTxt := Text10600010+FORMAT("VariaX Dim. Combination".Description);
                            //  END;
                            // END;
                            //
                            // ColorSizeTxt:=ColorTxt+SizeTxt;
                            //+NPR5.23 [240916]
                        end;
                    }
                    dataitem("Customer Details"; Customer)
                    {
                        DataItemLink = "No." = FIELD("No.");
                        DataItemLinkReference = Customer;
                        DataItemTableView = SORTING("No.");
                        column(No_CustomerDetails; "Customer Details"."No.")
                        {
                        }
                        column(Addr_CustomerDetails; Address)
                        {
                        }
                        column(PostCodeCity_CustomerDetails; "Post Code" + ' ' + City)
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if (Type = Type::Item) and Item.Get("No.") and Item."No Print on Reciept" then
                            CurrReport.Skip;

                        //IF ("Amount Including VAT" <> 0) AND (Type = Type::"G/L") AND ("No." = Register.Rounding) THEN BEGIN  //NPR5.53 [371955]-revoked
                        if ("Amount Including VAT" <> 0) and (Type = Type::"G/L") and ("No." = POSSetup.RoundingAccount(true)) then begin  //NPR5.53 [371955]
                            SubCurrencyGL := "Amount Including VAT";
                            CurrReport.Skip;
                        end;

                        /** If there is a returned item, display the return receipt **/
                        if Quantity < 0 then
                            flgRetursalg := true;

                        /** If payout. use negative amount **/
                        if "Sale Type" = "Sale Type"::"Out payment" then begin
                            "Unit Price" *= -1;
                            "Amount Including VAT" *= -1;
                            Amount *= -1;
                            flgUdbetal := true;
                        end;

                        /** Calculate remaining amount in case of prepayment **/
                        OutStandingAmount := 0;

                        /*IF "Buffer Invoice No." <> '' THEN BEGIN
                          CustLedgerEntry.SETRANGE("Document No.", "Buffer Invoice No.");
                          CustLedgerEntry.SETRANGE(Prepayment, TRUE);
                          IF CustLedgerEntry.FINDFIRST THEN BEGIN
                            IF SalesHeader.GET(SalesHeader."Document Type"::Order,CustLedgerEntry."Prepayment Order No.") THEN BEGIN
                              SalesOrderCalculations.SetSalesHeader(SalesHeader);
                              OutStandingAmount := SalesOrderCalculations.GetRemaingAmount;
                              RemainText := STRSUBSTNO(TextOutstanding,SalesHeader."No.", FORMAT(OutStandingAmount,0,'<Integer><Decimals,2>'));
                            END;
                          END;
                        END;*/

                        /** If pay-in. Set the flag **/
                        if ("Sale Type" = "Sale Type"::Deposit) and (Type = Type::Customer) then
                            flgIndbetal := true;

                        QuantityAmountTxt := Format(Quantity) + ' * ' + Format("Unit Price", 0, '<Precision,2:2><Standard Format,0>');

                        /*Section boolians - NAV2013*/
                        if Type = Type::"G/L" then
                            TypeAuditRolSale := true;
                        if "Sale Type" = "Sale Type"::Deposit then
                            SaleTypeAuditRolSale := true;


                        LoopValue += 1;

                        TotalAmountInclVat += "Amount Including VAT";
                        //NPR4.18
                        //TotalVatAmount += "Amount Including VAT" - AmounT;
                        if "VAT %" <> 0 then
                            TotalVatAmount += Amount * "VAT %" / 100;
                        //NPR4.18

                    end;

                    trigger OnPostDataItem()
                    begin
                        /** If the amount if positive, dont display the return receipt **/
                        /** But only if the customer wants it. Sag 57937**/
                        if not NPRetailConfig."Return Receipt Positive Amount" then
                            if "Amount Including VAT" > 0 then
                                flgRetursalg := false;

                        /** If FlgUdbetal was incorrectly set, remove it **/
                        if "Amount Including VAT" > 0 then
                            flgUdbetal := false;

                        /** Sale Total Discount percent **/
                        if "Line Discount Amount" + "Amount Including VAT" <> 0 then
                            DiscountPctTxt := Format(Round(("Line Discount Amount" * 100) / ("Line Discount Amount" + "Amount Including VAT"), 0.1)) + ' %';

                    end;

                    trigger OnPreDataItem()
                    begin
                        LoopValue := 0;
                    end;
                }
                dataitem("Audit Roll Finance"; "Audit Roll")
                {
                    DataItemLink = "Register No." = FIELD("Register No."), "Sales Ticket No." = FIELD("Sales Ticket No.");
                    DataItemLinkReference = "Audit Roll";
                    DataItemTableView = SORTING("Register No.", "Sales Ticket No.", "Sale Type", "Line No.", "No.", "Sale Date") ORDER(Ascending) WHERE("Sale Type" = CONST(Deposit), Type = CONST("G/L"));
                    dataitem("Foreign Currency"; "Payment Type POS")
                    {
                        DataItemLink = "No." = FIELD("No.");
                        DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending) WHERE("Processing Type" = CONST("Foreign Currency"));
                    }
                    dataitem("Credit card"; "Payment Type POS")
                    {
                        DataItemLink = "No." = FIELD("No.");
                        DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending) WHERE("Processing Type" = FILTER("Terminal Card" | EFT));
                    }
                    dataitem(Other; "Payment Type POS")
                    {
                        DataItemLink = "No." = FIELD("No.");
                        DataItemTableView = SORTING("No.", "Register No.") ORDER(Ascending) WHERE("Processing Type" = FILTER(<> "Foreign Currency" & <> "Terminal Card" & <> EFT));
                    }

                    trigger OnAfterGetRecord()
                    var
                        Text10600026: Label 'Payment';
                        Text10600027: Label 'on account';
                    begin
                        if ("Sale Type" = "Sale Type"::Deposit) then begin
                            flgIndbetal := true;

                            if flgDebitorFound then begin
                                IndbetalTXT := Text10600026;
                                IndbetalTXT2 := Text10600027 + ' ' + Format("No.");
                                IndbetalTXT3 := Format("Buffer Document Type") + ' ' + "Buffer ID";
                            end

                            else begin
                                IndbetalTXT := 'Indbetaling:';
                                if flgTilgodebevis then begin
                                    IndbetalTXT := '';
                                    IndbetalTXT3 := 'Udstedt:';
                                end;
                                if flgGavekort = true then
                                    IndbetalTXT := '';
                            end;
                        end;

                        /** Hack to display proper VAT when using credit vouchers
                           with negitive amounts **/
                        if flgTilgodebevis then
                            VAT := -0.25 * ("Amount Including VAT" - Amount); //0.25 = temporary hack

                    end;
                }

                trigger OnAfterGetRecord()
                var
                    AuditTemp: Record "Audit Roll";
                    PaymentTypePos: Record "Payment Type POS";
                    ShowPageTwo: Boolean;
                begin
                    /** Dont open drawer when paying with special. if chosen **/
                    flgOpenDrawer := true;

                    /** If "open on special" is set, always open the drawer **/
                    if not Register."Money drawer - open on special" then begin
                        flgOpenDrawer := false;
                        if "Audit Roll"."Copy No." < 1 then begin
                            AuditTemp.SetRange("Sales Ticket No.", "Audit Roll"."Sales Ticket No.");
                            AuditTemp.SetRange(Description);
                            AuditTemp.SetRange("Sale Type");
                            PaymentTypePos.SetFilter("Processing Type", '%1|%2',
                                                     PaymentTypePos."Processing Type"::Cash,
                                                     PaymentTypePos."Processing Type"::"Foreign Currency");
                            if PaymentTypePos.FindSet then
                                repeat
                                    AuditTemp.SetRange("No.", PaymentTypePos."No.");
                                    if AuditTemp.Count > 0 then
                                        flgOpenDrawer := true;
                                until (PaymentTypePos.Next = 0) or flgOpenDrawer;
                        end;
                    end;

                    if Pageloop.Number = 2 then begin
                        ShowPageTwo := flgRetursalg;
                        if flgTilgodebevis then
                            ShowPageTwo := false
                        else
                            if (flgIndbetal and not (flgGavekort and not NPRetailConfig."Copy Sales Ticket on Giftvo.")) or flgUdbetal then
                                ShowPageTwo := true;

                        if not ShowPageTwo then
                            CurrReport.Break;
                    end;

                end;
            }

            trigger OnAfterGetRecord()
            var
                Text10600012: Label '%2 - Bon %1/%4 - %3';
                "Salesperson/Purchaser": Record "Salesperson/Purchaser";
                Utility: Codeunit Utility;
            begin
                ReceiptInfoText := StrSubstNo(Text10600012, "Audit Roll"."Sales Ticket No.",
                  Format("Audit Roll"."Sale Date"), Format("Audit Roll"."Closing Time"), "Register No.");

                if NPRetailConfig."Salesperson on Sales Ticket" and
                 "Salesperson/Purchaser".Get("Salesperson Code") then begin
                    SalesPersonText := StrSubstNo(Text001, "Salesperson/Purchaser".Name);
                end else
                    SalesPersonText := StrSubstNo(Text001, "Salesperson Code");

                BarcodeLib.GenerateBarcode("Sales Ticket No.", TempBlob);
                BlobBuffer.GetFromTempBlob(TempBlob, 1);

                //-NPR4.18
                Register.Get("Register No.");
                Utility.GetTicketText(TempRetailComment, Register);
                //-NPR4.18
                //-NPR5.53 [371955]
                POSUnit.Get("Register No.");
                POSSetup.SetPOSUnit(POSUnit);
                //+NPR5.53 [371955]
            end;

            trigger OnPreDataItem()
            begin
                flgRetursalg := false;
                flgGavekort := false;
                flgIndbetal := false;
                flgTilgodebevis := false;
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
        PriceWDiscLbl = 'Unit Price incl. disc.';
        SerialNoLbl = 'Serial No.';
        DisciountLbl = 'Discount';
        UnitPriceLbl = 'Unit Price';
        TotalLbl = 'Total (LCY)';
        VatLbl = 'VAT thereof';
        SettlementLbl = 'Settlement';
        // The label 'TotalEuroLbl' could not be exported.
    }

    trigger OnPreReport()
    begin
        NPRetailConfig.Get();
    end;

    var
        NPRetailConfig: Record "Retail Setup";
        PrintersRegister: Record Register;
        POSUnit: Record "POS Unit";
        "Retail Form Code": Codeunit "Retail Form Code";
        POSSetup: Codeunit "POS Setup";
        SubCurrencyGL: Decimal;
        VAT: Decimal;
        OutStandingAmount: Decimal;
        QuantityAmountTxt: Text[50];
        IndbetalTXT: Text[200];
        IndbetalTXT2: Text[50];
        IndbetalTXT3: Text[50];
        SalesPersonText: Text[50];
        DiscountPctTxt: Text[50];
        flgTilgodebevis: Boolean;
        flgIndbetal: Boolean;
        flgRetursalg: Boolean;
        flgGavekort: Boolean;
        flgDebitorFound: Boolean;
        flgUdbetal: Boolean;
        flgOpenDrawer: Boolean;
        Text000: Label 'Sales Ticket No.: %1';
        TypeAuditRolSale: Boolean;
        SaleTypeAuditRolSale: Boolean;
        Text001: Label 'Eksp.  %1';
        Text002: Label 'Eksp.  %1';
        LoopValue: Integer;
        GuideNo: Code[20];
        NameAndAddress: array[5] of Text[50];
        PrintCommAddress: Boolean;
        CustInf: array[8] of Text[50];
        i: Integer;
        Text003: Label '%1, %2';
        ShowGuideNo: Boolean;
        TotalAmountInclVat: Decimal;
        TotalVatAmount: Decimal;
        ReceiptInfoText: Text;
        BarcodeLib: Codeunit "Barcode Library";
        TempBlob: Codeunit "Temp Blob";
        TempRetailComment: Record "Retail Comment" temporary;
        BlobBuffer: Record "BLOB Buffer" temporary;
}

