page 6059876 "NPR POS Unit Group Card"
{
    Extensible = False;
    Caption = 'POS Unit Group';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Unit Group";

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
            part(Lines;"NPR POS Unit Group Lines")
            {
                Caption = 'Lines';
                ApplicationArea = NPRRetail;
                SubPageLink = "No." = field("No.");
            }
        }
    }
}