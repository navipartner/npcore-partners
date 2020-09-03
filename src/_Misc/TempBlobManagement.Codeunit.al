codeunit 6184900 "NPR Temp Blob Management"
{
    procedure ExportToFile(var TempBlob: Codeunit "Temp Blob"; Path: Text)
    var
        OutputFile: File;
        InStr: InStream;
        OutStr: OutStream;
    begin
        OutputFile.Create(Path);
        TempBlob.CreateInStream(InStr);
        OutputFile.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        OutputFile.Close();
    end;

    procedure ImportFromFile(var TempBlob: Codeunit "Temp Blob"; Path: Text)
    var
        InputFile: File;
        InStr: InStream;
        OutStr: OutStream;
    begin
        InputFile.Open(Path);
        InputFile.CreateInStream(InStr);
        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        InputFile.Close();
    end;
}