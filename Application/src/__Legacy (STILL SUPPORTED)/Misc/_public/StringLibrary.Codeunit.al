codeunit 6014465 "NPR String Library"
{
    Access = Public;

    var
        _String: Text[1024];

    procedure Construct(txtString: Text[1024])
    begin
        _String := txtString;
    end;

    procedure CountOccurences(Sequence: Text[10]) Occurences: Integer
    var
        Index: Integer;
        String: Text;
    begin
        Index := 1;
        String := _String;
        while (Index > 0) and (Occurences < 100) do begin
            Index := StrPos(String, Sequence);
            if Index > 0 then begin
                Occurences += 1;
                String := CopyStr(String, Index + StrLen(Sequence));
            end;
        end;
    end;

    procedure SelectStringSep(Index: Integer; Sep: Text): Text
    var
        Int1: Integer;
        Int2: Integer;
        Itt: Integer;
        String: Text;
    begin
        String := _String;
        Itt := 1;
        Int1 := 1;
        while Itt < Index do begin
            Int1 := StrPos(String, Sep) + StrLen(Sep);
            String := CopyStr(String, Int1);
            Itt += 1;
        end;
        Int2 := StrPos(String, Sep);
        if Int2 > 0 then
            exit(CopyStr(String, 1, Int2 - 1))
        else
            exit(String);
    end;

    procedure PadStrLeft(String: Text[60]; TotalStrLen: Integer; PadChar: Text[30]; After: Boolean) OutStr: Text
    var
        i: Integer;
    begin
        OutStr := '';
        for i := 1 to TotalStrLen - StrLen(String) do begin
            if PadChar <> '' then
                OutStr := OutStr + PadChar
            else
                OutStr := OutStr + ' ';
        end;

        if After then
            OutStr := String + OutStr
        else
            OutStr := OutStr + String
    end;
}

