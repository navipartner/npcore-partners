codeunit 6151425 "NPR Magento Proj.Avail.Balan."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Item Mgt.", 'OnCalcStockQty', '', true, true)]
    local procedure CalcProjectedAvailableInventory(MagentoSetup: Record "NPR Magento Setup"; ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text; var StockQty: Decimal; var Handled: Boolean)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        GrossRequirement: Decimal;
        PlannedOrderRcpt: Decimal;
        ScheduledRcpt: Decimal;
        PlannedOrderReleases: Decimal;
        ProjAvailableBalance: Decimal;
        ExpectedInventory: Decimal;
        QtyAvailable: Decimal;
    begin
        if Handled then
            exit;

        if not IsSubscriber(MagentoSetup) then
            exit;

        Handled := true;

        if not Item.Get(ItemNo) then
            exit;

        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        if VariantFilter <> '' then begin
            Item.SetFilter("Variant Filter", VariantFilter);
            Item.SetFilter("Location Filter", LocationFilter);
            Item.SetRange("Date Filter", 0D, Today);
            ItemAvailFormsMgt.CalcAvailQuantities(
              Item, true,
              GrossRequirement, PlannedOrderRcpt, ScheduledRcpt,
              PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);

            StockQty := ProjAvailableBalance;
            exit;
        end;

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then begin
            StockQty := 0;
            repeat
                Item.SetFilter("Variant Filter", ItemVariant.Code);
                Item.SetFilter("Location Filter", LocationFilter);
                Item.SetRange("Date Filter", 0D, Today);
                ItemAvailFormsMgt.CalcAvailQuantities(
                  Item, true,
                  GrossRequirement, PlannedOrderRcpt, ScheduledRcpt,
                  PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);

                StockQty += ProjAvailableBalance;
            until ItemVariant.Next() = 0;

            exit;
        end;

        Item.SetFilter("Location Filter", LocationFilter);
        Item.SetRange("Date Filter", 0D, Today);
        ItemAvailFormsMgt.CalcAvailQuantities(
          Item, true,
          GrossRequirement, PlannedOrderRcpt, ScheduledRcpt,
          PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);

        StockQty := ProjAvailableBalance;
    end;

    local procedure RecRef2TempSalesLine(RecRef: RecordRef; var TempSalesLine: Record "Sales Line" temporary): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempSalesLine);
            TempSalesLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(SalesLine);
        if not SalesLine.Find() then
            exit(false);

        TempSalesLine.Init();
        TempSalesLine := SalesLine;
        TempSalesLine.Insert();
        exit(true)
    end;

    local procedure RecRef2TempPurchLine(RecRef: RecordRef; var TempPurchLine: Record "Purchase Line" temporary): Boolean
    var
        PurchLine: Record "Purchase Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempPurchLine);
            TempPurchLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(PurchLine);
        if not PurchLine.Find() then
            exit(false);

        TempPurchLine.Init();
        TempPurchLine := PurchLine;
        TempPurchLine.Insert();
        exit(true);
    end;

    local procedure RecRef2TempReqLine(RecRef: RecordRef; var TempReqLine: Record "Requisition Line" temporary): Boolean
    var
        ReqLine: Record "Requisition Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempReqLine);
            TempReqLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(ReqLine);
        if not ReqLine.Find() then
            exit(false);

        TempReqLine.Init();
        TempReqLine := ReqLine;
        TempReqLine.Insert();
        exit(true);
    end;

    local procedure RecRef2TempAssemblyHeader(RecRef: RecordRef; var TempAssemblyHeader: Record "Assembly Header" temporary): Boolean
    var
        AssemblyHeader: Record "Assembly Header";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempAssemblyHeader);
            TempAssemblyHeader.Insert();
            exit(true);
        end;

        RecRef.SetTable(AssemblyHeader);
        if not AssemblyHeader.Find() then
            exit(false);

        TempAssemblyHeader.Init();
        TempAssemblyHeader := AssemblyHeader;
        TempAssemblyHeader.Insert();
        exit(true);
    end;

    local procedure RecRef2TempAssemblyLine(RecRef: RecordRef; var TempAssemblyLine: Record "Assembly Line" temporary): Boolean
    var
        AssemblyLine: Record "Assembly Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempAssemblyLine);
            TempAssemblyLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(AssemblyLine);
        if not AssemblyLine.Find() then
            exit(false);

        TempAssemblyLine.Init();
        TempAssemblyLine := AssemblyLine;
        TempAssemblyLine.Insert();
        exit(true);
    end;

    local procedure RecRef2TempJobPlanningLine(RecRef: RecordRef; var TempJobPlanningLine: Record "Job Planning Line" temporary): Boolean
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempJobPlanningLine);
            TempJobPlanningLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(JobPlanningLine);
        if not JobPlanningLine.Find() then
            exit(false);

        TempJobPlanningLine.Init();
        TempJobPlanningLine := JobPlanningLine;
        TempJobPlanningLine.Insert();
        exit(true);
    end;

    local procedure RecRef2TempProdOrderLine(RecRef: RecordRef; var TempProdOrderLine: Record "Prod. Order Line" temporary): Boolean
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempProdOrderLine);
            TempProdOrderLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(ProdOrderLine);
        if not ProdOrderLine.Find() then
            exit(false);

        TempProdOrderLine.Init();
        TempProdOrderLine := ProdOrderLine;
        TempProdOrderLine.Insert();
        exit(true);
    end;

    local procedure RecRef2TempProdOrderComponent(RecRef: RecordRef; var TempProdOrderComponent: Record "Prod. Order Component" temporary): Boolean
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempProdOrderComponent);
            TempProdOrderComponent.Insert();
            exit(true);
        end;

        RecRef.SetTable(ProdOrderComponent);
        if not ProdOrderComponent.Find() then
            exit(false);

        TempProdOrderComponent.Init();
        TempProdOrderComponent := ProdOrderComponent;
        TempProdOrderComponent.Insert();
        exit(true);
    end;

    local procedure RecRef2TempTransLine(RecRef: RecordRef; var TempTransLine: Record "Transfer Line" temporary): Boolean
    var
        TransLine: Record "Transfer Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempTransLine);
            TempTransLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(TransLine);
        if not TransLine.Find() then
            exit(false);

        TempTransLine.Init();
        TempTransLine := TransLine;
        TempTransLine.Insert();
        exit(true);
    end;

    local procedure RecRef2TempServiceLine(RecRef: RecordRef; var TempServiceLine: Record "Service Line" temporary): Boolean
    var
        ServiceLine: Record "Service Line";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempServiceLine);
            TempServiceLine.Insert();
            exit(true);
        end;

        RecRef.SetTable(ServiceLine);
        if not ServiceLine.Find() then
            exit(false);

        TempServiceLine.Init();
        TempServiceLine := ServiceLine;
        TempServiceLine.Insert();
        exit(true);
    end;

    local procedure RecRef2TempPlanningComponent(RecRef: RecordRef; var TempPlanningComponent: Record "Planning Component" temporary): Boolean
    var
        PlanningComponent: Record "Planning Component";
    begin
        if RecRef.IsTemporary then begin
            RecRef.SetTable(TempPlanningComponent);
            TempPlanningComponent.Insert();
            exit(true);
        end;

        RecRef.SetTable(PlanningComponent);
        if not PlanningComponent.Find() then
            exit(false);

        TempPlanningComponent.Init();
        TempPlanningComponent := PlanningComponent;
        TempPlanningComponent.Insert();
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Item Mgt.", 'OnUpsertStockTriggers', '', true, true)]
    local procedure UpsertStockTriggers(MagentoSetup: Record "NPR Magento Setup"; NpXmlTemplate: Record "NPR NpXml Template"; var Handled: Boolean)
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ReqLine: Record "Requisition Line";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        JobPlanningLine: Record "Job Planning Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
        TransLine: Record "Transfer Line";
        ServiceLine: Record "Service Line";
        PlanningComponent: Record "Planning Component";
        MagentoItemMgt: Codeunit "NPR Magento Item Mgt.";
    begin
        if Handled then
            exit;

        if not IsSubscriber(MagentoSetup) then
            exit;

        Handled := true;

        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Item Ledger Entry", ItemLedgerEntry.FieldNo("Item No."), true, false, false);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Sales Line", SalesLine.FieldNo("No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Purchase Line", PurchLine.FieldNo("No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Requisition Line", ReqLine.FieldNo("No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Assembly Header", AssemblyHeader.FieldNo("Item No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Assembly Line", AssemblyLine.FieldNo("No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Job Planning Line", JobPlanningLine.FieldNo("No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Prod. Order Line", ProdOrderLine.FieldNo("Item No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Prod. Order Component", ProdOrderComponent.FieldNo("Item No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Transfer Line", TransLine.FieldNo("Item No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Service Line", ServiceLine.FieldNo("No."), true, true, true);
        MagentoItemMgt.UpsertStockTrigger(NpXmlTemplate, Item.FieldNo("No."), DATABASE::"Planning Component", PlanningComponent.FieldNo("Item No."), true, true, true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Magento Item Mgt.", 'OnTrigger2Item', '', true, true)]
    local procedure TriggerToItem(MagentoSetup: Record "NPR Magento Setup"; RecRef: RecordRef; var TempItem: Record Item temporary; var Handled: Boolean)
    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        TempSalesLine: Record "Sales Line" temporary;
        TempPurchLine: Record "Purchase Line" temporary;
        TempReqLine: Record "Requisition Line" temporary;
        TempAssemblyHeader: Record "Assembly Header" temporary;
        TempAssemblyLine: Record "Assembly Line" temporary;
        TempJobPlanningLine: Record "Job Planning Line" temporary;
        TempProdOrderLine: Record "Prod. Order Line" temporary;
        TempProdOrderComponent: Record "Prod. Order Component" temporary;
        TempTransLine: Record "Transfer Line" temporary;
        TempServiceLine: Record "Service Line" temporary;
        TempPlanningComponent: Record "Planning Component" temporary;
        ItemNo: Code[20];
    begin
        if Handled then
            exit;

        if not IsSubscriber(MagentoSetup) then
            exit;

        Handled := true;

        case RecRef.Number of
            DATABASE::"Item Ledger Entry":
                begin
                    RecRef.SetTable(ItemLedgerEntry);
                    ItemLedgerEntry.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    if not ItemLedgerEntry.Find() then
                        exit;

                    ItemNo := ItemLedgerEntry."Item No.";
                end;
            DATABASE::"Sales Line":
                begin
                    if not RecRef2TempSalesLine(RecRef, TempSalesLine) then
                        exit;

                    TempSalesLine.SetRecFilter();
                    TempSalesLine.FilterGroup(40);
                    TempSalesLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempSalesLine.SetFilter("Document Type", '%1|%2', TempSalesLine."Document Type"::Order, TempSalesLine."Document Type"::"Return Order");
                    TempSalesLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempSalesLine.SetRange(Type, TempSalesLine.Type::Item);
                    TempSalesLine.SetFilter("No.", '<>%1', '');
                    if not TempSalesLine.FindFirst() then
                        exit;

                    ItemNo := TempSalesLine."No.";
                end;
            DATABASE::"Purchase Line":
                begin
                    if not RecRef2TempPurchLine(RecRef, TempPurchLine) then
                        exit;

                    TempPurchLine.SetRecFilter();
                    TempPurchLine.FilterGroup(40);
                    TempPurchLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempPurchLine.SetFilter("Document Type", '%1|%2', TempPurchLine."Document Type"::Order, TempPurchLine."Document Type"::"Return Order");
                    TempPurchLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempPurchLine.SetRange(Type, TempPurchLine.Type::Item);
                    TempPurchLine.SetFilter("No.", '<>%1', '');
                    if not TempPurchLine.FindFirst() then
                        exit;

                    ItemNo := TempPurchLine."No.";
                end;
            DATABASE::"Requisition Line":
                begin
                    if not RecRef2TempReqLine(RecRef, TempReqLine) then
                        exit;

                    TempReqLine.SetRecFilter();
                    TempReqLine.FilterGroup(40);
                    TempReqLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempReqLine.SetRange("Planning Line Origin", TempReqLine."Planning Line Origin"::" ");
                    TempReqLine.SetRange(Type, TempReqLine.Type::Item);
                    TempReqLine.SetFilter("No.", '<>%1', '');
                    if not TempReqLine.FindFirst() then
                        exit;

                    ItemNo := TempReqLine."No.";
                end;
            DATABASE::"Assembly Header":
                begin
                    if not RecRef2TempAssemblyHeader(RecRef, TempAssemblyHeader) then
                        exit;

                    TempAssemblyHeader.SetRecFilter();
                    TempAssemblyHeader.FilterGroup(40);
                    TempAssemblyHeader.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempAssemblyHeader.SetRange("Document Type", TempAssemblyHeader."Document Type"::Order);
                    TempAssemblyHeader.SetFilter("Item No.", '<>%1', '');
                    if not TempAssemblyHeader.FindFirst() then
                        exit;

                    ItemNo := TempAssemblyHeader."Item No.";
                end;
            DATABASE::"Assembly Line":
                begin
                    if not RecRef2TempAssemblyLine(RecRef, TempAssemblyLine) then
                        exit;

                    TempAssemblyLine.SetRecFilter();
                    TempAssemblyLine.FilterGroup(40);
                    TempAssemblyLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempAssemblyLine.SetRange("Document Type", TempAssemblyLine."Document Type"::Order);
                    TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Item);
                    TempAssemblyLine.SetFilter("No.", '<>%1', '');
                    if not TempAssemblyLine.FindFirst() then
                        exit;

                    ItemNo := TempAssemblyLine."No.";
                end;
            DATABASE::"Job Planning Line":
                begin
                    if not RecRef2TempJobPlanningLine(RecRef, TempJobPlanningLine) then
                        exit;

                    TempJobPlanningLine.SetRecFilter();
                    TempJobPlanningLine.FilterGroup(40);
                    TempJobPlanningLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempJobPlanningLine.SetRange(Status, TempJobPlanningLine.Status::Order);
                    TempJobPlanningLine.SetRange(Type, TempJobPlanningLine.Type::Item);
                    TempJobPlanningLine.SetFilter("No.", '<>%1', '');
                    if not TempJobPlanningLine.FindFirst() then
                        exit;

                    ItemNo := TempJobPlanningLine."No.";
                end;
            DATABASE::"Prod. Order Line":
                begin
                    if not RecRef2TempProdOrderLine(RecRef, TempProdOrderLine) then
                        exit;

                    TempProdOrderLine.SetRecFilter();
                    TempProdOrderLine.FilterGroup(40);
                    TempProdOrderLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempProdOrderLine.SetFilter(Status, '%1|%2|%3', TempProdOrderLine.Status::Planned, TempProdOrderLine.Status::"Firm Planned", TempProdOrderLine.Status::Released);
                    TempProdOrderLine.SetFilter("Item No.", '<>%1', '');
                    if not TempProdOrderLine.FindFirst() then
                        exit;

                    ItemNo := TempProdOrderLine."Item No.";
                end;
            DATABASE::"Prod. Order Component":
                begin
                    if not RecRef2TempProdOrderComponent(RecRef, TempProdOrderComponent) then
                        exit;

                    TempProdOrderComponent.SetRecFilter();
                    TempProdOrderComponent.FilterGroup(40);
                    TempProdOrderComponent.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempProdOrderComponent.SetFilter(Status, '%1..%2', TempProdOrderComponent.Status::Planned, TempProdOrderComponent.Status::Released);
                    TempProdOrderComponent.SetFilter("Item No.", '<>%1', '');
                    if not TempProdOrderComponent.FindFirst() then
                        exit;

                    ItemNo := TempProdOrderComponent."Item No.";
                end;
            DATABASE::"Transfer Line":
                begin
                    if not RecRef2TempTransLine(RecRef, TempTransLine) then
                        exit;

                    TempTransLine.SetRecFilter();
                    TempTransLine.FilterGroup(40);
                    TempTransLine.SetRange("Derived From Line No.", 0);
                    TempTransLine.SetFilter("Item No.", '<>%1', '');
                    TempTransLine.SetFilter("Transfer-to Code", MagentoSetup."Inventory Location Filter");
                    if not TempTransLine.FindFirst() then begin
                        TempTransLine.SetRange("Transfer-to Code");
                        TempTransLine.SetFilter("Transfer-from Code", MagentoSetup."Inventory Location Filter");
                        if not TempTransLine.FindFirst() then
                            exit;
                    end;

                    ItemNo := TempTransLine."Item No.";
                end;
            DATABASE::"Service Line":
                begin
                    if not RecRef2TempServiceLine(RecRef, TempServiceLine) then
                        exit;

                    TempServiceLine.SetRecFilter();
                    TempServiceLine.FilterGroup(40);
                    TempServiceLine.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempServiceLine.SetRange("Document Type", TempServiceLine."Document Type"::Order);
                    TempServiceLine.SetRange(Type, TempServiceLine.Type::Item);
                    TempServiceLine.SetFilter("No.", '<>%1', '');
                    if not TempServiceLine.FindFirst() then
                        exit;

                    ItemNo := TempServiceLine."No.";
                end;
            DATABASE::"Planning Component":
                begin
                    if not RecRef2TempPlanningComponent(RecRef, TempPlanningComponent) then
                        exit;

                    TempPlanningComponent.SetRecFilter();
                    TempPlanningComponent.FilterGroup(40);
                    TempPlanningComponent.SetFilter("Location Code", MagentoSetup."Inventory Location Filter");
                    TempPlanningComponent.SetRange("Planning Line Origin", TempPlanningComponent."Planning Line Origin"::" ");
                    TempPlanningComponent.SetFilter("Item No.", '<>%1', '');
                    if not TempPlanningComponent.FindFirst() then
                        exit;

                    ItemNo := TempPlanningComponent."Item No.";
                end;
            else
                exit;
        end;

        if ItemNo = '' then
            exit;
        if not Item.Get(ItemNo) then
            exit;

        if not Item."NPR Magento Item" then
            exit;

        TempItem.Init();
        TempItem := Item;
        TempItem.Insert();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Magento Proj.Avail.Balan.");
    end;

    local procedure GetFunctionName(): Text
    begin
        exit('CalcProjectedAvailableInventory');
    end;

    local procedure IsSubscriber(MagentoSetup: Record "NPR Magento Setup"): Boolean
    begin
        if MagentoSetup."Stock Calculation Method" <> MagentoSetup."Stock Calculation Method"::"Function" then
            exit(false);

        if MagentoSetup."Stock Codeunit Id" <> CurrCodeunitId() then
            exit(false);

        exit(MagentoSetup."Stock Function Name" = GetFunctionName());
    end;
}