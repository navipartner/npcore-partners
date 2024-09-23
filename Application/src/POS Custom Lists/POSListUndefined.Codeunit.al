codeunit 6184966 "NPR POS List: Undefined" implements "NPR POS Custom List IHandler"
{
    Access = Internal;

    procedure GetTableNo(): Integer
    begin
        ThrowNoHandlerError();
    end;

    procedure GetColumns(): JsonArray
    begin
        ThrowNoHandlerError();
    end;

    procedure GetSorting(): JsonObject
    begin
        ThrowNoHandlerError();
    end;

    procedure GetMandatoryFilters(): JsonArray
    begin
        ThrowNoHandlerError();
    end;

    procedure CalculateColumnValue(RecRef: RecordRef; FieldID: Text; var CalculatedValue: Variant): Boolean
    begin
    end;

    local procedure ThrowNoHandlerError()
    var
        NoHandlerErr: Label 'No handler registered in the system for the specified POS custom list.';
    begin
        Error(NoHandlerErr);
    end;
}