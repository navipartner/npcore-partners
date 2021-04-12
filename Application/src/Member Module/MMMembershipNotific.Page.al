page 6060143 "NPR MM Membership Notific."
{

    Caption = 'Membership Notification';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Membership Notific.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Notification Code"; Rec."Notification Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Code field';
                }
                field("Date To Notify"; Rec."Date To Notify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date To Notify field';
                }
                field("Notification Status"; Rec."Notification Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Status field';
                }
                field("Notification Processed At"; Rec."Notification Processed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Processed At field';
                }
                field("Notification Processed By User"; Rec."Notification Processed By User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Processed By User field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Blocked By User"; Rec."Blocked By User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked By User field';
                }
                field("Notification Trigger"; Rec."Notification Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Trigger field';
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Filter Value field';
                }
                field("Target Member Role"; Rec."Target Member Role")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Member Role field';
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include NP Pass field';
                }
                field("Processing Method"; Rec."Processing Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Method field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the View Members Notified action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Send Notifications action';

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

