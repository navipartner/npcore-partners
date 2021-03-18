table 6060151 "NPR Event Word Layout"
{
    Caption = 'Event Word Layout';
    DataClassification = CustomerContent;
    LookupPageID = "NPR Event Word Layouts";

    fields
    {
        field(1; "Source Record ID"; RecordID)
        {
            Caption = 'Source Record ID';
            DataClassification = CustomerContent;
        }
        field(2; Usage; Option)
        {
            Caption = 'Usage';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Customer,Team';
            OptionMembers = " ",Customer,Team;

            trigger OnValidate()
            begin
                case Usage of
                    Usage::" ":
                        "Report ID" := 0;
                    Usage::Customer:
                        "Report ID" := REPORT::"NPR Event Customer Template";
                    Usage::Team:
                        "Report ID" := REPORT::"NPR Event Team Template";
                end;
            end;
        }
        field(5; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = CustomerContent;
        }
        field(10; "Basic Layout Code"; Code[20])
        {
            Caption = 'Basic Layout ID';
            DataClassification = CustomerContent;
            TableRelation = "Custom Report Layout".Code WHERE("Report ID" = FIELD("Report ID"));

            trigger OnValidate()
            begin
                if ("Basic Layout Code" <> xRec."Basic Layout Code") and Layout.HasValue then
                    if not Confirm(StrSubstNo(ConfirmLayoutChange, FieldCaption("Basic Layout Code"))) then
                        Error('');

                if "Basic Layout Code" = '' then begin
                    Clear(Layout);
                    Clear("XML Part");
                end else begin
                    CustomReportLayout.Get("Basic Layout Code");
                    if CustomReportLayout.Layout.HasValue then begin
                        CustomReportLayout.CalcFields(Layout);
                        Layout := CustomReportLayout.Layout;
                    end;
                    if CustomReportLayout."Custom XML Part".HasValue then begin
                        CustomReportLayout.CalcFields("Custom XML Part");
                        "XML Part" := CustomReportLayout."Custom XML Part";
                    end;
                end;
            end;
        }
        field(20; Layout; BLOB)
        {
            Caption = 'Layout';
            DataClassification = CustomerContent;
        }
        field(30; "XML Part"; BLOB)
        {
            Caption = 'XML Part';
            DataClassification = CustomerContent;
        }
        field(40; "Last Modified"; DateTime)
        {
            Caption = 'Last Modified';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Last Modified by User"; Code[50])
        {
            Caption = 'Last Modified by User';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Basic Layout Description"; Text[80])
        {
            CalcFormula = Lookup("Custom Report Layout".Description WHERE(Code = FIELD("Basic Layout Code")));
            Caption = 'Basic Layout Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(80; "Request Page Parameters"; Blob)
        {
            Caption = 'Request Page Parameters';
            DataClassification = CustomerContent;
        }
        field(81; "Use Req. Page Parameters"; Boolean)
        {
            Caption = 'Use Req. Page Parameters';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Use Req. Page Parameters" then
                    RunReportRequestPage()
                else begin
                    Clear(Rec."Request Page Parameters");
                    Message(RequestPageOptionsDeletedMsg);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Source Record ID", Usage)
        {
        }
    }

    trigger OnInsert()
    begin
        GetJobFromRecID(Job);
        Description := StrSubstNo(NewLayoutTxt, Job."No.", Format(Usage));
    end;

    trigger OnModify()
    begin
        SetUpdated();
    end;

    var
        ImportWordTxt: Label 'Import Word Document';
        FileFilterWordTxt: Label 'Word Files (*.docx)|*.docx', Comment = '{Split=r''\|''}{Locked=s''1''}';
        NoRecordsErr: Label 'There is no record in the list.';
        NewLayoutTxt: Label '%1 %2 Layout';
        ErrorInLayoutErr: Label 'Issue found in layout %1 for report ID  %2:\%3.', Comment = '%1=a name, %2=a number, %3=a sentence/error description.';
        CustomReportLayout: Record "Custom Report Layout";
        EventMgt: Codeunit "NPR Event Management";
        ConfirmLayoutChange: Label 'Changing %1 will remove current layout. If you''ve customized it, it will be lost. We suggest that you first run Export Layout and then try changing again. Do you want to continue?';
        Job: Record Job;
        RequestPageOptionsDeletedMsg: Label 'You have cleared the report parameters. Select the check box in the field to show the report request page again.';

    procedure CopyRecord()
    var
        EventCopy: Page "NPR Event Copy Attr./Templ.";
        Job: Record Job;
    begin
        TestField(Usage);
        GetJobFromRecID(Job);
        EventCopy.SetFromEvent(Job."No.", Usage);
        EventCopy.RunModal;
    end;

    procedure GetJobFromRecID(var Job: Record Job)
    var
        RecRef: RecordRef;
    begin
        Clear(Job);
        RecRef.Get("Source Record ID");
        RecRef.SetTable(Job);
    end;

    local procedure SetUpdated()
    begin
        "Last Modified" := RoundDateTime(CurrentDateTime);
        "Last Modified by User" := UserId;
    end;

    procedure ImportLayout(DefaultFileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        FileName: Text;
        FileFilterTxt: Text;
        ImportTxt: Text;
    begin
        if IsEmpty then
            Error(NoRecordsErr);
        ImportTxt := ImportWordTxt;
        FileFilterTxt := FileFilterWordTxt;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob, ImportTxt, DefaultFileName, FileFilterTxt, FileFilterTxt);
        if FileName = '' then
            exit;

        ImportLayoutBlob(TempBlob, UpperCase(FileMgt.GetExtension(FileName)));
    end;

    procedure ImportLayoutBlob(var TempBlob: Codeunit "Temp Blob"; FileExtension: Text[30])
    var
        OutputTempBlob: Codeunit "Temp Blob";
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        DocumentInStream: InStream;
        DocumentOutStream: OutStream;
        ErrorMessage: Text;
        XmlPart: Text;
        RecRef: RecordRef;
    begin
        TestField("Report ID");
        OutputTempBlob.CreateOutStream(DocumentOutStream);
        XmlPart := REPORT.WordXmlPart("Report ID", true);

        TempBlob.CreateInStream(DocumentInStream);
        ErrorMessage := DocumentReportMgt.TryUpdateWordLayout(DocumentInStream, DocumentOutStream, '', XmlPart);
        if ErrorMessage = '' then begin
            CopyStream(DocumentOutStream, DocumentInStream);
            DocumentReportMgt.ValidateWordLayout("Report ID", DocumentInStream, true, true);
        end;

        Clear(Layout);

        RecRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecRef, FieldNo("Layout"));
        RecRef.SetTable(Rec);

        InsertCustomXmlPart(Rec);
        Modify(true);
        Commit;

        if ErrorMessage <> '' then
            Message(ErrorMessage);
    end;

    procedure ExportLayout(DefaultFileName: Text; ShowFileDialog: Boolean): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
    begin
        UpdateLayout(true, false);

        if not Layout.HasValue then
            exit;

        if DefaultFileName = '' then
            DefaultFileName := '*.docx';

        TempBlob.FromRecord(Rec, FieldNo(Layout));
        exit(FileMgt.BLOBExport(TempBlob, DefaultFileName, ShowFileDialog));
    end;

    procedure ValidateLayout(useConfirm: Boolean; UpdateContext: Boolean): Boolean
    var
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        DocumentInStream: InStream;
        ValidationErrorFormat: Text;
    begin
        TestField("Report ID");
        CalcFields(Layout);
        if not Layout.HasValue then
            exit;
        Layout.CreateInStream(DocumentInStream);
        exit(DocumentReportMgt.ValidateWordLayout("Report ID", DocumentInStream, useConfirm, UpdateContext));
    end;

    procedure UpdateLayout(ContinueOnError: Boolean; IgnoreDelete: Boolean): Boolean
    var
        ErrorMessage: Text;
    begin
        ErrorMessage := TryUpdateLayout(IgnoreDelete);

        if ErrorMessage = '' then
            exit(ValidateLayout(true, true));

        ErrorMessage := StrSubstNo(ErrorInLayoutErr, "Basic Layout Description", "Report ID", ErrorMessage);
        if ContinueOnError then begin
            Message(ErrorMessage);
            exit(true);
        end;

        Error(ErrorMessage);
    end;

    procedure TryUpdateLayout(IgnoreDelete: Boolean): Text
    var
        TempBlob: Codeunit "Temp Blob";
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        DocumentInStream: InStream;
        DocumentOutStream: OutStream;
        PartStream: OutStream;
        WordXmlPart: Text;
        ErrorMessage: Text;
        RecRef: RecordRef;
    begin
        CalcFields(Layout);
        if not Layout.HasValue then
            exit('');

        CalcFields("XML Part");
        TestField("XML Part");
        TestField("Report ID");

        WordXmlPart := REPORT.WordXmlPart("Report ID", true);

        Layout.CreateInStream(DocumentInStream);
        TempBlob.CreateOutStream(DocumentOutStream);
        ErrorMessage := DocumentReportMgt.TryUpdateWordLayout(DocumentInStream, DocumentOutStream, GetCustomXmlPart, WordXmlPart);

        Clear("XML Part");
        "XML Part".CreateOutStream(PartStream, TEXTENCODING::UTF16);
        PartStream.Write(WordXmlPart);
        if TempBlob.HasValue then begin
            Clear(Layout);

            RecRef.GetTable(Rec);
            TempBlob.ToRecordRef(RecRef, FieldNo("Layout"));
            RecRef.SetTable(Rec);
        end;
        Modify;

        exit(ErrorMessage);
    end;

    local procedure InsertCustomXmlPart(var EventWordTemplate: Record "NPR Event Word Layout")
    var
        OutStr: OutStream;
        WordXmlPart: Text;
    begin
        EventWordTemplate."XML Part".CreateOutStream(OutStr, TEXTENCODING::UTF16);
        WordXmlPart := REPORT.WordXmlPart(EventWordTemplate."Report ID", true);
        if WordXmlPart <> '' then
            OutStr.Write(WordXmlPart);
    end;

    procedure GetCustomXmlPart() XmlPart: Text
    var
        InStr: InStream;
    begin
        CalcFields("XML Part");
        if not "XML Part".HasValue then
            exit;

        "XML Part".CreateInStream(InStr, TEXTENCODING::UTF16);
        InStr.Read(XmlPart);
    end;

    procedure PreviewReport()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        TestField(Usage);

        EventMgt.MergeAndSaveWordLayout(Rec, 1, '');
    end;

    procedure RunReportRequestPage()
    var
        InStr: InStream;
        OutStr: OutStream;
        Parameters: Text;
        NewParameters: Text;
    begin
        if "Request Page Parameters".HasValue then begin
            CalcFields("Request Page Parameters");
            "Request Page Parameters".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(Parameters);
        end;
        NewParameters := Report.RunRequestPage("Report ID", Parameters);
        if NewParameters <> '' then begin
            Clear("Request Page Parameters");
            "Request Page Parameters".CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(NewParameters);
            "Use Req. Page Parameters" := true;
            Modify();
        end;
    end;
}

