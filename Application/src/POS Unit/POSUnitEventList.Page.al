page 6150739 "NPR POS Unit Event List"
{
    PageType = List;
    Editable = true;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR POS Unit Event";
    Caption = 'POS Unit Event List';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;

                }
                field("Active Event No."; Rec."Active Event No.")
                {
                    ApplicationArea = All;

                }
            }
        }
    }
}