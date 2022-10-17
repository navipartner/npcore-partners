report 6014402 "NPR Discount Statistics"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Discount Statistics.rdlc';
    Caption = 'Discount Statistics';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Date Filter", "Vendor No.";
            column(PageNoCaptionLbl; PageNoCaptionLbl)
            {
            }
            column(Report_Caption; Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Register_Filter_Caption; Register_Filter_Caption_Lbl)
            {
            }
            column(RegisterFilter; POSUnitFilter)
            {
            }
            column(Date_Filter_Caption; Date_Filter_Caption_Lbl)
            {
            }
            column(DateFilter; DateFilter)
            {
            }
            column(Item_No_Caption; Item_No_Caption_Lbl)
            {
            }
            column(ItemNoFilter; ItemNoFilter)
            {
            }
            column(Disc_Structure_Caption; Disc_Structure_Caption_Lbl)
            {
            }
            column(DiscountFilter; DiscountFilter)
            {
            }
            column(Salesperson_Filter_Caption; Salesperson_Filter_Caption_Lbl)
            {
            }
            column(SalesPersonFilter; SalesPersonFilter)
            {
            }
            column(Vendor_Filter_Caption; Vendor_Filter_Caption_Lbl)
            {
            }
            column(SupplierFilter; SupplierFilter)
            {
            }
            column(Description_Caption; Description_Caption_Lbl)
            {
            }
            column(Quantity_Caption; Quantity_Caption_Lbl)
            {
            }
            column(Sales_Amount_Caption; Sales_Amount_Caption_Lbl)
            {
            }
            column(Discount_Amount_Caption; Discount_Amount_Caption_Lbl)
            {
            }
            column(No_Item; Item."No.")
            {
            }
            column(Description_Item; Item.Description)
            {
            }
            column(Total_For_Item; Total_Caption_Lbl + ' ' + Item.Description)
            {
            }
            column(Total_Caption; Total_Caption_Lbl)
            {
            }
            column(ShowItemLedger; ShowItemLedger)
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                DataItemTableView = SORTING(Code);
                PrintOnlyIfDetail = true;
                RequestFilterFields = "Code";
                column(Code_Salesperson_Purchaser; "Salesperson/Purchaser".Code)
                {
                }
                column(Name_Salesperson_Purchaser; "Salesperson/Purchaser".Name)
                {
                }
                dataitem(ValueEntry; "Value Entry")
                {
                    DataItemLink = "Item No." = FIELD("No.");
                    DataItemLinkReference = Item;
                    DataItemTableView = SORTING("Item No.", "Posting Date", "Item Ledger Entry Type") WHERE("Item Ledger Entry Type" = CONST(Sale));
                    //TODO:Temporary Aux Value Entry Reimplementation
                    // RequestFilterFields = "NPR Discount Type";
                    column(Entry_No_Caption; Entry_No_Caption_Lbl)
                    {
                    }
                    column(Entry_No_Value_Entry; ValueEntry."Entry No.")
                    {
                    }
                    column(Invoiced_Quantity_Value_Entry; -(ValueEntry."Invoiced Quantity"))
                    {
                    }
                    column(Sales_Amount_Actual_Value_Entry; ValueEntry."Sales Amount (Actual)")
                    {
                    }
                    column(Discount_Amount_Value_Entry; ValueEntry."Discount Amount")
                    {
                    }
                    column(Posting_Date_Value_Entry; ValueEntry."Posting Date")
                    {
                    }
                    column(Document_Type_Value_Entry; ValueEntry."Document Type")
                    {
                    }
                    column(Saleperson_Code_Value_Entry; ValueEntry."Salespers./Purch. Code")
                    {
                    }
                    column(Total_VE_Qty; Total_VE_Qty)
                    {
                    }
                    column(Total_VE_Sales_Amt; Total_VE_Sales_Amt)
                    {
                    }
                    column(Total_VE_Discount_Amt; Total_VE_Discount_Amt)
                    {
                    }
                    //TODO:Temporary Aux Value Entry Reimplementation
                    // column(GroupSale; "NPR Group Sale")
                    column(GroupSale; TempAuxValueEntry)
                    {
                    }
                    dataitem("Value Entry"; "Value Entry")
                    {
                        DataItemLink = "Entry No." = FIELD("Entry No.");
                        DataItemLinkReference = ValueEntry;
                        column(Document_No_; "Document No.")
                        {
                        }
                    }
                    trigger OnAfterGetRecord()
                    begin
                        Total_VE_Qty += -(ValueEntry."Invoiced Quantity");
                        Total_VE_Sales_Amt += ValueEntry."Sales Amount (Actual)";
                        Total_VE_Discount_Amt += ValueEntry."Discount Amount";
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                        Item.CopyFilter("Date Filter", ValueEntry."Posting Date");
                        //TODO:Temporary Aux Value Entry Reimplementation
                        // Item.CopyFilter("Vendor No.", ValueEntry."NPR Vendor No.");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    Total_VE_Qty := 0;
                    Total_VE_Sales_Amt := 0;
                    Total_VE_Discount_Amt := 0;
                end;

                trigger OnPreDataItem()
                begin
                end;
            }

            trigger OnPreDataItem()
            begin
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Show Item Ledger"; ShowItemLedger)
                    {
                        Caption = 'Show Value Entries';
                        ToolTip = 'Specifies whether the value entries per item no. will be displayed in the report.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    labels
    {
        Salesperson = 'Salesperson:';
        Sales = 'Sales Amount';
        Discount = 'Discount Amount';
        SalespersonTotal = 'Total for Salesperson';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);

        SalesPersonFilter := "Salesperson/Purchaser".GetFilter(Code);
        DateFilter := Item.GetFilter("Date Filter");
        SupplierFilter := Item.GetFilter("Vendor No.");
        ItemNoFilter := Item.GetFilter("No.");
        //TODO:Temporary Aux Value Entry Reimplementation
        // DiscountFilter := ValueEntry.GetFilter("NPR Discount Type");
    end;

    var
        CompanyInformation: Record "Company Information";
        ShowItemLedger: Boolean;
        DateFilter: Text;
        DiscountFilter: Text;
        ItemNoFilter: Text;
        POSUnitFilter: Text;
        SalesPersonFilter: Text;
        SupplierFilter: Text;
        Total_VE_Discount_Amt: Decimal;
        Total_VE_Qty: Decimal;
        Total_VE_Sales_Amt: Decimal;
        Date_Filter_Caption_Lbl: Label 'Date Filter';
        Description_Caption_Lbl: Label 'Description';
        Disc_Structure_Caption_Lbl: Label 'Disc. Structure';
        Discount_Amount_Caption_Lbl: Label 'Discount Amount';
        Report_Caption_Lbl: Label 'Discount Sale Statistics';
        Entry_No_Caption_Lbl: Label 'Entry No.';
        Item_No_Caption_Lbl: Label 'Item No. Filter';
        CurrReportPageNoCaptionLbl: Label 'Page';
        PageNoCaptionLbl: Label 'Page';
        Quantity_Caption_Lbl: Label 'Quantity';
        Register_Filter_Caption_Lbl: Label 'Register Filter';
        Sales_Amount_Caption_Lbl: Label 'Sales Amount';
        Salesperson_Filter_Caption_Lbl: Label 'Salesperson/purchaser';
        Total_Caption_Lbl: Label 'Total';
        Vendor_Filter_Caption_Lbl: Label 'Vendor filter';
        //TODO:Temporary Aux Value Entry Reimplementation
        TempAuxValueEntry:Integer;
}

