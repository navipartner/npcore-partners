report 6014417 "NPR Inventory per Date"
{
    // NPR70.00.00.00/LS/19-07-2013 CASE 159375  : Conversion of report to NAV 2013
    // NPR4.04/TR/20150330  CASE 208265 Option value SelectCalcMethod did not work descently. This has been corrected.
    // NPR4.10/KN/20150511 CASE  213056  Condition for showing zero qty inventory changed
    //                                   Changed expression of total profits field in report layout to avoid print of #ERROR
    // NPR4.15/KN/20150910 CASE 221390   Added posibility in req page to sort items by Item Group (controlled by expression in sorting property in Details-group)
    //                                   Added "Item Group"-group as parent to "Details" in layout
    // NPR5.23/JDH /20160512 CASE 240916 Removed old color size solution from req filters
    // NPR5.23/KN/20160609 CASE 243968 Increased width of "Vendor Item No." field and decreased width of "No." field
    // NPR5.36/KENU/20170919 CASE 290588 Added header "Last Direct Cost" and "Recent Purchase" column
    // NPR5.38/JLK /20180124  CASE 300892 Removed AL Error on obsolite property CurrReport_PAGENO
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.40/TJ  /20180319  CASE 307717 Replaced hardcoded dates with DMY2DATE structure
    // NPR5.51/ANPA/20190712  CASE 361236 The headlines have been changed so that they carry on to the next page
    // NPR5.53/TILA/20191003 CASE 371374 Layout update - EAN no. column expanded
    // NPR5.53/TILA/20191022 CASE 371374 Layout update - Expanded description column, removed "Last Inv. Cost" and "Total Profit" columns
    // NPR5.54/YAHA/20200309 CASE 394927 Added Last Direct Cost
    // NPR5.54/YAHA/20200309 CASE 394927 Added Sales Price caption and changed remove unit price labal to be replaced by Sales Price
    // NPR5.54/ANPA/20200326  CASE 384505 Changed labels such that there is a danish caption for 'Last Cost Price' and 'Sales Price' and made it possible to select SelectCaltMethod.
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Inventory per Date.rdlc';

    Caption = 'Inventory per Date';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            CalcFields = "Net Change";
            DataItemTableView = SORTING("NPR Primary Key Length");
            RequestFilterFields = "No.", "Vendor No.", "NPR Item Group", "NPR Group sale";
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
            column(ItemGroup_Item; Item."NPR Item Group")
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
            begin
                if IncludeItemStock then begin
                    if not ("Net Change" <> 0) then
                        CurrReport.Skip;
                end;

                if ShowItemNegativeInventory and not NegativVolumeShow then begin
                    if ("Net Change" < 0) then
                        CurrReport.Skip;
                end
                else
                    if NegativVolumeShow and not ShowItemNegativeInventory then begin
                        if ("Net Change" >= 0) then
                            CurrReport.Skip;
                    end
                    else
                        if ShowZeroInventory then begin
                            //-NPR4.10
                            //  IF "Net Change" = 0 THEN
                            if "Net Change" <> 0 then
                                //+NPR4.10
                                CurrReport.Skip;
                        end
                        else
                            if ShowItemNegativeInventory and NegativVolumeShow then begin
                                Error('Choose either');
                            end;

                if ShowNoInventory then Item."Net Change" := 0;

                case SelectCalcMethod of
                    SelectCalcMethod::"Sidste Kostpris":
                        begin
                            CostValuation := ("Net Change" * "Last Direct Cost");
                            CalcMethod := Text001;
                            "Last Direct Cost" := Round("Last Direct Cost", 0.01);
                        end;
                    SelectCalcMethod::Kostpris:
                        begin
                            CostValuation := ("Net Change" * "Unit Cost");
                            CalcMethod := Text002;
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
                if ItemLedgerEntry.FindFirst then
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

                //-NPR70.00.00.00
                if NotUnitPrice then
                    "Unit Price" := 0;
                //+NPR70.00.00.00
            end;

            trigger OnPreDataItem()
            begin
                //-NPR5.39
                //CurrReport.CREATETOTALS(CostValuation, ActualSales);
                //+NPR5.39
                //-NPR5.40 [307717]
                //SETRANGE("Date Filter", 010180D, EndDate);
                SetRange("Date Filter", DMY2Date(1, 1, 1980), EndDate);
                //+NPR5.40 [307717]
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(EndDate; EndDate)
                {
                    Caption = 'Date';
                    ApplicationArea = All;
                }
                field(IncludeItemStock; IncludeItemStock)
                {
                    Caption = 'Show only products with inventory';
                    ApplicationArea = All;
                }
                field(NotUnitPrice; NotUnitPrice)
                {
                    Caption = 'Do not display prices';
                    ApplicationArea = All;
                }
                field(ShowItemNegativeInventory; ShowItemNegativeInventory)
                {
                    Caption = 'Do not display items with negative inventory';
                    ApplicationArea = All;
                }
                field(NegativVolumeShow; NegativVolumeShow)
                {
                    Caption = 'Show only items with negativ volume';
                    ApplicationArea = All;
                }
                field(ShowNoInventory; ShowNoInventory)
                {
                    Caption = 'Do not show inventory';
                    ApplicationArea = All;
                }
                field(ShowZeroInventory; ShowZeroInventory)
                {
                    Caption = 'Show only 0 quantity inventory';
                    ApplicationArea = All;
                }
                field("Choose Calc. Method"; SelectCalcMethod)
                {
                    Caption = 'Choose Calc. Method';
                    OptionCaption = 'Last Direct Cost Price,Cost Price';
                    ApplicationArea = All;
                }
                field(GroupByItemGroup; GroupByItemGroup)
                {
                    Caption = 'Sort items by item group';
                    ApplicationArea = All;
                }
            }
        }

        actions
        {
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
        //-NPR5.54 [384505]
        //SelectCalcMethod := SelectCalcMethod::"Sidste Kostpris";
        //+NPR5.54 [384505]
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

        //-NPR5.39
        // Object.SETRANGE(ID, 6014417);
        // Object.SETRANGE(Type, 3);
        // Object.FIND('-');
        //+NPR5.39

        if EndDate = 0D then
            Error(Text10600000);

        Itemfilter := Item.GetFilters;
    end;

    var
        CompanyInfo: Record "Company Information";
        ItemLedgerEntry: Record "Item Ledger Entry";
        CostValuation: Decimal;
        ActualSales: Decimal;
        GrossAvg: Decimal;
        LatestSalesDate: Date;
        LatestPurchaseDate: Date;
        EndDate: Date;
        IncludeItemStock: Boolean;
        NotUnitPrice: Boolean;
        ShowItemNegativeInventory: Boolean;
        ShowZeroInventory: Boolean;
        VATPostingSetup: Record "VAT Posting Setup";
        ShowNoInventory: Boolean;
        NegativVolumeShow: Boolean;
        Itemfilter: Text[100];
        SelectCalcMethod: Option "Sidste Kostpris",Kostpris;
        CalcMethod: Text[50];
        Text10600000: Label 'Date has to be filled';
        Text001: Label 'Last Direct Cost';
        Text002: Label 'Unit cost';
        GroupByItemGroup: Boolean;
}

