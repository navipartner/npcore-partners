﻿codeunit 6060055 "NPR Item Status Mgt."
{
    Access = Internal;
    // NPR5.25\BR  \20160720  CASE 246088 Object Created


    trigger OnRun()
    begin
    end;

    var
        TextErrorStatusNotActive: Label 'Item %1 has status %2. This status does not have %3 activated.';

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnInsertItemSetInitalStatus(var Rec: Record Item; RunTrigger: Boolean)
    var
        ItemStatus: Record "NPR Item Status";
        AuxItem: Record "NPR Aux Item";
    begin
        Rec.NPR_GetAuxItem(AuxItem);
        if AuxItem."Item Status" <> '' then
            exit;
        ItemStatus.Reset();
        ItemStatus.SetRange(Initial, true);
        if ItemStatus.FindFirst() then
            AuxItem.Validate("Item Status", ItemStatus.Code)
        else
            AuxItem.Validate("Item Status", CreateInitialStatus());
        Rec.NPR_SetAuxItem(AuxItem);
        Rec.NPR_SaveAuxItem();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnAfterCheckItemJnlLine', '', true, true)]
    local procedure OnAfterCheckItemJnlLineCheckIfAllowed(var ItemJnlLine: Record "Item Journal Line")
    var
        Item: Record Item;
        AuxItem: Record "NPR Aux Item";
        ItemStatus: Record "NPR Item Status";
    begin
        if not Item.Get(ItemJnlLine."Item No.") then
            exit;
        Item.NPR_GetAuxItem(AuxItem);
        if AuxItem."Item Status" = '' then
            exit;
        if not ItemStatus.Get(AuxItem."Item Status") then
            exit;
        if ItemStatus.Description = '' then
            ItemStatus.Description := ItemStatus.Code;
        case ItemJnlLine."Entry Type" of
            ItemJnlLine."Entry Type"::Purchase:
                if not ItemStatus."Purchase Post" then
                    Error(TextErrorStatusNotActive, Item."No.", ItemStatus.Description, ItemStatus.FieldCaption("Purchase Post"));
            ItemJnlLine."Entry Type"::Sale:
                if not ItemStatus."Sales Post" then
                    Error(TextErrorStatusNotActive, Item."No.", ItemStatus.Description, ItemStatus.FieldCaption("Sales Post"));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteItemCheckIfAllowed(var Rec: Record Item; RunTrigger: Boolean)
    var
        AuxItem: Record "NPR Aux Item";
        ItemStatus: Record "NPR Item Status";
    begin
        Rec.NPR_GetAuxItem(AuxItem);
        if AuxItem."Item Status" = '' then
            exit;
        if not ItemStatus.Get(AuxItem."Item Status") then
            exit;
        if ItemStatus.Description = '' then
            ItemStatus.Description := ItemStatus.Code;
        if not ItemStatus."Delete Allowed" then
            Error(TextErrorStatusNotActive, Rec."No.", ItemStatus.Description, ItemStatus.FieldCaption("Delete Allowed"));
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeRenameEvent', '', true, true)]
    local procedure OnBeforeRenameItemCheckIfAllowed(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        AuxItem: Record "NPR Aux Item";
        ItemStatus: Record "NPR Item Status";
    begin
        Rec.NPR_GetAuxItem(AuxItem);
        if AuxItem."Item Status" = '' then
            exit;
        if not ItemStatus.Get(AuxItem."Item Status") then
            exit;
        if ItemStatus.Description = '' then
            ItemStatus.Description := ItemStatus.Code;
        if not ItemStatus."Rename Allowed" then
            Error(TextErrorStatusNotActive, xRec."No.", ItemStatus.Description, ItemStatus.FieldCaption("Rename Allowed"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnBeforeValidateNoSalesLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        AuxItem: Record "NPR Aux Item";
        ItemStatus: Record "NPR Item Status";
    begin
        if Rec.Type <> Rec.Type::Item then
            exit;
        if not Item.Get(Rec."No.") then
            exit;
        Item.NPR_GetAuxItem(AuxItem);
        if AuxItem."Item Status" = '' then
            exit;
        if not ItemStatus.Get(AuxItem."Item Status") then
            exit;
        if ItemStatus.Description = '' then
            ItemStatus.Description := ItemStatus.Code;
        if not ItemStatus."Sales Insert" then
            Error(TextErrorStatusNotActive, Item."No.", ItemStatus.Description, ItemStatus.FieldCaption("Sales Insert"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeValidateEvent', 'No.', true, true)]
    local procedure OnBeforeValidateNoPurchaseLine(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        AuxItem: Record "NPR Aux Item";
        ItemStatus: Record "NPR Item Status";
    begin
        if Rec.Type <> Rec.Type::Item then
            exit;
        if not Item.Get(Rec."No.") then
            exit;
        Item.NPR_GetAuxItem(AuxItem);
        if AuxItem."Item Status" = '' then
            exit;
        if not ItemStatus.Get(AuxItem."Item Status") then
            exit;
        if ItemStatus.Description = '' then
            ItemStatus.Description := ItemStatus.Code;
        if not ItemStatus."Purchase Insert" then
            Error(TextErrorStatusNotActive, Item."No.", ItemStatus.Description, ItemStatus.FieldCaption("Purchase Insert"));
    end;

    local procedure CreateInitialStatus(): Code[10]
    var
        InitialStatusCode: Code[10];
        ItemStatus: Record "NPR Item Status";
        TxtInitialStatusDescription: Label 'New';
    begin
        InitialStatusCode := '01NEW';
        if ItemStatus.Get(InitialStatusCode) then begin
            ItemStatus.Validate(Initial, true);
            ItemStatus.Modify(true);
        end else begin
            ItemStatus.Init();
            ItemStatus.Validate(Code, InitialStatusCode);
            ItemStatus.Validate(Description, TxtInitialStatusDescription);
            ItemStatus.Validate(Initial, true);
            ItemStatus.Insert(true);
        end;
        exit(InitialStatusCode);
    end;
}

