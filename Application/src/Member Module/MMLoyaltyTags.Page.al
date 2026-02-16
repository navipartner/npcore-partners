page 6150911 "NPR MM Loyalty Tags"
{
    PageType = List;
    Caption = 'Loyalty Tags';
    SourceTable = "NPR MM Loyalty Tag";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    UsageCategory = Lists;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Key"; Rec."Key")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the key of the loyalty tag.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the description of the loyalty tag.';
                }
            }
        }
    }
}
