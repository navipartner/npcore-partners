codeunit 6059807 "NPR Stripe Integration"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Service Tier User Mgt.", 'OnShouldCheckIsUsingRegularInvoicing', '', false, false)]
    local procedure HandleOnShouldCheckIsUsingRegularInvoicing(var CheckIsUsingRegularInvoicing: Boolean)
    begin
        CheckIsUsingRegularInvoicing := ShouldStripeBeUsed();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Service Tier User Mgt.", 'OnBeforeTestUserOnLogin', '', false, false)]
    local procedure HandleOnBeforeTestUserOnLogin(UsingRegularInvoicing: Boolean; var Handled: Boolean)
    begin
        UpdateStripeSetup(UsingRegularInvoicing);
        Handled := not UsingRegularInvoicing;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Service Tier User Mgt.", 'OnBeforeTestUserOnPOSSessionInitialize', '', false, false)]
    local procedure HandleOnBeforeTestUserOnPOSSessionInitialize(UsingRegularInvoicing: Boolean; var Handled: Boolean)
    begin
        UpdateStripeSetup(UsingRegularInvoicing);
        Handled := not UsingRegularInvoicing;
    end;

    // following areas are restricting app usage if the app subscription is not active or user is not defined as app user
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', true, true)]
    local procedure CheckSubscriptionStatus_OnOpenRoleCenter()
    begin
        OnCheckSubscriptionStatus(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Stripe Subs Usage Check", 'OnAfterRunCheck', '', false, false)]
    local procedure CheckSubscriptionStatus_OnAfterRunCheck()
    begin
        OnCheckSubscriptionStatus(true);
    end;

    local procedure UpdateStripeSetup(UsingRegularInvoicing: Boolean)
    var
        StripeSetup: Record "NPR Stripe Setup";
        ShouldUpdate: Boolean;
    begin
        StripeSetup.GetSetup();
        ShouldUpdate := true;
        if StripeSetup."Last Updated" <> 0DT then
            ShouldUpdate := (CurrentDateTime() - StripeSetup."Last Updated") > (1 * 60 * 10 * 1000);

        if ShouldUpdate then begin
            StripeSetup.Disabled := UsingRegularInvoicing;
            StripeSetup."Last Updated" := CurrentDateTime();
            StripeSetup.Modify();
        end;
    end;

    internal procedure ShouldStripeBeUsed(): Boolean
    var
        Company: Record Company;
        NPREnvironmentInformation: Record "NPR Environment Information";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        // Following line makes sure that Stripe is used only for app installed in production SaaS environment for companies which are not Cronus or evaluation. 
        // Apps in sandbox do not integrate with Stripe in this case.
        // Stripe can be disabled if Use Regular Invoicing is marked for the tenant in the case system
        // Note: if need to test this in own container comment the code below accordingly
        if not EnvironmentInformation.IsSaaS() then
            exit(false);

        if not EnvironmentInformation.IsProduction() then
            exit(false);

        if CompanyName().ToUpper().Contains('CRONUS') then
            exit(false);

        if Company.Get(CompanyName()) then
            if Company."Evaluation Company" then
                exit(false);

        if NPREnvironmentInformation.Get() then
            if (NPREnvironmentInformation."Environment Type" <> NPREnvironmentInformation."Environment Type"::PROD) or not NPREnvironmentInformation."Environment Verified" then
                exit(false);

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckSubscriptionStatus(ThrowSubscriptionIsNotValidErr: Boolean)
    begin
    end;
}