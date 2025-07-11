﻿page 6014617 "NPR Display Config WP"
{
    Extensible = False;
    Caption = 'Display Config';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Display Config";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6150617)
            {
                ShowCaption = false;
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRMagento;
                    trigger OnValidate()
                    begin
                        Rec."No." := '';
                    end;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRMagento;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                        Items: Page "Item List";
                    /* ItemGroup: Record "Magento Item Group";
                    ItemGroups: Page "Magento Item Groups"; */
                    begin
                        if Rec.Type = Rec.Type::Item then begin
                            Items.LookupMode := true;
                            Items.Editable := false;

                            if Rec."No." <> '' then
                                if Item.Get(Rec."No.") then
                                    Items.SetRecord(Item);

                            if Items.RunModal() = Action::LookupOK then begin
                                Items.GetRecord(Item);
                                Rec."No." := Item."No.";
                            end;
                        end;

                        /* if Type = Type::"Item Group" then begin
                            ItemGroups.LookupMode := true;
                            ItemGroups.Editable := false;

                            if "No." <> '' then
                                if ItemGroup.Get("No.") then
                                    ItemGroups.SetRecord(ItemGroup);

                            if ItemGroups.RunModal() = Action::LookupOK then begin
                                ItemGroups.GetRecord(ItemGroup);
                                "No." := ItemGroup."No.";
                            end;
                        end; */

                        if Rec.Type = Rec.Type::Brand then begin
                            Brands.LookupMode := true;
                            Brands.Editable := false;

                            Brands.SetRec(TempAllBrand);

                            if Rec."No." <> '' then
                                if TempAllBrand.Get(Rec."No.") then
                                    Brands.SetRecord(TempAllBrand);

                            if Brands.RunModal() = Action::LookupOK then begin
                                Brands.GetRecord(TempAllBrand);
                                Rec."No." := TempAllBrand.Id;
                            end;
                        end;
                    end;
                }
                field("Sales Type"; Rec."Sales Type")
                {

                    ToolTip = 'Specifies the value of the Sales Type field';
                    ApplicationArea = NPRMagento;
                    trigger OnValidate()
                    begin
                        Rec."Sales Code" := '';
                    end;
                }
                field("Sales Code"; Rec."Sales Code")
                {

                    ToolTip = 'Specifies the value of the Sales Code field';
                    ApplicationArea = NPRMagento;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Customer: Record Customer;
                        Customers: Page "Customer List";
                        MagDisplayGroups: Page "NPR Displ Groups Select";
                    begin
                        if Rec."Sales Type" = Rec."Sales Type"::Customer then begin
                            Customers.LookupMode := true;
                            Customers.Editable := false;

                            if Rec."Sales Code" <> '' then
                                if Customer.Get(Rec."Sales Code") then
                                    Customers.SetRecord(Customer);

                            if Customers.RunModal() = Action::LookupOK then begin
                                Customers.GetRecord(Customer);
                                Rec."Sales Code" := Customer."No.";
                            end;
                        end;

                        if Rec."Sales Type" = Rec."Sales Type"::"Display Group" then begin
                            MagDisplayGroups.LookupMode := true;
                            MagDisplayGroups.Editable := false;

                            MagDisplayGroups.SetRec(TempAllMagDispGroup);

                            if Rec."Sales Code" <> '' then
                                if TempAllMagDispGroup.Get(Rec."Sales Code") then
                                    MagDisplayGroups.SetRecord(TempAllMagDispGroup);

                            if MagDisplayGroups.RunModal() = Action::LookupOK then begin
                                MagDisplayGroups.GetRecord(TempAllMagDispGroup);
                                Rec."Sales Code" := TempAllMagDispGroup.Code;
                            end;
                        end;
                    end;
                }
                field("Is Visible"; Rec."Is Visible")
                {

                    ToolTip = 'Specifies the value of the Is Visible field';
                    ApplicationArea = NPRMagento;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRMagento;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRMagento;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    ToolTip = 'Specifies the value of the Ending Date field';
                    ApplicationArea = NPRMagento;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    var
        TempAllBrand: Record "NPR Magento Brand" temporary;
        TempAllMagDispGroup: Record "NPR Magento Display Group" temporary;
        Brands: Page "NPR Brands Select";

    internal procedure SetGlobals(var TempBrand: Record "NPR Magento Brand" temporary; var TempMagDisplayGroup: Record "NPR Magento Display Group" temporary; Global: Option Brand,"Mag. Display Group")
    begin
        case Global of
            Global::Brand:
                begin
                    TempAllBrand.DeleteAll();

                    if TempBrand.FindSet() then
                        repeat
                            TempAllBrand := TempBrand;
                            TempAllBrand.Insert();
                        until TempBrand.Next() = 0;
                end;
            Global::"Mag. Display Group":
                begin
                    TempAllMagDispGroup.DeleteAll();

                    if TempMagDisplayGroup.FindSet() then
                        repeat
                            TempAllMagDispGroup := TempMagDisplayGroup;
                            TempAllMagDispGroup.Insert();
                        until TempMagDisplayGroup.Next() = 0;
                end;
        end;
    end;

    internal procedure CreateMagentoDisplayConfig()
    var
        MagentoDisplayConfig: Record "NPR Magento Display Config";
    begin
        if Rec.FindSet() then
            repeat
                MagentoDisplayConfig := Rec;
                if not MagentoDisplayConfig.Insert() then
                    MagentoDisplayConfig.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure MagentoDisplayConfigToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;
}
