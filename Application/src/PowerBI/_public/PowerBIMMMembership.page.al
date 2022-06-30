page 6184615 NPRPowerBIMM_Membership
{
    PageType = List;
    Caption = 'PowerBI MM Membership';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR MM Membership";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = All;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = All;
                }
            }
        }
    }
}