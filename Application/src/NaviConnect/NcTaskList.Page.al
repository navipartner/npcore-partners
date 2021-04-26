page 6151502 "NPR Nc Task List"
{
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
                    field("COUNT"; Rec.Count)
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
                field("Task Processor Code"; Rec."Task Processor Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Processor Code field';
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed field';
                }
                field("Process Error"; Rec."Process Error")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Error field';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Record Value"; Rec."Record Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Record Value field';
                }
                field("Record Position"; Rec."Record Position")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Record Position field';
                }
                field("Log Date"; Rec."Log Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Log Date field';
                }
                field("Last Checked1"; Rec."Last Processing Started at")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Processing Started at field';
                }
                field("Last Processing Completed at"; Rec."Last Processing Completed at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Processing Completed at field';
                }
                field("Last Processing Duration"; Rec."Last Processing Duration")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Processing Duration (sec.) field';
                }
                field("Process Count"; Rec."Process Count")
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
        Text003: Label 'Updating: #1#############\Total: #2###############';
        TaskProcessorFilter: Code[20];

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
        if not TaskProcessor.FindSet() then begin
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
        Counter: Integer;
        Window: Dialog;
    begin
        CurrPage.SetSelectionFilter(Task);
        Window.Open(Text003);
        Window.Update(2, Task.Count());
        if Task.FindSet() then
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                SyncMgt.ProcessTask(Task);
            until Task.Next() = 0;
        Window.Close();
        CurrPage.Update(false);
    end;

    local procedure RescheduleForProcessing()
    var
        Task: Record "NPR Nc Task";
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
        FileMgt: Codeunit "File Management";
        InStr: InStream;
        Path: Text;
        Content: Text;
        BufferText: Text;
    begin
        Rec.CalcFields("Data Output");
        if not Rec."Data Output".HasValue() then begin
            NcTaskOutput.SetRange("Task Entry No.", Rec."Entry No.");
            if NcTaskOutput.FindLast() and NcTaskOutput.Data.HasValue() then begin
                NcTaskOutput.CalcFields(Data);
                NcTaskOutput.Data.CreateInStream(InStr, TEXTENCODING::UTF8);
                Path := TemporaryPath + NcTaskOutput.Name;
                DownloadFromStream(InStr, 'Export', FileMgt.Magicpath, '.' + FileMgt.GetExtension(NcTaskOutput.Name), Path);
                HyperLink(Path);
                exit;
            end;
            Message(Text001);
            exit;
        end;
        Rec."Data Output".CreateInStream(InStr, TextEncoding::UTF8);
        if IsWebClient() then begin
            BufferText := '';
            while not InStr.EOS do begin
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

