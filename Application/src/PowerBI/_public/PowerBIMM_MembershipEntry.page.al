page 6184614 NPRPowerBIMM_MembershipEntry
{
    PageType = List;
    Caption = 'PowerBI MM Membership Entry';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "NPR MM Membership Entry";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Context; Rec.Context)
                {
                    ToolTip = 'Specifies the value of the Context field';
                    ApplicationArea = All;
                }
                field("Created At"; Rec."Created At")
                {
                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = All;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = All;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                    ApplicationArea = All;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ToolTip = 'Specifies the value of the Valid From Date field';
                    ApplicationArea = All;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ToolTip = 'Specifies the value of the Valid Until Date field';
                    ApplicationArea = All;
                }
            }
        }
    }
}