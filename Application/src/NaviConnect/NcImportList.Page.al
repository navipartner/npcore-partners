page 6151504 "NPR Nc Import List"
{
    Caption = 'Import List';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Navigate,NaviPartner';
    SourceTable = "NPR Nc Import Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = Tasks;
    ApplicationArea = NPRNaviConnect;

    layout
    {

        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Date"; Rec.Date)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("<Filter Import Type>"; Rec."Import Type")
                {

                    ToolTip = 'Specifies the value of the Import Type field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Document ID"; Rec."Document ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Document ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Sequence No."; Rec."Sequence No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sequence No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Document Name"; Rec."Document Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Imported; Rec.Imported)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Imported field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Runtime Error"; Rec."Runtime Error")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Runtime Error field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Error Message"; Rec."Error Message")
                {

                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Error Message field';
                    ApplicationArea = NPRNaviConnect;

                    trigger OnDrillDown()
                    var
                        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
                    begin
                        Message(NcImportMgt.GetErrorMessage(Rec, false));
                    end;
                }
                field("Last Error E-mail Sent at"; Rec."Last Error E-mail Sent at")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Error E-mail Sent at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Last Error E-mail Sent to"; Rec."Last Error E-mail Sent to")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Error E-mail Sent to field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Started at"; Rec."Import Started at")
                {

                    ToolTip = 'Specifies the value of the Import Started at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Completed at"; Rec."Import Completed at")
                {

                    ToolTip = 'Specifies the value of the Import Completed at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Duration"; Rec."Import Duration")
                {

                    ToolTip = 'Specifies the value of the Import Duration (sec.) field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Count"; Rec."Import Count")
                {

                    ToolTip = 'Specifies the value of the Import Count field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Started by"; Rec."Import Started by")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Import Started by field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Server Instance Id"; Rec."Server Instance Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Server Instance Id field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Session Id"; Rec."Session Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Session Id field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Earliest Import Datetime"; Rec."Earliest Import Datetime")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Earliest Import Datetime field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRNaviConnect;
                }

            }
            group(Control6014407)
            {
                ShowCaption = false;
                field("COUNT"; Rec.Count)
                {

                    Caption = 'Quantity';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import Selected")
            {
                Caption = 'Import Selected';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+F9';

                ToolTip = 'Executes the Import Selected action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    ImportSelected();

                end;
            }
            action("Filter Imported")
            {
                Caption = 'Filter Imported';
                Image = FilterLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+F8';

                ToolTip = 'Executes the Filter Imported action which will change filter on Imported field';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    TxtCurrFilterOnFieldImported: Text;
                    BoolCurrFilterOnFieldImported: Boolean;
                begin
                    TxtCurrFilterOnFieldImported := Rec.GetFilter(Imported);
                    if not Evaluate(BoolCurrFilterOnFieldImported, TxtCurrFilterOnFieldImported) then
                        BoolCurrFilterOnFieldImported := true;
                    Rec.SetRange(Imported, not BoolCurrFilterOnFieldImported);
                    CurrPage.Update();
                end;
            }
            action("Reschedule Selected for Import")
            {
                Caption = 'Reschedule Selected for Import';
                Image = UpdateXML;
                ShortCutKey = 'F9';

                ToolTip = 'Executes the Reschedule Selected for Import action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    RescheduleSelectedforImport();
                end;
            }
            action("Add File")
            {
                Caption = 'Add File';
                Image = Save;

                ToolTip = 'Executes the Add File action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    AddFile();
                end;
            }
            action("Show Document Source")
            {
                Caption = 'Show Document Source';
                Image = XMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Show Document Source action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    ShowDocumentSource();
                end;
            }
            action("Show Formatted Source")
            {
                Caption = 'Show Formatted Source';
                Image = XMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Show Formatted Source action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    ShowFormattedDocument();
                end;
            }
            action("Edit File")
            {
                Caption = 'Edit File';
                Image = EditAttachment;
                Visible = NOT WebClient;

                ToolTip = 'Executes the Edit File action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    Message(EditFileMsg);
                end;
            }
            action("Export File")
            {
                Caption = 'Export File';
                Image = ExportAttachment;
                Visible = WebClient;

                ToolTip = 'Executes the Export File action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    Path: Text;
                begin
                    Rec.CalcFields("Document Source");
                    TempBlob.FromRecord(Rec, Rec.FieldNo("Document Source"));
                    if not TempBlob.HasValue() then
                        exit;
                    Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + Rec."Document Name", true);
                end;
            }
            action("Import File")
            {
                Caption = 'Import File';
                Image = ImportCodes;
                Visible = WebClient;

                ToolTip = 'Executes the Import File action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    FileName: Text;
                    Extension: Text;
                    RecRef: RecordRef;
                begin
                    Extension := FileMgt.GetExtension(Rec."Document Name");
                    if Extension = '' then
                        Extension := '*';
                    FileName := FileMgt.BLOBImportWithFilter(TempBlob, ImportFileTxt, Rec."Document Name", FileMgt.GetToFilterText('', Rec."Document Name"), '*.' + Extension);
                    if FileName = '' then
                        exit;

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo("Document Source"));
                    RecRef.SetTable(Rec);

                    Rec.Modify(true);
                    Clear(TempBlob);
                end;
            }
        }
        area(navigation)
        {
            action("Run Documents")
            {
                Caption = 'Documents';
                Image = EditLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ShortCutKey = 'Shift+F7';

                ToolTip = 'Executes the Documents action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    RunDocuments();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange(Imported, false);
        if Rec.FindFirst() then;
        WebClient := IsWebClient();
    end;

    var
        NoInputTxt: Label 'No Input';
        ScheduleForReImportQst: Label 'The %1 selected Import Entries will be scheduled for re-import\Continue?', Comment = '%1="NPR Nc Import Entry".Count()';
        NoDocsMsg: Label 'No Documents';
        NoOfImportedDoscMsg: Label '%1 Documents have been imported\\%2 Documents failed.', Comment = '%1=ImportedCount;%2=ImportEntry.Count()';
        WebClient: Boolean;
        ImportFileTxt: Label 'Import File';
        EmptyStyleSheetErr: Label 'XML Stylesheet is empty for Import Type: %1', Comment = '%1="NPR Nc Import Entry"."Import Type"';
        NoFileMatchErr: Label 'No Import Filenames matched %1', Comment = 'DocNo';
        EditFileMsg: Label 'In cloud environments files can not be stored on the server. Please use Export action to download the file, change it and then use Import action to return it into Database.';

    local procedure AddFile()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        Filename: Text;
        RecRef: RecordRef;
    begin
        Filename := FileMgt.BLOBImport(TempBlob, '*.*');
        if Filename = '' then
            exit;

        Filename := FileMgt.GetFileName(Filename);

        Rec.Init();
        Rec."Entry No." := 0;
        Rec."Document Name" := CopyStr(Filename, 1, MaxStrLen(Rec."Document Name"));

        RecRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecRef, Rec.FieldNo("Document Source"));
        RecRef.SetTable(Rec);

        Rec.Date := CurrentDateTime;
        Rec.Insert(true);
        CurrPage.Update(false);
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure ImportSelected()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        ImportedCount: Integer;
    begin
        ImportedCount := 0;
        CurrPage.SetSelectionFilter(ImportEntry);
        ImportEntry.ModifyAll("Earliest Import Datetime", 0DT);
        Commit();
        if ImportEntry.FindSet() then
            repeat
                CODEUNIT.Run(CODEUNIT::"NPR Nc Import Processor", ImportEntry);
                ImportedCount += 1;
            until ImportEntry.Next() = 0;
        ImportEntry.SetRange("Runtime Error", true);
        Message(NoOfImportedDoscMsg, ImportedCount, ImportEntry.Count());
    end;

    local procedure RescheduleSelectedforImport()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcImportProcessor: Codeunit "NPR Nc Import Processor";
    begin
        CurrPage.SetSelectionFilter(ImportEntry);
        if Confirm(ScheduleForReImportQst, true, ImportEntry.Count()) then begin
            ImportEntry.ModifyAll(Imported, false, false);
            ImportEntry.ModifyAll("Runtime Error", false, false);
            ImportEntry.ModifyAll("Earliest Import Datetime", 0DT);
            Commit();
            if ImportEntry.FindSet() then
                repeat
                    NcImportProcessor.ScheduleImport(ImportEntry);
                until ImportEntry.Next() = 0;
            CurrPage.Update(false);
        end;
    end;

    local procedure RunDocuments()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.Get(Rec."Import Type");
        ImportType.TestField("Lookup Codeunit ID");
        if not (CODEUNIT.Run(ImportType."Lookup Codeunit ID", Rec)) then
            Message(NoDocsMsg);
    end;

    local procedure ShowDocumentSource()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        InStr: InStream;
        Path: Text;
        Content: Text;
        tmp: Text;
    begin
        Rec.CalcFields("Document Source");
        if Rec."Document Source".HasValue() then
            if IsWebClient() then begin
                Rec."Document Source".CreateInStream(InStr);
                Content := '';
                while not InStr.EOS()
                do begin
                    InStr.ReadText(tmp);
                    Content += tmp + '\';
                end;
                Message(Content);
            end else begin
                TempBlob.FromRecord(Rec, Rec.FieldNo("Document Source"));
                Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + Rec."Document Name", false);
                HyperLink(Path);
            end
        else
            Message(NoInputTxt);
    end;

    procedure ShowFormattedDocument()
    var
        NcImportType: Record "NPR Nc Import Type";
        page: Page "NPR Nc Show Html";
        stream: InStream;
        xsltv: Text;
        xmlv: Text;
        xslt: Text;
        xml: Text;
    begin
        Rec.CalcFields("Document Source");
        if Rec."Document Source".HasValue() then begin

            Rec.TestField("Import Type");
            NcImportType.Get(Rec."Import Type");
            NcImportType.CalcFields("XML Stylesheet");
            if not NcImportType."XML Stylesheet".HasValue() then
                Error(EmptyStyleSheetErr, Rec."Import Type");

            NcImportType."XML Stylesheet".CreateInStream(stream, TextEncoding::UTF8);
            while not stream.EOS do begin
                stream.ReadText(xsltv);
                xslt := xslt + xsltv
            end;

            Rec."Document Source".CreateInStream(stream, TextEncoding::UTF8);
            stream.ReadText(xml);
            while not stream.EOS do begin
                stream.ReadText(xmlv);
                xml := xml + xmlv
            end;
            page.SetData(xslt, xml);
            page.Run();

        end else
            Message(NoInputTxt);
    end;

    procedure ShowFormattedDocByDocNo(DocNo: Text[100])
    var
        NcImportEntry: Record "NPR Nc Import Entry";
        NcImportListPg: Page "NPR Nc Import List";
    begin
        if DocNo = '' then
            Error(NoInputTxt);

        NcImportEntry.SetFilter("Document Name", '%1', '*' + DocNo + '*');
        if NcImportEntry.FindSet() then begin
            if NcImportEntry.Count() > 1 then begin
                NcImportListPg.SetRecord(NcImportEntry);
                NcImportListPg.RunModal();
            end else begin
                NcImportListPg.SetRecord(NcImportEntry);
                NcImportListPg.ShowFormattedDocument();
            end;
        end else
            Error(NoFileMatchErr, DocNo);
    end;
}

