page 6059881 "NPR POS Store Groups"
{
    Extensible = False;
    Caption = 'POS Store Groups';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR POS Store Group";
    Editable = false;
    CardPageId = "NPR POS Store Group Card";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}