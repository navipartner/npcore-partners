#if not BC17
page 6184563 "NPR Spfy Change Assigned ID"
{
    Extensible = false;
    PageType = ConfirmationDialog;
    InstructionalText = 'Please specify new Shopify ID for the entity';
    Caption = 'Set Shopify ID';
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field("BC Entity"; Format(BCRecID))
            {
                Caption = 'BC Entity';
                ToolTip = 'Specifies a BC entity the Shopify ID is assigned to, for example an item or a customer.';
                ApplicationArea = NPRShopify;
                Editable = false;
            }
            field("Current Shopify ID"; CurrentShopifyID)
            {
                Caption = 'Current Shopify ID';
                ToolTip = 'Specifies the Shopify ID currently assigned to the BC entity.';
                ApplicationArea = NPRShopify;
                Editable = false;
            }
            field("New Shopify ID"; NewShopifyID)
            {
                Caption = 'New Shopify ID';
                ToolTip = 'Specifies a new Shopify ID you would like to assign to the BC entity.';
                ApplicationArea = NPRShopify;
                AssistEdit = true;

                trigger OnAssistEdit()
                begin
                    GetIdFromShopify();
                end;
            }
        }
    }

    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        BCRecID: RecordId;
        IDType: Enum "NPR Spfy ID Type";
        CurrentShopifyID: Text[30];
        NewShopifyID: Text[30];

    internal procedure SetOptions(BCRecIDIn: RecordId; IDTypeIn: Enum "NPR Spfy ID Type")
    begin
        BCRecID := BCRecIDIn;
        IDType := IDTypeIn;
    end;

    trigger OnOpenPage()
    var
        BCEntityMustBeSpecified: Label 'BC entity must be specified.';
    begin
        if Format(BCRecID) = '' then
            Error(BCEntityMustBeSpecified);
        CurrentShopifyID := SpfyAssignedIDMgt.GetAssignedShopifyID(BCRecID, IDType);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        EmptyShopifyIDConfTxt: Label 'You have not specified the New Shopify ID.\Are you sure you want to clear Shopify ID for the entity?';
        UpdateInventoryLevelsTxt: Label 'You have changed Shopify Location ID.\You will need to run the "Calculate Inventory Levels" batch job on the "Shopify Inventory Levels" page to make sure inventory availability sent to Shopify reflects the change.';
    begin
        if CloseAction = Action::Yes then begin
            if NewShopifyID = '' then
                if not Confirm(EmptyShopifyIDConfTxt, true) then
                    exit(false);
            SpfyAssignedIDMgt.AssignShopifyID(BCRecID, IDType, NewShopifyID, BCRecID.TableNo <> Database::"NPR Spfy Store-Location Link");
            if (CurrentShopifyID <> NewShopifyID) and (BCRecID.TableNo = Database::"NPR Spfy Store-Location Link") and (IDType = "NPR Spfy ID Type"::"Entry ID") then
                Message(UpdateInventoryLevelsTxt);
        end;
        exit(true);
    end;

    internal procedure GetIdFromShopify()
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
        RecRef: RecordRef;
    begin
        case BCRecID.TableNo of
            Database::"NPR Spfy Store-Item Link":
                begin
                    RecRef.Get(BCRecID);
                    RecRef.SetTable(SpfyStoreItemLink);
                    SpfyStoreItemLink.TestField("Item No.");
                    SpfyStoreItemLink.TestField("Shopify Store Code");
                    case IDType of
                        "NPR Spfy ID Type"::"Entry ID":
                            NewShopifyID := SendItemAndInventory.GetShopifyVariantID(SpfyStoreItemLink, true);
                        "NPR Spfy ID Type"::"Inventory Item ID":
                            NewShopifyID := SendItemAndInventory.GetShopifyInventoryItemID(SpfyStoreItemLink, true);
                    end;
                end;
            Database::"NPR Spfy Store-Location Link":
                begin
                    RecRef.Get(BCRecID);
                    RecRef.SetTable(SpfyStoreLocationLink);
                    SpfyStoreLocationLink.TestField("Shopify Store Code");
                    SendItemAndInventory.SelectShopifyLocation(SpfyStoreLocationLink."Shopify Store Code", NewShopifyID);
                end;
        end;
    end;
}
#endif