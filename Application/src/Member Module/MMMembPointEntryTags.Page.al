page 6150913 "NPR MM Memb. Point Entry Tags"
{
    Caption = 'Membership Point Entry Tags';
    PageType = List;
    SourceTable = "NPR MM Member Point Entry Tag";
    InsertAllowed = false;
    DeleteAllowed = true;
    ModifyAllowed = false;
    UsageCategory = None;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member Point Entry No."; Rec."Member Point Entry No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the member point entry number.';
                    Editable = false;
                }
                field("Tag Key"; Rec."Tag Key")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the tag key for the member point entry.';
                }
                field("Tag Value"; Rec."Tag Value")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the tag value for the member point entry.';
                }
            }
        }
    }
}
