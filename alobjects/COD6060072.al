codeunit 6060072 "Fixed/Delimited File Import"
{
    // NPR5.27/BR  /20160926 CASE 252817 Object Created based on Codeunit 1241
    // NPR5.38/MHA /20180105  CASE 301053 Removed name Separator from return Variable of function GetSeparator() as it is a reserved name in V2

    Permissions = TableData "Data Exch. Field"=rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        ReadStream: InStream;
        ReadText: Text;
        ReadLen: Integer;
        LineNo: Integer;
        SkippedLineNo: Integer;
    begin
        with DataExchDef do begin
          Get("Data Exch. Def Code");
          case "File Encoding" of
            "File Encoding"::"MS-DOS" :
              "File Content".CreateInStream(ReadStream,TEXTENCODING::MSDos);
            "File Encoding"::WINDOWS :
              "File Content".CreateInStream(ReadStream,TEXTENCODING::Windows);
            "File Encoding"::"UTF-8" :
              "File Content".CreateInStream(ReadStream,TEXTENCODING::UTF8);
            "File Encoding"::"UTF-16" :
              "File Content".CreateInStream(ReadStream,TEXTENCODING::UTF16);
          end;
          LineNo := 1;
          repeat
            ReadLen := ReadStream.ReadText(ReadText);
            if ReadLen > 0 then
              ParseLine(ReadText,Rec,LineNo,SkippedLineNo);
          until ReadLen = 0;
        end;
    end;

    var
        DataExchDef: Record "Data Exch. Def";

    local procedure ParseLine(Line: Text;DataExch: Record "Data Exch.";var LineNo: Integer;var SkippedLineNo: Integer)
    var
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchField: Record "Data Exch. Field";
        StartPosition: Integer;
        FileTypeNotSupported: Label 'File Type %1 is not supported.';
    begin
        DataExchLineDef.SetRange("Data Exch. Def Code",DataExch."Data Exch. Def Code");
        DataExchLineDef.FindFirst;

        if ((LineNo + SkippedLineNo) <= DataExchDef."Header Lines") or
           ((DataExchLineDef."Data Line Tag" <> '') and (StrPos(Line,DataExchLineDef."Data Line Tag") <> 1))
        then begin
          SkippedLineNo += 1;
          exit;
        end;

        DataExchColumnDef.SetRange("Data Exch. Def Code",DataExch."Data Exch. Def Code");
        DataExchColumnDef.SetRange("Data Exch. Line Def Code",DataExchLineDef.Code);
        DataExchColumnDef.FindSet;

        StartPosition := 1;
        repeat
          if DataExchColumnDef.Constant <> '' then begin
            DataExchField.InsertRecXMLField(DataExch."Entry No.",LineNo,DataExchColumnDef."Column No.",'',
              DataExchColumnDef.Constant,DataExchLineDef.Code);

          end else begin
            case DataExchDef."File Type" of
              DataExchDef."File Type"::"Fixed Text" :
                begin
                  DataExchField.InsertRecXMLField(DataExch."Entry No.",LineNo,DataExchColumnDef."Column No.",'',
                    CopyStr(Line,StartPosition,DataExchColumnDef.Length),DataExchLineDef.Code);
                  StartPosition += DataExchColumnDef.Length;
                end;
              DataExchDef."File Type"::"Variable Text" :
                begin
                  DataExchField.InsertRecXMLField(DataExch."Entry No.",LineNo,DataExchColumnDef."Column No.",'',
                    ExtractFirstDelimitedPart(Line,GetSeparator),DataExchLineDef.Code);
                end;
              else
                Error(FileTypeNotSupported,DataExchDef."File Type");
            end;
          end;
        until DataExchColumnDef.Next = 0;
        LineNo += 1;
    end;

    local procedure GetSeparator(): Text[1]
    var
        Chr: Char;
    begin
        with DataExchDef do
          case "Column Separator" of
            //-NPR5.38 [301053]
            // "Column Separator"::Tab :
            //  Separator[1] := 9;
            // "Column Separator"::Semicolon :
            //  Separator := ';';
            // "Column Separator"::Comma :
            //  Separator := ',';
            // "Column Separator"::Space :
            //  Separator := ' ';
            "Column Separator"::Tab :
              begin
                Chr := 9;
                exit(Format(Chr));
              end;
            "Column Separator"::Semicolon :
              exit(';');
            "Column Separator"::Comma :
              exit(',');
            "Column Separator"::Space :
              exit(' ');
            //+NPR5.38 [301053]
          end;
    end;

    local procedure ExtractFirstDelimitedPart(var Line: Text;Separator: Text[1]) FirstPart: Text
    var
        SeparatorPosition: Integer;
    begin
        SeparatorPosition := StrPos(Line,Separator);
        if SeparatorPosition > 0 then begin
          FirstPart := CopyStr(Line,1,SeparatorPosition - 1);
          if SeparatorPosition + 1 <= StrLen(Line) then
            Line := CopyStr(Line,SeparatorPosition + 1)
          else
            Line := '';
        end else begin
          FirstPart := Line;
          Line := '';
        end;
    end;
}

