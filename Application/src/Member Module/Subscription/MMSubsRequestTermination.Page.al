page 6185077 "NPR MM SubsRequestTermination"
{
    Extensible = false;
    PageType = ConfirmationDialog;
    InstructionalText = 'Please fill out the info to terminate subscription.';
    Caption = 'Request Termination';
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
            field(TerminationDate; _TerminationDate)
            {
                Caption = 'Termination Date';
                ToolTip = 'The date to terminate the subscription';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            field(TerminationReason; _TerminationReason)
            {
                Caption = 'Termination Reason';
                ToolTip = 'The date to terminate the subscription';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }

    var
        _Membership: Record "NPR MM Membership";
        _TerminationDate: Date;
        _TerminationReason: Enum "NPR MM Subs Termination Reason";

    trigger OnOpenPage()
    var
        MemebrshipNotSelectedLbl: Label 'A membership must be selected.';
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin
        if _Membership."Entry No." = 0 then
            Error(MemebrshipNotSelectedLbl);

        if (not SubscriptionMgtImpl.GetEarliestTerminationDate(_Membership, _TerminationDate)) then
            Clear(_TerminationDate);

        _TerminationReason := _TerminationReason::CUSTOMER_INITIATED;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::Yes then
            ProcessResponse(_Membership, _TerminationDate, _TerminationReason);
        exit(true);
    end;

    internal procedure SetMembership(Membership: Record "NPR MM Membership")
    begin
        _Membership := Membership;
    end;

    local procedure ProcessResponse(var Membership: Record "NPR MM Membership"; RequestedDate: Date; Reason: Enum "NPR MM Subs Termination Reason")
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin
        SubscriptionMgtImpl.RequestTermination(Membership, RequestedDate, Reason);
    end;
}