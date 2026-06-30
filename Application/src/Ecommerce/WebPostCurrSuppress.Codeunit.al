codeunit 6151137 "NPR Web Post Curr. Suppress"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnValidatePostingDateOnBeforeCheckNeedUpdateCurrencyFactor', '', false, false)]
    local procedure SuppressCurrencyFactorUpdate(var SalesHeader: Record "Sales Header"; var IsConfirmed: Boolean; var NeedUpdateCurrencyFactor: Boolean)
    begin
        NeedUpdateCurrencyFactor := false;
    end;
}
