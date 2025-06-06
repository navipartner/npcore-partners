page 6184834 "NPR MM Subscription Details"
{
    Extensible = false;
    Caption = 'Subscription Details';
    PageType = List;
    SourceTable = "NPR MM Subscription";
    UsageCategory = None;
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ToolTip = 'Specifies the value of the Membership Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Ledger Entry No."; Rec."Membership Ledger Entry No.")
                {
                    ToolTip = 'Specifies the value of the Membership Ledger Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ToolTip = 'Specifies the value of the Valid From Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {
                    ToolTip = 'Specifies the value of the Valid Until Date field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Committed Until"; Rec."Committed Until")
                {
                    ToolTip = 'Specifies the date until which the subscription is committed.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Auto-Renew"; Rec."Auto-Renew")
                {
                    ToolTip = 'Specifies the value of the Auto-Renew field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Postpone Renewal Attempt Until"; Rec."Postpone Renewal Attempt Until")
                {
                    ToolTip = 'Specifies the value of the Postpone Renewal Attempt Until field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Outst. Subscr. Requests Exist"; Rec."Outst. Subscr. Requests Exist")
                {
                    ToolTip = 'Specifies the value of the Outst. Subscr. Requests Exist field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies a unique entry number, assigned by the system to this record according to an automatically maintained number series.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(SubscriptionRequests)
            {
                Caption = 'Requests';
                ToolTip = 'Shows the renewal requests generated for this subscription.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = History;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                RunObject = page "NPR MM Subscr. Requests";
                RunPageLink = "Subscription Entry No." = field("Entry No.");
            }
        }

        area(Processing)
        {
            action(CreateSubscriptionRequest)
            {
                Caption = 'Create Subscription Request';
                ToolTip = 'Creates a new subscription request.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = NewTransferOrder;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                var
                    SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
                begin
                    SubscriptionMgtImpl.CreateNewSubscriptionRequestWithConfirmation(Rec);
                end;
            }

            action(UnblockSubscription)
            {
                Caption = 'Unblock Subscription';
                ToolTip = 'Unblock the selected subscription';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Approval;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                var
                    SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
                begin
                    SubscriptionMgtImpl.UnblockSubscriptionWithConfirmation(Rec);
                end;
            }

            action(BlockSubscription)
            {
                Caption = 'Block Subscription';
                ToolTip = 'Block the selected subscription';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Cancel;
#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                var
                    SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
                begin
                    SubscriptionMgtImpl.BlockSubscriptionWithConfirmation(Rec);
                end;
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            actionref(SubscriptionRequests_Promoted; SubscriptionRequests) { }
            actionref(NewSubscriptionRequest_Promoted; CreateSubscriptionRequest) { }
            actionref(UnblockSubscription_Promoted; UnblockSubscription) { }
            actionref(BlockSubscription_Promoted; BlockSubscription) { }
        }
#endif
    }
}