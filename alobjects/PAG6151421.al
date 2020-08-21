page 6151421 "Magento Product Relations"
{
    // MAG1.00/MH/20150113  CASE 199932 Refactored Object from Web Integration
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Product Relations';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = CardPart;
    ShowFilter = false;
    SourceTable = "Magento Product Relation";

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
                }
                field("To Item No."; "To Item No.")
                {
                    ApplicationArea = All;
                }
                field("To Item Description"; "To Item Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

