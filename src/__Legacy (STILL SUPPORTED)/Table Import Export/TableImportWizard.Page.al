page 6014485 "NPR Table Import Wizard"
{
    // NPR5.31/JLK /20170331  CASE 268274 Changed ENU Caption
    // NPR5.38/MHA /20180105  CASE 301053 Removed FileMode::ADOStream
    // NPR5.41/TS  /20180105  CASE 300893 Removed OptionCation on Text Fields
    // NPR5.41/THRO/20180410  CASE 308570 Option to use xml-format for field values
    // NPR5.42/EMGO/20180415  CASE 315267 Removed FileMode::OStream
    // NPR5.48/MMV /20181217  CASE 340086 Changed defaults, added escape character field

    Caption = 'Table Import Wizard';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Execution,Template,Data,Test6,Test7,Test8';
    SourceTable = AllObj;
    SourceTableTemporary = true;
    SourceTableView = SORTING("Object Type", "Object ID")
                      ORDER(Ascending)
                      WHERE("Object Type" = CONST(Table));
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            grid(Control6150617)
            {
                GridLayout = Columns;
                ShowCaption = false;
                group(Control6150621)
                {
                    ShowCaption = false;
                    repeater(Control6150614)
                    {
                        Editable = false;
                        ShowCaption = false;
                        field("Object ID"; "Object ID")
                        {
                            ApplicationArea = All;
                            Editable = false;

                            trigger OnLookup(var Text: Text): Boolean
                            var
                                AllObjects: Page "All Objects";
                                AllObj: Record AllObj;
                                ac: Action;
                            begin
                                AllObj.SetRange("Object Type", AllObj."Object Type"::Table);

                                if "Object ID" > 0 then
                                    if AllObj.Get(AllObj."Object Type"::Table, "Object ID") then;

                                AllObjects.SetTableView(AllObj);
                                AllObjects.SetRecord(AllObj);
                                AllObjects.LookupMode(true);

                                if AllObjects.RunModal = ACTION::LookupOK then begin
                                    AllObjects.GetRecord(AllObj);
                                    TransferFields(AllObj);
                                    Insert;
                                end;
                            end;
                        }
                        field("Object Name"; "Object Name")
                        {
                            ApplicationArea = All;
                            Editable = false;

                            trigger OnValidate()
                            var
                                AllObj: Record AllObj;
                            begin
                                AllObj.Get(AllObj."Object Type"::Table, "Object ID");
                                "Object Name" := AllObj."Object Name";
                            end;
                        }
                        field("TempCommentLine.Comment"; TempCommentLine.Comment)
                        {
                            ApplicationArea = All;
                            Caption = 'Rows Imported';
                        }
                    }
                }
                group(Formatting)
                {
                    Caption = 'Formatting';
                    field(FieldStartDelimeter; FieldStartDelimeter)
                    {
                        ApplicationArea = All;
                        Caption = 'Field Start Delimeter';
                    }
                    field(FieldEndDelimeter; FieldEndDelimeter)
                    {
                        ApplicationArea = All;
                        Caption = 'Field End Delimeter';
                    }
                    field(FieldSeparator; FieldSeparator)
                    {
                        ApplicationArea = All;
                        Caption = 'Field Separator';
                    }
                    field(RecordSeparator; RecordSeparator)
                    {
                        ApplicationArea = All;
                        Caption = 'Record Separator';
                    }
                    field(DataItemSeparator; DataItemSeparator)
                    {
                        ApplicationArea = All;
                        Caption = 'Data Item Separator';
                    }
                    field(EscapeCharacter; EscapeCharacter)
                    {
                        ApplicationArea = All;
                        Caption = 'Escape Character';
                    }
                    field(ImportDataInXmlFormat; ImportDataInXmlFormat)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Xml-Format';
                    }
                }
                group("Data Settings")
                {
                    Caption = 'Data Settings';
                    field(InFileEncoding; InFileEncoding)
                    {
                        ApplicationArea = All;
                        Caption = 'File Encoding';
                    }
                    field(FileMode; FileMode)
                    {
                        ApplicationArea = All;
                        Caption = 'File Mode';
                    }
                    field(ErrorOnMissingFields; ErrorOnMissingFields)
                    {
                        ApplicationArea = All;
                        Caption = 'Error On Missing Fields';
                    }
                    field(ErrorOnDataMismatch; ErrorOnDataMismatch)
                    {
                        ApplicationArea = All;
                        Caption = 'Error On Data Mismatch';
                    }
                    field(AutoSave; AutoSave)
                    {
                        ApplicationArea = All;
                        Caption = 'AutoSave';
                    }
                    field(AutoUpdate; AutoUpdate)
                    {
                        ApplicationArea = All;
                        Caption = 'AutoUpdate';
                    }
                    field(AutoReplace; AutoReplace)
                    {
                        ApplicationArea = All;
                        Caption = 'AutoReplace';
                    }
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Run")
            {
                Caption = 'Run';
                Image = Export;
                Promoted = true;
                PromotedCategory = Category4;
                ApplicationArea=All;

                trigger OnAction()
                begin
                    RunImport();
                end;
            }
            action(DeleteAlll)
            {
                Caption = 'Delete All';
                Image = DeleteQtyToHandle;
                Promoted = true;
                PromotedCategory = Category5;
                ApplicationArea=All;

                trigger OnAction()
                begin
                    ClearTableInfo();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TempCommentLine.SetRange("No.", Format("Object ID"));
        if TempCommentLine.FindSet then;
    end;

    trigger OnOpenPage()
    begin
        SetDefaultVars;
        CurrPage.Editable(true);
        CurrPage.Update(false);
    end;

    var
        TempCommentLine: Record "Comment Line" temporary;
        "--- Input Vars ---": Integer;
        AutoSave: Boolean;
        AutoUpdate: Boolean;
        AutoReplace: Boolean;
        FileName: Text[250];
        FieldStartDelimeter: Text[10];
        FieldEndDelimeter: Text[10];
        FieldSeparator: Text[10];
        RecordSeparator: Text[30];
        DataItemSeparator: Text[30];
        ShowStatus: Boolean;
        InFileEncoding: Text[30];
        FileMode: Option ,,DotNetStream;
        TrimSpecialChars: Boolean;
        ImportDataInXmlFormat: Boolean;
        EscapeCharacter: Text[1];
        ErrorOnMissingFields: Boolean;
        ErrorOnDataMismatch: Boolean;
        RegenAutoInc: Boolean;

    procedure AddTable(TableID: Integer)
    var
        AllObj: Record AllObj;
    begin
        Init;
        AllObj.Get(AllObj."Object Type"::Table, TableID);
        TransferFields(AllObj);
        if Insert then;
    end;

    procedure ClearTableInfo()
    begin
        DeleteAll;
    end;

    procedure RunImport()
    var
        TempField: Record "Field" temporary;
        TempTable: Record AllObj temporary;
        TableImportLibrary: Codeunit "NPR Table Import Library";
    begin
        DeleteAll;
        TempCommentLine.DeleteAll;
        Clear(TempCommentLine);

        TableImportLibrary.Reset;
        TableImportLibrary.SetRecordSeparator(RecordSeparator);
        TableImportLibrary.SetDataItemSeparator(DataItemSeparator);
        TableImportLibrary.SetFieldStartDelimeter(FieldStartDelimeter);
        TableImportLibrary.SetFieldEndDelimeter(FieldEndDelimeter);
        TableImportLibrary.SetFieldSeparator(FieldSeparator);
        //-NPR5.48 [340086]
        TableImportLibrary.SetEscapeCharacter(EscapeCharacter);
        //+NPR5.48 [340086]

        TableImportLibrary.SetAutoSave(AutoSave);
        TableImportLibrary.SetAutoUpdate(AutoUpdate);
        TableImportLibrary.SetAutoReplace(AutoReplace);
        TableImportLibrary.SetFileName(FileName);
        //-NPR5.48 [340086]
        //TableImportLibrary.SetRaiseErrors(RaiseErrors);
        TableImportLibrary.SetErrorOnDataMismatch(ErrorOnDataMismatch);
        TableImportLibrary.SetErrorOnMissingFields(ErrorOnMissingFields);
        TableImportLibrary.SetRegenAutoIncrements(RegenAutoInc);
        //+NPR5.48 [340086]
        TableImportLibrary.SetShowStatus(ShowStatus);
        //-NPR5.41 [308570]
        TableImportLibrary.SetXmlDataFormat(ImportDataInXmlFormat);
        //+NPR5.41 [308570]

        case FileMode of
            //-NPR5.38 [301053]
            // FileMode::ADOStream :
            //   BEGIN
            //     TableImportLibrary.SetFileModeADO;
            //     TableImportLibrary.SetInFileEncoding(InFileEncoding);
            //   END;
            //+NPR5.38 [301053]
            //-NPR5.42
            //FileMode::OStream :
            //  TableImportLibrary.SetFileModeOStream;
            //+NPR5.42
            FileMode::DotNetStream:
                begin
                    TableImportLibrary.SetFileModeDotNetStream;
                    TableImportLibrary.SetInFileEncoding(InFileEncoding);
                end;
        end;

        //-NPR5.48 [340086]
        // IF NOT TableImportLibrary.RUN THEN
        //  MESSAGE(TableImportLibrary.GetLastPosition());
        //
        // TableImportLibrary.GetImportHistory(Rec);
        // TableImportLibrary.GetImportDetails(TempCommentLine);
        // TableImportLibrary.Reset;

        if TableImportLibrary.Run then begin
            TableImportLibrary.GetImportHistory(Rec);
            TableImportLibrary.GetImportDetails(TempCommentLine);
        end else
            Message(TableImportLibrary.GetLastPosition());
        //+NPR5.48 [340086]

        CurrPage.Update(false);
    end;

    procedure SetDefaultVars()
    begin
        AutoSave := true;
        AutoUpdate := true;
        AutoReplace := false;
        //-NPR5.48 [340086]
        //RaiseErrors           := FALSE;
        ErrorOnDataMismatch := true;
        ErrorOnMissingFields := false;
        //+NPR5.48 [340086]
        ShowStatus := true;
        InFileEncoding := 'utf-8';
        FileMode := FileMode::DotNetStream;
        TrimSpecialChars := false;
        FileName := '';
        //-NPR5.48 [340086]
        // FieldStartDelimeter   := '"';
        // FieldEndDelimeter     := '"';
        // FieldSeparator        := ';';
        FieldStartDelimeter := '';
        FieldEndDelimeter := '';
        FieldSeparator := '|';
        //+NPR5.48 [340086]
        RecordSeparator := '<NEWLINE>';
        DataItemSeparator := '<NEWLINE><NEWLINE>';
        //-NPR5.41 [308570]
        ImportDataInXmlFormat := true;
        //+NPR5.41 [308570]
        //-NPR5.48 [340086]
        EscapeCharacter := '\';
        //+NPR5.48 [340086]
    end;
}

