codeunit 6014540 "NPR Hexadecimal Convert"
{
    Access = Internal;

    procedure BlobAsHexadecimal(TempBlob: Codeunit "Temp Blob"): Text
    var
        Byte: Byte;
        IStream: InStream;
        HexArray: array[16] of Text;
        HexString: TextBuilder;
    begin
        HexArray[1] := '0';
        HexArray[2] := '1';
        HexArray[3] := '2';
        HexArray[4] := '3';
        HexArray[5] := '4';
        HexArray[6] := '5';
        HexArray[7] := '6';
        HexArray[8] := '7';
        HexArray[9] := '8';
        HexArray[10] := '9';
        HexArray[11] := 'A';
        HexArray[12] := 'B';
        HexArray[13] := 'C';
        HexArray[14] := 'D';
        HexArray[15] := 'E';
        HexArray[16] := 'F';

        TempBlob.CreateInStream(IStream);
        while (not IStream.EOS) do begin
            IStream.Read(Byte, 1);
            HexString.Append((HexArray[(Byte div 16) + 1] + HexArray[(Byte mod 16) + 1]));
        end;
        exit(HexString.ToText());
    end;

    procedure BigHexToText(HexStr: Text): Text
    var
        i, j, Len : BigInteger;
        DecimalText: Text;
    begin
        Len := StrLen(HexStr);
        DecimalText := '';
        for i := 0 to Len - 1 do begin
            j := Len - i;
            if (HexStr[j] >= '0') and (HexStr[j] <= '9') then
                DecimalText := SumTextValues(DecimalText, MultiplyTextValues(Format((HexStr[j] - 48)), BigNumberPower(16, i)))
            else
                if (HexStr[j] >= 'A') and (HexStr[j] <= 'F') then
                    DecimalText := SumTextValues(DecimalText, MultiplyTextValues(Format((HexStr[j] - 55)), BigNumberPower(16, i)));
        end;
        exit(DecimalText);
    end;

    local procedure MultiplyTextValues(NumberValue1: Text; NumberValue2: Text): Text
    var
        Carry, i, In1, In2, j, Len1, Len2, n1, n2, Sum : Integer;
        ResultArray: array[100] of Integer;
        ResultBuild: TextBuilder;
    begin
        Len1 := StrLen(NumberValue1);
        Len2 := StrLen(NumberValue2);

        if (Len1 = 0) or (Len2 = 0) then
            exit('0');

        In1 := 1;
        In2 := 1;

        for i := Len1 downto 1 do begin
            Carry := 0;
            n1 := NumberValue1[i] - '0';
            In2 := 0;

            for j := Len2 downto 1 do begin
                n2 := NumberValue2[j] - '0';
                Sum := n1 * n2 + ResultArray[In1 + In2] + Carry;
                Carry := Sum div 10;
                ResultArray[In1 + In2] := Sum mod 10;
                In2 += 1;
            end;

            if (Carry > 0) then
                ResultArray[In1 + In2] += Carry;

            In1 += 1;
        end;

        if (Sum = 0) then
            exit('0');

        i := ArrayLen(ResultArray) - 1;

        while (i >= 1) and (ResultArray[i] = 0) do
            i := i - 1;

        if (i = 0) then
            exit('0');

        while (i >= 1) do begin
            ResultBuild.Append(Format(ResultArray[i]));
            i := i - 1;
        end;

        exit(ResultBuild.ToText());
    end;

    local procedure SumTextValues(TextValue1: Text; TextValue2: Text): Text
    var
        Carry, Diff, i, StrLen1, StrLen2, Sum : Integer;
        TempLen, TempSum, TempSum2 : Integer;
        TempStr: Text;
        Result: TextBuilder;
    begin
        StrLen1 := StrLen(TextValue1);
        StrLen2 := StrLen(TextValue2);

        if StrLen1 > StrLen2 then begin
            TempStr := TextValue1;
            TextValue1 := TextValue2;
            TextValue2 := TempStr;

            TempLen := StrLen1;
            StrLen1 := StrLen2;
            StrLen2 := TempLen;
        end;

        Diff := StrLen2 - StrLen1;
        Result.Clear();
        Carry := 0;

        for i := StrLen1 downto 1 do begin
            Evaluate(TempSum, TextValue1[i]);
            Evaluate(TempSum2, TextValue2[i + Diff]);
            TempSum2 += Carry;
            Sum := TempSum + TempSum2;

            Result.Append(Format(Sum mod 10));

            Carry := Sum div 10;
        end;

        for i := StrLen2 - StrLen1 downto 1 do begin
            Clear(TempSum);
            Evaluate(TempSum, TextValue2[i]);
            Sum := TempSum + Carry;
            Result.Append(Format(Sum mod 10));
            Carry := Sum div 10;
        end;

        if Carry > 0 then
            Result.Append(Format(Carry));

        exit(ReverseText(Result.ToText()));
    end;

    local procedure CalculatePower(Number: Integer; var ResultArray: array[100] of Integer; var ResultSize: Integer): Integer
    var
        carry: Integer;
        i: Integer;
        prod: Integer;
    begin
        carry := 0;

        for i := 1 to ResultSize do begin
            prod := ResultArray[i] * Number + carry;
            ResultArray[i] := prod mod 10;
            carry := prod div 10;
        end;

        while carry > 0 do begin
            ResultSize := ResultSize + 1;
            ResultArray[ResultSize] := carry mod 10;
            carry := carry div 10;
        end;

        exit(ResultSize);
    end;

    local procedure BigNumberPower(Number: Integer; Power: Integer): Text
    var
        i, ResultSize, Temp : Integer;
        ResultArray: array[100] of Integer;
        ResultStr: TextBuilder;
    begin
        if Power = 0 then
            exit('1');

        ResultSize := 0;
        Temp := Number;

        while Temp <> 0 do begin
            ResultSize := ResultSize + 1;
            ResultArray[ResultSize] := Temp mod 10;
            Temp := Temp div 10;
        end;

        for i := 2 to Power do
            ResultSize := CalculatePower(Number, ResultArray, ResultSize);

        for i := ResultSize downto 1 do
            ResultStr.Append(Format(ResultArray[i]));

        exit(ResultStr.ToText());
    end;

    local procedure ReverseText(Input: Text) Output: Text
    var
        i, j : Integer;
    begin
        if Input = '' then
            exit;

        j := 0;
        for i := StrLen(Input) downto 1 do begin
            j += 1;
            Output[j] := Input[i];
        end;
    end;
}