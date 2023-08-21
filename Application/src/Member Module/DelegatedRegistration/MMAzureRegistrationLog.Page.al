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
            }
        }
    }
}