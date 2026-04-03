#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6150930 "NPR Entria Stores"
{
    Extensible = false;
    Caption = 'Entria Stores';
    PageType = List;
    CardPageId = "NPR Entria Store Card";
    SourceTable = "NPR Entria Store";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'entria, medusa, ecommerce, integration';
    ApplicationArea = NPRRetail;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies an internal unique id of the Entria store.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Entria store.';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether the integration with this Entria store is enabled.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(EntriaIntegrationSetup)
            {
                Caption = 'Integration Setup';
                ToolTip = 'Opens the Integration Setup page.';
                ApplicationArea = NPRRetail;
                Image = Setup;
                RunObject = page "NPR Entria Integration Setup";
            }
        }
    }
}
#endif
