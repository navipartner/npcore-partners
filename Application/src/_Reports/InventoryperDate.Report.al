report 6014417 "NPR Inventory per Date"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Inventory per Date.rdlc';
    Caption = 'Inventory per Date';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            CalcFields = "Net Change";
            RequestFilterFields = "No.", "Vendor No.", "Item Category Code", "NPR Group sale";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CalcMethod; CalcMethod)
            {
            }
            column(No_Item; Item."No.")
            {
                IncludeCaption = true;
            }
            column(Description_Item; Item.Description)
            {
            }
            column(UnitCost_Item; Item."Unit Cost")
            {
            }
            column(VendorItemNo_Item; Item."Vendor Item No.")
            {
            }
            column(NetChange_Item; Item."Net Change")
            {
            }
            column(UnitPrice_Item; Item."Unit Price")
            {
            }
            column(LastDirectCost_Item; Item."Last Direct Cost")
            {
                IncludeCaption = true;
            }
            column(CostValuation; CostValuation)
            {
            }
            column(GrossAvg; GrossAvg)
            {
            }
            column(ActualSales; ActualSales)
            {
            }
            column(LatestSalesDate; LatestSalesDate)
            {
            }
            column(Itemfilter; Itemfilter)
            {
            }
            column(EndDate; EndDate)
            {
            }
            column(ItemGroup_Item; Item."Item Category Code")
            {
                IncludeCaption = true;
            }
            column(GroupByItemGroup; GroupByItemGroup)
            {
            }
            column(LatestPurchaseDate_ItemLedgerEntry; LatestPurchaseDate)
            {
            }

            trigger OnAfterGetRecord()
            var
                ChooseErr: Label 'Choose either';
            begin
                if IncludeItemStock then begin
                    if not ("Net Change" <> 0) then
                        CurrReport.Skip();
                end;

                if ShowItemNegativeInventory and not NegativVolumeShow then begin
                    if ("Net Change" < 0) then
                        CurrReport.Skip();
                end
                else
                    if NegativVolumeShow and not ShowItemNegativeInventory then begin
                        if ("Net Change" >= 0) then
                            CurrReport.Skip();
                    end
                    else
                        if ShowZeroInventory then begin
                            if "Net Change" <> 0 then
                                CurrReport.Skip();
                        end
                        else
                            if ShowItemNegativeInventory and NegativVolumeShow then begin
                                Error(ChooseErr);
                            end;

                if ShowNoInventory then Item."Net Change" := 0;

                case SelectCalcMethod of
                    SelectCalcMethod::"Sidste Kostpris":
                        begin
                            CostValuation := ("Net Change" * "Last Direct Cost");
                            CalcMethod := LastDirectCostLbl;
                            "Last Direct Cost" := Round("Last Direct Cost", 0.01);
                        end;
                    SelectCalcMethod::Kostpris:
                        begin
                            CostValuation := ("Net Change" * "Unit Cost");
                            CalcMethod := UnitCostLbl;
                            "Last Direct Cost" := Round("Unit Cost", 0.01);
                        end;
                end;

                "Unit Price" := Round("Unit Price", 0.01);

                Clear(ItemLedgerEntry);
                // Find latest sales
                ItemLedgerEntry.SetCurrentKey("Item No.", "Entry Type", "Posting Date");
                ItemLedgerEntry.SetFilter("Entry Type", '%1', 1);
                ItemLedgerEntry.SetFilter("Item No.", '%1', "No.");
                LatestSalesDate := 0D;
                if ItemLedgerEntry.Find('+') then
                    LatestSalesDate := ItemLedgerEntry."Posting Date";

                Clear(ItemLedgerEntry);
                ItemLedgerEntry.SetView('SORTING(Posting Date) ORDER(DESCENDING)');
                ItemLedgerEntry.SetCurrentKey("Item No.", "Entry Type", "Posting Date");
                ItemLedgerEntry.SetFilter("Item No.", '=%1', "No.");
                ItemLedgerEntry.SetFilter("Entry Type", '=%1', ItemLedgerEntry."Entry Type"::Purchase);
                LatestPurchaseDate := 0D;
                if ItemLedgerEntry.FindFirst() then
                    LatestPurchaseDate := ItemLedgerEntry."Posting Date";

                // If prices include VAT
                if "Price Includes VAT" then begin
                    if VATPostingSetup.Get("VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group") then;
                    ActualSales := "Net Change" * ("Unit Price" / (1 + (VATPostingSetup."VAT %" / 100)));
                end else
                    ActualSales := "Net Change" * "Unit Price";


                if ActualSales <> 0 then
                    GrossAvg := 100 * (ActualSales - CostValuation) / ActualSales
                else
                    GrossAvg := 0;

                if NotUnitPrice then
                    "Unit Price" := 0;
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Date Filter", DMY2Date(1, 1, 1980), EndDate);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("End Date"; EndDate)
                {
                    Caption = 'Date';

                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Include Item Stock"; IncludeItemStock)
                {
                    Caption = 'Show only products with inventory';

                    ToolTip = 'Specifies the value of the Show only products with inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Not Unit Price"; NotUnitPrice)
                {
                    Caption = 'Do not display prices';

                    ToolTip = 'Specifies the value of the Do not display prices field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Item Negative Inventory"; ShowItemNegativeInventory)
                {
                    Caption = 'Do not display items with negative inventory';

                    ToolTip = 'Specifies the value of the Do not display items with negative inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Negativ Volume Show"; NegativVolumeShow)
                {
                    Caption = 'Show only items with negativ volume';

                    ToolTip = 'Specifies the value of the Show only items with negativ volume field';
                    ApplicationArea = NPRRetail;
                }
                field("Show No Inventory"; ShowNoInventory)
                {
                    Caption = 'Do not show inventory';

                    ToolTip = 'Specifies the value of the Do not show inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Zero Inventory"; ShowZeroInventory)
                {
                    Caption = 'Show only 0 quantity inventory';

                    ToolTip = 'Specifies the value of the Show only 0 quantity inventory field';
                    ApplicationArea = NPRRetail;
                }
                field("Choose Calc. Method"; SelectCalcMethod)
                {
                    Caption = 'Choose Calc. Method';
                    OptionCaption = 'Last Direct Cost Price,Cost Price';

                    ToolTip = 'Specifies the value of the Choose Calc. Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Group By Item Group"; GroupByItemGroup)
                {
                    Caption = 'Sort items by item group';

                    ToolTip = 'Specifies the value of the Sort items by item group field';
                    ApplicationArea = NPRRetail;
                }
            }
        }

    }

    labels
    {
        Report_Caption = 'Inventory per Date';
        No_Caption = 'No.';
        Description_Caption = 'Description';
        VendorItemNo_Caption = 'Vend. Item No.';
        Inventory_Caption = 'Inventory';
        UnitPrice_Caption = 'Unit Price';
        InvValue_Caption = 'Inv. Value';
        TotalProfit_Caption = 'Total Profit';
        RecentSale_Caption = 'Recent Sale';
        Total_Caption = 'Total';
        PerDate_Caption = 'Per Date';
        Footer_Caption = 'ˆNAVIPARTNER K¢benhavn 2002';
        LastPurchaseDate_Caption = 'Last Purchase Date';
        LastCostPrice_Caption = 'Last Cost Price';
        SalesPrice_Caption = 'Sales Price';
    }

    trigger OnInitReport()
    begin
        EndDate := Today();
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        if EndDate = 0D then
            Error(DateErr);

        Itemfilter := Item.GetFilters;
    end;

    var
        CompanyInfo: Record "Company Information";
        ItemLedgerEntry: Record "Item Ledger Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        GroupByItemGroup: Boolean;
        IncludeItemStock: Boolean;
        NegativVolumeShow: Boolean;
        NotUnitPrice: Boolean;
        ShowItemNegativeInventory: Boolean;
        ShowNoInventory: Boolean;
        ShowZeroInventory: Boolean;
        EndDate: Date;
        LatestPurchaseDate: Date;
        LatestSalesDate: Date;
        ActualSales: Decimal;
        CostValuation: Decimal;
        GrossAvg: Decimal;
        DateErr: Label 'Date has to be filled';
        LastDirectCostLbl: Label 'Last Direct Cost';
        UnitCostLbl: Label 'Unit cost';
        SelectCalcMethod: Option "Sidste Kostpris",Kostpris;
        CalcMethod: Text[50];
        Itemfilter: Text;
}

