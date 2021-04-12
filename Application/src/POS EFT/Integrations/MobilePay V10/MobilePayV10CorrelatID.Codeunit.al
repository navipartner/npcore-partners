codeunit 6014509 "NPR MobilePayV10 Correlat. ID"
{
    SingleInstance = true;

    var
        correlationId: Guid;

    internal procedure GenerateNewID()
    begin
        correlationId := CreateGuid();
    end;

    internal procedure GetCurrentID(): Guid
    begin
        if IsNullGuid(correlationId) then
            GenerateNewID();

        exit(correlationId);
    end;
}