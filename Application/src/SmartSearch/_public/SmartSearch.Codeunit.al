codeunit 6014623 "NPR Smart Search"
{
    [IntegrationEvent(false, false)]
    [Obsolete('Smart search is not used anymore.')]
    local procedure OnAfterApplyItemFilter(SearchTerm: Text; var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('Smart search is not used anymore.')]
    local procedure OnAfterApplyCustomerFilter(SearchTerm: Text; var Customer: Record Customer)
    begin
    end;
}
