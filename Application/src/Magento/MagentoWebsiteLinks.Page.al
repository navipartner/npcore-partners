page 6151405 "NPR Magento Website Links"
{
    Extensible = False;
    Caption = 'Website Links';
    DelayedInsert = true;
    Editable = true;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR Magento Website Link";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Website Code"; Rec."Website Code")
                {

                    ToolTip = 'Specifies the value of the Website Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Website Name"; Rec."Website Name")
                {

                    ToolTip = 'Specifies the value of the Website Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
