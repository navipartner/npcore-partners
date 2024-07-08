codeunit 6151051 "NPR Distribution Mgmt"
{
    Access = Internal;
    var
        NoLocationText: Label 'No Distribution Group Members exist in group %1';
        BlockedForDistribution: Label 'Distribution Blocked for %1';

    procedure CreateDistributionItem(DistributionId: Integer; ItemHierarchy: Record "NPR Item Hierarchy"; DistributionGroups: Record "NPR Distrib. Group")
    var
        ReplenishmentDemandLine: Record "NPR Retail Repl. Demand Line";
        DistributionHeaders: Record "NPR Distribution Headers";
        DistributionGroupMembers: Record "NPR Distrib. Group Members";
        DistributionLines: Record "NPR Distribution Lines";
        ItemHierarchyLine: Record "NPR Item Hierarchy Line";
        Item: Record Item;
        LineNo: Integer;
        ConfirmDeleteText: Label 'Distribution Lines exsits! - Do you want to delete them?';
    begin

        DistributionHeaders.Get(DistributionId);

        case DistributionHeaders."Distribution Type" of
            DistributionHeaders."Distribution Type"::Blocked:
                begin
                    Error(BlockedForDistribution, DistributionHeaders."Distribution Group");
                end;
            DistributionHeaders."Distribution Type"::Manual:
                begin
                    DistributionLines.SetRange("Distribution Id", DistributionId);
                    if not DistributionLines.IsEmpty then
                        if Confirm(ConfirmDeleteText, false, true) then
                            DistributionLines.DeleteAll();
                    DistributionGroupMembers.SetRange(DistributionGroupMembers."Distribution Group", DistributionGroups.Code);
                    if DistributionGroupMembers.FindSet() then begin
                        repeat
                            //Determine if Distribution Setup allows!!!
                            ItemHierarchyLine.SetRange("Item Hierarchy Code", ItemHierarchy."Hierarchy Code");
                            if ItemHierarchyLine.FindSet() then begin
                                repeat
                                    //delete if found
                                    DistributionLines.Init();
                                    LineNo := LineNo + 10000;
                                    DistributionLines."Distribution Id" := DistributionId;
                                    DistributionLines."Distribution Line" := LineNo;
                                    DistributionLines."Distribution Group Member" := Format(DistributionGroupMembers."Distribution Member Id");
                                    DistributionLines."Distribution Item" := ItemHierarchyLine."Item No.";
                                    DistributionLines."Item Hiearachy" := ItemHierarchy."Hierarchy Code";
                                    DistributionLines."Item Hiearachy Level" := ItemHierarchyLine."Item Hierarchy Level";
                                    DistributionLines.Location := DistributionGroupMembers.Location;
                                    DistributionLines."Date Required" := DistributionHeaders."Required Date";
                                    if ItemHierarchyLine."Item No." <> '' then begin
                                        Item.Get(ItemHierarchyLine."Item No.");
                                        //process qty before filters
                                        Item.SetFilter("Date Filter", '..%1', DistributionHeaders."Required Date");
                                        Item.CalcFields(Inventory, "Qty. on Sales Order", "Qty. on Purch. Order");
                                        DistributionLines.Description := Item.Description;

                                        DistributionLines."Avaliable Quantity" := Item.Inventory;

                                        if Item."Qty. on Purch. Order" > 0 then begin
                                            DistributionLines."Avaliable Quantity" := DistributionLines."Avaliable Quantity" + Item."Qty. on Purch. Order";
                                        end;

                                        ReplenishmentDemandLine.SetRange(ReplenishmentDemandLine."Item No.", Item."No.");
                                        ReplenishmentDemandLine.SetRange(Confirmed, true);
                                        ReplenishmentDemandLine.SetFilter("Due Date", '..%1', DistributionHeaders."Required Date");
                                        ReplenishmentDemandLine.SetRange("Location Code", DistributionGroupMembers.Location);
                                        if ReplenishmentDemandLine.FindSet() then begin
                                            DistributionLines."Demanded Quantity" := DistributionLines."Demanded Quantity" + ReplenishmentDemandLine."Demanded Quantity";
                                        end;

                                        DistributionLines."Distribution Quantity" := DistributionLines."Demanded Quantity";

                                        if ((DistributionLines."Demanded Quantity" > 0) and (DistributionLines."Avaliable Quantity" > 0) and (DistributionLines."Avaliable Quantity" < DistributionLines."Demanded Quantity")) then begin
                                            DistributionLines."Distribution Quantity" := (DistributionLines."Avaliable Quantity" - (DistributionLines."Demanded Quantity" - DistributionLines."Avaliable Quantity"))
                                            * (DistributionGroupMembers."Distribution Share Pct." / 100);
                                            //test for other distributions

                                        end;
                                        DistributionLines."Org. Distribution Quantity" := DistributionLines."Distribution Quantity";
                                    end else
                                        DistributionLines.Description := CopyStr(ItemHierarchyLine."Item Hierachy Description", 1, 50);
                                    DistributionLines.Insert();
                                until ItemHierarchyLine.Next() = 0;
                            end;
                        until DistributionGroupMembers.Next() = 0;
                    end else
                        Message(NoLocationText, DistributionGroups.Code);
                end;
            DistributionHeaders."Distribution Type"::Automatic:
                begin
                    Message('No support for automatic distribution now!');
                end;
        end;
    end;

    procedure CreateDistributionDocuments(var DistributionHeaders: Record "NPR Distribution Headers")
    var
        DistributionLines: Record "NPR Distribution Lines";
        PurchaseLine: Record "Purchase Line";
        DistribTableMap: Record "NPR Distribution Map";
        DistributionGroups: Record "NPR Distrib. Group";
        StockkeepingUnit: Record "Stockkeeping Unit";
        QtyToDist: Decimal;
    begin
        //IF status closed - error
        DistributionLines.SetCurrentKey(DistributionLines.Location, DistributionLines."Distribution Item");
        DistributionLines.SetRange(DistributionLines."Distribution Id", DistributionHeaders."Distribution Id");
        if DistributionLines.FindSet() then begin
            repeat
                //Find purchase orders to location
                QtyToDist := DistributionLines."Distribution Quantity";
                PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                PurchaseLine.SetRange("No.", DistributionLines."Distribution Item");
                PurchaseLine.SetRange("Location Code", DistributionLines.Location);
                PurchaseLine.SetFilter("Outstanding Quantity", '>0');
                PurchaseLine.SetFilter("Requested Receipt Date", '..%1', DistributionLines."Date Required");
                PurchaseLine.SetRange("Drop Shipment", false);
                PurchaseLine.SetRange("Special Order", false);
                //Test Released ??
                //
                if PurchaseLine.FindSet(true) then begin
                    repeat
                        if QtyToDist > 0 then
                            if not DistribTableMap.Get(DistributionLines."Distribution Id", Database::"Purchase Line", PurchaseLine.SystemId) then begin
                                if PurchaseLine."Outstanding Quantity" >= QtyToDist then
                                    QtyToDist := 0
                                else
                                    QtyToDist := QtyToDist - PurchaseLine."Outstanding Quantity";

                                DistribTableMap.CreateFromPurchaseLine(DistributionLines."Distribution Id", PurchaseLine);
                            end;
                    until PurchaseLine.Next() = 0;
                end;

                if QtyToDist > 0 then begin
                    //Test warehouse location inventory - if yes create transfer
                    DistributionGroups.Get(DistributionHeaders."Distribution Group");
                    if StockkeepingUnit.Get(DistributionGroups."Warehouse Location", DistributionLines."Distribution Item", DistributionLines."Item Variant") then
                        StockkeepingUnit.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit");

                    if (((StockkeepingUnit.Inventory + StockkeepingUnit."Qty. on Purch. Order") > 0) and (StockkeepingUnit."Qty. in Transit" < QtyToDist)) then begin
                        if QtyToDist < (StockkeepingUnit.Inventory + StockkeepingUnit."Qty. on Purch. Order") then
                            CreateTransfOrders(DistributionLines, QtyToDist)
                        else begin
                            //calc distribution percentage on shrtage
                            DistributionLines."Distribution Quantity" := DistributionLines."Org. Distribution Quantity" - (QtyToDist - (StockkeepingUnit.Inventory + StockkeepingUnit."Qty. on Purch. Order"));
                            CreateTransfOrders(DistributionLines, (StockkeepingUnit.Inventory + StockkeepingUnit."Qty. on Purch. Order"));
                        end;
                    end;
                    //Take SKU on warehouse into account ??
                    //if shortage test warehouse PO and create transfers

                    //IF inventory > DistributionHeaders THEN CREATE transfer else create purchse
                end;
            until DistributionLines.Next() = 0;
        end;

        //Per Item process on line per location
        //IF inventory use this first in transfers
        //ELSE create purchase.. INTERCOMPAY??
    end;

    procedure CreateTransfOrders(var DistributionLines: Record "NPR Distribution Lines"; TransferQuantity: Decimal)
    var
        ReplenSetup: Record "NPR Retail Replenishment Setup";
        DistribTableMap: Record "NPR Distribution Map";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        DistributionHeaders: Record "NPR Distribution Headers";
        DistributionGroups: Record "NPR Distrib. Group";
        Text007: Label 'The Transfer Route between Locations %1 and %2 has not been defined. The %3 in the %4 has not been filled out.';
    begin
        ReplenSetup.Get();
        DistributionHeaders.Get(DistributionLines."Distribution Id");
        DistributionGroups.Get(DistributionHeaders."Distribution Group");
        DistributionGroups.TestField("Warehouse Location");
        Clear(TransferHeader);
        TransferHeader.Validate("No.", '');
        TransferHeader.Validate("Posting Date", Today);
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", DistributionGroups."Warehouse Location");
        TransferHeader.Validate("Transfer-to Code", DistributionLines.Location);
        if TransferHeader."In-Transit Code" = '' then
            if ReplenSetup."Default Transit Location" <> '' then
                TransferHeader."In-Transit Code" := ReplenSetup."Default Transit Location"
            else
                Error(Text007, TransferHeader."Transfer-from Code", TransferHeader."Transfer-to Code",
                  ReplenSetup.FieldCaption("Default Transit Location"), ReplenSetup.TableCaption);
        TransferHeader.Modify(true);
        TransferLine."Document No." := TransferHeader."No.";
        TransferLine."Line No." := 0;
        TransferLine.SetCurrentKey("Item No.");
        TransferLine.SetRange("Document No.", TransferHeader."No.");
        TransferLine.SetRange("Item No.", DistributionLines."Distribution Item");
        TransferLine.SetRange("Variant Code", DistributionLines."Item Variant");
        if not TransferLine.FindFirst() then begin
            TransferLine."Line No." := TransferLine."Line No." + 10000;
            TransferLine.Insert(true);
            TransferLine.Quantity := 0;
        end;
        TransferLine."Transfer-from Code" := TransferHeader."Transfer-from Code";
        TransferLine."Transfer-to Code" := TransferHeader."Transfer-to Code";
        TransferLine.Validate("Transfer-from Code", TransferHeader."Transfer-from Code");
        TransferLine.Validate("Transfer-to Code", TransferHeader."Transfer-to Code");
        TransferLine.Validate("Item No.", DistributionLines."Distribution Item");
        TransferLine.Validate("Variant Code", DistributionLines."Item Variant");
        TransferLine.Validate(Quantity, TransferQuantity);

        TransferLine.Modify(true);

        DistribTableMap.CreateFromTransferLine(DistributionLines."Distribution Id", TransferLine);
    end;
}
