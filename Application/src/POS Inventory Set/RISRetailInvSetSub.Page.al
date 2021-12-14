page 6151087 "NPR RIS Retail Inv. Set Sub."
{
    UsageCategory = None;
    AutoSplitKey = true;
    Caption = 'Inventory Set Entries';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NPR RIS Retail Inv. Set Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Filter"; Rec."Location Filter")
                {

                    ToolTip = 'Specifies the value of the Location Filter field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Api Url"; Rec."Api Url")
                {

                    ToolTip = 'Specifies the value of the Api Url field';
                    ApplicationArea = NPRRetail;
                }
                field(AuthType; Rec.AuthType)
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Authorization Type.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Api Username"; Rec."Api Username")
                {

                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRRetail;
                    Visible = IsBasicAuthVisible;
                }

                field("API Password"; pw)
                {

                    ToolTip = 'Specifies the value of the User Password field';
                    ApplicationArea = NPRRetail;
                    Caption = 'API Password';
                    ExtendedDatatype = Masked;
                    Visible = IsBasicAuthVisible;
                    trigger OnValidate()
                    begin
                        if pw <> '' then
                            WebServiceAuthHelper.SetApiPassword(pw, Rec."API Password Key")
                        else begin
                            if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
                                WebServiceAuthHelper.RemoveApiPassword(Rec."API Password Key");
                        end;
                    end;
                }
                field("OAuth2 Setup Code"; Rec."OAuth2 Setup Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                    Visible = IsOAuth2Visible;
                }

                field("Processing Function"; Rec."Processing Function")
                {

                    ToolTip = 'Specifies the value of the Processing Function field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Codeunit ID"; Rec."Processing Codeunit ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Processing Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Codeunit Name"; Rec."Processing Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Processing Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    trigger OnAfterGetRecord()
    begin
        pw := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            pw := '***';
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    var
        [InDataSet]
        pw: Text[200];

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
}
