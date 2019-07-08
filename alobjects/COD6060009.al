codeunit 6060009 "GIM - Web Service"
{

    trigger OnRun()
    begin
    end;

    procedure SendFile(DocTypeCode: Text[10];SenderID: Text[20];FileHere: BigText;FileName: Text[250];FileExt: Text[10])
    var
        Bytes: DotNet npNetArray;
        Convert: DotNet npNetConvert;
        MemoryStream: DotNet npNetMemoryStream;
        MyStream: OutStream;
        WSFileReceive: Record "GIM - WS Received File";
        EntryNo: Integer;
    begin
        if WSFileReceive.FindLast then
          EntryNo := WSFileReceive."Entry No." + 1
        else
          EntryNo := 1;

        WSFileReceive.Init;
        WSFileReceive."Entry No." := EntryNo;
        WSFileReceive."Doc. Type Code" := UpperCase(DocTypeCode);
        WSFileReceive."Sender ID" := UpperCase(SenderID);
        WSFileReceive."File Name" := FileName;
        WSFileReceive."File Extension" := FileExt;
        WSFileReceive."Received At" := CurrentDateTime;

        Bytes := Convert.FromBase64String(FileHere);
        MemoryStream := MemoryStream.MemoryStream(Bytes);
        WSFileReceive."File Container".CreateOutStream(MyStream);
        MemoryStream.WriteTo(MyStream);

        WSFileReceive.Insert;

        WSFileReceive.ProcessFile();
    end;
}

