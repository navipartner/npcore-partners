page 6151466 "NPR PG Adyen Setup Card"
{
    Extensible = False;
    Caption = 'Payment Integration Adyen Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR PG Adyen Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Merchant Name"; Rec."Merchant Name")
                {
                    ToolTip = 'Specifies the value of the Merchant Name field';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRRetail;
                }
                group(APIUrlPrefixContainer)
                {
                    ShowCaption = false;
                    Visible = (Rec.Environment = Rec.Environment::Production);

                    field("API URL Prefix"; Rec."API URL Prefix")
                    {
                        ToolTip = 'Specifies the value of the API URL Prefix field';
                        ApplicationArea = NPRRetail;
                        ShowMandatory = true;
                    }
                }
                field("Api Username"; Rec."API Username")
                {
                    Caption = 'API Username';
                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field(APIPasswordTxt; APIPasswordTxt)
                {
                    Caption = 'API Password';
                    ToolTip = 'Specifies the value of the API Password field';
                    ExtendedDatatype = Masked;
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if (APIPasswordTxt = '') then
                            Rec.DeleteAPIPassword()
                        else
                            Rec.SetAPIPassword(APIPasswordTxt);
                    end;
                }
            }
        }
    }

    var
        [NonDebuggable]
        APIPasswordTxt: Text;

    trigger OnAfterGetRecord()
    begin
        if (Rec.HasAPIPassword()) then
            APIPasswordTxt := '***';
    end;
}
