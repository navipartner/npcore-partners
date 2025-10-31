page 6184909 "NPR MM Set Auto-Renew Status"
{
    Extensible = false;
    PageType = ConfirmationDialog;
    InstructionalText = 'Please select the auto-renew status of the membership';
    Caption = 'Set Auto-Renew Status';
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field("External Membership No."; _Membership."External Membership No.")
            {
                Caption = 'External Membership No.';
                ToolTip = 'The external membership no.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Editable = false;
            }
            field(Description; _Membership.Description)
            {
                Caption = 'Description';
                ToolTip = 'The description of the membership';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Editable = false;
            }
            field(AutoRenew; _AutoRenewStatus)
            {
                Caption = 'Auto-Renew';
                ToolTip = 'Specify the auto-renew status for the membership';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ValuesAllowed = NO, YES_INTERNAL, YES_EXTERNAL;
            }
            field(NotifyMember; _NotifyMember)
            {
                Caption = 'Notify Member';
                ToolTip = 'Specify if the member needs to be notified about the auto-renew status change';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }

    var
        _Membership: Record "NPR MM Membership";
        _NotifyMember: Boolean;
        _AutoRenewStatus: ENUM "NPR MM MembershipAutoRenew";

    trigger OnOpenPage()
    var
        MemebrshipNotSelectedLbl: Label 'A membership must be selected.';
    begin
        if _Membership."Entry No." = 0 then
            Error(MemebrshipNotSelectedLbl);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::Yes then
            ProcessResponse(_Membership, _NotifyMember, _AutoRenewStatus);
        exit(true);
    end;

    internal procedure SetMembership(Membership: Record "NPR MM Membership")
    begin
        _Membership := Membership;
        _AutoRenewStatus := Membership."Auto-Renew";
    end;

    internal procedure GetMembership(var Membership: Record "NPR MM Membership")
    begin
        Membership := _Membership;
    end;

    local procedure ProcessResponse(var Membership: Record "NPR MM Membership"; CreateMemberNotification: Boolean; AutoRenewStatus: ENUM "NPR MM MembershipAutoRenew")
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipAutoRenewalWithoutPaymentMethodErr: Label 'You must specify a membership default payment method before enabling auto-renewal.';
        Subscription: Record "NPR MM Subscription";
    begin
        case AutoRenewStatus of
            AutoRenewStatus::NO:
                begin
                    MembershipMgtInternal.DisableMembershipAutoRenewal(Membership, CreateMemberNotification, true);
                    MembershipMgtInternal.RegretSubscription(Membership);
                end;
            AutoRenewStatus::YES_EXTERNAL:
                MembershipMgtInternal.EnableMembershipExternalAutoRenewal(Membership, CreateMemberNotification, true);
            AutoRenewStatus::YES_INTERNAL:
                begin
                    if not PaymentMethodMgt.GetMemberPaymentMethod(Membership."Entry No.", MemberPaymentMethod) then
                        Error(MembershipAutoRenewalWithoutPaymentMethodErr);
                    MembershipMgtInternal.EnableMembershipInternalAutoRenewal(Membership, CreateMemberNotification, true);
                end;
        end;

        If GetSubscription(Subscription, Membership."Entry No.") then
            CreateProcessSubscRequest(Subscription, AutoRenewStatus);

        MemberNotification.CreateUpdateWalletNotification_Membership(Membership."Entry No.");
    end;

    local procedure GetSubscription(var Subscription: Record "NPR MM Subscription"; MembershipEntryNo: Integer): Boolean
    begin
        Subscription.Reset();
        Subscription.SetCurrentKey("Membership Entry No.");
        Subscription.SetRange("Membership Entry No.", MembershipEntryNo);
        exit(Subscription.FindFirst());
    end;

    local procedure CreateProcessSubscRequest(Subscription: Record "NPR MM Subscription"; AutoRenewStatus: Enum "NPR MM MembershipAutoRenew")
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        RequestType: Enum "NPR MM Subscr. Request Type";
    begin
        case AutoRenewStatus of
            AutoRenewStatus::NO:
                MembershipMgtInternal.CreateEnableDisableSubsRequest(Subscription, RequestType::Disable);

            AutoRenewStatus::YES_INTERNAL:
                MembershipMgtInternal.CreateEnableDisableSubsRequest(Subscription, RequestType::Enable);
        end;
    end;
}