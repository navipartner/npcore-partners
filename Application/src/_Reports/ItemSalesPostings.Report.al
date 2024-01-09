report 6014439 "NPR Item Sales Postings"
{
#if not BC17
    Extensible = false;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Sales Postings.rdlc';
    Caption = 'Item Sales Postings';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    UseSystemPrinter = true;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ItemDT; Item)
        {
            CalcFields = "Positive Adjmt. (LCY)", Inventory;
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Date Filter", "Item Category Code", "Vendor No.";
            UseTemporary = true;
        }

        dataitem(ReportDT; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = filter(1 ..));

            column(COMPANYNAME; CompanyName) { }
            column(ItemFilters; (Pct1Lbl + ' ' + ItemFilter)) { }
            column(DimFilters; ItemDT.GetFilter("Global Dimension 1 Code")) { }
            column(Item_No; ItemSalesPostings.ItemNo) { }
            column(Item_Description; Item.Description) { }
            column(Item_VendorNo; Item."Vendor No.") { }
            column(Item_VendorItemNo; Item."Vendor Item No.") { }
            column(Item_DiscountAmount; ItemSalesPostings.DiscountAmount) { }
            column(Item_SalesQty; ItemSalesPostings.SalesQty) { }
            column(Item_SalesLCY; ItemSalesPostings.SalesLCY) { }
            column(Item_CostAmountNonInvtbl; ItemSalesPostings.CostAmountNonInvtbl) { }
            column(Item_UnitPrice; Item.CalcUnitPriceExclVAT()) { }
            column(Item_UnitCost; Item."Unit Cost") { }
            column(Item_SalesUnitPrice; Item.CalcUnitPriceExclVAT() * ItemSalesPostings.SalesQty) { }
            column(Item_Inventory; Item.Inventory) { }
            column(Item_Profit; Profit) { }
            column(Item_ProfitPct; ItemProfitPct) { }

            trigger OnPreDataItem()
            begin
                if ItemDT.GetFilter("No.") <> '' then
                    ItemSalesPostings.SetFilter(ItemNo, ItemDT.GetFilter("No."));
                if ItemDT.GetFilter("Vendor No.") <> '' then
                    ItemSalesPostings.SetFilter(Item_VendorNo, ItemDT.GetFilter("Vendor No."));
                if ItemDT.GetFilter("Item Category Code") <> '' then
                    ItemSalesPostings.SetFilter(Item_ItemCategoryCode, ItemDT.GetFilter("Item Category Code"));
                if ItemDT.GetFilter("Global Dimension 1 Code") <> '' then
                    ItemSalesPostings.SetFilter(GlobalDimension1Code, ItemDT.GetFilter("Global Dimension 1 Code"));
                if ItemDT.GetFilter("Global Dimension 2 Code") <> '' then
                    ItemSalesPostings.SetFilter(GlobalDimension2Code, ItemDT.GetFilter("Global Dimension 2 Code"));
                if ItemDT.GetFilter("Location Filter") <> '' then
                    ItemSalesPostings.SetFilter(LocationCode, ItemDT.GetFilter("Location Filter"));
                if ItemDT.GetFilter("Date Filter") <> '' then
                    ItemSalesPostings.SetFilter(PostingDate, ItemDT.GetFilter("Date Filter"));

                ItemSalesPostings.Open();
            end;

            trigger OnAfterGetRecord()
            var
                ItemCOG: Decimal;
            begin
                if not ItemSalesPostings.Read() then
                    CurrReport.Break();

                Item.SetAutoCalcFields(Inventory, "Positive Adjmt. (LCY)");

                if not Item.Get(ItemSalesPostings.ItemNo) then
                    CurrReport.Skip();


                Clear(Profit);
                Clear(ItemProfitPct);

                if Item.Type = Item.Type::Service then
                    ItemCOG := ItemSalesPostings.CostAmountNonInvtbl
                else
                    ItemCOG := Item."Positive Adjmt. (LCY)";

                Profit := ItemSalesPostings.SalesLCY - Abs(ItemCOG);

                if ItemSalesPostings.SalesLCY <> 0 then
                    ItemProfitPct := Round(Profit / ItemSalesPostings.SalesLCY, 0.1)
                else
                    ItemProfitPct := 0;
            end;

            trigger OnPostDataItem()
            begin
                ItemSalesPostings.Close();
            end;
        }
    }

    labels
    {
        ReportCaptionLbl = 'Item Sales Postings';
        NoCaptionLbl = 'No.';
        DescriptionCaptionLbl = 'Description';
        PageCaptionLbl = 'Page';
        UnitPriceCaptionLbl = 'Unit price';
        SalesQtyCaptionLbl = 'Sales (Qty.)';
        SalesAmtActualCaptionLbl = 'Sales amount (Actual)';
        ProfitCaptionLbl = 'Profit (LCY)';
        ProfitPctCaptionLbl = 'Profit %';
        TotalCaptionLbl = 'Total';
        VendorItemNoCaptionLbl = 'Vendor Item No.';
        VendorNoCaptionLbl = 'Vendor No.';
        InventoryCaptionLbl = 'Inventory';
        UnitCostCaptionLbl = 'Unit Cost';
        SalesUnitPriceCaptionLbl = 'Sales (Unit Price)';
        DiscountAmountCaptionLbl = 'Discount Amount';
        OfCaptionLbl = 'of';
    }

    trigger OnPreReport()
    begin
        ItemFilter := CopyStr(ItemDT.GetFilters(), 1, MaxStrLen(ItemFilter));
    end;

    var
        ItemSalesPostings: Query "NPR Item Sales Postings";
        Item: Record Item;
        ItemProfitPct: Decimal;
        Profit: Decimal;
        Pct1Lbl: Label 'Item Filter:', Locked = true;
        ItemFilter: Text;
}