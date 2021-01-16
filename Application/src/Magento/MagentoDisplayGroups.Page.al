page 6151444 "NPR Magento Display Groups"
{
    // MAG1.07/MH/20150309  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Display Groups';
    PageType = List;
    SourceTable = "NPR Magento Display Group";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

