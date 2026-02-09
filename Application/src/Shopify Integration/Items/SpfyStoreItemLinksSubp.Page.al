#if not BC17
page 6184557 "NPR Spfy Store-Item Links Subp"
{
    Extensible = false;
    Caption = 'Shopify Store-Item Links';
    PageType = ListPart;
    SourceTable = "NPR Spfy Store-Item Link";
    UsageCategory = None;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies whether the entry is related to an item or item variant.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies a BC item the link to be created for.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies a BC item variant the link to be created for.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies a Shopify store the linked item is integrated to.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Store Integration Is Enabled"; Rec."Store Integration Is Enabled")
                {
                    ToolTip = 'Specifies whether integration with the Shopify store is generally enabled.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    DrillDown = false;
                }
                field("Sync. to this Store"; Rec."Sync. to this Store")
                {
                    ToolTip = 'Specifies whether the item has been requested to be integrated with the Shopify store.';
                    ApplicationArea = NPRShopify;
                    Editable = ItemListIntegrationIsEnabled;

                    trigger OnValidate()
                    begin
                        CheckIntegrationIsEnabled();
                    end;
                }
                field("Synchronization Is Enabled"; Rec."Synchronization Is Enabled")
                {
                    ToolTip = 'Specifies whether confirmation has been received from the Shopify store that the associated product has been successfully created in the store.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    DrillDown = false;
                }
                field("Shopify Status"; Rec."Shopify Status")
                {
                    ToolTip = 'Specifies the Shopify status of the item.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Shopify Name"; Rec."Shopify Name")
                {
                    ToolTip = 'Specifies the Shopify Name of the item.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Description"; Format(Rec."Shopify Description".HasValue()))
                {
                    Caption = 'Shopify Description';
                    ToolTip = 'Specifies the Shopify Description of the item.';
                    ApplicationArea = NPRShopify;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        MagentoFunctions: Codeunit "NPR Magento Functions";
                        TempBlob: Codeunit "Temp Blob";
                        OutStr: OutStream;
                        InStr: InStream;
                    begin
                        TempBlob.CreateOutStream(OutStr);
                        Rec.CalcFields("Shopify Description");
                        Rec."Shopify Description".CreateInStream(InStr);
                        CopyStream(OutStr, InStr);
                        if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                            if TempBlob.HasValue() then begin
                                TempBlob.CreateInStream(InStr);
                                Rec."Shopify Description".CreateOutStream(OutStr);
                                CopyStream(OutStr, InStr);
                            end else
                                Clear(Rec."Shopify Description");
                            Rec.Modify(true);
                        end;
                    end;
                }
                field(Vendor; Rec.Vendor)
                {
                    ToolTip = 'Specifies the vendor name of the item.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Product ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Product ID';
                    ToolTip = 'Specifies a Shopify Product ID assigned to the item.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        Rec.TestField(Type, Rec.Type::Item);
                        Rec.TestField("Item No.");
                        Rec.TestField("Shopify Store Code");
                        CurrPage.SaveRecord();
                        Commit();

                        SpfyStoreItemLink := Rec;
                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        ChangeShopifyID.RunModal();

                        CurrPage.Update(false);
                    end;
                }
                field("Product Metafields"; SpfyMetafieldMgt.SyncedEntityMetafieldCount(SpfyStoreItemLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCT))
                {
                    Caption = 'Product Metafields';
                    ToolTip = 'Specifies the number of product metafields synced with Shopify.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        SpfyMetafieldMgt.ShowEntitySyncedMetafields(SpfyStoreItemLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCT);
                    end;
                }
                field("Shopify Variant ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Variant ID';
                    ToolTip = 'Specifies a Shopify Variant ID assigned to the item. Only applies to items that have no variants.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        Rec.TestField("Item No.");
                        if Rec.Type = Rec.Type::"Variant" then
                            Rec.TestField("Variant Code");
                        Rec.TestField("Shopify Store Code");
                        CurrPage.SaveRecord();
                        Commit();

                        SpfyStoreItemVariantLink := Rec;
                        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        ChangeShopifyID.RunModal();

                        CurrPage.Update(false);
                    end;
                }
                field("Variant Metafields"; SpfyMetafieldMgt.SyncedEntityMetafieldCount(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCTVARIANT))
                {
                    Caption = 'Variant Metafields';
                    ToolTip = 'Specifies the number of product variant metafields that are synced with Shopify. Only applies to items that have no variants.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        SpfyMetafieldMgt.ShowEntitySyncedMetafields(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCTVARIANT);
                    end;
                }
                field("Allow Backorder"; AllowBackorder)
                {
                    Caption = 'Allow Backorder';
                    ToolTip = 'Specifies whether the item can still be sold on Shopify when it is out of stock. If the item has variants, this field must be set separately for each variant.';
                    ApplicationArea = NPRShopify;
                    Editable = ItemListIntegrationIsEnabled;

                    trigger OnValidate()
                    begin
                        CheckIntegrationIsEnabled();
                        SpfyItemVariantModifMgt.SetAllowBackorder(SpfyStoreItemVariantLink, AllowBackorder, false);
                    end;
                }
                field("Do Not Track Inventory"; DoNotTrackInventory)
                {
                    Caption = 'Do Not Track Inventory';
                    ToolTip = 'Specifies whether the item inventory is tracked in Shopify. If the item has variants, this field must be set separately for each variant.';
                    ApplicationArea = NPRShopify;
                    Editable = ItemListIntegrationIsEnabled;

                    trigger OnValidate()
                    begin
                        CheckIntegrationIsEnabled();
                        SpfyItemVariantModifMgt.SetDoNotTrackInventory(SpfyStoreItemVariantLink, DoNotTrackInventory, false);
                    end;
                }
                field(Weight; WeightValue)
                {
                    Caption = 'Weight';
                    ToolTip = 'Specifies the weight of the item used for shipping calculations in Shopify. If the item has variants, this field must be set separately for each variant.';
                    ApplicationArea = NPRShopify;
                    Editable = ItemListIntegrationIsEnabled;
                    DecimalPlaces = 0 : 5;
                    MinValue = 0;

                    trigger OnValidate()
                    begin
                        CheckWeightIntegrationIsEnabled();
                        if (WeightValue > 0) and (WeightUnit = Enum::"NPR Spfy Weight Unit"::" ") then
                            WeightUnit := DefaultWeightUnit;
                        SpfyItemVariantModifMgt.SetVariantWeight(SpfyStoreItemVariantLink, WeightValue, WeightUnit, false);
                    end;
                }
                field("Weight Unit"; WeightUnit)
                {
                    Caption = 'Weight Unit';
                    ToolTip = 'Specifies the weight unit of the item used for shipping calculations in Shopify. If the item has variants, this field must be set separately for each variant.';
                    ApplicationArea = NPRShopify;
                    Editable = ItemListIntegrationIsEnabled;

                    trigger OnValidate()
                    begin
                        CheckWeightIntegrationIsEnabled();
                        SpfyItemVariantModifMgt.SetVariantWeight(SpfyStoreItemVariantLink, WeightValue, WeightUnit, false);
                    end;
                }
                field("Shopify Inventory Item ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID"))
                {
                    Caption = 'Shopify Inventory Item ID';
                    ToolTip = 'Specifies a Shopify Inventory Item ID assigned to the item. Is applicable only for items not having any variants.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        Rec.TestField("Item No.");
                        if Rec.Type = Rec.Type::"Variant" then
                            Rec.TestField("Variant Code");
                        Rec.TestField("Shopify Store Code");
                        CurrPage.SaveRecord();
                        Commit();

                        SpfyStoreItemVariantLink := Rec;
                        SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(SpfyStoreItemVariantLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
                        ChangeShopifyID.RunModal();

                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateStoreList)
            {
                Caption = 'Update Store List';
                ToolTip = 'Updates the list of available Shopify stores for the item.';
                ApplicationArea = NPRShopify;
                Image = GetLines;

                trigger OnAction()
                var
                    Item: Record Item;
                    SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
                begin
                    CurrPage.SaveRecord();
                    if Rec."Item No." = '' then
                        Rec."Item No." := Rec.GetRangeMin("Item No.");
                    Rec.TestField("Item No.");
                    Item.Get(Rec."Item No.");
                    SpfyStoreLinkMgt.UpdateStoreItemLinks(Item);
                    CurrPage.Update(false);
                end;
            }
            action(SyncItems)
            {
                Caption = 'Update Sync. Status';
                ToolTip = 'Updates item synchronization status between BC and Shopify. The system will go through Shopify stores and mark the item as synchronized if it has already been created on the store. The system will also update the item status, name, description and metafields from Shopify, and create a request to assign product tags in Shopify based on the item category.';
                ApplicationArea = NPRShopify;
                Image = CheckList;

                trigger OnAction()
                var
                    Item: Record Item;
                    ShopifyStore: Record "NPR Spfy Store";
                    SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
                    SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
                    Window: Dialog;
                    SyncInProgressLbl: Label 'Updating items sync. status...';
                    DisabledStoresExist: Label 'There are Shopify stores for which integration is not enabled. The system will not update the item sync status for these stores. Are you sure you want to proceed?';
                begin
                    ShopifyStore.SetRange(Enabled, true);
                    ShopifyStore.FindFirst();
                    ShopifyStore.SetRange(Enabled, false);
                    if not ShopifyStore.IsEmpty() then
                        if not Confirm(DisabledStoresExist, true) then
                            exit;

                    CurrPage.SaveRecord();
                    Rec.TestField("Item No.");
                    Item.Get(Rec."Item No.");
                    SpfyStoreLinkMgt.UpdateStoreItemLinks(Item);
                    Commit();
                    Window.Open(SyncInProgressLbl);
                    ShopifyStore.SetRange(Enabled, true);
                    SendItemAndInventory.MarkItemAlreadyOnShopify(Item, ShopifyStore, false, false, true);
                    Window.Close();
                    CurrPage.Update(false);
                end;
            }
            action(InventoryLocations)
            {
                Caption = 'Inventory Locations';
                ApplicationArea = NPRShopify;
                Image = List;
                ToolTip = 'Shows a list of Shopify store locations where the listed inventory items are activated.';
                RunObject = page "NPR Spfy Inv. Item Locations";
                RunPageLink = "Shopify Store Code" = field("Shopify Store Code"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code");
            }
        }
    }

    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemVariantLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyItemVariantModifMgt: Codeunit "NPR Spfy ItemVariantModif Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        DefaultWeightUnit: Enum "NPR Spfy Weight Unit";
        WeightUnit: Enum "NPR Spfy Weight Unit";
        WeightValue: Decimal;
        AllowBackorder: Boolean;
        DoNotTrackInventory: Boolean;
        ItemListIntegrationIsEnabled: Boolean;
        ItemIntegrIsNotEnabledErr: Label 'Item integration is not enabled for the store. You cannot adjust this parameter.';

    trigger OnOpenPage()
    begin
        ItemListIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);
    end;

    trigger OnAfterGetRecord()
    begin
        SpfyStoreItemLink := Rec;
        SpfyStoreItemVariantLink := Rec;
        if Rec.Type = Rec.Type::Item then begin
            SpfyStoreItemVariantLink.Type := SpfyStoreItemVariantLink.Type::"Variant";
        end else begin
            SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
            SpfyStoreItemLink."Variant Code" := '';
        end;
        SpfyStoreItemVariantLink.CalcFields("Allow Backorder", "Do Not Track Inventory", "Weight Unit", "Weight Value");
        AllowBackorder := SpfyStoreItemVariantLink."Allow Backorder";
        DoNotTrackInventory := SpfyStoreItemVariantLink."Do Not Track Inventory";
        WeightValue := SpfyStoreItemVariantLink."Weight Value";
        WeightUnit := SpfyStoreItemVariantLink."Weight Unit";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(SpfyStoreItemLink);
        Clear(SpfyStoreItemVariantLink);
    end;

    local procedure CheckIntegrationIsEnabled()
    begin
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, Rec."Shopify Store Code") then
            Error(ItemIntegrIsNotEnabledErr);
    end;

    local procedure CheckWeightIntegrationIsEnabled()
    var
        NotEnabledErr: Label 'Weight integration is not enabled for this store. To enable this feature, please specify a default weight unit on the Shopify store card.';
    begin
        CheckIntegrationIsEnabled();
        DefaultWeightUnit := SpfyIntegrationMgt.DefaultWeightUnit(Rec."Shopify Store Code");
        if DefaultWeightUnit = Enum::"NPR Spfy Weight Unit"::" " then
            Error(NotEnabledErr);
    end;
}
#endif