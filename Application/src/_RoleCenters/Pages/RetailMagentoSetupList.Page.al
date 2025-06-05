page 6151242 "NPR Retail Magento Setup List"

{
    Extensible = False;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Setup";
    ApplicationArea = NPRMagento;
    Caption = 'Retail Magento Setup List';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Magento Version"; Rec."Magento Version")
                {

                    ToolTip = 'Specifies the Magento Version.';
                    ApplicationArea = NPRMagento;
                }
                field("Magento Enabled"; Rec."Magento Enabled")
                {

                    ToolTip = 'Specifies if Magento is enabled.';
                    ApplicationArea = NPRMagento;
                }
                field("Magento Url"; Rec."Magento Url")
                {

                    ToolTip = 'Specifies the Magento URL';
                    ApplicationArea = NPRMagento;
                }
                field("Variant System"; Rec."Variant System")
                {

                    ToolTip = 'Specifies if this setup uses variant or not';
                    ApplicationArea = NPRMagento;
                }
                field("Variant Picture Dimension"; Rec."Variant Picture Dimension")
                {

                    ToolTip = 'Specifies the variant by choosing from the list of available variants';
                    ApplicationArea = NPRMagento;
                }
                field("Miniature Picture"; Rec."Miniature Picture")
                {

                    ToolTip = 'Specifies what type of picture this setup uses';
                    ApplicationArea = NPRMagento;
                }
                field("Max. Picture Size"; Rec."Max. Picture Size")
                {

                    ToolTip = 'Specifies the maximum picture size (kb).';
                    ApplicationArea = NPRMagento;
                }
                field("Inventory Location Filter"; Rec."Inventory Location Filter")
                {

                    ToolTip = 'Specifies if there is any filter for location inventory and you can choose from the list of available locations';
                    ApplicationArea = NPRMagento;
                }
                field("Intercompany Inventory Enabled"; Rec."Intercompany Inventory Enabled")
                {

                    ToolTip = 'Specifies if the intercompany inventory is enabled';
                    ApplicationArea = NPRMagento;
                }
                field("Api Url"; Rec."Api Url")
                {

                    ToolTip = 'Specifies the API URL';
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
                    ToolTip = 'Specifies the API username.';
                    ApplicationArea = NPRMagento;
                    Visible = IsBasicAuthVisible;
                }
                field(Password; Password)
                {

                    Caption = 'Api Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the API password.';
                    ApplicationArea = NPRMagento;
                    Visible = IsBasicAuthVisible;

                    trigger OnValidate()
                    begin
                        if Password <> '' then
                            WebServiceAuthHelper.SetApiPassword(Password, Rec."Api Password Key")
                        else begin
                            if WebServiceAuthHelper.HasApiPassword(Rec."Api Password Key") then
                                WebServiceAuthHelper.RemoveApiPassword(Rec."Api Password Key");
                        end;

                        Commit();
                    end;
                }

                field("OAuth2 Setup Code"; Rec."OAuth2 Setup Code")
                {
                    ApplicationArea = NPRMagento;
                    ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                    Visible = IsOAuth2Visible;
                }

                field("Api Authorization"; Rec."Api Authorization")
                {
                    ToolTip = 'Specifies the API authorization type.';
                    ApplicationArea = NPRMagento;
                    Visible = IsCustomAuthVisible;
                }
                field("Brands Enabled"; Rec."Brands Enabled")
                {

                    ToolTip = 'Specifies the value of the Brands Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Attributes Enabled"; Rec."Attributes Enabled")
                {

                    ToolTip = 'Specifies the value of the Attributes Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Product Relations Enabled"; Rec."Product Relations Enabled")
                {

                    ToolTip = 'Specifies the value of the Product Relations Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Special Prices Enabled"; Rec."Special Prices Enabled")
                {

                    ToolTip = 'Specifies the value of the Special Prices Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Tier Prices Enabled"; Rec."Tier Prices Enabled")
                {

                    ToolTip = 'Specifies the value of the Tier Prices Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Customer Group Prices Enabled"; Rec."Customer Group Prices Enabled")
                {

                    ToolTip = 'Specifies the value of the Customer Group Prices Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Custom Options Enabled"; Rec."Custom Options Enabled")
                {

                    ToolTip = 'Specifies the value of the Custom Options Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Custom Options No. Series"; Rec."Custom Options No. Series")
                {

                    ToolTip = 'Specifies the value of the Custom Options Nos. field';
                    ApplicationArea = NPRMagento;
                }
                field("Bundled Products Enabled"; Rec."Bundled Products Enabled")
                {

                    ToolTip = 'Specifies the value of the Bundled Products Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Multistore Enabled"; Rec."Multistore Enabled")
                {

                    ToolTip = 'Specifies the value of the Multistore Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Tickets Enabled"; Rec."Tickets Enabled")
                {

                    ToolTip = 'Specifies the value of the Tickets Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Customers Enabled"; Rec."Customers Enabled")
                {

                    ToolTip = 'Specifies the value of the Customers Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Sales Prices Enabled"; Rec."Sales Prices Enabled")
                {

                    ToolTip = 'Specifies the value of the Sales Prices Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Sales Line Discounts Enabled"; Rec."Sales Line Discounts Enabled")
                {

                    ToolTip = 'Specifies the value of the Sales Line Discounts Enabled field';
                    ApplicationArea = NPRMagento;
                }
                field("Item Disc. Group Enabled"; Rec."Item Disc. Group Enabled")
                {

                    ToolTip = 'Specifies the value of the Item Disc. Group Enabled field';
                    ApplicationArea = NPRMagento;
                }

                field("Exchange Web Code Pattern"; Rec."Exchange Web Code Pattern")
                {

                    ToolTip = 'Specifies the value of the Exchange Web Code Pattern field';
                    ApplicationArea = NPRMagento;
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {

                    ToolTip = 'Specifies the value of the Customer Mapping field';
                    ApplicationArea = NPRMagento;
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Customer Posting Group field';
                    ApplicationArea = NPRMagento;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Not use anymore.';
                }
                field("Customer Template Code"; Rec."Customer Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Template Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                    ApplicationArea = NPRMagento;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Not use anymore.';
                }
                field("Payment Fee Account No."; Rec."Payment Fee Account No.")
                {

                    ToolTip = 'Specifies the value of the Payment Fee Account No. field';
                    ApplicationArea = NPRMagento;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Release Order on Import"; Rec."Release Order on Import")
                {

                    ToolTip = 'Specifies the value of the Release Order on Import field';
                    ApplicationArea = NPRMagento;
                }
                field("Replicate to Sales Prices"; Rec."Replicate to Sales Prices")
                {

                    ToolTip = 'Specifies the value of the Replicate to Sales Prices field';
                    ApplicationArea = NPRMagento;
                }
                field("Replicate to Price Source Type"; Rec."Replicate to Price Source Type")
                {

                    ToolTip = 'Specifies the value of the Replicate to Sales Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Replicate to Sales Code"; Rec."Replicate to Sales Code")
                {

                    ToolTip = 'Specifies the value of the Replicate to Sales Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Auto Seo Link Disabled"; Rec."Auto Seo Link Disabled")
                {

                    ToolTip = 'Specifies the value of the Auto Seo Link Disabled field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible);
    end;

    trigger OnAfterGetRecord()
    begin
        Password := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."Api Password Key") then
            Password := '***';

        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible);
    end;

    var
        Password: Text[200];
        IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
}
