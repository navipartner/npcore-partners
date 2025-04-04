#if not BC17
table 6150811 "NPR Spfy Store-Item Link"
{
    Access = Public;
    Extensible = false;
    Caption = 'Shopify Store-Item Link';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Store-Item Links";
    LookupPageId = "NPR Spfy Store-Item Links";

    fields
    {
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionMembers = Item,"Variant";
            OptionCaption = 'Item,Variant';
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            NotBlank = true;
        }
        field(30; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const("Variant")) "Item Variant" where("Item No." = field("Item No."));
        }
        field(40; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            NotBlank = true;
        }
        field(100; "Sync. to this Store"; Boolean)
        {
            Caption = 'Sync. with Store';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
                ConfirmDisableSyncLbl: Label 'Are you sure you want to disable synchronization for Item %1 with Shopify Store %2? If you confirm, the item will be marked as archived on the Shopify Store.', Comment = '%1 - Item No., %2 - Shopify Store Code';
            begin
                if xRec."Sync. to this Store" and not "Sync. to this Store" then
                    if not Confirm(ConfirmDisableSyncLbl, false, "Item No.", "Shopify Store Code") then
                        Error('');
                if "Sync. to this Store" then begin
                    Modify();
                    SpfyMetafieldMgt.InitStoreItemLinkMetafields(Rec);
                end;
            end;
        }
        field(105; "Synchronization Is Enabled"; Boolean)
        {
            Caption = 'Synchronization Enabled';
            DataClassification = CustomerContent;
        }
        field(110; "Shopify Name"; Text[250])
        {
            Caption = 'Shopify Name';
            DataClassification = CustomerContent;
        }
        field(120; "Shopify Description"; Blob)
        {
            Caption = 'Shopify Description';
            DataClassification = CustomerContent;
        }
        field(130; "Store Integration Is Enabled"; Boolean)
        {
            Caption = 'Store Is Enabled';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Store".Enabled where(Code = field("Shopify Store Code")));
        }
        field(140; "Shopify Status"; Enum "NPR Spfy Product Status")
        {
            Caption = 'Shopify Status';
            DataClassification = CustomerContent;
        }
        field(150; "Allow Backorder"; Boolean)
        {
            Caption = 'Allow Backorder';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Item Variant Modif."."Allow Backorder" where("Item No." = field("Item No."), "Variant Code" = field("Variant Code"), "Shopify Store Code" = field("Shopify Store Code")));
        }
    }
    keys
    {
        key(PK; Type, "Item No.", "Variant Code", "Shopify Store Code")
        {
            Clustered = true;
        }
        key(SyncEnabled; Type, "Item No.", "Variant Code", "Synchronization Is Enabled") { }
        key(StoreItems; "Shopify Store Code") { }
    }

    trigger OnDelete()
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
        if Rec.Type = Rec.Type::Item then begin
            SpfyStoreItemLink := Rec;
            SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::"Variant";
            SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
            SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID");
            SpfyItemMgt.RemoveShopifyItemVariantModification(SpfyStoreItemLink);
        end;
        SpfyMetafieldMgt.FilterSpfyEntityMetafields(RecordId(), "NPR Spfy Metafield Owner Type"::PRODUCT, SpfyEntityMetafield);
        SpfyEntityMetafield.SetRange("Owner Type", SpfyEntityMetafield."Owner Type"::PRODUCT, SpfyEntityMetafield."Owner Type"::PRODUCTVARIANT);
        if not SpfyEntityMetafield.IsEmpty() then
            SpfyEntityMetafield.DeleteAll();
    end;

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label '%1 record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr, Rec.TableCaption);
    end;

    internal procedure SetShopifyDescription(NewShopifyDescription: Text)
    var
        OStream: OutStream;
    begin
        if "Shopify Description".HasValue() then
            Clear("Shopify Description");
        if NewShopifyDescription = '' then
            exit;

        "Shopify Description".CreateOutStream(OStream);
        OStream.WriteText(NewShopifyDescription);
    end;
}
#endif