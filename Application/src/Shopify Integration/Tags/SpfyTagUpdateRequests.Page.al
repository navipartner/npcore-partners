#if not BC17
page 6184964 "NPR Spfy Tag Update Requests"
{
    Extensible = false;
    Caption = 'Shopify Tag Update Requests';
    PageType = List;
    SourceTable = "NPR Spfy Tag Update Request";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the BC table the Shopify tag value relates to.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("BC Record ID"; Format(Rec."BC Record ID"))
                {
                    Caption = 'BC Record ID';
                    ToolTip = 'Specifies the BC record the Shopify tag value is attached to.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the Shopify tag update request.';
                    ApplicationArea = NPRShopify;
                }
                field("Tag Value"; Rec."Tag Value")
                {
                    ToolTip = 'Specifies the Shopify tag value.';
                    ApplicationArea = NPRShopify;
                }
                field("Nc Task Entry No."; Rec."Nc Task Entry No.")
                {
                    ToolTip = 'Specifies the NaviConnect task entry number created for the Shopify tag update request.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
}
#endif