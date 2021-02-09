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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Relation Type field';
                }
                field("To Item No."; Rec."To Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Item No. field';
                }
                field("To Item Description"; Rec."To Item Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
            }
        }
    }
}