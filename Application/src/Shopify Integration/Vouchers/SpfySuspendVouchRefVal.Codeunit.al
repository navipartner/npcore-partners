#if not BC17
codeunit 6248555 "NPR Spfy Suspend Vouch.Ref.Val"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnCheckIfShopifyVoucherReferenceNoValidationSuspended', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", OnCheckIfShopifyVoucherReferenceNoValidationSuspended, '', true, false)]
#endif
    local procedure SuspendReferenceNoValidation(var Suspended: Boolean)
    begin
        Suspended := true;
    end;
}
#endif