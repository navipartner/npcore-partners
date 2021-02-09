page 6151405 "NPR Magento Website Links"
{
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Website Code field';
                }
                field("Website Name"; Rec."Website Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Website Name field';
                }
            }
        }
    }
}