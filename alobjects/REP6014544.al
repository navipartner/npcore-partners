report 6014544 "Item Loss - Return Reason"
{
    // NPR6.000.000/LS/100214 : UnderConstruction
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.48/TJ  /20180102  CASE 340615 Removed Product Group Code from ReqFilterFields property on dataitem Item
    // NPR5.48/BHR /20190111  CASE 341976 Comment Code as per OMA
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Item Loss - Return Reason.rdlc';

    Caption = 'Item Loss - Return Reason';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item;Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "Location Filter","Date Filter","Item Category Code","Vendor No.","No.";

            trigger OnAfterGetRecord()
            begin
                CalculateShrinkage();
            end;

            trigger OnPreDataItem()
            begin
                SetCurrentKey("No.");
                //-NPR5.48 [341976]
                // IF Item.GETFILTER(Item."Item Category Code") <> '' THEN
                //  Item.SETCURRENTKEY(Item."Item Category Code")
                // ELSE
                //+NPR5.48 [341976]
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

                // TmpReportSorting.RESET;
                // TmpReportSorting.SETCURRENTKEY(Template,"Line No.");
                // TmpReportSorting.SETRANGE(Template,"No.");
                // TmpReportSorting.SETRANGE("Line No.",1);
                // TmpReportSorting.DELETEALL;

                CostAmountTotal := 0;
                SalesAmountTotal := 0;
                QtyTotal := 0;
            end;
        }
        dataitem(Reason_Code;"Reason Code")
        {
            DataItemTableView = SORTING(Code);
            column(gFilter;ReportFilters)
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(Today;Format(Today,0,4))
            {
            }
            column(USERID;UserId)
            {
            }
            column(CurrReport_PAGENO;CurrReport.PageNo)
            {
            }
            column(Reason_Code_Code;Code)
            {
            }
            column(Reason_Code_Description;Description)
            {
            }
            column(Item_NoCaption;Item_NoCaptionLbl)
            {
            }
            column(Item_DescriptionCaption;Item_DescriptionCaptionLbl)
            {
            }
            column(QuantityCaption;QuantityCaptionLbl)
            {
            }
            column(FilterCaption;FilterCaptionLbl)
            {
            }
            column(Cost_AmountCaption;Cost_AmountCaptionLbl)
            {
            }
            column(Sales_AmountCaption;Sales_AmountCaptionLbl)
            {
            }
            column(Scrinkage_Reason_Code_ItemCaption;Scrinkage___Reason_Code___ItemCaptionLbl)
            {
            }
            column(Page_Caption;Page_CaptionLbl)
            {
            }
            dataitem(TmpReportSorting;"NPR - TEMP Buffer")
            {
                DataItemTableView = SORTING(Template,"Line No.");
                UseTemporary = true;
                column(gItemRec_Description;Item1.Description)
                {
                }
                column(gItemRec_No;Item1."No.")
                {
                }
                column(TmpReportSorting_Quantity;"Decimal 3")
                {
                }
                column(TmpReportSorting_Sales_Amount;"Decimal 5")
                {
                }
                column(TmpReportSorting_Cost_Amount;"Decimal 2")
                {
                }
                column(TmpReportSorting_Template;Template)
                {
                }
                column(TmpReportSorting_Line_No;"Line No.")
                {
                }
                column(ReasonCodeCount;ReasonCodeCount)
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
                    TmpReportSorting.SetRange("Code 1",Reason_Code.Code);

                    ReasonCodeCount := 0;
                end;
            }
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                column(gRC_Qty;Qty )
                {
                }
                column(gRC_CostAmount;CostAmount)
                {
                }
                column(gRC_SalesAmount;SalesAmount)
                {
                }
                column(Reason_Code_TotalCaption;Reason_Code_TotalCaptionLbl)
                {
                }
                column(Integer_Number;Number)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    IntY := 1;
                    if Integer.Number > 2 then
                      CurrReport.Skip;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CostAmount     := 0;
                SalesAmount    := 0;
                Qty            := 0;
            end;

            trigger OnPreDataItem()
            begin
                //-NPR6.000.000/LS/100214 : UnderConstruction
                //Reason_Code.SETRANGE(Group,gIMSetupRec."Shrinkage Reason Group");
                //+NPR6.000.000/LS/100214 : UnderConstruction
            end;
        }
        dataitem(Total;"Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
            column(gTotal_CostAmount;CostAmountTotal)
            {
            }
            column(gTotal_SalesAmount;SalesAmountTotal)
            {
            }
            column(gTotal_Qty;QtyTotal)
            {
            }
            column(Text002;Text002)
            {
            }
            column(TotalCaption;TotalCaptionLbl)
            {
            }
            column(Total_Number;Number)
            {
            }
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
                    field(SourceCodeFilter;SourceCodeFilter)
                    {
                        Caption = 'Source Code Filter';
                        TableRelation = "Source Code";
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
    }

    var
        CostAmount: Decimal;
        SalesAmount: Decimal;
        Qty: Decimal;
        CostAmountTotal: Decimal;
        SalesAmountTotal: Decimal;
        QtyTotal: Decimal;
        Item1: Record Item;
        IntY: Integer;
        SourceCodeFilter: Code[10];
        Text001: Label 'Source Code Filter:  ';
        Text002: Label 'Reason Code Total';
        ReportFilters: Text[250];
        Item_NoCaptionLbl: Label 'Item No.';
        Item_DescriptionCaptionLbl: Label 'Description';
        QuantityCaptionLbl: Label 'Quantity';
        FilterCaptionLbl: Label 'Filter';
        Cost_AmountCaptionLbl: Label 'Cost Amount';
        Sales_AmountCaptionLbl: Label 'Sales Amount';
        Scrinkage___Reason_Code___ItemCaptionLbl: Label 'Item Loss - Reason Code';
        Page_CaptionLbl: Label 'Page.';
        Reason_Code_TotalCaptionLbl: Label 'Reason Code Total';
        TotalCaptionLbl: Label 'Total';
        ReasonCodeCount: Integer;

    procedure CalculateShrinkage()
    var
        lItemEntryRec: Record "Item Ledger Entry";
        lValueEntryRec: Record "Value Entry";
        lReasonCodeRec: Record "Reason Code";
        lOK: Boolean;
    begin
        lItemEntryRec.SetCurrentKey("Item No.","Entry Type","Variant Code","Drop Shipment","Location Code","Posting Date");

        lItemEntryRec.SetRange("Item No.",Item."No.");
        lItemEntryRec.SetRange("Entry Type",lItemEntryRec."Entry Type"::"Negative Adjmt.");

        if Item.GetFilter("Date Filter") <> '' then
          lItemEntryRec.SetRange("Posting Date",Item.GetRangeMin("Date Filter"),
                                Item.GetRangeMax("Date Filter"));

        if Item.GetFilter("Location Filter") <> '' then
          lItemEntryRec.SetRange("Location Code",Item.GetRangeMin("Location Filter"),
                                Item.GetRangeMax("Location Filter"));

        if lItemEntryRec.FindFirst then
          repeat
            lOK := false;
            lValueEntryRec.Reset;
            lValueEntryRec.SetCurrentKey("Item Ledger Entry No.");
            lValueEntryRec.SetRange("Item Ledger Entry No.",lItemEntryRec."Entry No.");
            if lValueEntryRec.FindFirst then
              if (SourceCodeFilter = '') or ((SourceCodeFilter <> '') and (SourceCodeFilter = lValueEntryRec."Source Code")) then begin
                if lValueEntryRec."Reason Code" <> '' then
                  if lReasonCodeRec.Get(lValueEntryRec."Reason Code") then
                    lOK := true;
              end;
            if lOK then begin
              lItemEntryRec.CalcFields("Cost Amount (Actual)");

              TmpReportSorting.Init;
              TmpReportSorting.Template          := lItemEntryRec."Item No.";
              TmpReportSorting."Line No."        := 1;
              TmpReportSorting."Short Code 1"    := lItemEntryRec."Item No.";
              TmpReportSorting."Decimal 3"       := -lItemEntryRec.Quantity;
              TmpReportSorting."Code 1"          := lValueEntryRec."Reason Code";
              TmpReportSorting."Decimal 5"       := lItemEntryRec."Sales Amount (Actual)";
              TmpReportSorting."Decimal 2"       := -lItemEntryRec."Cost Amount (Actual)";
              TmpReportSorting.Insert(true);
            end;

          until lItemEntryRec.Next = 0;
    end;
}

