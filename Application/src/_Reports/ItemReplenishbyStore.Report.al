report 6014475 "NPR Item Replenish. by Store"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Replenishment by Store.rdlc';
    Caption = 'Inventory - List';
    PreviewMode = PrintLayout;
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

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
                    StoreGroup.FindFirst();

                    if ItemVariant.FindSet() then
                        repeat
                            CalcQtyAndInsert("No.", ItemVariant.Code, '');
                            SearchItemReplenishSetupAndInsert(StoreGroup.Code, "No.", ItemVariant.Code, '');
                        until ItemVariant.Next() = 0
                    else begin
                        CalcQtyAndInsert("No.", '', '');
                        SearchItemReplenishSetupAndInsert(StoreGroup.Code, "No.", '', '');
                    end;
                end;

                if Location.FindSet() then
                    repeat
                        if ItemVariant.FindSet() then
                            repeat
                                CalcQtyAndInsert("No.", ItemVariant.Code, Location.Code);
                                SearchItemReplenishSetupAndInsert(Location."NPR Store Group Code", "No.", ItemVariant.Code, Location.Code);
                            until ItemVariant.Next() = 0
                        else begin
                            CalcQtyAndInsert("No.", '', Location.Code);
                            SearchItemReplenishSetupAndInsert(Location."NPR Store Group Code", "No.", '', Location.Code);
                        end;
                    until Location.Next() = 0;
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
            column(Temp_ItemNo; TempItemLedgEntry."Item No.")
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
            column(Temp_VariantCode; TempItemLedgEntry."Variant Code")
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
            column(Temp_LocationCode; TempItemLedgEntry."Location Code")
            {
            }
            column(LocationCodeCaption; LocationCodeCaptionLbl)
            {
            }
            column(Temp_Inventory; TempItemLedgEntry.Quantity)
            {
            }
            column(InvCaption; InvCaptionLbl)
            {
            }
            column(FirstColCaption; FirstColCaptionLbl)
            {
            }
            column(Temp_QtyOnPurchOrders; TempItemLedgEntry."Remaining Quantity")
            {
            }
            column(QtyOnPurchOrderCaption; QtyOnPurchOrderCaptionLbl)
            {
            }
            column(SecondColCaption; SecondColCaptionLbl)
            {
            }
            column(Temp_QtyOnSaleOrders; TempItemLedgEntry."Invoiced Quantity")
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
            column(Temp_ReorderPoint; TempItemLedgEntry."Qty. per Unit of Measure")
            {
            }
            column(Temp_ReorderPointText; TempItemLedgEntry."Document No.")
            {
            }
            column(ReorderPointCaption; ReorderPointCaptionLbl)
            {
            }
            column(Temp_ReorderQty; TempItemLedgEntry."Shipped Qty. Not Returned")
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
            column(Temp_MaxInvText; TempItemLedgEntry.Description)
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
            column(Temp_DiffCalcReason; TempItemLedgEntry.Area)
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
                    TempItemLedgEntry.FindFirst()
                else
                    TempItemLedgEntry.Next();

                Item.Get(TempItemLedgEntry."Item No.");
                if not ItemVariant.Get(TempItemLedgEntry."Item No.", TempItemLedgEntry."Variant Code") then
                    Clear(ItemVariant);

                if TempItemLedgEntry."Global Dimension 1 Code" = '' then
                    DecValue1 := 0
                else
                    Evaluate(DecValue1, TempItemLedgEntry."Global Dimension 1 Code");

                if TempItemLedgEntry."Global Dimension 2 Code" = '' then
                    DecValue2 := 0
                else
                    Evaluate(DecValue2, TempItemLedgEntry."Global Dimension 2 Code");

                if TempItemLedgEntry."External Document No." = '' then
                    DecValue3 := 0
                else
                    Evaluate(DecValue3, TempItemLedgEntry."External Document No.");

                if ShowItems = ShowItems::"Without Replenish. Setup" then
                    OrderQty := 0
                else
                    OrderQty := DecValue3 - DecValue2;

                if PrepareReqWksh and (OrderQty > 0) then begin  //worksheet is created only if new projected inventory is greater then projected inventory
                    ReqLine.Init();
                    ReqLine."Line No." := LineNo + 10000;
                    ReqLine."Planning Line Origin" := ReqLine."Planning Line Origin"::"Order Planning";
                    ReqLine.Type := ReqLine.Type::Item;
                    ReqLine."No." := TempItemLedgEntry."Item No.";
                    ReqLine."Location Code" := TempItemLedgEntry."Location Code";
                    ReqLine.Validate("No.");
                    ReqLine.Validate("Variant Code", TempItemLedgEntry."Variant Code");
                    //  ReqLine."Demand Type" := ItemReplenishText;
                    ReqLine.Level := 1;
                    ReqLine."Action Message" := ReqLine."Action Message"::New;
