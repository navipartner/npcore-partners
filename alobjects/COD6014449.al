codeunit 6014449 "Table Import Library"
{
    // Table Export Library.
    //  Work started by Nicolai Esbensen.
    // 
    //  Library for importing files produced by the Table Export Library.
    //  Provides the same functionality as dataports, with the extra
    //  options of chosing import encoding type and to be run from an Application Server.
    // 
    //  Modifications contributing to import routines are welcome. However,
    //  only reference std. functionality. Extend the codeunit by builing upon it
    //  rather than modifying it.
    // 
    //  Current implementation expects table information in the file, as produced
    //  by the Table Export Library (when SetWriteTableInformation is invoked with
    //  a parameter value equal to TRUE).
    // 
    //  Sample code and the individual functions and their purpose are listed below.
    // ---------------------------------------------------------------------------
    //   ####################################################################################
    //   Sample code for importing a batch of tables is set below.
    //   1. SetFileModeADO;
    //   2. SetFileName('C:\Import\ImportSample.txt');
    //   3. SetShowStatus(TRUE);
    //   4. ImportTableBatch;
    // 
    //   ####################################################################################
    // 
    //   "ImportTableBatch()"
    //    Starts the import. Properties for the import should be set before invoking this
    //    method for the import to have effect. See the properties below.
    // 
    //   ####################   Properties              #####################################
    //   "SetFileName(FileNameIn : Text[250])"
    //    Sets the filename to use for the export. If no file is specified a dialog will request
    //    a proper filename to use for the export.
    // 
    //   "SetAutoSave(AutoSaveIn : Boolean)"
    //    Sets the import to automatically insert records.
    // 
    //   "SetAutoUpdate(AutoUpdateIn : Boolean)"
    //    Sets the import  to automatically update Records
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
    //   "GetTempTable(Index : Integer;VAR RecordRef : RecordRef)"
    //    Will return a record reference to a temporary record, for the record of the
    //    specified Table No. I the recordref is instantiated the contents of the
    //    internal temp record reference will be copied to the recordreference argument value.
    // 
    // NPR5.38/MHA /20180105  CASE 301053 Removed FileMode::ADO
    // NPR5.41/THRO/20180410  CASE 308570 Option to import in xml data format
    // NPR5.41/JDH /20180427 CASE 313106 Removed unused vars
    // NPR5.42/MMV /20180502  CASE 313693 Test for auto increment fields via object metadata read instead of inserting data.
    // NPR5.42/EMGO/20180515 CASE 315267 Changed file upload to not use dot net client side.
    //                                   Removed FileMode::OStream
    // NPR5.48/MMV /20181217 CASE 340086 Support for tablefield property "ObsoleteState" (NAV2018+), performance improvements, added escaping for robustness without field delimiters bloating size.
    //                                   "Raise Errors" split into "Error on missing fields" and "Error on data validation".
    //                                   Known issue: imports based on delimiters without escaping is still not fixed for field values containing the seperator or delimiter values!
    // NPR5.48/MMV /20190130 CASE 342396 Added delete all before import option
    //                                   Added MediaSet & Media handlers via events, so NAV2017+ can handle it.
    // NPR5.50/MMV /20190403 CASE 351021 Better delimiter handling and re-added support for unknown record count.
    // 
    // KNOWN BUG: IF DELIMITER VALUES ARE ALSO INSIDE THE FIELD VALUES IN NON-ESCAPED FORM, THERE WILL NOT BE ANY FANCY ATTEMPTS AT NARROWING DOWN WHAT IS A VALUE AND WHAT IS A DELIMITER!


    trigger OnRun()
    begin
        ImportTableBatch;
    end;

    var
        CurrentTableNo: Integer;
        CurrentRecordCount: Integer;
        CurrentRecRef: RecordRef;
        CurrentTableCount: Integer;
        CurrentFieldNo: Integer;
        CurrentRecordNo: Integer;
        CurrentValue: Text;
        TableExists: Boolean;
        TotalTableCount: Integer;
        ParseMode: Option ImportInfo,TableInfo,"Fields",FieldTypes,Records;
        LocalRecRef: RecordRef;
        LastTokenConsumed: Text[2];
        Lookahead: Integer;
        TempImportedObjects: Record AllObj temporary;
        TempObjectCommentLines: Record "Comment Line" temporary;
        TempExpectedTables: Record AllObj temporary;
        TempFieldsToImport: Record "Field" temporary;
        TempFieldsToSkip: Record "Field" temporary;
        TempAutoIncrementFields: Record "Field" temporary;
        FieldCount: Integer;
        FileMode: Option ,DotNet;
        IsFileOpen: Boolean;
        IsProcessingBatch: Boolean;
        IStream: InStream;
        InFile: File;
        InputEncoding: Text[50];
        DotNetStream: DotNet StreamReader;
        DotNetEncoding: DotNet Encoding;
        DotNetFilePath: Text;
        DotNetReadArray: DotNet Array;
        AutoSave: Boolean;
        AutoUpdate: Boolean;
        AutoReplace: Boolean;
        FileName: Text[250];
        FieldStartDelimeter: Text[5];
        FieldEndDelimeter: Text[5];
        FieldSeparator: Text[5];
        RecordSeparator: Text[30];
        DataItemSeparator: Text[30];
        ErrorOnDataMismatch: Boolean;
        ErrorOnMissingFields: Boolean;
        ShowStatus: Boolean;
        TrimSpecialChars: Boolean;
        SpecialCharString: Text[30];
        ReplaceCharString: Text[30];
        UseTempTable: Boolean;
        EscapeCharacter: Text[1];
        RegenAutoIncrements: Boolean;
        DeleteAllBeforeImport: Boolean;
        "-- Dialog": Integer;
        DialogValues: array [3] of Integer;
        ProgressDialog: Dialog;
        TxtProgess: Label 'Importing ##1######\@@2@@@@@@@@@@@@@@@@@\@@3@@@@@@@@@@@@@@@@@';
        IsDialogOpen: Boolean;
        InputCharsBuffer: Text;
        InputCharsRead: Integer;
        InputCharsInBuffer: Integer;
        ErrImcompatibleTypes: Label 'Error. Incompatible type for table %1, field no. %2.  (%3 vs. %4[%5]) ';
        TempRecordRefs: array [10] of RecordRef;
        ErrTableNotExpected: Label 'Error. Table no. %1 was not expected.';
        UseXmlDataFormat: Boolean;
        Text_UploadCaption: Label 'Choose file:';
        Text_ImportCancel: Label 'Import was cancelled or upload to NST failed.';
        ErrNavEncoding: Label 'Only utf-8 is supported for NAV stream input';
        ErrFormat: Label 'Invalid input file. Expected line start %1 in mode %2';
        FieldStartDelimiterSet: Boolean;
        FieldEndDelimiterSet: Boolean;

    procedure ImportTableBatch()
    begin
        OpenFileForImport;

        OpenDialog;

        ParseFile;

        IsProcessingBatch := false;

        CloseFileForImport;

        CloseDialog;
    end;

    local procedure ParseFile()
    var
        LineStart: Text[10];
    begin
        //-NPR5.48 [340086]
        // UpdateBuffer();
        // WHILE NOT EOS DO BEGIN
        //  IF ParseMode IN [ParseMode::ImportInfo,ParseMode::TableInfo,ParseMode::Records] THEN
        //    LineStart  := Peek(10)
        //  ELSE
        //    LineStart := '';
        //  CASE TRUE OF
        //    COPYSTR(LineStart,1,6) = 'Tables' :
        //      BEGIN
        //        ReadImportInfo;
        //        ParseMode := ParseMode::TableInfo;
        //      END;
        //    (COPYSTR(LineStart,1,5) = 'Table') AND (ParseMode = ParseMode::TableInfo) :
        //      BEGIN
        //        ReadTableNo;
        //        ParseMode         := ParseMode::TableInfo;
        //        CurrentRecordNo   := 0;
        //        CurrentTableCount += 1;
        //        CheckTableExists;
        //        CurrentRecRef.CLOSE;
        //        LocalRecRef.CLOSE;
        //        CheckTableExpected(CurrentTableNo);
        //        OpenTable;
        //        UpdateProgessDialog(2,CurrentTableCount,TotalTableCount);
        //        UpdateDialog(1,CurrentTableNo);
        //        AddImportedTable(CurrentTableNo);
        //      END;
        //    COPYSTR(LineStart,1,7) = 'Records' :
        //      BEGIN
        //        ReadRecordCount;
        //        ParseMode := ParseMode::Fields;
        //      END;
        //    ParseMode = ParseMode::Fields :
        //      BEGIN
        //        ReadFieldListDefinition;
        //        ParseMode := ParseMode::FieldTypes;
        //      END;
        //    ParseMode = ParseMode::FieldTypes :
        //      BEGIN
        //        ReadFieldTypeDefinitions();
        //        ParseMode := ParseMode::Records;
        //        CurrentRecordNo   := 1;
        //      END;
        //    ParseMode = ParseMode::Records :
        //      BEGIN
        //        IF Peek(STRLEN(DataItemSeparator)) <> DataItemSeparator THEN BEGIN
        //          ParseMode := ParseMode::Records;
        //          ParseRecord;
        //          UpdateProgessDialog(3,CurrentRecordNo,CurrentRecordCount);
        //          CurrentRecordNo += 1;
        //        END ELSE BEGIN
        //          ParseMode := ParseMode::TableInfo;
        //          Read(STRLEN(DataItemSeparator));
        //          IF UseTempTable THEN
        //            TempRecordRefs[CurrentTableCount] := CurrentRecRef.DUPLICATE;
        //          AddImportedDetails();
        //        END;
        //      END;

        UpdateBuffer();

        while not EOS do begin
          case ParseMode of
            ParseMode::Records :
              begin
        //-NPR5.50 [351021]
                if Peek(StrLen(DataItemSeparator)) <> DataItemSeparator then begin
        //+NPR5.50 [351021]
                  ParseRecord;
                  UpdateProgessDialog(3,CurrentRecordNo,CurrentRecordCount);
                  CurrentRecordNo += 1;
        //-NPR5.50 [351021]
        //        IF (CurrentRecordNo > CurrentRecordCount) THEN BEGIN
                end else begin
        //+NPR5.50 [351021]
                  ParseMode := ParseMode::TableInfo;
                  Read(StrLen(DataItemSeparator));
                  if UseTempTable then
                    TempRecordRefs[CurrentTableCount] := CurrentRecRef.Duplicate;
                  AddImportedDetails();
                end;
              end;
            ParseMode::TableInfo :
              begin
                LineStart := Peek(7);
                case true of
                  (CopyStr(LineStart,1,5) = 'Table') :
                    begin
                      ReadTableNo;
                      CurrentTableCount += 1;
                      if CheckTableExists() then begin
                        CurrentRecRef.Close;
                        LocalRecRef.Close;
                        CheckTableExpected(CurrentTableNo);
                        OpenTable;
                        UpdateProgessDialog(2,CurrentTableCount,TotalTableCount);
                        UpdateDialog(1,CurrentTableNo);
                        AddImportedTable(CurrentTableNo);
                      end;
                    end;
                  (LineStart = 'Records') :
                    begin
                      TempFieldsToImport.Reset;
                      TempFieldsToImport.DeleteAll;
                      TempFieldsToSkip.Reset;
                      TempFieldsToSkip.DeleteAll;
                      TempAutoIncrementFields.Reset;
                      TempAutoIncrementFields.DeleteAll;
                      ReadRecordCount;
                      ParseMode := ParseMode::Fields;
                    end;
                  else
                    Error(ErrFormat, 'Table/Record', 'TableInfo');
                end;
              end;
            ParseMode::FieldTypes :
              begin
                ReadFieldTypeDefinitions();
                FieldCount := TempFieldsToImport.Count;
                CurrentRecordNo   := 1;
                ParseMode := ParseMode::Records;
              end;
            ParseMode::Fields :
              begin
                ReadFieldListDefinition;
                ParseMode := ParseMode::FieldTypes;
              end;
            ParseMode::ImportInfo :
              begin
                LineStart := Peek(6);
                if not (LineStart = 'Tables') then
                  Error(ErrFormat, 'Tables', 'ImportInfo');

                ReadImportInfo;
                ParseMode := ParseMode::TableInfo;
              end;
        //+NPR5.48 [340086]
          end;
          Clear(LastTokenConsumed);
        end;

        AddImportedDetails();

        if (CurrentTableNo > 0) and UseTempTable then
          TempRecordRefs[CurrentTableCount] := CurrentRecRef.Duplicate;
    end;

    procedure ReadImportInfo()
    var
        SplitArray: DotNet Array;
    begin
        //-NPR5.48 [340086]
        //String.Construct(ReadLine);
        //EVALUATE(TotalTableCount,String.SelectStringSep(2,':'));
        SplitString(ReadUntil(RecordSeparator),':',SplitArray);
        Evaluate(TotalTableCount, SplitArray.GetValue(1));
        //+NPR5.48 [340086]
    end;

    local procedure ParseRecord()
    var
        FieldRef: FieldRef;
        Value: Text;
        Skip: Boolean;
        IsLastField: Boolean;
        FieldsRead: Integer;
        FieldsWritten: Integer;
        FieldType: Text;
    begin
        Skip := not TableExists;
        if not Skip then
          CurrentRecRef.Init;

        //-NPR5.48 [340086]
        //TempFieldsToImport.SETRANGE(TableNo,CurrentTableNo);
        //TempFieldsToImport.FINDFIRST;
        TempFieldsToImport.FindSet;
        //+NPR5.48 [340086]

        while CopyStr(LastTokenConsumed,(Lookahead + 1) - StrLen(RecordSeparator), StrLen(RecordSeparator)) <> RecordSeparator do begin
        //-NPR5.48 [340086]
          IsLastField := FieldsRead + 1 >= FieldCount;
        //+NPR5.48 [340086]

          if not Skip and not IgnoreField(TempFieldsToImport.TableNo,TempFieldsToImport."No.") then begin
            FieldRef := CurrentRecRef.Field(TempFieldsToImport."No.");

            CurrentFieldNo := TempFieldsToImport."No.";

        //-NPR5.48 [340086]
        //    IF FORMAT(FieldRef.TYPE) = 'BLOB' THEN BEGIN
        //      EvaluateBlob(FieldRef)
        //    END ELSE BEGIN
        //      Value    := ReadField;

            FieldType := UpperCase(Format(FieldRef.Type));

            if FieldType = 'BLOB' then begin
              EvaluateBlob(FieldRef, IsLastField);
        //-NPR5.48 [342396]
            end else if FieldType = 'MEDIA' then begin
              EvaluateMedia(FieldRef, IsLastField);
            end else if FieldType = 'MEDIASET' then begin
              EvaluateMediaSet(FieldRef, IsLastField);
        //+NPR5.48 [342396]
            end else begin
              Value := ReadField(IsLastField);
              if RegenAutoIncrements then
                if FieldIsInAutoIncrementBuffer(TempFieldsToImport.TableNo, TempFieldsToImport."No.") then
                  Value := '0';
        //+NPR5.48 [340086]

              CurrentValue := Value;

              if Format(FieldRef.Type) = 'Text' then
                Value := CopyStr(Value,1,FieldRef.Length);

              if not UseXmlDataFormat then begin
                if Format(FieldRef.Type) = 'Date' then
                  Value := EvaluateDate(FieldRef,Value);
                if Format(FieldRef.Type) = 'Decimal' then
                  Value := EvaluateDecimal(FieldRef,Value);
        //-NPR5.48 [340086]
        //        IF RaiseErrors THEN
                if ErrorOnDataMismatch then
        //+NPR5.48 [340086]
                  Evaluate(FieldRef,Value)
                else
                  if Evaluate(FieldRef,Value) then;
              end else begin
        //-NPR5.48 [340086]
        //        IF RaiseErrors THEN
                if ErrorOnDataMismatch then
        //+NPR5.48 [340086]
                  Evaluate(FieldRef,Value,9)
                else
                  if Evaluate(FieldRef,Value,9) then;
              end;
            end;
            //-NPR5.48 [340086]
            FieldsWritten += 1;
            //+NPR5.48 [340086]
          end else
        //-NPR5.48 [340086]
        //    ReadField();
            ReadField(IsLastField);
        //+NPR5.48 [340086]

          TempFieldsToImport.Next;
          FieldsRead += 1;
        end;

        //-NPR5.48 [340086]
        // IF NOT Skip AND (CurrentFieldsRead > 1) THEN
        //  StoreRecord;
        if not Skip and (FieldsWritten > 0) then
          StoreRecord;
        //+NPR5.48 [340086]
    end;

    local procedure ReadTableNo()
    var
        SplitArray: DotNet Array;
    begin
        //-NPR5.48 [340086]
        // LineVal := ReadLine;
        // String.Construct(LineVal);
        // EVALUATE(CurrentTableNo,String.SelectStringSep(2,':'));
        SplitString(ReadUntil(RecordSeparator),':',SplitArray);
        Evaluate(CurrentTableNo, SplitArray.GetValue(1));
        //+NPR5.48 [340086]
    end;

    local procedure ReadRecordCount()
    var
        SplitArray: DotNet Array;
    begin
        //-NPR5.48 [340086]
        // String.Construct(ReadLine);
        //EVALUATE(CurrentRecordCount,String.SelectStringSep(2,':'));
        SplitString(ReadUntil(RecordSeparator),':',SplitArray);
        Evaluate(CurrentRecordCount, SplitArray.GetValue(1));
        //+NPR5.48 [340086]
    end;

    local procedure ReadFieldListDefinition()
    var
        FieldNo: Integer;
        Value: Text;
        SplitArray: DotNet Array;
    begin
        //-NPR5.48 [340086]
        // WHILE COPYSTR(LastTokenConsumed,(Lookahead+1) - STRLEN(RecordSeparator)) <> RecordSeparator DO BEGIN
        //  EVALUATE(FieldNo,ReadField);
        //  AddFieldForImport(CurrentTableNo,FieldNo);
        // END;

        SplitString(ReadUntil(RecordSeparator),FieldSeparator,SplitArray);
        foreach Value in SplitArray do begin
        //-NPR5.50 [351021]
        //  IF (FieldStartDelimeter <> '') OR (FieldEndDelimeter <> '') THEN
        //    Value := COPYSTR(Value, STRLEN(FieldStartDelimeter)+1, STRLEN(Value)-STRLEN(FieldStartDelimeter)-STRLEN(FieldEndDelimeter));
        //+NPR5.50 [351021]

          Evaluate(FieldNo, Value);
          AddFieldForImport(CurrentTableNo, FieldNo);
        end;
        //+NPR5.48 [340086]
    end;

    local procedure ReadFieldTypeDefinitions()
    var
        FieldIndex: Integer;
        Value: Text;
        SplitArray: DotNet Array;
    begin
        //-NPR5.48 [340086]
        // WHILE COPYSTR(LastTokenConsumed,(Lookahead+1) - STRLEN(RecordSeparator)) <> RecordSeparator DO BEGIN
        //  FieldIndex      += 1;
        //  FieldTypeString := ReadField;
        //  CheckFieldDefinition(CurrentTableNo,FieldIndex,FieldTypeString);
        // END;

        //CheckTableAutoIncrement(CurrentTableNo);

        SplitString(ReadUntil(RecordSeparator),FieldSeparator,SplitArray);

        if not TableExists then
          exit;

        foreach Value in SplitArray do begin
        //-NPR5.50 [351021]
        //  IF (FieldStartDelimeter <> '') OR (FieldEndDelimeter <> '') THEN
        //    Value := COPYSTR(Value, STRLEN(FieldStartDelimeter)+1, STRLEN(Value)-STRLEN(FieldStartDelimeter)-STRLEN(FieldEndDelimeter));
        //+NPR5.50 [351021]

          FieldIndex += 1;
          CheckFieldDefinition(CurrentTableNo,FieldIndex,Value);
        end;

        CheckTableMetadata(CurrentTableNo);
        //+NPR5.48 [340086]

        TempFieldsToImport.MarkedOnly(true);

        if TempFieldsToImport.FindSet then repeat
          TempFieldsToSkip := TempFieldsToImport;
          TempFieldsToSkip.Insert;
        until TempFieldsToImport.Next = 0;

        TempFieldsToImport.MarkedOnly(false);
    end;

    local procedure ReadField(IsLastField: Boolean) Value: Text
    begin
        //-NPR5.48 [340086]
        //Value := ReadUntil(FieldSeparator)

        if IsLastField then
          exit(ReadUntil(RecordSeparator));
        exit(ReadUntil(FieldSeparator));
        //+NPR5.48 [340086]
    end;

    local procedure ReadUntil(ExitString: Text[2]) Value: Text
    var
        CharRead: Text[1];
        EscapeNext: Boolean;
    begin
        //-NPR5.48 [340086]
        //StringLength  := STRLEN(String);
        //RecSepLength  := STRLEN(RecordSeparator);
        //
        // WHILE (COPYSTR(CharsRead,(Lookahead+1)-StringLength) <> String) AND
        //      (COPYSTR(CharsRead,(Lookahead+1)-RecSepLength) <> RecordSeparator) DO BEGIN
        //
        //  IF (NOT (CharRead IN [FieldEndDelimeter,FieldStartDelimeter])) AND
        //     (CharRead[1] > 20) THEN
        //    Value    += CharRead;
        //
        //  CharRead := GetNextCharacter;
        //
        //  IF STRLEN(CharsRead) = MAXSTRLEN(CharsRead) THEN
        //    CharsRead  := COPYSTR(CharsRead,2) + CharRead
        //  ELSE
        //    CharsRead += CharRead;
        //
        //  LastTokenConsumed := CharsRead;
        // END;

        while true do begin
          CharRead := Read(1);
          SetLastTokenConsumed(CharRead);

          if (CharRead = '') then begin
            exit //EOS
          end else if (EscapeNext) then begin
            EscapeNext := false;
        //-NPR5.50 [351021]
        //    AddCharToValueBuffer(CharRead, Value)
            AddCharToValueBuffer(CharRead, Value, false)
        //+NPR5.50 [351021]
          end else if (CharRead = EscapeCharacter) then begin
            EscapeNext := true
          end else if (CharRead = CopyStr(ExitString,1,1)) then begin
            if (StrLen(ExitString) = 1) then
              exit
            else if (Peek(1) = CopyStr(ExitString,2,1)) then begin
              SetLastTokenConsumed(Read(1));
              exit;
            end else
        //-NPR5.50 [351021]
        //      AddCharToValueBuffer(CharRead, Value)
              AddCharToValueBuffer(CharRead, Value, true)
        //+NPR5.50 [351021]
          end else
        //-NPR5.50 [351021]
        //    AddCharToValueBuffer(CharRead, Value)
            AddCharToValueBuffer(CharRead, Value, true)
        //+NPR5.50 [351021]
        end;
        //+NPR5.48 [340086]
    end;

    local procedure AddCharToValueBuffer(Char: Text[1];var Value: Text;CheckValue: Boolean)
    begin
        //-NPR5.48 [340086]
        //This is the old approach - not robust against non-escaped delimiter values inside a fields value. Use escaping without delimiters instead.
        //Fix for this bug would be to parse delimiter group in pairs and accept any value between start & end, but not worth a fix when no delimiters at all is more optimal..

        //-NPR5.50 [351021]
        //IF (NOT (Char IN [FieldEndDelimeter,FieldStartDelimeter])) AND (Char[1] > 20) THEN
        //  Value += Char;

        if CheckValue then begin
          if (not (Char in [FieldEndDelimeter,FieldStartDelimeter])) and (Char[1] > 20) then
            Value += Char;
        end else
          Value += Char;
        //+NPR5.50 [351021]

        //+NPR5.48 [340086]
    end;

    local procedure SetLastTokenConsumed(Value: Text)
    begin
        //-NPR5.48 [340086]
        if (StrLen(LastTokenConsumed) = MaxStrLen(LastTokenConsumed)) then
          LastTokenConsumed := CopyStr(LastTokenConsumed, 2) + Value
        else
          LastTokenConsumed += Value;
        //+NPR5.48 [340086]
    end;

    local procedure Peek(CharacterCount: Integer): Text[30]
    var
        PreviousPosition: Integer;
        PrevBufferLength: Integer;
    begin
        //-NPR5.48 [340086]
        //CASE FileMode OF
        //  FileMode::OStream :
        //    BEGIN
        //    END;
        //  ELSE BEGIN
        //  IF (InputCharsRead + CharacterCount) >= InputCharsInBuffer THEN BEGIN
        //    UpdateBuffer;
        //    PeekVal := COPYSTR(InputCharsBuffer,InputCharsRead,CharacterCount);
        //  END ELSE BEGIN
        //    PeekVal := COPYSTR(InputCharsBuffer,InputCharsRead,CharacterCount);
        //  END;
        // END;
        //END;

        while ((InputCharsRead + CharacterCount) > InputCharsInBuffer) do begin
          UpdateBuffer;

          if InputCharsInBuffer = PrevBufferLength then
            exit(CopyStr(InputCharsBuffer,InputCharsRead+1,CharacterCount));
          PrevBufferLength := InputCharsInBuffer;
        end;

        exit(CopyStr(InputCharsBuffer,InputCharsRead+1,CharacterCount));
        //+NPR5.48 [340086]
    end;

    procedure UpdateBuffer()
    begin
        //-NPR5.48 [340086]
        // CASE FileMode OF
        //  FileMode::DotNet:
        //    BEGIN
        //      IF (InputCharsRead > InputCharsInBuffer) THEN
        //        InputCharsBuffer   := FileReadText(1024)
        //      ELSE BEGIN
        //        IF InputCharsRead > 0 THEN
        //          InputCharsBuffer := COPYSTR(InputCharsBuffer,InputCharsRead)
        //        ELSE
        //          InputCharsBuffer := COPYSTR(InputCharsBuffer,1);
        //        InputCharsBuffer += FileReadText(1024-STRLEN(InputCharsBuffer));
        //      END;
        //      InputCharsInBuffer := STRLEN(InputCharsBuffer)
        //    END;
        // END;
        //
        // InputCharsRead := 1;

        begin
          if (InputCharsRead >= InputCharsInBuffer) then
            InputCharsBuffer   := FileReadText(4096)
          else begin
            if InputCharsRead > 0 then
              InputCharsBuffer := CopyStr(InputCharsBuffer,InputCharsRead+1)
            else
              InputCharsBuffer := CopyStr(InputCharsBuffer,1);
            InputCharsBuffer += FileReadText(4096);
          end;
          InputCharsInBuffer := StrLen(InputCharsBuffer)
        end;

        InputCharsRead := 0;
        //+NPR5.48 [340086]
    end;

    local procedure StoreRecord()
    begin
        //-NPR5.48 [340086]
        // IF AutoSave THEN
        //  IF NOT CurrentRecRef.INSERT THEN
        //    IF AutoReplace THEN
        //      CurrentRecRef.MODIFY
        //    ELSE IF AutoUpdate THEN
        //      UpdateLocalRecord;

        if not AutoSave then
          exit;

        if (not AutoReplace) and (not AutoUpdate) and ErrorOnDataMismatch then begin
          CurrentRecRef.Insert; //Bulk insert - big perf improvement
          exit;
        end else
          if CurrentRecRef.Insert then
            exit;

        if AutoReplace then begin
          if ErrorOnDataMismatch then
            CurrentRecRef.Modify
          else
            if CurrentRecRef.Modify then;
        end else if AutoUpdate then
          UpdateLocalRecord();
        //+NPR5.48 [340086]
    end;

    local procedure AddFieldForImport(TableNo: Integer;FieldNo: Integer)
    var
        "Fields": Record "Field";
    begin
        //-NPR5.48 [340086]
        // Fields.SETRANGE(TableNo, TableNo);
        // Fields.SETRANGE("No.", FieldNo);
        //
        // IF RaiseErrors THEN
        //  Fields.FINDFIRST
        // ELSE
        //  IF Fields.FINDFIRST THEN;
        if ErrorOnMissingFields then
          Fields.Get(TableNo, FieldNo)
        else
          if Fields.Get(TableNo, FieldNo) then;
        //+NPR5.48 [340086]

        TempFieldsToImport.TableNo := TableNo;
        TempFieldsToImport.Type    := Fields.Type;
        TempFieldsToImport."No."   := FieldNo;
        TempFieldsToImport.Insert;
    end;

    local procedure AddImportedTable(TableNo: Integer)
    begin
        TempImportedObjects."Object Type" := TempImportedObjects."Object Type"::Table;
        TempImportedObjects."Object ID"   := TableNo;
        TempImportedObjects."Object Name" := GetTableName(TableNo);
        TempImportedObjects.Insert;
    end;

    local procedure AddImportedDetails()
    begin
        TempObjectCommentLines."No."   := Format(CurrentTableNo);
        TempObjectCommentLines.Comment := StrSubstNo('%1 Records imported.',CurrentRecordCount);
        if TempObjectCommentLines.Insert then;
    end;

    local procedure CheckFieldDefinition(TableNo: Integer;FieldIndex: Integer;TypeText: Text[50])
    var
        "Fields": Record "Field";
        LocalFieldType: Text[30];
        LocalFieldLength: Integer;
        LocalFieldEnabled: Boolean;
        ImportFieldType: Text[30];
        ImportFieldLength: Integer;
        String: Codeunit "String Library";
    begin
        //-NPR5.48 [340086]
        //TempFieldsToImport.SETRANGE(TableNo, TableNo);
        //+NPR5.48 [340086]
        TempFieldsToImport.FindFirst;
        TempFieldsToImport.Next(FieldIndex-1);

        //-NPR5.48 [340086]
        if not FieldExists(TableNo, TempFieldsToImport."No.") then
          exit;
        //+NPR5.48 [340086]

        LocalFieldType    := GetFieldType(TableNo,TempFieldsToImport."No.");
        LocalFieldLength  := GetFieldLength(TableNo,TempFieldsToImport."No.");
        LocalFieldEnabled := GetFieldEnabled(TableNo,TempFieldsToImport."No.");

        String.Construct(TypeText);
        ImportFieldType := String.SelectStringSep(1,':');
        if String.CountOccurences(':') = 1 then
          Evaluate(ImportFieldLength,DelChr(String.SelectStringSep(2,':'),'=','[]'))
        else
          ImportFieldLength := 0;

        case true of
          ImportFieldType  <> LocalFieldType   :
            begin
              TempFieldsToImport.Mark(true);
        //-NPR5.48 [340086]
        //      IF RaiseErrors THEN
              if ErrorOnDataMismatch then
        //+NPR5.48 [340086]
                Error(ErrImcompatibleTypes,TableNo,TempFieldsToImport."No.",
                      TypeText,LocalFieldType,LocalFieldLength);
            end;
          (ImportFieldLength > LocalFieldLength) and
          (LocalFieldType <> 'Text') :
            begin
              TempFieldsToImport.Mark(true);
        //-NPR5.48 [340086]
        //      IF RaiseErrors THEN
              if ErrorOnDataMismatch then
        //+NPR5.48 [340086]
                Error(ErrImcompatibleTypes,TableNo,TempFieldsToImport."No.",
                      TypeText,LocalFieldType,LocalFieldLength);
            end;
          not LocalFieldEnabled :
            begin
              TempFieldsToImport.Mark(true);
        //-NPR5.48 [340086]
        //      IF RaiseErrors THEN
              if ErrorOnDataMismatch then
        //+NPR5.48 [340086]
                Error(ErrImcompatibleTypes,TempFieldsToImport."No.",TableNo);
            end;
        end;
    end;

    procedure CheckTableMetadata(TableNo: Integer)
    var
        Metadata: Text;
        ObjectMetadata: Record "Object Metadata";
        InStream: InStream;
        XmlDoc: DotNet XmlDocument;
        IsAutoIncrement: Boolean;
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        IsObsolete: Boolean;
    begin
        //-NPR5.48 [340086]
        ObjectMetadata.SetAutoCalcFields(Metadata);
        //+NPR5.48 [340086]
        ObjectMetadata.Get(ObjectMetadata."Object Type"::Table, TableNo);
        if not LoadMetadataXml(ObjectMetadata, XmlDoc) then
          exit;

        //-NPR5.48 [340086]
        // TempFieldsToImport.SETRANGE(TableNo,TableNo);
        // TempFieldsToImport.SETFILTER(Type,'%1|%2',TempFieldsToImport.Type::Integer,TempFieldsToImport.Type::BigInteger);
        // IF TempFieldsToImport.FINDSET THEN REPEAT
        //  IF TryFieldAutoIncrementCheck(TempFieldsToImport."No.", XmlDoc, IsAutoIncrement) THEN
        //    IF IsAutoIncrement THEN
        //      TempFieldsToImport.MARK(TRUE);
        // UNTIL TempFieldsToImport.NEXT = 0;
        // TempFieldsToImport.SETRANGE(Type);

        if TempFieldsToImport.FindSet then repeat
          if TempFieldsToImport.Type in [TempFieldsToImport.Type::Integer, TempFieldsToImport.Type::BigInteger] then
            if TryFieldAutoIncrementCheck(TempFieldsToImport."No.", XmlDoc, IsAutoIncrement) then
              if IsAutoIncrement then begin
                TempAutoIncrementFields := TempFieldsToImport;
                TempAutoIncrementFields.Insert;
              end;

          if FieldIsObsolete(TempFieldsToImport.TableNo, TempFieldsToImport."No.") then
            TempFieldsToImport.Mark(true);
        until TempFieldsToImport.Next = 0;
        //+NPR5.48 [340086]
    end;

    [TryFunction]
    local procedure TryFieldObsoleteCheck(FieldNo: Integer;var XmlDoc: DotNet XmlDocument;var IsObsolete: Boolean)
    begin
        //-NPR5.48 [340086]
        IsObsolete := (XmlDoc.DocumentElement.SelectNodes(StrSubstNo('//*[local-name()=''Field''][@ID=''%1'' and @ObsoleteState=''Removed'']', FieldNo)).Count = 1)
        //+NPR5.48 [340086]
    end;

    [TryFunction]
    local procedure TryFieldAutoIncrementCheck(FieldNo: Integer;var XmlDoc: DotNet XmlDocument;var IsAutoIncrement: Boolean)
    begin
        //-NPR5.42 [313693]
        IsAutoIncrement := (XmlDoc.DocumentElement.SelectNodes(StrSubstNo('//*[local-name()=''Field''][@ID=''%1'' and @AutoIncrement=''1'']', FieldNo)).Count = 1)
        //+NPR5.42 [313693]
    end;

    local procedure FieldIsObsolete(TableNo: Integer;FieldNo: Integer): Boolean
    var
        FieldRecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NPR5.48 [340086]
        FieldRecRef.Open(DATABASE::Field);
        if not FieldRecRef.FieldExist(25) then
          exit(false);

        FieldRef := FieldRecRef.Field(1);
        FieldRef.SetRange(TableNo);

        FieldRef := FieldRecRef.Field(2);
        FieldRef.SetRange(FieldNo);

        FieldRef := FieldRecRef.Field(25); //ObsoleteState in NAV2018+
        FieldRef.SetFilter('<>%1', 2); //Option 2 = Removed

        exit(FieldRecRef.IsEmpty);
        //+NPR5.48 [340086]
    end;

    local procedure FieldIsInAutoIncrementBuffer(TableNo: Integer;FieldNo: Integer): Boolean
    begin
        //-NPR5.48 [340086]
        exit(TempAutoIncrementFields.Get(TableNo, FieldNo));
        //+NPR5.48 [340086]
    end;

    [TryFunction]
    local procedure LoadXmlInStream(var InStream: InStream;var XmlDoc: DotNet XmlDocument)
    begin
        //-NPR5.42 [313693]
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStream);
        //+NPR5.42 [313693]
    end;

    local procedure LoadMetadataXml(ObjectMetadata: Record "Object Metadata";var XmlDoc: DotNet XmlDocument): Boolean
    var
        InStream: InStream;
    begin
        //-NPR5.42 [313693]
        if not ObjectMetadata.Metadata.HasValue then
          exit(false);

        //-NPR5.48 [340086]
        //ObjectMetadata.CALCFIELDS(Metadata);
        //+NPR5.48 [340086]
        ObjectMetadata.Metadata.CreateInStream(InStream);
        if not LoadXmlInStream(InStream,XmlDoc) then
          exit(false);

        exit(not IsNull(XmlDoc.DocumentElement));
        //+NPR5.42 [313693]
    end;

    local procedure CheckTableExpected(TableID: Integer)
    begin
        if TempExpectedTables.Count > 0 then
          if not TempExpectedTables.Get(TempExpectedTables."Object Type"::Table,TempExpectedTables."Object ID") then
            Error(ErrTableNotExpected);
    end;

    procedure FieldExists(TableNo: Integer;FieldNo: Integer) Exists: Boolean
    var
        "Fields": Record "Field";
    begin
        //-NPR5.48 [340086]
        // Exists := Fields.GET(CurrentTableNo,FieldNo);
        // IF RaiseErrors AND NOT Exists THEN
        //  Fields.GET(CurrentTableNo,FieldNo)
        // ELSE
        //  EXIT(Exists);

        Fields.SetRange(Enabled, true);
        Fields.SetRange(TableNo, TableNo);
        Fields.SetRange("No.", FieldNo);
        Exists := not Fields.IsEmpty;
        if ErrorOnMissingFields and not Exists then
          Fields.FindFirst;
        //+NPR5.48 [340086]
    end;

    procedure IgnoreField(TableNo: Integer;FieldNo: Integer): Boolean
    begin
        //-NPR5.48 [340086]
        // TempFieldsToSkip.SETRANGE(TableNo,TableNo);
        // TempFieldsToSkip.SETRANGE("No.",FieldNo);
        // EXIT(TempFieldsToSkip.FINDFIRST);
        if not FieldExists(TableNo, FieldNo) then
          exit(true);
        exit(TempFieldsToSkip.Get(TableNo, FieldNo));
        //+NPR5.48 [340086]
    end;

    local procedure OpenTable()
    begin
        if TableExists then begin
          CurrentRecRef.Open(CurrentTableNo,UseTempTable);
          LocalRecRef.Open(CurrentTableNo);

        //-NPR5.48 [342396]
          if DeleteAllBeforeImport and (not UseTempTable) then
            CurrentRecRef.DeleteAll;
        //+NPR5.48 [342396]
        end;
    end;

    procedure CheckTableExists(): Boolean
    var
        TableMetadata: Record "Table Metadata";
        TableMetadataRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NPR5.48 [340086]
        // TableExists := Tables.GET(Tables."Object Type"::Table,CurrentTableNo);
        // IF RaiseErrors AND NOT TableExists THEN
        //  Tables.GET(Tables."Object Type"::Table,CurrentTableNo);

        TableMetadataRef.Open(DATABASE::"Table Metadata");
        if TableMetadataRef.FieldExist(13) then begin
          //NAV2018+
          FieldRef := TableMetadataRef.Field(1); //ID
          FieldRef.SetRange(CurrentTableNo);
          FieldRef := TableMetadataRef.Field(13); //ObsoleteState in NAV2018+
          FieldRef.SetFilter('<>%1', 2); //Option 2 = Removed
          TableExists := not TableMetadataRef.IsEmpty;
          if ErrorOnMissingFields and not TableExists then
            TableMetadataRef.FindFirst;
        end else begin
          //NAV2016-17
          TableExists := TableMetadata.Get(CurrentTableNo);
          if ErrorOnMissingFields and not TableExists then
            TableMetadata.Get(CurrentTableNo);
        end;

        exit(TableExists);
        //+NPR5.48 [340086]
    end;

    local procedure OpenFileForImport()
    begin
        if IsFileOpen then
          exit;

        case FileMode of
          FileMode::DotNet : OpenDotNetStreamForImport;
        end;

        IsFileOpen := true;
    end;

    procedure OpenDotNetStreamForImport()
    var
        FileManagement: Codeunit "File Management";
        Uploaded: Boolean;
        TempServerFileName: Text;
        ClientFileName: Text;
    begin
        SetDefaultValues;

        //-NPR5.48 [340086]
        if FileName <> '' then begin
          DotNetFilePath := FileName;
          DotNetStream := DotNetStream.StreamReader(DotNetFilePath, DotNetEncoding.GetEncoding(InputEncoding));
        end else begin
        //+NPR5.48 [340086]
          TempServerFileName := FileManagement.ServerTempFileName('.txt');
          Uploaded := Upload(Text_UploadCaption, '', 'Text Files (*.txt)|*.txt', ClientFileName, TempServerFileName);
          if Uploaded then begin
            FileManagement.ValidateFileExtension(TempServerFileName,'.txt');
            DotNetFilePath := TempServerFileName;
            DotNetStream := DotNetStream.StreamReader(DotNetFilePath, DotNetEncoding.GetEncoding(InputEncoding));
          end else
            Error(Text_ImportCancel);
        end;
    end;

    local procedure CloseFileForImport()
    begin
        case FileMode of
          FileMode::DotNet  : CloseDotNetStreamForImport;
        end;

        IsFileOpen := false;
    end;

    procedure CloseDotNetStreamForImport()
    begin
        DotNetStream.Close;
    end;

    procedure FileReadText("Count": Integer): Text
    var
        Index: Integer;
    begin
        case FileMode of
        //-NPR5.48 [340086]
        //  FileMode::DotNet :
        //    BEGIN
        //      Index := 1;
        //      WHILE (Index <= Count) AND NOT DotNetStream.EndOfStream DO BEGIN
        //        ReturnText[Index] := DotNetStream.Read;
        //        Index += 1;
        //      END;
        //    END;
          FileMode::DotNet : exit(FileReadTextDotNet(Count));
        //+NPR5.48 [340086]
        end;
    end;

    local procedure FileReadTextDotNet("Count": Integer) Output: Text
    var
        String: DotNet String;
        Char: DotNet Char;
        ReadChars: Integer;
        DotNetSubArray: DotNet Array;
    begin
        //-NPR5.48 [340086]
        if Count = 0 then begin //Full line
          if not DotNetStream.EndOfStream then
            Output := DotNetStream.ReadLine() + NEWLINE; //Readd newline so delimiter detection works
        end else begin
          if IsNull(DotNetReadArray) then
            DotNetReadArray := DotNetReadArray.CreateInstance(GetDotNetType(Char), Count);

          ReadChars := DotNetStream.Read(DotNetReadArray, 0, Count);
          if ReadChars > 0 then begin
            if ReadChars <> Count then begin
              DotNetSubArray := DotNetSubArray.CreateInstance(GetDotNetType(Char), ReadChars);
              DotNetReadArray.Copy(DotNetReadArray, DotNetSubArray, ReadChars);
              Output := String.String(DotNetSubArray);
            end else
              Output := String.String(DotNetReadArray);
          end;
        end;
        //+NPR5.48 [340086]
    end;

    local procedure EOS(): Boolean
    begin
        case FileMode of
        //-NPR5.48 [340086]
        //  FileMode::DotNet  : EndOfFile := DotNetStream.EndOfStream AND (InputCharsRead >= InputCharsInBuffer);
            FileMode::DotNet  :
              begin
                if InputCharsRead < InputCharsInBuffer then
                  exit(false);
                exit(DotNetStream.EndOfStream());
              end;
        //+NPR5.48 [340086]
        end;
    end;

    local procedure Read(Characters: Integer) Output: Text
    var
        CharsRead: Integer;
        CharsToRead: Integer;
        CharsRemainingInBuffer: Integer;
    begin
        //-NPR5.48 [340086]
        // FOR Itt := 1 TO Characters DO
        //  ValRead += GetNextCharacter;

        if Characters <= 0 then
          exit('');

        while (CharsRead < Characters) and (InputCharsInBuffer <> 0) do begin
          CharsToRead := Characters-CharsRead;
          CharsRemainingInBuffer := InputCharsInBuffer-InputCharsRead;
          if CharsRemainingInBuffer < CharsToRead then begin
            Output += CopyStr(InputCharsBuffer, InputCharsRead+1, CharsRemainingInBuffer);
            CharsRead += CharsRemainingInBuffer;
            InputCharsRead += CharsRemainingInBuffer;
            UpdateBuffer();
          end else begin
            Output += CopyStr(InputCharsBuffer, InputCharsRead+1, CharsToRead);
            CharsRead += CharsToRead;
            InputCharsRead += CharsToRead;
          end;
        end;
        //+NPR5.48 [340086]
    end;

    local procedure OpenDialog()
    begin
        if GuiAllowed and ShowStatus then
          if not IsDialogOpen then begin
            ProgressDialog.Open(TxtProgess);
            IsDialogOpen := true;
          end;
    end;

    local procedure UpdateDialog(ValueNo: Integer;Value: Integer)
    begin
        if GuiAllowed and ShowStatus then
          ProgressDialog.Update(ValueNo,Value);
    end;

    local procedure UpdateProgessDialog(ValueNo: Integer;Progress: Integer;Total: Integer)
    begin
        if GuiAllowed and ShowStatus then begin
          Progress := Round(Progress/Total *10000,1,'>');
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

    procedure Reset()
    begin
        ClearAll();
        TempExpectedTables.DeleteAll;
        TempFieldsToSkip.DeleteAll;
        TempFieldsToImport.DeleteAll;
        TempImportedObjects.DeleteAll;
        TempObjectCommentLines.DeleteAll;
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
          TestAndSet(FieldEndDelimeter,   '"');
        TestAndSet(FieldSeparator,      ';');
        TestAndSet(RecordSeparator,     NEWLINE);
        TestAndSet(DataItemSeparator,   NEWLINE + NEWLINE);
        if (InputEncoding = '') then begin
          InputEncoding := 'utf-8';
        end;

        Lookahead := 2;
    end;

    procedure SetAutoSave(AutoSaveIn: Boolean)
    begin
        AutoSave    := AutoSaveIn;
    end;

    procedure SetAutoUpdate(AutoUpdateIn: Boolean)
    begin
        AutoUpdate  := AutoUpdateIn;
    end;

    procedure SetAutoReplace(AutoReplaceIn: Boolean)
    begin
        AutoReplace := AutoReplaceIn;
    end;

    procedure SetFileName(FileNameIn: Text[250])
    begin
        FileName            := FileNameIn;
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
        FieldEndDelimeter   := ResolveDelimeters(FieldEndDelimeterIn);
    end;

    procedure SetFieldSeparator(FieldSeparatorIn: Text[30])
    begin
        FieldSeparator      := ResolveDelimeters(FieldSeparatorIn);
    end;

    procedure SetRecordSeparator(RecordSeparatorIn: Text[30])
    begin
        RecordSeparator     := ResolveDelimeters(RecordSeparatorIn);
    end;

    procedure SetDataItemSeparator(DataItemSeparatorIn: Text[30])
    begin
        DataItemSeparator   := ResolveDelimeters(DataItemSeparatorIn);
    end;

    procedure SetExpectedTable(TableID: Integer)
    begin
        TempExpectedTables."Object Type" := TempExpectedTables."Object Type"::Table;
        TempExpectedTables."Object ID"   := TableID;
        TempExpectedTables.Insert;
    end;

    procedure SetErrorOnDataMismatch(Value: Boolean)
    begin
        //-NPR5.48 [340086]
        ErrorOnDataMismatch := Value;
        //+NPR5.48 [340086]
    end;

    procedure SetErrorOnMissingFields(Value: Boolean)
    begin
        //-NPR5.48 [340086]
        ErrorOnMissingFields := Value;
        //+NPR5.48 [340086]
    end;

    procedure SetShowStatus(ShowStatusIn: Boolean)
    begin
        ShowStatus          := ShowStatusIn;
    end;

    procedure SetInFileEncoding(Encoding: Text[50])
    begin
        InputEncoding := Encoding;
    end;

    procedure SetFileModeDotNetStream()
    begin
        FileMode := FileMode::DotNet;
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

    procedure SetRegenAutoIncrements(Value: Boolean)
    begin
        //-NPR5.48 [340086]
        RegenAutoIncrements := Value;
        //+NPR5.48 [340086]
    end;

    procedure SetDeleteAllBeforeImport(DeleteAllBeforeImportIn: Boolean)
    begin
        //-NPR5.48 [342396]
        DeleteAllBeforeImport := DeleteAllBeforeImportIn;
        //+NPR5.48 [342396]
    end;

    procedure EvaluateDate(var FieldRef: FieldRef;Value: Text): Text[20]
    var
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        if Value = '' then exit('');

        Evaluate(Day,CopyStr(Value,1,2));
        Evaluate(Month,CopyStr(Value,3,2));
        Evaluate(Year,CopyStr(Value,5,4));
        exit(Format(DMY2Date(Day,Month,Year)));
    end;

    procedure EvaluateDecimal(var FieldRef: FieldRef;Value: Text): Text
    var
        CultureInfo: DotNet CultureInfo;
    begin
        CultureInfo := CultureInfo.CurrentCulture;
        exit(ConvertStr(Value,'.',CultureInfo.NumberFormat().NumberDecimalSeparator));
    end;

    procedure EvaluateBlob(var FieldRef: FieldRef;IsLastField: Boolean): Text
    var
        TempBlob: Record TempBlob temporary;
    begin
        //-NPR5.48 [342396]
        // LengthText := ReadUntil(':');
        // IF FieldStartDelimeter <> '' THEN
        //  EVALUATE(ReadLength,COPYSTR(LengthText,STRLEN(FieldStartDelimeter)))
        // ELSE
        //  EVALUATE(ReadLength,LengthText);
        //
        // IF ReadLength > 0 THEN BEGIN
        //  BlobValue := Read(ReadLength);
        //  TempBlob.Blob.CREATEOUTSTREAM(OutStream);
        //  MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(BlobValue));
        //  MemoryStream.WriteTo(OutStream);
        //  FieldRef.VALUE := TempBlob.Blob;
        // END;
        //
        // IF IsLastField THEN
        //  ReadUntil(RecordSeparator)
        // ELSE
        //  ReadUntil(FieldSeparator);

        ReadBinary(TempBlob);
        if TempBlob.Blob.HasValue then
          FieldRef.Value := TempBlob.Blob;

        ReadField(IsLastField);
        //+NPR5.48 [342396]
    end;

    local procedure EvaluateMedia(var FieldRef: FieldRef;IsLastField: Boolean)
    var
        TempBlob: Record TempBlob temporary;
        NullGuid: Guid;
    begin
        //-NPR5.48 [342396]
        FieldRef.Value := NullGuid; //Blank reference to existing media.

        ReadBinary(TempBlob);
        if TempBlob.Blob.HasValue then
          OnHandleMediaImport(FieldRef, TempBlob);

        ReadField(IsLastField);
        //+NPR5.48 [342396]
    end;

    local procedure EvaluateMediaSet(var FieldRef: FieldRef;IsLastField: Boolean)
    var
        TempBlob: Record TempBlob temporary;
        NullGuid: Guid;
        MediaInBuffer: Boolean;
    begin
        //-NPR5.48 [342396]
        FieldRef.Value := NullGuid; //Blank reference to existing media set.

        MediaInBuffer := true;
        while (MediaInBuffer) do begin
          ReadBinary(TempBlob);
          if TempBlob.Blob.HasValue then
            OnHandleMediaSetImport(FieldRef, TempBlob);

          if Peek(1) = '^' then
            Read(1)
          else
            MediaInBuffer := false;
        end;

        ReadField(IsLastField);
        //+NPR5.48 [342396]
    end;

    local procedure ReadBinary(var TempBlob: Record TempBlob temporary)
    var
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
        OutStream: OutStream;
        ReadLength: Integer;
        LengthText: Text;
        BlobValue: Text;
    begin
        //-NPR5.48 [342396]
        LengthText := ReadUntil(':');
        Evaluate(ReadLength,LengthText);

        if ReadLength > 0 then begin
          BlobValue := Read(ReadLength);
          TempBlob.Blob.CreateOutStream(OutStream);
          MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(BlobValue));
          MemoryStream.WriteTo(OutStream);
        end;
        //+NPR5.48 [342396]
    end;

    local procedure GetFieldType(TableNo: Integer;FieldNo: Integer): Text[30]
    var
        "Fields": Record "Field";
    begin
        if Fields.Get(TableNo,FieldNo) then
          exit(Format(Fields.Type));
    end;

    local procedure GetFieldLength(TableNo: Integer;FieldNo: Integer): Integer
    var
        "Fields": Record "Field";
    begin
        if Fields.Get(TableNo,FieldNo) then
          exit(Fields.Len);
    end;

    procedure GetFieldEnabled(TableNo: Integer;FieldNo: Integer) Enabled: Boolean
    var
        "Fields": Record "Field";
    begin
        if Fields.Get(TableNo,FieldNo) then
          exit(Fields.Enabled);
    end;

    procedure GetTableName(TableNo: Integer): Text
    var
        AllObj: Record AllObj;
    begin
        AllObj.Get(TempImportedObjects."Object Type",TableNo);
        exit(AllObj."Object Name")
    end;

    procedure GetLastPosition(): Text
    begin
        exit(StrSubstNo('Table %1, field %2, record no. %3, value %4\Error : %5',CurrentTableNo, CurrentFieldNo, CurrentRecordNo,CurrentValue,GetLastErrorText));
    end;

    procedure GetImportHistory(var TempAllObj: Record AllObj temporary)
    begin
        if TempImportedObjects.FindSet then repeat
          TempAllObj.TransferFields(TempImportedObjects);
          TempAllObj.Insert;
        until TempImportedObjects.Next = 0;
    end;

    procedure GetImportDetails(var TempCommentLine: Record "Comment Line" temporary)
    begin
        TempCommentLine.DeleteAll;
        if TempObjectCommentLines.FindSet then repeat
          TempCommentLine.TransferFields(TempObjectCommentLines);
          TempCommentLine.Insert;
        until TempObjectCommentLines.Next = 0;
    end;

    procedure UpdateLocalRecord()
    var
        LocalFieldRef: FieldRef;
        ExternalFieldRef: FieldRef;
        FieldNo: Integer;
    begin
        Clear(LocalRecRef);
        LocalRecRef.Open(CurrentTableNo);
        LocalRecRef.SetPosition(CurrentRecRef.GetPosition);
        if LocalRecRef.Find then;
        if TempFieldsToImport.FindSet then repeat
        //-NPR5.48 [340086]
        //  IF FieldExists(TempFieldsToImport."No.") AND NOT IgnoreField(TempFieldsToImport.TableNo,TempFieldsToImport."No.") THEN BEGIN
          if (not IgnoreField(TempFieldsToImport.TableNo,TempFieldsToImport."No.")) and (not FieldIsInAutoIncrementBuffer(TempFieldsToImport.TableNo, TempFieldsToImport."No.")) then begin
        //+NPR5.48 [340086]
            ExternalFieldRef    := CurrentRecRef.Field(TempFieldsToImport."No.");
            LocalFieldRef       := LocalRecRef.Field(TempFieldsToImport."No.");
            LocalFieldRef.Value := ExternalFieldRef.Value;
          end;
        until TempFieldsToImport.Next = 0;

        //-NPR5.48 [340086]
        //IF RaiseErrors THEN
        if ErrorOnDataMismatch then
        //+NPR5.48 [340086]
          LocalRecRef.Modify
        else
          if LocalRecRef.Modify then;

        LocalRecRef.Close;
    end;

    local procedure ResolveDelimeters(ConvertString: Text[30]): Text[30]
    var
        String: Codeunit "String Library";
    begin
        String.Construct(ConvertString);
        String.Replace('<NEWLINE>', NEWLINE);
        String.Replace('<TAB>',     TAB);
        String.Replace('<SPACE>',   SPACE);
        exit(String.Text);
    end;

    local procedure TestAndSet(var ToSetAndTest: Text[30];Value: Text[30])
    begin
        if ToSetAndTest = '' then
          ToSetAndTest := Value;
    end;

    local procedure SplitString(Text: Text;SplitChar: Text[1];var SplitArray: DotNet Array)
    var
        String: DotNet String;
        CharArray: DotNet Array;
        DotNetChar: DotNet Char;
    begin
        //-NPR5.48 [340086]
        CharArray := CharArray.CreateInstance(GetDotNetType(DotNetChar), 1);
        CharArray.SetValue(SplitChar[1], 0);
        String := Text;
        SplitArray := String.Split(CharArray);
        //+NPR5.48 [340086]
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
        exit (CR + LF);
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
    local procedure OnHandleMediaImport(var FieldRef: FieldRef;var TempBlob: Record TempBlob)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleMediaSetImport(var FieldRef: FieldRef;var TempBlob: Record TempBlob)
    begin
    end;
}

