report 6150614 "Posting Overview POS"
{
    // NPR5.40/JLK /20180314 CASE 307437 Object created
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Posting Overview POS.rdlc';

    Caption = 'Posting Overview POS';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(POS_Entry;"POS Entry")
        {
            DataItemTableView = SORTING("Entry No.");
            RequestFilterFields = "Entry No.","POS Store Code";
            column(EntryNo_POS_Entry;"Entry No.")
            {
            }
            column(EntryDate_POS_Entry;"Entry Date")
            {
                IncludeCaption = true;
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
            column(POSStoreCode_POS_Entry;"POS Store Code")
            {
                IncludeCaption = true;
            }
            column(ShortcutDimension1Code_POS_Entry;"Shortcut Dimension 1 Code")
            {
                IncludeCaption = true;
            }
            column(SalespersonCode_POS_Entry;"Salesperson Code")
            {
                IncludeCaption = true;
            }
            column(TotalAmountInclTax;TotalAmountInclTax)
            {
            }
            column(POSStoreFilter;POSStoreFilter)
            {
            }
            column(DateFilter;DateFilter)
            {
            }
            column(NoFilter;NoFilter)
            {
            }
            dataitem(POS_Sales_Line;"POS Sales Line")
            {
                DataItemLink = "POS Entry No."=FIELD("Entry No.");
                DataItemTableView = SORTING("POS Entry No.","Line No.");
                RequestFilterFields = "No.";
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
                    column(No_POS_Sales_Item_Line;NoText)
                    {
                    }
                    column(Description_POS_Sales_Item_Line;Description)
                    {
                        IncludeCaption = true;
                    }
                    column(Quantity_POS_Sales_Item_Line;Quantity)
                    {
                    }
                    column(UnitPrice_POS_Sales_Item_Line;"Unit Price")
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Item_Line;"Amount Incl. VAT")
                    {
                        IncludeCaption = true;
                    }
                    column(LineDiscount_POS_Sales_Item_Line;"Line Discount %")
                    {
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
                        Clear(NoText);

                        NoText := "No.";
                        if (Type = Type::Item) and (Item.Get("No.")) then
                          NoText := Item."Vendor Item No.";

                        TotalAmountInclTax += "Amount Incl. VAT";
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

                    trigger OnAfterGetRecord()
                    begin
                        TotalAmountInclTax += "Amount Incl. VAT";
                    end;
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
                    }
                    column(Description_POS_Sales_Customer_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Customer_Line;"Amount Incl. VAT")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalAmountInclTax += "Amount Incl. VAT";
                    end;
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
                    }
                    column(Description_POS_Sales_Voucher_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Voucher_Line;"Amount Incl. VAT")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalAmountInclTax += "Amount Incl. VAT";
                    end;
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
                    }
                    column(Description_POS_Sales_Payout_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Payout_Line;"Amount Incl. VAT")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalAmountInclTax += "Amount Incl. VAT";
                    end;
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
                    }
                    column(Description_POS_Sales_Rounding_Line;Description)
                    {
                    }
                    column(AmountInclVAT_POS_Sales_Rounding_Line;"Amount Incl. VAT")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        TotalAmountInclTax += "Amount Incl. VAT";
                    end;
                }
                dataitem("Credit Card Transaction";"Credit Card Transaction")
                {
                    DataItemLink = "Sales Ticket No."=FIELD("Document No."),"Register No."=FIELD("POS Store Code"),Date=FIELD("Entry Date");
                    DataItemLinkReference = POS_Entry;
                    DataItemTableView = SORTING("Register No.","Sales Ticket No.",Date) WHERE(Type=FILTER(<>1));
                    column(TransactionTime_CreditCardTransaction;"Transaction Time")
                    {
                    }
                    column(EntryNo_CreditCardTransaction;"Entry No.")
                    {
                    }
                    column(Type_CreditCardTransaction;Type)
                    {
                    }
                    column(Text_CreditCardTransaction;Text)
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        if not IncludeCreditCardTransaction then
                          CurrReport.Break;
                    end;
                }
            }

            trigger OnPreDataItem()
            begin
                Clear(TotalAmountInclTax);
                Clear(POSStoreFilter);
                Clear(DateFilter);
                Clear(NoFilter);

                if GetFilter("POS Store Code") <> '' then
                  POSStoreFilter := StrSubstNo(POSStoreFilterCaption,GetFilter("POS Store Code"));

                if GetFilter("Entry Date") <> '' then
                  DateFilter := StrSubstNo(DateFilterCaption,GetFilter("Entry Date"));

                if POS_Sales_Line.GetFilter("No.") <> '' then
                  NoFilter := StrSubstNo(NoFilterCaption,POS_Sales_Line.GetFilter("No."));
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(IncludeCreditCardTransaction;IncludeCreditCardTransaction)
                    {
                        Caption = 'Include Credit Card Transaction';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        StoreCodeLabel = 'Store Code';
        TotalLabel = 'Total';
        EntryOverviewLabel = 'POS Entry Overview';
        PageLabel = 'Page %1 of %2';
    }

    var
        CustomerNoCaption: Label 'Customer No.';
        TotalAmountInclTax: Decimal;
        IncludeCreditCardTransaction: Boolean;
        NoText: Text;
        POSStoreFilter: Text;
        DateFilter: Text;
        NoFilter: Text;
        POSStoreFilterCaption: Label 'POS  Store Filter: %1';
        DateFilterCaption: Label 'Date Filter: %1';
        NoFilterCaption: Label 'No. Filter: %1';
}

