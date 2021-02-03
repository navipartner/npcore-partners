codeunit 6060072 "NPR Fixed/Delimited File Imp."
{
    Permissions = TableData "Data Exch. Field" = rimd;
    TableNo = "Data Exch.";

    trigger OnRun()
    var
        ReadStream: InStream;
        ReadText: Text;
        ReadLen: Integer;
        LineNo: Integer;
        SkippedLineNo: Integer;
    begin
        DataExchDef.Get("Data Exch. Def Code");
        case DataExchDef."File Encoding" of
            DataExchDef."File Encoding"::"MS-DOS":
                Rec."File Content".CreateInStream(ReadStream, TEXTENCODING::MSDos);
            DataExchDef."File Encoding"::WINDOWS:
                Rec."File Content".CreateInStream(ReadStream, TEXTENCODING::Windows);
            DataExchDef."File Encoding"::"UTF-8":
                Rec."File Content".CreateInStream(ReadStream, TEXTENCODING::UTF8);
            DataExchDef."File Encoding"::"UTF-16":
                Rec."File Content".CreateInStream(ReadStream, TEXTENCODING::UTF16);
        end;
        LineNo := 1;
        repeat
            ReadLen := ReadStream.ReadText(ReadText);
            if ReadLen > 0 then
                ParseLine(ReadText, Rec, LineNo, SkippedLineNo);
        until ReadLen = 0;
    end;

    var
        DataExchDef: Record "Data Exch. Def";

    local procedure ParseLine(Line: Text; DataExch: Record "Data Exch."; var LineNo: Integer; var SkippedLineNo: Integer)
    var
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchField: Record "Data Exch. Field";
        StartPosition: Integer;
        FileTypeNotSupportedErr: Label 'File Type %1 is not supported.', Comment = '%1 = File Type';
    begin
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        DataExchLineDef.FindFirst();

        if ((LineNo + SkippedLineNo) <= DataExchDef."Header Lines") or
           ((DataExchLineDef."Data Line Tag" <> '') and (StrPos(Line, DataExchLineDef."Data Line Tag") <> 1))
        then begin
            SkippedLineNo += 1;
            exit;
        end;

        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        DataExchColumnDef.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        DataExchColumnDef.FindSet();

        StartPosition := 1;
        repeat
            if DataExchColumnDef.Constant <> '' then begin
                DataExchField.InsertRecXMLField(DataExch."Entry No.", LineNo, DataExchColumnDef."Column No.", '',
                  DataExchColumnDef.Constant, DataExchLineDef.Code);
            end else begin
                case DataExchDef."File Type" of
                    DataExchDef."File Type"::"Fixed Text":
                        begin
                            DataExchField.InsertRecXMLField(DataExch."Entry No.", LineNo, DataExchColumnDef."Column No.", '',
                              CopyStr(Line, StartPosition, DataExchColumnDef.Length), DataExchLineDef.Code);
                            StartPosition += DataExchColumnDef.Length;
                        end;
                    DataExchDef."File Type"::"Variable Text":
                        begin
                            DataExchField.InsertRecXMLField(DataExch."Entry No.", LineNo, DataExchColumnDef."Column No.", '',
                              ExtractFirstDelimitedPart(Line, GetSeparator), DataExchLineDef.Code);
                        end;
                    else
                        Error(FileTypeNotSupportedErr, DataExchDef."File Type");
                end;
            end;
        until DataExchColumnDef.Next() = 0;
        LineNo += 1;
    end;

    local procedure GetSeparator(): Text[1]
    var
        Chr: Char;
    begin
        case DataExchDef."Column Separator" of
            DataExchDef."Column Separator"::Tab:
                begin
                    Chr := 9;
                    exit(Format(Chr));
                end;
            DataExchDef."Column Separator"::Semicolon:
                exit(';');
            DataExchDef."Column Separator"::Comma:
                exit(',');
            DataExchDef."Column Separator"::Space:
                exit(' ');
        end;
    end;

    local procedure ExtractFirstDelimitedPart(var Line: Text; Separator: Text[1]) FirstPart: Text
    var
        SeparatorPosition: Integer;
    begin
        SeparatorPosition := StrPos(Line, Separator);
        if SeparatorPosition > 0 then begin
            FirstPart := CopyStr(Line, 1, SeparatorPosition - 1);
            if SeparatorPosition + 1 <= StrLen(Line) then
                Line := CopyStr(Line, SeparatorPosition + 1)
            else
                Line := '';
        end else begin
            FirstPart := Line;
            Line := '';
        end;
    end;
}

