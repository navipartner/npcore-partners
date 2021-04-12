codeunit 6014456 "NPR Item Category Mgt."
{
    #region Item Category creation and modification management

    procedure CreateNoSeries(ItemCategory: Record "Item Category"): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        NoSeriesCode: Code[20];
        NoSeriesDescTok: Label 'Item Category %1 number series.';
        ItemCategoryCodeTooLongErr: Label 'Item Category Code is too long. Please keep it up to 10 characters long.';
        NoSeriesPrefTok: Label 'ITEMCAT_', Locked = true;
    begin
        if StrLen(NoSeriesPrefTok + ItemCategory.Code) > 10 then
            error(ItemCategoryCodeTooLongErr);

        evaluate(NoSeriesCode, NoSeriesPrefTok + ItemCategory.Code);


        if not NoSeries.Get(NoSeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := NoSeriesCode;
            NoSeries.Description := StrSubstNo(NoSeriesDescTok, ItemCategory.Code);
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := true;
            NoSeries."Date Order" := false;
            NoSeries.Insert(true);

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := NoSeries.Code;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := CalcDate('<-1D>', Today());
            evaluate(NoSeriesLine."Starting No.", ItemCategory.Code + '000000');
            evaluate(NoSeriesLine."Ending No.", ItemCategory.Code + '999999');
            evaluate(NoSeriesLine."Warning No.", ItemCategory.Code + '999000');
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine."Last No. Used" := NoSeriesLine."Starting No.";
            NoSeriesLine.Open := true;
            NoSeriesLine.Insert(true);
        end;

        exit(NoSeriesCode);
    end;

    procedure UpdateItemDiscGroupOnItems(ItemCategory: Record "Item Category"; ItemDiscGroupCode: Code[20]; xItemDiscGroupCode: Code[20])
    var
        Item: Record Item;
        ConfirmQst: Label 'Items have been found belonging to %1 %2, but not having %3 in %4.\Edit these to %4 %5';
    begin
        if ItemCategory.Code = '' then
            exit;

        // Check if there are items with different item disc. group than was previously in template and ask if ok to change them.
        // Otherwise just change all items for item category code.
        Item.SetRange("Item Category Code", ItemCategory.Code);
        if not Item.IsEmpty() then begin
            Item.SetFilter("Item Disc. Group", '<>%1', xItemDiscGroupCode);
            if not Item.IsEmpty() then
                if ConfirmedOrGuiNotAlloved(
                        StrSubstNo(ConfirmQst, ItemCategory.TableCaption(), ItemCategory.Code, xItemDiscGroupCode, Item.FieldCaption("Item Disc. Group"), ItemDiscGroupCode),
                        false)
                then
                    Item.SetRange("Item Disc. Group")
                else
                    Item.SetRange("Item Disc. Group", xItemDiscGroupCode);
        end else
            Item.SetRange("Item Disc. Group");

        Item.ModifyAll("Item Disc. Group", ItemDiscGroupCode);
    end;

    procedure CopySetupFromParent(var ItemCategory: Record "Item Category"; Silent: Boolean)
    var
        ParentItemCategory: Record "Item Category";
        ConfirmQst: Label 'You are about to move the relation to another item category, do you wish to inherit the attributes?';
    begin
        if ItemCategory."Parent Category" = '' then
            exit;

        ParentItemCategory.Get(ItemCategory."Parent Category");

        if (not Silent) and (not ConfirmedOrGuiNotAlloved(ConfirmQst, false)) then
            exit;

        CopyItemCategory(ParentItemCategory, ItemCategory);
    end;

    procedure CopySetupToChildren(ParentItemCategory: Record "Item Category"; Silent: Boolean)
    var
        ChildItemCategory: Record "Item Category";
        ConfirmQst: Label 'Apply changes on Sub Item Categories?';
    begin
        ChildItemCategory.SetRange("Parent Category", ParentItemCategory.Code);
        if ChildItemCategory.IsEmpty() then
            exit;

        if not ConfirmedOrGuiNotAlloved(ConfirmQst, false) then
            exit;

        ChildItemCategory.FindSet();
        repeat
            CopyItemCategory(ParentItemCategory, ChildItemCategory);
        until ChildItemCategory.Next() = 0;
    end;

    procedure CopyItemCategory(FromItemCategory: Record "Item Category"; var ToItemCategory: Record "Item Category")
    var
        TemplateCode: Code[10];
    begin
        if (FromItemCategory.Code = '') or (ToItemCategory.Code = '') then
            exit;

        ToItemCategory."NPR VAT Prod. Posting Group" := FromItemCategory."NPR VAT Prod. Posting Group";
        ToItemCategory."NPR VAT Bus. Posting Group" := FromItemCategory."NPR VAT Bus. Posting Group";
        ToItemCategory."NPR Gen. Prod. Posting Group" := FromItemCategory."NPR Gen. Prod. Posting Group";
        ToItemCategory."NPR Gen. Bus. Posting Group" := FromItemCategory."NPR Gen. Bus. Posting Group";
        ToItemCategory."NPR Inventory Posting Group" := FromItemCategory."NPR Inventory Posting Group";
        ToItemCategory."NPR Global Dimension 1 Code" := FromItemCategory."NPR Global Dimension 1 Code";
        ToItemCategory."NPR Global Dimension 2 Code" := FromItemCategory."NPR Global Dimension 2 Code";

        TemplateCode := CopyItemTemplate(FromItemCategory, ToItemCategory);
        if ToItemCategory."NPR Item Template Code" = '' then
            ToItemCategory."NPR Item Template Code" := TemplateCode;

        ToItemCategory.Modify(true);
    end;

    procedure SetBlockedOnChildren(ParentCode: Code[20]; IsBlocked: Boolean; Silent: Boolean)
    var
        ItemCategory: Record "Item Category";
        ConfirmQst: Label 'Do you wish to set %1 to %2  on Item Categories below this level?';
    begin
        ItemCategory.SetRange("Parent Category", ParentCode);
        if ItemCategory.IsEmpty() then
            exit;

        if (not Silent) or (not ConfirmedOrGuiNotAlloved(ConfirmQst, false)) then
            exit;

        if ItemCategory.FindSet(true) then
            repeat
                ItemCategory."NPR Blocked" := IsBlocked;
                SetBlockedOnChildren(ItemCategory.Code, IsBlocked, true);
            until ItemCategory.Next() = 0;
    end;

    procedure CheckItemCategory(var ItemCategory: Record "Item Category"; CalledFromFieldNo: Integer)
    var
        ItemCategory2: Record "Item Category";
    begin
        if CalledFromFieldNo = ItemCategory.FieldNo("NPR Blocked") then begin
            if not ItemCategory."NPR Blocked" then begin
                ItemCategory.TestField("NPR Gen. Prod. Posting Group");
                ItemCategory.TestField("NPR Gen. Bus. Posting Group");
                ItemCategory2.Get(ItemCategory."Parent Category");
            end;
        end else
            if (ItemCategory."NPR Gen. Prod. Posting Group" = '') or
               (ItemCategory."NPR Gen. Bus. Posting Group" = '') or
               (not ItemCategory2.Get(ItemCategory."Parent Category"))
            then
                ItemCategory."NPR Blocked" := true;
    end;

    #endregion

    #region Item creation and modification management

    procedure SetupItemFromCategory(var Item: Record Item; var ItemCategory: Record "Item Category")
    var
        DefaultDimension: Record "Default Dimension";
        DefaultDimension2: Record "Default Dimension";
        TempItem: Record Item temporary;
        ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
    begin
        ItemCategory.TestField("NPR Blocked", false);
        ItemCategory.TestField("NPR Main Category", false);
        ItemCategory.TestField("NPR Item Template Code");
        ItemCategory.TestField("NPR VAT Bus. Posting Group");
        ItemCategory.TestField("NPR Gen. Prod. Posting Group");
        ItemCategory.TestField("NPR VAT Prod. Posting Group");

        ItemCategoryMgt.ApplyTemplateToTempItem(TempItem, ItemCategory);

        if TempItem.Type <> TempItem.Type::Service then
            ItemCategory.TestField("NPR Inventory Posting Group");

        if Item.Type <> TempItem.Type then
            Item.Validate(Item.Type, TempItem.Type);

        Item.Validate(Item."Gen. Prod. Posting Group", ItemCategory."NPR Gen. Prod. Posting Group");
        Item."VAT Prod. Posting Group" := ItemCategory."NPR VAT Prod. Posting Group";
        Item."VAT Bus. Posting Gr. (Price)" := ItemCategory."NPR VAT Bus. Posting Group";
        Item."Tax Group Code" := TempItem."Tax Group Code";
        Item.Validate(Item."Inventory Posting Group", ItemCategory."NPR Inventory Posting Group");

        Item.Validate(Item."Item Disc. Group", TempItem."Item Disc. Group");
        Item.Validate(Item."NPR Guarantee voucher", TempItem."NPR Guarantee voucher");
        Item."Costing Method" := TempItem."Costing Method";

        DefaultDimension2.SetRange("Table ID", DATABASE::Item);
        DefaultDimension2.SetRange("No.", Item."No.");
        DefaultDimension2.DeleteAll();
        DefaultDimension.SetRange("Table ID", DATABASE::"Item Category");
        DefaultDimension.SetRange("No.", Item."Item Category Code");
        if DefaultDimension.FindSet() then
            repeat
                DefaultDimension2 := DefaultDimension;
                DefaultDimension2."Table ID" := DATABASE::Item;
                DefaultDimension2."No." := Item."No.";
                DefaultDimension2.Insert();
            until DefaultDimension.Next() = 0;

        Item."Global Dimension 1 Code" := ItemCategory."NPR Global Dimension 1 Code";
        Item."Global Dimension 2 Code" := ItemCategory."NPR Global Dimension 2 Code";

        AddItemUOMIfMissing(item."No.", TempItem."Base Unit of Measure");
        AddItemUOMIfMissing(item."No.", TempItem."Sales Unit of Measure");
        AddItemUOMIfMissing(item."No.", TempItem."Purch. Unit of Measure");

        if Item."Base Unit of Measure" <> TempItem."Base Unit of Measure" then begin
            Item.Validate(Item."Base Unit of Measure", TempItem."Base Unit of Measure");
            Item.Validate(Item."Sales Unit of Measure", TempItem."Sales Unit of Measure");
            Item.Validate(Item."Sales Unit of Measure", TempItem."Purch. Unit of Measure");
        end;

        if TempItem."NPR Variety Group" <> '' then
            Item.Validate(Item."NPR Variety Group", TempItem."NPR Variety Group");
    end;

    local procedure AddItemUOMIfMissing(ItemNo: Code[20]; ItemUomCode: Code[10])
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if not ItemUnitofMeasure.Get(ItemNo, ItemUomCode) and (ItemUomCode <> '') then begin
            ItemUnitOfMeasure."Item No." := ItemNo;
            ItemUnitOfMeasure.Code := ItemUomCode;
            ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
            if ItemUnitOfMeasure.Insert() then
                ;
        end;
    end;

    #endregion

    #region Config. Template management 

    procedure ApplyTemplateToTempItem(var TempItem: Record Item temporary; ItemCategory: Record "Item Category"): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin
        if not TempItem.IsTemporary then
            exit(false);

        TempItem.Reset();
        TempItem.DeleteAll();
        TempItem.Init();
        TempItem."No." := 'TMP';
        TempItem.Insert();

        if ItemCategory."NPR Item Template Code" = '' then
            exit(false);

        ConfigTemplateHeader.Get(ItemCategory."NPR Item Template Code");

        RecRef.GetTable(TempItem);
        ConfigTemplateMgt.ApplyTemplateLinesWithoutValidation(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(TempItem);

        exit(true);
    end;

    procedure CreateItemTemplate(ItemCategory: Record "Item Category"; TempItem: Record Item temporary): Code[10]
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        TemplateFields: Array[13] of FieldRef;
        ConfigTemplateCode: Code[10];
    begin
        if ItemCategory.IsTemporary() then
            exit;

        ItemCategory.Testfield("NPR Item Template Code", '');

        ConfigTemplateCode := GetNextItemTemplateCode();

        SetFieldRef(TemplateFields[1], TempItem, TempItem.FieldNo(Type));
        SetFieldRef(TemplateFields[2], TempItem, TempItem.FieldNo("Item Disc. Group"));
        SetFieldRef(TemplateFields[3], TempItem, TempItem.FieldNo("No. Series"));
        SetFieldRef(TemplateFields[4], TempItem, TempItem.FieldNo("Costing Method"));
        SetFieldRef(TemplateFields[5], TempItem, TempItem.FieldNo("Base Unit of Measure")); // Base unit of Measure must be first
        SetFieldRef(TemplateFields[6], TempItem, TempItem.FieldNo("Sales Unit of Measure"));
        SetFieldRef(TemplateFields[7], TempItem, TempItem.FieldNo("Purch. Unit of Measure"));
        SetFieldRef(TemplateFields[8], TempItem, TempItem.FieldNo("NPR Guarantee voucher"));
        SetFieldRef(TemplateFields[9], TempItem, TempItem.FieldNo("Tax Group Code"));
        SetFieldRef(TemplateFields[10], TempItem, TempItem.FieldNo("Tariff No."));
        SetFieldRef(TemplateFields[11], TempItem, TempItem.FieldNo("Reordering Policy"));
        SetFieldRef(TemplateFields[12], TempItem, TempItem.FieldNo("NPR Variety Group"));
        SetFieldRef(TemplateFields[13], TempItem, TempItem.FieldNo("Item Category Code"));

        ConfigTemplateMgt.CreateConfigTemplateAndLines(
            ConfigTemplateCode, ItemCategory.Description, Database::Item, TemplateFields);

        if TempItem."No. Series" <> '' then begin
            ConfigTemplateHeader.Get(ConfigTemplateCode);
            ConfigTemplateHeader."Instance No. Series" := TempItem."No. Series";
            ConfigTemplateHeader.Modify();
        end;

        exit(ConfigTemplateCode);
    end;

    procedure CopyItemTemplate(FromItemCategory: Record "Item Category"; ToItemCategory: Record "Item Category"): Code[10]
    var
        FromConfigTemplateHeader: Record "Config. Template Header";
        FromConfigTemplateLine: Record "Config. Template Line";
        ToConfigTemplateHeader: Record "Config. Template Header";
        ToConfigTemplateLine: Record "Config. Template Line";
        ConfigTemplateCode: Code[10];
    begin
        if FromItemCategory.IsTemporary() or ToItemCategory.IsTemporary() then
            exit;

        if (FromItemCategory.Code = '') or (ToItemCategory.Code = '') then
            exit;

        FromConfigTemplateHeader.Get(FromItemCategory."NPR Item Template Code");

        if ToItemCategory."NPR Item Template Code" = '' then begin
            ConfigTemplateCode := GetNextItemTemplateCode();

            ToConfigTemplateHeader.Init();
            ToConfigTemplateHeader.Code := ConfigTemplateCode;
            ToConfigTemplateHeader."Table ID" := Database::Item;
            ToConfigTemplateHeader.Description := ToItemCategory.Description;
            ToConfigTemplateHeader.Insert(true);
        end else
            ConfigTemplateCode := ToItemCategory."NPR Item Template Code";

        ToConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateCode);
        ToConfigTemplateLine.DeleteAll(true);

        ToConfigTemplateLine.SetRange("Data Template Code");

        FromConfigTemplateLine.SetRange("Data Template Code", FromConfigTemplateHeader.Code);
        if FromConfigTemplateLine.FindSet() then
            repeat
                ToConfigTemplateLine.Init();
                ToConfigTemplateLine.TransferFields(FromConfigTemplateLine);
                ToConfigTemplateLine."Data Template Code" := ConfigTemplateCode;
                ToConfigTemplateLine.Insert(true);
            until FromConfigTemplateLine.Next() = 0;

        exit(ConfigTemplateCode);
    end;

    local procedure SetFieldRef(var FR: FieldRef; var Item: Record Item; FieldId: Integer)
    var
        RR: RecordRef;
    begin
        RR.GetTable(Item);
        FR := RR.Field(FieldId);
    end;

    local procedure GetNextItemTemplateCode() TemplateCode: Code[10]
    var
        TempText: Text;
        TemplatePrefixTok: Label 'ICT', Locked = true;
    begin
        if not NumberSequence.Exists(TemplatePrefixTok) then
            NumberSequence.Insert(TemplatePrefixTok, 1, 1, true);

        // Safe bet there will never be more than 9999999 categories?
        TempText := Format(NumberSequence.Next(TemplatePrefixTok));
        TempText := TemplatePrefixTok + TempText.PadLeft(7, '0');

        evaluate(TemplateCode, TempText);
    end;

    #endregion

    #region Dimension management

    procedure ApplyDimensionsToChildren(DefaultDimension: Record "Default Dimension"; DeleteDimension: Boolean; "Query": Boolean)
    var
        DefaultDimension2: Record "Default Dimension";
        ChildItemCategory: Record "Item Category";
        ConfirmQst: Label 'Apply Dimension change on Sub Item Groups?';
    begin
        if DefaultDimension.IsTemporary then
            exit;
        if DefaultDimension."Table ID" <> DATABASE::"Item Category" then
            exit;

        ChildItemCategory.SetRange("Parent Category", DefaultDimension."No.");
        if ChildItemCategory.IsEmpty() then
            exit;

        if not ConfirmedOrGuiNotAlloved(ConfirmQst, false) then
            exit;

        ChildItemCategory.FindSet();
        repeat
            if DeleteDimension then begin
                if DefaultDimension2.Get(DATABASE::"Item Category", ChildItemCategory.Code, DefaultDimension."Dimension Code") then
                    DefaultDimension2.Delete(true);
            end else
                if not DefaultDimension2.Get(DATABASE::"Item Category", ChildItemCategory.Code, DefaultDimension."Dimension Code") then begin
                    DefaultDimension2.Init();
                    DefaultDimension2 := DefaultDimension;
                    DefaultDimension2."No." := ChildItemCategory.Code;
                    DefaultDimension2.Insert(true);
                end else begin
                    DefaultDimension2.TransferFields(DefaultDimension, false);
                    DefaultDimension2.Modify(true);
                end;

            ApplyDimensionsToChildren(DefaultDimension2, DeleteDimension, false);
        until ChildItemCategory.Next() = 0;
    end;

    procedure CopyParentItemCategoryDimensions(ItemCategory: Record "Item Category"; "Query": Boolean)
    var
        DefaultDimension: Record "Default Dimension";
        DefaultDimension2: Record "Default Dimension";
        ConfirmQst: Label 'Apply Dimensions from Parent Item Category?';
    begin
        if ItemCategory."Parent Category" = '' then
            exit;

        DefaultDimension.SetRange("Table ID", DATABASE::"Item Category");
        DefaultDimension.SetRange("No.", ItemCategory."Parent Category");
        if DefaultDimension.IsEmpty() then
            exit;

        if not ConfirmedOrGuiNotAlloved(ConfirmQst, false) then
            exit;

        DefaultDimension.FindSet();
        repeat
            if not DefaultDimension2.Get(DATABASE::"Item Category", ItemCategory.Code, DefaultDimension."Dimension Code") then begin
                DefaultDimension2.Init();
                DefaultDimension2 := DefaultDimension;
                DefaultDimension2."No." := ItemCategory.Code;
                DefaultDimension2.Insert(true);
            end else begin
                DefaultDimension2.TransferFields(DefaultDimension, false);
                DefaultDimension2.Modify(true);
            end;
            ApplyDimensionsToChildren(DefaultDimension2, false, false);
        until DefaultDimension.Next() = 0;
    end;

    #endregion

    #region misc 

    procedure ConfirmedOrGuiNotAlloved(Qst: Text; Default: Boolean): Boolean
    begin
        if not GuiAllowed() then
            exit(Default);

        exit(Confirm(Qst));
    end;

    #endregion
}