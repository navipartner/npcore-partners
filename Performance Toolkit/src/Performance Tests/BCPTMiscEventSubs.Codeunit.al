codeunit 88109 "NPR BCPT Misc. Event Subs"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, database::"Sales Header", 'OnBeforeCouldDimensionsBeKept', '', false, false)]
    local procedure HandleOnBeforeCouldDimensionsBeKept(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
        Result := false;
        IsHandled := true;
    end;
}