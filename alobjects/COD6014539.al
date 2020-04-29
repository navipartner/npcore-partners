codeunit 6014539 "RP Epson Web Print Mgt."
{
    // NPR4.15/MMV/20151001 CASE 223893 Created CU for use with web service printing
    // NPR5.20/MMV/20160224 CASE 233229 Added function CreatePrintJob()
    // NPR5.32/MMV /20170425 CASE 241995 Retail Print 2.0


    trigger OnRun()
    begin
    end;

    procedure CreatePrintJob(PrinterName: Text[250];SlavePrinterName: Text[250];PrintString: Text;TargetEncoding: Text)
    var
        WebPrintBuffer: Record "Web Print Buffer";
        OutStream: OutStream;
        Hex: Text;
        HexBuffer: Text;
        XML: Text;
        i: Integer;
        Encoding: DotNet npNetEncoding;
        ByteArray: DotNet npNetArray;
        BitConverter: DotNet npNetBitConverter;
        Regex: DotNet npNetRegex;
    begin
        if StrPos(PrinterName,'EpsonW') > 0 then begin
          //Convert PrintString to hex representation (without '0x') of the byte values.
          Encoding := Encoding.GetEncoding(TargetEncoding);
          ByteArray := Encoding.GetBytes(PrintString);
          HexBuffer := BitConverter.ToString(ByteArray);
          HexBuffer := Regex.Replace(HexBuffer, '-', '');

          WebPrintBuffer.Init;
          WebPrintBuffer.Insert;
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

          WebPrintBuffer."Print Data".CreateOutStream(OutStream);
          OutStream.Write(XML);

          WebPrintBuffer."Time Created" := CurrentDateTime();
          WebPrintBuffer.Modify;
        end;
    end;
}

