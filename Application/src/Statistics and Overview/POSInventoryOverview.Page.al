﻿page 6060059 "NPR POS Inventory Overview"
{
    Extensible = False;
    Caption = 'POS Inventory Overview';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Inv. Overview Line";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(Control6014413)
            {
                ShowCaption = false;
                field(ItemCode; ItemCode)
                {

                    Caption = 'Item No.';
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(0);
                    end;

                    trigger OnValidate()
                    begin
                        RefreshLines();
                    end;
                }
                field(VariantCode; VariantCode)
                {

                    Caption = 'Variant Code';
                    Visible = VariantVisible;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(1);
                    end;

                    trigger OnValidate()
                    begin
                        RefreshLines();
                    end;
                }
                field(Variety1ValueCode; Variety1ValueCode)
                {

                    Caption = 'Variety 1';
                    Visible = Variety1ValueVisible;
                    ToolTip = 'Specifies the value of the Variety 1 field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(2);
                    end;

                    trigger OnValidate()
                    begin
                        RefreshLines();
                    end;
                }
                field(Variety2ValueCode; Variety2ValueCode)
                {

                    Caption = 'Variety 2';
                    Visible = Variety2ValueVisible;
                    ToolTip = 'Specifies the value of the Variety 2 field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(3);
                    end;

                    trigger OnValidate()
                    begin
                        RefreshLines();
                    end;
                }
                field(Variety3ValueCode; Variety3ValueCode)
                {

                    Caption = 'Variety 3';
                    Visible = Variety3ValueVisible;
                    ToolTip = 'Specifies the value of the Variety 3 field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(4);
                    end;

                    trigger OnValidate()
                    begin
                        RefreshLines();
                    end;
                }
                field(Variety4ValueCode; Variety4ValueCode)
                {

                    Caption = 'Variety 4';
                    Visible = Variety4ValueVisible;
                    ToolTip = 'Specifies the value of the Variety 4 field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupField(5);
                    end;

                    trigger OnValidate()
                    begin
                        RefreshLines();
                    end;
                }
            }
            repeater(Group)
            {
                Editable = false;
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Description"; Rec."Variant Description")
                {

                    Visible = VariantVisible;
                    ToolTip = 'Specifies the value of the Variant Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Name"; Rec."Location Name")
                {

                    ToolTip = 'Specifies the value of the Location Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    DecimalPlaces = 0 : 2;
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Description"; Rec."Item Description")
                {

                    Caption = 'Description 2';
                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Clear(Item);
        RefreshLines();
    end;

    var
        Item: Record Item;
        ItemCode: Code[20];
        VariantCode: Code[10];
        Variety1ValueCode: Code[50];
        Variety2ValueCode: Code[50];
        Variety3ValueCode: Code[50];
        Variety4ValueCode: Code[50];
        VariantVisible: Boolean;
        Variety1ValueVisible: Boolean;
        Variety2ValueVisible: Boolean;
        Variety3ValueVisible: Boolean;
        Variety4ValueVisible: Boolean;
        CurrentLocationCode: Code[10];
        QtyCurrentLocation: Decimal;
        TextSelectItemFirst: Label 'Please select an item.';
        OnlyCurentLoc: Boolean;

    internal procedure SetParameters(ItemCodeIn: Code[20]; VariantCodeIn: Code[10]; CurrentLocationIn: Code[10]; OnlyCurentLocIn: Boolean)
    begin
        ItemCode := ItemCodeIn;
        VariantCode := VariantCodeIn;
        CurrentLocationCode := CurrentLocationIn;
        OnlyCurentLoc := OnlyCurentLocIn;  //NPR5.52 [370333]
    end;

    local procedure RefreshLines()
    var
        Location: Record Location;
        ItemVariant: Record "Item Variant";
        AuxItem: Record "NPR Auxiliary Item";
        HasVariants: Boolean;
        POSInventoryOverview: Page "NPR POS Inventory Overview";
    begin
        if ItemCode = '' then
            exit;
        Rec.DeleteAll();
        QtyCurrentLocation := 0;

        if (Item."No." <> '') and (ItemCode <> Item."No.") then begin
            //Open a new page with new Visible properties
            //POSInventoryOverview.SetParameters(ItemCode,VariantCode,CurrentLocationCode);  //NPR5.52 [370333]-revoked
            POSInventoryOverview.SetParameters(ItemCode, VariantCode, CurrentLocationCode, OnlyCurentLoc);  //NPR5.52 [370333]
            POSInventoryOverview.Run();
            CurrPage.Close();
        end;

        Item.Get(ItemCode);
        Item.NPR_GetAuxItem(AuxItem);
        Variety1ValueVisible := AuxItem."Variety 1" <> '';
        Variety2ValueVisible := AuxItem."Variety 2" <> '';
        Variety3ValueVisible := AuxItem."Variety 3" <> '';
        Variety4ValueVisible := AuxItem."Variety 4" <> '';

        ItemVariant.Reset();
        ItemVariant.SetRange("Item No.", ItemCode);
        HasVariants := not (ItemVariant.IsEmpty());
        VariantVisible := HasVariants;
        if VariantCode <> '' then
            ItemVariant.SetFilter(Code, VariantCode);
        if Variety1ValueCode <> '' then
            ItemVariant.SetFilter("NPR Variety 1 Value", Variety1ValueCode);
        if Variety2ValueCode <> '' then
            ItemVariant.SetFilter("NPR Variety 2 Value", Variety2ValueCode);
        if Variety3ValueCode <> '' then
            ItemVariant.SetFilter("NPR Variety 3 Value", Variety3ValueCode);
        if Variety4ValueCode <> '' then
            ItemVariant.SetFilter("NPR Variety 4 Value", Variety4ValueCode);

        //-NPR5.52 [370333]
        if OnlyCurentLoc then
            Location.SetRange(Code, CurrentLocationCode);
        //+NPR5.52 [370333]
        if Location.FindSet() then
            repeat
                Item.SetFilter("Location Filter", Location.Code);
                if HasVariants then begin
                    if ItemVariant.FindSet() then
                        repeat
                            Item.SetFilter("Variant Filter", ItemVariant.Code);
                            Item.CalcFields(Inventory);
                            //-NPR5.55 [404868]
                            //IF Item.Inventory > 0 THEN BEGIN
                            if Item.Inventory <> 0 then begin
                                //+NPR5.55 [404868]
                                Rec."Item No." := Item."No.";
                                Rec."Item Description" := Item.Description;
                                Rec."Variant Code" := ItemVariant.Code;
                                Rec."Variant Description" := ItemVariant.Description;
                                Rec."Location Code" := Location.Code;
                                Rec."Location Name" := Location.Name;
                                Rec.Quantity := Item.Inventory;
                                Rec.Insert();
                                if CurrentLocationCode = Location.Code then
                                    QtyCurrentLocation := QtyCurrentLocation + Item.Inventory;
                            end;
                        until ItemVariant.Next() = 0;
                end else begin
                    Item.SetFilter("Variant Filter", '');
                    Item.CalcFields(Inventory);
                    //-NPR5.55 [404868]
                    //IF Item.Inventory > 0 THEN BEGIN
                    if Item.Inventory <> 0 then begin
                        //+NPR5.55 [404868]
                        Rec."Item No." := Item."No.";
                        Rec."Item Description" := Item.Description;
                        Rec."Location Code" := Location.Code;
                        Rec."Location Name" := Location.Name;
                        Rec.Quantity := Item.Inventory;
                        Rec.Insert();
                        if CurrentLocationCode = Location.Code then
                            QtyCurrentLocation := QtyCurrentLocation + Item.Inventory;
                    end;
                end;
            until Location.Next() = 0;
        CurrPage.Update(false);
    end;

    local procedure LookupField(FieldType: Option ItemNo,VariantCode,Variety1,Variety2,Variety3,Variety4): Code[20]
    var
        LookupItem: Record Item;
        AuxItem: Record "NPR Auxiliary Item";
        ItemVariant: Record "Item Variant";
        VarietyValue: Record "NPR Variety Value";
        VarietyValuePage: Page "NPR Variety Value";
        RetailItemList: Page "Item List";
        ItemVariants: Page "Item Variants";
    begin
        case FieldType of
            FieldType::ItemNo:
                begin
                    if LookupItem.Get(ItemCode) then;
                    LookupItem.SetRange(Blocked, false);
                    RetailItemList.LookupMode := true;
                    RetailItemList.SetRecord(LookupItem);
                    RetailItemList.SetTableView(LookupItem);
                    if RetailItemList.RunModal() = ACTION::LookupOK then begin
                        RetailItemList.GetRecord(LookupItem);
                        ItemCode := LookupItem."No.";
                        RefreshLines();
                    end;
                end;
            FieldType::VariantCode:
                begin
                    if not Item.Get(ItemCode) then
                        Error(TextSelectItemFirst);
                    ItemVariant.SetRange("Item No.", Item."No.");
                    ItemVariant.SetRange("NPR Blocked", false);
                    ItemVariants.LookupMode := true;
                    ItemVariants.SetRecord(ItemVariant);
                    ItemVariants.SetTableView(ItemVariant);
                    if ItemVariants.RunModal() = ACTION::LookupOK then begin
                        ItemVariants.GetRecord(ItemVariant);
                        VariantCode := ItemVariant.Code;
                        RefreshLines();
                    end;
                end;
            FieldType::Variety1:
                begin
                    if not Item.Get(ItemCode) then
                        Error(TextSelectItemFirst);
                    Item.NPR_GetAuxItem(AuxItem);
                    VarietyValue.SetRange(Type, AuxItem."Variety 1");
                    VarietyValue.SetRange(Table, AuxItem."Variety 1 Table");
                    VarietyValue.SetCurrentKey(Type, Table, "Sort Order");
                    VarietyValuePage.LookupMode := true;
                    VarietyValuePage.SetRecord(VarietyValue);
                    VarietyValuePage.SetTableView(VarietyValue);
                    if VarietyValuePage.RunModal() = ACTION::LookupOK then begin
                        VarietyValuePage.GetRecord(VarietyValue);
                        Variety1ValueCode := VarietyValue.Value;
                        RefreshLines();
                    end;
                end;
            FieldType::Variety2:
                begin
                    if not Item.Get(ItemCode) then
                        Error(TextSelectItemFirst);
                    Item.NPR_GetAuxItem(AuxItem);
                    VarietyValue.SetRange(Type, AuxItem."Variety 2");
                    VarietyValue.SetRange(Table, AuxItem."Variety 2 Table");
                    VarietyValue.SetCurrentKey(Type, Table, "Sort Order");
                    VarietyValuePage.LookupMode := true;
                    VarietyValuePage.SetRecord(VarietyValue);
                    VarietyValuePage.SetTableView(VarietyValue);
                    if VarietyValuePage.RunModal() = ACTION::LookupOK then begin
                        VarietyValuePage.GetRecord(VarietyValue);
                        Variety2ValueCode := VarietyValue.Value;
                        RefreshLines();
                    end;
                end;
            FieldType::Variety3:
                begin
                    if not Item.Get(ItemCode) then
                        Error(TextSelectItemFirst);
                    Item.NPR_GetAuxItem(AuxItem);
                    VarietyValue.SetRange(Type, AuxItem."Variety 3");
                    VarietyValue.SetRange(Table, AuxItem."Variety 3 Table");
                    VarietyValue.SetCurrentKey(Type, Table, "Sort Order");
                    VarietyValuePage.LookupMode := true;
                    VarietyValuePage.SetRecord(VarietyValue);
                    VarietyValuePage.SetTableView(VarietyValue);
                    if VarietyValuePage.RunModal() = ACTION::LookupOK then begin
                        VarietyValuePage.GetRecord(VarietyValue);
                        Variety3ValueCode := VarietyValue.Value;
                        RefreshLines();
                    end;
                end;
            FieldType::Variety4:
                begin
                    if not Item.Get(ItemCode) then
                        Error(TextSelectItemFirst);
                    Item.NPR_GetAuxItem(AuxItem);
                    VarietyValue.SetRange(Type, AuxItem."Variety 4");
                    VarietyValue.SetRange(Table, AuxItem."Variety 4 Table");
                    VarietyValue.SetCurrentKey(Type, Table, "Sort Order");
                    VarietyValuePage.LookupMode := true;
                    VarietyValuePage.SetRecord(VarietyValue);
                    VarietyValuePage.SetTableView(VarietyValue);
                    if VarietyValuePage.RunModal() = ACTION::LookupOK then begin
                        VarietyValuePage.GetRecord(VarietyValue);
                        Variety4ValueCode := VarietyValue.Value;
                        RefreshLines();
                    end;
                end;
        end;
    end;
}

