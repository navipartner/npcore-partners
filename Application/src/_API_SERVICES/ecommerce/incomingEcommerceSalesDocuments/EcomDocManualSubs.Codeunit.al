#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151123 "NPR Ecom Doc Manual Subs"
{
    // Manually bound event subscribers for incoming ecommerce sales document processing. Every subscriber
    // here is active for every BindSubscription scope of this codeunit, so only add ones safe to run there.

    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeLaunchDuplicateForm', '', false, false)]
    local procedure ContactOnBeforeLaunchDuplicateForm(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
#endif
