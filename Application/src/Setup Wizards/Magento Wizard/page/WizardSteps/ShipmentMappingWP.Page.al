page 6014551 "NPR Shipment Mapping WP"
{
    Caption = 'Shipment Method Mapping';
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Shipment Mapping";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Shipment Method Code"; "External Shipment Method Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the External Shipment Method Code field';
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ShipmentMethod: Record "Shipment Method";
                        ShipmentMethods: Page "Shipment Methods";
                    begin
                        ShipmentMethods.LookupMode := true;

                        if "Shipment Method Code" <> '' then
                            if ShipmentMethod.Get("Shipment Method Code") then
                                ShipmentMethods.SetRecord(ShipmentMethod);

                        if ShipmentMethods.RunModal() = Action::LookupOK then begin
                            ShipmentMethods.GetRecord(ShipmentMethod);
                            "Shipment Method Code" := ShipmentMethod.Code;
                        end;
                    end;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ShippingAgent: Record "Shipping Agent";
                        ShippingAgents: Page "Shipping Agents";
                    begin
                        ShippingAgents.LookupMode := true;

                        if "Shipping Agent Code" <> '' then
                            if ShippingAgent.Get("Shipping Agent Code") then
                                ShippingAgents.SetRecord(ShippingAgent);

                        if ShippingAgents.RunModal() = Action::LookupOK then begin
                            ShippingAgents.GetRecord(ShippingAgent);
                            "Shipping Agent Code" := ShippingAgent.Code;
                        end;
                    end;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ShippingAgentServices: Record "Shipping Agent Services";
                    begin
                        if "Shipping Agent Service Code" = '' then
                            ShippingAgentServices.SetRange("Shipping Agent Code", "Shipping Agent Code");
                        if ShippingAgentServices.FindSet() then;

                        if "Shipping Agent Service Code" <> '' then begin
                            ShippingAgentServices.SetRange(Code, "Shipping Agent Service Code");
                            ShippingAgentServices.FindFirst();
                            ShippingAgentServices.SetRange(Code);
                        end;

                        if Page.RunModal(0, ShippingAgentServices) = Action::LookupOK then begin
                            "Shipping Agent Service Code" := ShippingAgentServices.Code;
                        end;
                    end;
                }
                field("Shipment Fee Type"; "Shipment Fee Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Fee Type field';
                    trigger OnValidate()
                    begin
                        "Shipment Fee No." := '';
                    end;
                }
                field("Shipment Fee No."; "Shipment Fee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Fee No. field';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        GLAccount: Record "G/L Account";
                        Item: Record Item;
                        ItemList: Page "Item List";
                        Resource: Record Resource;
                        ResourceList: Page "Resource List";
                        FixedAsset: Record "Fixed Asset";
                        FixedAssets: Page "Fixed Asset List";
                        ItemCharge: Record "Item Charge";
                        ItemCharges: Page "Item Charges";
                    begin
                        if "Shipment Fee Type" = "Shipment Fee Type"::"G/L Account" then begin

                            if "Shipment Fee No." = '' then begin
                                GLAccount.SetRange("Direct Posting", true);
                                GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
                                GLAccount.SetRange(Blocked, false);
                            end;
                            if GLAccount.FindSet() then;

                            if "Shipment Fee No." <> '' then begin
                                GLAccount.SetRange("No.", "Shipment Fee No.");
                                GLAccount.FindFirst();
                                GLAccount.SetRange("No.");
                            end;

                            if Page.RunModal(0, GLAccount) = Action::LookupOK then begin
                                "Shipment Fee No." := GLAccount."No.";
                            end;
                        end;

                        if "Shipment Fee Type" = "Shipment Fee Type"::Item then begin
                            ItemList.LookupMode := true;

                            if "Shipment Fee No." <> '' then
                                if Item.Get("Shipment Fee No.") then
                                    ItemList.SetRecord(Item);

                            if ItemList.RunModal() = Action::LookupOK then begin
                                ItemList.GetRecord(Item);
                                "Shipment Fee No." := Item."No.";
                            end;
                        end;

                        if "Shipment Fee Type" = "Shipment Fee Type"::Resource then begin
                            ResourceList.LookupMode := true;

                            if "Shipment Fee No." <> '' then
                                if Resource.Get("Shipment Fee No.") then
                                    ResourceList.SetRecord(Resource);

                            if ResourceList.RunModal() = Action::LookupOK then begin
                                ResourceList.GetRecord(Resource);
                                "Shipment Fee No." := Resource."No.";
                            end;
                        end;

                        if "Shipment Fee Type" = "Shipment Fee Type"::"Fixed Asset" then begin
                            FixedAssets.LookupMode := true;

                            if "Shipment Fee No." <> '' then
                                if FixedAsset.Get("Shipment Fee No.") then
                                    FixedAssets.SetRecord(FixedAsset);

                            if FixedAssets.RunModal() = Action::LookupOK then begin
                                FixedAssets.GetRecord(FixedAsset);
                                "Shipment Fee No." := FixedAsset."No.";
                            end;
                        end;

                        if "Shipment Fee Type" = "Shipment Fee Type"::"Charge (Item)" then begin
                            ItemCharges.LookupMode := true;

                            if "Shipment Fee No." <> '' then
                                if ItemCharge.Get("Shipment Fee No.") then
                                    ItemCharges.SetRecord(ItemCharge);

                            if ItemCharges.RunModal() = Action::LookupOK then begin
                                ItemCharges.GetRecord(ItemCharge);
                                "Shipment Fee No." := ItemCharge."No.";
                            end;
                        end;
                    end;
                }
            }
        }
    }

    procedure CreateMagentoShipmentMapping()
    var
        MagentoShipmentMapping: Record "NPR Magento Shipment Mapping";
    begin
        if Rec.FindSet() then
            repeat
                MagentoShipmentMapping := Rec;
                if not MagentoShipmentMapping.Insert() then
                    MagentoShipmentMapping.Modify();
            until Rec.Next() = 0;
    end;

    procedure MagentoShipmentMappingToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;
}