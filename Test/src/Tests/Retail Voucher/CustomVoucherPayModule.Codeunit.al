codeunit 85554 "NPR Custom Voucher Pay. Module"
{
    // Stands in for an apply payment module from another app. It only subscribes to the OnSupportsPartialPayment event, as a PTE would.
    EventSubscriberInstance = Manual;

    internal procedure ModuleCode(): Code[20]
    begin
        exit('PVI-CUSTOM');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpRv Module Mgt.", OnSupportsPartialPayment, '', false, false)]
    local procedure DeclarePartialPaymentSupport(VoucherType: Record "NPR NpRv Voucher Type"; var SupportsPartialPayment: Boolean)
    begin
        if VoucherType."Apply Payment Module" = ModuleCode() then
            SupportsPartialPayment := true;
    end;
}
