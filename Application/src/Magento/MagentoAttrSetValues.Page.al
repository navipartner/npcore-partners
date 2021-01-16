page 6151435 "NPR Magento Attr. Set Values"
{
    // MAG1.00/MHA /20150113  CASE 199932 Refactored Object from Web Integration
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.18/TS  /20180910  CASE 323934 Added field Attribute Group ID

    Caption = 'Attribute Set Values';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Attr. Set Value";
    SourceTableView = SORTING(Position);

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Attribute ID"; "Attribute ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute ID field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
                field("Attribute Group ID"; "Attribute Group ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Group ID field';
                }
            }
        }
    }

    actions
    {
    }
}

