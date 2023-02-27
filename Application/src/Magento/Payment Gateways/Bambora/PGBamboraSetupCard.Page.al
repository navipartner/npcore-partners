page 6151472 "NPR PG Bambora Setup Card"
{
    Extensible = False;
    Caption = 'Payment Integration Bambora Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR PG Bambora Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    Visible = false;
                }
                field("Access Token"; Rec."Access Token")
                {
                    ToolTip = 'Specifies the value of the Access Token field';
                    ApplicationArea = NPRRetail;
                }
                field("Secret Token"; SecretToken)
                {
                    Caption = 'Secret Token';
                    ToolTip = 'Specifies the value of the Secret Token field';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        if (SecretToken = '') then
                            Rec.DeleteSecretToken()
                        else
                            Rec.SetSecretToken(SecretToken);
                    end;
                }
                field("Merchant ID"; Rec."Merchant ID")
                {
                    ToolTip = 'Specifies the value of the Merchant ID field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        [NonDebuggable]
        SecretToken: Text;

    trigger OnAfterGetRecord()
    begin
        if (Rec.HasSecretToken()) then
            SecretToken := '***';
    end;
}
