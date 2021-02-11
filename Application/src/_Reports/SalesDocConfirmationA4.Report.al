report 6014440 "NPR Sales Doc Confirmation A4"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Doc Confirmation A4.rdlc'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    Caption = 'Sales Doc Confirmation A4';
    PreviewMode = PrintLayout;
    dataset
    {
        dataitem("Audit Roll"; "NPR Audit Roll")
        {
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            column(RegisterNo_AuditRoll; "Audit Roll"."Register No.")
            {
            }
            column(SalesTicketNo_AuditRoll; "Audit Roll"."Sales Ticket No.")
            {
            }
            column(SaleDate_AuditRoll; AuditRollSale."Sale Date")
            {
            }
            column(CopyNo_AuditRoll; "Audit Roll"."Copy No.")
            {
            }
            column(Name_SalespersonPurchaser; SalespersonPurchaser.Name)
            {
            }
            column(RegisterNo_Register; Register."Register No.")
            {
            }
            column(Name_Register; POSStore.Name)
            {
            }
            column(Addres_Register; POSStore.Address)
            {
            }
            column(City_Register; POSStore.City)
            {
            }
            column(PostCode_Register; POSStore."Post Code")
            {
            }
            column(Telephone_Register; POSStore."Phone No.")
            {
            }
            column(Email_Register; POSStore."E-mail")
            {
            }
            column(Website_Register; POSStore."Home Page")
            {
            }
            column(VATRegNo; CompanyInformation."VAT Registration No.")
            {
            }
            column(BankAccNo; CompanyInformation."Bank Account No.")
            {
            }
            column(IBANNo; CompanyInformation.IBAN)
            {
            }
            column(ContactNo; ContactNo)
            {
            }
            column(ContactName; ContactName)
            {
            }
            column(ContactAddress; ContactAddress)
            {
            }
            column(ContactCity; ContactCity)
            {
            }
            column(ContactPostCode; ContactPostCode)
            {
            }
            dataitem(AuditRollSale; "NPR Audit Roll")
            {
                DataItemLink = "Register No." = FIELD("Register No."), "Sales Ticket No." = FIELD("Sales Ticket No.");
                DataItemTableView = SORTING("Sales Ticket No.", "Line No.") WHERE("Sale Type" = FILTER("Debit Sale"));
                column(LineNo_AuditRollSale; "Line No.")
                {
                }
                column(Type_AuditRollSale; Type)
                {
                }
                column(AmountLine; AmountLine)
                {
                }
                column(DescriptionLine; DescriptionLine)
                {
                }
                column(DescriptionLine2; DescriptionLine2)
                {
                }
                column(ItemInfo; ItemInfo)
                {
                }
                column(ItemNo; ItemNo)
                {
                }
                column(UnitOfMeasure; UnitOfMeasure)
                {
                }
                column(VariantCode; VariantCode)
                {
                }
                column(LineDiscountPct; LineDiscountPct)
                {
                }
                column(LineDiscountPctLine; LineDiscountPctLine)
                {
                }
                column(QuantityLine; QuantityLine)
                {
                }
                column(SerialNo_AuditrollSale; "Serial No.")
                {
                }
                column(SerialNoNotCreate_AuditRollSale; "Serial No. not Created")
                {
                }
                column(SeriealNoTxt; SerialNoTxt)
                {
                }
                column(VariantDesc; VariantDesc)
                {
                }
                column(UnitPriceExclDiscountLine; UnitPriceExclDiscountLine)
                {
                }
                column(UnitPriceInclDiscountLine; UnitPriceInclDiscountLine)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ResetVariables;
                    AuditRollSalesOnAfterGetRecord(AuditRollSale);
                    DescriptionLine := Description;

                    if (Type = Type::Item) then begin
                        ItemNo := "No.";
                        UnitOfMeasure := "Unit of Measure Code";
                        DescriptionLine2 := "Description 2";
                        VariantCode := "Variant Code";
                        LineDiscountPct := "Line Discount %";
                        LineDiscountPctLine := Format(LineDiscountPct);
                        AuditRollTotals."VAT %" := "VAT %";

                        if (Quantity <> 0) then begin
                            UnitPriceExclDiscountLine := Format(("Amount Including VAT" + "Line Discount Amount") / Quantity);
                            UnitPriceInclDiscountLine := Format("Amount Including VAT" / Quantity);
                            QuantityLine := Format(Quantity);
                        end;

                        AmountLine := "Amount Including VAT";
                    end;

                    PrintLineVariantDesc(AuditRollSale);
                end;
            }

            trigger OnAfterGetRecord()
            var
                POSUnit: Record "NPR POS Unit";
                POSFrontEnd: Codeunit "NPR POS Front End Management";
                POSSession: Codeunit "NPR POS Session";
                POSSetup: Codeunit "NPR POS Setup";
                QueryVATTotals: Query "NPR VAT Totals";
                varLineNo: Integer;
            begin
                Register.Get("Audit Roll"."Register No.");
                clear(POSStore);
                if POSSession.IsActiveSession(POSFrontEnd) then begin
                    POSFrontEnd.GetSession(POSSession);
                    POSSession.GetSetup(POSSetup);
                    POSSetup.GetPOSStore(POSStore);
                end else begin
                    if POSUnit.get(Register."Register No.") then
                        POSStore.get(POSUnit."POS Store Code");
                end;
                RetailSetup.Get();
                if SalespersonPurchaser.Get("Audit Roll"."Salesperson Code") then;
                Clear(AuditRollTotals);
                AuditRollTotals."Amount Including VAT" := 0;
                AuditRollTotals.Amount := 0;
                AuditRollTotals."Line Discount Amount" := 0;

                if Customer.Get("Customer No.") and ("Customer Type" = "Customer Type"::"Ord.") then
                    PrintCustomerInfo()
                else
                    if Contact.Get("Customer No.") and ("Customer Type" = "Customer Type"::Cash) then
                        PrintContactInfo()
                    else
                        if Customer.Get("Customer No.") and ("Customer Type" = "Customer Type"::"Ord.") then
                            PrintStaffSaleInfo();
            end;
        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(Number_Integer; Integer.Number)
            {
            }
            column(LCYCode_GeneralLedgerSetup; StrSubstNo(Total, GeneralLedgerSetup."LCY Code"))
            {
            }
            column(TotalAmountInclVAT; AuditRollTotals."Amount Including VAT")
            {
            }
            column(TotalDiscountPct; TotalDiscountPct)
            {
            }
            column(TotalLineDiscount; AuditRollTotals."Line Discount Amount")
            {
            }
            column(TotalAmountExclVAT; AuditRollTotals.Amount)
            {
            }
            column(TotalVATAmount; AuditRollTotals."Amount Including VAT" - AuditRollTotals.Amount)
            {
            }
            column(Reference_AuditRoll; "Audit Roll".Reference)
            {
            }
            column(ShowAmountInclVatPayment; ShowAmountInclVatPayment)
            {
            }
            column(ShowAdditionalInfo; ShowAdditionalInfo)
            {
            }
            column(VATPct; Format(AuditRollTotals."VAT %") + ' %')
            {
            }

            trigger OnAfterGetRecord()
            begin
                if GeneralLedgerSetup.Get then;

                if (AuditRollTotals."Line Discount Amount") <> 0 then
                    TotalDiscountPct := Format(Round((AuditRollTotals."Line Discount Amount" * 100) / (AuditRollTotals."Line Discount Amount" + AuditRollTotals."Amount Including VAT"), 0.1)) + ' %';
            end;
        }
    }

    labels
    {
        ContactNo_Lbl = 'Customer No. ';
        Telephone_Lbl = 'Telephone';
        Email_Lbl = 'E-mail';
        Website_Lbl = 'Website';
        VATNo_Lbl = 'VAT No.';
        BankAcc_Lbl = 'Bank Account No.';
        IBANNo_Lbl = 'IBAN No.';
        SalesTicket_Lbl = 'Sales Ticket No.';
        SalesPerson_Lbl = 'Sales Person';
        SaleDate_Lbl = 'Sales Date';
        Description_Lbl = 'Description';
        No_Lbl = 'No.';
        VariantCode_Lbl = 'Variant Code';
        UnitOfMeasure_Lbl = 'Unit of measure';
        Qty_Lbl = 'Quantity';
        Discount_Lbl = 'Discount %';
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
        TotalInclVAT_Lbl = 'Total Incl. VAT';
        TotalExclVAT_Lbl = 'Total Excl. VAT';
        TotalDiscount_Lbl = 'Total Discount';
        TotalVATPct_Lbl = 'Total VAT';
    }

    trigger OnInitReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
    end;

    var
        CompanyInformation: Record "Company Information";
        Contact: Record Contact;
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Item: Record Item;
        AuditRollTotals: Record "NPR Audit Roll" temporary;
        POSStore: Record "NPR POS Store";
        Register: Record "NPR Register";
        RetailSetup: Record "NPR Retail Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        FlagReturnSale: Boolean;
        IsItem: Boolean;
        ShowAdditionalInfo: Boolean;
        ShowAmountInclVatPayment: Boolean;
        ShowDeposit: Boolean;
        ShowOutPayment: Boolean;
        UnitOfMeasure: Code[10];
        AmountLine: Decimal;
        AmountPaymentLine: Decimal;
        LineDiscountPct: Decimal;
        SubCurrencyGL: Decimal;
        SerialNoTxt: Label 'Serial No.';
        Text0001: Label 'Staff Purchase';
        Total: Label 'Total %1';
        TotalDiscount: Label 'Total Discount';
        TotalEuro: Label 'Total euro';
        Text0002: Label 'Unit List Price : %1';
        TotalVAT: Label 'VAT Amount';
        Text0003: Label 'Vend. Item No.: %1';
        ContactAddress: Text;
        ContactCity: Text;
        ContactName: Text;
        ContactNo: Text;
        ContactPostCode: Text;
        DescriptionLine: Text;
        DescriptionLine2: Text;
        DescriptionPaymentLine: Text;
        FinansDescriptionLine: Text;
        ItemInfo: Text;
        ItemInfo2: Text;
        ItemNo: Text;
        LineDiscountPctLine: Text;
        QuantityLine: Text;
        TotalDiscountPct: Text;
        UnitPriceExclDiscountLine: Text;
        UnitPriceInclDiscountLine: Text;
        VariantCode: Text;
        VariantDesc: Text[100];

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
        ContactCity := Contact.City;
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

    procedure PrintLineVariantDesc(AuditRoll: Record "NPR Audit Roll")
    var
        ItemVariant: Record "Item Variant";
    begin
        //Variety
        if ItemVariant.Get(AuditRoll."No.", AuditRoll."Variant Code") and
           ((ItemVariant."NPR Variety 1" <> '') or
            (ItemVariant."NPR Variety 2" <> '') or
            (ItemVariant."NPR Variety 3" <> '') or
            (ItemVariant."NPR Variety 4" <> '')) then begin
            VariantDesc := ItemVariant.Description;
        end;
    end;

    local procedure ResetVariables()
    begin
        AmountLine := 0;
        DescriptionLine := '';
        DescriptionLine2 := '';
        ItemNo := '';
        LineDiscountPct := 0;
        UnitPriceInclDiscountLine := '0';
        VariantCode := '';
    end;

    local procedure CalcSaleLineTotals(var AuditRoll: Record "NPR Audit Roll")
    begin
        AuditRollTotals."Amount Including VAT" += AuditRoll."Amount Including VAT";
        AuditRollTotals.Amount += AuditRoll.Amount;
        AuditRollTotals."Line Discount Amount" += AuditRoll."Line Discount Amount";
    end;

    procedure AuditRollSalesOnAfterGetRecord(var AuditRollSales: Record "NPR Audit Roll") DoNotSkip: Boolean
    begin
        if (AuditRollSales.Type = AuditRollSales.Type::Item) and Item.Get(AuditRollSales."No.") and Item."NPR No Print on Reciept" then
            exit(false);

        //* If there is a returned item, display the return receipt *
        if AuditRollSales.Quantity < 0 then
            FlagReturnSale := true;

        CalcSaleLineTotals(AuditRollSales);
    end;
}

