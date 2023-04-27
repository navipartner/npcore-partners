page 6150804 "NPR PG Vipps Setup Card"
{
    Extensible = false;
    Caption = 'Vipps Setup Card';
    UsageCategory = None;
    PageType = Card;
    SourceTable = "NPR PG Vipps Setup";

    layout
    {
        area(Content)
        {
            group(PaymentGateway)
            {
                Caption = 'Payment Gateway';

                field("Payment Gateway Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    Editable = false;
                }

                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(MerchantInformation)
            {
                Caption = 'Merchant Information';

                field("Merchant Serial Number"; Rec."Merchant Serial Number")
                {
                    ToolTip = 'Specifies the value of the Payment Gateway Code field';
                    ApplicationArea = NPRRetail;
                }
            }

            group(APIKeys)
            {
                Caption = 'API Keys';

                group(TmpGroup1)
                {
                    ShowCaption = false;

                    field("Ocp-Apim-Subcription-Key"; OcpApimSubscriptionKeyTxt)
                    {
                        Caption = 'Ocp-Apim-Subscription-Key';
                        ToolTip = 'Specifies the value of the Ocp-Apim-Subscription-Key field';
                        ApplicationArea = NPRRetail;
                        ExtendedDatatype = Masked;

                        trigger OnValidate()
                        begin
                            if (OcpApimSubscriptionKeyTxt <> '') then
                                Rec.SetOcpApimSubscriptionKey(OcpApimSubscriptionKeyTxt)
                            else
                                Rec.RemoveOcpApimSubscriptionKey();
                        end;
                    }
                }

                group(TmpGroup2)
                {
                    ShowCaption = false;

                    field("API Client ID"; Rec."API Client ID")
                    {
                        Caption = 'API Client ID';
                        ToolTip = 'Specifies the value of the API Client ID field';
                        ApplicationArea = NPRRetail;
                    }

                    field("API Client Secret"; ClientSecretTxt)
                    {
                        Caption = 'API Client Secret';
                        ToolTip = 'Specifies the value of the API Client Secret field';
                        ApplicationArea = NPRRetail;
                        ExtendedDatatype = Masked;

                        trigger OnValidate()
                        begin
                            if (ClientSecretTxt <> '') then
                                Rec.SetAPIClientSecret(ClientSecretTxt)
                            else
                                Rec.RemoveAPIClientSecret();
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test Connection';
                ToolTip = 'Executes Test Connection action';
                ApplicationArea = NPRRetail;
                Image = Server;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    VippsIntegration: Codeunit "NPR PG Vipps Integration Mgt.";
                    [NonDebuggable]
                    AccessToken: Text;
                    ConnectionFailedLbl: Label 'Connection failed!';
                    ConnectionOKLbl: Label 'Connection OK!';
                begin
                    if (not VippsIntegration.TryGetAccessToken(Rec, AccessToken)) or (AccessToken = '') then
                        Message(ConnectionFailedLbl)
                    else
                        Message(ConnectionOKLbl);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if (Rec.GetOcpApimSubscriptionKey() <> '') then
            OcpApimSubscriptionKeyTxt := '***';

        if (Rec.GetAPIClientSecret() <> '') then
            ClientSecretTxt := '***';
    end;

    var
        [NonDebuggable]
        OcpApimSubscriptionKeyTxt: Text;
        [NonDebuggable]
        ClientSecretTxt: Text;
}