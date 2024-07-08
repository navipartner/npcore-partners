codeunit 6184750 "NPR NpRv Voucher Event Handler"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Page, Page::"NPR NpRv Voucher Types", 'OnBeforeEnqueuePageBackgroundTask', '', false, false)]
    local procedure OnBeforeEnqueuePageBackgroundTask(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR NpRv Voucher Types", 'OnBeforeOnPageBackgroundTaskCompleted', '', false, false)]
    local procedure OnBeforeOnPageBackgroundTaskCompleted(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
