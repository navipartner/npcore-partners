page 6060143 "NPR MM Membership Notific."
{
    Extensible = False;

    Caption = 'Membership Notification';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Membership Notific.";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Code"; Rec."Notification Code")
                {

                    ToolTip = 'Specifies the value of the Notification Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Date To Notify"; Rec."Date To Notify")
                {

                    ToolTip = 'Specifies the value of the Date To Notify field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Status"; Rec."Notification Status")
                {

                    ToolTip = 'Specifies the value of the Notification Status field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Processed At"; Rec."Notification Processed At")
                {

                    ToolTip = 'Specifies the value of the Notification Processed At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Processed By User"; Rec."Notification Processed By User")
                {

                    ToolTip = 'Specifies the value of the Notification Processed By User field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked By User"; Rec."Blocked By User")
                {

                    ToolTip = 'Specifies the value of the Blocked By User field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Trigger"; Rec."Notification Trigger")
                {

                    ToolTip = 'Specifies the value of the Notification Trigger field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Coupon No."; Rec."Coupon No.")
                {
                    ToolTip = 'Specifies the value of the Coupon No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Loyalty Point Setup Id"; Rec."Loyalty Point Setup Id")
                {
                    ToolTip = 'Specifies the value of the Loyalty Point Setup Id field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Card Entry No."; Rec."Member Card Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Card Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Method Source"; Rec."Notification Method Source")
                {
                    ToolTip = 'Specifies the value of the Notification Method Source field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {
                    ToolTip = 'Specifies the value of the Template Filter Value field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Target Member Role"; Rec."Target Member Role")
                {
                    ToolTip = 'Specifies the value of the Target Member Role field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {
                    ToolTip = 'Specifies the value of the Include NP Pass field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Processing Method"; Rec."Processing Method")
                {
                    ToolTip = 'Specifies the value of the Processing Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(MemberRegistrationSetupCode; Rec.AzureRegistrationSetupCode)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Profile to determine how to manage user delegated members.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("View Members Notified")
            {
                Caption = 'View Members Notified';
                Image = InteractionLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Member Notific. Entry";
                RunPageLink = "Notification Entry No." = FIELD("Entry No.");

                ToolTip = 'Executes the View Members Notified action';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action(ViewSmsSetup)
            {
                Caption = 'View SMS Log';
                Image = ServiceSetup;
                Promoted = false;
                RunObject = Page "NPR SMS Log";

                ToolTip = 'Navigates to View SMS Log';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
        area(processing)
        {
            action("Send Notifications")
            {
                Caption = 'Send Notification';
                Image = SendToMultiple;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Executes the Send Notification action for selected record.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    SendNotification(Rec);
                end;
            }
            action(SendSms)
            {
                Caption = 'Send Pending SMS''s Now';
                Image = SendToMultiple;
                Promoted = false;

                ToolTip = 'Executes the Send SMS action for all pending SMS.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                begin
                    ForceSendPendingSms();
                end;
            }
        }
    }

    local procedure ForceSendPendingSms()
    var
        MessageJOBHandler: Codeunit "NPR Send SMS Job Handler";
    begin
        MessageJOBHandler.Run();
    end;

    local procedure SendNotification(MembershipNotification: Record "NPR MM Membership Notific.")
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin

        MemberNotification.HandleMembershipNotification(MembershipNotification);
        CurrPage.Update(false);
    end;
}

