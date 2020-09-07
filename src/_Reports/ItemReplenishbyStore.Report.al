report 6014475 "NPR Item Replenish. by Store"
{
    // NPR4.16/TJ/20151115 CASE 222281 Report Created
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Replenishment by Store.rdlc';

    Caption = 'Inventory - List';
    PreviewMode = PrintLayout;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = WHERE("Replenishment System" = CONST(Purchase));
            RequestFilterFields = "Location Filter", "Date Filter";

            trigger OnAfterGetRecord()
            begin
                ItemVariant.SetRange("Item No.", "No.");
                Location.SetRange("Use As In-Transit", false);

                if LocationFilter <> '' then
                    Location.SetFilter(Code, LocationFilter)
                else begin
                    StoreGroup.SetRange("Blank Location", true);
                    StoreGroup.FindFirst;

                    if ItemVariant.FindSet then
                        repeat
                            CalcQtyAndInsert("No.", ItemVariant.Code, '');
                            SearchItemReplenishSetupAndInsert(StoreGroup.Code, "No.", ItemVariant.Code, '');
                        until ItemVariant.Next = 0
                    else begin
                        CalcQtyAndInsert("No.", '', '');
                        SearchItemReplenishSetupAndInsert(StoreGroup.Code, "No.", '', '');
                    end;
                end;

                if Location.FindSet then
                    repeat
                        if ItemVariant.FindSet then
                            repeat
                                CalcQtyAndInsert("No.", ItemVariant.Code, Location.Code);
                                SearchItemReplenishSetupAndInsert(Location."NPR Store Group Code", "No.", ItemVariant.Code, Location.Code);
                            until ItemVariant.Next = 0
                        else begin
                            CalcQtyAndInsert("No.", '', Location.Code);
                            SearchItemReplenishSetupAndInsert(Location."NPR Store Group Code", "No.", '', Location.Code);
                        end;
                    until Location.Next = 0;
            end;
        }
        dataitem("Integer"; "Integer")
        {
            column(CompanyName; CompanyName)
            {
            }
            column(ItemFilter; ItemFilter)
            {
            }
            column(Temp_ItemNo; ItemLedgEntryTemp."Item No.")
            {
            }
            column(ItemNoCaption; ItemNoCaptionLbl)
            {
            }
            column(Item_Description; Item.Description)
            {
            }
            column(ItemDescCaption; ItemDescCaptionLbl)
            {
            }
            column(Temp_VariantCode; ItemLedgEntryTemp."Variant Code")
            {
            }
            column(VariantCodeCaption; VariantCodeCaptionLbl)
            {
            }
            column(ItemVariant_Description; ItemVariant.Description)
            {
            }
            column(VariantDescCaption; VariantDescCaptionLbl)
            {
            }
            column(Temp_LocationCode; ItemLedgEntryTemp."Location Code")
            {
            }
            column(LocationCodeCaption; LocationCodeCaptionLbl)
            {
            }
            column(Temp_Inventory; ItemLedgEntryTemp.Quantity)
            {
            }
            column(InvCaption; InvCaptionLbl)
            {
            }
            column(FirstColCaption; FirstColCaptionLbl)
            {
            }
            column(Temp_QtyOnPurchOrders; ItemLedgEntryTemp."Remaining Quantity")
            {
            }
            column(QtyOnPurchOrderCaption; QtyOnPurchOrderCaptionLbl)
            {
            }
            column(SecondColCaption; SecondColCaptionLbl)
            {
            }
            column(Temp_QtyOnSaleOrders; ItemLedgEntryTemp."Invoiced Quantity")
            {
            }
            column(QtyOnSalesOrderCaption; QtyOnSalesOrderCaptionLbl)
            {
            }
            column(ThirdColCaption; ThirdColCaptionLbl)
            {
            }
            column(Temp_ProjectedInv; DecValue2)
            {
            }
            column(ProjectedInvCaption; ProjectedInvCaptionLbl)
            {
            }
            column(FourthColCaption; FourthColCaptionLbl)
            {
            }
            column(Temp_ReorderPoint; ItemLedgEntryTemp."Qty. per Unit of Measure")
            {
            }
            column(Temp_ReorderPointText; ItemLedgEntryTemp."Document No.")
            {
            }
            column(ReorderPointCaption; ReorderPointCaptionLbl)
            {
            }
            column(Temp_ReorderQty; ItemLedgEntryTemp."Shipped Qty. Not Returned")
            {
            }
            column(ReorderQtyCaption; ReorderQtyCaptionLbl)
            {
            }
            column(FifthColCaption; FifthColCaptionLbl)
            {
            }
            column(Temp_MaxInv; DecValue1)
            {
            }
            column(Temp_MaxInvText; ItemLedgEntryTemp.Description)
            {
            }
            column(MaxiInvCaption; MaxiInvCaptionLbl)
            {
            }
            column(Temp_NewProjectedInv; DecValue3)
            {
            }
            column(NewProjectedInvCaption; NewProjectedInvCaptionLbl)
            {
            }
            column(SixthColCaption; SixthColCaptionLbl)
            {
            }
            column(Temp_DiffCalcReason; ItemLedgEntryTemp.Area)
            {
            }
            column(Temp_OrderQty; OrderQty)
            {
            }
            column(OrderQtyCaption; OrderQtyCaptionLbl)
            {
            }
            column(ItemReplenByStoreCaption; ItemReplenByStoreCaptionLbl)
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(NotBelowReorderPointCaption; NotBelowReorderPointCaptionLbl)
            {
            }
            column(InvOverMaxCaption; InvOverMaxCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if Number = 1 then
                    ItemLedgEntryTemp.FindFirst
                else
                    ItemLedgEntryTemp.Next;

                Item.Get(ItemLedgEntryTemp."Item No.");
                if not ItemVariant.Get(ItemLedgEntryTemp."Item No.", ItemLedgEntryTemp."Variant Code") then
                    Clear(ItemVariant);

                if ItemLedgEntryTemp."Global Dimension 1 Code" = '' then
                    DecValue1 := 0
                else
                    Evaluate(DecValue1, ItemLedgEntryTemp."Global Dimension 1 Code");

                if ItemLedgEntryTemp."Global Dimension 2 Code" = '' then
                    DecValue2 := 0
                else
                    Evaluate(DecValue2, ItemLedgEntryTemp."Global Dimension 2 Code");

                if ItemLedgEntryTemp."External Document No." = '' then
                    DecValue3 := 0
                else
                    Evaluate(DecValue3, ItemLedgEntryTemp."External Document No.");

                if ShowItems = ShowItems::"Without Replenish. Setup" then
                    OrderQty := 0
                else
                    OrderQty := DecValue3 - DecValue2;

                if PrepareReqWksh and (OrderQty > 0) then begin  //worksheet is created only if new projected inventory is greater then projected inventory
                    ReqLine.Init;
                    ReqLine."Line No." := LineNo + 10000;
                    ReqLine."Planning Line Origin" := ReqLine."Planning Line Origin"::"Order Planning";
                    ReqLine.Type := ReqLine.Type::Item;
                    ReqLine."No." := ItemLedgEntryTemp."Item No.";
                    ReqLine."Location Code" := ItemLedgEntryTemp."Location Code";
                    ReqLine.Validate("No.");
                    ReqLine.Validate("Variant Code", ItemLedgEntryTemp."Variant Code");
                    //  ReqLine."Demand Type" := ItemReplenishText;
                    ReqLine.Level := 1;
                    ReqLine."Action Message" := ReqLine."Action Message"::New;
                    ReqLine."User ID" := UserId;
                    ReqLine."Qty. per Unit of Measure" := 1;
                    ReqLine.Validate(Quantity, OrderQty);
                    ReqLine.SetSupplyDates(OrderDate);
                    ReqLine.Validate("Supply From", Item."Vendor No.");
                    ReqLine.Insert;
                    LineNo := LineNo + 10000;
                end;
            end;

            trigger OnPreDataItem()
            begin
                ItemLedgEntryTemp.Reset;
                if ItemLedgEntryTemp.Count = 0 then
                    CurrReport.Break
                else
                    SetRange(Number, 1, ItemLedgEntryTemp.Count);
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
                    field(ExcludeNoReplenishSetup; ExcludeNoReplenishSetup)
                    {
                        Caption = 'Excl. Empty Replenish Setup';
                        Visible = false;
                        ApplicationArea=All;
                    }
                    field(ShowItems; ShowItems)
                    {
                        Caption = 'Show Items';
                        ApplicationArea=All;
                    }
                    field(PrepareReqWksh; PrepareReqWksh)
                    {
                        Caption = 'Prepare Order Planning';
                        ApplicationArea=All;
                    }
                    field(OrderDate; OrderDate)
                    {
                        Caption = 'Order Date';
                        Visible = false;
                        ApplicationArea=All;
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

    trigger OnPreReport()
    begin
        ItemFilter := Item.GetFilters;
        LocationFilter := Item.GetFilter("Location Filter");
        DateFilter := Item.GetFilter("Date Filter");
        if PrepareReqWksh then begin
            ReqLine.SetRange("Worksheet Template Name", '');
            ReqLine.SetRange("Journal Batch Name", '');
            if ReqLine.FindLast then
                LineNo := ReqLine."Line No.";
        end;
    end;

    var
        ItemFilter: Text;
        ItemReplenByStoreCaptionLbl: Label 'Item Replenishment by Store';
        CurrReportPageNoCaptionLbl: Label 'Page';
        ItemBlockedCaptionLbl: Label 'Blocked';
        ItemLedgEntryTemp: Record "Item Ledger Entry" temporary;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
        StoreGroup: Record "NPR Store Group";
        EntryNo: Integer;
        LocationFilter: Text;
        ItemDescCaptionLbl: Label 'Item Description';
        VariantCodeCaptionLbl: Label 'Variant Code';
        VariantDescCaptionLbl: Label 'Variant Description';
        InvCaptionLbl: Label 'Inventory';
        QtyOnPurchOrderCaptionLbl: Label 'Qty. on Purch. Order';
        QtyOnSalesOrderCaptionLbl: Label 'Qty. on Sales Order';
        FirstColCaptionLbl: Label '(1)';
        SecondColCaptionLbl: Label '(2)';
        ThirdColCaptionLbl: Label '(3)';
        FourthColCaptionLbl: Label '(4)=(1+2-3)';
        FifthColCaptionLbl: Label '(5)';
        SixthColCaptionLbl: Label '(6)=(4+5)';
        NotBelowReorderPointCaptionLbl: Label '* Projected inventory not below order point.';
        InvOverMaxCaptionLbl: Label '** Reorder quantity would pass set maximum inventory.';
        DecValue1: Decimal;
        DecValue2: Decimal;
        DecValue3: Decimal;
        ProjectedInvCaptionLbl: Label 'Projected Inventory';
        ReorderPointCaptionLbl: Label 'Reorder Point';
        ReorderQtyCaptionLbl: Label 'Reorder Quantity';
        MaxiInvCaptionLbl: Label 'Maximum Inventory';
        NewProjectedInvCaptionLbl: Label 'New Projected Inventory';
        ItemNoCaptionLbl: Label 'Item No.';
        LocationCodeCaptionLbl: Label 'Location Code';
        ExcludeNoReplenishSetup: Boolean;
        PrepareReqWksh: Boolean;
        ReqLine: Record "Requisition Line";
        LineNo: Integer;
        OrderDate: Date;
        DateFilter: Text;
        OrderQty: Decimal;
        OrderQtyCaptionLbl: Label 'Order Qty.';
        ItemReplenishText: Label 'Item Replenishment';
        ShowItems: Option All,"With Replenish. Setup","Without Replenish. Setup";

    local procedure InsertIntoTemp(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; QtyOnHandHere: Decimal; QtyPurchOrdHere: Decimal; QtySalesOrdHere: Decimal)
    begin
        ItemLedgEntryTemp.Reset;
        ItemLedgEntryTemp.SetRange("Item No.", ItemNo);
        ItemLedgEntryTemp.SetRange("Variant Code", VariantCode);
        ItemLedgEntryTemp.SetRange("Location Code", LocationCode);
        if not ItemLedgEntryTemp.FindFirst then begin
            EntryNo += 1;
            ItemLedgEntryTemp.Init;
            ItemLedgEntryTemp."Entry No." := EntryNo;
            ItemLedgEntryTemp."Item No." := ItemNo;
            ItemLedgEntryTemp."Variant Code" := VariantCode;
            ItemLedgEntryTemp."Location Code" := LocationCode;
            ItemLedgEntryTemp.Quantity := QtyOnHandHere; // Inventory (1)
            ItemLedgEntryTemp."Remaining Quantity" := QtyPurchOrdHere; // Qty. on Purch. Orders (2)
            ItemLedgEntryTemp."Invoiced Quantity" := QtySalesOrdHere;  // Qty. on Sales Orders (3)
            ItemLedgEntryTemp."Global Dimension 2 Code" := Format(QtyOnHandHere + QtyPurchOrdHere - QtySalesOrdHere); //Projected Inventory (4)=(1+2-3)
            ItemLedgEntryTemp.Insert;
        end else begin
            ItemLedgEntryTemp.Quantity := QtyOnHandHere;
            ItemLedgEntryTemp."Remaining Quantity" := QtyPurchOrdHere;
            ItemLedgEntryTemp."Invoiced Quantity" := QtySalesOrdHere;
            ItemLedgEntryTemp."Global Dimension 2 Code" := Format(QtyOnHandHere + QtyPurchOrdHere - QtySalesOrdHere);
            MakeTotals();
            ItemLedgEntryTemp.Modify;
        end;
    end;

    local procedure CalcQtyAndInsert(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
    var
        ItemHere: Record Item;
        QtyOnHandHere: Decimal;
        QtyPurchOrdHere: Decimal;
        QtySalesOrdHere: Decimal;
    begin
        with ItemHere do begin
            SetRange("No.", ItemNo);
            SetFilter("Variant Filter", VariantCode);
            SetFilter("Location Filter", LocationCode);
            if DateFilter <> '' then
                SetFilter("Date Filter", DateFilter); //influences only purch. and sales orders
            if FindFirst then begin
                CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order");
                QtyOnHandHere := Inventory;
                QtyPurchOrdHere := "Qty. on Purch. Order";
                QtySalesOrdHere := "Qty. on Sales Order";
            end;
        end;

        //IF (QtyOnHandHere <> 0) OR (QtyPurchOrdHere <> 0) OR (QtySalesOrdHere <> 0) THEN
        InsertIntoTemp(ItemNo, VariantCode, LocationCode, QtyOnHandHere, QtyPurchOrdHere, QtySalesOrdHere);
    end;

    local procedure SearchItemReplenishSetupAndInsert(StoreGroupHere: Code[20]; ItemNoHere: Code[20]; VariantCodeHere: Code[10]; LocationCodeHere: Code[10])
    var
        ItemReplenishByStore: Record "NPR Item Repl. by Store";
    begin
        ItemLedgEntryTemp.Reset;
        ItemLedgEntryTemp.SetRange("Item No.", ItemNoHere);
        ItemLedgEntryTemp.SetRange("Variant Code", VariantCodeHere);
        ItemLedgEntryTemp.SetRange("Location Code", LocationCodeHere);
        if ItemReplenishByStore.Get(StoreGroupHere, ItemNoHere, VariantCodeHere) then begin
            if ShowItems = ShowItems::"Without Replenish. Setup" then
                if ItemLedgEntryTemp.FindFirst then begin
                    ItemLedgEntryTemp.Delete;
                    exit;
                end;
            if not ItemLedgEntryTemp.FindFirst then
                InsertIntoTemp(ItemReplenishByStore."Item No.", ItemReplenishByStore."Variant Code", LocationCodeHere, 0, 0, 0);
            ItemLedgEntryTemp."Qty. per Unit of Measure" := ItemReplenishByStore."Reorder Point";
            ItemLedgEntryTemp."Document No." := ItemReplenishByStore."Reorder Point Text";
            ItemLedgEntryTemp."Shipped Qty. Not Returned" := ItemReplenishByStore."Reorder Quantity"; // Reorder Quantity (5)
            ItemLedgEntryTemp."Global Dimension 1 Code" := Format(ItemReplenishByStore."Maximum Inventory");
            ItemLedgEntryTemp.Description := ItemReplenishByStore."Maximum Inventory Text";
            MakeTotals();
            ItemLedgEntryTemp.Modify;
        end else
            if ShowItems = ShowItems::"With Replenish. Setup" then
                if ItemLedgEntryTemp.FindFirst then
                    ItemLedgEntryTemp.Delete;
    end;

    local procedure MakeTotals()
    var
        DecValueHere: Decimal;
        DecValueHere2: Decimal;
    begin
        if ItemLedgEntryTemp."Global Dimension 1 Code" = '' then
            DecValueHere := 0
        else
            Evaluate(DecValueHere, ItemLedgEntryTemp."Global Dimension 1 Code");

        if ItemLedgEntryTemp."Global Dimension 2 Code" = '' then
            DecValueHere2 := 0
        else
            Evaluate(DecValueHere2, ItemLedgEntryTemp."Global Dimension 2 Code");

        ItemLedgEntryTemp."External Document No." := Format(DecValueHere2 + ItemLedgEntryTemp."Shipped Qty. Not Returned");

        if ItemLedgEntryTemp."Document No." <> '' then //if reorder point has been set check if it's greater then projected inventory, else leave new projected inventory from previous code block
            if DecValueHere2 > ItemLedgEntryTemp."Qty. per Unit of Measure" then begin
                ItemLedgEntryTemp."External Document No." := ItemLedgEntryTemp."Global Dimension 2 Code"; // New Projected Inventory (6)=(4+5)
                ItemLedgEntryTemp.Area := '*';
            end else
                if ItemLedgEntryTemp.Description <> '' then //if max. inventory has been set then check if new inventory will be greater, else leave new projected inventory from previous code block
                    if (DecValueHere2 + ItemLedgEntryTemp."Shipped Qty. Not Returned") > DecValueHere then begin
                        ItemLedgEntryTemp."External Document No." := Format(DecValueHere);
                        ItemLedgEntryTemp.Area := '**';
                    end;
    end;
}

