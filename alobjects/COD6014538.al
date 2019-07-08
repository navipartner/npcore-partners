codeunit 6014538 "RP Epson Web Print Service"
{
    // NPR4.15/MMV/20151001 CASE 223893 Created CU for use with web service printing
    // NPR4.15/MMV/20151016 CASE 223893 Changed print job deletion filter.
    // NPR5.20/MMV/20151020 CASE 223893 Added method GetInnerXML which builds a printjob that is processed faster on the printer than GetSinglePrintJob().
    //                                  Changed printjob expiration time from 10 sec. to 15 sec.
    // NPR5.20/MMV/20160224 CASE 233229 Small fix. Also removed old version tags.
    // NPR5.32/MMV /20170425 CASE 241995 Retail Print 2.0


    trigger OnRun()
    begin
    end;

    procedure GetPrintJobs(PrinterID: Text[250]): Text
    var
        WebPrintBuffer: Record "Web Print Buffer";
        PrintJobs: Text;
        OldestPrintTime: DateTime;
        CurrentPrintTime: DateTime;
    begin
        CurrentPrintTime := CurrentDateTime;
        OldestPrintTime  := CreateDateTime(Today,Time-15000);

        if StrPos(PrinterID,'EpsonW') > 0 then begin
          WebPrintBuffer.SetRange("Printer ID",PrinterID);
          WebPrintBuffer.SetFilter("Time Created", '>%1', OldestPrintTime);
          //-NPR5.20
          WebPrintBuffer.SetAutoCalcFields("Print Data");
          //+NPR5.20
          if WebPrintBuffer.FindSet then begin
            PrintJobs := '<?xml version="1.0" encoding="utf-8"?><PrintRequestInfo Version="2.00">';
            PrintJobs += GetAllPrintJobs(WebPrintBuffer);
            PrintJobs += '</PrintRequestInfo>';
          end;
          //Delete expired and currently handled printjobs
          WebPrintBuffer.SetFilter("Time Created", '<=%1', CurrentPrintTime);
          WebPrintBuffer.DeleteAll;
        end;

        exit(PrintJobs);
    end;

    local procedure "-- Aux"()
    begin
    end;

    local procedure GetSinglePrintJob(var WebPrintBuffer: Record "Web Print Buffer"): Text
    var
        InStream: InStream;
        InnerXML: Text;
    begin
        //Each print job is contained in a XML element : ePOSPrint
        if WebPrintBuffer."Print Data".HasValue then begin
          WebPrintBuffer.CalcFields("Print Data");
          WebPrintBuffer."Print Data".CreateInStream(InStream);
          InStream.Read(InnerXML);
          exit(InnerXML);
        end;
        exit('');
    end;

    local procedure GetAllPrintJobs(var WebPrintBuffer: Record "Web Print Buffer"): Text
    var
        TmpWebPrintBuffer: Record "Web Print Buffer" temporary;
        InnerXML: Text;
        InStream: InStream;
        OutStream: OutStream;
        DevID: Text;
        DevIDStrStart: Integer;
        NewCommand: Text;
        ExistingCommand: Text;
        TotalInnerXML: Text;
    begin
        //Gathers all escpos for same device in one XML element to avoid ~0,5 sec. printer lag on each new XML element processed.
        //Note for future reference: this erases the 1:1 relation between <printjobid> and WebPrintBuffer."Printjob ID" on printer callback
        repeat
          if WebPrintBuffer."Print Data".HasValue then begin
            //-NPR5.20
            //WebPrintBuffer.CALCFIELDS("Print Data");
            //+NPR5.20
            WebPrintBuffer."Print Data".CreateInStream(InStream);
            InStream.Read(InnerXML);

            DevIDStrStart := StrPos(InnerXML,'<devid>')+7;
            DevID         := CopyStr(InnerXML,DevIDStrStart,StrPos(InnerXML,'</devid>')-DevIDStrStart);

            TmpWebPrintBuffer.SetRange("Printer ID",DevID);
            if TmpWebPrintBuffer.FindFirst and TmpWebPrintBuffer."Print Data".HasValue then begin
              NewCommand   := CopyStr(InnerXML,StrPos(InnerXML,'<command>')+9);

              TmpWebPrintBuffer.CalcFields("Print Data");
              TmpWebPrintBuffer."Print Data".CreateInStream(InStream);
              InStream.Read(ExistingCommand);

              TmpWebPrintBuffer."Print Data".CreateOutStream(OutStream);
              OutStream.Write(CopyStr(ExistingCommand,1,StrPos(ExistingCommand,'</command>')-1) + NewCommand);
              TmpWebPrintBuffer.Modify;
            end else begin
              TmpWebPrintBuffer.Init;
              TmpWebPrintBuffer."Printer ID" := DevID;
              TmpWebPrintBuffer."Print Data".CreateOutStream(OutStream);
              OutStream.Write(InnerXML);
              TmpWebPrintBuffer.Insert;
            end;
          end;
        until WebPrintBuffer.Next = 0;

        if TmpWebPrintBuffer.FindSet then repeat
          if TmpWebPrintBuffer."Print Data".HasValue then begin
            TmpWebPrintBuffer.CalcFields("Print Data");
            TmpWebPrintBuffer."Print Data".CreateInStream(InStream);
            InStream.Read(InnerXML);
            TotalInnerXML += InnerXML;
          end;
        until TmpWebPrintBuffer.Next = 0;

        exit(TotalInnerXML)
    end;
}

