page 6150739 "NPR POS Unit Event List"
{
    PageType = List;
    Editable = true;

    UsageCategory = Lists;
    SourceTable = "NPR POS Unit Event";
    Caption = 'POS Unit Event List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    Editable = false;
                    ApplicationArea = NPRRetail;
                }
                field("Active Event No."; Rec."Active Event No.")
                {

                    ToolTip = 'Specifies the value of the Active Event No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}