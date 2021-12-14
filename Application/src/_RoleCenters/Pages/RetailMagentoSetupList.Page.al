page 6151242 "NPR Retail Magento Setup List"

{
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Setup";
    ApplicationArea = NPRRetail;
    Caption = 'Retail Magento Setup List';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Magento Version"; Rec."Magento Version")
                {

                    ToolTip = 'Specifies the value of the Magento Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Magento Enabled"; Rec."Magento Enabled")
                {

                    ToolTip = 'Specifies the value of the Magento Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Magento Url"; Rec."Magento Url")
                {

                    ToolTip = 'Specifies the value of the Magento Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant System"; Rec."Variant System")
                {

                    ToolTip = 'Specifies the value of the Variant System field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Picture Dimension"; Rec."Variant Picture Dimension")
                {

                    ToolTip = 'Specifies the value of the Variant Picture Dimension field';
                    ApplicationArea = NPRRetail;
                }
                field("Miniature Picture"; Rec."Miniature Picture")
                {

                    ToolTip = 'Specifies the value of the Miniature Picture field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Picture Size"; Rec."Max. Picture Size")
                {

                    ToolTip = 'Specifies the value of the Max. Picture Size (kb) field';
                    ApplicationArea = NPRRetail;
                }
                field("Inventory Location Filter"; Rec."Inventory Location Filter")
                {

                    ToolTip = 'Specifies the value of the Inventory Location Filter field';
                    ApplicationArea = NPRRetail;
                }
                field("Intercompany Inventory Enabled"; Rec."Intercompany Inventory Enabled")
                {

                    ToolTip = 'Specifies the value of the Intercompany Inventory Enabled field';
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
                field(Password; Password)
                {

                    Caption = 'Api Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Password field';
                    ApplicationArea = NPRRetail;
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
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                    Visible = IsOAuth2Visible;
                }

                field("Api Authorization"; Rec."Api Authorization")
                {
                    ToolTip = 'Specifies the value of the Api Authorization field';
                    ApplicationArea = NPRRetail;
                    Visible = IsCustomAuthVisible;
                }
                field("Brands Enabled"; Rec."Brands Enabled")
                {

                    ToolTip = 'Specifies the value of the Brands Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Attributes Enabled"; Rec."Attributes Enabled")
                {

                    ToolTip = 'Specifies the value of the Attributes Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Product Relations Enabled"; Rec."Product Relations Enabled")
                {

                    ToolTip = 'Specifies the value of the Product Relations Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Special Prices Enabled"; Rec."Special Prices Enabled")
                {

                    ToolTip = 'Specifies the value of the Special Prices Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Tier Prices Enabled"; Rec."Tier Prices Enabled")
                {

                    ToolTip = 'Specifies the value of the Tier Prices Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Group Prices Enabled"; Rec."Customer Group Prices Enabled")
                {

                    ToolTip = 'Specifies the value of the Customer Group Prices Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Options Enabled"; Rec."Custom Options Enabled")
                {

                    ToolTip = 'Specifies the value of the Custom Options Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Options No. Series"; Rec."Custom Options No. Series")
                {

                    ToolTip = 'Specifies the value of the Custom Options Nos. field';
                    ApplicationArea = NPRRetail;
                }
                field("Bundled Products Enabled"; Rec."Bundled Products Enabled")
                {

                    ToolTip = 'Specifies the value of the Bundled Products Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Multistore Enabled"; Rec."Multistore Enabled")
                {

                    ToolTip = 'Specifies the value of the Multistore Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Tickets Enabled"; Rec."Tickets Enabled")
                {

                    ToolTip = 'Specifies the value of the Tickets Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Customers Enabled"; Rec."Customers Enabled")
                {

                    ToolTip = 'Specifies the value of the Customers Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Prices Enabled"; Rec."Sales Prices Enabled")
                {

                    ToolTip = 'Specifies the value of the Sales Prices Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Line Discounts Enabled"; Rec."Sales Line Discounts Enabled")
                {

                    ToolTip = 'Specifies the value of the Sales Line Discounts Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Disc. Group Enabled"; Rec."Item Disc. Group Enabled")
                {

                    ToolTip = 'Specifies the value of the Item Disc. Group Enabled field';
                    ApplicationArea = NPRRetail;
                }

                field("Exchange Web Code Pattern"; Rec."Exchange Web Code Pattern")
                {

                    ToolTip = 'Specifies the value of the Exchange Web Code Pattern field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {

                    ToolTip = 'Specifies the value of the Customer Mapping field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {

                    ToolTip = 'Specifies the value of the Customer Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Template Code"; Rec."Customer Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {

                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {

                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Fee Account No."; Rec."Payment Fee Account No.")
                {

                    ToolTip = 'Specifies the value of the Payment Fee Account No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Release Order on Import"; Rec."Release Order on Import")
                {

                    ToolTip = 'Specifies the value of the Release Order on Import field';
                    ApplicationArea = NPRRetail;
                }
                field("Replicate to Sales Prices"; Rec."Replicate to Sales Prices")
                {

                    ToolTip = 'Specifies the value of the Replicate to Sales Prices field';
                    ApplicationArea = NPRRetail;
                }
                field("Replicate to Price Source Type"; Rec."Replicate to Price Source Type")
                {

                    ToolTip = 'Specifies the value of the Replicate to Sales Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Replicate to Sales Code"; Rec."Replicate to Sales Code")
                {

                    ToolTip = 'Specifies the value of the Replicate to Sales Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Seo Link Disabled"; Rec."Auto Seo Link Disabled")
                {

                    ToolTip = 'Specifies the value of the Auto Seo Link Disabled field';
                    ApplicationArea = NPRRetail;
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