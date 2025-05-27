page 6151467 "NPR PG Dibs Setup Card"
{
    Extensible = False;
    Caption = 'Payment Integration Dibs Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR PG Dibs Setup";

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
                field("Api Url"; Rec."Api Url")
                {
                    ToolTip = 'Specifies the value of the Api Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Username"; Rec."Api Username")
                {
                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRRetail;
                }
                field(PasswordTxt; PasswordTxt)
                {
                    Caption = 'Api Password';
                    ToolTip = 'Specifies the Api Password';
                    ApplicationArea = NPRRetail;
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        if (PasswordTxt = '') then
                            Rec.DeleteApiPassword()
                        else
                            Rec.SetApiPassword(PasswordTxt);
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
        PasswordTxt: Text;

    trigger OnAfterGetRecord()
    begin
        if (Rec.HasApiPassword()) then
            PasswordTxt := '***';
    end;
}
