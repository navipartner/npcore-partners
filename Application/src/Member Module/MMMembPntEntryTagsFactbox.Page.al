page 6150912 "NPR MM MembPntEntryTagsFactbox"
{
    Caption = 'Membership Point Entry Tags';
    PageType = ListPart;
    SourceTable = "NPR MM Member Point Entry Tag";
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
