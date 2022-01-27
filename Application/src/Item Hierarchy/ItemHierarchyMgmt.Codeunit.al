codeunit 6151050 "NPR Item Hierarchy Mgmt."
{
    Access = Internal;
    var
        TextUpdateRetailCampHieracy: Label 'Do you want to update the Item Hierachy %1 with the items from retail Campaign %2';
        TextCancelledByUser: Label 'Cancelled by user!';
        TextCreateNewItemHierachyFromCamp: Label 'Do you want to create the Item Hierachy %1 with the items from retail Campaign %2';
        TextDemandLinesExists: Label 'Demand lines exist for the campaign items - please update those manually';

    procedure CreateItemHierarchyLines(ItemHierarchy: Record "NPR Item Hierarchy")
    var
        ItemHierarchyLevel: Record "NPR Item Hierarchy Level";
        ItemHierarchyLine: Record "NPR Item Hierarchy Line";
        Item: Record Item;
        PreviousLevelLine: Record "NPR Item Hierarchy Level";
        ItemVariant: Record "Item Variant";
        LineNo: Integer;
        ConfirmDeleteText: Label 'Item Hierachy Lines exsits! - Do you want to delete them?';
        RecRef: RecordRef;
        FldRef: FieldRef;
        DescFldRef: FieldRef;
        ParentRecRef: RecordRef;
        ParentFldRef: FieldRef;
    begin
        ItemHierarchyLine.SetRange("Item Hierarchy Code", ItemHierarchy."Hierarchy Code");
        if not ItemHierarchyLine.IsEmpty then
            if Confirm(ConfirmDeleteText, false, true) then
                ItemHierarchyLine.DeleteAll();

        ItemHierarchyLevel.SetRange("Hierarchy Code", ItemHierarchy."Hierarchy Code");
        if ItemHierarchyLevel.FindSet() then begin
            repeat
                LineNo := LineNo + 10000;
                if ((ItemHierarchyLevel."Table No." = 0) and (ItemHierarchyLevel.Level < ItemHierarchy."No. Of Levels")) then begin
                    ItemHierarchyLine."Item Hierarchy Code" := ItemHierarchy."Hierarchy Code";
                    ItemHierarchyLine."Item Hierarchy Line No." := LineNo;
                    ItemHierarchyLine."Item Hierarchy Level" := ItemHierarchyLevel.Level;
                    ItemHierarchyLine."Related Table Desc Field Value" := ItemHierarchyLevel.Description;
                    ItemHierarchyLine."Item Hierachy Description" := ItemHierarchyLevel.Description;
                    ItemHierarchyLine.Insert();
                end else begin
                    ItemHierarchyLevel.TestField("Table No.");
                    ItemHierarchyLevel.TestField("Primary Field No.");
                    if ItemHierarchyLevel."Level Link Table No." > 0 then begin
                        ItemHierarchyLevel.TestField("Level Link Field No.");
                        Clear(ParentRecRef);
                        ParentRecRef.Open(ItemHierarchyLevel."Level Link Table No.");
                        if ItemHierarchyLevel."Level Link Field No." > 0 then
                            ParentFldRef := ParentRecRef.Field(ItemHierarchyLevel."Level Link Field No.")
                        else
                            ParentFldRef := ParentRecRef.Field(PreviousLevelLine."Primary Field No.");
                        if ItemHierarchyLevel."Level Link Filter" <> '' then
                            ParentFldRef.SetFilter(ItemHierarchyLevel."Level Link Filter");
                        if ParentRecRef.FindSet() then begin
                            repeat
                                Clear(RecRef);
                                RecRef.Open(ItemHierarchyLevel."Table No.");
                                FldRef := RecRef.Field(ItemHierarchyLevel."Primary Field No.");
                                if ItemHierarchyLevel."Level Link Field No." > 0 then
                                    FldRef.SetFilter(Format(ParentFldRef.Value));
                                DescFldRef := RecRef.Field(ItemHierarchyLevel."Description Field No.");
                                if RecRef.FindSet() then begin
                                    repeat
                                        LineNo := LineNo + 10000;
                                        ItemHierarchyLine."Item Hierarchy Code" := ItemHierarchy."Hierarchy Code";
                                        ItemHierarchyLine."Item Hierarchy Line No." := LineNo;
                                        ItemHierarchyLine."Item Hierarchy Level" := ItemHierarchyLevel.Level;
                                        ItemHierarchyLine."Related Table Desc Field Value" := ParentFldRef.Value;
                                        ItemHierarchyLine."Related Table Key Field Value" := FldRef.Value;
                                        ItemHierarchyLine."Linked Table No." := ItemHierarchyLevel."Level Link Table No.";
                                        ItemHierarchyLine."Linked Table Key Value" := ParentFldRef.Value;
                                        ItemHierarchyLine."Linked Table Value Desc." := ParentFldRef.Value;
                                        ItemHierarchyLine."Item Hierachy Description" := DescFldRef.Value;
                                        if ItemHierarchyLevel."Table No." = 27 then begin
                                            DescFldRef := RecRef.Field(1);
                                            Item.Get(DescFldRef.Value);
                                            ItemHierarchyLine."Item No." := Item."No.";
                                            ItemHierarchyLine."Related Table Desc Field Value" := Item."No.";
                                            ItemHierarchyLine."Item Desc." := Item.Description;
                                            ItemHierarchyLine."Item Hierachy Description" := '';
                                            ItemVariant.SetRange("Item No.", Item."No.");
                                            if ItemVariant.FindSet() then begin
                                                LineNo := LineNo - 10000;
                                                repeat
                                                    LineNo := LineNo + 10000;
                                                    ItemHierarchyLine."Item Hierarchy Line No." := LineNo;
                                                    ItemHierarchyLine."Variant Code" := ItemVariant.Code;
                                                    ItemHierarchyLine."Item Desc." := ItemVariant.Description;
                                                    ItemHierarchyLine.Insert();
                                                until ItemVariant.Next() = 0;
                                            end else
                                                ItemHierarchyLine.Insert();
                                        end else
                                            ItemHierarchyLine.Insert();
                                    until RecRef.Next() = 0;
                                end;
                            until ParentRecRef.Next() = 0;
                        end;
                    end else begin
                        Clear(RecRef);
                        RecRef.Open(ItemHierarchyLevel."Table No.");
                        FldRef := RecRef.Field(ItemHierarchyLevel."Primary Field No.");
                        DescFldRef := RecRef.Field(ItemHierarchyLevel."Description Field No.");
                        //FldRef.SETFILTER();
                        if RecRef.FindSet() then begin
                            repeat
                                LineNo := LineNo + 10000;
                                ItemHierarchyLine."Item Hierarchy Code" := ItemHierarchy."Hierarchy Code";
                                ItemHierarchyLine."Item Hierarchy Line No." := LineNo;
                                ItemHierarchyLine."Item Hierarchy Level" := ItemHierarchyLevel.Level;
                                ItemHierarchyLine."Related Table Desc Field Value" := FldRef.Value;
                                ItemHierarchyLine."Related Table Key Field Value" := FldRef.Value;
                                ItemHierarchyLine."Linked Table No." := ItemHierarchyLevel."Level Link Table No.";
                                ItemHierarchyLine."Linked Table Key Value" := FldRef.Value;
                                ItemHierarchyLine."Linked Table Value Desc." := FldRef.Value;
                                ItemHierarchyLine."Item Hierachy Description" := DescFldRef.Value;
                                ItemHierarchyLine.Insert();
                            until RecRef.Next() = 0;
                        end;
                    end;
                end;
                PreviousLevelLine := ItemHierarchyLevel;
            until ItemHierarchyLevel.Next() = 0;
        end;
    end;

    procedure CreateItemHierachyFromRetailCampaign(RetailCampaignHeader: Record "NPR Retail Campaign Header")
    var
        ItemHierarchy: Record "NPR Item Hierarchy";
        ItemHierarchyLevel: Record "NPR Item Hierarchy Level";
    begin
        if ItemHierarchy.Get(RetailCampaignHeader.Code) and GuiAllowed then begin
            if Confirm(StrSubstNo(TextUpdateRetailCampHieracy, ItemHierarchy."Hierarchy Code", RetailCampaignHeader.Code), true) then begin
                UpdateItemHierachyLinesFromRetailCampaign(RetailCampaignHeader);
            end else
                Message(TextCancelledByUser);
        end else begin
            if Confirm(StrSubstNo(TextCreateNewItemHierachyFromCamp, ItemHierarchy."Hierarchy Code", RetailCampaignHeader.Code), true) then begin
                ItemHierarchy.Validate("Hierarchy Code", RetailCampaignHeader.Code);
                ItemHierarchy.Validate(Description, RetailCampaignHeader.Description);
                ItemHierarchy.Insert(true);
                //Define static item level - should later be dynamical by setup
                ItemHierarchyLevel.Validate("Hierarchy Code", ItemHierarchy."Hierarchy Code");
                ItemHierarchyLevel.Validate("Line No.", 10000);
                ItemHierarchyLevel.Validate(Code, 'ITEM');
                ItemHierarchyLevel.Validate(Level, 0);
                ItemHierarchyLevel.Validate("Table No.", 267);
                ItemHierarchyLevel.Validate("Primary Field No.", 1);
                ItemHierarchyLevel.Insert(true);
                CreateItemHierachyLinesFromRetailCampaign(RetailCampaignHeader, ItemHierarchy);
            end else
                Message(TextCancelledByUser);
        end;
    end;

    local procedure UpdateItemHierachyLinesFromRetailCampaign(RetailCampaignHeader: Record "NPR Retail Campaign Header")
    var
        ItemHierarchy: Record "NPR Item Hierarchy";
        ItemHierarchyLine: Record "NPR Item Hierarchy Line";
        RetaiReplDemandLine: Record "NPR Retail Repl. Demand Line";
    begin
        //test if demands are present

        RetaiReplDemandLine.SetRange("Item Hierachy", RetailCampaignHeader.Code);
        if not RetaiReplDemandLine.IsEmpty then
            Message(TextDemandLinesExists);

        //test if distributions are present

        //delete lines
        ItemHierarchy.Get(RetailCampaignHeader.Code);
        ItemHierarchyLine.SetRange("Item Hierarchy Code", RetailCampaignHeader.Code);
        ItemHierarchyLine.DeleteAll();

        //recreate lines
        CreateItemHierachyLinesFromRetailCampaign(RetailCampaignHeader, ItemHierarchy);
    end;

    local procedure CreateItemHierachyLinesFromRetailCampaign(RetailCampaignHeader: Record "NPR Retail Campaign Header"; ItemHierarchy: Record "NPR Item Hierarchy")
    var
        RetailCampaignLine: Record "NPR Retail Campaign Line";
        ItemHierarchyLine: Record "NPR Item Hierarchy Line";
        ItemHierarchyLevel: Record "NPR Item Hierarchy Level";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        Item: Record Item;
        LineNo: Integer;
    begin
        RetailCampaignLine.SetRange("Campaign Code", RetailCampaignHeader.Code);
        LineNo := 0;
        if RetailCampaignLine.FindSet() then begin
            repeat
                case RetailCampaignLine.Type of
                    RetailCampaignLine.Type::"Period Discount":
                        begin
                            PeriodDiscountLine.SetRange(Code, RetailCampaignLine.Code);
                            if PeriodDiscountLine.FindSet() then begin
                                repeat
                                    //use level 0 - should be expanded..
                                    LineNo += 10000;
                                    ItemHierarchyLine.Validate("Item Hierarchy Code", ItemHierarchy."Hierarchy Code");
                                    ItemHierarchyLine.Validate("Item Hierarchy Line No.", LineNo);
                                    ItemHierarchyLine.Validate("Item Hierarchy Level", 0);
                                    ItemHierarchyLine.Validate("Item No.", PeriodDiscountLine."Item No.");
                                    ItemHierarchyLine.Validate("Retail Campaign Disc. Code", PeriodDiscountLine.Code);
                                    ItemHierarchyLine.Validate("Retail Campaign Disc. Type", ItemHierarchyLine."Retail Campaign Disc. Type"::Period);
                                    if ItemHierarchyLevel.Get(ItemHierarchy."Hierarchy Code", 10000) then begin
                                        ItemHierarchyLine."Related Table Desc Field Value" := ItemHierarchyLevel.Code;
                                        ItemHierarchyLine."Item Hierachy Description" := ItemHierarchyLevel.Code;
                                    end;
                                    ItemHierarchyLine.Insert(true);
                                until PeriodDiscountLine.Next() = 0;
                            end;
                        end;
                    RetailCampaignLine.Type::"Mixed Discount":
                        begin
                            MixedDiscountLine.SetRange(Code, RetailCampaignLine.Code);
                            if MixedDiscountLine.FindSet() then begin
                                repeat
                                    case MixedDiscountLine."Disc. Grouping Type" of
                                        MixedDiscountLine."Disc. Grouping Type"::Item:
                                            begin
                                                LineNo += 10000;
                                                ItemHierarchyLine.Validate("Item Hierarchy Code", ItemHierarchy."Hierarchy Code");
                                                ItemHierarchyLine.Validate("Item Hierarchy Line No.", LineNo);
                                                ItemHierarchyLine.Validate("Item No.", MixedDiscountLine."No.");
                                                ItemHierarchyLine.Validate("Item Hierarchy Level", 0);
                                                ItemHierarchyLine.Validate("Retail Campaign Disc. Code", MixedDiscountLine.Code);
                                                ItemHierarchyLine.Validate("Retail Campaign Disc. Type", ItemHierarchyLine."Retail Campaign Disc. Type"::Mix);
                                                if ItemHierarchyLevel.Get(ItemHierarchy."Hierarchy Code", 10000) then begin
                                                    ItemHierarchyLine."Related Table Desc Field Value" := ItemHierarchyLevel.Code;
                                                    ItemHierarchyLine."Item Hierachy Description" := ItemHierarchyLevel.Code;
                                                end;
                                                ItemHierarchyLine.Insert(true);
                                            end;
                                        MixedDiscountLine."Disc. Grouping Type"::"Item Group":
                                            begin

                                                // add all frtom group..
                                                Item.SetRange("Item Category Code", MixedDiscountLine."No.");
                                                Item.SetRange(Blocked, false);
                                                if Item.FindSet() then begin
                                                    repeat
                                                        LineNo += 10000;
                                                        ItemHierarchyLine.Validate("Item Hierarchy Code", ItemHierarchy."Hierarchy Code");
                                                        ItemHierarchyLine.Validate("Item Hierarchy Line No.", LineNo);
                                                        ItemHierarchyLine.Validate("Item No.", Item."No.");
                                                        ItemHierarchyLine.Validate("Item Hierarchy Level", 0);
                                                        if ItemHierarchyLevel.Get(ItemHierarchy."Hierarchy Code", 10000) then begin
                                                            ItemHierarchyLine."Related Table Desc Field Value" := ItemHierarchyLevel.Code;
                                                            ItemHierarchyLine."Item Hierachy Description" := ItemHierarchyLevel.Code;
                                                        end;
                                                        ItemHierarchyLine.Insert(true);
                                                    until Item.Next() = 0
                                                end;
                                            end;
                                    end;
                                until MixedDiscountLine.Next() = 0;
                            end;
                        end;
                end;
            until RetailCampaignLine.Next() = 0;
        end;
    end;

}

