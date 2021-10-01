page 6151502 "NPR Nc Task List"
{
    Caption = 'Task List';
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Navigate,NaviPartner';
    ShowFilter = true;
    SourceTable = "NPR Nc Task";
    UsageCategory = Tasks;
    SourceTableView = SORTING("Log Date")
                      ORDER(Descending);
    ApplicationArea = NPRNaviConnect;

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
                    field("COUNT"; Rec.Count)
                    {

                        Caption = 'Quantity';
                        Editable = false;
                        ToolTip = 'Specifies the value of the Quantity field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(TaskProcessorFilter; TaskProcessorFilter)
                    {

                        Caption = 'Task Processor';
                        TableRelation = "NPR Nc Task Processor";
                        ToolTip = 'Specifies the value of the Task Processor field';
                        ApplicationArea = NPRNaviConnect;

                        trigger OnValidate()
                        begin
                            SetPresetFilters();
                        end;
                    }
                    field("Show Exported"; ShowProcessed)
                    {

                        Caption = 'Show Processed';
                        ToolTip = 'Specifies the value of the Show Processed field';
                        ApplicationArea = NPRNaviConnect;

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

                        Caption = 'Response:                                                                                                                                                                                                                                                                               _';
                        HideValue = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the Response:                                                                                                                                                                                                                                                                               _ field';
                        ApplicationArea = NPRNaviConnect;
                    }
                    field(ResponseText; ResponseText)
                    {

                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                        ToolTip = 'Specifies the value of the ResponseText field';
                        ApplicationArea = NPRNaviConnect;
                    }
                }
            }
            repeater(Control6150622)
            {
                ShowCaption = false;
                field("Task Processor Code"; Rec."Task Processor Code")
                {

                    ToolTip = 'Specifies the value of the Task Processor Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Processed; Rec.Processed)
                {

                    ToolTip = 'Specifies the value of the Processed field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Process Error"; Rec."Process Error")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Error field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Company Name"; Rec."Company Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Type; Rec.Type)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table Name"; Rec."Table Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Record Value"; Rec."Record Value")
                {

                    ToolTip = 'Specifies the value of the Record Value field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Record Position"; Rec."Record Position")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Record Position field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Log Date"; Rec."Log Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Log Date field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Last Checked1"; Rec."Last Processing Started at")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Processing Started at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Last Processing Completed at"; Rec."Last Processing Completed at")
                {

                    ToolTip = 'Specifies the value of the Last Processing Completed at field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Last Processing Duration"; Rec."Last Processing Duration")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Processing Duration (sec.) field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Process Count"; Rec."Process Count")
                {

                    ToolTip = 'Specifies the value of the Process Count field';
                    ApplicationArea = NPRNaviConnect;
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

                ToolTip = 'Executes the Import new Tasks action';
                ApplicationArea = NPRNaviConnect;

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

                ToolTip = 'Executes the Process Manually action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    ProcessManually();
                end;
            }
            action("Reschedule For Processing")
            {
                Caption = 'Reschedule for Processing';
                Image = UpdateXML;
                ShortCutKey = 'F9';

                ToolTip = 'Executes the Reschedule for Processing action';
                ApplicationArea = NPRNaviConnect;

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

                ToolTip = 'Executes the Fields action';
                ApplicationArea = NPRNaviConnect;
            }
            action("Show Output")
            {
                Caption = 'Show Output';
                Image = XMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                ToolTip = 'Executes the Show Output action';
                ApplicationArea = NPRNaviConnect;

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

                ToolTip = 'Executes the Source Card action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                begin
                    RunSourceCard();
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

                ToolTip = 'Executes the Output action';
                ApplicationArea = NPRNaviConnect;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateResponseText();
    end;

    trigger OnOpenPage()
    begin
        SetPresetFilters();
    end;

    procedure SetShowProcessed(ShowProcessedPar: Boolean)
    begin
        ShowProcessed := ShowProcessedPar;
    end;

    var
        SyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        NoOutputMsg: Label 'No Output';
        TaskMgt: Codeunit "NPR Nc Task Mgt.";
        ResponseText: Text;
        ScheduleForReexportQst: Label 'The %1 selected Task(s) will be scheduled for re-export\Continue?';
        ShowProcessed: Boolean;
        OpenWindowTxt: Label 'Updating: #1#############\Total: #2###############';
        TaskProcessorFilter: Code[20];

    local procedure IsWebClient(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then
            exit(ActiveSession."Client Type" = ActiveSession."Client Type"::"Web Client");
        exit(false);
    end;

    local procedure SetPresetFilters()
    var
        CurrentEntryNo: BigInteger;
    begin
        CurrentEntryNo := Rec."Entry No.";
        Rec.FilterGroup(2);
        Rec.SetFilter("Task Processor Code", TaskProcessorFilter);

        if ShowProcessed then
            Rec.SetRange(Processed)
        else
            Rec.SetRange(Processed, false);

        Rec.FilterGroup(0);
        if Rec.Get(CurrentEntryNo) then;
        CurrPage.Update(false);
    end;

    local procedure UpdateResponseText()
    var
        InStr: InStream;
        BufferText: Text;
    begin
        ResponseText := '';
        if not Rec.Response.HasValue() then
            exit;
        Rec.CalcFields(Response);
        Rec.Response.CreateInStream(InStr, TextEncoding::UTF8);
        BufferText := '';
        while not InStr.EOS do begin
            InStr.ReadText(BufferText);
            ResponseText += BufferText;
        end;
    end;

    local procedure ImportNewTasks()
    var
        TaskProcessor: Record "NPR Nc Task Processor";
    begin
        if TaskProcessor.IsEmpty then begin
            SyncMgt.UpdateTaskProcessor(TaskProcessor);
            Commit();
        end;
        if PAGE.RunModal(PAGE::"NPR Nc Task Proces. List", TaskProcessor) <> ACTION::LookupOK then
            exit;

        TaskMgt.UpdateTasks(TaskProcessor);
        Clear(TaskMgt);
    end;

    local procedure ProcessManually()
    var
        Task: Record "NPR Nc Task";
        Task2: Record "NPR Nc Task";
        Counter: Integer;
        Window: Dialog;
    begin
        CurrPage.SetSelectionFilter(Task);
        Window.Open(OpenWindowTxt);
        Window.Update(2, Task.Count());
        if Task.FindSet() then
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Task2 := Task;
                SyncMgt.ProcessTask(Task2);
            until Task.Next() = 0;
        Window.Close();
        CurrPage.Update(false);
    end;

    local procedure RescheduleForProcessing()
    var
        Task: Record "NPR Nc Task";
    begin
        CurrPage.SetSelectionFilter(Task);
        if Confirm(ScheduleForReexportQst, true, Task.Count()) then begin
            Task.ModifyAll("Process Error", false, true);
            CurrPage.Update(false);
        end;
    end;

    local procedure ShowOutput()
    var
        NcTaskOutput: Record "NPR Nc Task Output";
        FileMgt: Codeunit "File Management";
        InStr: InStream;
        Content: Text;
        BufferText: Text;
    begin
        Rec.CalcFields("Data Output");
        if not Rec."Data Output".HasValue() then begin
            NcTaskOutput.SetRange("Task Entry No.", Rec."Entry No.");
            if NcTaskOutput.FindLast() and NcTaskOutput.Data.HasValue() then begin
                NcTaskOutput.CalcFields(Data);
                NcTaskOutput.Data.CreateInStream(InStr, TEXTENCODING::UTF8);
                DownloadFromStream(InStr, 'Export', FileMgt.Magicpath(), '.' + FileMgt.GetExtension(NcTaskOutput.Name), NcTaskOutput.Name);
                exit;
            end;
            Message(NoOutputMsg);
            exit;
        end;
        Rec."Data Output".CreateInStream(InStr, TextEncoding::UTF8);
        if IsWebClient() then begin
            BufferText := '';
            while not InStr.EOS() do begin
                InStr.ReadText(BufferText);
                Content += BufferText;
            end;
            Message(Content);
        end;
    end;

    local procedure RunSourceCard()
    var
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
    begin
        NcTaskMgt.RunSourceCard(Rec);
    end;
}

