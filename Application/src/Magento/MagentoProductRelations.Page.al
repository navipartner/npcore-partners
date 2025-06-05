page 6151421 "NPR Magento Product Relations"
{
    Extensible = False;
    Caption = 'Product Relations';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
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
                    ApplicationArea = NPRMagento;
                }
                field("To Item No."; Rec."To Item No.")
                {

                    ToolTip = 'Specifies the value of the To Item No. field';
                    ApplicationArea = NPRMagento;
                }
                field("To Item Description"; Rec."To Item Description")
                {

                    Caption = 'Description';
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMagento;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
