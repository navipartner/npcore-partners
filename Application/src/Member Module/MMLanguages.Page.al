page 6184605 "NPR MM Languages"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Language";
    Caption = 'Member Communication Languages';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(LanguageCode; Rec.LanguageCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Language Code field.';
                }
                field(LanguageName; Rec.LanguageName)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Name field.';
                }
            }
        }
    }
}