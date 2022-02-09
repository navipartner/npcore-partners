codeunit 6151428 "NPR Manul Bound Event Sub. Mgt"
{
    // This codeunit is meant for Manually bound Event Subscribers, like for example codeunit 6014430 but not module related like that one.
    // Idea is not to create small codeunits for one event subscriber only. And to save codeunit IDs instead.
    // If this CU become to big, we will split it to "module" based or if you have a need for many subscribers on the start, create module based right away.

    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Setup Management", 'OnBeforeCheckRespCenter2', '', false, false)]
    local procedure UserSetupMgtOnBeforeCheckRespCenter2(DocType: Option; AccRespCenter: Code[10]; UserCode: Code[50]; var IsHandled: Boolean; var Result: Boolean)
    begin
        Result := true;
        IsHandled := true;
    end;
}
