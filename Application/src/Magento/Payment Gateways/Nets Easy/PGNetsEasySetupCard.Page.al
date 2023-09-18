page 6151470 "NPR PG Nets Easy Setup Card"
{
    Extensible = False;
    Caption = 'Payment Integration Nets Easy Setup Card';
    ContextSensitiveHelpPage = 'docs/integrations/payment_gateway/how-to/netseasy/';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR PG Nets Easy Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the environment field';
                    ApplicationArea = NPRRetail;
                }
                field(AuthTokenTxt; AuthTokenTxt)
                {
                    Caption = 'API Authorization Token';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the API Authorization Token field';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if (AuthTokenTxt = '') then
                            Rec.DeleteAuthorizationToken()
                        else
                            Rec.SetAuthorizationToken(AuthTokenTxt);
                    end;
                }
            }
        }
    }

    var
        [NonDebuggable]
        AuthTokenTxt: Text;

    trigger OnAfterGetRecord()
    begin
        if (Rec.HasAuthorizationToken()) then
            AuthTokenTxt := '***';
    end;
}