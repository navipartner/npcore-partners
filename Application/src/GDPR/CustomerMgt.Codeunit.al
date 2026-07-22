codeunit 6151250 "NPR Customer Mgt."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Membership Events", 'OnBeforeAnonymizeMembership', '', false, false)]
    local procedure "NPR MM Membership Events_OnBeforeAnonymizeMembership"(var Membership: Record "NPR MM Membership")
    var
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
    begin
        if not CustomerGDPRV2.IsFeatureEnabled() then
            exit;

        if Membership."Customer No." = '' then
            exit;

        CheckCustomerLastActivity(Membership."Customer No.");
    end;

    local procedure CheckCustomerLastActivity(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        ActivityRefresh: Codeunit "NPR Cust. Activity Refresh";
        CustomerNotExistErr: Label 'Customer %1 does not exist.', Comment = '%1 Customer number';
        CustomerNotDueErr: Label 'Customer %1 not yet due to be anonymized (estimated cleanup date: %2).', Comment = '%1 Customer number, %2 Estimated Cleanup Date';
    begin
        if not Customer.Get(CustomerNo) then
            Error(CustomerNotExistErr, CustomerNo);

        ActivityRefresh.RefreshSingleCustomer(Customer);

        if (Customer."NPR Estimated Cleanup Date" <> 0D) and (Customer."NPR Estimated Cleanup Date" > Today()) then
            Error(CustomerNotDueErr, CustomerNo, Customer."NPR Estimated Cleanup Date");
    end;
}
