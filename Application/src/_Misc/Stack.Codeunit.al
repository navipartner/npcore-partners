codeunit 6150898 "NPR Stack of [Integer]"
{
    var
        _listOfInteger: List of [Integer];

        LabelInvalidOperation: Label 'Invalid operation. %1';
        LabelCannotPop: Label 'Cannot pop a value from an empty stack.';
        LabelCannotPeek: Label 'Cannot peek into an empty stack.';

    procedure Contains(Value: Integer): Boolean;
    begin
        exit(_listOfInteger.Contains(Value));
    end;

    procedure Count(): Integer;
    begin
        exit(_listOfInteger.Count);
    end;

    procedure Push(Value: Integer);
    begin
        _listOfInteger.Add(Value);
    end;

    procedure Pop() Result: Integer;
    begin
        if _listOfInteger.Count = 0 then
            Error(LabelInvalidOperation, LabelCannotPop);

        _listOfInteger.Get(_listOfInteger.Count, Result);
        _listOfInteger.RemoveAt(_listOfInteger.Count);
    end;

    procedure Peek() Result: Integer;
    begin
        if _listOfInteger.Count = 0 then
            Error(LabelInvalidOperation, LabelCannotPeek);

        _listOfInteger.Get(_listOfInteger.Count, Result);
    end;
}
