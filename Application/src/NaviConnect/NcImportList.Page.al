page 6151504 "NPR Nc Import List"
{
    // NC1.00 /MHA /20150113  CASE 199932 Refactored object from Web Integration
    // NC1.01 /MHA /20150201  CASE 199932 Updated Layout and added functions:
    //                                    SetPresetFilters(): Sets easy-to-use Preset Filters
    //                                    CreateGambitCase(): Create Case
    // NC1.02 /MHA /20150202  CASE 199932 Created Action-functions.
    //                                    Added XmlValidation to EditXml().
    // NC1.04 /MHA /20150206  CASE 206395 Add functionality for RunPageSalesInvoice().
    // NC1.04 /TS  /20150212  CASE 201682 Add Change Caption Show Exported to Show Imported
    // NC1.05 /MHA /20150223  CASE 206395 Update Action Image
    // NC1.08 /MHA /20150310  CASE 206395 Replaced Automation Windows Script Host with .NET System.Diagnostics.Process for launching Applications
    // NC1.14 /MHA /20150429  CASE 212845 Changed PageType from List to ListPlus and implemented WebClient functions
    // NC1.16 /TS  /20150424  CASE 212103 Replaced references to hardcode Import Codeunit with NaviConnect Setup Import Codeunits
    // NC1.17 /TS  /20150424  CASE 213378 Error Log for Import Contacts
    // NC1.17 /MHA /20150623  CASE 215533 Moved import code to codeunit and added GetReturnDocuments()
    // NC1.18 /MHA /20150709  CASE 218282 Sync. Mgt. is invoke for import instead of import mgt.
    // NC1.21 /TTH /20151118  CASE 227358 Replacing Type option field with Import type, Added the import types to the list, removed old import type
    // NC1.22 /MHA /20151202  CASE 227358 Added field 110 "Webservice Function"
    // NC1.22 /TSA /20151207  CASE 228983 Added field 30,35 with visibility false
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.01 /MHA /20160913  CASE 252048 Updated NC2.00 TableRelation for FilterImportType
    // NC2.02 /MHA /20170227  CASE 262318 Added fields 15 "Last Error E-mail Sent at" and 17 "Last Error E-mail Sent to"
    // NC2.08 /MHA /20171121  CASE 297159 Added function AddFile()
    // NC2.08 /TS  /20180108  CASE 300893 Removed Caption on Control Container
    // NC2.12/MHA /20180418  CASE 308107 Deleted function ShowXml() and added ShowDocumentSource() to enable multiple file types
    // NC2.16/MHA /20180907  CASE 313184 Added fields 40,45,50 for diagnostics
    // NC2.17/JDH /20181112 CASE 334163 Added Caption to Action Add File
    // NC2.23/ZESO/20190819  CASE 360787 Added Export File and Import File for Web Client
    // NC2.23/MHA /20190927  CASE 369170 Removed Gambit integration
    // NC2.24/MHA /20191108  CASE 373525 Changed extension filter for Import File to reflect "Document Name"
    // NPR5.54/CLVA/20200127 CASE 366790 Added function ShowFormattedDocumentSource
    // NPR5.55/CLVA/20200506 CASE 366790 Changed error handling. Added function ShowFormattedDocByDocNo
    // NPR5.55/MHA /20200604  CASE 408100 Reworked layout for better Web Client experience

    Caption = 'Import List';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Navigate,NaviPartner';
    SourceTable = "NPR Nc Import Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Date"; Date)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("<Filter Import Type>"; "Import Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Type field';
                }
                field("Document ID"; "Document ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document ID field';
                }
                field("Sequence No."; "Sequence No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sequence No. field';
                }
                field("Document Name"; "Document Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Name field';
                }
                field(Imported; Imported)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Imported field';
                }
                field("Runtime Error"; "Runtime Error")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Runtime Error field';
                }
                field("Error Message"; "Error Message")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Error Message field';

                    trigger OnDrillDown()
                    var
                        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
                    begin
                        //-NPR5.55 [408100]
                        Message(NcImportMgt.GetErrorMessage(Rec, false));
                        //+NPR5.55 [408100]
                    end;
                }
                field("Last Error E-mail Sent at"; "Last Error E-mail Sent at")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Error E-mail Sent at field';
                }
                field("Last Error E-mail Sent to"; "Last Error E-mail Sent to")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Error E-mail Sent to field';
                }
                field("Import Started at"; "Import Started at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Started at field';
                }
                field("Import Completed at"; "Import Completed at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Completed at field';
                }
                field("Import Duration"; "Import Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Duration (sec.) field';
                }
                field("Import Count"; "Import Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Count field';
                }
                field("Import Started by"; "Import Started by")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Import Started by field';
                }
                field("Server Instance Id"; "Server Instance Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Server Instance Id field';
                }
                field("Session Id"; "Session Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Session Id field';
                }
                field("Earliest Import Datetime"; "Earliest Import Datetime")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Earliest Import Datetime field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
            group(Control6014407)
            {
                ShowCaption = false;
                field("COUNT"; Count)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Quantity field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Import Selected action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Filter Imported action which will change filter on Imported field';

                trigger OnAction()
                var
                    TxtCurrFilterOnFieldImported: Text;
                    BoolCurrFilterOnFieldImported: Boolean;
                begin
                    TxtCurrFilterOnFieldImported := Rec.GetFilter(Imported);
                    Evaluate(BoolCurrFilterOnFieldImported, TxtCurrFilterOnFieldImported);
                    Rec.SetRange(Imported, not BoolCurrFilterOnFieldImported);
                    CurrPage.Update();
                end;
            }
            action("Reschedule Selected for Import")
            {
                Caption = 'Reschedule Selected for Import';
                Image = UpdateXML;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                ShortCutKey = 'F9';
                ApplicationArea = All;
                ToolTip = 'Executes the Reschedule Selected for Import action';

                trigger OnAction()
                begin
                    RescheduleSelectedforImport();
                end;
            }
            action("Add File")
            {
                Caption = 'Add File';
                Image = Save;
                ApplicationArea = All;
                ToolTip = 'Executes the Add File action';

                trigger OnAction()
                begin
                    //-NC2.08 [297159]
                    AddFile();
                    //+NC2.08 [297159]
                end;
            }
            action("Show Document Source")
            {
                Caption = 'Show Document Source';
                Image = XMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Document Source action';

                trigger OnAction()
                begin
                    //-NC2.12 [308107]
                    //ShowXml();
                    ShowDocumentSource();
                    //+NC2.12 [308107]
                end;
            }
            action("Show Formatted Source")
            {
                Caption = 'Show Formatted Source';
                Image = XMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Formatted Source action';

                trigger OnAction()
                begin
                    //-NPR5.54 [366790]
                    ShowFormattedDocumentSource();
                    //+NPR5.54 [366790]
                end;
            }
            action("Edit File")
            {
                Caption = 'Edit File';
                Image = EditAttachment;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                Visible = NOT WebClient;
                ApplicationArea = All;
                ToolTip = 'Executes the Edit File action';

                trigger OnAction()
                begin
                    //-NC2.24 [373525]
                    EditFile();
                    //+NC2.24 [373525]
                end;
            }
            action("Export File")
            {
                Caption = 'Export File';
                Image = ExportAttachment;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                Visible = WebClient;
                ApplicationArea = All;
                ToolTip = 'Executes the Export File action';

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    Path: Text;
                begin
                    //-NC2.23 [360787]
                    CalcFields("Document Source");
                    TempBlob.FromRecord(Rec, FieldNo("Document Source"));
                    if not TempBlob.HasValue then
                        exit;
                    Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + "Document Name", true);
                    //+NC2.23 [360787]
                end;
            }
            action("Import File")
            {
                Caption = 'Import File';
                Image = ImportCodes;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                Visible = WebClient;
                ApplicationArea = All;
                ToolTip = 'Executes the Import File action';

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    Path: Text;
                    FileName: Text;
                    Extension: Text;
                    RecRef: RecordRef;
                begin
                    //-NC2.23 [360787]
                    //-NC2.24 [373525]
                    //FileName := FileMgt.BLOBImportWithFilter(TempBlob,'Import Layout','',FileFilterTxt,FileFilterTxt);
                    Extension := FileMgt.GetExtension("Document Name");
                    if Extension = '' then
                        Extension := '*';
                    FileName := FileMgt.BLOBImportWithFilter(TempBlob, Text005, "Document Name", FileMgt.GetToFilterText('', "Document Name"), '*.' + Extension);
                    //+NC2.24 [373525]
                    if FileName = '' then
                        exit;

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo("Document Source"));
                    RecRef.SetTable(Rec);

                    Modify(true);
                    Clear(TempBlob);
                    //+NC2.23 [360787]
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
                ApplicationArea = All;
                ToolTip = 'Executes the Documents action';

                trigger OnAction()
                begin
                    RunDocuments();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        //-NPR5.55 [408100]
        SetRange(Imported, false);
        if FindFirst then;
        //+NPR5.55 [408100]

        //-NC1.14
        WebClient := IsWebClient();
        //+NC1.14
    end;

    var
        Text001: Label 'No Input';
        Text002: Label 'The %1 selected Import Entries will be scheduled for re-import\Continue?';
        Text003: Label 'No Documents';
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Text004: Label '%1 Documents have been imported\\%2 Documents failed.';
        WebClient: Boolean;
        Text005: Label 'Import File';
        Text006: Label 'XML Stylesheet is empty for Import Type: %1';
        Text007: Label 'No Import Filenames matched %1';

    local procedure AddFile()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        Filename: Text;
        RecRef: RecordRef;
    begin
        //-NC2.08 [297159]
        Filename := FileMgt.BLOBImport(TempBlob, '*.*');
        if Filename = '' then
            exit;

        Filename := FileMgt.GetFileName(Filename);

        Init;
        "Entry No." := 0;
        "Document Name" := CopyStr(Filename, 1, MaxStrLen("Document Name"));

        RecRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecRef, FieldNo("Document Source"));
        RecRef.SetTable(Rec);

        Date := CurrentDateTime;
        Insert(true);
        CurrPage.Update(false);
        //+NC2.08 [297159]
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure EditFile()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        SyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        f: File;
        InStr: InStream;
        OutStr: OutStream;
        Path: Text;
        RecRef: RecordRef;
    begin
        CalcFields("Document Source");
        TempBlob.FromRecord(Rec, FieldNo("Document Source"));
        Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + "Document Name", false);
        SyncMgt.RunProcess('notepad.exe', Path, true);
        Path := FileMgt.UploadFileSilent(Path);

        f.Open(Path);
        f.CreateInStream(InStr);
        //-NC2.24 [373525]
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        //+NC2.24 [373525]
        f.Close;
        Erase(Path);

        RecRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecRef, FieldNo("Document Source"));
        RecRef.SetTable(Rec);
        Modify(true);
        Clear(TempBlob);
    end;

    local procedure ImportSelected()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        ImportedCount: Integer;
    begin
        //-NC1.21
        ImportedCount := 0;
        CurrPage.SetSelectionFilter(ImportEntry);
        //-NPR5.55 [408100]
        ImportEntry.ModifyAll("Earliest Import Datetime", 0DT);
        Commit;
        //+NPR5.55 [408100]
        if ImportEntry.FindSet then
            repeat
                //-NPR5.55 [408100]
                CODEUNIT.Run(CODEUNIT::"NPR Nc Import Processor", ImportEntry);
                //+NPR5.55 [408100]
                ImportEntry.Get(ImportEntry."Entry No.");
                ImportedCount += 1;
            until ImportEntry.Next = 0;
        ImportEntry.SetRange("Runtime Error", true);
        Message(StrSubstNo(Text004, ImportedCount, ImportEntry.Count));
        //+NC1.21
    end;

    local procedure RescheduleSelectedforImport()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NcImportProcessor: Codeunit "NPR Nc Import Processor";
    begin
        CurrPage.SetSelectionFilter(ImportEntry);
        if Confirm(StrSubstNo(Text002, ImportEntry.Count), true) then begin
            //-NC2.16 [313184]
            //ImportEntry.MODIFYALL("Runtime Error",FALSE,TRUE);
            ImportEntry.ModifyAll(Imported, false, false);
            ImportEntry.ModifyAll("Runtime Error", false, false);
            //+NC2.16 [313184]
            //-NPR5.55 [408100]
            ImportEntry.ModifyAll("Earliest Import Datetime", 0DT);
            Commit;
            if ImportEntry.FindSet then
                repeat
                    NcImportProcessor.ScheduleImport(ImportEntry);
                until ImportEntry.Next = 0;
            //+NPR5.55 [408100]
            CurrPage.Update(false);
        end;
    end;

    local procedure RunDocuments()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.Get("Import Type");
        ImportType.TestField("Lookup Codeunit ID");
        if not (CODEUNIT.Run(ImportType."Lookup Codeunit ID", Rec)) then
            Message(Text003);
    end;

    local procedure ShowDocumentSource()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        StreamReader: DotNet NPRNetStreamReader;
        InStr: InStream;
        Path: Text;
        Content: Text;
    begin
        //-NC2.12 [308107]
        CalcFields("Document Source");
        if "Document Source".HasValue then
            if IsWebClient() then begin
                "Document Source".CreateInStream(InStr);
                StreamReader := StreamReader.StreamReader(InStr);
                Content := StreamReader.ReadToEnd();
                Message(Content);
            end else begin
                TempBlob.FromRecord(Rec, FieldNo("Document Source"));
                Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + "Document Name", false);
                HyperLink(Path);
            end
        else
            Message(Text001);
        //+NC2.12 [308107]
    end;

    procedure ShowFormattedDocumentSource()
    var
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        StreamReader: DotNet NPRNetStreamReader;
        InStr: InStream;
        Path: Text;
        Content: Text;
        NcImportType: Record "NPR Nc Import Type";
        XMLStylesheetPath: Text;
        [RunOnClient]
        XslCompiledTransform: DotNet NPRNetXslCompiledTransform;
        LocalTempFile: Text;
        HtmlContent: Text;
        ServerFileName: Text;
    begin
        //-NPR5.54 [366790]
        CalcFields("Document Source");
        if "Document Source".HasValue then begin

            TestField("Import Type");
            NcImportType.Get("Import Type");

            NcImportType.CalcFields("XML Stylesheet");
            if not NcImportType."XML Stylesheet".HasValue then
                //-NPR5.55 [366790]
                //ERROR(Text006);
                Error(Text006, "Import Type");
            //+NPR5.55 [366790]

            TempBlob.FromRecord(NcImportType, NcImportType.FieldNo("XML Stylesheet"));
            XMLStylesheetPath := FileMgt.BLOBExport(TempBlob, 'Stylesheet.xslt', false);

            XslCompiledTransform := XslCompiledTransform.XslCompiledTransform;
            XslCompiledTransform.Load(XMLStylesheetPath);

            LocalTempFile := FileMgt.ClientTempFileName('html');

            TempBlob.FromRecord(Rec, FieldNo("Document Source"));
            Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + "Document Name", false);

            XslCompiledTransform.Transform(Path, LocalTempFile);

            ServerFileName := FileMgt.UploadFileSilent(LocalTempFile);

            HtmlContent := GetFormattedDocumentAsString(ServerFileName, true);
            PreviewFormattedDocument("Document Name", HtmlContent);

        end else
            Message(Text001);
        //+NPR5.54 [366790]
    end;

    local procedure GetFormattedDocumentAsString(FileName: Text; DeleteFile: Boolean) String: Text
    var
        TempFile: File;
        Istream: InStream;
        StreamReader: DotNet NPRNetStreamReader;
        Encoding: DotNet NPRNetEncoding;
    begin
        //-NPR5.54 [366790]
        if Exists(FileName) then begin
            TempFile.Open(FileName);
            TempFile.CreateInStream(Istream);

            StreamReader := StreamReader.StreamReader(Istream, Encoding.Unicode);
            String := StreamReader.ReadToEnd();
            TempFile.Close;

            if DeleteFile then
                FILE.Erase(FileName);

            exit(String);
        end;
        //+NPR5.54 [366790]
    end;

    local procedure PreviewFormattedDocument(Title: Text; Content: Text)
    var
        HTMLContent: Text;
        JToken: DotNet NPRNetJToken;
        [RunOnClient]
        WinForm: DotNet NPRNetForm;
        [RunOnClient]
        WinText: DotNet NPRNetTextBox;
        [RunOnClient]
        Colour: DotNet NPRNetColor;
        [RunOnClient]
        DockStyle: DotNet NPRNetDockStyle;
        [RunOnClient]
        WebBrowser: DotNet NPRNetWebBrowser;
        [RunOnClient]
        FormWindowState: DotNet NPRNetFormWindowState;
        ActiveFormAlHelper: Variant;
    begin
        //-NPR5.54 [366790]
        if (Content = '') then
            exit;

        if CurrentClientType in [CLIENTTYPE::Tablet, CLIENTTYPE::Web, CLIENTTYPE::Phone] then begin
            Message('Brigde framework is missing\Please use the RTC client for previewing');
        end else begin
            WinForm := WinForm.Form;
            Colour := Colour.Color;
            WinText := WinText.TextBox;
            WinForm.Width := 1000;
            WinForm.Height := 600;
            ActiveFormAlHelper := WinForm.ActiveForm;
            WinForm.Text := Title;
            WinForm.WindowState := FormWindowState.Normal;
            WinForm.ShowInTaskbar := false;
            WinForm.ShowIcon := false;

            WebBrowser := WebBrowser.WebBrowser;
            WebBrowser.Dock := DockStyle.Fill;
            WebBrowser.DocumentText := '0';
            WebBrowser.Document.OpenNew(true);
            WebBrowser.Document.Write(Content);
            WebBrowser.Refresh();

            WinForm.Controls.Add(WebBrowser);
            WinForm.ShowDialog;
            //-NPR5.55 [366790]
            WinForm.Dispose();
            Clear(WinForm);
            //+NPR5.55 [366790]
        end;
        //+NPR5.54 [366790]
    end;

    procedure ShowFormattedDocByDocNo(DocNo: Text[100])
    var
        NcImportEntry: Record "NPR Nc Import Entry";
        NcImportListPg: Page "NPR Nc Import List";
    begin
        //-NPR5.55 [366790]
        if DocNo = '' then
            Error(Text001);

        NcImportEntry.SetFilter("Document Name", '%1', '*' + DocNo + '*');
        if NcImportEntry.FindSet then begin
            if NcImportEntry.Count > 1 then begin
                NcImportListPg.SetRecord(NcImportEntry);
                NcImportListPg.RunModal();
            end else begin
                NcImportListPg.SetRecord(NcImportEntry);
                NcImportListPg.ShowFormattedDocumentSource();
            end;
        end else
            Error(Text007, DocNo);
        //+NPR5.55 [366790]
    end;
}

