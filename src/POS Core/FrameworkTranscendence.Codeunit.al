codeunit 6150750 "NPR Framework: Transcendence" implements "NPR Framework Interface"
{
    var
        Framework: controladdin "NPR Transcendence";
        Initialized: boolean;

        ErrorNotInitialized: label 'Transcendence framework has not been initialized, but an attempt was made to use it.';

    procedure Constructor(AddIn: controladdin "NPR Transcendence")
    begin
        Framework := AddIn;
        Initialized := true;
    end;

    procedure InvokeFrontEndAsync(Request: JsonObject)
    begin
        if not initialized then
            Error(ErrorNotInitialized);

        Framework.InvokeFrontEndAsync(Request);
    end;
}
