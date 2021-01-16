page 6014617 "NPR Display Config WP"
{
    Caption = 'Display Config';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Display Config";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control6150617)
            {
                ShowCaption = false;
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                    trigger OnValidate()
                    begin
                        "No." := '';
                    end;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                        Items: Page "Item List";
                    /* ItemGroup: Record "Magento Item Group";
                    ItemGroups: Page "Magento Item Groups"; */
                    begin
                        if Type = Type::Item then begin
                            Items.LookupMode := true;
                            Items.Editable := false;

                            if "No." <> '' then
                                if Item.Get("No.") then
                                    Items.SetRecord(Item);

                            if Items.RunModal() = Action::LookupOK then begin
                                Items.GetRecord(Item);
                                "No." := Item."No.";
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

                        if Type = Type::Brand then begin
                            Brands.LookupMode := true;
                            Brands.Editable := false;

                            Brands.SetRec(TempAllBrand);

                            if "No." <> '' then
                                if TempAllBrand.Get("No.") then
                                    Brands.SetRecord(TempAllBrand);

                            if Brands.RunModal() = Action::LookupOK then begin
                                Brands.GetRecord(TempAllBrand);
                                "No." := TempAllBrand.Id;
                            end;
                        end;
                    end;
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Type field';
                    trigger OnValidate()
                    begin
                        "Sales Code" := '';
                    end;
                }
                field("Sales Code"; "Sales Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Code field';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Customer: Record Customer;
                        Customers: Page "Customer List";
                        MagDisplayGroups: Page "NPR Displ Groups Select";
                    begin
                        if "Sales Type" = "Sales Type"::Customer then begin
                            Customers.LookupMode := true;
                            Customers.Editable := false;

                            if "Sales Code" <> '' then
                                if Customer.Get("Sales Code") then
                                    Customers.SetRecord(Customer);

                            if Customers.RunModal() = Action::LookupOK then begin
                                Customers.GetRecord(Customer);
                                "Sales Code" := Customer."No.";
                            end;
                        end;

                        if "Sales Type" = "Sales Type"::"Display Group" then begin
                            MagDisplayGroups.LookupMode := true;
                            MagDisplayGroups.Editable := false;

                            MagDisplayGroups.SetRec(TempAllMagDispGroup);

                            if "Sales Code" <> '' then
                                if TempAllMagDispGroup.Get("Sales Code") then
                                    MagDisplayGroups.SetRecord(TempAllMagDispGroup);

                            if MagDisplayGroups.RunModal() = Action::LookupOK then begin
                                MagDisplayGroups.GetRecord(TempAllMagDispGroup);
                                "Sales Code" := TempAllMagDispGroup.Code;
                            end;
                        end;
                    end;
                }
                field("Is Visible"; "Is Visible")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Visible field';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Time field';
                }
            }
        }
    }

    var
        TempAllBrand: Record "NPR Magento Brand" temporary;
        TempAllMagDispGroup: Record "NPR Magento Display Group" temporary;
        Brands: Page "NPR Brands Select";

    procedure SetGlobals(var TempBrand: Record "NPR Magento Brand" temporary; var TempMagDisplayGroup: Record "NPR Magento Display Group" temporary; Global: Option Brand,"Mag. Display Group")
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

    procedure CreateMagentoDisplayConfig()
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

    procedure MagentoDisplayConfigToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;
}
