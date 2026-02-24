page 6248221 "NPR MM Subscription List"
{
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "NPR MM Subscription";
    SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Subscription List';
    Extensible = false;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the value of the External Membership No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies whether the subscription is blocked.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Started At"; Rec."Started At")
                {
                    ToolTip = 'Specifies when the subscription started.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ToolTip = 'Specifies the current period start date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ToolTip = 'Specifies the current period end date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Committed Until"; Rec."Committed Until")
                {
                    ToolTip = 'Specifies the commitment end date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew"; Rec."Auto-Renew")
                {
                    ToolTip = 'Specifies the auto-renewal setting.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Postpone Renewal Attempt Until"; Rec."Postpone Renewal Attempt Until")
                {
                    ToolTip = 'Specifies when the next renewal attempt is scheduled.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Outst. Subscr. Requests Exist"; Rec."Outst. Subscr. Requests Exist")
                {
                    ToolTip = 'Specifies whether outstanding subscription requests exist.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
        area(factboxes)
        {
            part(SubscriptionFactBox; "NPR MM Subscription FactBox")
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Details';
                SubPageLink = "Entry No." = field("Entry No.");
                Visible = true;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Membership)
            {
                Caption = 'Membership';
                ToolTip = 'Opens membership card.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = CustomerContact;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    Membership: Record "NPR MM Membership";
                begin
                    if Membership.Get(Rec."Membership Entry No.") then
                        Page.Run(Page::"NPR MM Membership Card", Membership);
                end;
            }
            action(SubscriptionRequests)
            {
                Caption = 'Subscription Requests';
                ToolTip = 'Opens subscription requests for selected subscription.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = History;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR MM Subscr. Requests";
                RunPageLink = "Subscription Entry No." = field("Entry No.");
            }
            action(PaymentMethods)
            {
                Caption = 'Payment Methods';
                ToolTip = 'Opens payment methods for selected membership.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = PaymentJournal;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    Membership: Record "NPR MM Membership";
                begin
                    if Membership.Get(Rec."Membership Entry No.") then
                        Membership.ShowPaymentMethods();
                end;
            }
            action(UserAccount)
            {
                Caption = 'User Account';
                ToolTip = 'Opens the user account for selected subscription.';
                Image = User;
                Scope = Repeater;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    Member: Record "NPR MM Member";
                    UserAccount: Record "NPR UserAccount";
                    MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
                    NoAdminMemberErr: Label 'No admin member found for this membership.';
                    NoUserAccountErr: Label 'No user account found for this member.';
                begin
                    if not MembershipMgtInternal.GetFirstAdminMember(Rec."Membership Entry No.", Member) then
                        Error(NoAdminMemberErr);
                    if not MembershipMgtInternal.GetUserAccountFromMember(Member, UserAccount) then
                        Error(NoUserAccountErr);
                    Page.Run(Page::"NPR UserAccounts", UserAccount);
                end;
            }
        }
    }
}
