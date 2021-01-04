page 6151421 "NPR Magento Product Relations"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Product Relations';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = CardPart;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR Magento Product Relation";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Relation Type"; "Relation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Relation Type field';
                }
                field("To Item No."; "To Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Item No. field';
                }
                field("To Item Description"; "To Item Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
            }
        }
    }

    actions
    {
    }
}

