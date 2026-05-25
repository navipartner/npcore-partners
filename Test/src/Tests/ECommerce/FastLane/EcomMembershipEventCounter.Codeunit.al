#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85255 "NPR EcomMbrEventCounter"
{
    // Manual-subscription event counter used by the multi-qty membership tests in EcomMembershipCreationTest.
    // BindSubscription(EventCounter) before the operation under test;
    // UnbindSubscription(EventCounter) and assert counters afterwards.
    EventSubscriberInstance = Manual;

    var
        _Created: Integer;
        _Confirmed: Integer;
        _Renewed: Integer;
        _Extended: Integer;
        _Upgraded: Integer;

    procedure ResetCounters()
    begin
        _Created := 0;
        _Confirmed := 0;
        _Renewed := 0;
        _Extended := 0;
        _Upgraded := 0;
    end;

    procedure GetCreatedCount(): Integer
    begin
        exit(_Created);
    end;

    procedure GetConfirmedCount(): Integer
    begin
        exit(_Confirmed);
    end;

    procedure GetRenewedCount(): Integer
    begin
        exit(_Renewed);
    end;

    procedure GetExtendedCount(): Integer
    begin
        exit(_Extended);
    end;

    procedure GetUpgradedCount(): Integer
    begin
        exit(_Upgraded);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomVirtualItemEvents", 'OnAfterMembershipCreatedBeforeCommit', '', false, false)]
    local procedure OnCreated(var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        _Created += 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomVirtualItemEvents", 'OnAfterMembershipConfirmedBeforeCommit', '', false, false)]
    local procedure OnConfirmed(var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        _Confirmed += 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomVirtualItemEvents", 'OnAfterMembershipRenewedBeforeCommit', '', false, false)]
    local procedure OnRenewed(var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        _Renewed += 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomVirtualItemEvents", 'OnAfterMembershipExtendedBeforeCommit', '', false, false)]
    local procedure OnExtended(var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        _Extended += 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EcomVirtualItemEvents", 'OnAfterMembershipUpgradedBeforeCommit', '', false, false)]
    local procedure OnUpgraded(var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
        _Upgraded += 1;
    end;
}
#endif
