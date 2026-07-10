codeunit 6151262 "NPR HashSet of [BigInteger]"
{
    Access = Internal;

    //A dictionary where only the key is used is equal to a hashset. Boolean dummy value is used as minimal datatype size.
    //Object can be used instead of native list, when O(1) search is needed.

    var
        _dictionary: Dictionary of [BigInteger, Boolean];

    procedure Add(Value: BigInteger): Boolean
    begin
        exit(_dictionary.Add(Value, true));
    end;

    procedure Contains(Value: BigInteger): Boolean
    begin
        exit(_dictionary.ContainsKey(Value));
    end;

    procedure Count(): Integer
    begin
        exit(_dictionary.Count);
    end;

    procedure Remove(Value: BigInteger): Boolean
    begin
        exit(_dictionary.Remove(Value));
    end;

    procedure RemoveAll()
    begin
        Clear(_dictionary);
    end;

    procedure Values(): List of [BigInteger]
    begin
        exit(_dictionary.Keys());
    end;
}
