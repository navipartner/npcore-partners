codeunit 6014540 "NPR Hexadecimal Convert"
{
    Access = Internal;

    procedure BlobAsHexadecimal(TempBlob: Codeunit "Temp Blob"): Text
    var
        HexArray: Array[16] of Text;
        IStream: InStream;
        Byte: Byte;
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
}