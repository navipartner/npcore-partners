page 6184870 "NPR MM Sub Adyen PG Setup Card"
{
    Extensible = False;
    Caption = 'Subscriptions Payment Gateway Adyen Setup Card';
    PageType = Card;
    SourceTable = "NPR MM Subs Adyen PG Setup";
    UsageCategory = None;

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
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ShowMandatory = true;
                }
                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                group(APIUrlPrefixContainer)
                {
                    ShowCaption = false;
                    Visible = (Rec.Environment = Rec.Environment::Production);

                    field("API URL Prefix"; Rec."API URL Prefix")
                    {
                        ToolTip = 'Specifies the value of the API URL Prefix field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ShowMandatory = true;
                    }
                }
                field(APIPasswordTxt; ApiKeyText)
                {
                    Caption = 'API Key';
                    ToolTip = 'Specifies the value of the API Password field';
                    ExtendedDatatype = Masked;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if (ApiKeyText = '') then
                            Rec.DeleteAPIKey()
                        else
                            Rec.SetAPIKey(ApiKeyText);
                    end;
                }
            }
            group(Posting)
            {
                field("Payment Account Type"; Rec."Payment Account Type")
                {
                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Account No."; Rec."Payment Account No.")
                {
                    ToolTip = 'Specifies the value of the Environment field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ShowMandatory = true;
                }
            }
        }
    }

    var
        [NonDebuggable]
        ApiKeyText: Text;

    trigger OnAfterGetRecord()
    begin
        if (Rec.HasAPIKey()) then
            ApiKeyText := '***';
    end;
}
