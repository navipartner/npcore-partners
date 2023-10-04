page 6151271 "NPR MM Loyalty Sales Channels"
{
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    Caption = 'Sales Channels';
    Editable = true;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR MM Loyalty Sales Channel";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
            }
        }
    }
}
