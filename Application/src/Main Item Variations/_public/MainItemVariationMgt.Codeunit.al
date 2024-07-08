Codeunit 6059856 "NPR Main Item Variation Mgt."
{
    Access = Public;

    #region Item
    procedure OpenMainItemVariationList(Item: Record "Item")
    var
        MainItemVariation: Record "NPR Main Item Variation";
    begin
        MainItemVariation.FilterGroup(2);
        if Item."NPR Main Item/Variation" = Item."NPR Main Item/Variation"::Variation then begin
            Item.TestField("NPR Main Item No.");
            MainItemVariation.SetRange("Main Item No.", Item."NPR Main Item No.");
        end else
            MainItemVariation.SetRange("Main Item No.", Item."No.");
        MainItemVariation.FilterGroup(0);
        Page.RunModal(0, MainItemVariation);
    end;

    procedure AddAsVariation(var Item: Record Item)
    var
        MainItem: Record Item;
        ConfirmAddAsVariationTxt: Label 'Are you sure you want set item No. %1 as a variation of main item No. %2?', Comment = '%1 - current item number, %2 - selected main item number';
    begin
        Item.TestField("NPR Main Item/Variation", Item."NPR Main Item/Variation"::" ");

        MainItem.FilterGroup(2);
        MainItem.SetFilter("NPR Main Item/Variation", '<>%1', MainItem."NPR Main Item/Variation"::Variation);
        MainItem.SetFilter("No.", '<>%1', Item."No.");
        MainItem.FilterGroup(0);
        if Page.RunModal(Page::"Item List", MainItem) = Action::LookupOK then begin
            if not Confirm(ConfirmAddAsVariationTxt, true, Item."No.", MainItem."No.") then
                exit;
            AddAsVariation(Item, MainItem."No.");
        end;
    end;

    procedure AddAsVariation(var Item: Record Item; MainItemNo: Code[20])
    var
        MainItemVariation: Record "NPR Main Item Variation";
    begin
        MainItemVariation.Init();
        MainItemVariation."Main Item No." := MainItemNo;
        MainItemVariation."Item No." := Item."No.";
        MainItemVariation.Description := Item.Description;
        MainItemVariation.CheckMainItemVariation();
        MainItemVariation.AddNewItemVariation(Item);
        MainItemVariation.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeItemDeleteCheckItemVariation(var Rec: Record Item; RunTrigger: Boolean);
    var
        CannotDeleteMainItemErr: Label 'A main item cannot be deleted.';
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."NPR Main Item/Variation" = Rec."NPR Main Item/Variation"::"Main Item" then
            Error(CannotDeleteMainItemErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterItemDeleteUpdateItemVariation(var Rec: Record Item; RunTrigger: Boolean);
    var
        MainItemVariation: Record "NPR Main Item Variation";
        MainItem: Record Item;
    begin
        if Rec.IsTemporary() then
            exit;

        MainItemVariation.SetCurrentKey("Item No.");
        MainItemVariation.SetRange("Item No.", Rec."No.");
        MainItemVariation.DeleteAll();

        if Rec."NPR Main Item/Variation" <> Rec."NPR Main Item/Variation"::Variation then
            exit;
        MainItemVariation.Reset();
        MainItemVariation.SetRange("Main Item No.", Rec."NPR Main Item No.");
        MainItemVariation.SetRange("Item No.", '');
        MainItemVariation.DeleteAll();

        MainItemVariation.SetRange("Item No.");
        if not MainItemVariation.IsEmpty() then
            exit;
        if MainItem.Get(Rec."NPR Main Item No.") then begin
            MainItem."NPR Main Item/Variation" := MainItem."NPR Main Item/Variation"::" ";
            MainItem."NPR Main Item No." := '';
            MainItem.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckMainItemVariation2(var MainItemVariation: Record "NPR Main Item Variation"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddNewItemVariation2(var MainItemVariation: Record "NPR Main Item Variation"; var VariationItem: Record Item; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRemoveItemVariation2(var MainItemVariation: Record "NPR Main Item Variation"; var Handled: Boolean);
    begin
    end;
    #endregion

    #region Auxiliary Item (Obsolete)
#pragma warning disable AL0432
    [Obsolete('Moving Auxiliary Item table fields back to Item table.', 'NPR23.0')]
    procedure OpenMainItemVariationList(AuxItem: Record "NPR Auxiliary Item")
    var
        MainItemVariation: Record "NPR Main Item Variation";
    begin
        MainItemVariation.FilterGroup(2);
        if AuxItem."Main Item/Variation" = AuxItem."Main Item/Variation"::Variation then begin
            AuxItem.TestField("Main Item No.");
            MainItemVariation.SetRange("Main Item No.", AuxItem."Main Item No.");
        end else
            MainItemVariation.SetRange("Main Item No.", AuxItem."Item No.");
        MainItemVariation.FilterGroup(0);
        Page.RunModal(0, MainItemVariation);
    end;

    [Obsolete('Moving Auxiliary Item table fields back to Item table.', 'NPR23.0')]
    procedure AddAsVariation(var ItemIn: Record Item; var AuxItemIn: Record "NPR Auxiliary Item")
    var
        Item: Record Item;
        AuxItem: Record "NPR Auxiliary Item";
        MainItem: Record Item;
        ConfirmAddAuxAsVariationTxt: Label 'Are you sure you want set item No. %1 as a variation of main item No. %2?', Comment = '%1 - current item number, %2 - selected main item number';
    begin
        Item := ItemIn;
        AuxItem := AuxItemIn;
        AuxItem.TestField("Main Item/Variation", Item."NPR Main Item/Variation"::" ");

        MainItem.FilterGroup(2);
        MainItem.SetFilter("No.", '<>%1', AuxItem."Item No.");
        MainItem.FilterGroup(0);
        if Page.RunModal(Page::"Item List", MainItem) = Action::LookupOK then begin
            if not Confirm(ConfirmAddAuxAsVariationTxt, true, AuxItem."Item No.", MainItem."No.") then
                exit;
            AddAsVariation(Item, AuxItem, MainItem."No.");
            AuxItemIn := AuxItem;
            ItemIn := Item;
        end;
    end;

    [Obsolete('Moving Auxiliary Item table fields back to Item table.', 'NPR23.0')]
    procedure AddAsVariation(Item: Record Item; var AuxItem: Record "NPR Auxiliary Item"; MainItemNo: Code[20])
    var
        MainItemVariation: Record "NPR Main Item Variation";
    begin
        MainItemVariation.Init();
        MainItemVariation."Main Item No." := MainItemNo;
        MainItemVariation."Item No." := Item."No.";
        MainItemVariation.Description := Item.Description;
        MainItemVariation.CheckMainItemVariation();
        MainItemVariation.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCheckMainItemVariation(var MainItemVariation: Record "NPR Main Item Variation"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAddNewItemVariation(var MainItemVariation: Record "NPR Main Item Variation"; var VariationAuxItem: Record "NPR Auxiliary Item"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRemoveItemVariation(var MainItemVariation: Record "NPR Main Item Variation"; var Handled: Boolean);
    begin
    end;
#pragma warning restore
    #endregion
}
