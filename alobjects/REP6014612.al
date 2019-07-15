report 6014612 "Inventory per Variant at date"
{
    // NPR70.00.00.00/LS/280613 CASE  143458 : COnvert Report to NAV 2013 report
    // NPR5.25/JLK /20160801 CASE 241520 VariaX removed to replace by Item Variants
    //                                   Corrected Report Totals and Fields: Inventory, Sale Date
    //                                   Changed Gross Profit Caption to Exp Gross Profit
    //                                   Uncommented and made necessary corrections to display Quantity for Location Code per Variants
    // NPR5.32/KENU/20170502 CASE 274094 Changed filter
    // NPR5.38/JLK /20180124 CASE 300892 Corrected AL Error on ReqFilterFields property referencing invalid field6014600, field6014604 and field6014605
    // NPR5.39/TJ  /20180208 CASE 302634 Removed unused variables
    // NPR5.39/JLK /20180219  CASE 300892 Removed warning/error from AL
    // NPR5.40/TJ  /20180319  CASE 307717 Replaced hardcoded dates with DMY2DATE structure
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Inventory per Variant at date.rdlc';

    Caption = 'Inventory Per Date';
    Description = 'Inventory per Variant at date';
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ReportHdr;"Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(COMPANYNAME;CompanyName)
            {
            }
            column(CompanyInfoPicture;CompanyInfo.Picture)
            {
            }
            column(Report_Caption;Report_Caption)
            {
            }
            column(Date_Caption;Date_Caption)
            {
            }
            column(Itemfilter;Itemfilter)
            {
            }
            column(tildato;Tildato)
            {
            }
            column(No_Caption;No_Caption)
            {
            }
            column(Desc_Caption;Desc_Caption)
            {
            }
            column(NetChange_Caption;NetChange_Caption)
            {
            }
            column(ItemVendorItemNo_Caption;ItemVendorItemNo_Caption)
            {
            }
            column(UnitPrice_Caption;UnitPrice_Caption)
            {
            }
            column(DirCost_Caption;DirCost_Caption)
            {
            }
            column(InvValue_Caption;InvValue_Caption)
            {
            }
            column(brutto_Caption;Gross_Caption)
            {
            }
            column(SalesDate_Caption;SalesDate_Caption)
            {
            }
            column(TotalTxt;Txt003)
            {
            }
            column(NaviPartTxt;Txt004)
            {
            }
            column(ViewSalesPrice;ViewSalesPrice)
            {
            }
            column(ShowNoInventory;ShowNoInventory)
            {
            }
        }
        dataitem(Item;Item)
        {
            CalcFields = "Net Change","Has Variants";
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.","Vendor No.","Item Group","Group sale","Location Filter","Date Filter";
            column(ShowLocation;ShowLocation)
            {
            }
            column(ItemNo;Item."No.")
            {
            }
            column(ItemDesc;Item.Description)
            {
            }
            column(ItemNetChange;NetChangeItem)
            {
            }
            column(ItemVendorItemNo;Item."Vendor Item No.")
            {
            }
            column(ItemUnitPrice;Item."Unit Price")
            {
                AutoFormatType = 1;
            }
            column(ItemLastDirCost;Item."Last Direct Cost")
            {
                AutoFormatType = 1;
            }
            column(bruttoavialt;Bruttoavialt)
            {
                AutoFormatType = 1;
            }
            column(CostValue;CostValue)
            {
                AutoFormatType = 1;
            }
            column(GrossValue;Gross)
            {
                AutoFormatType = 1;
            }
            column(SaleDate;Format(SaleDate))
            {
            }
            column(ItemTotalNetChange;ItemTotalNetChange)
            {
            }
            column(ItemTotalCostValue;ItemTotalCostValue)
            {
            }
            column(ItemSalesValue;ItemSalesValue)
            {
            }
            dataitem(ItemVariant;"Item Variant")
            {
                DataItemLink = "Item No."=FIELD("No.");
                DataItemTableView = SORTING("Item No.",Code);
                column(ItemVarItemNo;ItemVariant."Item No.")
                {
                }
                column(ItemVarCode;ItemVariant.Code)
                {
                }
                column(ItemVarDescription;ItemVariant.Description)
                {
                }
                column(Item1NetChange;NetChangeItemVariant)
                {
                }
                column(InventoryLocation1;InventoryLocation[1])
                {
                }
                column(InventoryQty1;InventoryQty[1])
                {
                }
                column(InventoryLocation2;InventoryLocation[2])
                {
                }
                column(InventoryQty2;InventoryQty[2])
                {
                }
                column(InventoryLocation3;InventoryLocation[3])
                {
                }
                column(InventoryQty3;InventoryQty[3])
                {
                }
                column(InventoryLocation4;InventoryLocation[4])
                {
                }
                column(InventoryQty4;InventoryQty[4])
                {
                }
                column(InventoryLocation5;InventoryLocation[5])
                {
                }
                column(InventoryQty5;InventoryQty[5])
                {
                }
                column(InventoryLocation6;InventoryLocation[6])
                {
                }
                column(InventoryQty6;InventoryQty[6])
                {
                }
                column(InventoryLocation7;InventoryLocation[7])
                {
                }
                column(InventoryQty7;InventoryQty[7])
                {
                }
                column(CostValueVariant;CostValueVariant)
                {
                    AutoFormatType = 1;
                }
                column(ItemVarGross;GrossVariant)
                {
                    AutoFormatType = 1;
                }
                column(ItemVarSaleDate;Format(SaleDateVariant))
                {
                }
                column(LocationCaption;LocationText)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Item1.Get(Item."No.");
                    Item1.CopyFilters(Item);
                    Item1.SetRange("Variant Filter", Code);
                    Item1.CalcFields("Has Variants","Net Change");

                    if Varermedbeholdning then begin
                      if Item1."Net Change" = 0 then
                        CurrReport.Skip;
                    end;

                    i := 1;
                    Clear(InventoryLocation);
                    Clear(InventoryQty);
                    Clear(ItemLedgEntry);
                    TempQuantity := 0;

                    ItemLedgEntry.Reset;
                    ItemLedgEntry.SetRange("Item No.",Item."No.");
                    ItemLedgEntry.SetRange("Variant Code", Code);
                    //-NPR5.32
                    ItemLedgEntry.SetFilter("Posting Date", Item1.GetFilter("Date Filter"));
                    //+NPR5.32
                    ItemLedgEntry.SetRange("Location Code",'');
                    if ItemLedgEntry.FindSet then repeat
                     TempQuantity += ItemLedgEntry.Quantity;
                    until ItemLedgEntry.Next = 0;

                    if TempQuantity <> 0 then begin
                     InventoryLocation[i] := '';
                     InventoryQty[i] := TempQuantity;
                     i += 1;
                     TempQuantity := 0;
                    end;

                    if Location.FindSet then repeat
                      ItemLedgEntry.SetRange("Location Code");
                      ItemLedgEntry.SetRange("Location Code", Location.Code);
                      if ItemLedgEntry.FindSet then repeat
                        TempQuantity += ItemLedgEntry.Quantity;
                      until ItemLedgEntry.Next = 0;

                      if TempQuantity <> 0 then begin
                        InventoryLocation[i] := Location.Code;
                        InventoryQty[i] := TempQuantity;
                        i += 1;
                        TempQuantity := 0;
                      end;
                    until Location.Next = 0;

                    LocationText := '';
                    if InventoryQty[1] <> 0 then
                      LocationText := LocationCaption;

                    if Item1."Last Direct Cost" = 0 then
                      Item1."Last Direct Cost" := Item1."Unit Cost";
                    CostValueVariant := (Item1."Net Change" * Item1."Last Direct Cost");
                    Item1."Unit Price" := Round(Item1."Unit Price",0.01);
                    Item1."Last Direct Cost" := Round(Item1."Last Direct Cost",0.01);

                    ItemLedgEntry.SetRange("Location Code");
                    ItemLedgEntry.SetRange("Entry Type",1);
                    if ItemLedgEntry.FindLast then
                      SaleDateVariant := ItemLedgEntry."Posting Date"
                    else
                      SaleDateVariant := 0D;

                    if Item1."Price Includes VAT" then begin
                      if Vatpostingsetup.Get(Item1."VAT Bus. Posting Gr. (Price)",Item1."VAT Prod. Posting Group") then;
                      SalesValueVariant := Item1."Net Change"*(Item1."Unit Price"/(1+(Vatpostingsetup."VAT %" / 100)));
                    end else
                      SalesValueVariant := Item1."Net Change" * Item1."Unit Price";

                    if SalesValueVariant <> 0 then
                      GrossVariant := 100 * (SalesValueVariant - CostValueVariant) / SalesValueVariant
                    else
                      GrossVariant := 0;

                    NetChangeItemVariant := Item1."Net Change";
                    if ShowNoInventory then
                       NetChangeItemVariant := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin

                if Negativbeh and not NegativVolumeShow then begin
                  if ("Net Change" < 0) then
                    CurrReport.Skip;
                end
                else if NegativVolumeShow and not Negativbeh then begin
                  if ("Net Change" >= 0) then
                    CurrReport.Skip;
                end
                else if Negativbeh and NegativVolumeShow then
                   Error('Choose either');

                if Varermedbeholdning then begin
                  if not "Has Variants" then begin
                    if "Net Change" = 0 then
                      CurrReport.Skip;
                  end else begin
                    if not CheckInventory(Item) and ("Net Change" = 0) then
                      CurrReport.Skip;
                  end;
                end;

                if "Last Direct Cost" = 0 then
                  "Last Direct Cost" := "Unit Cost";

                CostValue := ("Net Change" * "Last Direct Cost");

                "Unit Price" := Round("Unit Price",0.01);
                "Last Direct Cost" := Round("Last Direct Cost",0.01);

                ItemLedgEntry.Reset;
                ItemLedgEntry.SetCurrentKey("Item No.","Entry Type","Posting Date");
                ItemLedgEntry.SetRange("Entry Type",1);
                ItemLedgEntry.SetFilter(ItemLedgEntry."Item No.",'%1',"No.");
                //-NPR5.32
                ItemLedgEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));
                //+NPR5.32
                if ItemLedgEntry.FindLast then
                  SaleDate := ItemLedgEntry."Posting Date"
                else
                  SaleDate := 0D;

                if "Price Includes VAT" then begin
                  if Vatpostingsetup.Get("VAT Bus. Posting Gr. (Price)","VAT Prod. Posting Group") then;
                  SalesValue := "Net Change"*("Unit Price"/(1+(Vatpostingsetup."VAT %" / 100)));
                end else
                  SalesValue := "Net Change" * "Unit Price";

                if SalesValue <> 0 then
                  Gross := 100 * (SalesValue - CostValue) / SalesValue
                else
                  Gross := 0;

                if not ViewSalesPrice then begin
                  Item."Unit Price" := 0;
                end;

                NetChangeItem := "Net Change";
                if ShowNoInventory then
                   NetChangeItem := 0;

                ItemTotalNetChange += NetChangeItem;
                ItemSalesValue += SalesValue;
                ItemTotalCostValue += CostValue;
            end;

            trigger OnPreDataItem()
            begin
                //-NPR5.39
                //CurrReport.CREATETOTALS("Net Change","Unit Price","Last Direct Cost",CostValue, SalesValue);
                //+NPR5.39
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(Varermedbeholdning;Varermedbeholdning)
                {
                    Caption = 'Show Only Items With Inventory';
                }
                field(ViewSalesPrice;ViewSalesPrice)
                {
                    Caption = 'View Sales Prices';
                }
                field(Negativbeh;Negativbeh)
                {
                    Caption = 'Hide Items With Negative Inventory';
                }
                field(NegativVolumeShow;NegativVolumeShow)
                {
                    Caption = 'Show Only Items With Negative Inventory';
                }
                field(ShowNoInventory;ShowNoInventory)
                {
                    Caption = 'Do Not Show Inventory';
                }
                field(ShowLocation;ShowLocation)
                {
                    Caption = 'Show Location';
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            //-NPR5.40 [307717]
            /*
            //-NPR5.32
            Item.SETFILTER("Date Filter",'%1..%2',010180D,(Tildato));
            //+NPR5.32
            */
            Item.SetFilter("Date Filter",'%1..%2',DMY2Date(1,1,1980),(Tildato));
            //+NPR5.40 [307717]

        end;
    }

    labels
    {
        LocationQty = 'Quantity';
    }

    trigger OnInitReport()
    begin
        Tildato:=Today();
        ShowLocation := true;
        ViewSalesPrice := true;
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

        //-NPR5.39
        // ObjectR.SETRANGE(ID, 6014612);
        // ObjectR.SETRANGE(Type, 3);
        // ObjectR.FIND('-');
        // ObjectInfo := FORMAT(ObjectR.ID)+', '+FORMAT(ObjectR."Version List");
        //+NPR5.39

        if Tildato = 0D then Error(Txt001);

        Itemfilter  := Item.GetFilters;
    end;

    var
        CompanyInfo: Record "Company Information";
        Location: Record Location;
        ItemLedgEntry: Record "Item Ledger Entry";
        CostValue: Decimal;
        CostValueVariant: Decimal;
        SalesValue: Decimal;
        SalesValueVariant: Decimal;
        GrossVariant: Decimal;
        Gross: Decimal;
        TempQuantity: Decimal;
        InventoryLocation: array [10] of Code[30];
        InventoryQty: array [10] of Decimal;
        SaleDateVariant: Date;
        SaleDate: Date;
        Tildato: Date;
        Bruttoavialt: Decimal;
        Varermedbeholdning: Boolean;
        ViewSalesPrice: Boolean;
        Negativbeh: Boolean;
        Vatpostingsetup: Record "VAT Posting Setup";
        ShowNoInventory: Boolean;
        NegativVolumeShow: Boolean;
        Itemfilter: Text[100];
        i: Integer;
        Item1: Record Item;
        Txt001: Label 'Date is required';
        Txt003: Label 'Total';
        Txt004: Label '�NAVIPARTNER Copenhagen 2002';
        Report_Caption: Label 'Item stock acc. date';
        Date_Caption: Label 'Date';
        No_Caption: Label 'Number';
        Desc_Caption: Label 'Description';
        NetChange_Caption: Label 'Inventory ';
        ItemVendorItemNo_Caption: Label 'Vendor item no.';
        UnitPrice_Caption: Label 'Sales price';
        DirCost_Caption: Label 'Last cost price';
        InvValue_Caption: Label 'Inventory value';
        Gross_Caption: Label 'Gross';
        SalesDate_Caption: Label 'Recent sales';
        LocationCaption: Label 'Location Code';
        LocationText: Text;
        ShowLocation: Boolean;
        ItemTotalNetChange: Decimal;
        ItemTotalCostValue: Decimal;
        NetChangeItem: Decimal;
        NetChangeItemVariant: Decimal;
        ItemSalesValue: Decimal;

    procedure CheckInventory(var localItem: Record Item): Boolean
    var
        localVariant: Record "Item Variant";
        localItem1: Record Item;
    begin
        localVariant.SetRange("Item No.", localItem."No.");
        if localVariant.FindFirst then begin
          localItem1.Get(localItem."No.");
          localItem1.CopyFilters(localItem);
          localItem1.SetRange("Variant Filter", localVariant.Code);
          localItem1.CalcFields("Has Variants","Net Change");
          if Varermedbeholdning then begin
            if (localItem1."Net Change" <> 0) then
              exit(true);
          end;

        end;

        exit(false);
    end;
}

