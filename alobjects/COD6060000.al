codeunit 6060000 "GIM - Raw Data Reader"
{
    TableNo = "GIM - Import Document";

    trigger OnRun()
    begin
        GIMImportDoc := Rec;
        with GIMImportDoc do begin
          case "Data Source" of
            "Data Source"::"File upload":
              if "File Path" = '' then
                WorkingText := FileMgt.BLOBImport(TempBLOB,'')
              else
                WorkingText := "File Path";
            "Data Source"::FTP,"Data Source"::"Web service":
              WorkingText := "File Path";
          end;
          if WorkingText = '' then
            Error(Text001);
          CalcFields("File Container");
          if not "File Container".HasValue then begin
            FileMgt.BLOBImportFromServerFile(TempBLOB,FileMgt.UploadFileSilent(WorkingText));
            "File Container" := TempBLOB.Blob;
          end;
          if "File Name" = '' then begin
            while StrPos(WorkingText,'\') > 0 do
              WorkingText := CopyStr(WorkingText,StrPos(WorkingText,'\') + 1);
            "File Name" := WorkingText;
          end;
          if "File Extension" = '' then begin
            WorkingText := "File Name";
            while StrPos(WorkingText,'.') > 0 do
              WorkingText := CopyStr(WorkingText,StrPos(WorkingText,'.') + 1);
            "File Extension" := WorkingText;
          end;
          if "Data Format Code" = '' then begin
            DocType.Get("Document Type","Sender ID");
            "Data Format Code" := DocType."Data Format Code";
          end;
        end;
        Rec := GIMImportDoc;
    end;

    var
        GIMImportDoc: Record "GIM - Import Document";
        FileMgt: Codeunit "File Management";
        WorkingText: Text[250];
        TempBLOB: Record TempBlob temporary;
        Text001: Label 'File not imported.';
        DocType: Record "GIM - Document Type";
}

