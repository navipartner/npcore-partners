codeunit 6014448 "NPR Table Export Library"
{
    // Table Export Library.
    //  Work started by Nicolai Esbensen.
    //  Edited by Henrik Palm.
    // 
    //  Library for producing table export for flat files.
    //  Provides the same functionality as dataports, with the extra
    //  options of chosing export encoding type and to be run from an Application Server.
    // 
    //  Modifications contributing to export routines are welcome. However,
    //  only reference std. functionality. Extend the codeunit by builing upon it
    //  rather than modifying it. For an example of such an extension, one are
    //  referred to CU 6014449 - "DBI - Table Export Wrapper".
    // 
    //  Sample code and the individual functions and their purpose are listed below.
    // ---------------------------------------------------------------------------
    //   ####################################################################################
    //   Sample code for exporting a batch of tables is set below.
    //     1. AddTableForExport(18);                    // Adds customer table for export.
    //     2. AddFieldForExport(18,1);                  // Set field 1 to be exported.
    //     3. AddTableForExport(27);                    // Adds item table for export.
    //     4. Customer.SETFILTER(Name,'*@Nic*');        // Uses customer table to build view for
    //     5. SetTableView(18,Customer.GETVIEW(FALSE)); // customers with a name like "Nic" and applies it for the export
    //     6. SetFileName('C:\test.txt');               // Sets the file to export to.
    //     7. ExportTableBatch;                         // Executes the batch export.
    //   ####################################################################################
    // 
    //   "ExportTableBatch()"
    //    Executes the batch set up.
    // 
    //   "ExportTableFromRecRefWithDef(VAR RecRef : RecordRef;FieldDefinitions : TEMPORARY Record Field)"
    //    Exports the records within the record reference, with regards to the fields being specied
    //    in the temporary field table.
    // 
    //   "ExportTableFromRecRef(VAR RecRef : RecordRef)"
    //    Exports all fields and records defined by the record definition.
    // 
    //   ####################   ExportDefFunctinality   #####################################
    // 
    //   "AddTableForExport(TableNo : Integer)"
    //    Adds the table with the ID equal of the TableNo argument to the batch export.
    // 
    //   "AddFieldForExport(TableNo : Integer;FieldNo : Integer)"
    //    Includes the field specified for the specific table in the export.
    //    If used for a specific table, only fields specified with this method is included in the export.
    // 
    //   "SetFieldsToExport(VAR TempFieldsToExportIn : TEMPORARY Record Field)"
    //    Includes the fields in the list in the export. Only fields in the list will be exported.
    // 
    //   "SetTableView(TableNo : Integer;FilterString : Text[250])"
    //    Filters the table with the specific tableno. The method GETVIEW must be used to produce
    //    the FilterString argument.
    // 
    //   ####################   Properties              #####################################
    //   "SetFileName(FileNameIn : Text[250])"
    //    Sets the filename to use for the export. If no file is specified a dialog will request
    //    a proper filename to use for the export.
    // 
    //   "SetFieldStartDelimeter(FieldStartDelimeterIn : Text[30])",
    //   "SetFieldEndDelimeter(FieldEndDelimeterIn : Text[30])",
    //   "SetFieldSeparator(FieldSeparatorIn : Text[30])",
    //   "SetRecordSeparator(RecordSeparatorIn : Text[30])",
    //   "SetDataItemSeparator(DataItemSeparatorIn : Text[30])" :
    //    Sets the delimeters for the individual seperation types. Common strings can be used.
    //    List of special characters is <TAB>, <NEWLINE>, <SPACE>. The arguments will be substituted
    //    with the corresponding character(s).
    // 
    //   "SetShowStatus(ShowStatusIn : Boolean)"
    //    Sets if Statusbar should be shown. Default is FALSE.
    // 
    //   "SetWriteFieldHeader(WriteFieldHeaderIn : Boolean)"
    //    Sets if the fieldnames for the individual dataitems should be included in the export
    //    before the actual data. Default is FALSE.
    // 
    //   "SetSkipFlowFields(SkipFlowFieldsIn : Boolean)"
    //    Sets if flowfields should be skipped in the export. Default is FALSE.
    // 
    //   "SetOutFileEncoding(Encoding : Text[50])"
    //    Sets the encoding equal to the encoding specified in the string argument.
    //    Ado export is used if an encoding is specified.
    //    Possible values for ADO Encodings
    //      - http://msdn.microsoft.com/en-us/library/ms526296(v=exchg.10).aspx
    //    Possible values for DotNet Ecodings
    //      - http://msdn.microsoft.com/en-us/library/system.text.encoding(v=vs.110).aspx
    // 
    //   "SetFileModeADO()"
    //    Set the export to use ADOStream. Default out encoding is UTF-8.
    // 
    //   "SetFileModeOStream()"
    //    Set the export to use NAV OStream (Default non-ISO encoding).
    // 
    //   "SetFileModeDotNetStream()"
    //    Set the export to use .Net class StreamWriter. Default encoding UTF-8.
    // 
    // 
    // NPR5.23/THRO/20160425 CASE 234161 : Table filters on Export Wizard
    // NPR5.26/THRO/20160812 CASE 248465 : Removed hardcoded filepath for serverfile
    // NPR5.38/MHA /20180105  CASE 301053 Removed FileMode::ADO
    // NPR5.41/THRO/20180410  CASE 308570 Blob-fields always included + option to export in xml data format
    // NPR5.48/MMV /20181217 CASE 340086 Added escape character support.
    // NPR5.48/MMV /20190214 CASE 342396 Added media & mediaset events for handling in NAV2017+
    // NPR5.50/MMV /20190403 CASE 351021 Added CLEARALL in Reset function


    trigger OnRun()
    begin
    end;

    var
        "-- RecordDefinition": Integer;
        TempFieldsToExport: Record "Field" temporary;
        TempTablesToExport: Record AllObj temporary;
        TempFiltersForTablesToExport: Record "Record Link" temporary;
        TempTableFiltersForExport: Record "Table Filter" temporary;
        "-- FileHandling Vars": Integer;
        FileMode: Option OStream,,DotNet;
        IsFileOpen: Boolean;
        IsProcessingBatch: Boolean;
        OStream: OutStream;
        OutFile: File;
        OutputEncoding: Text[50];
        DotNetStream: DotNet NPRNetStreamWriter;
        DotNetEncoding: DotNet NPRNetEncoding;
        DotNetFilePath: Text;
        "-- ExportVariables": Integer;
        ExportCompanyName: Text[100];
        FileName: Text[250];
        FieldStartDelimeter: Text[5];
        FieldEndDelimeter: Text[5];
        FieldSeparator: Text[5];
        RecordSeparator: Text[30];
        DataItemSeparator: Text[30];
        WriteFieldHeader: Boolean;
        WriteTableInformation: Boolean;
        RaiseErrors: Boolean;
        ShowStatus: Boolean;
        SkipFlowFields: Boolean;
        TrimSpecialChars: Boolean;
        SpecialCharString: Text[30];
        ReplaceCharString: Text[30];
        UseXmlDataFormat: Boolean;
        "-- Dialog": Integer;
        DialogValues: array[3] of Integer;
        ProgressDialog: Dialog;
        TxtProgess: Label 'Exporting ##1######\@@2@@@@@@@@@@@@@@@@@\@@3@@@@@@@@@@@@@@@@@';
        IsDialogOpen: Boolean;
        FileMgt: Codeunit "File Management";
        ToFile: Text;
        Envfunc: Codeunit "NPR Environment Mgt.";
        ServerFile: Text;
        FieldStartDelimiterSet: Boolean;
        FieldEndDelimiterSet: Boolean;
        EscapeCharacter: Text[1];

    procedure "-- TableExportFunctions"()
    begin
    end;

    procedure ExportTableBatch()
    var
        RecRef: RecordRef;
        Total: Integer;
        Itt: Integer;
    begin
        OpenFileForExport;

        OpenDialog;

        Total := TempTablesToExport.Count;

        if WriteTableInformation then
            WriteTableExportInformation;

        if TempTablesToExport.FindSet then
            repeat
                Itt += 1;
                UpdateProgessDialog(2, Itt, Total);
                IsProcessingBatch := true;

                if ExportCompanyName <> '' then
                    RecRef.Open(TempTablesToExport."Object ID", false, ExportCompanyName)
                else
                    RecRef.Open(TempTablesToExport."Object ID");

                ExportTableFromRecRef(RecRef);
                WriteDataItemSeparator;
                RecRef.Close;
            until TempTablesToExport.Next = 0;

        IsProcessingBatch := false;

        CloseFileForExport;

        CloseDialog;
    end;

    procedure ExportTableFromRecRefWithDef(var RecRef: RecordRef; FieldDefinitions: Record "Field" temporary)
    begin
        SetFieldsToExport(FieldDefinitions);
        ExportTableFromRecRef(RecRef);
    end;

    procedure ExportTableFromRecRef(var RecRef: RecordRef)
    var
        Itt: Integer;
        Total: Integer;
    begin
        SetDefaultValues;
        OpenFileForExport;

        OpenDialog;

        Clear(TempFieldsToExport);
        TempFieldsToExport.SetRange(TableNo, RecRef.Number);
        if (not TempFieldsToExport.FindFirst) then
            ConstructRDefFromTableNo(RecRef.Number);

        ApplyFilters(RecRef);

        if WriteTableInformation then
            WriteTableInfoFromRecRef(RecRef);

        if WriteFieldHeader then
            WriteRecordHeaderFromTableNo(RecRef.Number);

        Total := RecRef.Count;

        UpdateDialog(1, RecRef.Number);

        if RecRef.FindSet then
            repeat
                Itt += 1;
                UpdateProgessDialog(3, Itt, Total);
                ExportRow(RecRef);
            until RecRef.Next = 0;

        if not IsProcessingBatch then
            CloseFileForExport;
    end;

    local procedure "-- Locals"()
    begin
    end;

    local procedure ConstructRDefFromTableNo("Table No.": Integer)
    var
        "Fields": Record "Field";
    begin
        TempFieldsToExport.Init;

        Fields.SetRange(TableNo, "Table No.");

        Fields.SetRange(Class, Fields.Class::Normal, Fields.Class::FlowField);

        if SkipFlowFields then begin
            Fields.SetRange(Class, Fields.Class::Normal);
            //-NPR5.41 [308570]
            //  Fields.SETFILTER(Type,'<>%1',Fields.Type::BLOB);
            //+NPR5.41 [308570]
        end;

        if Fields.FindSet then
            repeat
                TempFieldsToExport.TableNo := Fields.TableNo;
                TempFieldsToExport."No." := Fields."No.";
                TempFieldsToExport.Enabled := Fields.Enabled;
                if TempFieldsToExport.Enabled then
                    TempFieldsToExport.Insert;
            until Fields.Next = 0;
    end;

    local procedure ResolveDelimeter(DelimeterCode: Text[30]): Text[2]
    begin
        case DelimeterCode of
            '<NEWLINE>':
                exit(NEWLINE);
            '<TAB>':
                exit(TAB);
            '<EOF>':
                exit(EOF);
            '<SPACE>':
                exit(SPACE);
            '<CR>':
                exit(CR);
            '<LF>':
                exit(LF);
        end;
    end;

    local procedure WriteDataItemSeparator()
    begin
        Write(DataItemSeparator);
    end;

    local procedure WriteFieldSeparator()
    begin
        Write(FieldSeparator);
    end;

    local procedure WriteRecordSeparator()
    begin
        Write(RecordSeparator);
    end;

    local procedure WriteFieldValue(Value: Text)
    var
        String: DotNet NPRNetString;
    begin
        //-NPR5.48 [340086]
        if EscapeCharacter <> '' then begin
            String := Value;
            if StrPos(Value, '\') <> 0 then
                String := String.Replace('\', '\\');

            if StrPos(Value, FieldSeparator) <> 0 then
                String := String.Replace(FieldSeparator, '\' + FieldSeparator);

            Value := String;
        end;
        //+NPR5.48 [340086]
        Write(FieldStartDelimeter + Value + FieldEndDelimeter);
    end;

    procedure WriteFieldType(var "Field": Record "Field")
    begin
        case Field.Type of
            Field.Type::OemCode,
          Field.Type::OemText:
                WriteFieldValue(Format(Field.Type) + ':[' + Format(Field.Len) + ']');
            else
                WriteFieldValue(Format(Field.Type));
        end;
    end;

    local procedure "-- FileHandling"()
    begin
    end;

    local procedure OpenFileForExport()
    begin
        TestFileName;

        if IsFileOpen then exit;

        case FileMode of
            //-NPR5.38 [301053]
            //FileMode::ADO        : OpenADOStreamForExport;
            //+NPR5.38 [301053]
            FileMode::OStream:
                OpenOStreamForExport;
            FileMode::DotNet:
                OpenDotNetStream;
        end;

        IsFileOpen := true;
    end;

    local procedure OpenOStreamForExport()
    begin

        if FILE.Erase(FileName) then;

        OutFile.TextMode(false);
        OutFile.Create(FileName);
        OutFile.CreateOutStream(OStream);
    end;

    procedure OpenDotNetStream()
    var
        Environment: Codeunit "NPR Environment Mgt.";
    begin
        //ServerFile :=FileMgt.ServerTempFileName('txt');
        //OutFile.CREATE( ServerFile);
        //OutFile.CREATEOUTSTREAM(OStream);


        //IF FILE.ERASE(FileName) THEN;
        //FileName :=  FileMgt.ServerTempFileName('txt') ;
        //OutFile.TEXTMODE(FALSE);
        ///OutFile.CREATE(FileName);
        //OutFile.CREATEOUTSTREAM(OStream);


        //-NPR5.26 [248465]
        //DotNetFilePath := 'C:\temp\TempExport.txt';
        DotNetFilePath := FileMgt.ServerTempFileName('txt');
        //-NPR5.26 [248465]


        SetDefaultValues;

        DotNetEncoding := DotNetEncoding.GetEncoding(OutputEncoding);

        DotNetStream := DotNetStream.StreamWriter(DotNetFilePath, false, DotNetEncoding);



        //OutFile.CLOSE();

        //FileMgt.DownloadToFile(FileName ,DotNetFilePath);
    end;

    local procedure CloseFileForExport()
    begin
        case FileMode of
            //-NPR5.38 [301053]
            //FileMode::ADO     : CloseAdoStreamForExport;
            //-NPR5.38 [301053]
            FileMode::OStream:
                CloseOStreamForExport;
            FileMode::DotNet:
                CloseDotNetStreamForExport;
        end;

        IsFileOpen := false;
    end;

    local procedure CloseOStreamForExport()
    begin
        OutFile.Close;
    end;

    procedure CloseDotNetStreamForExport()
    var
        [RunOnClient]
        DotNetFile: DotNet NPRNetFile;
        DotNetFileServer: DotNet NPRNetFile;
        FileManagement: Codeunit "File Management";
    begin
        DotNetStream.Close;

        if GuiAllowed then
            FileManagement.DownloadToFile(DotNetFilePath, FileName)
        else
            DotNetFileServer.Copy(DotNetFilePath, FileName);
    end;

    local procedure TestFileName()
    var
        FileMgt: Codeunit "File Management";
    begin
        if FileName = '' then begin
            FileName := FileMgt.SaveFileDialog('Choose File For Export', '', 'Text Files (*.txt)|*.txt');
        end;

        if FileName = '' then Error('');
    end;

    local procedure Write(Text: Text)
    begin
        case FileMode of
            //-NPR5.38 [301053]
            //FileMode::ADO     : ADOStream.WriteText(Text);
            //+NPR5.38 [301053]
            FileMode::OStream:
                OStream.WriteText(Text);
            FileMode::DotNet:
                DotNetStream.Write(Text);
        end;
    end;

    local procedure "-- DialogFunctionality"()
    begin
    end;

    local procedure OpenDialog()
    begin
        if GuiAllowed and ShowStatus then
            if not IsDialogOpen then begin
                ProgressDialog.Open(TxtProgess);
                IsDialogOpen := true;
            end;
    end;

    local procedure UpdateDialog(ValueNo: Integer; Value: Integer)
    begin
        if GuiAllowed and ShowStatus then
            ProgressDialog.Update(ValueNo, Value);
    end;

    local procedure UpdateProgessDialog(ValueNo: Integer; Progress: Integer; Total: Integer)
    begin
        if GuiAllowed and ShowStatus then begin
            Progress := Round(Progress / Total * 10000, 1, '>');
            if Progress <> DialogValues[ValueNo] then begin
                DialogValues[ValueNo] := Progress;
                ProgressDialog.Update(ValueNo, DialogValues[ValueNo]);
            end;
        end;
    end;

    local procedure CloseDialog()
    begin
        if GuiAllowed and ShowStatus then
            ProgressDialog.Close;

        IsDialogOpen := false;
    end;

    procedure "-- ExportDefFunctinality"()
    begin
    end;

    procedure AddTableForExport(TableNo: Integer)
    var
        Tables: Record AllObj;
    begin
        TempTablesToExport."Object Type" := TempTablesToExport."Object Type"::Table;
        TempTablesToExport."Object ID" := TableNo;
        if Tables.Get(Tables."Object Type"::Table, TableNo) then begin
            if TempTablesToExport.Insert then;
        end else
            if RaiseErrors then Tables.Get(Tables."Object Type"::Table, TableNo);
    end;

    procedure AddFieldForExport(TableNo: Integer; FieldNo: Integer)
    var
        "Fields": Record "Field";
    begin
        TempFieldsToExport.TableNo := TableNo;
        TempFieldsToExport."No." := FieldNo;
        if Fields.Get(TableNo, FieldNo) then begin
            if TempFieldsToExport.Insert then;
        end else
            if RaiseErrors then Fields.Get(TableNo, FieldNo);
    end;

    procedure SetFieldsToExport(var TempFieldsToExportIn: Record "Field" temporary)
    begin
        TempFieldsToExport.DeleteAll;
        if TempFieldsToExportIn.FindSet then
            repeat
                TempFieldsToExport.Init;
                TempFieldsToExport.TransferFields(TempFieldsToExportIn);
                TempFieldsToExport.Insert;
            until TempFieldsToExportIn.Next = 0;
    end;

    procedure SetTableView(TableNo: Integer; FilterString: Text[250])
    begin
        TempFiltersForTablesToExport."Link ID" := TableNo;
        TempFiltersForTablesToExport.URL1 := FilterString;
        TempFiltersForTablesToExport.Insert;
    end;

    procedure SetTableFilters(var TempTableFilter: Record "Table Filter")
    begin
        //-NPR5.23
        TempTableFiltersForExport.Reset;
        TempTableFiltersForExport.DeleteAll;
        if TempTableFilter.FindSet then
            repeat
                TempTableFiltersForExport.Init;
                TempTableFiltersForExport.TransferFields(TempTableFilter);
                TempTableFiltersForExport.Insert;
            until TempTableFilter.Next = 0;
        //+NPR5.23
    end;

    local procedure "-- TableExportFunctionality"()
    begin
    end;

    local procedure ApplyFilters(RecRef: RecordRef)
    var
        FldRef: FieldRef;
    begin
        if TempFiltersForTablesToExport.Get(RecRef.Number) then begin
            RecRef.SetView(TempFiltersForTablesToExport.URL1)
        end;
        //-NPR5.23
        TempTableFiltersForExport.SetRange("Table Number", RecRef.Number);
        if TempTableFiltersForExport.FindSet then
            repeat
                if (TempTableFiltersForExport."Field Number" <> 0) and (TempTableFiltersForExport."Field Filter" <> '') then begin
                    FldRef := RecRef.Field(TempTableFiltersForExport."Field Number");
                    FldRef.SetFilter(TempTableFiltersForExport."Field Filter");
                end;
            until TempTableFiltersForExport.Next = 0;
        TempTableFiltersForExport.SetRange("Table Number");
        //+NPR5.23
    end;

    local procedure "-- RowExportFunctionality"()
    begin
    end;

    local procedure ExportRow(RecRef: RecordRef)
    var
        FieldNo: Integer;
        FieldRef: FieldRef;
    begin
        TempFieldsToExport.SetRange(TableNo, RecRef.Number);
        TempFieldsToExport.FindSet;
        repeat
            if FieldNo > 0 then
                WriteFieldSeparator;
            FieldRef := RecRef.Field(TempFieldsToExport."No.");
            ExportField(FieldRef);
            FieldNo += 1;
        until TempFieldsToExport.Next = 0;

        WriteRecordSeparator;
    end;

    local procedure "-- FieldExportFunctionality"()
    begin
    end;

    local procedure ExportField(var FieldRef: FieldRef)
    var
        TempBlob: Codeunit "Temp Blob";
        Encoding: DotNet NPRNetEncoding;
        BinaryReader: DotNet NPRNetBinaryReader;
        Stream: DotNet NPRNetStream;
        DotNetString: DotNet NPRNetString;
        Convert: DotNet NPRNetConvert;
        InStream: InStream;
        Value: Text;
        DateVal: Date;
        IntVal: Integer;
        Base64: Text;
        "Count": Integer;
        i: Integer;
    begin
        if (Format(FieldRef.Class) = 'FlowField') or (Format(FieldRef.Type) = 'BLOB') then begin
            FieldRef.CalcField;
        end;

        //-NPR5.41 [308570]
        if UseXmlDataFormat then
            Value := Format(FieldRef.Value, 0, 9)
        else
            //+NPR5.41 [308570]
            Value := Format(FieldRef.Value);

        if (Format(FieldRef.Type) = 'Text') and TrimSpecialChars then
            RemoveSpeacialChars(Value);
        if (Format(FieldRef.Type) = 'Boolean') then
            FormatBoolean(Value);
        //-NPR5.41 [308570]
        if not UseXmlDataFormat then
            //+NPR5.41 [308570]
            if (Format(FieldRef.Type) = 'Date') then begin
                DateVal := FieldRef.Value;
                Value := FormatDate(DateVal);
            end;
        if (Format(FieldRef.Type) = 'Option') then begin
            IntVal := FieldRef.Value;
            Value := Format(IntVal);
        end;
        if (Format(FieldRef.Type) = 'BLOB') then begin
            TempBlob.FromFieldRef(FieldRef);
            TempBlob.CreateInStream(InStream);
            Stream := InStream;
            BinaryReader := BinaryReader.BinaryReader(Stream);
            Value := Convert.ToBase64String(BinaryReader.ReadBytes(Stream.Length));
            Value := StrSubstNo('%1:%2', StrLen(Value), Value);
            WriteFieldValue(Value);
            //-NPR5.48 [342396]
        end else
            if (UpperCase(Format(FieldRef.Type)) = 'MEDIA') then begin
                OnHandleExportMedia(FieldRef, TempBlob);
                TempBlob.CreateInStream(InStream);
                Stream := InStream;
                BinaryReader := BinaryReader.BinaryReader(Stream);
                Base64 := Convert.ToBase64String(BinaryReader.ReadBytes(Stream.Length));
                Value := StrSubstNo('%1:%2', StrLen(Base64), Base64);
                WriteFieldValue(Value);
            end else
                if (UpperCase(Format(FieldRef.Type)) = 'MEDIASET') then begin
                    Value := '';
                    OnGetMediaSetCount(FieldRef, Count);
                    if Count > 0 then begin
                        for i := 1 to Count do begin
                            OnHandleExportMediaSet(FieldRef, TempBlob, i);
                            TempBlob.CreateInStream(InStream);
                            Stream := InStream;
                            BinaryReader := BinaryReader.BinaryReader(Stream);
                            Base64 := Convert.ToBase64String(BinaryReader.ReadBytes(Stream.Length));
                            if i > 1 then
                                Value += '^'; //Separator between multiple media values.
                            Value += StrSubstNo('%1:%2', StrLen(Base64), Base64);
                        end;
                    end else
                        Value := '0:';

                    WriteFieldValue(Value);
                    //+NPR5.48 [342396]
                end else
                    WriteFieldValue(Value);
    end;

    local procedure "-- ExportFunctionality"()
    begin
    end;

    local procedure WriteRecordHeaderFromTableNo("TableNo.": Integer)
    var
        "Fields": Record "Field";
        FieldNo: Integer;
    begin
        TempFieldsToExport.SetRange(TableNo, "TableNo.");

        if TempFieldsToExport.FindSet then
            repeat
                Fields.Get(TempFieldsToExport.TableNo, TempFieldsToExport."No.");
                if not SkipFlowFields or (Fields.Class = Fields.Class::Normal) then begin
                    if FieldNo > 0 then
                        WriteFieldSeparator;
                    WriteFieldValue(ConvertStr(Fields.FieldName, '.', '_'));
                end;
                FieldNo += 1;
            until TempFieldsToExport.Next = 0;

        WriteRecordSeparator;
    end;

    local procedure WriteTableInfoFromRecRef(RecRef: RecordRef)
    var
        "Fields": Record "Field";
        FieldNo: Integer;
    begin
        Write('Table:' + Format(RecRef.Number));
        WriteRecordSeparator;
        Write('Records:' + Format(RecRef.Count));
        WriteRecordSeparator;

        TempFieldsToExport.SetRange(TableNo, RecRef.Number);

        if TempFieldsToExport.FindSet then
            repeat
                Fields.Get(TempFieldsToExport.TableNo, TempFieldsToExport."No.");
                if not SkipFlowFields or (Fields.Class = Fields.Class::Normal) then begin
                    if FieldNo > 0 then
                        WriteFieldSeparator;
                    WriteFieldValue(Format(Fields."No."));
                end;
                FieldNo += 1;
            until TempFieldsToExport.Next = 0;

        WriteRecordSeparator;

        FieldNo := 0;

        if TempFieldsToExport.FindSet then
            repeat
                Fields.Get(TempFieldsToExport.TableNo, TempFieldsToExport."No.");
                if not SkipFlowFields or (Fields.Class = Fields.Class::Normal) then begin
                    if FieldNo > 0 then
                        WriteFieldSeparator;
                    WriteFieldType(Fields);
                end;
                FieldNo += 1;
            until TempFieldsToExport.Next = 0;

        WriteRecordSeparator;
    end;

    local procedure WriteTableExportInformation()
    begin
        Write('Tables:' + Format(TempTablesToExport.Count));
        WriteRecordSeparator;
    end;

    procedure "-- InitFunctionality"()
    begin
    end;

    procedure Reset()
    begin
        //-NPR5.50 [351021]
        ClearAll;
        //+NPR5.50 [351021]
        TempFieldsToExport.DeleteAll;
        TempTablesToExport.DeleteAll;
        TempFiltersForTablesToExport.DeleteAll;
        //-NPR5.23
        TempTableFiltersForExport.Reset;
        TempTableFiltersForExport.DeleteAll;
        //+NPR5.23
    end;

    local procedure SetDefaultValues()
    begin
        //-NPR5.48 [340086]
        if not FieldStartDelimiterSet then
            //+NPR5.48 [340086]
            TestAndSet(FieldStartDelimeter, '"');
        //-NPR5.48 [340086]
        if not FieldEndDelimiterSet then
            //+NPR5.48 [340086]
            TestAndSet(FieldEndDelimeter, '"');
        TestAndSet(FieldSeparator, ';');
        TestAndSet(RecordSeparator, NEWLINE);
        TestAndSet(DataItemSeparator, NEWLINE + NEWLINE);
        TestAndSet(OutputEncoding, 'utf-8')
    end;

    procedure "-- Properties"()
    begin
    end;

    procedure SetCompany(CompanyNameIn: Text[100])
    begin
        ExportCompanyName := CompanyNameIn;
    end;

    procedure SetFileName(FileNameIn: Text[250])
    begin
        FileName := FileNameIn;
    end;

    procedure SetFieldStartDelimeter(FieldStartDelimeterIn: Text[30])
    begin
        //-NPR5.48 [340086]
        FieldStartDelimiterSet := true;
        //+NPR5.48 [340086]
        FieldStartDelimeter := ResolveDelimeters(FieldStartDelimeterIn);
    end;

    procedure SetFieldEndDelimeter(FieldEndDelimeterIn: Text[30])
    begin
        //-NPR5.48 [340086]
        FieldEndDelimiterSet := true;
        //+NPR5.48 [340086]
        FieldEndDelimeter := ResolveDelimeters(FieldEndDelimeterIn);
    end;

    procedure SetFieldSeparator(FieldSeparatorIn: Text[30])
    begin
        FieldSeparator := ResolveDelimeters(FieldSeparatorIn);
    end;

    procedure SetRaiseErrors(RaiseErrorsIn: Boolean)
    begin
        RaiseErrors := RaiseErrorsIn;
    end;

    procedure SetRecordSeparator(RecordSeparatorIn: Text[30])
    begin
        RecordSeparator := ResolveDelimeters(RecordSeparatorIn);
    end;

    procedure SetDataItemSeparator(DataItemSeparatorIn: Text[30])
    begin
        DataItemSeparator := ResolveDelimeters(DataItemSeparatorIn);
    end;

    procedure SetShowStatus(ShowStatusIn: Boolean)
    begin
        ShowStatus := ShowStatusIn;
    end;

    procedure SetWriteFieldHeader(WriteFieldHeaderIn: Boolean)
    begin
        WriteFieldHeader := WriteFieldHeaderIn;
    end;

    procedure SetWriteTableInformation(WriteTableInformationIn: Boolean)
    begin
        WriteTableInformation := WriteTableInformationIn;
    end;

    procedure SetSkipFlowFields(SkipFlowFieldsIn: Boolean)
    begin
        SkipFlowFields := SkipFlowFieldsIn;
    end;

    procedure SetOutFileEncoding(Encoding: Text[50])
    begin

        OutputEncoding := Encoding;
    end;

    procedure SetFileModeOStream()
    begin
        FileMode := FileMode::OStream;
    end;

    procedure SetFileModeDotNetStream()
    begin
        FileMode := FileMode::DotNet;
    end;

    procedure SetTrimSpecialChars(TrimSpecialCharsIn: Boolean)
    begin
        TrimSpecialChars := TrimSpecialCharsIn;
    end;

    procedure SetXmlDataFormat(XmlDataFormat: Boolean)
    begin
        //-NPR5.41 [308570]
        UseXmlDataFormat := XmlDataFormat;
        //+NPR5.41 [308570]
    end;

    procedure SetEscapeCharacter(Char: Text[1])
    begin
        EscapeCharacter := Char;
    end;

    local procedure "-- Aux"()
    begin
    end;

    procedure FormatBoolean(var Value: Text[1024])
    var
        TestBool: Boolean;
    begin
        if not Evaluate(TestBool, Value) then begin
            Value := '0';
            exit;
        end;

        if TestBool then
            Value := '1'
        else
            Value := '0';
    end;

    procedure FormatDate(DateVal: Date): Text[20]
    var
        String: Codeunit "NPR String Library";
        Day: Text[2];
        Month: Text[2];
        Year: Text[4];
    begin
        if DateVal = 0D then exit('');

        Day := String.PadStrLeft(Format(Date2DMY(DateVal, 1)), 2, '0', false);
        Month := String.PadStrLeft(Format(Date2DMY(DateVal, 2)), 2, '0', false);
        Year := Format(Date2DMY(DateVal, 3));

        exit(Day + Month + Year);
    end;

    procedure RemoveSpeacialChars(var Text: Text[1024])
    var
        Ch10: Char;
        Ch13: Char;
        Itt: Integer;
    begin
        Ch10 := 10;
        Ch13 := 13;

        if SpecialCharString = '' then begin
            SpecialCharString := Format(Ch10) + Format(Ch13) + FieldStartDelimeter + FieldEndDelimeter + FieldSeparator;
            for Itt := 1 to StrLen(SpecialCharString) do
                ReplaceCharString += ' ';
        end;

        Text := ConvertStr(Text, SpecialCharString, ReplaceCharString);
    end;

    local procedure ResolveDelimeters(ConvertString: Text[30]): Text[30]
    var
        String: Codeunit "NPR String Library";
    begin
        String.Construct(ConvertString);
        String.Replace('<NEWLINE>', NEWLINE);
        String.Replace('<TAB>', TAB);
        String.Replace('<SPACE>', SPACE);
        exit(String.Text);
    end;

    local procedure TestAndSet(var ToSetAndTest: Text[30]; Value: Text[30])
    begin
        if ToSetAndTest = '' then
            ToSetAndTest := Value;
    end;

    local procedure "-- Char Contants"()
    begin
    end;

    local procedure CR(): Text[1]
    var
        c13: Char;
    begin
        c13 := 13;
        exit(Format(c13));
    end;

    local procedure EOF(): Text[1]
    var
        c26: Char;
    begin
        c26 := 26;
        exit(Format(c26))
    end;

    local procedure LF(): Text[1]
    var
        c10: Char;
    begin
        c10 := 10;
        exit(Format(c10));
    end;

    local procedure NEWLINE(): Text[2]
    begin
        exit(CR + LF);
    end;

    local procedure SPACE(): Text[1]
    var
        c32: Char;
    begin
        c32 := 32;
        exit(Format(c32))
    end;

    local procedure TAB(): Text[1]
    var
        c9: Char;
    begin
        c9 := 9;
        exit(Format(c9))
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleExportMedia(var FieldRef: FieldRef; var TempBlob: Codeunit "Temp Blob")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleExportMediaSet(var FieldRef: FieldRef; var TempBlob: Codeunit "Temp Blob"; Index: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetMediaSetCount(var FieldRef: FieldRef; var "Count": Integer)
    begin
    end;
}

