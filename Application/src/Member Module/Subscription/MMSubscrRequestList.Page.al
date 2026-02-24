page 6150942 "NPR MM Subscr. Request List"
{
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "NPR MM Subscr. Request";
    SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Subscription Request List';
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
                field("External Membership No."; ExternalMembershipNo)
                {
                    Caption = 'External Membership No.';
                    ToolTip = 'Specifies the value of the External Membership No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Type; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    BlankZero = true;
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ToolTip = 'Specifies the value of the Processing Status field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("New Valid From Date"; Rec."New Valid From Date")
                {
                    ToolTip = 'Specifies the value of the New Valid From Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("New Valid Until Date"; Rec."New Valid Until Date")
                {
                    ToolTip = 'Specifies the value of the New Valid Until Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Terminate At"; Rec."Terminate At")
                {
                    ToolTip = 'Specifies the value of the Terminate At field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Termination Reason"; Rec."Termination Reason")
                {
                    ToolTip = 'Specifies the value of the Termination Reason field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies whether the subscription request has been posted.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Document No."; Rec."Posting Document No.")
                {
                    ToolTip = 'Specifies the document number used by the posting process.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Reversed; Rec.Reversed)
                {
                    ToolTip = 'Specifies the value of the Reversed field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Process Try Count"; Rec."Process Try Count")
                {
                    ToolTip = 'Specifies the value of the Process Try Count field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Subscription Entry No."; Rec."Subscription Entry No.")
                {
                    ToolTip = 'Specifies the value of the Subscription Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
        area(factboxes)
        {
            part(SubscrRequestFactBox; "NPR MM Subscr. Request FactBox")
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
                    Subscription: Record "NPR MM Subscription";
                    Membership: Record "NPR MM Membership";
                begin
                    if Subscription.Get(Rec."Subscription Entry No.") then
                        if Membership.Get(Subscription."Membership Entry No.") then
                            Page.Run(Page::"NPR MM Membership Card", Membership);
                end;
            }
            action(Subscription)
            {
                Caption = 'Subscription';
                ToolTip = 'Opens subscription details.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = DueDate;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    Subscription: Record "NPR MM Subscription";
                begin
                    Subscription.SetRange("Entry No.", Rec."Subscription Entry No.");
                    Page.Run(Page::"NPR MM Subscription Details", Subscription);
                end;
            }
            action(PaymentRequests)
            {
                Caption = 'Payment Requests';
                ToolTip = 'Opens payment requests for this subscription request.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Payment;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
                    SubscrPaymentRequest_Marked: Record "NPR MM Subscr. Payment Request";
                begin
                    SubscrPaymentRequest.SetCurrentKey("Subscr. Request Entry No.");
                    SubscrPaymentRequest.SetLoadFields("Subscr. Request Entry No.", Reversed, "Reversed by Entry No.");
                    SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", Rec."Entry No.");
                    if SubscrPaymentRequest.FindSet() then
                        repeat
                            SubscrPaymentRequest_Marked := SubscrPaymentRequest;
                            SubscrPaymentRequest_Marked.Mark(true);
                            SubscrPaymentRequest.MarkReversed(SubscrPaymentRequest_Marked);
                        until SubscrPaymentRequest.Next() = 0;

                    SubscrPaymentRequest_Marked.MarkedOnly(true);
                    Page.Run(Page::"NPR MM Subscr.Payment Requests", SubscrPaymentRequest_Marked);
                end;
            }
            action(UserAccount)
            {
                Caption = 'User Account';
                ToolTip = 'Opens the user account for this subscription request.';
                Image = User;
                Scope = Repeater;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
                    Subscription: Record "NPR MM Subscription";
                    Member: Record "NPR MM Member";
                    UserAccount: Record "NPR UserAccount";
                    NoSubscriptionErr: Label 'No subscription found for this request.';
                    NoAdminMemberErr: Label 'No admin member found for this membership.';
                    NoUserAccountErr: Label 'No user account found for this member.';
                begin
                    if not Subscription.Get(Rec."Subscription Entry No.") then
                        Error(NoSubscriptionErr);
                    if not MembershipMgtInternal.GetFirstAdminMember(Subscription."Membership Entry No.", Member) then
                        Error(NoAdminMemberErr);
                    if not MembershipMgtInternal.GetUserAccountFromMember(Member, UserAccount) then
                        Error(NoUserAccountErr);
                    Page.Run(Page::"NPR UserAccounts", UserAccount);
                end;
            }
            action(LogEntries)
            {
                Caption = 'Log Entries';
                ToolTip = 'Shows the log entries for the current subscription request.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    SubsPayReqLogUtils: Codeunit "NPR MM Subs Req Log Utils";
                begin
                    SubsPayReqLogUtils.OpenLogEntries(Rec);
                end;
            }
            action(FindEntries)
            {
                Caption = 'Find Entries...';
                ToolTip = 'Find the posted entries for current subscription request.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Posting Document No.");
                    Navigate.Run();
                end;
            }
        }
    }

    var
        ExternalMembershipNo: Code[20];

    trigger OnAfterGetRecord()
    var
        SubscriptionRec: Record "NPR MM Subscription";
        MembershipRec: Record "NPR MM Membership";
    begin
        ExternalMembershipNo := '';
        SubscriptionRec.SetLoadFields("Membership Entry No.");
        if SubscriptionRec.Get(Rec."Subscription Entry No.") then begin
            MembershipRec.SetLoadFields("External Membership No.");
            if MembershipRec.Get(SubscriptionRec."Membership Entry No.") then
                ExternalMembershipNo := MembershipRec."External Membership No.";
        end;
    end;
}
