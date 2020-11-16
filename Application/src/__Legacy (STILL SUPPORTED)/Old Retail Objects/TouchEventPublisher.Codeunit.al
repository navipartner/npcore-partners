codeunit 6014631 "NPR Touch - Event Publisher"
{

    trigger OnRun()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupShowCard(CardPageId: Integer; RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupNew(CardPageId: Integer; var RecRef: RecordRef)
    begin
    end;
}

