codeunit 88108 "NPR BCPT Validate Voucher Subs"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Valid.: Def.", 'OnBeforeCheckVoucher', '', false, false)]
    local procedure HandleOnBeforeCheckVoucher(var Voucher: Record "NPR NpRv Voucher"; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}