page 6151298 "NPR PG Stripe Setup Card"
{
    Extensible = false;
    Caption = 'Stipe Setup Card';
    UsageCategory = None;
    PageType = Card;
    SourceTable = "NPR PG Stripe Setup";

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
                    trigger OnValidate()

                    begin
                        TestGroupVisibility := Rec.Environment = Rec.Environment::Test;
                        LiveGroupVisibility := not TestGroupVisibility;
                    end;
                }
            }

            group(Live)
            {
                Caption = 'Live Keys';
                Visible = LiveGroupVisibility;
                field(LiveSecretKey; _LiveSecretKey)
                {
                    Caption = 'Secret API Key';
                    ToolTip = 'Specifies the value of the Secret Key field';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        if _LiveSecretKey <> '' then
                            Rec.SetSecret(Rec.FieldNo("Live API Client Secret Key"), _LiveSecretKey)
                        else
                            if Rec.HasSecret(Rec.FieldNo("Live API Client Secret Key")) then
                                Rec.RemoveSecret(Rec.FieldNo("Live API Client Secret Key"));

                    end;
                }
            }

            group("Test Keys")
            {
                Caption = 'Test Keys';
                Visible = TestGroupVisibility;

                field(TestSecretKey; _TestSecretKey)
                {
                    Caption = 'Secret API Key';
                    ToolTip = 'Specifies the value of the Secret Key field';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        if _TestSecretKey <> '' then
                            Rec.SetSecret(Rec.FieldNo("Test API Client Secret Key"), _TestSecretKey)
                        else
                            if Rec.HasSecret(Rec.FieldNo("Test API Client Secret Key")) then
                                Rec.RemoveSecret(Rec.FieldNo("Test API Client Secret Key"));

                    end;

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
                    StripeIntegrationMgt: Codeunit "NPR PG Stripe Integration Mgt.";
                begin
                    StripeIntegrationMgt.TestPaymentIntentAPI(Rec);
                end;
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        TestGroupVisibility := Rec.Environment = Rec.Environment::Test;
        LiveGroupVisibility := not TestGroupVisibility;
        _LiveSecretKey := Rec.GetSecret(Rec.FieldNo("Live API Client Secret Key"));
        _TestSecretKey := Rec.GetSecret(Rec.FieldNo("Test API Client Secret Key"));
    end;

    var
        [NonDebuggable]
        _LiveSecretKey: Text;
        [NonDebuggable]
        _TestSecretKey: Text;
        LiveGroupVisibility, TestGroupVisibility : Boolean;
}