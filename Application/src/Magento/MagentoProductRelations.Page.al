page 6151421 "NPR Magento Product Relations"
{
    Caption = 'Product Relations';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = CardPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR Magento Product Relation";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Relation Type"; Rec."Relation Type")
                {

                    ToolTip = 'Specifies the value of the Relation Type field';
                    ApplicationArea = NPRRetail;
                }
                field("To Item No."; Rec."To Item No.")
                {

                    ToolTip = 'Specifies the value of the To Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("To Item Description"; Rec."To Item Description")
                {

                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}