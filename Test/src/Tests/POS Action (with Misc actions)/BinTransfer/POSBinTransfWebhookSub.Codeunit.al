codeunit 85274 "NPR POS Bin Transf. WebhookSub"
{
    EventSubscriberInstance = Manual;

    var
        _LastPosUnit: Code[10];
        _TransferredInCount: Integer;
        _TransferredOutCount: Integer;

    procedure Reset()
    begin
        _TransferredInCount := 0;
        _TransferredOutCount := 0;
        _LastPosUnit := '';
    end;

    procedure TransferredOutCount(): Integer
    begin
        exit(_TransferredOutCount);
    end;

    procedure TransferredInCount(): Integer
    begin
        exit(_TransferredInCount);
    end;

    procedure LastPosUnit(): Code[10]
    begin
        exit(_LastPosUnit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Webhooks", OnAfterPOSBinTransferredOutWebhook, '', false, false)]
    local procedure OnAfterPOSBinTransferredOutWebhook(workshiftCheckpointId: Guid; posUnit: Code[10])
    begin
        _TransferredOutCount += 1;
        _LastPosUnit := posUnit;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Webhooks", OnAfterPOSBinTransferredInWebhook, '', false, false)]
    local procedure OnAfterPOSBinTransferredInWebhook(workshiftCheckpointId: Guid; posUnit: Code[10])
    begin
        _TransferredInCount += 1;
        _LastPosUnit := posUnit;
    end;
}
