codeunit 6150898 "NPR Stack of [Integer]"
{
    Access = Internal;
    var
        CannotPeekErr: Label 'Cannot peek into an empty stack.';
        CannotPopErr: Label 'Cannot pop a value from an empty stack.';
        InvalidOperationErr: Label 'Invalid operation. %1', Comment = '%1 = Operation';
        _listOfInteger: List of [Integer];

    procedure Contains(Value: Integer): Boolean;
    begin
        exit(_listOfInteger.Contains(Value));
    end;

    procedure Count(): Integer;
    begin
        exit(_listOfInteger.Count());
    end;

    procedure Push(Value: Integer);
    begin
        _listOfInteger.Add(Value);
    end;

    procedure Pop() Result: Integer;
    begin
        if _listOfInteger.Count() = 0 then
            Error(InvalidOperationErr, CannotPopErr);

        _listOfInteger.Get(_listOfInteger.Count, Result);
        _listOfInteger.RemoveAt(_listOfInteger.Count());
    end;

    procedure Peek() Result: Integer;
    begin
        if _listOfInteger.Count() = 0 then
            Error(InvalidOperationErr, CannotPeekErr);

        _listOfInteger.Get(_listOfInteger.Count, Result);
    end;
}
