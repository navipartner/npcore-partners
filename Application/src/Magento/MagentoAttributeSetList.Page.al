page 6151433 "NPR Magento Attribute Set List"
{
    AutoSplitKey = true;
    Caption = 'Attribute Sets';
    CardPageID = "NPR Magento Attribute Sets";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Attribute Set";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Used by Items"; Rec."Used by Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used by Items field';
                }
            }
        }
    }
}