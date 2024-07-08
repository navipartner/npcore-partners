report 6014540 "NPR Items With Low Sales"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Items With Low Sales.rdlc';
    Caption = 'Items With Low Sales';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "Inventory Posting Group", "Item Category Code", "Vendor No.";

            trigger OnAfterGetRecord()
            begin
                DialogBox.Update(1, "No.");

                CalcFields("Sales (LCY)", "Sales (Qty.)");
                if ("Sales (Qty.)" <= 0) and not ShowNotSold then
                    CurrReport.Skip();
                if ("Sales (LCY)" = 0) and not ShowNotSold then
                    CurrReport.Skip();

                TempItemAmount.Init();
                TempItemAmount."Item No." := "No.";
                TempItemAmount.Amount := "Sales (LCY)";
                TempItemAmount."Amount 2" := "Sales (Qty.)";
                TempItemAmount.Insert();
                if (RankQty = 0) or (i < RankQty) then
                    i := i + 1
                else begin
                    TempItemAmount.FindLast();
                    TempItemAmount.Delete();
                end;
                ItemSalesAmt += "Sales (LCY)";
            end;

            trigger OnPreDataItem()
            var
                ItemAllSale: record Item;
            begin
                if (PeriodStartDate = 0D) or (PeriodEndDate = 0D) then
                    Error(TextInputDate);

                Item.SetRange("Date Filter", PeriodStartDate, PeriodEndDate);
                DialogBox.Open(Text001);
                TempItemAmount.DeleteAll();
                i := 0;

                ItemAllSale.SetRange("Date Filter", PeriodStartDate, PeriodEndDate);
                ItemAllSale.CalcFields(ItemAllSale."Sales (LCY)");
                ItemSalesAmt := ItemAllSale."Sales (LCY)";
            end;

        }
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = FILTER(1 ..));
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Text002___ItemDateFilter; ItemDateFilter)
            {
            }
            column(AplyedFilters; AppliedFilters)
            {
            }
            column(Text004; Text004)
            {
            }
            column(txtShowNotSold; TxtShowNotSold)
            {
            }
            column(Item__Vendor_Item_No__; Item."Vendor Item No.")
            {
            }
            column(Item__Sales__LCY__; Item."Sales (LCY)")
            {
            }
            column(Item__Base_Unit_of_Measure_; Item."Base Unit of Measure")
            {
            }
            column(Item__Sales__Qty___; Item."Sales (Qty.)")
            {
            }
            column(Item_Description; Item.Description)
            {
            }
            column(Item__No__; Item."No.")
            {
            }
            column(Integer_Number; Number)
            {
            }
            column(ItemDateFilter; ItemDateFilter)
            {
            }
            column(ShowNotSold; ShowNotSold)
            {
            }
            column(Item__Sales__LCY___Control25; Item."Sales (LCY)")
            {
            }
            column(ItemSalesAmt_; ItemSalesAmt)
            {
            }
            column(txtTotal; TxtTotal)
            {
            }
            column(txtTotalSales_; TxtTotalSales)
            {
            }
            column(txtPctTotalSales_; TxtPctTotalSales)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(Vendors_item_no_Caption; Vendors_item_no_CaptionLbl)
            {
            }
            column(txtSalesLCYCaption; TxtSalesLCYCaptionLbl)
            {
            }
            column(txtSalesQuantityCaption; TxtSalesQuantityCaptionLbl)
            {
            }
            column(Item_descriptionCaption; Item_descriptionCaptionLbl)
            {
            }
            column(txtItemNoCaption; TxtItemNoCaptionLbl)
            {
            }
            column(txtRankCaption; TxtRankCaptionLbl)
            {
            }
            column(UnitOfMeasureCaption; UnitOfMeasureLbl)
            {
            }
            trigger OnAfterGetRecord()
            begin
                if Number = 1 then begin
                    if not TempItemAmount.FindFirst() then
                        CurrReport.Break();
                end else begin
                    if TempItemAmount.Next() = 0 then
                        CurrReport.Break();
                end;

                Item.Get(TempItemAmount."Item No.");
                Item.CalcFields("Sales (LCY)", "Sales (Qty.)");
            end;

            trigger OnPreDataItem()
            begin
                DialogBox.Close();
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
                    field("Rank Qty"; RankQty)
                    {
                        Caption = 'Rank Quantity';

                        ToolTip = 'Specifies how many low sales items will be displayed.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Period Start Date"; PeriodStartDate)
                    {
                        Caption = 'Start Period';

                        ToolTip = 'Specifies the start date for the period.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Period End Date"; PeriodEndDate)
                    {
                        Caption = 'End Period';

                        ToolTip = 'Specifies the end date for the period.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Not Sold"; ShowNotSold)
                    {
                        Caption = 'Include Items Not On Inventory Or Not Sold';

                        ToolTip = 'Displays items not on inventory or items that are not sold.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

    }

    trigger OnInitReport()
    begin
        RankQty := 10;
        PeriodStartDate := CalcDate(TxtFirstCM, Today);
        PeriodEndDate := CalcDate(TxtLastCM, Today);
    end;

    trigger OnPreReport()
    begin
        AppliedFilters := Item.GetFilters;
        ItemDateFilter := Text002 + ' ' + Format(PeriodStartDate) + '..' + Format(PeriodEndDate);
    end;

    var
        TempItemAmount: Record "Item Amount" temporary;
        ShowNotSold: Boolean;
        PeriodEndDate: Date;
        PeriodStartDate: Date;
        ItemSalesAmt: Decimal;
        DialogBox: Dialog;
        i: Integer;
        RankQty: Integer;
        TxtPctTotalSales: Label '% of Total Sales';
        TxtLastCM: Label '<CM>';
        TxtFirstCM: Label '<-CM>';
        Text001: Label 'Grouping Items   #1##########';
        Item_descriptionCaptionLbl: Label 'Item Description';
        TxtItemNoCaptionLbl: Label 'Item No.';
        TxtShowNotSold: Label 'Item not sold or with no inventory are included.';
        Text004: Label 'Items With Low Sales';
        PageCaptionLbl: Label 'Page';
        Text002: Label 'Period: ';
        TextInputDate: Label 'Please fill Period Start Date and Period Closing Date';
        TxtRankCaptionLbl: Label 'Rank';
        TxtSalesLCYCaptionLbl: Label 'Sales (LCY)';
        TxtSalesQuantityCaptionLbl: Label 'Sales Quantity';
        TxtTotal: Label 'Total';
        TxtTotalSales: Label 'Total Sales';
        Vendors_item_no_CaptionLbl: Label 'Vendors Item No.:';
        ItemDateFilter: Text;
        UnitOfMeasureLbl: Label 'Unit of Measure';
        AppliedFilters: Text;
}

