codeunit 85396 "NPR Spfy TL Pickup Event Sub"
{
    // Records what OnBeforeSendOrderReadyForPickup was handed, and can refuse the send like a customer subscriber would.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _DocumentNo: Code[20];
        _ShopifyStoreCode: Code[20];
        _ShopifyOrderId: Text;
        _RaiseError: Boolean;
        _Raised: Boolean;
        _SubscriberRefusedErr: Label 'Pickup subscriber refused the send.', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnBeforeSendOrderReadyForPickup', '', false, false)]
    local procedure RecordPickupSend(NpCsDocument: Record "NPR NpCs Document"; ShopifyOrderId: Text; ShopifyStoreCode: Code[20])
    begin
        _Raised := true;
        _DocumentNo := NpCsDocument."Document No.";
        _ShopifyOrderId := ShopifyOrderId;
        _ShopifyStoreCode := ShopifyStoreCode;
        if _RaiseError then
            Error(_SubscriberRefusedErr);
    end;

    internal procedure SetRaiseError(NewRaiseError: Boolean)
    begin
        _RaiseError := NewRaiseError;
    end;

    internal procedure Raised(): Boolean
    begin
        exit(_Raised);
    end;

    internal procedure DocumentNo(): Code[20]
    begin
        exit(_DocumentNo);
    end;

    internal procedure RaisedShopifyOrderId(): Text
    begin
        exit(_ShopifyOrderId);
    end;

    internal procedure RaisedShopifyStoreCode(): Code[20]
    begin
        exit(_ShopifyStoreCode);
    end;

    internal procedure RefusalText(): Text
    begin
        exit(_SubscriberRefusedErr);
    end;
}
