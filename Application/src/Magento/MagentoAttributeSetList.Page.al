page 6151433 "NPR Magento Attribute Set List"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    AutoSplitKey = true;
    Caption = 'Attribute Sets';
    CardPageID = "NPR Magento Attribute Sets";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Magento Attribute Set";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Used by Items"; "Used by Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used by Items field';
                }
            }
        }
    }

    actions
    {
    }
}

