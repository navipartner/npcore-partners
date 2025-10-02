codeunit 6059819 "NPR Stripe Subs Usage Check"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", 'OnInitialize', '', false, false)]
    local procedure HandleOnInitialize()
    begin
        RunCheck();
    end;

    local procedure RunCheck()
    var
        StripeSetup: Record "NPR Stripe Setup";
        POSSession: Codeunit "NPR POS Session";
    begin
        if not StripeSetup.Get() then
            exit;

        if not StripeSetup.IsStripeActive() then
            exit;

        if not TryRunCheck() then begin
            POSSession.SetErrorOnInitialize(true);
            exit;
        end;

        OnAfterRunCheck();
    end;

    [TryFunction]
    local procedure TryRunCheck()
    begin
        CheckStripePOSUser();
    end;

    local procedure CheckStripePOSUser()
    var
        StripePOSUser: Record "NPR Stripe POS User";
        StripePOSUserDoesNotExistErr: Label 'User %1 must be defined as %2.', Comment = '%1 - current User Id, %2 - Stripe POS User table caption';
        StripePOSUserEmptyErr: Label 'The %1 table is empty.', Comment = '%1 - Stripe POS User table caption';
    begin
        if StripePOSUser.IsEmpty() then
            Error(StripePOSUserEmptyErr, StripePOSUser.TableCaption());

        if not StripePOSUser.Get(UserId()) then
            Error(StripePOSUserDoesNotExistErr, UserId, StripePOSUser.TableCaption());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck()
    begin
    end;
}