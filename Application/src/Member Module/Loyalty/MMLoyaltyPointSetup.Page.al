page 6060106 "NPR MM Loyalty Point Setup"
{
    Extensible = False;

    AutoSplitKey = true;
    Caption = 'Loyalty Points Setup';
    ContextSensitiveHelpPage = 'docs/entertainment/loyalty/intro/';
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR MM Loyalty Point Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon Type Code"; Rec."Coupon Type Code")
                {
                    ToolTip = 'Specifies the value of the Coupon Type Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Value Assignment"; Rec."Value Assignment")
                {
                    ToolTip = 'Specifies the value of the Value Assignment field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Points Threshold"; Rec."Points Threshold")
                {
                    ToolTip = 'Specifies the value of the Points Threshold field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Amount LCY"; Rec."Amount LCY")
                {
                    ToolTip = 'Specifies the value of the Amount LCY field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Point Rate"; Rec."Point Rate")
                {
                    ToolTip = 'Specifies the value of the Point Rate field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Minimum Coupon Amount"; Rec."Minimum Coupon Amount")
                {
                    ToolTip = 'Specifies the value of the Minimum Coupon Amount field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Consume Available Points"; Rec."Consume Available Points")
                {
                    ToolTip = 'Specifies the value of the Consume Available Points field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Code"; Rec."Notification Code")
                {
                    ToolTip = 'Specifies the value of the Notification Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

            }
        }
    }

    actions
    {
    }
}

