page 6151469 "NPR PG Netaxept Setup Card"
{
    Extensible = False;
    Caption = 'Payment Integration Netaxept Setup Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR PG Netaxept Setup";

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
                    Visible = false;
                    Editable = false;
                }
                field(TokenTxt; TokenTxt)
                {
                    Caption = 'Api Access Token';
                    ToolTip = 'Specifies the value of the Api Access Token field';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if (TokenTxt = '') then
                            Rec.DeleteApiAccessToken()
                        else
                            Rec.SetApiAccessToken(TokenTxt);
                    end;
                }
                field("Merchant ID"; Rec."Merchant ID")
                {
                    ToolTip = 'Specifies the value of the Merchant ID field';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        [NonDebuggable]
        TokenTxt: Text;

    trigger OnAfterGetRecord()
    begin
        if (Rec.HasApiAccessToken()) then
            TokenTxt := '***';
    end;
}
