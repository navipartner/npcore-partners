#if not BC17
page 6184853 "NPR Spfy Metafields"
{
    Extensible = false;
    Caption = 'Shopify Metafields';
    PageType = List;
    SourceTable = "NPR Spfy Metafield Definition";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field.';
                    ApplicationArea = NPRShopify;
                }
                field("Key"; Rec."Key")
                {
                    ToolTip = 'Specifies the value of the Key field.';
                    ApplicationArea = NPRShopify;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = NPRShopify;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRShopify;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = NPRShopify;
                }
                field(Namespace; Rec."Namespace")
                {
                    ToolTip = 'Specifies the value of the Namespace field.';
                    ApplicationArea = NPRShopify;
                }
                field("Owner Type"; Rec."Owner Type")
                {
                    ToolTip = 'Specifies the value of the Owner Type field.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
}
#endif