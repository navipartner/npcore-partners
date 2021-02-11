page 6151242 "NPR Retail Magento Setup List"

{
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Setup";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Magento Version"; Rec."Magento Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Version field';
                }
                field("Magento Enabled"; Rec."Magento Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Enabled field';
                }
                field("Magento Url"; Rec."Magento Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Magento Url field';
                }
                field("Variant System"; Rec."Variant System")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant System field';
                }
                field("Variant Picture Dimension"; Rec."Variant Picture Dimension")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Picture Dimension field';
                }
                field("Miniature Picture"; Rec."Miniature Picture")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Miniature Picture field';
                }
                field("Max. Picture Size"; Rec."Max. Picture Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Picture Size (kb) field';
                }
                field("Generic Setup"; Rec."Generic Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Generic Setup field';
                }
                field("Inventory Location Filter"; Rec."Inventory Location Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inventory Location Filter field';
                }
                field("Intercompany Inventory Enabled"; Rec."Intercompany Inventory Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Intercompany Inventory Enabled field';
                }
                field("Api Url"; Rec."Api Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Url field';
                }
                field("Api Username Type"; Rec."Api Username Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Username Type field';
                }
                field("Api Username"; Rec."Api Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Username field';
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    Caption = 'Api Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Password field';

                    trigger OnValidate()
                    begin
                        Rec.SetApiPassword(Password);
                        Commit();
                    end;
                }
                field("Api Authorization"; Rec."Api Authorization")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Api Authorization field';
                }
                field("Managed Nav Modules Enabled"; Rec."Managed Nav Modules Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Managed Nav Modules Enabled field';
                }
                field("Managed Nav Api Url"; Rec."Managed Nav Api Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Managed Nav Api Url field';
                }
                field("Managed Nav Api Username"; Rec."Managed Nav Api Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Managed Nav api brugernavn field';
                }
                field(NavPassword; NavPassword)
                {
                    ApplicationArea = All;
                    Caption = 'Managed Nav Api Password';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Managed Nav Api Password field';

                    trigger OnValidate()
                    begin
                        Rec.SetNavApiPassword(NavPassword);
                        Commit();
                    end;
                }
                field("Version No."; Rec."Version No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version No. field';
                }
                field("Version Coverage"; Rec."Version Coverage")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version Coverage field';
                }
                field("Brands Enabled"; Rec."Brands Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Brands Enabled field';
                }
                field("Attributes Enabled"; Rec."Attributes Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attributes Enabled field';
                }
                field("Product Relations Enabled"; Rec."Product Relations Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Product Relations Enabled field';
                }
                field("Special Prices Enabled"; Rec."Special Prices Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Special Prices Enabled field';
                }
                field("Tier Prices Enabled"; Rec."Tier Prices Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tier Prices Enabled field';
                }
                field("Customer Group Prices Enabled"; Rec."Customer Group Prices Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Group Prices Enabled field';
                }
                field("Custom Options Enabled"; Rec."Custom Options Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Options Enabled field';
                }
                field("Custom Options No. Series"; Rec."Custom Options No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Options Nos. field';
                }
                field("Bundled Products Enabled"; Rec."Bundled Products Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bundled Products Enabled field';
                }
                field("Multistore Enabled"; Rec."Multistore Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Multistore Enabled field';
                }
                field("Tickets Enabled"; Rec."Tickets Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tickets Enabled field';
                }
                field("Customers Enabled"; Rec."Customers Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customers Enabled field';
                }
                field("Sales Prices Enabled"; Rec."Sales Prices Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Prices Enabled field';
                }
                field("Sales Line Discounts Enabled"; Rec."Sales Line Discounts Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Line Discounts Enabled field';
                }
                field("Item Disc. Group Enabled"; Rec."Item Disc. Group Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Disc. Group Enabled field';
                }

                field("Exchange Web Code Pattern"; Rec."Exchange Web Code Pattern")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exchange Web Code Pattern field';
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Mapping field';
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Posting Group field';
                }
                field("Customer Template Code"; Rec."Customer Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Template Code field';
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Config. Template Code field';
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                }
                field("Payment Fee Account No."; Rec."Payment Fee Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Fee Account No. field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Release Order on Import"; Rec."Release Order on Import")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Release Order on Import field';
                }
                field("Replicate to Sales Prices"; Rec."Replicate to Sales Prices")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Replicate to Sales Prices field';
                }
                field("Replicate to Sales Type"; Rec."Replicate to Sales Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Replicate to Sales Type field';
                }
                field("Replicate to Sales Code"; Rec."Replicate to Sales Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Replicate to Sales Code field';
                }
                field("Auto Seo Link Disabled"; Rec."Auto Seo Link Disabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Seo Link Disabled field';
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Password := '';
        NavPassword := '';
        if not IsNullGuid(Rec."Api Password Key") then
            Password := '***';
        if not IsNullGuid(Rec."Managed Nav Api Password Key") then
            NavPassword := '***';
    end;

    var
        Password: Text;
        NavPassword: Text;
}