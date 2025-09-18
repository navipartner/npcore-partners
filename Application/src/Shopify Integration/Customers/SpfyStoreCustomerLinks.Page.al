#if not BC17
page 6185101 "NPR Spfy Store-Customer Links"
{
    Extensible = false;
    Caption = 'Shopify Store-Customer Links';
    PageType = List;
    SourceTable = "NPR Spfy Store-Customer Link";
    UsageCategory = None;
    Editable = false;

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
                }
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store the linked customer is integrated to.';
                    ApplicationArea = NPRShopify;
                }
                field("Sync. to this Store"; Rec."Sync. to this Store")
                {
                    ToolTip = 'Specifies whether the customer has been requested to be integrated with the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("Synchronization Is Enabled"; Rec."Synchronization Is Enabled")
                {
                    ToolTip = 'Specifies whether confirmation has been received from the Shopify store that the associated customer has been successfully created in the store.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Customer ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Customer ID';
                    ToolTip = 'Specifies a Shopify Customer ID assigned to the customer.';
                    ApplicationArea = NPRShopify;
                }
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the first name of the customer as it is specified in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the last name of the customer as it is specified in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("E-Mail"; Rec."E-Mail")
                {
                    ToolTip = 'Specifies the email address of the customer as it is specified in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the phone number of the customer as it is specified in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }

    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
}
#endif