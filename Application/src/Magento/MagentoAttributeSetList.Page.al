page 6151433 "NPR Magento Attribute Set List"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Attribute Sets';
    CardPageID = "NPR Magento Attribute Sets";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Attribute Set";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Used by Items"; Rec."Used by Items")
                {

                    ToolTip = 'Specifies the value of the Used by Items field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
