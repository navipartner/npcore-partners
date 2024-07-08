page 6059875 "NPR POS Unit Groups"
{
    Extensible = False;
    Caption = 'POS Unit Groups';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/intro/';
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR POS Unit Group";
    Editable = false;
    CardPageId = "NPR POS Unit Group Card";

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