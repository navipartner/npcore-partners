page 6151445 "NPR Magento Store Items"
{
    Caption = 'Magento Webshop Items';
    LinksAllowed = false;
    PageType = List;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR Magento Store Item";
    CardPageId = "NPR Magento Store Items Card";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Webshop; Rec.Webshop)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Webshop field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Code"; Rec."Store Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Website Code"; Rec."Website Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Website Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(GetEnabledFieldsCaption; Rec.GetEnabledFieldsCaption())
                {

                    Caption = 'Fields Enabled';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Fields Enabled field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
