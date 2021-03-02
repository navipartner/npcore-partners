page 6151502 "NPR Nc Task List"
{
    // NC1.00/MH/20150113  CASE 199932 Refactored object from Web Integration
    // NC1.01/MH/20150201  CASE 199932 Updated Layout and added functions:
    //                                 - SetPresetFilters(): Sets easy-to-use Preset Filters
    //                                 - CreateGambitCase(): Create Gambit Case
    // NC1.02/MH/20150202  CASE 199932 Created Action-functions
    // NC1.07/MH/20150223  CASE 206395 Renamed function RunItemCard to RunSourceCard
    // NC1.08/MH/20150310  CASE 206395 Replaced Automation Windows Script Host with .NET System.Diagnostics.Process for launching Applications
    // NC1.14/MH/20150414  CASE 211360 Added Primary Key Fields fields for easier record identification
    // NC1.14/MH/20150415  CASE 211360 Added Timestamp Fields
    // NC1.14/MH/20150429  CASE 212845 Changed PageType from List to ListPlus and implemented WebClient functions
    // NC1.17/MH/20150619  CASE 216851 NaviConnect related functions moved to NaviConnect Mgt
    // NC1.22/MHA/20160108 CASE 231618 Updated caption of "Show Processed"
    // NC1.22/MHA/20160125 CASE 232733 Task Queue Worker Group replaced by NaviConnect Task Processor and added Task Processor Filter
    // NC1.22/MHA/20160415 CASE 231214 Added field 7 Company Name
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20160913  CASE 252048 Added Task Processor filter and added TextEncoding Utf8 to Data Output and Response
    // NC2.08/TS  /20180108  CASE 300893 Removed Caption on Control Container
    // NC2.12/MHA /20180418  CASE 308107 Added Action: Output
    // NC2.13/MHA /20180605  CASE 312583 "Fields" PagePart moved to NAVIGATE Action "Fields" and removed empty fields under "Show Processed" to reduce Header Area
    // NC2.16/MHA /20181003  CASE 328785 Removed delete of file in ShowOutput()
    // NC2.17/MHA /20181121  CASE 335927 ShowOutput() now takes last Nc Task Output if Rec output is blank
    // NC2.23/MHA /20190927  CASE 369170 Removed Gambit integration

    Caption = 'Task List';
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Navigate,NaviPartner';
    ShowFilter = true;
    SourceTable = "NPR Nc Task";
    UsageCategory = Tasks;
    ApplicationArea = All;
    SourceTableView = SORTING("Log Date")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            grid(Control6150664)
            {
                GridLayout = Rows;
                ShowCaption = false;
                group(Filters)
                {
                    Caption = 'Filters';
                    field("COUNT"; Count)
                    {
                        ApplicationArea = All;
                        Caption = 'Quantity';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Quantity field';
                    }
                    field(TaskProcessorFilter; TaskProcessorFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Task Processor';
                        TableRelation = "NPR Nc Task Processor";
                        ToolTip = 'Specifies the value of the Task Processor field';

                        trigger OnValidate()
                        begin
                            SetPresetFilters();
                        end;
                    }
                    field("Show Exported"; ShowProcessed)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Processed';
                        ToolTip = 'Specifies the value of the Show Processed field';

                        trigger OnValidate()
                        begin
                            SetPresetFilters();
                        end;
                    }
                }
                group(Control6150657)
                {
                    ShowCaption = false;
                    field(Control6150656; '')
                    {
                        ApplicationArea = All;
                        Caption = 'Response:                                                                                                                                                                                                                                                                               _';
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Response:                                                                                                                                                                                                                                                                               _ field';
                    }
                    field(ResponseText; ResponseText)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the ResponseText field';
                    }
                }
            }
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("Task Processor Code"; "Task Processor Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Processor Code field';
                }
                field(Processed; Processed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed field';
                }
                field("Process Error"; "Process Error")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Error field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Record Value"; "Record Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Record Value field';
                }
                field("Record Position"; "Record Position")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Record Position field';
                }
                field("Log Date"; "Log Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Last Checked1"; "Last Processing Started at")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Processing Started at field';
                }
                field("Last Processing Completed at"; "Last Processing Completed at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Processing Completed at field';
                }
                field("Last Processing Duration"; "Last Processing Duration")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Processing Duration (sec.) field';
                }
                field("Process Count"; "Process Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Process Count field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import New Tasks")
            {
                Caption = 'Import new Tasks';
                Image = GetEntries;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+F5';
                ApplicationArea = All;
                ToolTip = 'Executes the Import new Tasks action';

                trigger OnAction()
                begin
                    ImportNewTasks();
                end;
            }
            action("Process Manually")
            {
                Caption = 'Process Manually';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Ctrl+F9';
                ApplicationArea = All;
                ToolTip = 'Executes the Process Manually action';

                trigger OnAction()
                begin
                    ProcessManually();
                end;
            }
            action("Reschedule For Processing")
            {
                Caption = 'Reschedule for Processing';
                Image = UpdateXML;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                ShortCutKey = 'F9';
                ApplicationArea = All;
                ToolTip = 'Executes the Reschedule for Processing action';

                trigger OnAction()
                begin
                    RescheduleForProcessing();
                end;
            }
        }
        area(navigation)
        {
            action(Fields)
            {
                Caption = 'Fields';
                Image = List;
                RunObject = Page "NPR Nc Task Fields";
                RunPageLink = "Task Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Fields action';
            }
            action("Show Output")
            {
                Caption = 'Show Output';
                Image = XMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Output action';

                trigger OnAction()
                begin
                    ShowOutput();
                end;
            }
            action("Run Source Card")
            {
                Caption = 'Source Card';
                Image = Item;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Source Card action';

                trigger OnAction()
                begin
                    //-NC1.07
                    //RunItemCard();
                    RunSourceCard();
                    //+NC1.07
                end;
            }
            action(Output)
            {
                Caption = 'Output';
                Image = List;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                RunObject = Page "NPR Nc Task Output List";
                RunPageLink = "Task Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Output action';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateResponseText();
    end;

    trigger OnOpenPage()
    begin
        ShowProcessed := false;
        SetPresetFilters();
    end;

    var
        SyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        Text001: Label 'No Output';
        TaskMgt: Codeunit "NPR Nc Task Mgt.";
        ResponseText: Text;
        Text002: Label 'The %1 selected Task(s) will be scheduled for re-export\Continue?';
        ShowProcessed: Boolean;
        WebClient: Boolean;
        Text003: Label 'Updating: #1#############\Total: #2###############';
        TaskProcessorFilter: Code[20];
        NaviConnectTaskProcessorCode: Code[20];

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId, SessionId) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure SetPresetFilters()
    var
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        CurrentEntryNo: BigInteger;
    begin
        //-NC1.01
        CurrentEntryNo := "Entry No.";
        FilterGroup(2);
        //-NC2.01 [252048]
        SetFilter("Task Processor Code", TaskProcessorFilter);
        //+NC2.01 [252048]

        //-NC2.00
        //RESET;
        //+NC2.00
        if ShowProcessed then
            SetRange(Processed)
        else
            SetRange(Processed, false);

        //-NC2.00
        // IF ItemNo <> '' THEN BEGIN
        //  NaviConnectMgt.SetItemNoFilter(Rec,ItemNo);
        //  MARKEDONLY(TRUE);
        // END;
        //
        // //-NC1.22
        // SETFILTER("Task Processor Code",NaviConnectTaskProcessorCode);
        // //+NC1.22
        //+NC2.00
        FilterGroup(0);
        if Get(CurrentEntryNo) then;
        CurrPage.Update(false);
        //+NC1.01
    end;

    local procedure UpdateResponseText()
    var
        InStream: InStream;
        Line: Text;
        LF: Char;
        CR: Char;
        StreamReader: DotNet NPRNetStreamReader;
    begin
        //-NC2.01 [252048]
        // LF := 10;
        // CR := 13;
        // ResponseText := '';
        // CALCFIELDS(Response);
        // Response.CREATEINSTREAM(InStream);
        // WHILE NOT InStream.EOS DO BEGIN
        //  InStream.READTEXT(Line);
        //  IF ResponseText <> '' THEN
        //    ResponseText += FORMAT(CR) + FORMAT(LF);
        //  ResponseText += Line;
        // END;
        ResponseText := '';
        if not Response.HasValue then
            exit;
        CalcFields(Response);
        Response.CreateInStream(InStream, TEXTENCODING::UTF8);
        StreamReader := StreamReader.StreamReader(InStream);
        ResponseText := StreamReader.ReadToEnd();
        //+NC2.01 [252048]
    end;

    local procedure "--- Actions"()
    begin
    end;

    local procedure ImportNewTasks()
    var
        TaskProcessor: Record "NPR Nc Task Processor";
    begin
        //-NC1.22
        //IF PAGE.RUNMODAL(PAGE::"Task Worker Group",TaskWorkerGroup) = ACTION::LookupOK THEN
        //  TaskMgt.UpdateTasks(TaskWorkerGroup.Code);
        if not TaskProcessor.FindSet then begin
            SyncMgt.UpdateTaskProcessor(TaskProcessor);
            Commit;
        end;
        if PAGE.RunModal(PAGE::"NPR Nc Task Proces. List", TaskProcessor) <> ACTION::LookupOK then
            exit;

        TaskMgt.UpdateTasks(TaskProcessor);
        Clear(TaskMgt);
        //+NC1.22
    end;

    local procedure ProcessManually()
    var
        Task: Record "NPR Nc Task";
        Counter: Integer;
        Window: Dialog;
    begin
        CurrPage.SetSelectionFilter(Task);
        Window.Open(Text003);
        Window.Update(2, Task.Count);
        if Task.FindSet then
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                SyncMgt.ProcessTask(Task);
            until Task.Next = 0;
        Window.Close;
        CurrPage.Update(false);
    end;

    local procedure RescheduleForProcessing()
    var
        Task: Record "NPR Nc Task";
        Counter: Integer;
        Window: Dialog;
    begin
        CurrPage.SetSelectionFilter(Task);
        if Confirm(StrSubstNo(Text002, Task.Count), true) then begin
            Task.ModifyAll("Process Error", false, true);
            CurrPage.Update(false);
        end;
    end;

    local procedure ShowOutput()
    var
        NcTaskOutput: Record "NPR Nc Task Output";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        StreamReader: DotNet NPRNetStreamReader;
        InStr: InStream;
        Path: Text;
        Content: Text;
    begin
        CalcFields("Data Output");
        if not "Data Output".HasValue then begin
            //-NC2.17 [335927]
            NcTaskOutput.SetRange("Task Entry No.", "Entry No.");
            if NcTaskOutput.FindLast and NcTaskOutput.Data.HasValue then begin
                NcTaskOutput.CalcFields(Data);
                NcTaskOutput.Data.CreateInStream(InStr, TEXTENCODING::UTF8);
                Path := TemporaryPath + NcTaskOutput.Name;
                DownloadFromStream(InStr, 'Export', FileMgt.Magicpath, '.' + FileMgt.GetExtension(NcTaskOutput.Name), Path);
                HyperLink(Path);
                exit;
            end;
            //+NC2.17 [335927]
            Message(Text001);
            exit;
        end;
        //-NC2.01 [252048]
        "Data Output".CreateInStream(InStr, TEXTENCODING::UTF8);
        //+NC2.01 [252048]
        if IsWebClient() then begin
            //-NC2.01 [252048]
            //"Data Output".CREATEINSTREAM(InStr);
            //+NC2.01 [252048]
            StreamReader := StreamReader.StreamReader(InStr);
            Content := StreamReader.ReadToEnd();
            Message(Content);
        end else begin
            //-NC2.01 [252048]
            //TempBlob.Blob := "Data Output";
            //Path := FileMgt.BLOBExport(TempBlob,TEMPORARYPATH + 'Task-' + FORMAT("Entry No.") + '.xml',FALSE);
            Path := TemporaryPath + 'Task-' + Format("Entry No.") + '.xml';
            StreamReader := StreamReader.StreamReader(InStr);
            DownloadFromStream(InStr, 'Export', FileMgt.Magicpath, '.xml', Path);
            //+NC2.01 [252048]
            SyncMgt.RunProcess('notepad.exe', Path, false);
            //-#285886 [285886]
            // SLEEP(100);
            // FileMgt.DeleteClientFile(Path);
            //+#285886 [285886]
        end;
    end;

    local procedure RunSourceCard()
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
    begin
        //-NC2.00
        //NaviConnectMgt.RunSourceCard(Rec);
        NcTaskMgt.RunSourceCard(Rec);
        //+NC2.00
    end;
}

