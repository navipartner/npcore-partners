page 6151301 "NPR NpEc Store Card"
{
    Extensible = true;
    Caption = 'E-commerce Store Card';
    PageType = Card;
    SourceTable = "NPR NpEc Store";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code of the record.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the record.';
                    ApplicationArea = NPRRetail;
                }
#if not BC17
                field("Spfy Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Shopify: specifies the Shopify store code that represents this record.';
                    ApplicationArea = NPRShopify;
                }
                field("Spfy Source Name"; Rec."Shopify Source Name")
                {
                    ToolTip = 'Shopify: specifies the source name that is used by Shopify in incoming sales order json files to identify this record.';
                    ApplicationArea = NPRShopify;
                }
#endif
                field("Salesperson/Purchaser Code"; Rec."Salesperson/Purchaser Code")
                {
                    ToolTip = 'Specifies the name of the salesperson who is assigned to the e-commerce store.';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the location of the e-commerce store.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the code for the first dimension, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Specifies the code for the second dimension, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    ApplicationArea = NPRRetail;
                }
#if not BC17
                field("Spfy Country/Region Code"; Rec."Spfy Country/Region Code")
                {
                    ToolTip = 'Shopify: specifies the default country/region code that the system should use for the imported Shopify sales orders if no information about the customer’s country/region code has been provided in the incoming order json file.';
                    ApplicationArea = NPRShopify;
                }
                field("Spfy NP-Spy Customer No."; Rec."Spfy Customer No.")
                {
                    ToolTip = 'Shopify: specifies the default (pre-defined) customer that will be used by default for imported Shopify orders if a specific customer can’t be found. Alternatively, you can set up pre-defined customers through the customer mapping.';
                    ApplicationArea = NPRShopify;
                }
#endif
                field("Customer Mapping"; Rec."Customer Mapping")
                {
                    ToolTip = 'Specifies way for searching customer while creating or updating sales order.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ToolTip = 'Specifies the code of the customer configuration template.';
                    ApplicationArea = NPRRetail;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ToolTip = 'Specifies the code of the responsibility center, such as a distribution hub, that is associated with the involved user, company, customer, or vendor. When webshop order is created and imported to Business Central, if Code of this Store is named, then value from this field will be passed to the Sales Header.';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Create Customers"; Rec."Allow Create Customers")
                {
                    ToolTip = 'Specifies if customer will be created for current e-commerce store. Customer will be created if it''s not found when order is imported.';
                    ApplicationArea = NPRRetail;
                }
                field("Update Customers from S. Order"; Rec."Update Customers from S. Order")
                {
                    ToolTip = 'Specifies if customer will be updated for current e-commerce store. Customer will be updated if it''s found when order is imported.';
                    ApplicationArea = NPRRetail;
                }
                field("Release Order on Import"; Rec."Release Order on Import")
                {
                    ToolTip = 'Specifies the value of the Release Order on Import field';
                    ApplicationArea = NPRRetail;
                }
#if not BC17
                field("Shopify C&C Orders"; Rec."Shopify C&C Orders")
                {
                    ToolTip = 'Shopify: specifies whether this record is used to import Shopify Click&Collect orders.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-08-18';
                    ObsoleteReason = 'Moved to a PTE as it was a customization for a specific customer.';
                }
#endif
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(CustomerMapping)
            {
                Caption = 'Customer Mapping';
                Image = List;
                RunObject = Page "NPR NpEc Customer Mapping";
                RunPageLink = "Store Code" = FIELD(Code);
                ToolTip = 'View or edit customer mapping.';
                ApplicationArea = NPRRetail;
            }
#if not BC17
            action("NPR Spfy LocationMapping")
            {
                Caption = 'Location Mapping';
                ToolTip = 'Shopify: executes the Location Mapping action. You can set up rules to identify the location code, as well as the shipping agent and its service code, to be used for imported Shopify orders. Alternatively, you can pre-define a location code for each e-commerce store.';
                Image = List;
                RunObject = page "NPR Spfy Location Mapping";
                RunPageLink = "Store Code" = field(Code);
                ApplicationArea = NPRShopify;
            }
#endif
        }
    }
}
