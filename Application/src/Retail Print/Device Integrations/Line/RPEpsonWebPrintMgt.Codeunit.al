codeunit 6014539 "NPR RP Epson Web Print Mgt."
{
    trigger OnRun()
    begin
    end;

    procedure CreatePrintJob(PrinterName: Text[250]; SlavePrinterName: Text[250]; PrintString: Text; TargetEncoding: Text)
    var
        WebPrintBuffer: Record "NPR Web Print Buffer";
        Encoding: DotNet NPRNetEncoding;
        ByteArray: DotNet NPRNetArray;
        BitConverter: DotNet NPRNetBitConverter;
        Regex: DotNet NPRNetRegex;
        OutStr: OutStream;
        Hex: Text;
        HexBuffer: Text;
        XML: Text;
        i: Integer;
    begin
        if StrPos(PrinterName, 'EpsonW') > 0 then begin
            //Convert PrintString to hex representation (without '0x') of the byte values.
            Encoding := Encoding.GetEncoding(TargetEncoding);
            ByteArray := Encoding.GetBytes(PrintString);
            HexBuffer := BitConverter.ToString(ByteArray);
            HexBuffer := Regex.Replace(HexBuffer, '-', '');

            WebPrintBuffer.Init();
            WebPrintBuffer.Insert();
            WebPrintBuffer."Printer ID" := PrinterName;

            XML += '<ePOSPrint>' +
                     '<Parameter>';
            if SlavePrinterName <> '' then
                XML += '<devid>' + SlavePrinterName + '</devid>'
            else
                XML += '<devid>local_printer</devid>';
            XML += '<timeout>10000</timeout>' +
                   '<printjobid>' + Format(WebPrintBuffer."Printjob ID") + '</printjobid>' +
                 '</Parameter>' +
                 '<PrintData>' +
                   '<epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">' +
                     '<command>' + HexBuffer + '</command>' +
                   '</epos-print>' +
                 '</PrintData>' +
               '</ePOSPrint>';

            WebPrintBuffer."Print Data".CreateOutStream(OutStr);
            OutStr.Write(XML);

            WebPrintBuffer."Time Created" := CurrentDateTime();
            WebPrintBuffer.Modify();
        end;
    end;
}

