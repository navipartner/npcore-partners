page 6060143 "NPR MM Membership Notific."
{
    Extensible = False;

    Caption = 'Membership Notification';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Membership Notific.";
    ApplicationArea = NPRRetail;

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
                    ApplicationArea = NPRRetail;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Code"; Rec."Notification Code")
                {

                    ToolTip = 'Specifies the value of the Notification Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Date To Notify"; Rec."Date To Notify")
                {

                    ToolTip = 'Specifies the value of the Date To Notify field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Status"; Rec."Notification Status")
                {

                    ToolTip = 'Specifies the value of the Notification Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Processed At"; Rec."Notification Processed At")
                {

                    ToolTip = 'Specifies the value of the Notification Processed At field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Processed By User"; Rec."Notification Processed By User")
                {

                    ToolTip = 'Specifies the value of the Notification Processed By User field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {

                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked By User"; Rec."Blocked By User")
                {

                    ToolTip = 'Specifies the value of the Blocked By User field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Trigger"; Rec."Notification Trigger")
                {

                    ToolTip = 'Specifies the value of the Notification Trigger field';
                    ApplicationArea = NPRRetail;
                }
                field("Coupon No."; Rec."Coupon No.")
                {
                    ToolTip = 'Specifies the value of the Coupon No. field.';
                    ApplicationArea = All;
                }
                field("Loyalty Point Setup Id"; Rec."Loyalty Point Setup Id")
                {
                    ToolTip = 'Specifies the value of the Loyalty Point Setup Id field.';
                    ApplicationArea = All;
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field.';
                    ApplicationArea = All;
                }
                field("Member Card Entry No."; Rec."Member Card Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Card Entry No. field.';
                    ApplicationArea = All;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Entry No. field.';
                    ApplicationArea = All;
                }
                field("Notification Method Source"; Rec."Notification Method Source")
                {
                    ToolTip = 'Specifies the value of the Notification Method Source field.';
                    ApplicationArea = All;
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {

                    ToolTip = 'Specifies the value of the Template Filter Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Target Member Role"; Rec."Target Member Role")
                {

                    ToolTip = 'Specifies the value of the Target Member Role field';
                    ApplicationArea = NPRRetail;
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {

                    ToolTip = 'Specifies the value of the Include NP Pass field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Method"; Rec."Processing Method")
                {

                    ToolTip = 'Specifies the value of the Processing Method field';
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            action("Send Notifications")
            {
                Caption = 'Send Notifications';
                Image = SendTo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Executes the Send Notifications action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin

                    SendNotification(Rec);
                end;
            }
        }
    }

    local procedure SendNotification(MembershipNotification: Record "NPR MM Membership Notific.")
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin

        MemberNotification.HandleMembershipNotification(MembershipNotification);
        CurrPage.Update(false);
    end;
}

