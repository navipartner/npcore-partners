page 6151402 "NPR Magento Inv. Companies"
{
    Extensible = False;
    Caption = 'Inventory Companies';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Inv. Company";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRMagento;
                }
                field("Location Filter"; Rec."Location Filter")
                {

                    ToolTip = 'Specifies the value of the Location Filter field';
                    ApplicationArea = NPRMagento;
                }

                field(AuthType; Rec.AuthType)
                {
                    ApplicationArea = NPRMagento;
                    Tooltip = 'Specifies the Authorization Type.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Api Username"; Rec."Api Username")
                {

                    ToolTip = 'Specifies the value of the Api Username field';
                    ApplicationArea = NPRMagento;
                    Visible = IsBasicAuthVisible;
                }
                field("API Password"; pw)
                {

                    ToolTip = 'Specifies the value of the User Password field';
                    ApplicationArea = NPRMagento;
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
                    ApplicationArea = NPRMagento;
                    ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                    Visible = IsOAuth2Visible;
                }
                field("Api Url"; Rec."Api Url")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Api Url field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TestApiUrl)
            {
                Caption = 'Test Api Url';
                Image = TestFile;
                ToolTip = 'Executes the Test Api Url action';
                ApplicationArea = NPRMagento;

                trigger OnAction()
                begin
                    TestApi();
                end;
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
        pw: Text[200];
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text000: Label 'Api Url OK';

    internal procedure TestApi()
    var
        Item: Record Item;
        MagentoInventoryNpXmlValue: Codeunit "NPR Magento Inv. NpXml Value";
    begin
        if Item.ChangeCompany(Rec."Company Name") then;
        Item.FindFirst();
        MagentoInventoryNpXmlValue.CalcMagentoInventoryCompany(Rec, Item."No.", '');
        Message(Text000);
    end;
}
