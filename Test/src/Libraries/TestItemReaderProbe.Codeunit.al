codeunit 85526 "NPR Test Item Reader Probe"
{
    // Manually bound observer of the NP Retail Item readers that need the item as it was before a modify. Each subscriber
    // records what the reader handed on and stops the reader's own work, so a test can tell whether a code-driven change
    // reached it.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _SalesPriceUpdateRaised: Boolean;
        _VarietyChangeSeen: Boolean;
        _VarietyBefore: Code[10];
        _ItemStatusChangeSeen: Boolean;
        _ItemStatusBefore: Code[10];

    procedure SalesPriceUpdateRaised(): Boolean
    begin
        exit(_SalesPriceUpdateRaised);
    end;

    procedure VarietyChangeSeen(): Boolean
    begin
        exit(_VarietyChangeSeen);
    end;

    procedure VarietyBefore(): Code[10]
    begin
        exit(_VarietyBefore);
    end;

    procedure ItemStatusChangeSeen(): Boolean
    begin
        exit(_ItemStatusChangeSeen);
    end;

    procedure ItemStatusBefore(): Code[10]
    begin
        exit(_ItemStatusBefore);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Price Maint. Mgt.", OnBeforeUpdateSalesPricesForStaff, '', false, false)]
    local procedure OnBeforeUpdateSalesPricesForStaff(var Handled: Boolean)
    begin
        _SalesPriceUpdateRaised := true;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Check", OnBeforeChangeItemVariety, '', false, false)]
    local procedure OnBeforeChangeItemVariety(xItem: Record Item; var IsHandled: Boolean)
    begin
        _VarietyChangeSeen := true;
        _VarietyBefore := xItem."NPR Variety 1";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", OnBeforeHandleEventWithxRec, '', false, false)]
    local procedure OnBeforeHandleEventWithxRec(FunctionName: Code[128]; xVariant: Variant; var IsHandled: Boolean)
    var
        xItem: Record Item;
    begin
        if FunctionName <> 'ITEMSTATUSCHANGED' then
            exit;
        xItem := xVariant;
        _ItemStatusChangeSeen := true;
        _ItemStatusBefore := xItem."NPR Item Status";
        IsHandled := true;
    end;
}
