codeunit 6151052 "NPR Retail Replenish. Mgt."
{
    trigger OnRun()
    begin
    end;

    procedure CreateDemandLines(ItemHierachyID: Code[20]; DistributionGroup: Code[20])
    var
        RetailReplenishmentSetup: Record "NPR Retail Replenishment Setup";
        Item: Record Item;
        StockkeepingUnit: Record "Stockkeeping Unit";
        ItemHierarchyLine: Record "NPR Item Hierarchy Line";
        DistributionGroupMembers: Record "NPR Distrib. Group Members";
        DistributionSetup: Record "NPR Distribution Setup";
        BlockedError: Label 'This distribution setup is blocked for distribution!';
        ReplenishmentDemandLine: Record "NPR Retail Repl. Demand Line";
        RetailCampaignHeader: Record "NPR Retail Campaign Header";
        RetailCampaignLine: Record "NPR Retail Campaign Line";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        RetailComment: Record "NPR Retail Comment";
        CreateStockkeepingUnit: Report "Create Stockkeeping Unit";
        LineNo: Integer;
    begin
        DistributionSetup.Get(DistributionGroup, ItemHierachyID);
        RetailReplenishmentSetup.Get;

        if ReplenishmentDemandLine.FindLast then
            LineNo := ReplenishmentDemandLine."Entry No."
        else
            LineNo := 0;

        Clear(DistributionGroupMembers);
        DistributionGroupMembers.SetRange(DistributionGroupMembers."Distribution Group", DistributionGroup);
        if DistributionGroupMembers.FindSet then begin
            //IF demandlines exsist and not - error or delete..
            repeat
                ItemHierarchyLine.SetRange("Item Hierarchy Code", ItemHierachyID);
                ItemHierarchyLine.SetFilter("Item No.", '<>%1', '');
                if ItemHierarchyLine.FindSet then begin
                    repeat
                        LineNo := LineNo + 10000;
                        Clear(Item);
                        Item.Get(ItemHierarchyLine."Item No.");
                        //Create SKU
                        if ((DistributionSetup."Create SKU Per Location") and (not StockkeepingUnit.Get(DistributionGroupMembers.Location, ItemHierarchyLine."Item No.", ItemHierarchyLine."Variant Code"))) then begin
                            Item.SetFilter("Location Filter", DistributionGroupMembers.Location);
                            REPORT.Run(REPORT::"Create Stockkeeping Unit", false, true, Item);
                        end;

                        //check if line exists
                        ReplenishmentDemandLine.SetRange("Item No.", ItemHierarchyLine."Item No.");
                        ReplenishmentDemandLine.SetRange("Location Code", DistributionGroupMembers.Location);
                        ReplenishmentDemandLine.SetRange("Distribution Group", DistributionGroup);
                        ReplenishmentDemandLine.SetRange("Item Hierachy", ItemHierachyID);
                        if ReplenishmentDemandLine.IsEmpty then begin
                            ReplenishmentDemandLine.Init;
                            ReplenishmentDemandLine."Entry No." := LineNo;
                            ReplenishmentDemandLine."Item No." := ItemHierarchyLine."Item No.";
                            ReplenishmentDemandLine.Description := Item.Description;
                            ReplenishmentDemandLine."Vendor No." := Item."Vendor No.";
                            ReplenishmentDemandLine."Units per Parcel" := Item."Units per Parcel";
                            ReplenishmentDemandLine."Due Date" := DistributionSetup."Required Delivery Date";
                            ReplenishmentDemandLine."Location Code" := DistributionGroupMembers.Location;
                            ReplenishmentDemandLine."Vendor Item No." := Item."Vendor Item No.";
                            ReplenishmentDemandLine."Item Hierachy" := ItemHierachyID;
                            ReplenishmentDemandLine."Distribution Group" := DistributionGroup;

                            //FIND period disc info
                            if ItemHierarchyLine."Retail Campaign Disc. Code" <> '' then begin
                                case ItemHierarchyLine."Retail Campaign Disc. Type" of
                                    ItemHierarchyLine."Retail Campaign Disc. Type"::Period:
                                        begin
                                            if PeriodDiscountLine.Get(ItemHierarchyLine."Retail Campaign Disc. Code", ItemHierarchyLine."Item No.") then begin
                                                ReplenishmentDemandLine."Campaign Unit Price" := PeriodDiscountLine."Campaign Unit Price";
                                                ReplenishmentDemandLine."Campaign Unit Cost" := PeriodDiscountLine."Campaign Unit Cost";
                                                ReplenishmentDemandLine.Priority := PeriodDiscountLine.Priority;
                                                ReplenishmentDemandLine."Page no. in advert" := PeriodDiscountLine."Page no. in advert";
                                                ReplenishmentDemandLine.Photo := PeriodDiscountLine.Photo;
                                                RetailComment.SetRange("Table ID", 6014414);
                                                RetailComment.SetRange("No.", PeriodDiscountLine.Code);
                                                RetailComment.SetRange("No. 2", PeriodDiscountLine."Item No.");
                                                if RetailComment.FindFirst then
                                                    ReplenishmentDemandLine."Discount Comment" := CopyStr(RetailComment.Comment, 1, 50);
                                            end;
                                        end;
                                    ItemHierarchyLine."Retail Campaign Disc. Type"::Mix:
                                        begin
                                            //                    //implement Mix when new fields are added
                                        end;
                                end;
                            end;
                            ReplenishmentDemandLine.Insert;

                            //Calc demand qty
                            if RetailReplenishmentSetup."Item Demand Calc. Codeunit" > 0 then begin
                                CODEUNIT.Run(RetailReplenishmentSetup."Item Demand Calc. Codeunit", ReplenishmentDemandLine);
                            end else begin
                                //Default demand calc
                                DefaultDemandCalc(ReplenishmentDemandLine, DistributionSetup."Replenishment Grace Period");
                            end;
                            ReplenishmentDemandLine.CalcFields("Reordering Policy");
                            ReplenishmentDemandLine.Status := ReplenishmentDemandLine.Status::"0";
                            if ReplenishmentDemandLine."Reordering Policy" = ReplenishmentDemandLine."Reordering Policy"::" " then
                                ReplenishmentDemandLine.Status := ReplenishmentDemandLine.Status::"2";
                            if ReplenishmentDemandLine."Demanded Quantity" > 0 then
                                ReplenishmentDemandLine."Demanded Quantity" := 0
                            else
                                ReplenishmentDemandLine."Demanded Quantity" := Abs(ReplenishmentDemandLine."Demanded Quantity");
                            ReplenishmentDemandLine."Unit of Measure Code" := Item."Base Unit of Measure";
                            ReplenishmentDemandLine.Modify;
                        end;
                    until ItemHierarchyLine.Next = 0;
                end;
            until DistributionGroupMembers.Next = 0;
        end;
    end;

    local procedure DefaultDemandCalc(var RetaiReplDemandLine: Record "NPR Retail Repl. Demand Line"; GracePeriod: DateFormula)
    var
        DistributionSetup: Record "NPR Distribution Setup";
        Item: Record Item;
        Location: Record Location;
        ItemLedgerEntry: Record "Item Ledger Entry";
        DemandQuantity: Decimal;
        IncomingQuantity: Decimal;
        OutgoingQuantity: Decimal;
        DailyDemand: Decimal;
        StartSalesHistDate: Date;
        SpreadDays: Integer;
        DemandDays: Integer;
    begin
        Item.Get(RetaiReplDemandLine."Item No.");
        Location.Get(RetaiReplDemandLine."Location Code");
        StartSalesHistDate := CalcDate(GracePeriod, Today);
        //test location for allow replenisment

        //Test Item for blocked for purchase / Transfer / Item Blocked

        //Implement for Variants

        //Test for exsisting demands
        Item.SetFilter("Location Filter", Location.Code);
        Item.SetFilter("Date Filter", '%1..%2', StartSalesHistDate, Today);
        Item.CalcFields("Qty. on Purch. Order", "Qty. on Sales Order", "Qty. in Transit", Inventory);

        IncomingQuantity := Item."Qty. on Purch. Order" + Item.Inventory;

        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        ItemLedgerEntry.SetRange("Location Code", Location.Code);
        ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', StartSalesHistDate, Today);
        ItemLedgerEntry.CalcSums("Remaining Quantity", Quantity);

        OutgoingQuantity := Item."Qty. on Sales Order" + ItemLedgerEntry.Quantity;

        //OutgoingQuantity := + forecast + campaign

        DemandQuantity := OutgoingQuantity - IncomingQuantity;
        RetaiReplDemandLine.Validate("Demanded Quantity", DemandQuantity);

        //Find Sales date spread
        SpreadDays := Today - StartSalesHistDate;
        if OutgoingQuantity < 0 then
            DailyDemand := OutgoingQuantity / SpreadDays
        else
            DailyDemand := 0;

        if ((DailyDemand < 0) and (Item.Inventory > 0)) then begin
            DemandDays := (Item.Inventory div DailyDemand);
        end;

        RetaiReplDemandLine."Due Date" := CalcDate(Item."Lead Time Calculation", Today);

        if ((DistributionSetup.Get(RetaiReplDemandLine."Distribution Group", RetaiReplDemandLine."Item Hierachy")) and (DistributionSetup."Required Delivery Date" <> 0D)) then begin
            RetaiReplDemandLine."Due Date" := CalcDate(Item."Lead Time Calculation", DistributionSetup."Required Delivery Date");
        end;
    end;

    procedure CreateRetailCampaignDemands(RetailCampaignHeader: Record "NPR Retail Campaign Header")
    begin
        //Create demands
    end;

    procedure CreateCampaignPurchOrdersDirectFromDemand(var RetaiReplDemandLine: Record "NPR Retail Repl. Demand Line")
    var
        PurchaseHeader: Record "Purchase Header";
        NewPurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        RetailCampaignHeader: Record "NPR Retail Campaign Header";
        LineNo: Integer;
        MissingDiscFilter: Label 'Direct order must have a filter on dist. group and item hiearacy!';
    begin
        if ((RetaiReplDemandLine.GetFilter("Item Hierachy") <> '') and (RetaiReplDemandLine.GetFilter("Distribution Group") <> '')) then begin
            RetaiReplDemandLine.SetCurrentKey("Location Code");
            RetaiReplDemandLine.SetRange(Confirmed, true);
            if RetaiReplDemandLine.FindSet(true) then begin
                repeat
                    LineNo := 0;
                    Clear(PurchaseLine);
                    Clear(PurchaseHeader);
                    PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                    PurchaseHeader.SetRange("Buy-from Vendor No.", RetaiReplDemandLine."Vendor No.");
                    PurchaseHeader.SetRange("Campaign No.", RetaiReplDemandLine."Item Hierachy");
                    PurchaseHeader.SetRange("Requested Receipt Date", RetaiReplDemandLine."Due Date");
                    PurchaseHeader.SetRange("Location Code", RetaiReplDemandLine."Location Code");
                    if PurchaseHeader.FindFirst then begin
                        PurchaseHeader.TestField("Buy-from Vendor No.");
                        PurchaseHeader.TestField("Campaign No.");
                        PurchaseHeader.TestField(Status, PurchaseHeader.Status::Open);
                        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                        if PurchaseLine.FindLast then
                            LineNo := PurchaseLine."Line No.";
                        PurchaseLine.Init;
                        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                        PurchaseLine."Document No." := PurchaseHeader."No.";
                        PurchaseLine."Line No." := LineNo + 10000;
                        PurchaseLine.Type := PurchaseLine.Type::Item;
                        PurchaseLine.Validate("No.", RetaiReplDemandLine."Item No.");
                        PurchaseLine.Insert(true);
                        PurchaseLine.Validate(Quantity, Abs(RetaiReplDemandLine."Quantity (Base)"));
                        PurchaseLine.Validate("Location Code", RetaiReplDemandLine."Location Code");
                        PurchaseLine.Validate("Order Date", Today);
                        PurchaseLine.Modify(true);
                        PurchaseLine.Validate("Expected Receipt Date", RetaiReplDemandLine."Due Date");
                        PurchaseLine.Validate("Direct Unit Cost", RetaiReplDemandLine."Campaign Unit Cost");
                        PurchaseLine.Modify(true);
                    end else begin
                        Clear(NewPurchaseHeader);
                        NewPurchaseHeader.Init;
                        NewPurchaseHeader.Validate("Document Type", NewPurchaseHeader."Document Type"::Order);
                        NewPurchaseHeader.Validate("Buy-from Vendor No.", RetaiReplDemandLine."Vendor No.");
                        NewPurchaseHeader.Insert(true);
                        NewPurchaseHeader.Validate("Document Date", Today);
                        NewPurchaseHeader.Validate("Posting Date", Today);
                        NewPurchaseHeader.Validate("Requested Receipt Date", RetaiReplDemandLine."Due Date");
                        NewPurchaseHeader.Validate("Location Code", RetaiReplDemandLine."Location Code");
                        NewPurchaseHeader.Validate("Campaign No.", RetaiReplDemandLine."Item Hierachy");
                        NewPurchaseHeader.Validate("Expected Receipt Date", RetaiReplDemandLine."Due Date");
                        NewPurchaseHeader.Modify(true);

                        PurchaseLine.Init;
                        PurchaseLine."Document Type" := NewPurchaseHeader."Document Type";
                        PurchaseLine."Document No." := NewPurchaseHeader."No.";
                        PurchaseLine."Line No." := 10000;
                        PurchaseLine.Type := PurchaseLine.Type::Item;
                        PurchaseLine.Validate("No.", RetaiReplDemandLine."Item No.");
                        PurchaseLine.Insert(true);
                        PurchaseLine.Validate(Quantity, Abs(RetaiReplDemandLine."Quantity (Base)"));
                        PurchaseLine.Validate("Location Code", RetaiReplDemandLine."Location Code");
                        PurchaseLine.Validate("Order Date", Today);
                        PurchaseLine.Modify(true);
                        PurchaseLine.Validate("Direct Unit Cost", RetaiReplDemandLine."Campaign Unit Cost");
                        PurchaseLine.Validate("Expected Receipt Date", RetaiReplDemandLine."Due Date");
                        PurchaseLine.Modify(true);
                    end;
                    RetaiReplDemandLine.Status := RetaiReplDemandLine.Status::"9";
                    RetaiReplDemandLine.Modify;
                until RetaiReplDemandLine.Next = 0;
            end;
        end else
            Error(MissingDiscFilter);
    end;
}