codeunit 6060073 "NPR CSV Splitter"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Not used anymore.';

    trigger OnRun()
    begin
        Initialize('', ',', '"', 0, 0, '', 1, 3, true);
        Process();
    end;

    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        FileMgt: Codeunit "File Management";
        ExportToServer: Boolean;
        WindowIsOpen: Boolean;
        FieldDelimiter: Char;
        FieldSeparator: Char;
        Window: Dialog;
        InputFile: File;
        Instr: InStream;
        HeaderRows: Integer;
        MaxNoOfColumns: Integer;
        NumberOfFiles: Integer;
        NumberOfLines: Integer;
        SplitOnColumn: Integer;
        FileExtensionLbl: Label '*.*', Locked = true;
        MaxLinesErr: Label 'File to large: cannot read more than %1 lines. ';
        ImportFileLbl: Label 'Import Excel File';
        SplitMethod: Option "0",GroupByColumn,SplitOnValueFirstField;
        FileTextEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS;
        ColumnValue: array[99] of Text;
        FileName: Text;
        InputFileName: Text;
        SheetName: Text;
        SplitOnValue: Text;

    procedure Process(): Text
    begin
        ImportFile();
        if IsExcelFile(InputFileName) then begin
            ReadExcel();
        end else begin
            OpenFile();
            FillArray();
        end;
        AssignLinestoFiles();
        BuildNewFiles();
        UpdateWindow('');
        if (NumberOfFiles > 0) and (ExportToServer) then begin
            if Exists(InputFileName) then
                Erase(InputFileName);
            exit(GetDirectoryName())
        end else
            exit('');
    end;

    procedure Initialize(ParInputFilename: Text; ParFieldSeparator: Char; ParFieldDelimiter: Char; ParSplitMethod: Option "0",GroupByColumn,SplitOnValueFirstField; ParSplitOnColumn: Integer; ParSplitOnValue: Text; ParHeaderRows: Integer; ParFileTextEncoding: Option "MS-DOS","UTF-8","UTF-16",WINDOWS; ParExportToServer: Boolean)
    var
        InitializingLbl: Label 'Initializing';
    begin
        UpdateWindow(InitializingLbl);
        InputFileName := ParInputFilename;
        FieldSeparator := ParFieldSeparator;
        FieldDelimiter := ParFieldDelimiter;
        SplitMethod := ParSplitMethod;
        SplitOnColumn := ParSplitOnColumn;
        SplitOnValue := ParSplitOnValue;
        HeaderRows := ParHeaderRows;
        FileTextEncoding := ParFileTextEncoding;
        ExportToServer := ParExportToServer;
        NumberOfLines := 0;
        NumberOfFiles := 0;
        MaxNoOfColumns := 0;
        Clear(ColumnValue);
        Clear(Instr);
    end;

    local procedure ImportFile()
    var
        NoFileSelectedErr: Label 'No file selected.';
    begin
        UpdateWindow('');
        if InputFileName <> '' then begin
            if not Exists(InputFileName) then begin
                InputFileName := '';
            end;
        end;

        if GuiAllowed then
            InputFileName := FileMgt.UploadFile(ImportFileLbl, FileExtensionLbl);
        if InputFileName = '' then
            Error(NoFileSelectedErr);
    end;

    local procedure OpenFile()
    begin
        case FileTextEncoding of
            FileTextEncoding::"MS-DOS":
                InputFile.Open(InputFileName, TEXTENCODING::MSDos);
            FileTextEncoding::"UTF-16":
                InputFile.Open(InputFileName, TEXTENCODING::UTF16);
            FileTextEncoding::"UTF-8":
                InputFile.Open(InputFileName, TEXTENCODING::UTF8);
            FileTextEncoding::WINDOWS:
                InputFile.Open(InputFileName, TEXTENCODING::Windows);
        end;
        InputFile.CreateInStream(Instr);
    end;

    local procedure ReadExcel()
    var
        NoRowsReadErr: Label 'No rows could be read.';
    begin
        if SheetName = '' then
            SheetName := ExcelBuffer.SelectSheetsName(InputFileName);
        ExcelBuffer.LockTable();
        ExcelBuffer.OpenBook(InputFileName, SheetName);
        ExcelBuffer.ReadSheet();
        if not ExcelBuffer.FindLast() then
            Error(NoRowsReadErr);
        NumberOfLines := ExcelBuffer."Row No.";
        ExcelBuffer.CloseBook();
    end;

    local procedure FillArray()
    var
        LineEnumerator: Integer;
        NoOfFields: Integer;
        Size: Integer;
        BuildingLinesLbl: Label 'Parsing Lines.';
        CSVLine: Text;
    begin
        UpdateWindow(BuildingLinesLbl);
        LineEnumerator := 0;
        while not Instr.EOS do begin
            if LineEnumerator = 1000 then
                Error(MaxLinesErr, LineEnumerator);
            LineEnumerator += 1;
            Size := Instr.ReadText(CSVLine);
            if Size <> 0 then begin
                NoOfFields := ParseLine(LineEnumerator, CSVLine);
            end;
        end;
        NumberOfLines := LineEnumerator;
        InputFile.Close();
    end;

    local procedure ParseLine(LineEnumarator: Integer; CSVLine: Text): Integer
    var
        FieldEnumerator: Integer;
        FieldValue: Text;
    begin
        FieldEnumerator := 0;
        repeat
            FieldEnumerator += 1;
            FieldValue := NextField(CSVLine);
            if FieldValue <> '' then begin
                ExcelBuffer.Init();
                ExcelBuffer.Validate("Row No.", LineEnumarator);
                ExcelBuffer.Validate("Column No.", FieldEnumerator);
                ExcelBuffer.Validate("Cell Value as Text", FieldValue);
                ExcelBuffer.Insert();
            end;
        until (CSVLine = '') or (FieldEnumerator = 99);
        ExcelBuffer.Init();
        ExcelBuffer.Validate("Row No.", LineEnumarator);
        ExcelBuffer.Validate("Column No.", FieldEnumerator + 1);
        ExcelBuffer.Validate("Cell Value as Text", GetEndofLineText());
        ExcelBuffer.Insert();
        exit(FieldEnumerator);
    end;

    local procedure NextField(var VarLineOfText: Text): Text
    begin
        exit(ForwardTokenizer(VarLineOfText, FieldSeparator, FieldDelimiter));
    end;

    local procedure ForwardTokenizer(var VarText: Text; PSeparator: Char; PQuote: Char) RField: Text
    var
        IsNextField: Boolean;
        IsQuoted: Boolean;
        NextFieldPos: Integer;
        InputText: Text;
        NextByte: Text[1];
    begin

        //  This function splits the textline into 2 parts at first occurence of separator
        //  Quotecharacter enables separator to occur inside datablock

        //  example:
        //  23;some text;"some text with a ;";xxxx

        //  result:
        //  1) 23
        //  2) some text
        //  3) some text with a ;
        //  4) xxxx

        //  Quoted text, variable length text tokenizer:
        //  forward searching tokenizer splitting string at separator.
        //  separator is protected by quoting string
        //  the separator is omitted from the resulting strings
        if VarText = '' then
            exit('');
        if ((VarText[1] = PQuote) and (StrLen(VarText) = 1)) then begin
            VarText := '';
            RField := '';
            exit(RField);
        end;

        IsQuoted := false;
        NextFieldPos := 1;
        IsNextField := false;

        InputText := VarText;

        if (PQuote = InputText[NextFieldPos]) then
            IsQuoted := true;
        while ((NextFieldPos <= StrLen(InputText)) and (not IsNextField)) do begin
            if (PSeparator = InputText[NextFieldPos]) then
                IsNextField := true;
            if (IsQuoted and IsNextField) then
                IsNextField := (InputText[NextFieldPos - 1] = PQuote);

            NextByte[1] := InputText[NextFieldPos];
            if (not IsNextField) then
                RField += NextByte;
            NextFieldPos += 1;
        end;
        if (IsQuoted) then
            RField := CopyStr(RField, 2, StrLen(RField) - 2);

        VarText := CopyStr(InputText, NextFieldPos);
        exit(RField);
    end;

    local procedure AssignLinestoFiles()
    var
        LineEnumerator: Integer;
        AssigningLinesLbl: Label 'Assigning %1 Lines to new files.', Comment = '%1 = Number of lines';
    begin
        UpdateWindow(StrSubstNo(AssigningLinesLbl, NumberOfLines));
        if NumberOfFiles = 0 then
            NumberOfFiles := 1;
        LineEnumerator := 0;
        repeat
            LineEnumerator += 1;
            AssignLinetoFile(LineEnumerator);
        until LineEnumerator = NumberOfLines;
    end;

    local procedure AssignLinetoFile(LineEnumerator: Integer)
    var
        FieldValue: Text;
    begin
        if ExcelBuffer.Get(LineEnumerator, SplitOnColumn) then
            FieldValue := ExcelBuffer."Cell Value as Text"
        else
            FieldValue := '';
        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", LineEnumerator);
        if ExcelBuffer.FindLast() then begin
            if MaxNoOfColumns < ExcelBuffer."Column No." then
                MaxNoOfColumns := ExcelBuffer."Column No.";
        end;
        case SplitMethod of
            0:
                begin
                    ExcelBuffer.Init();
                    ExcelBuffer.Validate("Row No.", LineEnumerator);
                    ExcelBuffer.Validate("Column No.", 999);
                    ExcelBuffer.Validate("Cell Value as Text", Format(1));
                    ExcelBuffer.Insert(true);
                end;
            SplitMethod::GroupByColumn:
                begin
                    ExcelBuffer.Init();
                    ExcelBuffer.Validate("Row No.", LineEnumerator);
                    ExcelBuffer.Validate("Column No.", 999);
                    ExcelBuffer.Validate("Cell Value as Text", FieldValue);
                    ExcelBuffer.Insert(true);
                end;
            SplitMethod::SplitOnValueFirstField:
                begin
                    if SplitOnValue = FieldValue then
                        NumberOfFiles += 1;
                    ExcelBuffer.Init();
                    ExcelBuffer.Validate("Row No.", LineEnumerator);
                    ExcelBuffer.Validate("Column No.", 999);
                    ExcelBuffer.Validate("Cell Value as Text", Format(NumberOfFiles));
                    ExcelBuffer.Insert(true);
                end;
        end;
    end;

    local procedure BuildNewFiles()
    var
        AllLinesExported: Boolean;
        OutputFile: File;
        LocalInstr: InStream;
        I: Integer;
        J: Integer;
        BuildingFileLbl: Label 'Building file %1.', Comment = '%1 = Number of building file';
        FileLbl: Label 'File %1', Locked = true;
    begin
        if ExportToServer then
            if FileMgt.ServerDirectoryExists(GetDirectoryName()) then
                FileMgt.ServerRemoveDirectory(GetDirectoryName(), true);

        I := 0;
        repeat
            I := I + 1;
            UpdateWindow(StrSubstNo(BuildingFileLbl, I));
            ExcelBuffer.Reset();
            ExcelBuffer.SetRange("Column No.", 999);
            ExcelBuffer.SetFilter(ExcelBuffer.Comment, '=%1', '');
            if HeaderRows > 0 then
                ExcelBuffer.SetRange("Row No.", HeaderRows + 1, 9999999);
            if ExcelBuffer.FindFirst() then begin
                CreateOutputfile(I, OutputFile);
                if not ExportToServer then
                    OutputFile.CreateInStream(LocalInstr);
                ExcelBuffer.SetRange("Cell Value as Text", ExcelBuffer."Cell Value as Text");
                ExcelBuffer.SetRange(ExcelBuffer.Comment);
                if HeaderRows > 0 then begin
                    J := 0;
                    repeat
                        J += 1;
                        OutputFile.Write(BuildLine(J));
                    until J = HeaderRows;
                end;
                if ExcelBuffer.FindSet() then
                    repeat
                        if ExcelBuffer.Comment = '' then begin
                            ExcelBuffer.Validate(Comment, StrSubstNo(FileLbl, Format(I)));
                            ExcelBuffer.Modify();
                            OutputFile.Write(BuildLine(ExcelBuffer."Row No."));
                        end;
                    until ExcelBuffer.Next() = 0;
                if not ExportToServer then begin
                    DownloadFromStream(LocalInstr, 'Export', '', 'All Files (*.*)|*.*', FileName);
                end;
                OutputFile.Close();
                Clear(OutputFile);
            end else begin
                AllLinesExported := true;
            end;
        until AllLinesExported;
        NumberOfFiles := I;
    end;

    local procedure CreateOutputfile(FileNo: Integer; var Outputfile: File)
    begin
        if IsExcelFile(InputFileName) then
            FileName := FileMgt.GetFileNameWithoutExtension(InputFileName) + '-' + Format(FileNo) + '.csv'
        else
            FileName := FileMgt.GetFileNameWithoutExtension(InputFileName) + '-' + Format(FileNo) + '.' + FileMgt.GetExtension(InputFileName);
        if ExportToServer then begin
            FileMgt.ServerCreateDirectory(GetDirectoryName());
            FileName := GetDirectoryName() + '\' + FileName;
            if FileMgt.ServerFileExists(FileName) then
                FileMgt.DeleteServerFile(FileName);
            case FileTextEncoding of
                FileTextEncoding::"MS-DOS":
                    Outputfile.Create(FileName, TEXTENCODING::MSDos);
                FileTextEncoding::"UTF-16":
                    Outputfile.Create(FileName, TEXTENCODING::UTF16);
                FileTextEncoding::"UTF-8":
                    Outputfile.Create(FileName, TEXTENCODING::UTF8);
                FileTextEncoding::WINDOWS:
                    Outputfile.Create(FileName, TEXTENCODING::Windows);
            end;
        end else begin
            case FileTextEncoding of
                FileTextEncoding::"MS-DOS":
                    Outputfile.CreateTempFile(TEXTENCODING::MSDos);
                FileTextEncoding::"UTF-16":
                    Outputfile.CreateTempFile(TEXTENCODING::UTF16);
                FileTextEncoding::"UTF-8":
                    Outputfile.CreateTempFile(TEXTENCODING::UTF8);
                FileTextEncoding::WINDOWS:
                    Outputfile.CreateTempFile(TEXTENCODING::Windows);
            end;
        end;
        Outputfile.TextMode(true);
    end;

    local procedure BuildLine(LineNo: Integer) LineText: Text[1024]
    var
        ColumnNo: Integer;
        FieldValue: Text;
        BuiltLineAndColumnLbl: Label 'Line %1 column %2 being built', Comment = '%1 = Line, %2 = Column';
    begin
        LineText := '';
        ColumnNo := 0;
        repeat
            ColumnNo += 1;
            UpdateWindow(StrSubstNo(BuiltLineAndColumnLbl, LineNo, ColumnNo));
            if ExcelBuffer.Get(LineNo, ColumnNo) then
                FieldValue := ExcelBuffer."Cell Value as Text"
            else
                FieldValue := '';
            if FieldValue <> GetEndofLineText() then begin
                FieldValue := DelChr(FieldValue, '=', Format(FieldSeparator)); //Field separators are not allowed within a field
                LineText := LineText + FieldValue + Format(FieldSeparator);
            end;
        until (ColumnNo = MaxNoOfColumns) or (FieldValue = GetEndofLineText());
    end;

    local procedure GetEndofLineText(): Text
    var
        EndOfLineLbl: Label 'ENDOFLINE', Locked = true;
    begin
        exit(EndOfLineLbl);
    end;

    local procedure GetDirectoryName(): Text
    begin
        exit(FileMgt.GetDirectoryName(InputFileName) + '\' + FileMgt.GetFileNameWithoutExtension(InputFileName));
    end;

    local procedure UpdateWindow(WindowText: Text)
    var
        SplittingStatusLbl: Label 'Splitting file: #1################################################################';
    begin
        if not GuiAllowed then
            exit;
        if (WindowText = '') and WindowIsOpen then begin
            Window.Close();
            WindowIsOpen := false;
            exit;
        end;
        if not WindowIsOpen then begin
            Window.Open(SplittingStatusLbl, WindowText);
            WindowIsOpen := true;
        end;
        Window.Update(1, WindowText);
    end;

    local procedure IsExcelFile(Filename: Text): Boolean
    begin
        exit((FileMgt.GetExtension(Filename) = 'xlsx') or (FileMgt.GetExtension(InputFileName) = 'xls'))
    end;
}

