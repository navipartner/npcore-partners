page 6151141 "NPR MM AzureRegistrationLog"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM AzureMemberUpdateLog";
    Caption = 'Azure Registration Log';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(SetupCode; Rec.SetupCode)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Setup Code field.';
                }
                field(DataSubjectId; Rec.DataSubjectId)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Data Subject Id field.';
                }
                field(NotificationAddress; Rec.NotificationAddress)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Notification Address field.';
                }
                field(RequestCreated; Rec.RequestCreated)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Request Created field.';
                }
                field(ResponseReceived; Rec.ResponseReceived)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Response Received field.';
                }
                field(RegistrationMethod; Rec.RegistrationMethod)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Registration Method field.';
                }
                field(Token; Rec.Token)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Token field.';
                }
                field(HaveImage; Rec.HaveImage)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Have Image field.';
                }
                field(ImageLength; Rec.ImageLength)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Image Length field.';
                }
                field(ImageB64Taste; Rec.ImageB64Taste)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Image B64 Taste field.';
                }
                field(ImageResponseMessage; Rec.ImageResponseMessage)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Image Response Message field.';
                }

            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Refresh)
            {
                ApplicationArea = NPRMembershipAdvanced;
                Caption = 'Go to Membership';
                Image = Customer;
                ToolTip = 'Refresh the page.';
                Scope = Repeater;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    MembershipRole: Record "NPR MM Membership Role";
                    Membership: Record "NPR MM Membership";
                begin
                    MembershipRole.SetFilter("GDPR Data Subject Id", '=%1', Rec.DataSubjectId);
                    if (not MembershipRole.FindFirst()) then
                        Error('No membership found for Data Subject Id %1', Rec.DataSubjectId);
                    Membership.Get(MembershipRole."Membership Entry No.");
                    Page.Run(Page::"NPR MM Membership Card", Membership);
                end;
            }
        }
    }
}