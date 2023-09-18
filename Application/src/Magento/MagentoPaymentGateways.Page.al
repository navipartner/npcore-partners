page 6151453 "NPR Magento Payment Gateways"
{
    Extensible = False;
    Caption = 'Payment Gateways';
    ContextSensitiveHelpPage = 'docs/integrations/payment_gateway/explanation/payment_gateway/';
    PageType = List;
    SourceTable = "NPR Magento Payment Gateway";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Description';
                    ApplicationArea = NPRRetail;
                }
                field(IntegrationType; Rec."Integration Type")
                {
                    ToolTip = 'Specifies the value of the Enum Integration Type';
                    ApplicationArea = NPRRetail;
                }
                field("Enable Capture"; Rec."Enable Capture")
                {
                    ToolTip = 'Specifies if the Capture is enabled';
                    ApplicationArea = NPRRetail;
                }
                field("Enable Refund"; Rec."Enable Refund")
                {
                    ToolTip = 'Specifies if the Refund is enabled';
                    ApplicationArea = NPRRetail;
                }
                field("Enable Cancel"; Rec."Enable Cancel")
                {
                    ToolTip = 'Specifies if the Cancel is enabled';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ShowSetupCard)
            {
                Caption = 'Show Setup Card';
                ToolTip = 'Shows the setup card for the selected Payment Gateway';
                ApplicationArea = NPRRetail;
                Enabled = HasIntegrationSelected;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    IPaymentGateway: Interface "NPR IPaymentGateway";
                begin
                    IPaymentGateway := Rec."Integration Type";
                    IPaymentGateway.RunSetupCard(Rec.Code);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        HasIntegrationSelected := (Rec."Integration Type".AsInteger() <> 0);
    end;

    var
        HasIntegrationSelected: Boolean;
}
