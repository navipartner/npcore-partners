page 6151453 "NPR Magento Payment Gateways"
{
    Extensible = False;
    Caption = 'Payment Gateways';
    ContextSensitiveHelpPage = 'retail/webshopintegrations/payment_gateway/paymentgateway.html';
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
                field("Api Url"; Rec."Api Url")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';

                    ToolTip = 'Specifies the value of the Api Url field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
                }
                field(Token; Rec.Token)
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';

                    ToolTip = 'Specifies the value of the Api Token';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
                }
                field("Api Username"; Rec."Api Username")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';

                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
                }
                field(Password; Password)
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';

                    Caption = 'Api Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Password field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);

                    trigger OnValidate()
                    begin
                        Rec.SetApiPassword(Password);
                        Commit();
                    end;
                }
                field("Merchant ID"; Rec."Merchant ID")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';

                    ToolTip = 'Specifies the value of the Merchant Id field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
                }
                field("Merchant Name"; Rec."Merchant Name")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';

                    ToolTip = 'Specifies the value of the Merchant Name field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx';

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
                }
                field("Capture Codeunit Id"; Rec."Capture Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Capture]';

                    ToolTip = 'Specifies the value of the Capture codeunit-id field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
                }
                field("Refund Codeunit Id"; Rec."Refund Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Refund]';

                    ToolTip = 'Specifies the value of the Refund codeunit-id field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
                }
                field("Cancel Codeunit Id"; Rec."Cancel Codeunit Id")
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Cancel]';

                    ToolTip = 'Specifies the value of the Cancel Codeunit Id field';
                    ApplicationArea = NPRRetail;

                    Visible = false;
                    Editable = (not HasIntegrationSelected);
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

    trigger OnAfterGetRecord()
    begin
        Password := '';
        if not IsNullGuid(Rec."Api Password Key") then
            Password := '***';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        HasIntegrationSelected := (Rec."Integration Type".AsInteger() <> 0);
    end;

    var
        Password: Text[200];
        HasIntegrationSelected: Boolean;
}
