report 6014612 "NPR Inventory per Variant/date"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Inventory per Variant at date.rdlc';
    Caption = 'Inventory Per Date';
    Description = 'Inventory per Variant at date';
    PreviewMode = Normal;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem(ReportHdr; "Integer")
        {
            DataItemTableView = SORTING(Number);
            MaxIteration = 1;
            column(COMPANYNAME; CompanyName)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(Report_Caption; Report_Caption)
            {
            }
            column(Date_Caption; Date_Caption)
            {
            }
            column(Itemfilter; Itemfilter)
            {
            }
            column(tildato; Tildato)
            {
            }
            column(No_Caption; No_Caption)
            {
            }
            column(Desc_Caption; Desc_Caption)
            {
            }
            column(NetChange_Caption; NetChange_Caption)
            {
            }
            column(ItemVendorItemNo_Caption; ItemVendorItemNo_Caption)
            {
            }
            column(UnitPrice_Caption; UnitPrice_Caption)
            {
            }
            column(DirCost_Caption; DirCost_Caption)
            {
            }
            column(InvValue_Caption; InvValue_Caption)
            {
            }
            column(brutto_Caption; Gross_Caption)
            {
            }
            column(SalesDate_Caption; SalesDate_Caption)
            {
            }
            column(TotalTxt; Txt003)
            {
            }
            column(NaviPartTxt; Txt004)
            {
            }
            column(ViewSalesPrice; ViewSalesPrice)
            {
            }
            column(ShowNoInventory; ShowNoInventory)
            {
            }
        }
        dataitem(Item; Item)
        {
            CalcFields = "Net Change", "NPR Has Variants";
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Vendor No.", "Item Category Code", "NPR Group sale", "Location Filter", "Date Filter";
            column(ShowLocation; ShowLocation)
            {
            }
            column(ItemNo; Item."No.")
            {
            }
            column(ItemDesc; Item.Description)
            {
            }
            column(ItemNetChange; NetChangeItem)
            {
            }
            column(ItemVendorItemNo; Item."Vendor Item No.")
            {
            }
            column(ItemUnitPrice; Item."Unit Price")
            {
                AutoFormatType = 1;
            }
            column(ItemLastDirCost; Item."Last Direct Cost")
            {
                AutoFormatType = 1;
            }
            column(bruttoavialt; Bruttoavialt)
            {
                AutoFormatType = 1;
            }
            column(CostValue; CostValue)
            {
                AutoFormatType = 1;
            }
            column(GrossValue; Gross)
            {
                AutoFormatType = 1;
            }
            column(SaleDate; Format(SaleDate))
            {
            }
            column(ItemTotalNetChange; ItemTotalNetChange)
            {
            }
            column(ItemTotalCostValue; ItemTotalCostValue)
            {
            }
            column(ItemSalesValue; ItemSalesValue)
            {
            }
            dataitem(ItemVariant; "Item Variant")
            {
                DataItemLink = "Item No." = FIELD("No.");
                DataItemTableView = SORTING("Item No.", Code);
                column(ItemVarItemNo; ItemVariant."Item No.")
                {
                }
                column(ItemVarCode; ItemVariant.Code)
                {
                }
                column(ItemVarDescription; ItemVariant.Description)
                {
                }
                column(Item1NetChange; NetChangeItemVariant)
                {
                }
                column(InventoryLocation1; InventoryLocation[1])
                {
                }
                column(InventoryQty1; InventoryQty[1])
                {
                }
                column(InventoryLocation2; InventoryLocation[2])
                {
                }
                column(InventoryQty2; InventoryQty[2])
                {
                }
                column(InventoryLocation3; InventoryLocation[3])
                {
                }
                column(InventoryQty3; InventoryQty[3])
                {
                }
                column(InventoryLocation4; InventoryLocation[4])
                {
                }
                column(InventoryQty4; InventoryQty[4])
                {
                }
                column(InventoryLocation5; InventoryLocation[5])
                {
                }
                column(InventoryQty5; InventoryQty[5])
                {
                }
                column(InventoryLocation6; InventoryLocation[6])
                {
                }
                column(InventoryQty6; InventoryQty[6])
                {
                }
                column(InventoryLocation7; InventoryLocation[7])
                {
                }
                column(InventoryQty7; InventoryQty[7])
                {
                }
                column(CostValueVariant; CostValueVariant)
                {
                    AutoFormatType = 1;
                }
                column(ItemVarGross; GrossVariant)
                {
                    AutoFormatType = 1;
                }
                column(ItemVarSaleDate; Format(SaleDateVariant))
                {
                }
                column(LocationCaption; LocationText)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Item1.Get(Item."No.");
                    Item1.CopyFilters(Item);
                    Item1.SetRange("Variant Filter", Code);
                    IF Item1.GETFILTER("Location Filter") = '' THEN BEGIN
                        if not ShowBlankLocation then
                            Item1.SetFilter("Location Filter", '<>%1', '');
                    END;
                    Item1.CalcFields("NPR Has Variants", "Net Change");
                    if Varermedbeholdning then begin
                        if Item1."Net Change" = 0 then
                            CurrReport.Skip();
                    end;

                    i := 1;
                    Clear(InventoryLocation);
                    Clear(InventoryQty);
                    Clear(ItemLedgEntry);
                    TempQuantity := 0;

                    ItemLedgEntry.Reset();
                    ItemLedgEntry.SetRange("Item No.", Item."No.");
                    ItemLedgEntry.SetRange("Variant Code", Code);
                    ItemLedgEntry.SetFilter("Posting Date", Item1.GetFilter("Date Filter"));
                    if ShowBlankLocation then begin
                        ItemLedgEntry.SetRange("Location Code", '');
                        if ItemLedgEntry.FindSet() then
                            repeat
                                TempQuantity += ItemLedgEntry.Quantity;
                            until ItemLedgEntry.Next() = 0;

                        if TempQuantity <> 0 then begin
                            InventoryLocation[i] := '';
                            InventoryQty[i] := TempQuantity;
                            i += 1;
                            TempQuantity := 0;
                        end;
                    end;

                    if Location.FindSet() then
                        repeat
                            ItemLedgEntry.SetRange("Location Code");
                            ItemLedgEntry.SetRange("Location Code", Location.Code);
                            if ItemLedgEntry.FindSet() then
                                repeat
                                    TempQuantity += ItemLedgEntry.Quantity;
                                until ItemLedgEntry.Next() = 0;

                            if TempQuantity <> 0 then begin
                                InventoryLocation[i] := Location.Code;
                                InventoryQty[i] := TempQuantity;
                                i += 1;
                                TempQuantity := 0;
                            end;
                        until Location.Next() = 0;

                    LocationText := '';
                    if InventoryQty[1] <> 0 then
                        LocationText := LocationCaption;

                    if Item1."Last Direct Cost" = 0 then
                        Item1."Last Direct Cost" := Item1."Unit Cost";
                    CostValueVariant := (Item1."Net Change" * Item1."Last Direct Cost");
                    Item1."Unit Price" := Round(Item1."Unit Price", 0.01);
                    Item1."Last Direct Cost" := Round(Item1."Last Direct Cost", 0.01);

                    ItemLedgEntry.SetRange("Location Code");
                    ItemLedgEntry.SetRange("Entry Type", 1);
                    if ItemLedgEntry.FindLast() then
                        SaleDateVariant := ItemLedgEntry."Posting Date"
                    else
                        SaleDateVariant := 0D;

                    if Item1."Price Includes VAT" then begin
                        if Vatpostingsetup.Get(Item1."VAT Bus. Posting Gr. (Price)", Item1."VAT Prod. Posting Group") then;
                        SalesValueVariant := Item1."Net Change" * (Item1."Unit Price" / (1 + (Vatpostingsetup."VAT %" / 100)));
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
            var
                ChooseErr: Label 'Choose either';
            begin

                if Negativbeh and not NegativVolumeShow then begin
                    if ("Net Change" < 0) then
                        CurrReport.Skip();
                end
                else
                    if NegativVolumeShow and not Negativbeh then begin
                        if ("Net Change" >= 0) then
                            CurrReport.Skip();
                    end
                    else
                        if Negativbeh and NegativVolumeShow then
                            Error(ChooseErr);

                if Varermedbeholdning then begin
                    if not "NPR Has Variants" then begin
                        if "Net Change" = 0 then
                            CurrReport.Skip();
                    end else begin
                        if not CheckInventory(Item) and ("Net Change" = 0) then
                            CurrReport.Skip();
                    end;
                end;

                if "Last Direct Cost" = 0 then
                    "Last Direct Cost" := "Unit Cost";

                CostValue := ("Net Change" * "Last Direct Cost");

                "Unit Price" := Round("Unit Price", 0.01);
                "Last Direct Cost" := Round("Last Direct Cost", 0.01);

                ItemLedgEntry.Reset();
                ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type", "Posting Date");
                ItemLedgEntry.SetRange("Entry Type", 1);
                ItemLedgEntry.SetFilter(ItemLedgEntry."Item No.", '%1', "No.");
                ItemLedgEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));
                if ItemLedgEntry.FindLast() then
                    SaleDate := ItemLedgEntry."Posting Date"
                else
                    SaleDate := 0D;

                if "Price Includes VAT" then begin
                    if Vatpostingsetup.Get("VAT Bus. Posting Gr. (Price)", "VAT Prod. Posting Group") then;
                    SalesValue := "Net Change" * ("Unit Price" / (1 + (Vatpostingsetup."VAT %" / 100)));
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
                IF Item.GETFILTER("Location Filter") = '' THEN BEGIN
                    IF NOT ShowBlankLocation THEN
                        Item.SETFILTER("Location Filter", '<>%1', '');
                END;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Varer med beholdning"; Varermedbeholdning)
                {
                    Caption = 'Show Only Items With Inventory';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Only Items With Inventory field';
                }
                field("View Sales Price"; ViewSalesPrice)
                {
                    Caption = 'View Sales Prices';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the View Sales Prices field';
                }
                field("Negativ beh"; Negativbeh)
                {
                    Caption = 'Hide Items With Negative Inventory';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hide Items With Negative Inventory field';
                }
                field("Negativ Volume Show"; NegativVolumeShow)
                {
                    Caption = 'Show Only Items With Negative Inventory';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Only Items With Negative Inventory field';
                }
                field("Show No Inventory"; ShowNoInventory)
                {
                    Caption = 'Do Not Show Inventory';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Do Not Show Inventory field';
                }
                field("Show Location"; ShowLocation)
                {
                    Caption = 'Show Location';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Location field';
                }
                field("Show Blank Location"; ShowBlankLocation)
                {
                    Caption = 'Show Blank Location';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Blank Location field';
                }
            }
        }

        trigger OnOpenPage()
        begin
            Item.SetFilter("Date Filter", '%1..%2', DMY2Date(1, 1, 1980), (Tildato));
        end;
    }

    labels
    {
        LocationQty = 'Quantity';
    }

    trigger OnInitReport()
    begin
        Tildato := Today();
        ShowLocation := true;
        ViewSalesPrice := true;
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        if Tildato = 0D then
            Error(Txt001);

        Itemfilter := Item.GetFilters;
        Location.RESET();
        IF Item.GETFILTER("Location Filter") <> '' THEN
            Location.SETRANGE(Code, Item.GETFILTER("Location Filter"));

    end;

    var
        CompanyInfo: Record "Company Information";
        Item1: Record Item;
        ItemLedgEntry: Record "Item Ledger Entry";
        Location: Record Location;
        Vatpostingsetup: Record "VAT Posting Setup";
        Negativbeh: Boolean;
        NegativVolumeShow: Boolean;
        ShowBlankLocation: Boolean;
        ShowLocation: Boolean;
        ShowNoInventory: Boolean;
        Varermedbeholdning: Boolean;
        ViewSalesPrice: Boolean;
        InventoryLocation: array[10] of Code[30];
        SaleDate: Date;
        SaleDateVariant: Date;
        Tildato: Date;
        Bruttoavialt: Decimal;
        CostValue: Decimal;
        CostValueVariant: Decimal;
        Gross: Decimal;
        GrossVariant: Decimal;
        InventoryQty: array[10] of Decimal;
        ItemSalesValue: Decimal;
        ItemTotalCostValue: Decimal;
        ItemTotalNetChange: Decimal;
        NetChangeItem: Decimal;
        NetChangeItemVariant: Decimal;
        SalesValue: Decimal;
        SalesValueVariant: Decimal;
        TempQuantity: Decimal;
        i: Integer;
        Txt004: Label 'ˆNAVIPARTNER Copenhagen 2002';
        Date_Caption: Label 'Date';
        Txt001: Label 'Date is required';
        Desc_Caption: Label 'Description';
        Gross_Caption: Label 'Gross';
        NetChange_Caption: Label 'Inventory ';
        InvValue_Caption: Label 'Inventory value';
        Report_Caption: Label 'Item stock acc. date';
        DirCost_Caption: Label 'Last cost price';
        LocationCaption: Label 'Location Code';
        No_Caption: Label 'Number';
        SalesDate_Caption: Label 'Recent sales';
        UnitPrice_Caption: Label 'Sales price';
        Txt003: Label 'Total';
        ItemVendorItemNo_Caption: Label 'Vendor item no.';
        LocationText: Text;
        Itemfilter: Text[100];


    procedure CheckInventory(var localItem: Record Item): Boolean
    var
        localItem1: Record Item;
        localVariant: Record "Item Variant";
    begin
        localVariant.SetRange("Item No.", localItem."No.");
        if localVariant.FindFirst() then begin
            localItem1.Get(localItem."No.");
            localItem1.CopyFilters(localItem);
            localItem1.SetRange("Variant Filter", localVariant.Code);
            localItem1.CalcFields("NPR Has Variants", "Net Change");
            if Varermedbeholdning then begin
                if (localItem1."Net Change" <> 0) then
                    exit(true);
            end;

        end;

        exit(false);
    end;
}

