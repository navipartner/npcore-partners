#if not BC17
table 6151228 "NPR Spfy Store-Customer Link"
{
    Access = Public;
    Extensible = false;
    Caption = 'Shopify Store-Customer Link';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Store-Customer Links";
    LookupPageId = "NPR Spfy Store-Customer Links";

    fields
    {
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionMembers = Customer;
            OptionCaption = 'Customer';
        }
        field(20; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Customer)) Customer."No.";
            NotBlank = true;
        }
        field(40; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            NotBlank = true;
        }
        field(50; "First Name"; Text[100])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(60; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(70; "E-Mail"; Text[100])
        {
            Caption = 'E-Mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(80; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(100; "Sync. to this Store"; Boolean)
        {
            Caption = 'Sync. with Store';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
                ConfirmDisableSyncLbl: Label 'Are you sure you want to disable synchronization for Customer %1 with the Shopify store %2? If you confirm, the customer will be removed from the Shopify store.', Comment = '%1 - Customer No., %2 - Shopify Store Code';
            begin
                if xRec."Sync. to this Store" and not "Sync. to this Store" then
                    if GuiAllowed() then
                        if not Confirm(ConfirmDisableSyncLbl, false, "No.", "Shopify Store Code") then
                            Error('');
                if "Sync. to this Store" then begin
                    Modify(true);
                    SpfyMetafieldMgt.InitStoreCustomerLinkMetafields(Rec);
                end;
            end;
        }
        field(105; "Synchronization Is Enabled"; Boolean)
        {
            Caption = 'Synchronization Enabled';
            DataClassification = CustomerContent;
        }
        field(130; "Store Integration Is Enabled"; Boolean)
        {
            Caption = 'Store Is Enabled';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Store".Enabled where(Code = field("Shopify Store Code")));
        }
        field(200; "E-mail Marketing State"; Enum "NPR Spfy EMail Marketing State")
        {
            Caption = 'E-mail Marketing State';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InvalidValueErr: Label 'This value cannot be set directly.';
            begin
                if not ("E-mail Marketing State" in ["E-mail Marketing State"::SUBSCRIBED, "E-mail Marketing State"::UNSUBSCRIBED]) then
                    Error(InvalidValueErr);
                if "E-mail Marketing State" <> xRec."E-mail Marketing State" then
                    "Marketing State Updated in BC" := true;
            end;
        }
        field(210; "Marketing State Updated in BC"; Boolean)
        {
            Caption = 'Marketing State Updated in BC';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Type, "No.", "Shopify Store Code")
        {
            Clustered = true;
        }
        key(SyncEnabled; Type, "No.", "Synchronization Is Enabled") { }
        key(SyncToStore; "Sync. to this Store") { }
        key(StoreCustomers; "Shopify Store Code") { }
    }

    trigger OnDelete()
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        SpfyMetafieldMgt.FilterSpfyEntityMetafields(RecordId(), "NPR Spfy Metafield Owner Type"::CUSTOMER, SpfyEntityMetafield);
        if not SpfyEntityMetafield.IsEmpty() then
            SpfyEntityMetafield.DeleteAll();
    end;

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label '%1 record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr, Rec.TableCaption());
    end;
}
#endif