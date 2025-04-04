codeunit 88106 "NPR BCPT POS Framework: Mock" implements "NPR Framework Interface"
{
    /*
        Use manually bound event subscribers on this mock to validate front end invocations.
    */

    var
        Initialized: boolean;

        ErrorNotInitializedLbl: label 'Mock framework has not been initialized, but an attempt was made to use it.';

    procedure Constructor()
    begin
        Initialized := true;
    end;

    procedure InvokeFrontEndAsync(Request: JsonObject)
    begin
        if not initialized then
            Error(ErrorNotInitializedLbl);

        OnMockFrontEndInvoke(Request);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMockFrontEndInvoke(Request: JsonObject)
    begin
    end;
}