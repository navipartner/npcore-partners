page 6059879 "NPR POS Store Group Card"
{
    Extensible = False;
    Caption = 'POS Store Group';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Store Group";

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Lines;"NPR POS Store Group Lines")
            {
                Caption = 'Lines';
                ApplicationArea = NPRRetail;
                SubPageLink = "No." = field("No.");
            }
        }
    }
}