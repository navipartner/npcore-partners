codeunit 6014456 "NPR Item Category Mgt."
{
    var
        ConfirmationManagement: Codeunit "Confirm Management";

    #region Item Category creation and modification management
    internal procedure UpdateItemDiscGroupOnItems(ItemCategory: Record "Item Category"; ItemDiscGroupCode: Code[20]; xItemDiscGroupCode: Code[20])
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
                if ConfirmationManagement.GetResponseOrDefault(
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

    internal procedure CopySetupFromParent(var ItemCategory: Record "Item Category"; Silent: Boolean)
    var
        ParentItemCategory: Record "Item Category";
        ConfirmQst: Label 'You are about to move the relation to another item category, do you wish to inherit the attributes?';
    begin
        if ItemCategory."Parent Category" = '' then
            exit;

        ParentItemCategory.Get(ItemCategory."Parent Category");

        if (not Silent) then
            if not ConfirmationManagement.GetResponseOrDefault(ConfirmQst, false) then
                exit;

        CopyItemCategory(ParentItemCategory, ItemCategory);
        CopyParentItemCategoryDimensions(ItemCategory, true);
    end;

    internal procedure CopySetupToChildren(ParentItemCategory: Record "Item Category"; Silent: Boolean)
    var
        ChildItemCategory: Record "Item Category";
        ConfirmQst: Label 'Apply changes on Sub Item Categories?';
    begin
        ChildItemCategory.SetRange("Parent Category", ParentItemCategory.Code);
        if ChildItemCategory.IsEmpty() then
            exit;

        if not Silent then
            if not ConfirmationManagement.GetResponseOrDefault(ConfirmQst, false) then
                exit;

        ChildItemCategory.FindSet();
        repeat
            CopySetupFromParent(ChildItemCategory, Silent);
            CopySetupToChildren(ChildItemCategory, true);
        until ChildItemCategory.Next() = 0;
    end;

    internal procedure CopyItemCategory(FromItemCategory: Record "Item Category"; var ToItemCategory: Record "Item Category")
    var
        TemplateCode: Code[10];
    begin
        if (FromItemCategory.Code = '') or (ToItemCategory.Code = '') then
            exit;

        ToItemCategory.Validate("NPR Global Dimension 1 Code", FromItemCategory."NPR Global Dimension 1 Code");
        ToItemCategory.Validate("NPR Global Dimension 2 Code", FromItemCategory."NPR Global Dimension 2 Code");

        TemplateCode := CopyItemTemplate(FromItemCategory, ToItemCategory);
        if ToItemCategory."NPR Item Template Code" = '' then
            ToItemCategory."NPR Item Template Code" := TemplateCode;

        ToItemCategory.Modify(true);
    end;

    internal procedure SetBlockedOnChildren(ParentCode: Code[20]; IsBlocked: Boolean; Silent: Boolean)
    var
        ItemCategory: Record "Item Category";
        ConfirmQst: Label 'Do you wish to set %1 to %2 on Item Categories below this level?';
    begin
        ItemCategory.SetRange("Parent Category", ParentCode);
        if ItemCategory.IsEmpty() then
            exit;

        if not Silent then
            if not ConfirmationManagement.GetResponseOrDefault(StrSubstNo(ConfirmQst, ItemCategory.FieldCaption("NPR Blocked"), IsBlocked), false) then
                exit;

        if ItemCategory.FindSet(true) then
            repeat
                ItemCategory."NPR Blocked" := IsBlocked;
                ItemCategory.Modify(true);
                SetBlockedOnChildren(ItemCategory.Code, IsBlocked, true);
            until ItemCategory.Next() = 0;
    end;

    #endregion

    #region Item creation and modification management

    internal procedure CreateItemFromItemCategory(var ItemCategory: Record "Item Category"): Code[20]
    var
        Item: Record Item;
        ConfigTemplateHeader: Record "Config. Template Header";
    begin
        if ItemCategory.IsTemporary() then
            exit('');

        ItemCategory.TestField("NPR Item Template Code");

        ConfigTemplateHeader.Get(ItemCategory."NPR Item Template Code");
        ConfigTemplateHeader.TestField("Instance No. Series");
        ConfigTemplateHeader.TestField("Table ID", Database::Item);

        Item.Reset();
        InsertItemFromTemplate(ConfigTemplateHeader, Item);

        exit(Item."No.");
    end;

    internal procedure InsertItemFromTemplate(ConfigTemplateHeader: Record "Config. Template Header"; var Item: Record Item)
    var
        DimensionsTemplate: Record "Dimensions Template";
        UnitOfMeasure: Record "Unit of Measure";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        FoundUoM: Boolean;
    begin
        InitItemNo(Item, ConfigTemplateHeader);
        Item.Insert(true);
        RecRef.GetTable(Item);
        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(Item);

        if Item."Base Unit of Measure" = '' then begin
            UnitOfMeasure.SetRange("International Standard Code", 'EA'); // 'Each' ~= 'PCS'
            FoundUoM := UnitOfMeasure.FindFirst();
            if not FoundUoM then begin
                UnitOfMeasure.SetRange("International Standard Code");
                FoundUoM := UnitOfMeasure.FindFirst();
            end;
            if FoundUoM then begin
                Item.Validate("Base Unit of Measure", UnitOfMeasure.Code);
                Item.Modify(true);
            end;
        end;

        DimensionsTemplate.InsertDimensionsFromTemplates(ConfigTemplateHeader, Item."No.", DATABASE::Item);
        Item.Find();

        OnAfterInsertItemFromTemplate(Item, ConfigTemplateHeader);
    end;

    local procedure InitItemNo(var Item: Record Item; ConfigTemplateHeader: Record "Config. Template Header")
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitItemNo(Item, ConfigTemplateHeader, IsHandled);
        if IsHandled then
            exit;

        if ConfigTemplateHeader."Instance No. Series" = '' then
            exit;
        NoSeriesMgt.InitSeries(ConfigTemplateHeader."Instance No. Series", '', 0D, Item."No.", Item."No. Series");
    end;

    internal procedure SetupItemFromCategory(var Item: Record Item; var ItemCategory: Record "Item Category")
    var
        // TempItem: Record Item temporary;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin
        ItemCategory.TestField("NPR Blocked", false);
        ItemCategory.TestField("NPR Main Category", false);
        ItemCategory.TestField("NPR Item Template Code");

        ConfigTemplateHeader.Get(ItemCategory."NPR Item Template Code");

        RecRef.GetTable(Item);
        ConfigTemplateMgt.ApplyTemplateLinesWithoutValidation(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(Item);

        // ApplyTemplateToTempItem(TempItem, ItemCategory);

        // if Item.Type <> TempItem.Type then
        //     Item.Validate(Item.Type, TempItem.Type);

        // Item.Validate(Item."Gen. Prod. Posting Group", TempItem."Gen. Prod. Posting Group");
        // Item."VAT Prod. Posting Group" := TempItem."VAT Prod. Posting Group";
        // Item."VAT Bus. Posting Gr. (Price)" := TempItem."VAT Bus. Posting Gr. (Price)";
        // Item."Tax Group Code" := TempItem."Tax Group Code";
        // Item.Validate(Item."Inventory Posting Group", TempItem."Inventory Posting Group");

        // Item.Validate(Item."Item Disc. Group", TempItem."Item Disc. Group");
        // Item.Validate(Item."NPR Guarantee voucher", TempItem."NPR Guarantee voucher");
        // Item."Costing Method" := TempItem."Costing Method";

        // DefaultDimension2.SetRange("Table ID", DATABASE::Item);
        // DefaultDimension2.SetRange("No.", Item."No.");
        // DefaultDimension2.DeleteAll();
        // DefaultDimension.SetRange("Table ID", DATABASE::"Item Category");
        // DefaultDimension.SetRange("No.", Item."Item Category Code");
        // if DefaultDimension.FindSet() then
        //     repeat
        //         DefaultDimension2 := DefaultDimension;
        //         DefaultDimension2."Table ID" := DATABASE::Item;
        //         DefaultDimension2."No." := Item."No.";
        //         DefaultDimension2.Insert();
        //     until DefaultDimension.Next() = 0;

        // Item."Global Dimension 1 Code" := ItemCategory."NPR Global Dimension 1 Code";
        // Item."Global Dimension 2 Code" := ItemCategory."NPR Global Dimension 2 Code";

        // AddItemUOMIfMissing(item."No.", TempItem."Base Unit of Measure");
        // AddItemUOMIfMissing(item."No.", TempItem."Sales Unit of Measure");
        // AddItemUOMIfMissing(item."No.", TempItem."Purch. Unit of Measure");

        // if Item."Base Unit of Measure" <> TempItem."Base Unit of Measure" then begin
        //     Item.Validate(Item."Base Unit of Measure", TempItem."Base Unit of Measure");
        //     Item.Validate(Item."Sales Unit of Measure", TempItem."Sales Unit of Measure");
        //     Item.Validate(Item."Sales Unit of Measure", TempItem."Purch. Unit of Measure");
        // end;

        // if TempItem."NPR Variety Group" <> '' then
        // Item.Validate(Item."NPR Variety Group", TempItem."NPR Variety Group");

        // Item.Validate("Item Category Code", ItemCategory.Code);

        ApplyItemCategoryDimensionsToItem(ItemCategory, Item, true);
    end;

    internal procedure GetVATPostingSetupFromItemCategory(ItemCategory: Record "Item Category"; var VATPostingSetup: Record "VAT Posting Setup"): Boolean
    var
        TempItem: Record Item temporary;
    begin
        if ItemCategory.IsTemporary() then
            exit(false);

        if not ApplyTemplateToTempItem(TempItem, ItemCategory) then
            exit(false);

        exit(VATPostingSetup.Get(TempItem."VAT Bus. Posting Gr. (Price)", TempItem."VAT Prod. Posting Group"));
    end;

    #endregion

    #region Config. Template management 

    internal procedure ApplyTemplateToTempItem(var TempItem: Record Item temporary; ItemCategory: Record "Item Category"): Boolean
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
        ConfigTemplateLine: Record "Config. Template Line";
        Fields: Record Field;
        TemplateFields: Array[20] of FieldRef;
        ConfigTemplateCode: Code[10];
        ConfigTemplateMgt: Codeunit "Config. Template Management";
    begin
        if ItemCategory.IsTemporary() then
            exit;

        if ItemCategory."NPR Item Template Code" <> '' then
            exit;

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
        SetFieldRef(TemplateFields[13], TempItem, TempItem.FieldNo("Gen. Prod. Posting Group"));
        SetFieldRef(TemplateFields[14], TempItem, TempItem.FieldNo("VAT Prod. Posting Group"));
        SetFieldRef(TemplateFields[15], TempItem, TempItem.FieldNo("VAT Bus. Posting Gr. (Price)"));
        SetFieldRef(TemplateFields[16], TempItem, TempItem.FieldNo("Inventory Posting Group"));
        SetFieldRef(TemplateFields[17], TempItem, TempItem.FieldNo("NPR Group sale"));
        SetFieldRef(TemplateFields[18], TempItem, TempItem.FieldNo("Price Includes VAT"));
        SetFieldRef(TemplateFields[19], TempItem, TempItem.FieldNo("Price/Profit Calculation"));
        SetFieldRef(TemplateFields[20], TempItem, TempItem.FieldNo("Item Category Code"));

        ConfigTemplateMgt.CreateConfigTemplateAndLines(
           ConfigTemplateCode, ItemCategory.Description, Database::Item, TemplateFields);

        if TempItem."No. Series" <> '' then begin
            ConfigTemplateHeader.Get(ConfigTemplateCode);
            ConfigTemplateHeader."Instance No. Series" := TempItem."No. Series";
            ConfigTemplateHeader.Modify();
        end;

        ConfigTemplateLine.Reset();
        ConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateCode);
        if ConfigTemplateLine.FindSet() then
            repeat
                if Fields.Get(ConfigTemplateLine."Table ID", ConfigTemplateLine."Field ID") then begin
                    ConfigTemplateLine."Field Name" := Fields.FieldName;
                    ConfigTemplateLine.Modify();
                end;
            until ConfigTemplateLine.Next() = 0;

        exit(ConfigTemplateCode);
    end;

    internal procedure CopyItemTemplate(FromItemCategory: Record "Item Category"; ToItemCategory: Record "Item Category"): Code[10]
    var
        FromConfigTemplateHeader: Record "Config. Template Header";
        FromConfigTemplateLine: Record "Config. Template Line";
        ToConfigTemplateHeader: Record "Config. Template Header";
        ToConfigTemplateLine: Record "Config. Template Line";
        ConfigTemplateCode: Code[10];
        Item: Record Item;
    begin
        if FromItemCategory.IsTemporary() or ToItemCategory.IsTemporary() then
            exit('');

        if (FromItemCategory.Code = '') or (ToItemCategory.Code = '') or (FromItemCategory."NPR Item Template Code" = '') then
            exit('');

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
                if (FromConfigTemplateLine."Table ID" = Database::Item) and (FromConfigTemplateLine."Field ID" = Item.FieldNo("Item Category Code")) then
                    ToConfigTemplateLine."Default Value" := ToItemCategory.Code;
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

    internal procedure ApplyDimensionsToChildren(DefaultDimension: Record "Default Dimension"; DeleteDimension: Boolean; Silent: Boolean)
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

        if not Silent then
            if not ConfirmationManagement.GetResponseOrDefault(ConfirmQst, false) then
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

            ApplyDimensionsToChildren(DefaultDimension2, DeleteDimension, true);
        until ChildItemCategory.Next() = 0;
    end;

    internal procedure CopyParentItemCategoryDimensions(ItemCategory: Record "Item Category"; Silent: Boolean)
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

        if not Silent then
            if not ConfirmationManagement.GetResponseOrDefault(ConfirmQst, false) then
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
            ApplyDimensionsToChildren(DefaultDimension2, false, true);
        until DefaultDimension.Next() = 0;
    end;

    internal procedure ApplyItemCategoryDimensionsToItem(ItemCategory: Record "Item Category"; Item: Record Item; Silent: Boolean)
    var
        DefaultDimension: Record "Default Dimension";
        DefaultDimension2: Record "Default Dimension";
        ConfirmQst: Label 'Apply Dimensions from Item Category to Item?';
    begin
        if ItemCategory.IsTemporary() or Item.IsTemporary() then
            exit;

        if (ItemCategory.Code = '') or (Item."No." = '') then
            exit;

        DefaultDimension.SetRange("Table ID", Database::"Item Category");
        DefaultDimension.SetRange("No.", ItemCategory.Code);
        if DefaultDimension.IsEmpty() then
            exit;

        if not Silent then
            if not ConfirmationManagement.GetResponseOrDefault(ConfirmQst, false) then
                exit;

        repeat
            if DefaultDimension2.Get(Database::Item, Item."No.", DefaultDimension."Dimension Code") then
                DefaultDimension2.Delete(true);

            DefaultDimension2.Init();
            DefaultDimension2 := DefaultDimension;
            DefaultDimension2."Table ID" := Database::Item;
            DefaultDimension2."No." := Item."No.";
            DefaultDimension2.Insert(true);
        until DefaultDimension.Next() = 0;
    end;

    #endregion


    #region Item Category Report Managment

    #region Insert to Item Category Buffer

    [Obsolete('In next release goes internal')]
    procedure InsertItemCategoryToBuffer(ItemRootCategoryCode: Code[20]; var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; SalespersonCode: Code[20]; GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20]; CalcFieldsDict: Dictionary of [Integer, Decimal])
    var
        ItemCategory: Record "Item Category";
    begin
        if not ItemCategory.Get(ItemRootCategoryCode) then
            exit;
        ItemCategoryBuffer."Entry No." := GetItemCategoryBufferEntryNo(ItemCategoryBuffer);
        ItemCategoryBuffer.Code := ItemCategory.Code;
        ItemCategoryBuffer."Parent Category" := ItemCategory."Parent Category";
        ItemCategoryBuffer."Code with Indentation" := ItemCategory.Code;
        ItemCategoryBuffer.Description := ItemCategory.Description;
        ItemCategoryBuffer.Indentation := ItemCategory.Indentation;
        ItemCategoryBuffer."Presentation Order" := ItemCategory."Presentation Order";
        ItemCategoryBuffer."Has Children" := ItemCategory."Has Children";
        ItemCategoryBuffer."Last Modified Date Time" := ItemCategory."Last Modified Date Time";
        ItemCategoryBuffer."Salesperson Code" := SalespersonCode;
        ItemCategoryBuffer."Global Dimension 1 Code" := GlobalDimension1Code;
        ItemCategoryBuffer."Global Dimension 2 Code" := GlobalDimension2Code;
        ItemCategoryBuffer.Insert();
        InsertCalcFieldsInItemCategoryBuffer(ItemCategoryBuffer, CalcFieldsDict);
    end;

    [Obsolete('In next release goes internal')]
    procedure InsertItemCategoryToBuffer(ItemRootCategoryCode: Code[20]; var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; SalespersonCode: Code[20]; GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20])
    var
        ItemCategory: Record "Item Category";
    begin
        if not ItemCategory.Get(ItemRootCategoryCode) then
            exit;
        ItemCategoryBuffer.Init();
        ItemCategoryBuffer."Entry No." := GetItemCategoryBufferEntryNo(ItemCategoryBuffer);
        ItemCategoryBuffer.Code := ItemCategory.Code;
        ItemCategoryBuffer."Parent Category" := ItemCategory."Parent Category";
        ItemCategoryBuffer."Code with Indentation" := ItemCategory.Code;
        ItemCategoryBuffer.Description := ItemCategory.Description;
        ItemCategoryBuffer.Indentation := ItemCategory.Indentation;
        ItemCategoryBuffer."Presentation Order" := ItemCategory."Presentation Order";
        ItemCategoryBuffer."Has Children" := ItemCategory."Has Children";
        ItemCategoryBuffer."Last Modified Date Time" := ItemCategory."Last Modified Date Time";
        ItemCategoryBuffer."Salesperson Code" := SalespersonCode;
        ItemCategoryBuffer."Salesperson Code" := SalespersonCode;
        ItemCategoryBuffer."Global Dimension 1 Code" := GlobalDimension1Code;
        ItemCategoryBuffer."Global Dimension 2 Code" := GlobalDimension2Code;
        ItemCategoryBuffer."Calc Field 1" := 0;
        ItemCategoryBuffer."Calc Field 2" := 0;
        ItemCategoryBuffer."Calc Field 3" := 0;
        ItemCategoryBuffer."Calc Field 4" := 0;
        ItemCategoryBuffer."Calc Field 5" := 0;
        ItemCategoryBuffer."Calc Field 6" := 0;
        ItemCategoryBuffer."Calc Field 7" := 0;
        ItemCategoryBuffer."Calc Field 8" := 0;
        ItemCategoryBuffer."Calc Field 9" := 0;
        ItemCategoryBuffer."Calc Field 10" := 0;
        ItemCategoryBuffer.Insert();
    end;

    [Obsolete('In next release goes internal')]
    procedure InsertItemCategoryToBuffer(ItemRootCategoryCode: Code[20]; var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary)
    var
        ItemCategory: Record "Item Category";
    begin
        if not ItemCategory.Get(ItemRootCategoryCode) then
            exit;
        ItemCategoryBuffer.Init();
        ItemCategoryBuffer."Entry No." := GetItemCategoryBufferEntryNo(ItemCategoryBuffer);
        ItemCategoryBuffer.Code := ItemCategory.Code;
        ItemCategoryBuffer."Parent Category" := ItemCategory."Parent Category";
        ItemCategoryBuffer."Code with Indentation" := ItemCategory.Code;
        ItemCategoryBuffer.Description := ItemCategory.Description;
        ItemCategoryBuffer.Indentation := ItemCategory.Indentation;
        ItemCategoryBuffer."Presentation Order" := ItemCategory."Presentation Order";
        ItemCategoryBuffer."Has Children" := ItemCategory."Has Children";
        ItemCategoryBuffer."Last Modified Date Time" := ItemCategory."Last Modified Date Time";
        ItemCategoryBuffer."Calc Field 1" := 0;
        ItemCategoryBuffer."Calc Field 2" := 0;
        ItemCategoryBuffer."Calc Field 3" := 0;
        ItemCategoryBuffer."Calc Field 4" := 0;
        ItemCategoryBuffer."Calc Field 5" := 0;
        ItemCategoryBuffer."Calc Field 6" := 0;
        ItemCategoryBuffer."Calc Field 7" := 0;
        ItemCategoryBuffer."Calc Field 8" := 0;
        ItemCategoryBuffer."Calc Field 9" := 0;
        ItemCategoryBuffer."Calc Field 10" := 0;
        ItemCategoryBuffer.Insert();
    end;

    [Obsolete('In next release goes internal')]
    procedure InsertUncatagorizedToItemCategoryBuffer(ItemCategoryCode: Code[20]; Description: Text[100]; var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; SalespersonCode: Code[20]; CalcFieldsDict: Dictionary of [Integer, Decimal])
    begin
        ItemCategoryBuffer.Init();
        ItemCategoryBuffer."Entry No." := GetItemCategoryBufferEntryNo(ItemCategoryBuffer);
        ItemCategoryBuffer.Code := ItemCategoryCode;
        ItemCategoryBuffer."Parent Category" := '';
        ItemCategoryBuffer."Code with Indentation" := ItemCategoryCode;
        ItemCategoryBuffer.Description := Description;
        ItemCategoryBuffer.Indentation := 0;
        ItemCategoryBuffer."Presentation Order" := 1;
        ItemCategoryBuffer."Has Children" := false;
        ItemCategoryBuffer."Salesperson Code" := SalespersonCode;
        ItemCategoryBuffer.Insert();
        InsertCalcFieldsInItemCategoryBuffer(ItemCategoryBuffer, CalcFieldsDict);
    end;

    [Obsolete('In next release goes internal')]
    procedure AddItemCategoryParentsToBuffer(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary)
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
    begin
        if ItemCategoryBuffer.IsEmpty() then
            exit;

        ItemCategoryBuffer.Reset();

        if ItemCategoryBuffer.FindSet() then
            repeat
                TempItemCategoryBuffer.Init();
                TempItemCategoryBuffer := ItemCategoryBuffer;
                TempItemCategoryBuffer.Insert();
            until ItemCategoryBuffer.Next() = 0;

        TempItemCategoryBuffer.SetFilter("Parent Category", '<>%1', '');

        if TempItemCategoryBuffer.FindSet() then
            repeat
                InsertItemCategoryParentsToBuffer(ItemCategoryBuffer, TempItemCategoryBuffer);
            until TempItemCategoryBuffer.Next() = 0;

        UpdateParentsCalcFieldsValues(ItemCategoryBuffer);
    end;

    local procedure InsertItemCategoryParentsToBuffer(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; CurrItemCategoryBuffer: Record "NPR Item Category Buffer" temporary)
    var
        ItemCategory: Record "Item Category";
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        ItemCategoryCode: Code[20];
    begin
        ItemCategoryCode := CurrItemCategoryBuffer."Parent Category";

        ItemCategoryBuffer.Reset();
        if ItemCategoryBuffer.FindSet() then
            repeat
                TempItemCategoryBuffer.Init();
                TempItemCategoryBuffer := ItemCategoryBuffer;
                TempItemCategoryBuffer.Insert();
            until ItemCategoryBuffer.Next() = 0;

        repeat
            if ItemCategory.Get(ItemCategoryCode) then;

            TempItemCategoryBuffer.SetRange(Code, ItemCategoryCode);
            TempItemCategoryBuffer.SetRange("Salesperson Code", CurrItemCategoryBuffer."Salesperson Code");
            TempItemCategoryBuffer.SetRange("Global Dimension 1 Code", CurrItemCategoryBuffer."Global Dimension 1 Code");
            TempItemCategoryBuffer.SetRange("Global Dimension 2 Code", CurrItemCategoryBuffer."Global Dimension 2 Code");

            if not TempItemCategoryBuffer.FindFirst() then begin
                ItemCategoryBuffer.Reset();
                InsertItemCategoryToBuffer(ItemCategoryCode, ItemCategoryBuffer, CurrItemCategoryBuffer."Salesperson Code", CurrItemCategoryBuffer."Global Dimension 1 Code", CurrItemCategoryBuffer."Global Dimension 2 Code");
            end;

            ItemCategoryCode := ItemCategory."Parent Category";
        until ItemCategoryCode = '';
    end;

    local procedure GetItemCategoryBufferEntryNo(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary): Integer
    begin
        ItemCategoryBuffer.Reset();

        if ItemCategoryBuffer.FindLast() then
            exit(ItemCategoryBuffer."Entry No." + 10000);
        exit(10000);
    end;

    #endregion

    #region Sorting and Formating
    [Obsolete('In next release goes internal')]
    procedure SortItemCategoryBuffer(var ItemCategoryBuffer: Record "NPR Item Category Buffer"; FieldNo: Integer; Ascending: Boolean)
    begin
        if ItemCategoryBuffer.IsEmpty() then
            exit;

        if CheckIfCalcFieldExistsInItemCategoryBuffer(FieldNo) = 0 then
            exit;

        ChangeItemCategoryBufferPresentationOrder(ItemCategoryBuffer, FieldNo, Ascending);
    end;

    local procedure ChangeItemCategoryBufferPresentationOrder(var ItemCategoryBuffer: Record "NPR Item Category Buffer"; FieldNo: Integer; Ascending: Boolean)
    var
        PresentationOrder: Integer;
        TempItemCategoryBuffer2: Record "NPR Item Category Buffer" temporary;
        TempNewItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
    begin
        PresentationOrder := 1;
        if ItemCategoryBuffer.FindSet() then
            repeat
                TempItemCategoryBuffer2.Init();
                TempItemCategoryBuffer2 := ItemCategoryBuffer;
                TempItemCategoryBuffer2.Insert();
            until ItemCategoryBuffer.Next() = 0;

        SetSortOrderOnCalcField(TempItemCategoryBuffer2, FieldNo, Ascending);

        TempItemCategoryBuffer2.SetFilter("Parent Category", '%1', '');
        if TempItemCategoryBuffer2.FindSet() then
            repeat
                TempNewItemCategoryBuffer.Init();
                TempNewItemCategoryBuffer := TempItemCategoryBuffer2;
                TempNewItemCategoryBuffer."Presentation Order" := PresentationOrder;
                PresentationOrder += 1;
                TempNewItemCategoryBuffer.Insert();
                SortItemCategoryBufferChilds(TempNewItemCategoryBuffer.Code, TempNewItemCategoryBuffer, ItemCategoryBuffer, PresentationOrder, FieldNo, Ascending);
            until TempItemCategoryBuffer2.Next() = 0;

        ItemCategoryBuffer.DeleteAll();

        TempNewItemCategoryBuffer.Reset();
        if TempNewItemCategoryBuffer.FindSet() then
            repeat
                ItemCategoryBuffer.Init();
                ItemCategoryBuffer := TempNewItemCategoryBuffer;
                ItemCategoryBuffer.Insert();
            until TempNewItemCategoryBuffer.Next() = 0;
    end;

    local procedure SortItemCategoryBufferChilds(ItemCategoryCode: Code[20]; var NewItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; var ItemCategoryBufferSet: Record "NPR Item Category Buffer" temporary; var PresentationOrder: Integer; FieldNo: Integer; Ascending: Boolean)
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
    begin
        if ItemCategoryBufferSet.FindSet() then
            repeat
                TempItemCategoryBuffer.Init();
                TempItemCategoryBuffer := ItemCategoryBufferSet;
                TempItemCategoryBuffer.Insert();
            until ItemCategoryBufferSet.Next() = 0;

        SetSortOrderOnCalcField(TempItemCategoryBuffer, FieldNo, Ascending);

        TempItemCategoryBuffer.SetRange("Parent Category", ItemCategoryCode);
        if TempItemCategoryBuffer.FindSet() then
            repeat
                NewItemCategoryBuffer.Init();
                NewItemCategoryBuffer := TempItemCategoryBuffer;
                NewItemCategoryBuffer."Presentation Order" := PresentationOrder;
                PresentationOrder += 1;
                if NewItemCategoryBuffer.Insert() then;
                SortItemCategoryBufferChilds(TempItemCategoryBuffer.Code, NewItemCategoryBuffer, ItemCategoryBufferSet, PresentationOrder, FieldNo, Ascending);
            until TempItemCategoryBuffer.Next() = 0;
    end;

    [Obsolete('In next release goes internal')]
    procedure FormatIndentationInItemCategories(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; NumberOfSpaces: Integer)
    begin
        ItemCategoryBuffer.Reset();
        if ItemCategoryBuffer.FindSet() then
            repeat
                ItemCategoryBuffer."Code with Indentation" := ItemCategoryBuffer.Code;
                ItemCategoryBuffer."Code with Indentation" := CopyStr(ItemCategoryBuffer."Code with Indentation".PadLeft(StrLen(ItemCategoryBuffer."Code with Indentation") + ItemCategoryBuffer."Indentation" * NumberOfSpaces, ' '), 1, MaxStrLen(ItemCategoryBuffer."Code with Indentation"));
                ItemCategoryBuffer.Modify();
            until ItemCategoryBuffer.Next() = 0;
    end;

    [Obsolete('In next release goes internal')]
    procedure SetOrderNoInItemCategoryBuffer(var ItemCategoryBuffer: Record "NPR Item Category Buffer")
    var
        Index: Integer;
    begin
        if ItemCategoryBuffer.IsEmpty() then
            exit;

        Index := 1;
        ItemCategoryBuffer.SetRange(Indentation, 0);

        ItemCategoryBuffer.SetCurrentKey("Presentation Order");
        ItemCategoryBuffer.SetAscending("Presentation Order", true);

        ItemCategoryBuffer.FindSet();
        repeat
            ItemCategoryBuffer."Order No." := Index;
            ItemCategoryBuffer.Modify();
            Index += 1;
        until ItemCategoryBuffer.Next() = 0;

        ItemCategoryBuffer.Reset();
        ItemCategoryBuffer.SetFilter(Indentation, '>%1', 0);
        ItemCategoryBuffer.ModifyAll("Order No.", 0);
    end;

    local procedure SetSortOrderOnCalcField(var ItemCategoryBuffer: Record "NPR Item Category Buffer"; FieldNo: Integer; Ascending: Boolean): Integer
    begin
        case FieldNo of
            ItemCategoryBuffer.FieldNo("Calc Field 1"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 1");
                    ItemCategoryBuffer.SetAscending("Calc Field 1", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 2"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 2");
                    ItemCategoryBuffer.SetAscending("Calc Field 2", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 3"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 3");
                    ItemCategoryBuffer.SetAscending("Calc Field 3", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 4"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 4");
                    ItemCategoryBuffer.SetAscending("Calc Field 4", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 5"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 5");
                    ItemCategoryBuffer.SetAscending("Calc Field 5", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 6"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 6");
                    ItemCategoryBuffer.SetAscending("Calc Field 6", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 7"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 7");
                    ItemCategoryBuffer.SetAscending("Calc Field 7", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 8"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 8");
                    ItemCategoryBuffer.SetAscending("Calc Field 8", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 9"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 9");
                    ItemCategoryBuffer.SetAscending("Calc Field 9", Ascending);
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 10"):
                begin
                    ItemCategoryBuffer.SetCurrentKey("Calc Field 10");
                    ItemCategoryBuffer.SetAscending("Calc Field 10", Ascending);
                end;
        end;
    end;

    #endregion

    #region Item Category Buffer. Calc Fields Mgt.

    procedure ClearCalcFieldsDictionary(var CalcFieldsDict: Dictionary of [Integer, Decimal])
    var
        DictKey: Integer;
    begin
        foreach DictKey in CalcFieldsDict.Keys() do begin
            CalcFieldsDict.Remove(DictKey);
        end;
    end;

    [Obsolete('In next release goes internal')]
    procedure SetCalcFieldValue(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; FieldNo: Integer; Value: Decimal)
    begin
        if CheckIfCalcFieldExistsInItemCategoryBuffer(FieldNo) = 0 then
            Error('Codeunit:''NPR Item Category Mgt.''\Procedure:''SetCalcFieldValue''\Field with id %1 does not exists in table Item Category Buffer.', FieldNo);
        case FieldNo of
            ItemCategoryBuffer.FieldNo("Calc Field 1"):
                begin
                    ItemCategoryBuffer."Calc Field 1" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 2"):
                begin
                    ItemCategoryBuffer."Calc Field 2" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 3"):
                begin
                    ItemCategoryBuffer."Calc Field 3" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 4"):
                begin
                    ItemCategoryBuffer."Calc Field 4" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 5"):
                begin
                    ItemCategoryBuffer."Calc Field 5" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 6"):
                begin
                    ItemCategoryBuffer."Calc Field 6" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 7"):
                begin
                    ItemCategoryBuffer."Calc Field 7" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 8"):
                begin
                    ItemCategoryBuffer."Calc Field 8" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 9"):
                begin
                    ItemCategoryBuffer."Calc Field 9" += Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 10"):
                begin
                    ItemCategoryBuffer."Calc Field 10" += Value;
                    ItemCategoryBuffer.Modify();
                end;
        end;
    end;

    local procedure InsertCalcFieldValue(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; FieldNo: Integer; Value: Decimal)
    begin
        if CheckIfCalcFieldExistsInItemCategoryBuffer(FieldNo) = 0 then
            Error('Codeunit:''NPR Item Category Mgt.''\Procedure:''InsertCalcFieldValue''\Field with id %1 does not exists in table Item Category Buffer.', FieldNo);
        case FieldNo of
            ItemCategoryBuffer.FieldNo("Calc Field 1"):
                begin
                    ItemCategoryBuffer."Calc Field 1" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 2"):
                begin
                    ItemCategoryBuffer."Calc Field 2" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 3"):
                begin
                    ItemCategoryBuffer."Calc Field 3" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 4"):
                begin
                    ItemCategoryBuffer."Calc Field 4" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 5"):
                begin
                    ItemCategoryBuffer."Calc Field 5" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 6"):
                begin
                    ItemCategoryBuffer."Calc Field 6" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 7"):
                begin
                    ItemCategoryBuffer."Calc Field 7" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 8"):
                begin
                    ItemCategoryBuffer."Calc Field 8" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 9"):
                begin
                    ItemCategoryBuffer."Calc Field 9" := Value;
                    ItemCategoryBuffer.Modify();
                end;
            ItemCategoryBuffer.FieldNo("Calc Field 10"):
                begin
                    ItemCategoryBuffer."Calc Field 10" := Value;
                    ItemCategoryBuffer.Modify();
                end;
        end;
    end;

    local procedure GetCalcFieldValue(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; FieldNo: Integer): Decimal
    begin
        if CheckIfCalcFieldExistsInItemCategoryBuffer(FieldNo) = 0 then
            Error('Codeunit:''NPR Item Category Mgt.''\Procedure:''GetCalcFieldValue''\Field with id %1 does not exists in table Item Category Buffer.', FieldNo);

        case FieldNo of
            ItemCategoryBuffer.FieldNo("Calc Field 1"):
                exit(ItemCategoryBuffer."Calc Field 1");
            ItemCategoryBuffer.FieldNo("Calc Field 2"):
                exit(ItemCategoryBuffer."Calc Field 2");
            ItemCategoryBuffer.FieldNo("Calc Field 3"):
                exit(ItemCategoryBuffer."Calc Field 3");
            ItemCategoryBuffer.FieldNo("Calc Field 4"):
                exit(ItemCategoryBuffer."Calc Field 4");
            ItemCategoryBuffer.FieldNo("Calc Field 5"):
                exit(ItemCategoryBuffer."Calc Field 5");
            ItemCategoryBuffer.FieldNo("Calc Field 6"):
                exit(ItemCategoryBuffer."Calc Field 6");
            ItemCategoryBuffer.FieldNo("Calc Field 7"):
                exit(ItemCategoryBuffer."Calc Field 7");
            ItemCategoryBuffer.FieldNo("Calc Field 8"):
                exit(ItemCategoryBuffer."Calc Field 8");
            ItemCategoryBuffer.FieldNo("Calc Field 9"):
                exit(ItemCategoryBuffer."Calc Field 9");
            ItemCategoryBuffer.FieldNo("Calc Field 10"):
                exit(ItemCategoryBuffer."Calc Field 10");
        end;
    end;

    local procedure InsertCalcFieldsInItemCategoryBuffer(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; CalcFieldsDictionary: Dictionary of [Integer, Decimal])
    var
        DictKey: Integer;
        Value: Decimal;
    begin
        foreach DictKey in CalcFieldsDictionary.Keys() do begin
            if CheckIfCalcFieldExistsInItemCategoryBuffer(DictKey) = 0 then
                Error('Codeunit:''NPR Item Category Mgt.''\Procedure:''InsertCalcFieldsInItemCategoryBuffer''\Field with id %1 does not exists in table Item Category Buffer.', DictKey);

            Value := CalcFieldsDictionary.Get(DictKey);
            InsertCalcFieldValue(ItemCategoryBuffer, DictKey, Value);
        end;
    end;

    [Obsolete('In next release goes internal')]
    procedure SetCalcFieldsInItemCategoryBuffer(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; CalcFieldsDictionary: Dictionary of [Integer, Decimal])
    var
        DictKey: Integer;
        Value: Decimal;
    begin
        foreach DictKey in CalcFieldsDictionary.Keys() do begin
            if CheckIfCalcFieldExistsInItemCategoryBuffer(DictKey) = 0 then
                Error('Codeunit:''NPR Item Category Mgt.''\Procedure:''SetCalcFieldsInItemCategoryBuffer''\Field with id %1 does not exists in table Item Category Buffer.', DictKey);

            Value := CalcFieldsDictionary.Get(DictKey);
            SetCalcFieldValue(ItemCategoryBuffer, DictKey, Value);
        end;
    end;

    local procedure CheckIfCalcFieldExistsInItemCategoryBuffer(FieldNo: Integer): Integer
    var
        ItemCategoryBuffer: Record "NPR Item Category Buffer";
    begin
        case FieldNo of
            ItemCategoryBuffer.FieldNo("Calc Field 1"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 1"));
            ItemCategoryBuffer.FieldNo("Calc Field 2"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 2"));
            ItemCategoryBuffer.FieldNo("Calc Field 3"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 3"));
            ItemCategoryBuffer.FieldNo("Calc Field 4"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 4"));
            ItemCategoryBuffer.FieldNo("Calc Field 5"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 5"));
            ItemCategoryBuffer.FieldNo("Calc Field 6"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 6"));
            ItemCategoryBuffer.FieldNo("Calc Field 7"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 7"));
            ItemCategoryBuffer.FieldNo("Calc Field 8"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 8"));
            ItemCategoryBuffer.FieldNo("Calc Field 9"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 9"));
            ItemCategoryBuffer.FieldNo("Calc Field 10"):
                exit(ItemCategoryBuffer.FieldNo("Calc Field 10"));
            else
                exit(0);
        end;
    end;

    local procedure UpdateParentsCalcFieldsValues(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary)
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
        CalcFields: Array[10] of Decimal;
    begin
        ItemCategoryBuffer.Reset();
        if ItemCategoryBuffer.FindSet() then
            repeat
                TempItemCategoryBuffer.Init();
                TempItemCategoryBuffer := ItemCategoryBuffer;
                TempItemCategoryBuffer.Insert();
            until ItemCategoryBuffer.Next() = 0;

        ItemCategoryBuffer.Reset();
        if ItemCategoryBuffer.FindSet() then
            repeat
                CalcFields[1] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 1"));
                CalcFields[2] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 2"));
                CalcFields[3] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 3"));
                CalcFields[4] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 4"));
                CalcFields[5] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 5"));
                CalcFields[6] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 6"));
                CalcFields[7] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 7"));
                CalcFields[8] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 8"));
                CalcFields[9] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 9"));
                CalcFields[10] := GetTotalCalcFieldValuesDict(ItemCategoryBuffer, TempItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 10"));
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 1"), CalcFields[1]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 2"), CalcFields[2]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 3"), CalcFields[3]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 4"), CalcFields[4]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 5"), CalcFields[5]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 6"), CalcFields[6]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 7"), CalcFields[7]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 8"), CalcFields[8]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 9"), CalcFields[9]);
                InsertCalcFieldValue(ItemCategoryBuffer, ItemCategoryBuffer.FieldNo("Calc Field 10"), CalcFields[10]);
            until ItemCategoryBuffer.Next() = 0;
    end;

    local procedure GetTotalCalcFieldValuesDict(var CurrItemCategoryBuffer: Record "NPR Item Category Buffer" temporary; var ItemCategoryBufferFull: Record "NPR Item Category Buffer" temporary; FieldNo: Integer) Amount: Decimal
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
    begin

        if ItemCategoryBufferFull.FindSet() then
            repeat
                TempItemCategoryBuffer.Init();
                TempItemCategoryBuffer := ItemCategoryBufferFull;
                TempItemCategoryBuffer.Insert();
            until ItemCategoryBufferFull.Next() = 0;

        TempItemCategoryBuffer.SetRange("Parent Category", CurrItemCategoryBuffer.Code);
        TempItemCategoryBuffer.SetRange("Salesperson Code", CurrItemCategoryBuffer."Salesperson Code");
        TempItemCategoryBuffer.SetRange("Global Dimension 1 Code", CurrItemCategoryBuffer."Global Dimension 1 Code");
        TempItemCategoryBuffer.SetRange("Global Dimension 2 Code", CurrItemCategoryBuffer."Global Dimension 2 Code");

        Amount := GetCalcFieldValue(CurrItemCategoryBuffer, FieldNo);

        if TempItemCategoryBuffer.FindSet() then
            repeat
                Amount += GetTotalCalcFieldValuesDict(TempItemCategoryBuffer, ItemCategoryBufferFull, FieldNo);
            until TempItemCategoryBuffer.Next() = 0;
        exit(Amount);
    end;

    #endregion

    [Obsolete('In next release goes internal')]
    procedure DeleteItemCategoryBuffer(ItemCategoryCode: Code[20]; SalespersonCode: Code[20]; GlobalDimensionCode1: Code[20]; GlobalDimensionCode2: Code[20]; var ItemCatagoryBuffer: Record "NPR Item Category Buffer" temporary; var ItemCategoryBufferFull: Record "NPR Item Category Buffer" temporary)
    var
        TempItemCategoryBuffer: Record "NPR Item Category Buffer" temporary;
    begin
        if ItemCategoryBufferFull.FindSet() then
            repeat
                TempItemCategoryBuffer.Init();
                TempItemCategoryBuffer := ItemCategoryBufferFull;
                TempItemCategoryBuffer.Insert();
            until ItemCategoryBufferFull.Next() = 0;

        TempItemCategoryBuffer.SetRange("Parent Category", ItemCategoryCode);
        TempItemCategoryBuffer.SetRange("Salesperson Code", SalespersonCode);
        TempItemCategoryBuffer.SetRange("Global Dimension 1 Code", GlobalDimensionCode1);
        TempItemCategoryBuffer.SetRange("Global Dimension 2 Code", GlobalDimensionCode2);

        if TempItemCategoryBuffer.FindSet() then
            repeat
                DeleteItemCategoryBuffer(TempItemCategoryBuffer.Code, SalespersonCode, GlobalDimensionCode1, GlobalDimensionCode2, ItemCatagoryBuffer, ItemCategoryBufferFull);
            until TempItemCategoryBuffer.Next() = 0;

        ItemCatagoryBuffer.Reset();

        ItemCatagoryBuffer.SetRange(Code, ItemCategoryCode);
        ItemCatagoryBuffer.SetRange("Salesperson Code", SalespersonCode);
        ItemCatagoryBuffer.SetRange("Global Dimension 1 Code", GlobalDimensionCode1);
        ItemCatagoryBuffer.SetRange("Global Dimension 2 Code", GlobalDimensionCode2);

        if ItemCatagoryBuffer.FindFirst() then
            ItemCatagoryBuffer.Delete();
    end;

    #endregion

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertItemFromTemplate(var Item: Record Item; ConfigTemplateHeader: Record "Config. Template Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitItemNo(var Item: Record Item; ConfigTemplateHeader: Record "Config. Template Header"; var IsHandled: Boolean)
    begin
    end;
}
