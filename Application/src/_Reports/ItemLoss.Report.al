report 6014542 "NPR Item - Loss"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item - Loss.rdlc';
    Caption = 'Item - Loss';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "Location Filter", "Date Filter", "Item Category Code", "Vendor No.", "No.";
            column(USERID; UserId)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column(gFilter; ItemFilterTxtConst + ' ' + ItemFilters)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(txtAmount; TxtAmount)
            {
            }
            column(txtQty; TxtQty)
            {
            }
            column(txtDescription; TxtDescription)
            {
            }
            column(txtItemNo; TxtItemNo)
            {
            }
            column(Item_Item__No__; Item."No.")
            {
            }
            column(gShrinkageQty; SvindQty)
            {
            }
            column(gShrinkageAmount; SvindAmount)
            {
            }
            column(Item_Item_Description; Item.Description)
            {
            }
            column(txtReportName; TxtReportName)
            {
            }
            column(gShrinkageQtyTotal; SvindQtyTotal)
            {
            }
            column(gShrinkageAmountTotal; SvindAmountTotal)
            {
            }
            column(Page_Caption; Page_CaptionLbl)
            {
            }
            column(Shrinkage___ItemCaption; Shrinkage___ItemCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                SvindCalculation();

                if SvindQty = 0 then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                SvindQtyTotal := 0;
                SvindAmountTotal := 0;

                Item.SetCurrentKey("No.");
                ItemFilters := Item.GetFilters;
                if SourceCodeFilter <> '' then begin
                    if ItemFilters <> '' then
                        ItemFilters := ItemFilters + '; ' + Text001
                    else
                        ItemFilters := Text001;
                    ItemFilters := ItemFilters + SourceCodeFilter;
                end;
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
        SourceCodeFilter: Code[10];
        SvindAmount: Decimal;
        SvindAmountTotal: Decimal;
        SvindQty: Decimal;
        SvindQtyTotal: Decimal;
        TxtAmount: Label 'Amount';
        TxtDescription: Label 'Description';
        ItemFilterTxtConst: Label 'Item Filter:';
        Shrinkage___ItemCaptionLbl: Label 'Item - Loss';
        TxtItemNo: Label 'Item no.';
        TxtReportName: Label 'Item - Shrinkage';
        Page_CaptionLbl: Label 'Page.';
        TxtQty: Label 'Qty.';
        Text001: Label 'Source Code Filter:  ';
        TotalCaptionLbl: Label 'Total';
        ItemFilters: Text;

    procedure SvindCalculation()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        lReasonCodeRec: Record "Reason Code";
        ValueEntry: Record "Value Entry";
        lOK: Boolean;
    begin
        SvindQty := 0;
        SvindAmount := 0;

        ItemLedgerEntry.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");

        if Item.GetFilter("Date Filter") <> '' then
            ItemLedgerEntry.SetRange("Posting Date", Item.GetRangeMin("Date Filter"),
                                  Item.GetRangeMax("Date Filter"));
        if Item.GetFilter("Location Filter") <> '' then
            ItemLedgerEntry.SetRange("Location Code", Item.GetRangeMin("Location Filter"),
                                  Item.GetRangeMax("Location Filter"));
        if ItemLedgerEntry.FindFirst() then begin
            repeat
                lOK := false;
                ValueEntry.Reset();
                ValueEntry.SetCurrentKey("Item Ledger Entry No.");
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                if ValueEntry.FindFirst() then
                    if (SourceCodeFilter = '') or
                       ((SourceCodeFilter <> '') and (SourceCodeFilter = ValueEntry."Source Code"))
                    then begin
                        if ValueEntry."Reason Code" <> '' then
                            if lReasonCodeRec.Get(ValueEntry."Reason Code") then
                                lOK := true;
                    end;
                if lOK then begin
                    SvindQty += ItemLedgerEntry.Quantity;
                    ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                    SvindAmount += ItemLedgerEntry."Cost Amount (Actual)";
                end;
            until ItemLedgerEntry.Next() = 0;
        end;

        SvindQty := -SvindQty;
        SvindAmount := -SvindAmount;
        SvindQtyTotal := SvindQtyTotal + SvindQty;
        SvindAmountTotal := SvindAmountTotal + SvindAmount;
    end;
}

