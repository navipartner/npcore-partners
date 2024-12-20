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
                OptionCaption = 'No,Yes (Internal),Yes (External)';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
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
        _AutoRenewStatus: Option NO,YES_INTERNAL,YES_EXTERNAL;

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

    local procedure ProcessResponse(var Membership: Record "NPR MM Membership"; CreateMemberNotification: Boolean; AutoRenewStatus: Option NO,YES_INTERNAL,YES_EXTERNAL)
    var
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
    begin
        case AutoRenewStatus of
            AutoRenewStatus::NO:
                MembershipMgtInternal.DisableMembershipAutoRenewal(Membership, CreateMemberNotification, true);
            AutoRenewStatus::YES_EXTERNAL:
                MembershipMgtInternal.EnableMembershipExternalAutoRenewal(Membership, CreateMemberNotification, true);
            AutoRenewStatus::YES_INTERNAL:
                MembershipMgtInternal.EnableMembershipInternalAutoRenewal(Membership, CreateMemberNotification, true);
        end;
    end;
}