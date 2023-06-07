report 6014612 "NPR Inventory per Variant/date"
{
#if not BC17
    Extensible = false;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Inventory per Variant at date.rdlc';
    Caption = 'Inventory per Variant/Location';
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            CalcFields = "Net Change", "NPR Has Variants";
            DataItemTableView = sorting("No.") where("NPR Has Variants" = const(true));
            RequestFilterFields = "No.", "Vendor No.", "Item Category Code", "NPR Group sale", "Location Filter", "Date Filter";
            column(ShowLocation; ShowLocation) { }
            column(COMPANYNAME; CompanyName) { }
            column(CompanyInfoPicture; CompanyInfo.Picture) { }
            column(Itemfilter; ItemFilter) { }
            column(ItemNo; Item."No.") { }
            column(ItemDesc; Item.Description) { }
            column(ItemNetChange; "Net Change") { }
            column(ItemVendorItemNo; Item."Vendor Item No.") { }
            column(ItemUnitPrice; Item."Unit Price") { }
            column(ItemLastDirCost; Item."Last Direct Cost") { }
            column(CostValue; CostValue) { }
            column(SaleDate; Format(SaleDate)) { }
            column(Item_Profit; ItemProfit) { }
            column(Item_TotalProfit; ItemTotalProfit) { }
            column(Item_TotalNetChange; ItemTotalNetChange) { }
            column(Item_TotalInvValue; ItemTotalInvValue) { }

            dataitem(ItemVariant; "Item Variant")
            {
                DataItemLink = "Item No." = field("No.");
                DataItemTableView = sorting("Item No.", Code);
                column(ItemVarItemNo; ItemVariant."Item No.") { }
                column(ItemVarCode; ItemVariant.Code) { }
                column(ItemVarDescription; ItemVariant.Description) { }
                column(ItemVarNetChange; NetChangeItemVariant) { }
                column(ItemVarGross; ItemVariantProfit) { }
                column(ItemVarSaleDate; Format(SaleDateVariant)) { }
                column(SalesValueVariant; SalesValueVariant) { }
                column(CostValueVariant; CostValueVariant) { }

                dataitem(Location; Location)
                {
                    DataItemTableView = sorting(Code);
                    column(Location_Code; Code) { }
                    column(Location_Name; Name) { }
                    column(Location_NetChange; LocationNetChange) { }
                    column(Location_InventoryValue; Location2InventoryValue) { }
                    column(Location_Profit; LocationProfit) { }
                    column(Location_RecentSaleDate; Format(LocationRecentSaleDate)) { }

                    trigger OnPreDataItem()
                    begin
                        Location.SetFilter(Code, Item.GetFilter("Location Filter"));
                    end;

                    trigger OnAfterGetRecord()
                    var
                        Item2: Record Item;
                        LocationSalesValue: Decimal;
                    begin
                        Item2.Get(Item."No.");
                        Item2.CopyFilters(Item);
                        Item2.SetRange("Variant Filter", ItemVariant.Code);
                        Item2.SetRange("Location Filter", Location.Code);

                        Item2.CalcFields("Net Change");
                        if Item2."Net Change" = 0 then
                            CurrReport.Skip();

                        if Item2."Last Direct Cost" = 0 then
                            Item2."Last Direct Cost" := Item2."Unit Cost";
                        Location2InventoryValue := Item2."Net Change" * Item2."Last Direct Cost";

                        if Item2."Price Includes VAT" then begin
                            if VATPostingSetup.Get(Item2."VAT Bus. Posting Gr. (Price)", Item2."VAT Prod. Posting Group") then;
                            LocationSalesValue := Item2."Net Change" * (Item2."Unit Price" / (1 + (VATPostingSetup."VAT %" / 100)));
                        end else
                            LocationSalesValue := Item2."Net Change" * Item2."Unit Price";

                        LocationProfit := LocationSalesValue - Location2InventoryValue;
                        LocationNetChange := Item2."Net Change";

                        ItemLedgEntry.Reset();
                        ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type", "Posting Date", "Variant Code", "Location Code");
                        ItemLedgEntry.SetRange(ItemLedgEntry."Item No.", Item."No.");
                        ItemLedgEntry.SetRange("Variant Code", ItemVariant.Code);
                        ItemLedgEntry.SetRange("Location Code", Location.Code);
                        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Sale);
                        ItemLedgEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));

                        if ItemLedgEntry.FindLast() then
                            LocationRecentSaleDate := ItemLedgEntry."Posting Date"
                        else
                            LocationRecentSaleDate := 0D;
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    Item2: Record Item;
                begin
                    Item2.Get(Item."No.");
                    Item2.CopyFilters(Item);
                    Item2.SetRange("Variant Filter", Code);
                    Item2.CalcFields("Net Change");

                    if Item2."Net Change" = 0 then
                        CurrReport.Skip();

                    if Item2."Last Direct Cost" = 0 then
                        Item2."Last Direct Cost" := Item2."Unit Cost";
                    CostValueVariant := Item2."Net Change" * Item2."Last Direct Cost";
                    Item2."Unit Price" := Round(Item2."Unit Price", 0.01);
                    Item2."Last Direct Cost" := Round(Item2."Last Direct Cost", 0.01);

                    if Item2."Price Includes VAT" then begin
                        if VATPostingSetup.Get(Item2."VAT Bus. Posting Gr. (Price)", Item2."VAT Prod. Posting Group") then;
                        SalesValueVariant := Item2."Net Change" * (Item2."Unit Price" / (1 + (VATPostingSetup."VAT %" / 100)));
                    end else
                        SalesValueVariant := Item2."Net Change" * Item2."Unit Price";

                    ItemVariantProfit := SalesValueVariant - CostValueVariant;
                    NetChangeItemVariant := Item2."Net Change";

                    ItemLedgEntry.Reset();
                    ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type", "Posting Date", "Variant Code");
                    ItemLedgEntry.SetRange("Variant Code", ItemVariant.Code);
                    ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Sale);
                    ItemLedgEntry.SetRange(ItemLedgEntry."Item No.", Item."No.");
                    ItemLedgEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));

                    if ItemLedgEntry.FindLast() then
                        SaleDateVariant := ItemLedgEntry."Posting Date"
                    else
                        SaleDateVariant := 0D;
                end;
            }

            trigger OnPreDataItem()
            begin
                if HideNegativeInventoryItems then
                    Item.SetFilter("Net Change", '>0')
                else
                    if ShowOnlyNegativeInventoryItems then
                        Item.SetFilter("Net Change", '<0')
                    else
                        Item.SetFilter("Net Change", '<>0');
            end;

            trigger OnAfterGetRecord()
            begin
                if "Last Direct Cost" = 0 then
                    "Last Direct Cost" := "Unit Cost";
                CostValue := "Net Change" * "Last Direct Cost";

                if "Price Includes VAT" then begin
                    if VATPostingSetup.Get("VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group") then;
                    SalesValue := "Net Change" * ("Unit Price" / (1 + (VATPostingSetup."VAT %" / 100)));
                end else
                    SalesValue := "Net Change" * "Unit Price";

                ItemProfit := SalesValue - CostValue;

                ItemTotalProfit += ItemProfit;
                ItemTotalInvValue += CostValue;
                ItemTotalNetChange += "Net Change";

                ItemLedgEntry.Reset();
                ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type", "Posting Date");
                ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Sale);
                ItemLedgEntry.SetRange(ItemLedgEntry."Item No.", "No.");
                ItemLedgEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));

                if ItemLedgEntry.FindLast() then
                    SaleDate := ItemLedgEntry."Posting Date"
                else
                    SaleDate := 0D;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                field("Varer med beholdning"; ShowOnlyItemsWithInventory)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Show Only Items With Inventory';
                    ToolTip = 'Specifies the value of the Show Only Items With Inventory field';
                    Visible = false;
                }
                field("View Sales Price"; ViewSalesPrice)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'View Sales Prices';
                    ToolTip = 'Specifies the value of the View Sales Prices field';
                    Visible = false;
                }
                field("Negativ beh"; HideNegativeInventoryItems)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Hide Items With Negative Inventory';
                    ToolTip = 'Specifies the value of the Hide Items With Negative Inventory field';
                }
                field("Negativ Volume Show"; ShowOnlyNegativeInventoryItems)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Show Only Items With Negative Inventory';
                    ToolTip = 'Specifies the value of the Show Only Items With Negative Inventory field';
                }
                field("Show No Inventory"; ShowNoInventory)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Do not Show Inventory';
                    ToolTip = 'Specifies the value of the Do not Show Inventory field';
                    Visible = false;
                }
                field("Show Location"; ShowLocation)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Show Location';
                    ToolTip = 'Specifies the value of the Show Location field';
                }
                field("Show Blank Location"; ShowBlankLocation)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Show Blank Location';
                    ToolTip = 'Specifies the value of the Show Blank Location field';
                    Visible = false;
                }
            }
        }

    }

    labels
    {
        DescCaptionLbl = 'Description';
        ProfitCaptionLbl = 'Profit';
        NetChangeCaptionLbl = 'Inventory (Qty.)';
        InvValueCaptionLbl = 'Inventory Value';
        ReportCaptionLbl = 'Inventory per Variant/Location';
        DirCostCaptionLbl = 'Last Cost Price';
        LocationCaptionLbl = 'Location Code';
        NoCaptionLbl = 'No.';
        SalesDateCaptionLbl = 'Recent Sales';
        UnitPriceCaptionLbl = 'Sales Price';
        TotalCaptionLbl = 'Total';
        ItemVendorItemNoCaptionLbl = 'Vendor Item No.';
        DateCaptionLbl = 'Date';
        PageCaptionLbl = 'Page';
    }

    trigger OnInitReport()
    begin
        ShowLocation := true;
        ViewSalesPrice := true;
    end;

    trigger OnPreReport()
    begin
        if HideNegativeInventoryItems and ShowOnlyNegativeInventoryItems then
            Error(ChooseEitherErrLbl);

        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        ItemFilter := Item.GetFilters();
    end;

    var
        CompanyInfo: Record "Company Information";
        ItemLedgEntry: Record "Item Ledger Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        HideNegativeInventoryItems: Boolean;
        ShowBlankLocation: Boolean;
        ShowLocation: Boolean;
        ShowNoInventory: Boolean;
        ShowOnlyItemsWithInventory: Boolean;
        ShowOnlyNegativeInventoryItems: Boolean;
        ViewSalesPrice: Boolean;
        LocationRecentSaleDate: Date;
        SaleDate: Date;
        SaleDateVariant: Date;
        CostValue: Decimal;
        CostValueVariant: Decimal;
        ItemProfit: Decimal;
        ItemTotalInvValue: Decimal;
        ItemTotalNetChange: Decimal;
        ItemTotalProfit: Decimal;
        ItemVariantProfit: Decimal;
        Location2InventoryValue: Decimal;
        LocationNetChange: Decimal;
        LocationProfit: Decimal;
        NetChangeItemVariant: Decimal;
        SalesValue: Decimal;
        SalesValueVariant: Decimal;
        ChooseEitherErrLbl: Label 'Choose either option for showing only items with negative inventory or to hide them.';
        ItemFilter: Text;
}