codeunit 6014623 "NPR Smart Search"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    [IntegrationEvent(false, false)]
    [Obsolete('Smart search is not used anymore.', '2023-06-28')]
    local procedure OnAfterApplyItemFilter(SearchTerm: Text; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Smart search is not used anymore.', '2023-06-28')]
    local procedure OnAfterApplyCustomerFilter(SearchTerm: Text; var Customer: Record Customer)
    begin
    end;
}
