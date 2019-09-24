report 6150613 "Sales Ticket A4 - POS Rdlc"
{
    // NPR5.39/JLK /20180212  CASE 302797 Object created
    // NPR5.40/JLK /20180314  CASE 307437 Added format on decimals in rdlc layout
    // NPR5.41/JLK /20180504  CASE 307437 Seperated Report to rdlc layout only
    RDLCLayout = './layouts/Sales Ticket A4 - POS Rdlc.rdlc';

    Caption = 'Sales Ticket A4 - POS Rdlc';
    DefaultLayout = RDLC;
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(POS_Entry;"POS Entry")
        {
            DataItemTableView = SORTING("Entry No.");
            RequestFilterFields = "Entry No.";
            column(EntryNo_POS_Entry;"Entry No.")
            {
            }
            column(EntryDate_POS_Entry;"Entry Date")
            {
            }
            column(DocumentNo_POS_Entry;"Document No.")
            {
                IncludeCaption = true;
            }
            column(POSUnitNo_POS_Entry;"POS Unit No.")
            {
            }
            column(EndingTime_POS_Entry;"Ending Time")
            {
            }
            column(DiscountAmount_POS_Entry;"Discount Amount")
            {
            }
            column(TotalAmount_POS_Entry;"Amount Excl. Tax")
            {
            }
            column(TotalTaxAmount_POS_Entry;"Tax Amount")
            {
            }
            column(TotalAmountInclTax_POS_Entry;"Amount Incl. Tax")
            {
            }
            column(TotalTaxText;TotalTaxText)
            {
            }
            column(Picture_Company_Information;CompanyInformation.Picture)
            {
            }
            dataitem(General_Ledger_Setup;"General Ledger Setup")
            {
                DataItemTableView = SORTING("Primary Key");
                column(PrimaryKey_General_Ledger_Setup;"Primary Key")
                {
                }
                column(LCYCode_General_Ledger_Setup;"LCY Code")
                {
                }

                trigger OnPreDataItem()
                begin
                    Get;
                end;
            }
            dataitem(POS_Store;"POS Store")
            {
                DataItemLink = Code=FIELD("POS Store Code");
                DataItemTableView = SORTING(Code);
                column(Code_POS_Store;Code)
                {
                }
                column(Name_POS_Store;Name)
                {
                }
                column(Name2_POS_Store;"Name 2")
                {
                }
                column(Address_POS_Store;Address)
                {
                }
                column(Address2_POS_Store;"Address 2")
                {
                }
                column(PostCode_POS_Store;"Post Code")
                {
                }
                column(City_POS_Store;City)
                {
                }
                column(PhoneNo_POS_Store;"Phone No.")
                {
                    IncludeCaption = true;
                }
                column(VATRegistrationNo_POS_Store;"VAT Registration No.")
                {
                    IncludeCaption = true;
                }
                column(EMail_POS_Store;"E-Mail")
                {
                    IncludeCaption = true;
                }
                column(HomePage_POS_Store;"Home Page")
                {
                    IncludeCaption = true;
                }
                column(StoreAddr1;StoreAddr[1])
                {
                }
                column(StoreAddr2;StoreAddr[2])
                {
                }
                column(StoreAddr3;StoreAddr[3])
                {
                }
                column(StoreAddr4;StoreAddr[4])
                {
                }
                column(StoreAddr5;StoreAddr[5])
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(StoreAddr);
                    StoreAddr[1] := Name;
                    StoreAddr[2] := "Name 2";
                    StoreAddr[3] := Address;
                    StoreAddr[4] := "Address 2";
                    StoreAddr[5] := "Post Code" + ' - ' + City;
                    CompressArray(StoreAddr);
                end;
            }
            dataitem(POS_Unit;"POS Unit")
            {
                DataItemLink = "No."=FIELD("POS Unit No.");
                DataItemTableView = SORTING("No.");
            }
            dataitem(Customer;Customer)
            {
                DataItemLink = "No."=FIELD("Customer No.");
                DataItemTableView = SORTING("No.");
                column(No_Customer;"No.")
                {
                }
                column(Name_Customer;Name)
                {
                }
                column(Address_Customer;Address)
                {
                }
                column(CustomerPriceGroup_Customer;"Customer Price Group")
                {
                }
                column(City_Customer;City)
                {
                }
                column(PostCode_Customer;"Post Code")
                {
                    IncludeCaption = true;
                }

                trigger OnAfterGetRecord()
                begin
                    Clear(CustAddr);
                    CustAddr[1] := Name;
                    CustAddr[2] := "Name 2";
                    CustAddr[3] := Address;
                    CustAddr[4] := "Address 2";
                    CustAddr[5] := "Post Code" + ' - ' + City;
                    CustAddr[6] := CustomerNoCaption + ': ' + "No.";
                    CompressArray(CustAddr);
                end;
            }
            dataitem(POS_Entry_Blank_Customer;"POS Entry")
            {
                DataItemLink = "Entry No."=FIELD("Entry No.");
                DataItemTableView = SORTING("Entry No.") WHERE("Customer No."=FILTER(' '));
                dataitem(Contact;Contact)
                {
                    DataItemLink = "No."=FIELD("Contact No.");
                    DataItemTableView = SORTING("No.");
                    column(No_Contact;"No.")
                    {
                    }
                    column(Name_Contact;Name)
                    {
                    }
                    column(Address_Contact;Address)
                    {
                    }
                    column(City_Contact;City)
                    {
                    }
                    column(PostCode_Contact;"Post Code")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Clear(CustAddr);
                        CustAddr[1] := Name;
                        CustAddr[2] := "Name 2";
                        CustAddr[3] := Address;
                        CustAddr[4] := "Address 2";
                        CustAddr[5] := "Post Code" + ' - ' + City;
                        CustAddr[6] := '';
                        CustAddr[7] := '';
                        CompressArray(CustAddr);
                    end;
                }
            }
            dataitem(CustAddress;"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                column(Number;Number)
                {
                }
                column(CustAddr1;CustAddr[1])
                {
                }
                column(CustAddr2;CustAddr[2])
                {
                }
                column(CustAddr3;CustAddr[3])
                {
                }
                column(CustAddr4;CustAddr[4])
                {
                }
                column(CustAddr5;CustAddr[5])
                {
                }
                column(CustAddr6;CustAddr[6])
                {
                }
                column(CustAddr7;CustAddr[7])
                {
                }
            }
            dataitem("Salesperson/Purchaser";"Salesperson/Purchaser")
            {
                DataItemLink = Code=FIELD("Salesperson Code");
                DataItemTableView = SORTING(Code);
                column(Code_SalespersonPurchaser;Code)
                {
                }
                column(Name_SalespersonPurchaser;Name)
                {
                }
            }
            dataitem(POS_Sales_Line;"POS Sales Line")
            {
                DataItemLink = "POS Entry No."=FIELD("Entry No.");
                DataItemTableView = SORTING("POS Entry No.","Line No.");
                column(POSEntryNo_POS_Sales_Line;"POS Entry No.")
                {
                }
                column(LineNo_POS_Sales_Line;"Line No.")
                {
                }
                dataitem(POS_Sales_Item_Line;"POS Sales Line")
                {
                    DataItemLink = "POS Entry No."=FIELD("POS Entry No."),"Line No."=FIELD("Line No.");
                    DataItemTableView = SORTING("POS Entry No.","Line No.") WHERE(Type=FILTER(Item));
                    column(Type_POS_Sales_Item_Line;Type)
                    {
                    }
                    column(No_POS_Sales_Item_Line;"No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_POS_Sales_Item_Line;Description)
                    {
                        IncludeCaption = true;
                    }
                    column(Quantity_POS_Sales_Item_Line;Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(UnitPrice_POS_Sales_Item_Line;"Unit Price")
                    {
                        IncludeCaption = true;
                    }
                    column(AmountInclVAT_POS_Sales_Item_Line;"Amount Incl. VAT")
                    {
                        IncludeCaption = true;
                    }
                    column(LineDiscount_POS_Sales_Item_Line;"Line Discount %")
                    {
                        IncludeCaption = true;
                    }
                    dataitem(Item_Variant;"Item Variant")
                    {
                        DataItemLink = Code=FIELD("Variant Code"),"Item No."=FIELD("No.");
                        DataItemTableView = SORTING("Item No.",Code);
                        column(Description_Item_Variant;Description)
                        {
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        Item: Record Item;
                    begin
                        if Item.Get("No.") and Item."No Print on Reciept" then
                            CurrReport.Skip;
                    end;
                }
                dataitem(POS_Sales_GLAccount_Line;"POS Sales Line")
                {
                    DataItemLink = "POS Entry No."=FIELD("POS Entry No."),"Line No."=FIELD("Line No.");
                    DataItemTableView = SORTING("POS Entry No.","Line No.") WHERE(Type=FILTER("G/L Account"));
                    column(Type_POS_Sales_GLAccount_Line;Type)
                    {
                    }
                    column(No_POS_Sales_GLAccount_Line;"No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_POS_Sales_GLAccount_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_GLAccount_Line;"Amount Incl. VAT")
                    {
                    }
                }
                dataitem(POS_Sales_Comment_Line;"POS Sales Line")
                {
                    DataItemLink = "POS Entry No."=FIELD("POS Entry No."),"Line No."=FIELD("Line No.");
                    DataItemTableView = SORTING("POS Entry No.","Line No.") WHERE(Type=FILTER(Comment));
                    column(Type_POS_Sales_Comment_Line;Type)
                    {
                    }
                    column(No_POS_Sales_Comment_Line;"No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_POS_Sales_Comment_Line;Description)
                    {
                    }
                }
                dataitem(POS_Sales_Customer_Line;"POS Sales Line")
                {
                    DataItemLink = "POS Entry No."=FIELD("POS Entry No."),"Line No."=FIELD("Line No.");
                    DataItemTableView = SORTING("POS Entry No.","Line No.") WHERE(Type=FILTER(Customer));
                    column(Type_POS_Sales_Customer_Line;Type)
                    {
                    }
                    column(No_POS_Sales_Customer_Line;"No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_POS_Sales_Customer_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Customer_Line;"Amount Incl. VAT")
                    {
                    }
                }
                dataitem(POS_Sales_Voucher_Line;"POS Sales Line")
                {
                    DataItemLink = "POS Entry No."=FIELD("POS Entry No."),"Line No."=FIELD("Line No.");
                    DataItemTableView = SORTING("POS Entry No.","Line No.") WHERE(Type=FILTER(Voucher));
                    column(Type_POS_Sales_Voucher_Line;Type)
                    {
                    }
                    column(No_POS_Sales_Voucher_Line;"No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_POS_Sales_Voucher_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Voucher_Line;"Amount Incl. VAT")
                    {
                    }
                }
                dataitem(POS_Sales_Payout_Line;"POS Sales Line")
                {
                    DataItemLink = "POS Entry No."=FIELD("POS Entry No."),"Line No."=FIELD("Line No.");
                    DataItemTableView = SORTING("POS Entry No.","Line No.") WHERE(Type=FILTER(Payout));
                    column(Type_POS_Sales_Payout_Line;Type)
                    {
                    }
                    column(No_POS_Sales_Payout_Line;"No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_POS_Sales_Payout_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Payout_Line;"Amount Incl. VAT")
                    {
                    }
                }
                dataitem(POS_Sales_Rounding_Line;"POS Sales Line")
                {
                    DataItemLink = "POS Entry No."=FIELD("POS Entry No."),"Line No."=FIELD("Line No.");
                    DataItemTableView = SORTING("POS Entry No.","Line No.") WHERE(Type=FILTER(Rounding));
                    column(Type_POS_Sales_Rounding_Line;Type)
                    {
                    }
                    column(No_POS_Sales_Rounding_Line;"No.")
                    {
                        IncludeCaption = true;
                    }
                    column(Description_POS_Sales_Rounding_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Rounding_Line;"Amount Incl. VAT")
                    {
                    }
                }
            }
            dataitem(POS_Payment_Line;"POS Payment Line")
            {
                DataItemLink = "POS Entry No."=FIELD("Entry No.");
                DataItemTableView = SORTING("POS Entry No.","Line No.");
                column(POS_Entry_No_POS_Payment_Line;"POS Entry No.")
                {
                }
                column(Line_No_POS_Payment_Line;"Line No.")
                {
                    IncludeCaption = true;
                }
                column(Description_POS_Payment_Line;Description)
                {
                    IncludeCaption = true;
                }
                column(Amount_POS_Payment_Line;Amount)
                {
                    IncludeCaption = true;
                }
                column(CurrencyCode_POS_Payment_Line;"Currency Code")
                {
                }
                column(AmountSalesCurrency_POS_Payment_Line;"Amount (Sales Currency)")
                {
                    IncludeCaption = true;
                }
                column(POSPaymentMethodCode_POS_Payment_Line;"POS Payment Method Code")
                {
                    IncludeCaption = true;
                }
            }
            dataitem(POS_Tax_Amount_Line;"POS Tax Amount Line")
            {
                DataItemLink = "POS Entry No."=FIELD("Entry No.");
                DataItemTableView = SORTING("POS Entry No.","Tax Area Code for Key","Tax Jurisdiction Code","VAT Identifier","Tax %","Tax Group Code","Expense/Capitalize","Tax Type","Use Tax",Positive);
                column(POS_Entry_No_POS_Tax_Amount_Line;"POS Entry No.")
                {
                }
                column(TaxCalculationType_POS_Tax_Amount_Line;"Tax Calculation Type")
                {
                    IncludeCaption = true;
                }
                column(Tax_POS_Tax_Amount_Line;"Tax %")
                {
                    IncludeCaption = true;
                }
                column(TaxBaseAmount_POS_Tax_Amount_Line;"Tax Base Amount")
                {
                    IncludeCaption = true;
                }
                column(TaxAmount_POS_Tax_Amount_Line;"Tax Amount")
                {
                    IncludeCaption = true;
                }
                column(Quantity_POS_Tax_Amount_Line;Quantity)
                {
                    IncludeCaption = true;
                }
                column(TaxAreaCode_POS_Tax_Amount_Line;"Tax Area Code")
                {
                    IncludeCaption = true;
                }
                column(VATIdentifier_POS_Tax_Amount_Line;"VAT Identifier")
                {
                    IncludeCaption = true;
                }
                column(AmountIncludingTax_POS_Tax_Amount_Line;"Amount Including Tax")
                {
                    IncludeCaption = true;
                }
                column(LineAmount_POS_Tax_Amount_Line;"Line Amount")
                {
                    IncludeCaption = true;
                }
            }

            trigger OnAfterGetRecord()
            var
                POSTaxAmountLine: Record "POS Tax Amount Line";
            begin
                TotalTaxText := GetVATText("Entry No.");
                CompanyInformation.CalcFields(Picture);
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
        LineDiscountPercentageLabel = 'Disc. %';
        TotalAmountLabel = 'Total %1 Excl. VAT';
        TotalDiscountAmountLabel = 'Discount Amount';
        TotalTaxAmountLabel = '%1 VAT';
        TotalAmountInclVATLabel = 'Total %1 Incl. VAT';
        PaidCurrencyLabel = 'Paid Currency';
        MethodCodeLabel = 'Method Code';
        TotalLabel = 'Total';
        PaymentLabel = 'Payment Specification';
        VATLabel = 'VAT Specification';
        SalespersonNameLabel = 'Salesperson';
        DocumentDateLabel = 'Document Date';
        PageOfLabel = '%1 of %2';
        PageLabel = 'Page';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
    end;

    var
        TotalTaxText: Text;
        StoreAddr: array [8] of Text;
        CustAddr: array [8] of Text;
        CompanyInformation: Record "Company Information";
        CustomerNoCaption: Label 'Customer No.';

    local procedure GetVATText(EntryNo: Integer): Text
    var
        POSTaxAmountLine: Record "POS Tax Amount Line";
    begin
        with POSTaxAmountLine do begin
          SetRange("POS Entry No.",EntryNo);
          if Count > 1 then
            exit('');

          if FindFirst then
            exit(Format("Tax %") + '%');

          exit('');
        end;
    end;
}

