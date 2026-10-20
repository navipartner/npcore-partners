codeunit 85498 "NPR Mock Cust. Metric Sender" implements "NPR ICustomer Metric Sender"
{
    Access = Internal;

    var
        _EventIds: List of [Guid];
        _EventTypes: List of [Integer];
        _Quantities: List of [Decimal];
        _Metadata: List of [Text];
        _FailWith: Text;

    procedure SetFailure(ErrorText: Text)
    begin
        _FailWith := ErrorText;
    end;

    procedure EventCount(): Integer
    begin
        exit(_EventIds.Count());
    end;

    procedure GetEvent(Index: Integer; var EventId: Guid; var EventType: Enum "NPR Billing Event Type"; var Quantity: Decimal; var Metadata: JsonObject)
    begin
        EventId := _EventIds.Get(Index);
        EventType := Enum::"NPR Billing Event Type".FromInteger(_EventTypes.Get(Index));
        Quantity := _Quantities.Get(Index);
        Metadata.ReadFrom(_Metadata.Get(Index));
    end;

    procedure EventCountFor(EventId: Guid) Count: Integer
    var
        SentEventId: Guid;
    begin
        foreach SentEventId in _EventIds do
            if SentEventId = EventId then
                Count += 1;
    end;

    procedure GetEventFor(EventId: Guid; var EventType: Enum "NPR Billing Event Type"; var Quantity: Decimal; var Metadata: JsonObject)
    var
        SentEventId: Guid;
    begin
        GetEvent(_EventIds.IndexOf(EventId), SentEventId, EventType, Quantity, Metadata);
    end;

    procedure RegisterEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Quantity: Decimal; Metadata: JsonObject)
    var
        MetadataText: Text;
    begin
        if _FailWith <> '' then
            Error(_FailWith);
        Metadata.WriteTo(MetadataText);
        _EventIds.Add(EventId);
        _EventTypes.Add(EventType.AsInteger());
        _Quantities.Add(Quantity);
        _Metadata.Add(MetadataText);
    end;
}
