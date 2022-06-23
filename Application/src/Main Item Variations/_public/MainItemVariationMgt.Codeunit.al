Codeunit 6059856 "NPR Main Item Variation Mgt."
{
    Access = Public;

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

    procedure AddAsVariation(var ItemIn: Record Item; var AuxItemIn: Record "NPR Auxiliary Item")
    var
        Item: Record Item;
        AuxItem: Record "NPR Auxiliary Item";
        MainItem: Record Item;
        ConfirmAddAsVariationTxt: Label 'Are you sure you want set item No. %1 as a variation of main item No. %2?', Comment = '%1 - current item number, %2 - selected main item number';
    begin
        Item := ItemIn;
        AuxItem := AuxItemIn;
        AuxItem.TestField("Main Item/Variation", AuxItem."Main Item/Variation"::" ");

        MainItem.FilterGroup(2);
        MainItem.SetFilter("No.", '<>%1', AuxItem."Item No.");
        MainItem.FilterGroup(0);
        if Page.RunModal(Page::"Item List", MainItem) = Action::LookupOK then begin
            if not Confirm(ConfirmAddAsVariationTxt, true, AuxItem."Item No.", MainItem."No.") then
                exit;
            AddAsVariation(Item, AuxItem, MainItem."No.");
            AuxItemIn := AuxItem;
            ItemIn := Item;
        end;
    end;

    procedure AddAsVariation(Item: Record Item; var AuxItem: Record "NPR Auxiliary Item"; MainItemNo: Code[20])
    var
        MainItemVariation: Record "NPR Main Item Variation";
    begin
        MainItemVariation.Init();
        MainItemVariation."Main Item No." := MainItemNo;
        MainItemVariation."Item No." := Item."No.";
        MainItemVariation.Description := Item.Description;
        MainItemVariation.CheckMainItemVariation();
        MainItemVariation.AddNewItemVariation(AuxItem);
        MainItemVariation.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Auxiliary Item", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeItemDelete(var Rec: Record "NPR Auxiliary Item"; RunTrigger: Boolean);
    var
        CannotDeleteMainItemErr: Label 'A main item cannot be deleted.';
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Main Item/Variation" = Rec."Main Item/Variation"::"Main Item" then
            Error(CannotDeleteMainItemErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Auxiliary Item", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterItemDelete(var Rec: Record "NPR Auxiliary Item"; RunTrigger: Boolean);
    var
        MainItemVariation: Record "NPR Main Item Variation";
        MainAuxItem: Record "NPR Auxiliary Item";
    begin
        if Rec.IsTemporary() then
            exit;

        MainItemVariation.SetCurrentKey("Item No.");
        MainItemVariation.SetRange("Item No.", Rec."Item No.");
        MainItemVariation.DeleteAll();

        if Rec."Main Item/Variation" <> Rec."Main Item/Variation"::Variation then
            exit;
        MainItemVariation.Reset();
        MainItemVariation.SetRange("Main Item No.", Rec."Main Item No.");
        MainItemVariation.SetRange("Item No.", '');
        MainItemVariation.DeleteAll();

        MainItemVariation.SetRange("Item No.");
        if not MainItemVariation.IsEmpty() then
            exit;
        if MainAuxItem.Get(Rec."Main Item No.") then begin
            MainAuxItem."Main Item/Variation" := MainAuxItem."Main Item/Variation"::" ";
            MainAuxItem."Main Item No." := '';
            MainAuxItem.Modify();
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnCheckMainItemVariation(var MainItemVariation: Record "NPR Main Item Variation"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAddNewItemVariation(var MainItemVariation: Record "NPR Main Item Variation"; var VariationAuxItem: Record "NPR Auxiliary Item"; var Handled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRemoveItemVariation(var MainItemVariation: Record "NPR Main Item Variation"; var Handled: Boolean);
    begin
    end;
}