# pragma warning disable AA0139
                    ReqLine."User ID" := UserId;
# pragma warning restore
                    ReqLine."Qty. per Unit of Measure" := 1;
                    ReqLine.Validate(Quantity, OrderQty);
                    ReqLine.SetSupplyDates(OrderDate);
                    ReqLine.Validate("Supply From", Item."Vendor No.");
                    ReqLine.Insert();
                    LineNo := LineNo + 10000;
                end;
            end;

            trigger OnPreDataItem()
            begin
                TempItemLedgEntry.Reset();
                if TempItemLedgEntry.Count() = 0 then
                    CurrReport.Break()
                else
                    SetRange(Number, 1, TempItemLedgEntry.Count());
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
                group(Options)
                {
                    Caption = 'Options';
                    field("Exclude No Replenish Setup"; ExcludeNoReplenishSetup)
                    {

                        Caption = 'Excl. Empty Replenish Setup';
                        ToolTip = 'Specifies the value of the Excl. Empty Replenish Setup field';
                        Visible = false;
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Items"; ShowItems)
                    {

                        Caption = 'Show Items';
                        OptionCaption = 'All,With Replenish. Setup,Without Replenish. Setup';
                        ToolTip = 'Specifies the value of the Show Items field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Prepare Req Wksh"; PrepareReqWksh)
                    {

                        Caption = 'Prepare Order Planning';
                        ToolTip = 'Specifies the value of the Prepare Order Planning field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Order Date"; OrderDate)
                    {

                        Caption = 'Order Date';
                        ToolTip = 'Specifies the value of the Order Date field';
                        Visible = false;
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }

    }


    trigger OnPreReport()
    begin
        ItemFilter := Item.GetFilters;
        LocationFilter := Item.GetFilter("Location Filter");
        DateFilter := Item.GetFilter("Date Filter");
        if PrepareReqWksh then begin
            ReqLine.SetRange("Worksheet Template Name", '');
            ReqLine.SetRange("Journal Batch Name", '');
            if ReqLine.FindLast() then
                LineNo := ReqLine."Line No.";
        end;
    end;

    var
        TempItemLedgEntry: Record "Item Ledger Entry" temporary;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
        StoreGroup: Record "NPR Store Group";
        ReqLine: Record "Requisition Line";
        ExcludeNoReplenishSetup: Boolean;
        PrepareReqWksh: Boolean;
        OrderDate: Date;
        DecValue1: Decimal;
        DecValue2: Decimal;
        DecValue3: Decimal;
        OrderQty: Decimal;
        EntryNo: Integer;
        LineNo: Integer;
        FirstColCaptionLbl: Label '(1)';
        SecondColCaptionLbl: Label '(2)';
        ThirdColCaptionLbl: Label '(3)';
        FourthColCaptionLbl: Label '(4)=(1+2-3)';
        FifthColCaptionLbl: Label '(5)';
        SixthColCaptionLbl: Label '(6)=(4+5)';
        InvOverMaxCaptionLbl: Label '** Reorder quantity would pass set maximum inventory.';
        NotBelowReorderPointCaptionLbl: Label '* Projected inventory not below order point.';
        InvCaptionLbl: Label 'Inventory';
        ItemDescCaptionLbl: Label 'Item Description';
        ItemNoCaptionLbl: Label 'Item No.';
        ItemReplenByStoreCaptionLbl: Label 'Item Replenishment by Store';
        LocationCodeCaptionLbl: Label 'Location Code';
        MaxiInvCaptionLbl: Label 'Maximum Inventory';
        NewProjectedInvCaptionLbl: Label 'New Projected Inventory';
        OrderQtyCaptionLbl: Label 'Order Qty.';
        CurrReportPageNoCaptionLbl: Label 'Page';
        ProjectedInvCaptionLbl: Label 'Projected Inventory';
        QtyOnPurchOrderCaptionLbl: Label 'Qty. on Purch. Order';
        QtyOnSalesOrderCaptionLbl: Label 'Qty. on Sales Order';
        ReorderPointCaptionLbl: Label 'Reorder Point';
        ReorderQtyCaptionLbl: Label 'Reorder Quantity';
        VariantCodeCaptionLbl: Label 'Variant Code';
        VariantDescCaptionLbl: Label 'Variant Description';
        ShowItems: Option All,"With Replenish. Setup","Without Replenish. Setup";
        DateFilter: Text;
        ItemFilter: Text;
        LocationFilter: Text;

    local procedure InsertIntoTemp(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; QtyOnHandHere: Decimal; QtyPurchOrdHere: Decimal; QtySalesOrdHere: Decimal)
    begin
        TempItemLedgEntry.Reset();
        TempItemLedgEntry.SetRange("Item No.", ItemNo);
        TempItemLedgEntry.SetRange("Variant Code", VariantCode);
        TempItemLedgEntry.SetRange("Location Code", LocationCode);
        if not TempItemLedgEntry.FindFirst() then begin
            EntryNo += 1;
            TempItemLedgEntry.Init();
            TempItemLedgEntry."Entry No." := EntryNo;
            TempItemLedgEntry."Item No." := ItemNo;
            TempItemLedgEntry."Variant Code" := VariantCode;
            TempItemLedgEntry."Location Code" := LocationCode;
            TempItemLedgEntry.Quantity := QtyOnHandHere; // Inventory (1)
            TempItemLedgEntry."Remaining Quantity" := QtyPurchOrdHere; // Qty. on Purch. Orders (2)
            TempItemLedgEntry."Invoiced Quantity" := QtySalesOrdHere;  // Qty. on Sales Orders (3)
            TempItemLedgEntry."Global Dimension 2 Code" := Format(QtyOnHandHere + QtyPurchOrdHere - QtySalesOrdHere); //Projected Inventory (4)=(1+2-3)
            TempItemLedgEntry.Insert();
        end else begin
            TempItemLedgEntry.Quantity := QtyOnHandHere;
            TempItemLedgEntry."Remaining Quantity" := QtyPurchOrdHere;
            TempItemLedgEntry."Invoiced Quantity" := QtySalesOrdHere;
            TempItemLedgEntry."Global Dimension 2 Code" := Format(QtyOnHandHere + QtyPurchOrdHere - QtySalesOrdHere);
            MakeTotals();
            TempItemLedgEntry.Modify();
        end;
    end;

    local procedure CalcQtyAndInsert(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
    var
        ItemHere: Record Item;
        QtyOnHandHere: Decimal;
        QtyPurchOrdHere: Decimal;
        QtySalesOrdHere: Decimal;
    begin
        ItemHere.SetRange("No.", ItemNo);
        ItemHere.SetFilter("Variant Filter", VariantCode);
        ItemHere.SetFilter("Location Filter", LocationCode);
        if DateFilter <> '' then
            ItemHere.SetFilter("Date Filter", DateFilter); //influences only purch. and sales orders
        if ItemHere.FindFirst() then begin
            ItemHere.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. on Sales Order");
            QtyOnHandHere := ItemHere.Inventory;
            QtyPurchOrdHere := ItemHere."Qty. on Purch. Order";
            QtySalesOrdHere := ItemHere."Qty. on Sales Order";
        end;

        InsertIntoTemp(ItemNo, VariantCode, LocationCode, QtyOnHandHere, QtyPurchOrdHere, QtySalesOrdHere);
    end;

    local procedure SearchItemReplenishSetupAndInsert(StoreGroupHere: Code[20]; ItemNoHere: Code[20]; VariantCodeHere: Code[10]; LocationCodeHere: Code[10])
    var
        ItemReplenishByStore: Record "NPR Item Repl. by Store";
    begin
        TempItemLedgEntry.Reset();
        TempItemLedgEntry.SetRange("Item No.", ItemNoHere);
        TempItemLedgEntry.SetRange("Variant Code", VariantCodeHere);
        TempItemLedgEntry.SetRange("Location Code", LocationCodeHere);
        if ItemReplenishByStore.Get(StoreGroupHere, ItemNoHere, VariantCodeHere) then begin
            if ShowItems = ShowItems::"Without Replenish. Setup" then
                if TempItemLedgEntry.FindFirst() then begin
                    TempItemLedgEntry.Delete();
                    exit;
                end;
            if not TempItemLedgEntry.FindFirst() then
                InsertIntoTemp(ItemReplenishByStore."Item No.", ItemReplenishByStore."Variant Code", LocationCodeHere, 0, 0, 0);
            TempItemLedgEntry."Qty. per Unit of Measure" := ItemReplenishByStore."Reorder Point";
# pragma warning disable AA0139
            TempItemLedgEntry."Document No." := ItemReplenishByStore."Reorder Point Text";
# pragma warning restore
            TempItemLedgEntry."Shipped Qty. Not Returned" := ItemReplenishByStore."Reorder Quantity"; // Reorder Quantity (5)
            TempItemLedgEntry."Global Dimension 1 Code" := Format(ItemReplenishByStore."Maximum Inventory");
            TempItemLedgEntry.Description := ItemReplenishByStore."Maximum Inventory Text";
            MakeTotals();
            TempItemLedgEntry.Modify();
        end else
            if ShowItems = ShowItems::"With Replenish. Setup" then
                if TempItemLedgEntry.FindFirst() then
                    TempItemLedgEntry.Delete();
    end;

    local procedure MakeTotals()
    var
        DecValueHere: Decimal;
        DecValueHere2: Decimal;
    begin
        if TempItemLedgEntry."Global Dimension 1 Code" = '' then
            DecValueHere := 0
        else
            Evaluate(DecValueHere, TempItemLedgEntry."Global Dimension 1 Code");

        if TempItemLedgEntry."Global Dimension 2 Code" = '' then
            DecValueHere2 := 0
        else
            Evaluate(DecValueHere2, TempItemLedgEntry."Global Dimension 2 Code");

        TempItemLedgEntry."External Document No." := Format(DecValueHere2 + TempItemLedgEntry."Shipped Qty. Not Returned");
        if TempItemLedgEntry."Document No." <> '' then //if reorder point has been set check if it's greater then projected inventory, else leave new projected inventory from previous code block
            if DecValueHere2 > TempItemLedgEntry."Qty. per Unit of Measure" then begin
                TempItemLedgEntry."External Document No." := TempItemLedgEntry."Global Dimension 2 Code"; // New Projected Inventory (6)=(4+5)
                TempItemLedgEntry.Area := '*';
            end else
                if TempItemLedgEntry.Description <> '' then //if max. inventory has been set then check if new inventory will be greater, else leave new projected inventory from previous code block
                    if (DecValueHere2 + TempItemLedgEntry."Shipped Qty. Not Returned") > DecValueHere then begin
                        TempItemLedgEntry."External Document No." := Format(DecValueHere);
                        TempItemLedgEntry.Area := '**';
                    end;
    end;
}

