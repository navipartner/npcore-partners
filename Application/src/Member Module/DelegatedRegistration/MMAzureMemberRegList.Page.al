page 6151112 "NPR MM AzureMemberRegList"
{
    PageType = List;
    ApplicationArea = NPRMembershipAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR MM AzureMemberRegSetup";
    CardPageId = "NPR MM AzureMemberRegSetup";
    Editable = false;
    Caption = 'Azure Member Registration Setup';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(MemberRegistrationSetupCode; Rec.AzureRegistrationSetupCode)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Enabled field.';
                }
            }
        }
    }
}