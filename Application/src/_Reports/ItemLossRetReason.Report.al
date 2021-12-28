report 6014544 "NPR Item Loss - Ret. Reason"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Loss - Return Reason.rdlc';
    Caption = 'Item Loss - Return Reason';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "Location Filter", "Date Filter", "Item Category Code", "Vendor No.", "No.";

            trigger OnAfterGetRecord()
            begin
                CalculateShrinkage();
            end;

            trigger OnPreDataItem()
            begin
                SetCurrentKey("No.");
                if Item.GetFilter("Vendor No.") <> '' then
                    Item.SetCurrentKey("Vendor No.");

                ReportFilters := Item.GetFilters;
                if SourceCodeFilter <> '' then begin
                    if ReportFilters <> '' then
                        ReportFilters := ReportFilters + '; ' + Text001
                    else
                        ReportFilters := Text001;
                    ReportFilters += SourceCodeFilter;
                end;

                CostAmountTotal := 0;
                SalesAmountTotal := 0;
                QtyTotal := 0;
            end;
        }
        dataitem(Reason_Code; "Reason Code")
        {
            DataItemTableView = SORTING(Code);
            column(gFilter; ReportFilters)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(Today; Format(Today, 0, 4))
            {
            }
            column(USERID; UserId)
            {
            }
            column(Reason_Code_Code; Code)
            {
            }
            column(Reason_Code_Description; Description)
            {
            }
            column(Item_NoCaption; Item_NoCaptionLbl)
            {
            }
            column(Item_DescriptionCaption; Item_DescriptionCaptionLbl)
            {
            }
            column(QuantityCaption; QuantityCaptionLbl)
            {
            }
            column(FilterCaption; FilterCaptionLbl)
            {
            }
            column(Cost_AmountCaption; Cost_AmountCaptionLbl)
            {
            }
            column(Sales_AmountCaption; Sales_AmountCaptionLbl)
            {
            }
            column(Scrinkage_Reason_Code_ItemCaption; Scrinkage___Reason_Code___ItemCaptionLbl)
            {
            }
            column(Page_Caption; Page_CaptionLbl)
            {
            }
            dataitem(TmpReportSorting; "NPR TEMP Buffer")
            {
                DataItemTableView = SORTING(Template, "Line No.");
                UseTemporary = true;
                column(gItemRec_Description; Item1.Description)
                {
                }
                column(gItemRec_No; Item1."No.")
                {
                }
                column(TmpReportSorting_Quantity; "Decimal 3")
                {
                }
                column(TmpReportSorting_Sales_Amount; "Decimal 5")
                {
                }
                column(TmpReportSorting_Cost_Amount; "Decimal 2")
                {
                }
                column(TmpReportSorting_Template; Template)
                {
                }
                column(TmpReportSorting_Line_No; "Line No.")
                {
                }
                column(ReasonCodeCount; ReasonCodeCount)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if TmpReportSorting.Template <> '' then
                        ReasonCodeCount += 1;

                    CostAmount += "Decimal 2";
                    SalesAmount += "Decimal 5";
                    Qty += "Decimal 3";

                    CostAmountTotal += "Decimal 2";
                    SalesAmountTotal += "Decimal 5";
                    QtyTotal += "Decimal 3";
                    Item1.SetCurrentKey("No.");
                    if Item1.Get(Template) then;
                end;

                trigger OnPreDataItem()
                begin
                    TmpReportSorting.SetRange("Code 1", Reason_Code.Code);

                    ReasonCodeCount := 0;
                end;
            }
            dataitem("Integer"; "Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                column(gRC_Qty; Qty)
                {
                }
                column(gRC_CostAmount; CostAmount)
                {
                }
                column(gRC_SalesAmount; SalesAmount)
                {
                }
                column(Reason_Code_TotalCaption; Reason_Code_TotalCaptionLbl)
                {
                }
                column(Integer_Number; Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if Integer.Number > 2 then
                        CurrReport.Skip();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CostAmount := 0;
                SalesAmount := 0;
                Qty := 0;
            end;
        }
        dataitem(Total; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(gTotal_CostAmount; CostAmountTotal)
            {
            }
            column(gTotal_SalesAmount; SalesAmountTotal)
            {
            }
            column(gTotal_Qty; QtyTotal)
            {
            }
            column(Text002; Text002)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(Total_Number; Number)
            {
            }
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
                    field("Source Code Filter"; SourceCodeFilter)
                    {
                        Caption = 'Source Code Filter';
                        TableRelation = "Source Code";

                        ToolTip = 'Specifies the value of the Source Code Filter field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    var
        Item1: Record Item;
        SourceCodeFilter: Code[10];
        CostAmount: Decimal;
        CostAmountTotal: Decimal;
        Qty: Decimal;
        QtyTotal: Decimal;
        SalesAmount: Decimal;
        SalesAmountTotal: Decimal;
        ReasonCodeCount: Integer;
        Cost_AmountCaptionLbl: Label 'Cost Amount';
        Item_DescriptionCaptionLbl: Label 'Description';
        FilterCaptionLbl: Label 'Filter';
        Scrinkage___Reason_Code___ItemCaptionLbl: Label 'Item Loss - Reason Code';
        Item_NoCaptionLbl: Label 'Item No.';
        Page_CaptionLbl: Label 'Page.';
        QuantityCaptionLbl: Label 'Quantity';
        Reason_Code_TotalCaptionLbl: Label 'Reason Code Total';
        Text002: Label 'Reason Code Total';
        Sales_AmountCaptionLbl: Label 'Sales Amount';
        Text001: Label 'Source Code Filter:  ';
        TotalCaptionLbl: Label 'Total';
        ReportFilters: Text;

    procedure CalculateShrinkage()
    var
        lItemEntryRec: Record "Item Ledger Entry";
        lReasonCodeRec: Record "Reason Code";
        lValueEntryRec: Record "Value Entry";
        lOK: Boolean;
    begin
        lItemEntryRec.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        lItemEntryRec.SetRange("Item No.", Item."No.");
        lItemEntryRec.SetRange("Entry Type", lItemEntryRec."Entry Type"::"Negative Adjmt.");
        if Item.GetFilter("Date Filter") <> '' then
            lItemEntryRec.SetRange("Posting Date", Item.GetRangeMin("Date Filter"),
                                  Item.GetRangeMax("Date Filter"));
        if Item.GetFilter("Location Filter") <> '' then
            lItemEntryRec.SetRange("Location Code", Item.GetRangeMin("Location Filter"),
                                  Item.GetRangeMax("Location Filter"));
        if lItemEntryRec.FindFirst() then
            repeat
                lOK := false;
                lValueEntryRec.Reset();
                lValueEntryRec.SetCurrentKey("Item Ledger Entry No.");
                lValueEntryRec.SetRange("Item Ledger Entry No.", lItemEntryRec."Entry No.");
                if lValueEntryRec.FindFirst() then
                    if (SourceCodeFilter = '') or ((SourceCodeFilter <> '') and (SourceCodeFilter = lValueEntryRec."Source Code")) then begin
                        if lValueEntryRec."Reason Code" <> '' then
                            if lReasonCodeRec.Get(lValueEntryRec."Reason Code") then
                                lOK := true;
                    end;
                if lOK then begin
                    lItemEntryRec.CalcFields("Cost Amount (Actual)");

                    TmpReportSorting.Init();
                    TmpReportSorting.Template := lItemEntryRec."Item No.";
                    TmpReportSorting."Line No." += 1;
                    TmpReportSorting."Short Code 1" := lItemEntryRec."Item No.";
                    TmpReportSorting."Decimal 3" := -lItemEntryRec.Quantity;
                    TmpReportSorting."Code 1" := lValueEntryRec."Reason Code";
                    TmpReportSorting."Decimal 5" := lItemEntryRec."Sales Amount (Actual)";
                    TmpReportSorting."Decimal 2" := -lItemEntryRec."Cost Amount (Actual)";
                    TmpReportSorting.Insert(true);
                end;

            until lItemEntryRec.Next() = 0;
    end;
}

