codeunit 6059769 "NPR HashSet of [Integer]"
{
    Access = Internal;

    //A dictionary where only the key is used is equal to a hashset. Boolean dummy value is used as minimal datatype size.
    //Object can be used instead of native list, when O(1) search is needed.

    var
        _dictionary: Dictionary of [Integer, Boolean];

    procedure Add(Value: Integer)
    begin
        _dictionary.Add(Value, true);
    end;

    procedure Contains(Value: Integer): Boolean
    begin
        exit(_dictionary.ContainsKey(Value));
    end;

    procedure Count(): Integer
    begin
        exit(_dictionary.Count);
    end;

    procedure Remove(Value: Integer): Boolean
    begin
        exit(_dictionary.Remove(Value));
    end;

    procedure RemoveAll()
    begin
        Clear(_dictionary);
    end;

}