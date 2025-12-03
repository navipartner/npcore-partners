#if not BC17
page 6185092 "NPR Spfy Store-Cust.Links Subp"
{
    Extensible = false;
    Caption = 'Shopify Store-Customer Links';
    PageType = ListPart;
    SourceTable = "NPR Spfy Store-Customer Link";
    UsageCategory = None;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the Business Central customer the link to be created for.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store the linked customer is integrated to.';
                    ApplicationArea = NPRShopify;
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
                    ToolTip = 'Specifies whether the customer has been requested to be integrated with the Shopify store.';
                    ApplicationArea = NPRShopify;
                    Editable = CustomerListIntegrationIsEnabled;

                    trigger OnValidate()
                    begin
                        CheckIntegrationIsEnabled();
                    end;
                }
                field("Synchronization Is Enabled"; Rec."Synchronization Is Enabled")
                {
                    ToolTip = 'Specifies whether confirmation has been received from the Shopify store that the associated customer has been successfully created in the store.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    DrillDown = false;
                }
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the first name of the customer as it is defined in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the last name of the customer as it is defined in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ToolTip = 'Specifies the email address of the customer as it is defined in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the phone number of the customer as it is defined in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("E-mail Marketing State"; Rec."E-mail Marketing State")
                {
                    ToolTip = 'Specifies the customer’s e-mail marketing consent state (i.e. whether the customer is subscribed to the newsletter) at the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Customer ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Customer ID';
                    ToolTip = 'Specifies a Shopify Customer ID assigned to the customer.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        Rec.TestField(Type, Rec.Type::Customer);
                        Rec.TestField("No.");
                        Rec.TestField("Shopify Store Code");
                        CurrPage.SaveRecord();
                        Commit();

                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        ChangeShopifyID.RunModal();

                        CurrPage.Update(false);
                    end;
                }
                field("Customer Metafields"; SpfyMetafieldMgt.SyncedEntityMetafieldCount(Rec.RecordId(), "NPR Spfy Metafield Owner Type"::CUSTOMER))
                {
                    Caption = 'Customer Metafields';
                    ToolTip = 'Specifies the number of customer metafields synced with Shopify.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        SpfyMetafieldMgt.ShowEntitySyncedMetafields(Rec.RecordId(), "NPR Spfy Metafield Owner Type"::CUSTOMER);
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
                ToolTip = 'Updates the list of available Shopify stores for the customer.';
                ApplicationArea = NPRShopify;
                Image = GetLines;

                trigger OnAction()
                var
                    Customer: Record Customer;
                    SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
                begin
                    CurrPage.SaveRecord();
                    if Rec."No." = '' then
                        Rec."No." := Rec.GetRangeMin("No.");
                    Rec.TestField("No.");
                    Customer.Get(Rec."No.");
                    SpfyStoreLinkMgt.UpdateStoreCustomerLinks(Customer);
                    CurrPage.Update(false);
                end;
            }
            action(SyncItems)
            {
                Caption = 'Update Sync. Status';
                ToolTip = 'Updates customer synchronization status between BC and Shopify. The system will go through Shopify stores and mark the customer as synchronized if it has already been created in the store. The system will also update the customer first and last names, email, phone number and metafields from Shopify.';
                ApplicationArea = NPRShopify;
                Image = CheckList;

                trigger OnAction()
                var
                    Customer: Record Customer;
                    ShopifyStore: Record "NPR Spfy Store";
                    SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
                    SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
                    Window: Dialog;
                    SyncInProgressLbl: Label 'Updating customer sync. status...';
                    DisabledStoresExist: Label 'There are Shopify stores for which integration is not enabled. The system will not update the customer sync status for these stores. Are you sure you want to proceed?';
                begin
                    ShopifyStore.SetRange(Enabled, true);
                    ShopifyStore.FindFirst();
                    ShopifyStore.SetRange(Enabled, false);
                    if not ShopifyStore.IsEmpty() then
                        if not Confirm(DisabledStoresExist, true) then
                            exit;

                    CurrPage.SaveRecord();
                    if Rec."No." = '' then
                        Rec."No." := Rec.GetRangeMin("No.");
                    Rec.TestField("No.");
                    Customer.Get(Rec."No.");
                    SpfyStoreLinkMgt.UpdateStoreCustomerLinks(Customer);
                    Commit();
                    Window.Open(SyncInProgressLbl);
                    ShopifyStore.SetRange(Enabled, true);
                    SpfySendCustomers.MarkCustomerAlreadyOnShopify(Customer, ShopifyStore, false, false, true);
                    Window.Close();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
        CustomerListIntegrationIsEnabled: Boolean;

    trigger OnOpenPage()
    begin
        CustomerListIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders");
    end;

    local procedure CheckIntegrationIsEnabled()
    var
        CustomerIntegrIsNotEnabledErr: Label 'Customer (Sales Order) integration is not enabled for the store. You cannot adjust this parameter.';
    begin
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", Rec."Shopify Store Code") then
            Error(CustomerIntegrIsNotEnabledErr);
    end;
}
#endif