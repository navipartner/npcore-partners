report 6014402 "Discount Statistics"
{
    // NPR7.000.000 LS, 05-11-12, CASE:144111 : Convert Report to Nav 2013
    // NPR5.38/JLK /20180124  CASE 300892 Corrected AL Error on Caption name
    //                                    Obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.49/BHR /20190115  CASE 341969 Corrections as per OMA Guidelines
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Discount Statistics.rdlc';

    Caption = 'Discount Statistics';
    UsageCategory = ReportsAndAnalysis;
    UseSystemPrinter = true;

    dataset
    {
        dataitem(Item;Item)
        {
            DataItemTableView = SORTING("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.","Date Filter","Vendor No.";
            column(PageNoCaptionLbl;PageNoCaptionLbl)
            {
            }
            column(Report_Caption;Report_Caption_Lbl)
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(Register_Filter_Caption;Register_Filter_Caption_Lbl)
            {
            }
            column(RegisterFilter;RegisterFilter)
            {
            }
            column(Date_Filter_Caption;Date_Filter_Caption_Lbl)
            {
            }
            column(DateFilter;DateFilter)
            {
            }
            column(Item_No_Caption;Item_No_Caption_Lbl)
            {
            }
            column(ItemNoFilter;ItemNoFilter)
            {
            }
            column(Disc_Structure_Caption;Disc_Structure_Caption_Lbl)
            {
            }
            column(DiscountFilter;DiscountFilter)
            {
            }
            column(Salesperson_Filter_Caption;Salesperson_Filter_Caption_Lbl)
            {
            }
            column(SalesPersonFilter;SalesPersonFilter)
            {
            }
            column(Vendor_Filter_Caption;Vendor_Filter_Caption_Lbl)
            {
            }
            column(SupplierFilter;SupplierFilter)
            {
            }
            column(Description_Caption;Description_Caption_Lbl)
            {
            }
            column(Quantity_Caption;Quantity_Caption_Lbl)
            {
            }
            column(Sales_Amount_Caption;Sales_Amount_Caption_Lbl)
            {
            }
            column(Discount_Amount_Caption;Discount_Amount_Caption_Lbl)
            {
            }
            column(No_Item;Item."No.")
            {
            }
            column(Description_Item;Item.Description)
            {
            }
            column(Total_For_Item;Total_Caption_Lbl+ ' '+Item.Description)
            {
            }
            column(Total_Caption;Total_Caption_Lbl)
            {
            }
            column(ShowItemLedger;ShowItemLedger)
            {
            }
            dataitem("Salesperson/Purchaser";"Salesperson/Purchaser")
            {
                DataItemTableView = SORTING(Code);
                PrintOnlyIfDetail = true;
                RequestFilterFields = "Code";
                column(Code_Salesperson_Purchaser;"Salesperson/Purchaser".Code)
                {
                }
                column(Name_Salesperson_Purchaser;"Salesperson/Purchaser".Name)
                {
                }
                dataitem("Value Entry";"Value Entry")
                {
                    DataItemLink = "Item No."=FIELD("No.");
                    DataItemLinkReference = Item;
                    DataItemTableView = SORTING("Group Sale","Posting Date","Salespers./Purch. Code","Item Ledger Entry Type") WHERE("Item Ledger Entry Type"=CONST(Sale));
                    RequestFilterFields = "Discount Type","Register No.";
                    column(Entry_No_Caption;Entry_No_Caption_Lbl)
                    {
                    }
                    column(Entry_No_Value_Entry;"Value Entry"."Entry No.")
                    {
                    }
                    column(Invoiced_Quantity_Value_Entry;-("Value Entry"."Invoiced Quantity"))
                    {
                    }
                    column(Sales_Amount_Actual_Value_Entry;"Value Entry"."Sales Amount (Actual)")
                    {
                    }
                    column(Discount_Amount_Value_Entry;"Value Entry"."Discount Amount")
                    {
                    }
                    column(Posting_Date_Value_Entry;"Value Entry"."Posting Date")
                    {
                    }
                    column(Document_Type_Value_Entry;"Value Entry"."Document Type")
                    {
                    }
                    column(Saleperson_Code_Value_Entry;"Value Entry"."Salespers./Purch. Code")
                    {
                    }
                    column(Total_VE_Qty;Total_VE_Qty)
                    {
                    }
                    column(Total_VE_Sales_Amt;Total_VE_Sales_Amt)
                    {
                    }
                    column(Total_VE_Discount_Amt;Total_VE_Discount_Amt)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Total_VE_Qty += -("Value Entry"."Invoiced Quantity");
                        Total_VE_Sales_Amt += "Value Entry"."Sales Amount (Actual)";
                        Total_VE_Discount_Amt += "Value Entry"."Discount Amount";
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Salespers./Purch. Code", "Salesperson/Purchaser".Code);
                        Item.CopyFilter("Date Filter", "Value Entry"."Posting Date");
                        Item.CopyFilter("Vendor No.","Value Entry"."Vendor No.");
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
                    //-NPR5.39
                    //CurrReport.CREATETOTALS("Value Entry"."Discount Amount", "Value Entry"."Sales Amount (Actual)","Value Entry"."Invoiced Quantity");
                    //+NPR5.39
                end;
            }

            trigger OnPreDataItem()
            begin
                //-NPR5.39
                //CurrReport.CREATETOTALS("Value Entry"."Discount Amount", "Value Entry"."Sales Amount (Actual)","Value Entry"."Invoiced Quantity");
                //+NPR5.39
            end;
        }
        dataitem("Salesperson/Purchaser 2";"Salesperson/Purchaser")
        {
            DataItemTableView = SORTING(Code);
            PrintOnlyIfDetail = false;
            column(Code_Salesperson_Purchaser_2;"Salesperson/Purchaser 2".Code)
            {
            }
            column(Name_Salesperson_Purchaser_2;"Salesperson/Purchaser 2".Name)
            {
            }
            column(Sales_LCY_Salesperson_Purchaser_2;"Salesperson/Purchaser 2"."Sales (LCY)")
            {
            }
            column(Discount_Amount_Salesperson_Purchaser_2;"Salesperson/Purchaser 2"."Discount Amount")
            {
            }
            column(Salesperson_Caption;Salesperson_Caption_Lbl)
            {
            }
            column(Total_Salesperson_Caption;Total_Salesperson_Caption_Lbl)
            {
            }

            trigger OnPreDataItem()
            begin
                Item.CopyFilter("Date Filter", "Salesperson/Purchaser 2"."Date Filter");
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
                    field(ShowItemLedger;ShowItemLedger)
                    {
                        Caption = 'Show Value Entries';
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
        Salesperson = 'Salesperson:';
        Sales = 'Sales Amount';
        Discount = 'Discount Amount';
        SalespersonTotal = 'Total for Salesperson';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get;
        CompanyInformation.CalcFields(Picture);

        SalesPersonFilter := "Salesperson/Purchaser".GetFilter(Code);
        RegisterFilter := "Value Entry".GetFilter("Register No.");
        DateFilter := Item.GetFilter("Date Filter");
        SupplierFilter := Item.GetFilter("Vendor No.");
        ItemNoFilter := Item.GetFilter("No.");
        DiscountFilter := "Value Entry".GetFilter("Discount Type");

        //-NPR5.39
        // Object.SETRANGE(ID, 6014402);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39
    end;

    var
        CompanyInformation: Record "Company Information";
        RegisterFilter: Code[50];
        DateFilter: Code[50];
        ItemNoFilter: Code[50];
        DiscountFilter: Code[50];
        SalesPersonFilter: Code[50];
        ShowItemLedger: Boolean;
        SupplierFilter: Code[50];
        PageNoCaptionLbl: Label 'Page';
        Report_Caption_Lbl: Label 'Discount Sale Statistics';
        Register_Filter_Caption_Lbl: Label 'Register Filter';
        Date_Filter_Caption_Lbl: Label 'Date Filter';
        Item_No_Caption_Lbl: Label 'Item No. Filter';
        Disc_Structure_Caption_Lbl: Label 'Disc. Structure';
        Salesperson_Filter_Caption_Lbl: Label 'Salesperson/purchaser';
        Vendor_Filter_Caption_Lbl: Label 'Vendor filter';
        Description_Caption_Lbl: Label 'Description';
        Quantity_Caption_Lbl: Label 'Quantity';
        Sales_Amount_Caption_Lbl: Label 'Sales Amount';
        Discount_Amount_Caption_Lbl: Label 'Discount Amount';
        Entry_No_Caption_Lbl: Label 'Entry No.';
        Total_Caption_Lbl: Label 'Total';
        Salesperson_Caption_Lbl: Label 'Salesperson:';
        Total_Salesperson_Caption_Lbl: Label 'Total for Salesperson';
        Total_VE_Qty: Decimal;
        Total_VE_Sales_Amt: Decimal;
        Total_VE_Discount_Amt: Decimal;
}

