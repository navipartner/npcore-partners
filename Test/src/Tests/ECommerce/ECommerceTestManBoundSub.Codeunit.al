codeunit 85232 "NPR ECommerceTestManBoundSub"
{
    EventSubscriberInstance = Manual;
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeUpdateSellToEmail', '', false, false)]
    local procedure SalesHeaderOnBeforeUpdateSellToEmail(var SalesHeader: Record "Sales Header"; Contact: Record Contact; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        IsHandled := true;
        SalesHeader.Validate("Sell-to E-Mail", Contact."E-Mail");
    end;
#endif

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeConfirmCloseUnposted', '', false, false)]
    local procedure PurchaseHeaderOnBeforeConfirmCloseUnposted(var Result: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := true;
        Result := true;
    end;
#endif

}
