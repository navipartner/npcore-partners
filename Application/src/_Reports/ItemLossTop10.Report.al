report 6014543 "NPR Item - Loss - Top 10"
{
#IF NOT BC17
    Extensible = False;
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item - Loss - Top 10.rdlc';
    Caption = 'Item - Loss - Top 10';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "Date Filter", "Item Category Code", "Vendor No.", "No.";

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

            trigger OnAfterGetRecord()
            begin
                ItemShrinkage();
            end;

            trigger OnPostDataItem()
            var
                ValueEntryTotal: Record "Value Entry";
            begin
                ValueEntryTotal.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
                if Item.GetFilter("Date Filter") <> '' then
                    ValueEntryTotal.SetRange("Posting Date", Item.GetRangeMin("Date Filter"),
                                          Item.GetRangeMax("Date Filter"));

                if Item.GetFilter("Location Filter") <> '' then
                    ValueEntryTotal.SetRange("Location Code", Item.GetRangeMin("Location Filter"),
                                          Item.GetRangeMax("Location Filter"));

                ValueEntryTotal.SetRange("Item Ledger Entry Type", ValueEntryTotal."Item Ledger Entry Type"::Sale);
                ValueEntryTotal.CalcSums("Cost Amount (Actual)");
                ItemCostAmountTotal := -ValueEntryTotal."Cost Amount (Actual)";
            end;
        }
        dataitem(ItemReportSorting; "NPR TEMP Buffer")
        {
            DataItemTableView = SORTING(Template, "Line No.");
            UseTemporary = true;
            column(COMPANYNAME; CompanyName)
            {
            }
            column(gFilter; 'Item Filters:' + ItemFilters)
            {
            }
            column(SortBy; SortBy)
            {
            }
            column(ItemCostAmount; ItemCostAmount)
            {
                AutoFormatType = 1;
            }
            column(ItemDescription; ItemDescription)
            {
            }
            column(ItemNo; ItemNo)
            {
            }
            column(Rank; Rank)
            {
            }
            column(ItemQuantity; "Decimal 3")
            {
            }
            column(ShrinkagePct; ShrinkagePct)
            {
                DecimalPlaces = 1 : 1;
            }
            column(ItemCostAmountTotal; ItemCostAmountTotal)
            {
                AutoFormatType = 1;
            }

            trigger OnPreDataItem()
            begin
                Rank := 0;
                Reset();
                SetCurrentKey(Template, "Line No.");
                SetCurrentKey("Decimal 1", "Short Code 1");
                Ascending := false;
            end;

            trigger OnAfterGetRecord()
            begin
                Rank += 1;
                ItemNo := CopyStr(ItemReportSorting.Template, 1, MaxStrLen(ItemNo));
                ItemCostAmount := ItemReportSorting."Decimal 2";
                ShrinkagePct := Pct("Decimal 3", "Decimal 4");

                if Rank <= NoOfRecordsToPrint then
                    ItemCostAmountTotal_Top := ItemCostAmountTotal_Top + ItemReportSorting."Decimal 2";
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
                group(Control6150614)
                {
                    ShowCaption = false;
                    field("Source Code Filter"; SourceCodeFilter)
                    {
                        Caption = 'Source Code Filter';
                        ToolTip = 'Specifies the value of the Source Code Filter field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sorting"; SortOrder)
                    {
                        Caption = 'Quantity';
                        OptionCaption = 'Quantity,CostAmount,Shrinkage';
                        ToolTip = 'Specifies the value of the Quantity field';
                        ApplicationArea = NPRRetail;
                    }
                    field("No Of Records To Print"; NoOfRecordsToPrint)
                    {
                        Caption = 'Print Lines';
                        ToolTip = 'Specifies the value of the Print Lines field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    labels
    {
        ReportCaptionLbl = 'Item - Loss - Top 10';
        PageLbl = 'Page.';
        OfLbl = 'of';
        ShrinkageCaptionLbl = 'Shrinkage %';
        ItemCostAmountCaptionLbl = 'Cost Amount';
        ItemCostAmountTotalListedCaptionLbl = 'Total Listed';
        ItemCostAmountTotalCostCaptionLbl = 'Total Cost';
        ItemCostAmount_PctCaptionLbl = '% of Total Cost';
        ItemssQuantityCaptionLbl = 'Quantity';
        ItemNoCaptionLbl = 'Item No';
        SalesAmountCaptionLbl = 'No.';
        ItemDescriptionCaptionLbl = 'Item Description';
    }

    trigger OnInitReport()
    begin
        NoOfRecordsToPrint := 10;
    end;

    trigger OnPreReport()
    begin
        case SortOrder of
            SortOrder::Quantity:
                SortBy := Text002;
            SortOrder::CostAmount:
                SortBy := Text003;
            SortOrder::Shrinkage:
                SortBy := Text004;
        end;
    end;

    var
        ItemNo: Code[20];
        SourceCodeFilter: Code[10];
        ItemDescription: Text[100];
        ItemFilters: Text;
        SortBy: Text[30];
        SortOrder: Option Quantity,CostAmount,Shrinkage;
        ItemCostAmount: Decimal;
        ItemCostAmountTotal: Decimal;
        ItemCostAmountTotal_Top: Decimal;
        NoOfRecordsToPrint: Integer;
        Text001: Label 'Source Code Filter:  ';
        Text002: Label 'Sorted by ''Quantity''';
        Text003: Label 'Sorted by ''Cost Amount''';
        Text004: Label 'Sorted by ''Shrinkage %''';
        ShrinkagePct: Decimal;
        Rank: Integer;

    internal procedure ItemShrinkage()
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
        ItemLedgerEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));
        ItemLedgerEntry.SetFilter("Location Code", Item.GetFilter("Location Filter"));
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
                if ValueEntry.FindFirst() then
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

                        case SortOrder of
                            SortOrder::Quantity:
                                ItemReportSorting."Decimal 1" := ItemReportSorting."Decimal 3";
                            SortOrder::CostAmount:
                                ItemReportSorting."Decimal 1" := ItemReportSorting."Decimal 2";
                            SortOrder::Shrinkage:
                                ItemReportSorting."Decimal 1" := Pct(ItemReportSorting."Decimal 3", ItemReportSorting."Decimal 4");
                        end;
                        ItemReportSorting.Modify();
                    end
                    else begin
                        ItemReportSorting.Init();
                        ItemReportSorting.Template := ItemLedgerEntry."Item No.";
                        ItemReportSorting."Line No." := 1;
                        ItemReportSorting.Description := Item.Description;
                        ItemReportSorting."Short Code 1" := ItemLedgerEntry."Item No.";
                        ItemReportSorting."Decimal 3" := -ItemLedgerEntry.Quantity;
                        ItemReportSorting."Decimal 4" := -SalesQty;
                        ItemReportSorting."Decimal 2" := -ItemLedgerEntry."Cost Amount (Actual)";

                        case SortOrder of
                            SortOrder::Quantity:
                                ItemReportSorting."Decimal 1" := ItemReportSorting."Decimal 3";
                            SortOrder::CostAmount:
                                ItemReportSorting."Decimal 1" := ItemReportSorting."Decimal 2";
                            SortOrder::Shrinkage:
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