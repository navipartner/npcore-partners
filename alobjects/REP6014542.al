report 6014542 "Item - Loss"
{
    // NPR70.00.00.00/LS/100214  CASE 175118  : Creation of report
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.48/TJ  /20180102  CASE 340615 Removed Product Group Code from ReqFilterFields property on dataitem Item
    // NPR5.48/BHR /20190111  CASE 341969 Removed unneeded code as per OMA
    DefaultLayout = RDLC;
    RDLCLayout = './Item - Loss.rdlc';

    Caption = 'Item - Loss';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item;Item)
        {
            RequestFilterFields = "Location Filter","Date Filter","Item Category Code","Vendor No.","No.";
            column(USERID;UserId)
            {
            }
            column(COMPANYNAME;CompanyName)
            {
            }
            column(gFilter;ItemFilterTxtConst + ' ' + ItemFilters)
            {
            }
            column(FORMAT_TODAY_0_4_;Format(Today,0,4))
            {
            }
            column(txtAmount;TxtAmount)
            {
            }
            column(txtQty;TxtQty)
            {
            }
            column(txtDescription;TxtDescription)
            {
            }
            column(txtItemNo;TxtItemNo)
            {
            }
            column(Item_Item__No__;Item."No.")
            {
            }
            column(gShrinkageQty;SvindQty)
            {
            }
            column(gShrinkageAmount;SvindAmount)
            {
            }
            column(Item_Item_Description;Item.Description)
            {
            }
            column(txtReportName;TxtReportName)
            {
            }
            column(gShrinkageQtyTotal;SvindQtyTotal)
            {
            }
            column(gShrinkageAmountTotal;SvindAmountTotal)
            {
            }
            column(Page_Caption;Page_CaptionLbl)
            {
            }
            column(Shrinkage___ItemCaption;Shrinkage___ItemCaptionLbl)
            {
            }
            column(TotalCaption;TotalCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                SvindCalculation;

                if SvindQty = 0 then
                  CurrReport.Skip;
            end;

            trigger OnPreDataItem()
            begin
                SvindQtyTotal := 0;
                SvindAmountTotal := 0;

                Item.SetCurrentKey("No.");
                //-NPR5.48 [341976]
                // IF Item.GETFILTER(Item."Item Category Code") <> '' THEN
                //  Item.SETCURRENTKEY(Item."Item Category Code")
                // ELSE
                //  IF Item.GETFILTER(Item."Vendor No.") <> '' THEN
                //    Item.SETCURRENTKEY(Item."Vendor No.");
                //+NPR5.48 [341976]
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

    trigger OnInitReport()
    begin
        //gIMSetupRec.GET;
    end;

    var
        SvindQty: Decimal;
        SvindAmount: Decimal;
        SvindQtyTotal: Decimal;
        SvindAmountTotal: Decimal;
        ItemFilters: Text[250];
        SourceCodeFilter: Code[10];
        Text001: Label 'Source Code Filter:  ';
        TxtReportName: Label 'Item - Shrinkage';
        TxtDescription: Label 'Description';
        TxtQty: Label 'Qty.';
        TxtAmount: Label 'Amount';
        TxtItemNo: Label 'Item no.';
        Page_CaptionLbl: Label 'Page.';
        Shrinkage___ItemCaptionLbl: Label 'Item - Loss';
        TotalCaptionLbl: Label 'Total';
        ItemFilterTxtConst: Label 'Item Filter:';

    procedure SvindCalculation()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        lReasonCodeRec: Record "Reason Code";
        lOK: Boolean;
    begin
        SvindQty := 0;
        SvindAmount := 0;

        ItemLedgerEntry.SetCurrentKey("Item No.","Entry Type","Variant Code","Drop Shipment","Location Code","Posting Date");
        ItemLedgerEntry.SetRange("Item No.",Item."No.");
        ItemLedgerEntry.SetRange("Entry Type",ItemLedgerEntry."Entry Type"::"Negative Adjmt.");

        if Item.GetFilter("Date Filter") <> '' then
          ItemLedgerEntry.SetRange("Posting Date",Item.GetRangeMin("Date Filter"),
                                Item.GetRangeMax("Date Filter"));

        if Item.GetFilter("Location Filter") <> '' then
          ItemLedgerEntry.SetRange("Location Code",Item.GetRangeMin("Location Filter"),
                                Item.GetRangeMax("Location Filter"));

        if ItemLedgerEntry.FindFirst then begin
          repeat
            lOK := false;
            ValueEntry.Reset;
            ValueEntry.SetCurrentKey("Item Ledger Entry No.");
            ValueEntry.SetRange("Item Ledger Entry No.",ItemLedgerEntry."Entry No.");
            if ValueEntry.FindFirst then
              if (SourceCodeFilter = '') or
                 ((SourceCodeFilter <> '') and (SourceCodeFilter = ValueEntry."Source Code"))
              then begin
                if ValueEntry."Reason Code" <> '' then
                  if lReasonCodeRec.Get(ValueEntry."Reason Code") then
                    //to uncomment it if we have a field Svind
                    ///IF lReasonCodeRec.Group = gIMSetupRec."Shrinkage Reason Group" THEN
                      lOK := true;
              end;
            if lOK then begin
                SvindQty += ItemLedgerEntry.Quantity;
                ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                SvindAmount += ItemLedgerEntry."Cost Amount (Actual)";
              end;
          until ItemLedgerEntry.Next = 0;
        end;

        SvindQty := -SvindQty;
        SvindAmount := -SvindAmount;
        SvindQtyTotal := SvindQtyTotal + SvindQty;
        SvindAmountTotal := SvindAmountTotal + SvindAmount;
    end;
}

