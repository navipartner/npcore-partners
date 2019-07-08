table 6060151 "Event Word Layout"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.31/TJ  /20170504 CASE 269162 Added code to function CopyRecord

    Caption = 'Event Word Layout';
    LookupPageID = "Event Word Layouts";

    fields
    {
        field(1;"Source Record ID";RecordID)
        {
            Caption = 'Source Record ID';
        }
        field(2;Usage;Option)
        {
            Caption = 'Usage';
            OptionCaption = ' ,Customer,Team';
            OptionMembers = " ",Customer,Team;

            trigger OnValidate()
            begin
                case Usage of
                  Usage::" ": "Report ID" := 0;
                  Usage::Customer: "Report ID" := REPORT::"Event Customer Template";
                  Usage::Team: "Report ID" := REPORT::"Event Team Template";
                end;
            end;
        }
        field(5;"Report ID";Integer)
        {
            Caption = 'Report ID';
        }
        field(10;"Basic Layout ID";Integer)
        {
            Caption = 'Basic Layout ID';
            TableRelation = "Custom Report Layout".Code WHERE ("Report ID"=FIELD("Report ID"));

            trigger OnValidate()
            begin
                if ("Basic Layout ID" <> xRec."Basic Layout ID") and Layout.HasValue then
                  if not Confirm(StrSubstNo(ConfirmLayoutChange,FieldCaption("Basic Layout ID"))) then
                    Error('');

                if "Basic Layout ID" = 0 then begin
                  Clear(Layout);
                  Clear("XML Part");
                end else begin
                  CustomReportLayout.Get("Basic Layout ID");
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
        field(20;"Layout";BLOB)
        {
            Caption = 'Layout';
        }
        field(30;"XML Part";BLOB)
        {
            Caption = 'XML Part';
        }
        field(40;"Last Modified";DateTime)
        {
            Caption = 'Last Modified';
            Editable = false;
        }
        field(50;"Last Modified by User";Code[50])
        {
            Caption = 'Last Modified by User';
            Editable = false;
        }
        field(60;"Basic Layout Description";Text[80])
        {
            CalcFormula = Lookup("Custom Report Layout".Description WHERE (Code=FIELD("Basic Layout ID")));
            Caption = 'Basic Layout Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70;Description;Text[80])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Source Record ID",Usage)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        GetJobFromRecID(Job);
        Description := StrSubstNo(NewLayoutTxt,Job."No.",Format(Usage));
    end;

    trigger OnModify()
    begin
        SetUpdated();
    end;

    var
        ImportWordTxt: Label 'Import Word Document';
        FileFilterWordTxt: Label 'Word Files (*.docx)|*.docx', Comment='{Split=r''\|''}{Locked=s''1''}';
        NoRecordsErr: Label 'There is no record in the list.';
        NewLayoutTxt: Label '%1 %2 Layout';
        ErrorInLayoutErr: Label 'Issue found in layout %1 for report ID  %2:\%3.', Comment='%1=a name, %2=a number, %3=a sentence/error description.';
        CustomReportLayout: Record "Custom Report Layout";
        EventMgt: Codeunit "Event Management";
        ConfirmLayoutChange: Label 'Changing %1 will remove current layout. If you''ve customized it, it will be lost. We suggest that you first run Export Layout and then try changing again. Do you want to continue?';
        Job: Record Job;

    procedure CopyRecord()
    var
        EventCopy: Page "Event Copy Attr./Templ.";
        Job: Record Job;
    begin
        TestField(Usage);
        GetJobFromRecID(Job);
        //-NPR5.31 [269162]
        //EventCopy.SetFromCode(Job,Usage);
        EventCopy.SetFromEvent(Job."No.",Usage);
        //+NPR5.31 [269162]
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
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        FileName: Text;
        FileFilterTxt: Text;
        ImportTxt: Text;
    begin
        if IsEmpty then
          Error(NoRecordsErr);
        ImportTxt := ImportWordTxt;
        FileFilterTxt := FileFilterWordTxt;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob,ImportTxt,DefaultFileName,FileFilterTxt,FileFilterTxt);
        if FileName = '' then
          exit;

        ImportLayoutBlob(TempBlob,UpperCase(FileMgt.GetExtension(FileName)));
    end;

    procedure ImportLayoutBlob(var TempBlob: Record TempBlob;FileExtension: Text[30])
    var
        OutputTempBlob: Record TempBlob;
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        DocumentInStream: InStream;
        DocumentOutStream: OutStream;
        ErrorMessage: Text;
        XmlPart: Text;
    begin
        TestField("Report ID");
        OutputTempBlob.Blob.CreateOutStream(DocumentOutStream);
        XmlPart := REPORT.WordXmlPart("Report ID",true);

        TempBlob.Blob.CreateInStream(DocumentInStream);
        ErrorMessage := DocumentReportMgt.TryUpdateWordLayout(DocumentInStream,DocumentOutStream,'',XmlPart);
        if ErrorMessage = '' then begin
          CopyStream(DocumentOutStream,DocumentInStream);
          DocumentReportMgt.ValidateWordLayout("Report ID",DocumentInStream,true,true);
        end;

        Clear(Layout);
        Layout := OutputTempBlob.Blob;

        InsertCustomXmlPart(Rec);
        Modify(true);
        Commit;

        if ErrorMessage <> '' then
          Message(ErrorMessage);
    end;

    procedure ExportLayout(DefaultFileName: Text;ShowFileDialog: Boolean): Text
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        UpdateLayout(true,false);

        if not Layout.HasValue then
          exit;

        if DefaultFileName = '' then
          DefaultFileName := '*.docx';

        TempBlob.Blob := Layout;
        exit(FileMgt.BLOBExport(TempBlob,DefaultFileName,ShowFileDialog));
    end;

    procedure ValidateLayout(useConfirm: Boolean;UpdateContext: Boolean): Boolean
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
        exit(DocumentReportMgt.ValidateWordLayout("Report ID",DocumentInStream,useConfirm,UpdateContext));
    end;

    procedure UpdateLayout(ContinueOnError: Boolean;IgnoreDelete: Boolean): Boolean
    var
        ErrorMessage: Text;
    begin
        ErrorMessage := TryUpdateLayout(IgnoreDelete);

        if ErrorMessage = '' then
          exit(ValidateLayout(true,true));

        ErrorMessage := StrSubstNo(ErrorInLayoutErr,"Basic Layout Description","Report ID",ErrorMessage);
        if ContinueOnError then begin
          Message(ErrorMessage);
          exit(true);
        end;

        Error(ErrorMessage);
    end;

    procedure TryUpdateLayout(IgnoreDelete: Boolean): Text
    var
        TempBlob: Record TempBlob;
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        DocumentInStream: InStream;
        DocumentOutStream: OutStream;
        PartStream: OutStream;
        WordXmlPart: Text;
        ErrorMessage: Text;
    begin
        CalcFields(Layout);
        if not Layout.HasValue then
          exit('');

        CalcFields("XML Part");
        TestField("XML Part");
        TestField("Report ID");

        WordXmlPart := REPORT.WordXmlPart("Report ID",true);

        Layout.CreateInStream(DocumentInStream);
        TempBlob.Blob.CreateOutStream(DocumentOutStream);
        ErrorMessage := DocumentReportMgt.TryUpdateWordLayout(DocumentInStream,DocumentOutStream,GetCustomXmlPart,WordXmlPart);

        Clear("XML Part");
        "XML Part".CreateOutStream(PartStream,TEXTENCODING::UTF16);
        PartStream.Write(WordXmlPart);
        if TempBlob.Blob.HasValue then begin
          Clear(Layout);
          Layout := TempBlob.Blob;
        end;
        Modify;

        exit(ErrorMessage);
    end;

    procedure EditLayout()
    begin
        UpdateLayout(true,true);
        EventMgt.EditTemplate(Rec);
    end;

    local procedure InsertCustomXmlPart(var EventWordTemplate: Record "Event Word Layout")
    var
        OutStr: OutStream;
        WordXmlPart: Text;
    begin
        EventWordTemplate."XML Part".CreateOutStream(OutStr,TEXTENCODING::UTF16);
        WordXmlPart := REPORT.WordXmlPart(EventWordTemplate."Report ID",true);
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

        "XML Part".CreateInStream(InStr,TEXTENCODING::UTF16);
        InStr.Read(XmlPart);
    end;

    procedure PreviewReport()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        TestField(Usage);

        EventMgt.MergeAndSaveWordLayout(Rec,1,'');
    end;
}

