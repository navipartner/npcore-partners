report 6150613 "NPR Sales Ticket A4 - POS Rdlc"
{
#if not BC17
    Extensible = true;
#ENDIF
    RDLCLayout = './src/_Reports/layouts/Sales Ticket A4 - POS.rdlc';
    WordLayout = './src/_Reports/layouts/Sales Ticket A4 - POS Word.docx';
    Caption = 'Sales Ticket A4 - POS';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DefaultLayout = Word;
    PreviewMode = PrintLayout;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem("NPR POS Entry"; "NPR POS Entry")
        {
            DataItemTableView = sorting("Entry No.");
            RequestFilterFields = "Entry No.";

            column(EntryNo_POS_Entry; "Entry No.")
            {
            }
            column(Entry_Date_POS_Entry; Format("Entry Date", 0, 0))
            {
            }
            column(Document_No_POS_Entry; "Document No.")
            {
                IncludeCaption = true;
            }
            column(DocumentDate_No_POS_Entry; "Document Date")
            {
            }
            column(DiscountAmount_POS_Entry; "Discount Amount")
            {
            }
            column(TotalAmount_POS_Entry; "Amount Excl. Tax")
            {
            }
            column(TotalTaxAmount_POS_Entry; "Tax Amount")
            {
            }
            column(TotalAmountInclTax_POS_Entry; "Amount Incl. Tax")
            {
            }
            column(StoreAddress_POS_Entry; StoreAddress)
            {
            }
            column(CustomerAddress_POS_Entry; CustomerAddress)
            {
            }
            column(TotalAmountLabel_POS_Entry; StrSubstNo(TotalAmountLabel, GeneralLedgerSetup."LCY Code"))
            {
            }
            column(TotalAmountInclVATLabel_POS_Entry; StrSubstNo(TotalAmountInclVATLabel, GeneralLedgerSetup."LCY Code"))
            {
            }
            column(POS_Store_Code; "POS Store Code")
            {
            }
            column(POS_Unit_No_; "POS Unit No.")
            {
            }
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            column(VAT_Registration_No_CompanyInformation; CompanyInformation."VAT Registration No.")
            {
            }
            column(Phone_No_CompanyInformation; CompanyInformation."Phone No.")
            {
            }
            column(E_Mail_CompanyInformation; CompanyInformation."E-Mail")
            {
            }
            column(Home_Page_CompanyInformation; CompanyInformation."Home Page")
            {
            }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                DataItemLink = Code = field("Salesperson Code");
                DataItemTableView = sorting(Code);
                column(Code_SalespersonPurchaser; "Code")
                {
                }
                column(Name_SalespersonPurchaser; Name)
                {
                }
            }
            dataitem("NPR POS Entry Sales Line"; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = field("Entry No.");
                DataItemTableView = sorting("POS Entry No.", "Line No.");
                column(POSEntryNo_POS_Entry_Sales_Line; "POS Entry No.")
                {
                }
                column(LineNo_POS_Entry_Sales_Line; "Line No.")
                {
                }
                column(Type_POS_Entry_Sales_Line; Type)
                {
                }
                column(No_POS_Entry_Sales_Line; "No.")
                {
                    IncludeCaption = true;
                }
                column(Description_POS_Entry_Sales_Line; Description)
                {
                    IncludeCaption = true;
                }
                column(Description_2_POS_Entry_Sales_Line; "Description 2")
                {
                    IncludeCaption = true;
                }
                column(Quantity_POS_Entry_Sales_Line; Quantity)
                {
                    IncludeCaption = true;
                }
                column(UOM_POS_Entry_Sales_Line; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }
                column(Unit_Price_POS_Entry_Sales_Line; "Unit Price")
                {
                    IncludeCaption = true;
                }
                column(Line_Discount_pct_POS_Entry_Sales_Line; "Line Discount %")
                {
                    IncludeCaption = true;
                }
                column(Amount_Incl_VAT_POS_Entry_Sales_Line; "Amount Incl. VAT")
                {
                    IncludeCaption = true;
                }
                column(Total_Quantity_UnitPrice; TotalQuantityUnitPrice)
                {
                }
                column(Line_Discount_Amount_Incl__VAT; "Line Discount Amount Incl. VAT")
                {
                }
                dataitem(Item_Variant; "Item Variant")
                {
                    DataItemLink = Code = field("Variant Code"), "Item No." = field("No.");
                    DataItemTableView = sorting("Item No.", Code);
                    column(Description_Item_Variant; Description)
                    {
                    }
                }
                trigger OnAfterGetRecord()
                var
                    Item: Record Item;
                begin
                    if (Type = Type::Item) and Item.Get("No.") and Item."NPR No Print on Reciept" then
                        CurrReport.Skip();

                    TotalQuantityUnitPrice := (Quantity * "Unit Price");
                end;
            }
            dataitem("NPR DE POS Audit Log Aux. Info"; "NPR DE POS Audit Log Aux. Info")
            {
                DataItemLink = "POS Entry No." = field("Entry No.");

                column(POSEntryNo_NPRDEPOSAuditLogAuxInfo; "POS Entry No.")
                {
                    IncludeCaption = true;
                }
                column(TSSCode_NPRDEPOSAuditLogAuxInfo; "TSS Code")
                {
                    IncludeCaption = true;
                }
                column(TransactionID_NPRDEPOSAuditLogAuxInfo; "Transaction ID")
                {
                    IncludeCaption = true;
                }
                column(StartTime_NPRDEPOSAuditLogAuxInfo; "Start Time")
                {
                    IncludeCaption = true;
                }
                column(FinishTime_NPRDEPOSAuditLogAuxInfo; "Finish Time")
                {
                    IncludeCaption = true;
                }
                column(SignatureCount_NPRDEPOSAuditLogAuxInfo; "Signature Count")
                {
                    IncludeCaption = true;
                }
                column(Signature_NPRDEPOSAuditLogAuxInfo; Signature)
                {
                    IncludeCaption = true;
                }
                column(SerialNumber_NPRDEPOSAuditLogAuxInfo; "Serial Number")
                {
                    IncludeCaption = true;
                }
            }

            dataitem("NPR POS Entry Payment Line"; "NPR POS Entry Payment Line")
            {
                DataItemTableView = sorting("POS Entry No.", "Line No.");
                column(LineNo_POS_Payment_Line; "Line No.")
                {
                }
                column(POS_Entry_No_POS_Payment_Line; "POS Entry No.")
                {
                }
                column(POSPaymentMethodCode_POS_Payment_Line; "POS Payment Method Code")
                {
                    IncludeCaption = true;
                }
                column(Description_POS_Payment_Line; Description)
                {
                    IncludeCaption = true;
                }
                column(CurrencyCode_POS_Payment_Line; "Currency Code")
                {
                }
                column(Amount_POS_Payment_Line; Amount)
                {
                    IncludeCaption = true;
                }
                column(AmountSalesCurrency_POS_Payment_Line; "Amount (Sales Currency)")
                {
                    IncludeCaption = true;
                }

                trigger OnPreDataItem()
                begin
                    "NPR POS Entry Payment Line".SetRange("POS Entry No.", "NPR POS Entry"."Entry No.");
                    Clear(AmounTotalPOSPaymentLine);
                    Clear(AmountSalesCurrencyTotalPOSPaymentLine);
                end;

                trigger OnAfterGetRecord()
                var
                begin
                    AmounTotalPOSPaymentLine += Amount;
                    AmountSalesCurrencyTotalPOSPaymentLine += "Amount (Sales Currency)";
                end;
            }

            dataitem("NPR POS Entry Tax Line"; "NPR POS Entry Tax Line")
            {
                DataItemTableView = sorting("POS Entry No.", "Tax Area Code for Key", "Tax Jurisdiction Code", "VAT Identifier", "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax", Positive);
                column(POSEntryNo_POS_Tax_Amount_Line; "POS Entry No.")
                {
                }
                column(VATIdentifier_POS_Tax_Amount_Line; "VAT Identifier")
                {
                    IncludeCaption = true;
                }
                column(TaxCalculationType_POS_Tax_Amount_Line; "Tax Calculation Type")
                {
                    IncludeCaption = true;
                }
                column(Tax_POS_Tax_Amount_Line; "Tax %")
                {
                    IncludeCaption = true;
                }
                column(Quantity_POS_Tax_Amount_Line; Quantity)
                {
                    IncludeCaption = true;
                }
                column(LineAmount_POS_Tax_Amount_Line; "Line Amount")
                {
                    IncludeCaption = true;
                }
                column(TaxBaseAmount_POS_Tax_Amount_Line; "Tax Base Amount")
                {
                    IncludeCaption = true;
                }
                column(TaxAmount_POS_Tax_Amount_Line; "Tax Amount")
                {
                    IncludeCaption = true;
                }
                column(TotalTaxText_POS_Tax_Amount_Line; TotalTaxAmountLabel)
                {
                }

                trigger OnPreDataItem()
                begin
                    "NPR POS Entry Tax Line".SetRange("POS Entry No.", "NPR POS Entry"."Entry No.");
                    Clear(QuantityTotalPOSTaxAmountLine);
                    Clear(LineAmountTotalPOSTaxAmountLine);
                    Clear(TaxBaseAmountTotalPOSTaxAmountLine);
                    Clear(TaxAmountTotalPOSTaxAmountLine);
                end;

                trigger OnAfterGetRecord()
                begin
                    QuantityTotalPOSTaxAmountLine += Quantity;
                    LineAmountTotalPOSTaxAmountLine += "Line Amount";
                    TaxBaseAmountTotalPOSTaxAmountLine += "Tax Base Amount";
                    TaxAmountTotalPOSTaxAmountLine += "Tax Amount";
                end;
            }

            trigger OnAfterGetRecord()
            var
                Contact: Record Contact;
                Customer: Record Customer;
                POSStore: Record "NPR POS Store";
                FormatAddress: Codeunit "Format Address";
                TextFunctions: Codeunit "NPR Text Functions";
            begin
                if POSStore.Get("NPR POS Entry"."POS Store Code") then begin
                    CompanyInformation.Name := POSStore.Name;
                    CompanyInformation."Name 2" := POSStore."Name 2";
                    CompanyInformation.Address := POSStore.Address;
                    CompanyInformation."Address 2" := POSStore."Address 2";
                    CompanyInformation.City := POSStore.City;
                    CompanyInformation."Post Code" := POSStore."Post Code";
                    CompanyInformation."Phone No." := POSStore."Phone No.";
                    CompanyInformation."E-Mail" := POSStore."E-Mail";
                    CompanyInformation."Home Page" := POSStore."Home Page";
                    CompanyInformation."VAT Registration No." := POSStore."VAT Registration No.";
                    FormatAddress.Company(AddrArray, CompanyInformation);
                    StoreAddress := TextFunctions.AddressArrayToMultilineString(AddrArray);
                end;

                Clear(AddrArray);
                if "NPR POS Entry"."Customer No." <> '' then begin
                    Customer.Get("NPR POS Entry"."Customer No.");
                    FormatAddress.Customer(AddrArray, Customer);
                end else
                    if "NPR POS Entry"."Contact No." <> '' then begin
                        Contact.Get("NPR POS Entry"."Contact No.");
                        FormatAddress.ContactAddr(AddrArray, Contact);
                    end;
                CustomerAddress := TextFunctions.AddressArrayToMultilineString(AddrArray);
            end;
        }
        dataitem("NPR POS Entry Payment Line Totals"; Integer) // Because we have Word Layout!
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(AmountTotal_POS_Payment_Line; AmounTotalPOSPaymentLine)
            {
            }
            column(AmountSalesCurrencyTotal_POS_Payment_Line; AmountSalesCurrencyTotalPOSPaymentLine)
            {
            }
        }
        dataitem("NPR POS Entry Tax Line Totals"; Integer) // Because we have Word Layout!
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            column(QuantityTotal_POS_Tax_Amount_Line; QuantityTotalPOSTaxAmountLine)
            {
            }
            column(LineAmountTotal_POS_Tax_Amount_Line; LineAmountTotalPOSTaxAmountLine)
            {
            }
            column(TaxBaseAmountTotal_POS_Tax_Amount_Line; TaxBaseAmountTotalPOSTaxAmountLine)
            {
            }
            column(TaxAmountTotal_POS_Tax_Amount_Line; TaxAmountTotalPOSTaxAmountLine)
            {
            }
        }
    }

    requestpage
    {
        SaveValues = true;
    }

    labels
    {
        DocumentDateLabel = 'Document Date';
        SalespersonNameLabel = 'Salesperson';
        PageLabel = 'Page';
        PageOfLabel = '%1 of %2';
        LineDiscountPercentageLabel = 'Discount Amount';
        PaidCurrencyLabel = 'Paid Currency';
        TotalLabel = 'Total';
        MethodCodeLabel = 'Method Code';
        TotalDiscountAmountLabel = 'Total Discount Amount';
        PaymentLabel = 'Payment Specification';
        VATLabel = 'VAT Specification';
        PosStoreCodeLabel = 'Store Code';
        UOMLabel = 'UOM';
        POSUnitLabel = 'POS Unit';
        VatRegistrationNoLabel = 'VAT Registration No.';
        PhoneNoLabel = 'Phone No.';
        EmailLabel = 'Email';
        HomePageLabel = 'Home Page';
        TotalVATCaptionLbl = 'Total VAT';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
        GeneralLedgerSetup.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AmounTotalPOSPaymentLine: Decimal;
        AmountSalesCurrencyTotalPOSPaymentLine: Decimal;
        LineAmountTotalPOSTaxAmountLine: Decimal;
        QuantityTotalPOSTaxAmountLine: Decimal;
        TaxAmountTotalPOSTaxAmountLine: Decimal;
        TaxBaseAmountTotalPOSTaxAmountLine: Decimal;
        TotalQuantityUnitPrice: Decimal;
        AddrArray: Array[8] of Text[100];
        CustomerAddress: Text;
        StoreAddress: Text;
        TotalAmountInclVATLabel: Label 'Total %1 Incl. VAT';
        TotalAmountLabel: Label 'Total %1 Excl. VAT';
        TotalTaxAmountLabel: Label 'Total VAT';
}