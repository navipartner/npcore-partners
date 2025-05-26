codeunit 85231 "NPR OIOUBLUoMTestDisabler"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR OIOUBL Unit Of Measure Mgt", 'OnBeforeTestUoMCode', '', false, false)]
    local procedure OnBeforeTestUoMCode(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
