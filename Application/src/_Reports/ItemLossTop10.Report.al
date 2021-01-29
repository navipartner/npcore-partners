report 6014543 "NPR Item - Loss - Top 10"
{
    RDLCLayout = './src/_Reports/layouts/Item - Loss - Top 10.rdlc';
    Caption = 'Item Shrinkage - Top 10'; 
    UsageCategory = ReportsAndAnalysis; 
    ApplicationArea = All;
    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "Date Filter", "Item Category Code", "Vendor No.", "No.";

            trigger OnAfterGetRecord()
            begin
                ItemShrinkage;
            end;

            trigger OnPreDataItem()
            begin
                Item.SetCurrentKey("No.");
                if Item.GetFilter("Vendor No.") <> '' then
                    Item.SetCurrentKey("Vendor No.");

                ItemFilters := Item.GetFilters;
                if SourceCodeFilter <> '' then begin
                    if ItemFilters <> '' then
                        ItemFilters := ItemFilters + '; ' + Text001
                    else
                        ItemFilters := Text001;
                    ItemFilters := ItemFilters + SourceCodeFilter;
                end;

                ItemReportSorting.Reset();
                ItemReportSorting.DeleteAll();
            end;
        }
        dataitem("Item Report Sorting"; "NPR TEMP Buffer")
        {
            DataItemTableView = SORTING(Template, "Line No.");
            column(USERID; UserId)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(gFilter; 'Item Filters:' + ItemFilters)
            {
            }
            column(SortBy; SortBy)
            {
            }
            column(ProgressText; ProgressText)
            {
            }
            column(ItemCostAmount; ItemCostAmount)
            {
                AutoFormatType = 1;
            }
            column(ItemDescription; ItemDescription)
            {
            }
            column(ItemNo__; "ItemNo.")
            {
            }
            column(Rank; Rank)
            {
            }
            column(Item_Report_Sorting_Quantity; "Decimal 3")
            {
            }
            column(ShrinkagePct; ShrinkagePct)
            {
                DecimalPlaces = 1 : 1;
            }
            column(ItemCostAmount_Pct; ItemCostAmount_Pct)
            {
                DecimalPlaces = 1 : 1;
            }
            column(ItemCostAmountTotal; ItemCostAmountTotal)
            {
                AutoFormatType = 1;
            }
            column(ItemCostAmountTotal_Top; ItemCostAmountTotal_Top)
            {
                AutoFormatType = 1;
            }
            column(Vare_Svind___Top_10Caption; Vare_Svind___Top_10CaptionLbl)
            {
            }
            column(Page_Caption; Page_CaptionLbl)
            {
            }
            column(Item_NoCaption; Item_NoCaptionLbl)
            {
            }
            column(Item_DescriptionCaption; Item_DescriptionCaptionLbl)
            {
            }
            column(Cost_AmountCaption; Cost_AmountCaptionLbl)
            {
            }
            column(Sales_AmountCaption; Sales_AmountCaptionLbl)
            {
            }
            column(Item_Report_Sorting_QuantityCaption; Item_Report_Sorting_QuantityCaptionLbl)
            {
            }
            column(Svind__Caption; Svind__CaptionLbl)
            {
            }
            column(ItemCostAmount_PctCaption; ItemCostAmount_PctCaptionLbl)
            {
            }
            column(ItemCostAmountTotalCaption; ItemCostAmountTotalCaptionLbl)
            {
            }
            column(ItemCostAmountTotal_TopCaption; ItemCostAmountTotal_TopCaptionLbl)
            {
            }
            column(Item_Report_Sorting_Template; Template)
            {
            }
            column(Item_Report_Sorting_Line_No_; "Line No.")
            {
            }

            trigger OnAfterGetRecord()
            begin
                Rank += 1;
                "ItemNo." := "Item Report Sorting".Template;
                ItemDescription := '';
                if Item1.Get("ItemNo.") then
                    ItemDescription := Item1.Description;
                ItemCostAmount := "Item Report Sorting"."Decimal 2";
                ShrinkagePct := Pct("Decimal 3", "Decimal 4");

                if Rank = 1 then
                    MaxAmt := ItemCostAmount;
                TestAmt := Round(ItemCostAmount / MaxAmt * 45, 1);
                if ItemCostAmount > 0 then
                    ProgressText := PadStr('', Round(ItemCostAmount / MaxAmt * 45, 1), '*')
                else
                    ProgressText := '';

                if Rank <= NoOfRecordsToPrint then
                    ItemCostAmountTotal_Top := ItemCostAmountTotal_Top + "Item Report Sorting"."Decimal 2";
                ItemCostAmountTotal := ItemCostAmountTotal + "Item Report Sorting"."Decimal 2";
                ItemCostAmount_Pct := Pct(ItemCostAmountTotal_Top, ItemCostAmountTotal);
            end;

            trigger OnPreDataItem()
            begin
                Rank := 0;
                Reset();
                SetCurrentKey(Template, "Line No.");
                SetCurrentKey("Decimal 1", "Short Code 1");
                Ascending := false;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control6150614)
                {
                    ShowCaption = false;
                    field(SourceCodeFilter; SourceCodeFilter)
                    {
                        Caption = 'Source Code Filter';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Source Code Filter field';
                    }
                    field("Sorting"; Sorting)
                    {
                        Caption = 'Quantity';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Quantity field';
                    }
                    field(NoOfRecordsToPrint; NoOfRecordsToPrint)
                    {
                        Caption = 'Print Lines';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Print Lines field';
                    }
                }
            }
        }
    }

    trigger OnInitReport()
    begin
        NoOfRecordsToPrint := 10;
    end;

    trigger OnPreReport()
    begin
        case Sorting of
            Sorting::Quantity:
                SortBy := Text002;
            Sorting::CostAmount:
                SortBy := Text003;
            Sorting::Shrinkage:
                SortBy := Text004;
        end;
    end;

    var
        Item1: Record Item;
        "ItemNo.": Code[20];
        SourceCodeFilter: Code[10];
        ItemDescription: Text[50];
        ItemFilters: Text[250];
        ProgressText: Text[1024];
        SortBy: Text[30];
        Sorting: Option Quantity,CostAmount,Shrinkage;
        ItemCostAmount: Decimal;
        ItemCostAmountTotal: Decimal;
        ItemCostAmountTotal_Top: Decimal;
        ItemCostAmount_Pct: Decimal;
        NoOfRecordsToPrint: Integer;
        Text001: Label 'Source Code Filter:  ';
        Text002: Label 'Sorted by ''Quantity''';
        Text003: Label 'Sorted by ''Cost Amount''';
        Text004: Label 'Sorted by ''Shrinkage %''';
        ItemReportSorting: Record "NPR TEMP Buffer";
        ShrinkagePct: Decimal;
        Rank: Integer;
        TestAmt: Decimal;
        MaxAmt: Decimal;
        Vare_Svind___Top_10CaptionLbl: Label 'Item Shrinkage - Top 10';
        Page_CaptionLbl: Label 'Page.';
        Item_NoCaptionLbl: Label 'Item No';
        Item_DescriptionCaptionLbl: Label 'Item Description';
        Cost_AmountCaptionLbl: Label 'Cost Amount';
        Sales_AmountCaptionLbl: Label 'No.';
        Item_Report_Sorting_QuantityCaptionLbl: Label 'Quantity';
        Svind__CaptionLbl: Label 'Shrinkage %';
        ItemCostAmount_PctCaptionLbl: Label '% of Total Cost';
        ItemCostAmountTotalCaptionLbl: Label 'Total Cost';
        ItemCostAmountTotal_TopCaptionLbl: Label 'Total Listed';

    procedure ItemShrinkage()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        ReasonCode: Record "Reason Code";
        SalesQty: Decimal;
        Location: Record Location;
        ReasonCodeGrp: Boolean;
    begin
        ItemLedgerEntry.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", Item."No.");

        if Item.GetFilter("Date Filter") <> '' then
            ItemLedgerEntry.SetRange("Posting Date", Item.GetRangeMin("Date Filter"),
                                  Item.GetRangeMax("Date Filter"));

        if Item.GetFilter("Location Filter") <> '' then
            ItemLedgerEntry.SetRange("Location Code", Item.GetRangeMin("Location Filter"),
                                  Item.GetRangeMax("Location Filter"));

        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.CalcSums("Invoiced Quantity");
        SalesQty := ItemLedgerEntry."Invoiced Quantity";
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
        if ItemLedgerEntry.FindFirst() then begin
            repeat
                ReasonCodeGrp := false;
                ValueEntry.Reset();
                ValueEntry.SetCurrentKey("Item Ledger Entry No.");
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                if ValueEntry.FindFirst then
                    if (SourceCodeFilter = '') or
                       ((SourceCodeFilter <> '') and (SourceCodeFilter = ValueEntry."Source Code"))
                    then begin
                        if ValueEntry."Reason Code" <> '' then
                            if ReasonCode.Get(ValueEntry."Reason Code") then
                                ReasonCodeGrp := true;
                    end;
                if ReasonCodeGrp then begin
                    Location.Reset();
                    Location.SetCurrentKey(Code);
                    Location.SetRange(Code, ItemLedgerEntry."Location Code");
                    if Location.FindFirst() then;
                    ItemLedgerEntry.CalcFields("Cost Amount (Actual)");

                    ItemReportSorting.SetCurrentKey(Template, "Line No.");
                    if ItemReportSorting.Get(ItemLedgerEntry."Item No.", 1) then begin
                        ItemReportSorting."Decimal 3" := ItemReportSorting."Decimal 3" - ItemLedgerEntry.Quantity;
                        ItemReportSorting."Decimal 2" := ItemReportSorting."Decimal 2" - ItemLedgerEntry."Cost Amount (Actual)";

                        case Sorting of
                            Sorting::Quantity:
                                ItemReportSorting."Decimal 1" := ItemReportSorting."Decimal 3";
                            Sorting::CostAmount:
                                ItemReportSorting."Decimal 1" := ItemReportSorting."Decimal 2";
                            Sorting::Shrinkage:
                                ItemReportSorting."Decimal 1" := Pct(ItemReportSorting."Decimal 3", ItemReportSorting."Decimal 4");
                        end;
                        ItemReportSorting.Modify();
                    end
                    else begin
                        ItemReportSorting.Init();
                        ItemReportSorting.Template := ItemLedgerEntry."Item No.";
                        ItemReportSorting."Line No." := 1;
                        ItemReportSorting."Short Code 1" := ItemLedgerEntry."Item No.";
                        ItemReportSorting."Decimal 3" := -ItemLedgerEntry.Quantity;
                        ItemReportSorting."Decimal 4" := -SalesQty;
                        ItemReportSorting."Decimal 2" := -ItemLedgerEntry."Cost Amount (Actual)";

                        case Sorting of
                            Sorting::Quantity:
                                ItemReportSorting."Decimal 1" := ItemReportSorting."Decimal 3";
                            Sorting::CostAmount:
                                ItemReportSorting."Decimal 1" := ItemReportSorting."Decimal 2";
                            Sorting::Shrinkage:
                                ItemReportSorting."Decimal 1" := Pct(ItemReportSorting."Decimal 3", ItemReportSorting."Decimal 4");
                        end;

                        ItemReportSorting.Insert(true);
                    end;
                end;
            until ItemLedgerEntry.Next() = 0;
        end;
    end;

    local procedure Pct(Numeral1: Decimal; Numeral2: Decimal): Decimal
    begin
        if Numeral2 = 0 then
            exit(0);
        exit(Round(Numeral1 / Numeral2 * 100, 0.1));
    end;
}

