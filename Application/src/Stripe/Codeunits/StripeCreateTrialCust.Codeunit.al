codeunit 6059804 "NPR Stripe Create Trial Cust."
{
    Access = Internal;

    internal procedure CreateTrialCustomer(var StripeCustomer: Record "NPR Stripe Customer"): Boolean
    begin
        exit(DoCreateTrialCustomer(StripeCustomer));
    end;

    local procedure DoCreateTrialCustomer(var StripeCustomer: Record "NPR Stripe Customer"): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        GetCompanyInformation(CompanyInformation);
        InitStripeCustomer(StripeCustomer, CompanyInformation);
        exit(StripeCustomer.CreateCustomer());
    end;

    local procedure GetCompanyInformation(var CompanyInformation: Record "Company Information")
    begin
        if not CompanyInformation.Get() then
            CompanyInformation.Init();
    end;

    local procedure InitStripeCustomer(var StripeCustomer: Record "NPR Stripe Customer"; CompanyInformation: Record "Company Information")
    begin
        StripeCustomer.Init();
        StripeCustomer.Name := CompanyInformation.Name;
        StripeCustomer.Address := CompanyInformation.Address;
        StripeCustomer."Address 2" := CompanyInformation."Address 2";
        StripeCustomer.City := CompanyInformation.City;
        StripeCustomer."Phone No." := CompanyInformation."Phone No.";
        StripeCustomer."Country/Region Code" := CompanyInformation."Country/Region Code";
        StripeCustomer."VAT Registration No." := CompanyInformation."VAT Registration No.";
        StripeCustomer."Post Code" := CompanyInformation."Post Code";
        StripeCustomer.County := CompanyInformation.County;
        StripeCustomer."E-Mail" := CompanyInformation."E-Mail";
    end;
}