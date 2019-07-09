page 6151504 "Nc Import List"
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

    Caption = 'Import List';
    DelayedInsert = true;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Navigate,NaviPartner';
    SourceTable = "Nc Import Entry";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            grid(Control6150639)
            {
                GridLayout = Rows;
                ShowCaption = false;
                group(Filters)
                {
                    Caption = 'Filters';
                    field("COUNT";Count)
                    {
                        Caption = 'Quantity';
                        Editable = false;
                    }
                    field(FilterImportType;FilterImportType)
                    {
                        Caption = 'Import Type';
                        TableRelation = "Nc Import Type";

                        trigger OnValidate()
                        begin
                            SetPresetFilters();
                        end;
                    }
                    field("Show Exported";ShowImported)
                    {
                        Caption = 'Show Imported';

                        trigger OnValidate()
                        begin
                            SetPresetFilters();
                        end;
                    }
                }
                group(Control6150632)
                {
                    ShowCaption = false;
                    field(Control6150622;'')
                    {
                        Caption = 'Error Message:                                                                                                                                                                                                                                                                                ';
                        HideValue = true;
                        ShowCaption = false;
                    }
                    field(ErrorText;ErrorText)
                    {
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Entry No.";"Entry No.")
                {
                    Editable = false;
                }
                field(Date;Date)
                {
                    Editable = false;
                }
                field("<Filter Import Type>";"Import Type")
                {
                }
                field("Document ID";"Document ID")
                {
                    Visible = false;
                }
                field("Sequence No.";"Sequence No.")
                {
                    Visible = false;
                }
                field("Document Name";"Document Name")
                {
                    Editable = false;
                }
                field(Imported;Imported)
                {
                    Editable = false;
                }
                field("Runtime Error";"Runtime Error")
                {
                }
                field("Last Error E-mail Sent at";"Last Error E-mail Sent at")
                {
                    Visible = false;
                }
                field("Last Error E-mail Sent to";"Last Error E-mail Sent to")
                {
                    Visible = false;
                }
                field("Import Started at";"Import Started at")
                {
                    Visible = false;
                }
                field("Import Completed at";"Import Completed at")
                {
                    Visible = false;
                }
                field("Import Duration";"Import Duration")
                {
                    Visible = false;
                }
                field("NaviPartner Case Url";"NaviPartner Case Url")
                {
                    Visible = false;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+F9';

                trigger OnAction()
                begin
                    ImportSelected();
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

                trigger OnAction()
                begin
                    RescheduleSelectedforImport();
                end;
            }
            action("Add File")
            {
                Caption = 'Add File';
                Image = Save;

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
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    //-NC2.12 [308107]
                    //ShowXml();
                    ShowDocumentSource();
                    //+NC2.12 [308107]
                end;
            }
            action("Edit Xml")
            {
                Caption = 'Edit Xml';
                Image = EditAttachment;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                Visible = NOT WebClient;

                trigger OnAction()
                begin
                    EditXml();
                end;
            }
            action("Create Gambit Case")
            {
                Caption = 'Create Gambit Case';
                Image = Job;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    CreateGambitCase();
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
                PromotedCategory = Process;
                ShortCutKey = 'Shift+F7';

                trigger OnAction()
                begin
                    RunDocuments();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateErrorText();
    end;

    trigger OnOpenPage()
    begin
        SetPresetFilters();

        //-NC1.14
        WebClient := IsWebClient();
        //+NC1.14
    end;

    var
        FilterImportType: Code[10];
        GambitMgt: Codeunit "Nc Gambit Management";
        Text001: Label 'No Input';
        Text002: Label 'The %1 selected Import Entries will be scheduled for re-import\Continue?';
        Text003: Label 'No Documents';
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        SyncMgt: Codeunit "Nc Sync. Mgt.";
        ErrorText: Text;
        ShowImported: Boolean;
        Text004: Label '%1 Order(s) has been imported \\%2 Orders contained errors.';
        WebClient: Boolean;

    local procedure AddFile()
    var
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        Filename: Text;
    begin
        //-NC2.08 [297159]
        Filename := FileMgt.BLOBImport(TempBlob,'*.*');
        if Filename = '' then
          exit;

        Filename := FileMgt.GetFileName(Filename);

        Init;
        "Entry No." := 0;
        "Document Name" := CopyStr(Filename,1,MaxStrLen("Document Name"));
        "Document Source" := TempBlob.Blob;
        Date := CurrentDateTime;
        Insert(true);
        CurrPage.Update(false);
        //+NC2.08 [297159]
    end;

    local procedure CreateGambitCase()
    begin
        GambitMgt.InsertCaseImportEntry(Rec);
    end;

    local procedure SetPresetFilters()
    var
        CurrentEntryNo: BigInteger;
    begin
        CurrentEntryNo := "Entry No.";
        FilterGroup(2);

        Reset;
        if ShowImported then
          SetRange(Imported)
        else
          SetRange(Imported,false);

        if FilterImportType = '' then
          SetRange("Import Type")
        else
          SetRange("Import Type",FilterImportType);

        FilterGroup(0);
        if Get(CurrentEntryNo) then;
        CurrPage.Update(false);
    end;

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId,SessionId) then
          exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure UpdateErrorText()
    var
        NcImportMgt: Codeunit "Nc Import Mgt.";
    begin
        //-NC2.02 [262318]
        // LF := 10;
        // CR := 13;
        // ErrorText := '';
        // CALCFIELDS("Last Error Message");
        // "Last Error Message".CREATEINSTREAM(InStream);
        // WHILE NOT InStream.EOS DO BEGIN
        //  InStream.READTEXT(Line);
        //  IF ErrorText <> '' THEN
        //    ErrorText += FORMAT(CR) + FORMAT(LF);
        //  ErrorText += Line;
        // END;
        ErrorText := NcImportMgt.GetErrorMessage(Rec,false);
        //+NC2.02 [262318]
    end;

    local procedure EditXml()
    var
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        MemoryStream: DotNet npNetMemoryStream;
        XmlDoc: DotNet npNetXmlDocument;
        f: File;
        InStr: InStream;
        OutStr: OutStream;
        Path: Text;
    begin
        CalcFields("Document Source");
        TempBlob.Blob := "Document Source";
        Path := FileMgt.BLOBExport(TempBlob,TemporaryPath + "Document Name",false);
        SyncMgt.RunProcess('notepad.exe',Path,true);
        Path := FileMgt.UploadFileSilent(Path);

        f.Open(Path);
        f.CreateInStream(InStr);
        MemoryStream := InStr;
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);

        Clear(TempBlob);
        TempBlob.Blob.CreateOutStream(OutStr);
        MemoryStream := OutStr;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Flush;
        MemoryStream.Close;
        Clear(MemoryStream);
        f.Close;
        Erase(Path);

        "Document Source" := TempBlob.Blob;
        Modify(true);
        Clear(TempBlob);
    end;

    local procedure ImportSelected()
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        ImportedCount: Integer;
    begin
        //-NC1.21
        ImportedCount := 0;
        CurrPage.SetSelectionFilter(ImportEntry);
        if ImportEntry.FindSet then
          repeat
            NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
            ImportEntry.Get(ImportEntry."Entry No.");
            ImportedCount += 1;
          until ImportEntry.Next = 0;
        ImportEntry.SetRange("Runtime Error",true);
        Message(StrSubstNo(Text004,ImportedCount,ImportEntry.Count));
        //+NC1.21
    end;

    local procedure RescheduleSelectedforImport()
    var
        ImportEntry: Record "Nc Import Entry";
    begin
        CurrPage.SetSelectionFilter(ImportEntry);
        if Confirm(StrSubstNo(Text002,ImportEntry.Count),true) then begin
          //-NC2.16 [313184]
          //ImportEntry.MODIFYALL("Runtime Error",FALSE,TRUE);
          ImportEntry.ModifyAll(Imported,false,false);
          ImportEntry.ModifyAll("Runtime Error",false,false);
          //+NC2.16 [313184]
          CurrPage.Update(false);
        end;
    end;

    local procedure RunDocuments()
    var
        ImportType: Record "Nc Import Type";
    begin
        ImportType.Get("Import Type");
        ImportType.TestField("Lookup Codeunit ID");
        if not(CODEUNIT.Run(ImportType."Lookup Codeunit ID",Rec)) then
          Message(Text003);
    end;

    local procedure ShowDocumentSource()
    var
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        StreamReader: DotNet npNetStreamReader;
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
            TempBlob.Blob := "Document Source";
            Path := FileMgt.BLOBExport(TempBlob,TemporaryPath + "Document Name",false);
            HyperLink(Path);
          end
        else
          Message(Text001);
        //+NC2.12 [308107]
    end;
}

