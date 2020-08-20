codeunit 6150751 "Framework: Dragonglass" implements "Framework Interface"
{
    var
        Framework: controladdin Dragonglass;
        Initialized: boolean;

        ErrorNotInitialized: label 'Dragonglass framework has not been initialized, but an attempt was made to use it.';

    procedure Constructor(AddIn: controladdin Dragonglass)
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
