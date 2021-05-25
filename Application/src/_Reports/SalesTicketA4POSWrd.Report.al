report 6150616 "NPR Sales Ticket A4 - POS Wrd"
{
    RDLCLayout = './src/_Reports/layouts/Sales Ticket A4 - POS Wrd.rdlc';
    WordLayout = './src/_Reports/layouts/Sales Ticket A4 - POS Wrd.docx';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Sales Ticket A4 - POS Wrd';
    DefaultLayout = Word;
    PreviewMode = PrintLayout;
    dataset
    {
        dataitem(POS_Entry; "NPR POS Entry")
        {
            DataItemTableView = SORTING("Entry No.");
            RequestFilterFields = "Entry No.";
            column(PE_EntryNo; "Entry No.")
            {
            }
            column(PE_EntryDate; Format("Entry Date", 0, 4))
            {
            }
            column(PE_DocumentNo; "Document No.")
            {
                IncludeCaption = true;
            }
            column(PE_POSUnitNo; "POS Unit No.")
            {
            }
            column(PE_EndingTime; "Ending Time")
            {
            }
            column(PE_DiscountAmount; "Discount Amount")
            {
            }
            column(PE_TotalAmount; "Amount Excl. Tax")
            {
            }
            column(PE_TotalTaxAmount; "Tax Amount")
            {
            }
            column(PE_TotalAmountInclTax; "Amount Incl. Tax")
            {
            }
            column(TotalAmountCaption; StrSubstNo(TotalAmountCaption, GeneralLedgerSetup."LCY Code"))
            {
            }
            column(TotalAmountInclVATCaption; StrSubstNo(TotalAmountInclVATCaption, GeneralLedgerSetup."LCY Code"))
            {
            }
            column(TotalTaxAmountCaption; TotalTaxText)
            {
            }
            column(Picture_CompanyInformation; CompanyInformation.Picture)
            {
            }
            column(LCYCode_GeneralLedgerSetup; GeneralLedgerSetup."LCY Code")
            {
            }
            column(PS_Code; POSStore.Code)
            {
            }
            column(PS_Name; POSStore.Name)
            {
            }
            column(PS_Name2; POSStore."Name 2")
            {
            }
            column(PS_Address; POSStore.Address)
            {
            }
            column(PS_Address2; POSStore."Address 2")
            {
            }
            column(PS_PostCode; POSStore."Post Code")
            {
            }
            column(PS_City; POSStore.City)
            {
            }
            column(PS_PhoneNo; POSStore."Phone No.")
            {
            }
            column(PS_VATRegistrationNo; POSStore."VAT Registration No.")
            {
            }
            column(PS_EMail; POSStore."E-Mail")
            {
            }
            column(PS_HomePage; POSStore."Home Page")
            {
            }
            column(StoreAddr1; StoreAddr[1])
            {
            }
            column(StoreAddr2; StoreAddr[2])
            {
            }
            column(StoreAddr3; StoreAddr[3])
            {
            }
            column(StoreAddr4; StoreAddr[4])
            {
            }
            column(StoreAddr5; StoreAddr[5])
            {
            }
            column(CustAddr1; CustAddr[1])
            {
            }
            column(CustAddr2; CustAddr[2])
            {
            }
            column(CustAddr3; CustAddr[3])
            {
            }
            column(CustAddr4; CustAddr[4])
            {
            }
            column(CustAddr5; CustAddr[5])
            {
            }
            column(CustAddr6; CustAddr[6])
            {
            }
            column(CustAddr7; CustAddr[7])
            {
            }
            column(Code_SalespersonPurchaser; SalespersonPurchaser.Code)
            {
            }
            column(Name_SalespersonPurchaser; SalespersonPurchaser.Name)
            {
            }

            column(CustomerNo_POSEntry; "Customer No.")
            {
            }

            column(Customer_PhoneNo; Customer."Phone No.")
            {
            }
            dataitem(POS_Sales_Line; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = FIELD("Entry No.");
                DataItemTableView = SORTING("POS Entry No.", "Line No.");
                column(PSL_POSEntryNo; "POS Entry No.")
                {
                }
                column(PSL_LineNo; "Line No.")
                {
                }
                column(PSL_Type; Type)
                {
                }
                column(PSL_No; "No.")
                {
                    IncludeCaption = true;
                }
                column(PSL_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(PSL_Quantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(PSL_UnitPrice; "Unit Price")
                {
                    IncludeCaption = true;
                }
                column(PSL_AmountInclVAT; "Amount Incl. VAT")
                {
                    IncludeCaption = true;
                }
                column(PSL_LineDiscount; "Line Discount %")
                {
                }
                column(Description_ItemVariant; ItemVariant.Description)
                {
                }
                column(PSL_BlankZero_Quantity; BlankZero(Quantity))
                {
                }
                column(PSL_BlankZero_UnitPrice; BlankZero("Unit Price"))
                {
                }
                column(PSL_BlankZero_AmountInclVAT; BlankZero("Amount Incl. VAT"))
                {
                }
                column(PSL_BlankZero_LineDiscount; BlankZero("Line Discount %"))
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if not ItemVariant.Get("No.", "Variant Code") then
                        Clear(ItemVariant);
                end;
            }
            dataitem(POS_Payment_Line; "NPR POS Entry Payment Line")
            {
                DataItemLink = "POS Entry No." = FIELD("Entry No.");
                DataItemTableView = SORTING("POS Entry No.", "Line No.");
                column(PPL_POS_Entry_No; "POS Entry No.")
                {
                }
                column(PPL_Line_No; "Line No.")
                {
                    IncludeCaption = true;
                }
                column(PPL_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(PPL_Amount; Amount)
                {
                    IncludeCaption = true;
                }
                column(PPL_CurrencyCode; "Currency Code")
                {
                }
                column(PPL_AmountSalesCurrency; "Amount (Sales Currency)")
                {
                    IncludeCaption = true;
                }
                column(PPL_POSPaymentMethodCode; "POS Payment Method Code")
                {
                    IncludeCaption = true;
                }
                column(PPL_BlankZero_Amount; BlankZero(Amount))
                {
                }
                column(PPL_BlankZero_AmountSalesCurrency; BlankZero("Amount (Sales Currency)"))
                {
                }
            }
            dataitem(POS_Tax_Amount_Line; "NPR POS Entry Tax Line")
            {
                DataItemLink = "POS Entry No." = FIELD("Entry No.");
                DataItemTableView = SORTING("POS Entry No.", "Tax Area Code for Key", "Tax Jurisdiction Code", "VAT Identifier", "Tax %", "Tax Group Code", "Expense/Capitalize", "Tax Type", "Use Tax", Positive);
                column(PTAL_POS_Entry_No; "POS Entry No.")
                {
                }
                column(PTAL_TaxCalculationType; "Tax Calculation Type")
                {
                    IncludeCaption = true;
                }
                column(PTAL_Tax_Percent; "Tax %")
                {
                    IncludeCaption = true;
                }
                column(PTAL_TaxBaseAmount; "Tax Base Amount")
                {
                    IncludeCaption = true;
                }
                column(PTAL_TaxAmount; "Tax Amount")
                {
                    IncludeCaption = true;
                }
                column(PTAL_Quantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(PTAL_TaxAreaCode; "Tax Area Code")
                {
                    IncludeCaption = true;
                }
                column(PTAL_VATIdentifier; "VAT Identifier")
                {
                    IncludeCaption = true;
                }
                column(PTAL_AmountIncludingTax; "Amount Including Tax")
                {
                    IncludeCaption = true;
                }
                column(PTAL_LineAmount; "Line Amount")
                {
                    IncludeCaption = true;
                }
                column(PTAL_BlankZero_Tax_Percent; BlankZero("Tax %"))
                {
                }
                column(PTAL_BlankZero_TaxBaseAmount; BlankZero("Tax Base Amount"))
                {
                }
                column(PTAL_BlankZero_TaxAmount; BlankZero("Tax Amount"))
                {
                }
                column(PTAL_BlankZero_Quantity; BlankZero(Quantity))
                {
                }
                column(PTAL_BlankZero_AmountIncludingTax; BlankZero("Amount Including Tax"))
                {
                }
                column(PTAL_BlankZero_LineAmount; BlankZero("Line Amount"))
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                TotalTaxText := GetVATText("Entry No.");
                if DelChr(TotalTaxText, '=', '0123456789') = '' then
                    TotalTaxText := StrSubstNo(TotalTaxAmountCaptionBlank)
                else
                    TotalTaxText := StrSubstNo(TotalTaxAmountCaption, TotalTaxText);

                CompanyInformation.CalcFields(Picture);

                if not POSStore.Get("POS Store Code") then
                    Clear(POSStore);

                Clear(StoreAddr);
                StoreAddr[1] := POSStore.Name;
                StoreAddr[2] := POSStore."Name 2";
                StoreAddr[3] := POSStore.Address;
                StoreAddr[4] := POSStore."Address 2";
                StoreAddr[5] := POSStore."Post Code" + ' - ' + POSStore.City;
                CompressArray(StoreAddr);

                Clear(CustAddr);
                if not Customer.Get("Customer No.") then begin
                    Clear(Customer);
                    if Contact.Get("Customer No.") then begin
                        CustAddr[1] := Contact.Name;
                        CustAddr[2] := Contact."Name 2";
                        CustAddr[3] := Contact.Address;
                        CustAddr[4] := Contact."Address 2";
                        CustAddr[5] := Contact."Post Code" + ' - ' + Contact.City;
                        if Contact."No." <> '' then
                            CustAddr[6] := ContactNoCaption + ': ' + Contact."No.";
                        CustAddr[7] := '';
                        CustPhoneNo := Contact."Phone No.";
                    end;
                end;

                CustAddr[1] := Customer.Name;
                CustAddr[2] := Customer."Name 2";
                CustAddr[3] := Customer.Address;
                CustAddr[4] := Customer."Address 2";
                CustAddr[5] := Customer."Post Code" + ' - ' + Customer.City;
                if Customer."No." <> '' then
                    CustAddr[6] := CustomerNoCaption + ': ' + Customer."No.";
                CustAddr[7] := '';
                CustPhoneNo := Customer."Phone No.";
                CompressArray(CustAddr);

                if not SalespersonPurchaser.Get(POS_Entry."Salesperson Code") then
                    Clear(SalespersonPurchaser);
            end;

            trigger OnPreDataItem()
            begin
                GeneralLedgerSetup.Get();
            end;
        }
    }

    labels
    {
        LineDiscountLabel = 'Disc. %';
        TotalDiscountAmountLabel = 'Discount Amount';
        CurrencyCodeLabel = 'Paid Currency';
        MethodCodeLabel = 'Method Code';
        TotalLabel = 'Total';
        PaymentSpecificationLabel = 'Payment Specification';
        VATSpecificationLabel = 'VAT Specification';
        SalespersonNameLabel = 'Salesperson';
        DocumentDateLabel = 'Document Date';
        PageOfLabel = '%1 of %2';
        PageLabel = 'Page';
        PhoneNoLabel = 'Phone No.';
        VATRegistrationNoLabel = 'VAT Registration No.';
        EMailLabel = 'E-Mail';
        HomePageLabel = 'Home Page';
        POSStoreCode = 'Store Code';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
    end;

    var
        CompanyInformation: Record "Company Information";
        Contact: Record Contact;
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        ItemVariant: Record "Item Variant";
        POSStore: Record "NPR POS Store";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        TotalTaxAmountCaption: Label '%1 VAT';
        ContactNoCaption: Label 'Contact No.';
        CustomerNoCaption: Label 'Customer No.';
        TotalAmountCaption: Label 'Total %1 Excl. VAT';
        TotalAmountInclVATCaption: Label 'Total %1 Incl. VAT';
        TotalTaxAmountCaptionBlank: Label 'VAT Amount';
        CustAddr: array[8] of Text;
        StoreAddr: array[8] of Text;
        TotalTaxText: Text;
        CustPhoneNo: text[30];

    local procedure GetVATText(EntryNo: Integer): Text
    var
        POSTaxAmountLine: Record "NPR POS Entry Tax Line";
    begin
        POSTaxAmountLine.SetRange("POS Entry No.", EntryNo);
        if POSTaxAmountLine.Count() > 1 then
            exit('');

        if POSTaxAmountLine.FindFirst() then
            exit(Format(POSTaxAmountLine."Tax %") + '%');

        exit('');
    end;

    local procedure BlankZero(DecimalValue: Decimal): Text
    begin
        if DecimalValue = 0 then
            exit('');

        exit(Format(DecimalValue, 0, '<Sign><Integer Thousand><Decimals,3>'));
    end;
}

