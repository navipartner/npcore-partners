codeunit 6151426 "NPR Magento Retail Cmn. Mgt."
{
    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Campaign Line", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertRetailCampaignLine(var Rec: Record "NPR Retail Campaign Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        InitMagentoCategoryLinks(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Campaign Line", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyRetailCampaignLine(var Rec: Record "NPR Retail Campaign Line"; var xRec: Record "NPR Retail Campaign Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if (xRec.Type <> Rec.Type) or (xRec.Code <> Rec.Code) then
            RemoveMagentoCategoryLinks(xRec);

        InitMagentoCategoryLinks(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Campaign Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnDeleteRetailCampaignLine(var Rec: Record "NPR Retail Campaign Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        RemoveMagentoCategoryLinks(Rec);
    end;

    local procedure RetailCampaignLine2MagentoCategory(RetailCampaignLine: Record "NPR Retail Campaign Line"; var MagentoCategory: Record "NPR Magento Category"): Boolean
    var
        RetailCampaignHeader: Record "NPR Retail Campaign Header";
    begin
        Clear(MagentoCategory);
        if not RetailCampaignHeader.Get(RetailCampaignLine."Campaign Code") then
            exit(false);

        if RetailCampaignHeader."Magento Category Id" = '' then
            exit(false);

        exit(MagentoCategory.Get(RetailCampaignHeader."Magento Category Id"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertPeriodDiscountLine(var Rec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        InitMagentoCategoryLinks2(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnDeletePeriodDiscountLine(var Rec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        RemoveMagentoCategoryLinks2(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Period Discount Line", 'OnAfterRenameEvent', '', true, true)]
    local procedure OnRenamePeriodDiscountLine(var Rec: Record "NPR Period Discount Line"; var xRec: Record "NPR Period Discount Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        RemoveMagentoCategoryLinks2(xRec);
        InitMagentoCategoryLinks2(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertMixedDiscountLine(var Rec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        InitMagentoCategoryLinks3(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnDeleteMixedDiscountLine(var Rec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        RemoveMagentoCategoryLinks3(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Mixed Discount Line", 'OnAfterRenameEvent', '', true, true)]
    local procedure OnRenameMixedDiscountLine(var Rec: Record "NPR Mixed Discount Line"; var xRec: Record "NPR Mixed Discount Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        RemoveMagentoCategoryLinks3(xRec);
        InitMagentoCategoryLinks3(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Campaign Header", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnInsertRetailCampaignHeader(var Rec: Record "NPR Retail Campaign Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        InitMagentoCategoryLinks4(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Campaign Header", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyRetailCampaignHeader(var Rec: Record "NPR Retail Campaign Header"; var xRec: Record "NPR Retail Campaign Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        if xRec."Magento Category Id" = Rec."Magento Category Id" then
            exit;

        RemoveMagentoCategoryLinks4(xRec);
        InitMagentoCategoryLinks4(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Retail Campaign Header", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnDeleteRetailCampaignHeader(var Rec: Record "NPR Retail Campaign Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
            exit;

        RemoveMagentoCategoryLinks4(Rec);
    end;

    local procedure InitMagentoCategoryLinks(RetailCampaignLine: Record "NPR Retail Campaign Line")
    var
        MagentoCategory: Record "NPR Magento Category";
        TempItem: Record Item temporary;
        MagentoCategoryLink: Record "NPR Magento Category Link";
    begin
        if RetailCampaignLine.Type = RetailCampaignLine.Type::" " then
            exit;
        if RetailCampaignLine.Code = '' then
            exit;
        if not RetailCampaignLine2MagentoCategory(RetailCampaignLine, MagentoCategory) then
            exit;

        FindRetailCampaignItems(RetailCampaignLine."Campaign Code", RetailCampaignLine.Type, RetailCampaignLine.Code, TempItem);
        if not TempItem.FindSet() then
            exit;

        repeat
            if not MagentoCategoryLink.Get(TempItem."No.", MagentoCategory.Id) then begin
                MagentoCategoryLink.Init();
                MagentoCategoryLink."Item No." := TempItem."No.";
                MagentoCategoryLink."Category Id" := MagentoCategory.Id;
                MagentoCategoryLink.Insert(true);
            end;
        until TempItem.Next() = 0;
    end;

    local procedure InitMagentoCategoryLinks2(PeriodDiscountLine: Record "NPR Period Discount Line")
    var
        Item: Record Item;
        MagentoCategory: Record "NPR Magento Category";
        MagentoCategoryLink: Record "NPR Magento Category Link";
        RetailCampaignLine: Record "NPR Retail Campaign Line";
    begin
        if PeriodDiscountLine."Item No." = '' then
            exit;
        if not Item.Get(PeriodDiscountLine."Item No.") then
            exit;

        RetailCampaignLine.SetRange(Type, RetailCampaignLine.Type::"Period Discount");
        RetailCampaignLine.SetRange(Code, PeriodDiscountLine.Code);
        if not RetailCampaignLine.FindSet() then
            exit;

        repeat
            if RetailCampaignLine2MagentoCategory(RetailCampaignLine, MagentoCategory) and
              not MagentoCategoryLink.Get(Item."No.", MagentoCategory.Id)
            then begin
                MagentoCategoryLink.Init();
                MagentoCategoryLink."Item No." := Item."No.";
                MagentoCategoryLink."Category Id" := MagentoCategory.Id;
                MagentoCategoryLink.Insert(true);
            end;
        until RetailCampaignLine.Next() = 0;
    end;

    local procedure InitMagentoCategoryLinks3(MixedDiscountLine: Record "NPR Mixed Discount Line")
    var
        TempItem: Record Item temporary;
        MagentoCategory: Record "NPR Magento Category";
        MagentoCategoryLink: Record "NPR Magento Category Link";
        RetailCampaignLine: Record "NPR Retail Campaign Line";
    begin
        if MixedDiscountLine."No." = '' then
            exit;

        RetailCampaignLine.SetRange(Type, RetailCampaignLine.Type::"Mixed Discount");
        RetailCampaignLine.SetRange(Code, MixedDiscountLine.Code);
        if RetailCampaignLine.IsEmpty then
            exit;

        FindMixedItems(MixedDiscountLine, TempItem);

        if TempItem.IsEmpty then
            exit;

        RetailCampaignLine.FindSet();
        repeat
            if RetailCampaignLine2MagentoCategory(RetailCampaignLine, MagentoCategory) then begin
                TempItem.FindSet();
                repeat
                    if not MagentoCategoryLink.Get(TempItem."No.", MagentoCategory.Id) then begin
                        MagentoCategoryLink.Init();
                        MagentoCategoryLink."Item No." := TempItem."No.";
                        MagentoCategoryLink."Category Id" := MagentoCategory.Id;
                        MagentoCategoryLink.Insert(true);
                    end;
                until TempItem.Next() = 0;
            end;
        until RetailCampaignLine.Next() = 0;
    end;

    local procedure InitMagentoCategoryLinks4(RetailCampaignHeader: Record "NPR Retail Campaign Header")
    var
        MagentoCategory: Record "NPR Magento Category";
        MagentoCategoryLink: Record "NPR Magento Category Link";
        RetailCampaignLine: Record "NPR Retail Campaign Line";
        TempItem: Record Item temporary;
    begin
        if RetailCampaignHeader."Magento Category Id" = '' then
            exit;
        if not MagentoCategory.Get(RetailCampaignHeader."Magento Category Id") then
            exit;

        FindRetailCampaignItems(RetailCampaignHeader.Code, RetailCampaignLine.Type::" ", '', TempItem);
        if not TempItem.FindSet() then
            exit;

        repeat
            if not MagentoCategoryLink.Get(TempItem."No.", MagentoCategory.Id) then begin
                MagentoCategoryLink.Init();
                MagentoCategoryLink."Item No." := TempItem."No.";
                MagentoCategoryLink."Category Id" := MagentoCategory.Id;
                MagentoCategoryLink.Insert(true);
            end;
        until TempItem.Next() = 0;
    end;

    local procedure RemoveMagentoCategoryLinks(RetailCampaignLine: Record "NPR Retail Campaign Line")
    var
        MagentoCategory: Record "NPR Magento Category";
        MagentoCategoryLink: Record "NPR Magento Category Link";
        TempItem: Record Item temporary;
        TempItem2: Record Item temporary;
    begin
        if RetailCampaignLine.Type = RetailCampaignLine.Type::" " then
            exit;
        if RetailCampaignLine.Code = '' then
            exit;
        if not RetailCampaignLine2MagentoCategory(RetailCampaignLine, MagentoCategory) then
            exit;

        FindRetailDiscountItems(RetailCampaignLine.Type, RetailCampaignLine.Code, TempItem);
        if TempItem.IsEmpty then
            exit;

        FindRetailCampaignItems(RetailCampaignLine."Campaign Code", RetailCampaignLine.Type::" ", '', TempItem2);
        TempItem.FindSet();
        repeat
            if MagentoCategoryLink.Get(TempItem."No.", MagentoCategory.Id) and not TempItem2.Get(TempItem."No.") then
                MagentoCategoryLink.Delete(true);
        until TempItem.Next() = 0;
    end;

    local procedure RemoveMagentoCategoryLinks2(PeriodDiscountLine: Record "NPR Period Discount Line")
    var
        MagentoCategory: Record "NPR Magento Category";
        MagentoCategoryLink: Record "NPR Magento Category Link";
        RetailCampaignLine: Record "NPR Retail Campaign Line";
        TempItem: Record Item temporary;
    begin
        if PeriodDiscountLine."Item No." = '' then
            exit;

        RetailCampaignLine.SetRange(Type, RetailCampaignLine.Type::"Period Discount");
        RetailCampaignLine.SetRange(Code, PeriodDiscountLine.Code);
        if not RetailCampaignLine.FindSet() then
            exit;

        repeat
            if RetailCampaignLine2MagentoCategory(RetailCampaignLine, MagentoCategory) and
              MagentoCategoryLink.Get(PeriodDiscountLine."Item No.", MagentoCategory.Id)
            then begin
                FindRetailCampaignItems(RetailCampaignLine."Campaign Code", RetailCampaignLine.Type::" ", '', TempItem);
                if not TempItem.Get(PeriodDiscountLine."Item No.") then
                    MagentoCategoryLink.Delete(true);
            end;
        until RetailCampaignLine.Next() = 0;
    end;

    local procedure RemoveMagentoCategoryLinks3(MixedDiscountLine: Record "NPR Mixed Discount Line")
    var
        TempItem: Record Item temporary;
        TempItem2: Record Item temporary;
        MagentoCategory: Record "NPR Magento Category";
        MagentoCategoryLink: Record "NPR Magento Category Link";
        RetailCampaignLine: Record "NPR Retail Campaign Line";
    begin
        if MixedDiscountLine."No." = '' then
            exit;

        RetailCampaignLine.SetRange(Type, RetailCampaignLine.Type::"Mixed Discount");
        RetailCampaignLine.SetRange(Code, MixedDiscountLine.Code);
        if RetailCampaignLine.IsEmpty then
            exit;

        FindMixedItems(MixedDiscountLine, TempItem);
        if TempItem.IsEmpty then
            exit;

        RetailCampaignLine.FindSet();
        repeat
            if RetailCampaignLine2MagentoCategory(RetailCampaignLine, MagentoCategory) then begin
                FindRetailCampaignItems(RetailCampaignLine."Campaign Code", RetailCampaignLine.Type::" ", '', TempItem2);
                TempItem.FindSet();
                repeat
                    if MagentoCategoryLink.Get(TempItem."No.", MagentoCategory.Id) and not TempItem2.Get(TempItem."No.") then
                        MagentoCategoryLink.Delete(true);
                until TempItem.Next() = 0;
            end;
        until RetailCampaignLine.Next() = 0;
    end;

    local procedure RemoveMagentoCategoryLinks4(RetailCampaignHeader: Record "NPR Retail Campaign Header")
    var
        MagentoCategory: Record "NPR Magento Category";
        MagentoCategoryLink: Record "NPR Magento Category Link";
        RetailCampaignLine: Record "NPR Retail Campaign Line";
        TempItem: Record Item temporary;
    begin
        if RetailCampaignHeader."Magento Category Id" = '' then
            exit;
        if not MagentoCategory.Get(RetailCampaignHeader."Magento Category Id") then
            exit;

        FindRetailCampaignItems(RetailCampaignHeader.Code, RetailCampaignLine.Type::" ", '', TempItem);
        if not TempItem.FindSet() then
            exit;

        repeat
            if MagentoCategoryLink.Get(TempItem."No.", MagentoCategory.Id) then
                MagentoCategoryLink.Delete(true);
        until TempItem.Next() = 0;
    end;

    local procedure FindRetailCampaignItems(RetailCampaignCode: Code[20]; Type: Option " ","Period Discount","Mixed Discount"; DiscountCode: Code[20]; var TempItem: Record Item temporary)
    begin
        if not TempItem.IsTemporary then
            exit;

        Clear(TempItem);
        TempItem.DeleteAll();

        case Type of
            Type::" ":
                begin
                    FindRetailCampaignItemsPeriodDiscItems(RetailCampaignCode, DiscountCode, TempItem);
                    FindRetailCampaignItemsMixedDiscItems0(RetailCampaignCode, DiscountCode, TempItem);
                    FindRetailCampaignItemsMixedDiscItems1(RetailCampaignCode, DiscountCode, TempItem);
                    FindRetailCampaignItemsMixedDiscItems2(RetailCampaignCode, DiscountCode, TempItem);
                end;
            Type::"Period Discount":
                begin
                    FindRetailCampaignItemsPeriodDiscItems(RetailCampaignCode, DiscountCode, TempItem);
                end;
            Type::"Mixed Discount":
                begin
                    FindRetailCampaignItemsMixedDiscItems0(RetailCampaignCode, DiscountCode, TempItem);
                    FindRetailCampaignItemsMixedDiscItems1(RetailCampaignCode, DiscountCode, TempItem);
                    FindRetailCampaignItemsMixedDiscItems2(RetailCampaignCode, DiscountCode, TempItem);
                end;
        end;
    end;

    local procedure FindRetailCampaignItemsPeriodDiscItems(RetailCampaignCode: Code[20]; DiscountCode: Code[20]; var TempItem: Record Item temporary)
    var
        RetailCampaignItemsPeriod: Query "NPR Campaign Items (Period)";
    begin
        RetailCampaignItemsPeriod.SetRange(Campaign_Code, RetailCampaignCode);
        RetailCampaignItemsPeriod.SetFilter(Discount_Code, DiscountCode);
        RetailCampaignItemsPeriod.Open();
        while RetailCampaignItemsPeriod.Read() do begin
            if not TempItem.Get(RetailCampaignItemsPeriod.Item_No) then begin
                TempItem.Init();
                TempItem."No." := RetailCampaignItemsPeriod.Item_No;
                TempItem.Insert();
            end;
        end;
        RetailCampaignItemsPeriod.Close();
    end;

    local procedure FindRetailCampaignItemsMixedDiscItems0(RetailCampaignCode: Code[20]; DiscountCode: Code[20]; var TempItem: Record Item temporary)
    var
        RetailCampaignItemsMix0: Query "NPR Retail Cmpgn.Items Mix 0";
    begin
        RetailCampaignItemsMix0.SetRange(Campaign_Code, RetailCampaignCode);
        RetailCampaignItemsMix0.SetFilter(Discount_Code, DiscountCode);
        RetailCampaignItemsMix0.Open();
        while RetailCampaignItemsMix0.Read() do begin
            if not TempItem.Get(RetailCampaignItemsMix0.Item_No) then begin
                TempItem.Init();
                TempItem."No." := RetailCampaignItemsMix0.Item_No;
                TempItem.Insert();
            end;
        end;
        RetailCampaignItemsMix0.Close();
    end;

    local procedure FindRetailCampaignItemsMixedDiscItems1(RetailCampaignCode: Code[20]; DiscountCode: Code[20]; var TempItem: Record Item temporary)
    var
        RetailCampaignItemsMix1: Query "NPR Retail Cmpgn. Items Mix 1";
    begin
        RetailCampaignItemsMix1.SetRange(Campaign_Code, RetailCampaignCode);
        RetailCampaignItemsMix1.SetFilter(Discount_Code, DiscountCode);
        RetailCampaignItemsMix1.Open();
        while RetailCampaignItemsMix1.Read() do begin
            if not TempItem.Get(RetailCampaignItemsMix1.Item_No) then begin
                TempItem.Init();
                TempItem."No." := RetailCampaignItemsMix1.Item_No;
                TempItem.Insert();
            end;
        end;
        RetailCampaignItemsMix1.Close();
    end;

    local procedure FindRetailCampaignItemsMixedDiscItems2(RetailCampaignCode: Code[20]; DiscountCode: Code[20]; var TempItem: Record Item temporary)
    var
        RetailCampaignItemsMix2: Query "NPR Retail Cmpgn Items Mix 2";
    begin
        RetailCampaignItemsMix2.SetRange(Campaign_Code, RetailCampaignCode);
        RetailCampaignItemsMix2.SetFilter(Discount_Code, DiscountCode);
        RetailCampaignItemsMix2.Open();
        while RetailCampaignItemsMix2.Read() do begin
            if not TempItem.Get(RetailCampaignItemsMix2.Item_No) then begin
                TempItem.Init();
                TempItem."No." := RetailCampaignItemsMix2.Item_No;
                TempItem.Insert();
            end;
        end;
        RetailCampaignItemsMix2.Close();
    end;

    local procedure FindRetailDiscountItems(Type: Option " ","Period Discount","Mixed Discount"; DiscountCode: Code[20]; var TempItem: Record Item temporary)
    begin
        if not TempItem.IsTemporary then
            exit;

        Clear(TempItem);
        TempItem.DeleteAll();

        case Type of
            Type::" ":
                begin
                    FindRetailDiscountItemsPeriodDiscItems(DiscountCode, TempItem);
                    FindRetailDiscountItemsMixedDiscItems0(DiscountCode, '', TempItem);
                    FindRetailDiscountItemsMixedDiscItems1(DiscountCode, '', TempItem);
                    FindRetailDiscountItemsMixedDiscItems2(DiscountCode, '', TempItem);
                end;
            Type::"Period Discount":
                begin
                    FindRetailDiscountItemsPeriodDiscItems(DiscountCode, TempItem);
                end;
            Type::"Mixed Discount":
                begin
                    FindRetailDiscountItemsMixedDiscItems0(DiscountCode, '', TempItem);
                    FindRetailDiscountItemsMixedDiscItems1(DiscountCode, '', TempItem);
                    FindRetailDiscountItemsMixedDiscItems2(DiscountCode, '', TempItem);
                end;
        end;
    end;

    local procedure FindRetailDiscountItemsPeriodDiscItems(DiscountCode: Code[20]; var TempItem: Record Item temporary)
    var
        PeriodDiscountItems: Query "NPR Period Discount Items";
    begin
        PeriodDiscountItems.SetFilter(Discount_Code, DiscountCode);
        PeriodDiscountItems.Open();
        while PeriodDiscountItems.Read() do begin
            if not TempItem.Get(PeriodDiscountItems.Item_No) then begin
                TempItem.Init();
                TempItem."No." := PeriodDiscountItems.Item_No;
                TempItem.Insert();
            end;
        end;
        PeriodDiscountItems.Close();
    end;

    local procedure FindRetailDiscountItemsMixedDiscItems0(DiscountCode: Code[20]; NoFilter: Code[20]; var TempItem: Record Item temporary)
    var
        MixedDiscountItemsMix0: Query "NPR Mixed Disc. Items Mix 0";
    begin
        MixedDiscountItemsMix0.SetFilter(Discount_code, DiscountCode);
        MixedDiscountItemsMix0.SetFilter(No, NoFilter);
        MixedDiscountItemsMix0.Open();
        while MixedDiscountItemsMix0.Read() do begin
            if not TempItem.Get(MixedDiscountItemsMix0.Item_No) then begin
                TempItem.Init();
                TempItem."No." := MixedDiscountItemsMix0.Item_No;
                TempItem.Insert();
            end;
        end;
        MixedDiscountItemsMix0.Close();
    end;

    local procedure FindRetailDiscountItemsMixedDiscItems1(DiscountCode: Code[20]; NoFilter: Code[20]; var TempItem: Record Item temporary)
    var
        MixedDiscountItemsMix1: Query "NPR Mixed Disc. Items Mix 1";
    begin
        MixedDiscountItemsMix1.SetFilter(Discount_Code, DiscountCode);
        MixedDiscountItemsMix1.SetFilter(No, NoFilter);
        MixedDiscountItemsMix1.Open();
        while MixedDiscountItemsMix1.Read() do begin
            if not TempItem.Get(MixedDiscountItemsMix1.Item_No) then begin
                TempItem.Init();
                TempItem."No." := MixedDiscountItemsMix1.Item_No;
                TempItem.Insert();
            end;
        end;
        MixedDiscountItemsMix1.Close();
    end;

    local procedure FindRetailDiscountItemsMixedDiscItems2(DiscountCode: Code[20]; NoFilter: Code[20]; var TempItem: Record Item temporary)
    var
        MixedDiscountItemsMix2: Query "NPR Mixed Disc. Items Mix 2";
    begin
        MixedDiscountItemsMix2.SetFilter(Discount_Code, DiscountCode);
        MixedDiscountItemsMix2.SetFilter(No, NoFilter);
        MixedDiscountItemsMix2.Open();
        while MixedDiscountItemsMix2.Read() do begin
            if not TempItem.Get(MixedDiscountItemsMix2.Item_No) then begin
                TempItem.Init();
                TempItem."No." := MixedDiscountItemsMix2.Item_No;
                TempItem.Insert();
            end;
        end;
        MixedDiscountItemsMix2.Close();
    end;

    local procedure FindMixedItems(MixedDiscountLine: Record "NPR Mixed Discount Line"; var TempItem: Record Item temporary)
    var
        Item: Record Item;
    begin
        if not TempItem.IsTemporary then
            exit;

        Clear(TempItem);
        TempItem.DeleteAll();

        if MixedDiscountLine."No." = '' then
            exit;

        case MixedDiscountLine."Disc. Grouping Type" of
            MixedDiscountLine."Disc. Grouping Type"::Item:
                begin
                    TempItem.Init();
                    TempItem."No." := MixedDiscountLine."No.";
                    TempItem.Insert();

                    exit;
                end;
            MixedDiscountLine."Disc. Grouping Type"::"Item Group":
                begin
                    Item.SetRange("Item Category Code", MixedDiscountLine."No.");
                end;
            MixedDiscountLine."Disc. Grouping Type"::"Item Disc. Group":
                begin
                    Item.SetRange("Item Disc. Group", MixedDiscountLine."No.");
                end;
        end;

        if not Item.FindSet() then
            exit;

        repeat
            TempItem.Init();
            TempItem := Item;
            TempItem.Insert();
        until Item.Next() = 0;
    end;
}