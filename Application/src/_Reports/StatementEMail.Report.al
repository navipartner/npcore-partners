report 6014550 "NPR Statement E-Mail"
{
    Caption = 'Statement - Paper/E-Mail';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    UseRequestPage = false;
    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Search Name", "Print Statements", "Currency Filter";

            trigger OnAfterGetRecord()
            var
                TempEmailAttachment: Record "NPR E-mail Attachment" temporary;
                EmailTemplateHeader: Record "NPR E-mail Template Header";
                ReportSelections: Record "Report Selections";
                DocSendProfile: Record "Document Sending Profile";
                EmailMgt: Codeunit "NPR E-mail Management";
                RecRef: RecordRef;
                FldRef: FieldRef;
                ReportGenerated: Boolean;
                FilterGroupNo: Integer;
                OStream: OutStream;
                Filename: Text[50];
                SendToEmail: Text[250];
            begin
                DocSendProfile.GetDefaultForCustomer(Customer."No.", DocSendProfile);
                if DocSendProfile."E-Mail" = DocSendProfile."E-Mail"::No then
                    CurrReport.Skip();

                RecRef.GetTable(Customer);
                ReportGenerated := false;
                ReportSelections.SetRange(Usage, ReportSelections.Usage::"C.Statement");
                ReportSelections.SetFilter("Report ID", '<>0');
                if ReportSelections.FindSet() then
                    repeat
                        if Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send now" then
                            if EmailMgt.GetEmailTemplateHeader(RecRef, EmailTemplateHeader) then begin
                                Filename := EmailMgt.GetFilename(EmailTemplateHeader, RecRef);
                                TempEmailAttachment.DeleteAll();
                                TempEmailAttachment.Init();
                                TempEmailAttachment.Description := Filename;
                                TempEmailAttachment."Attached File".CreateOutStream(OStream);
                                FldRef := RecRef.Field(1);
                                FilterGroupNo := SetNextGroupFilter(RecRef, FldRef, Customer."No.");
                                ReportGenerated := REPORT.SaveAs(ReportSelections."Report ID", RequestPageParameters, REPORTFORMAT::Pdf, OStream, RecRef);
                                SetGroupFilter(RecRef, FldRef, '', FilterGroupNo);
                                if ReportGenerated then
                                    ReportGenerated := TempEmailAttachment."Attached File".HasValue;
                                if ReportGenerated then begin
                                    ReportGenerated := false;
                                    SendToEmail := GetCustomReportSelectionEmail(Customer."No.", ReportSelections."Report ID");
                                    if SendToEmail = '' then
                                        SendToEmail := Customer."E-Mail";
                                    TempEmailAttachment.Insert();
                                    if EmailMgt.SetupEmailTemplate(RecRef, SendToEmail, true, EmailTemplateHeader) = '' then
                                        if EmailMgt.CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader, RecRef, DATABASE::Customer) = '' then begin
                                            if EmailMgt.AddAttachmentToSmtpMessage(TempEmailAttachment) then begin
                                                EmailMgt.SendSmtpMessage(RecRef, true);
                                                ReportGenerated := true;
                                            end;
                                        end;
                                end;
                            end;

                        if Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send through NaviDocs" then begin
                            SendToEmail := GetCustomReportSelectionEmail(Customer."No.", ReportSelections."Report ID");
                            if SendToEmail = '' then
                                SendToEmail := Customer."E-Mail";
                            AddtoNaviDocs(RecRef, ReportSelections."Report ID", SendToEmail, NaviDocsDelayUntil);
                            ReportGenerated := true;
                        end;
                    until ReportSelections.Next() = 0;
                if ReportGenerated then
                    Counter += 1;
                RecRef.Close();
            end;

            trigger OnPostDataItem()
            begin
                Message(StrSubstNo(Txt001, Format(Counter)));
            end;

            trigger OnPreDataItem()
            var
                RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
                RecRef: RecordRef;
            begin
                Counter := 0;
                RecRef.Open(18);
                RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob);
                Customer.SetView(RecRef.GetView());
                Evaluate(Pdf2NavOutputMethod, RequestPageParametersHelper.GetRequestPageOptionValue('Pdf2NavOutputMethod', RequestPageParameters));
                Evaluate(NaviDocsDelayUntil, RequestPageParametersHelper.GetRequestPageOptionValue('NaviDocsDelayUntil', RequestPageParameters), 9);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowOverdueEntries; PrintEntriesDue)
                    {
                        Caption = 'Show Overdue Entries';

                        ToolTip = 'Specifies the value of the Show Overdue Entries field';
                        ApplicationArea = NPRRetail;
                    }
                    field(IncludeAllCustomerswithLE; PrintAllHavingEntry)
                    {
                        Caption = 'Include All Customers with Ledger Entries';
                        MultiLine = true;

                        ToolTip = 'Specifies the value of the Include All Customers with Ledger Entries field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if not PrintAllHavingEntry then
                                PrintAllHavingBal := true;
                        end;
                    }
                    field(IncludeAllCustomerswithBalance; PrintAllHavingBal)
                    {
                        Caption = 'Include All Customers with a Balance';
                        MultiLine = true;

                        ToolTip = 'Specifies the value of the Include All Customers with a Balance field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if not PrintAllHavingBal then
                                PrintAllHavingEntry := true;
                        end;
                    }
                    field(IncludeReversedEntries; PrintReversedEntries)
                    {
                        Caption = 'Include Reversed Entries';

                        ToolTip = 'Specifies the value of the Include Reversed Entries field';
                        ApplicationArea = NPRRetail;
                    }
                    field(IncludeUnappliedEntries; PrintUnappliedEntries)
                    {
                        Caption = 'Include Unapplied Entries';

                        ToolTip = 'Specifies the value of the Include Unapplied Entries field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Include Aging Band"; IncludeAgingBand)
                    {
                        Caption = 'Include Aging Band';

                        ToolTip = 'Specifies the value of the Include Aging Band field';
                        ApplicationArea = NPRRetail;
                    }
                    field(AgingBandPeriodLengt; PeriodLength)
                    {
                        Caption = 'Aging Band Period Length';

                        ToolTip = 'Specifies the value of the Aging Band Period Length field';
                        ApplicationArea = NPRRetail;
                    }
                    field(AgingBandby; DateChoice)
                    {
                        Caption = 'Aging Band by';
                        OptionCaption = 'Due Date,Posting Date';

                        ToolTip = 'Specifies the value of the Aging Band by field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Log Interaction"; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;

                        ToolTip = 'Specifies the value of the Log Interaction field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Start Date"; StartDate)
                    {
                        Caption = 'Start Date';

                        ToolTip = 'Specifies the value of the Start Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("End Date"; EndDate)
                    {
                        Caption = 'End Date';

                        ToolTip = 'Specifies the value of the End Date field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group("Output Options")
                {
                    Caption = 'Output Options';
                    field(ReportOutput; Pdf2NavOutputMethod)
                    {
                        Caption = 'Report Output';
                        OptionCaption = 'Send now,Send through NaviDocs';

                        ToolTip = 'Specifies the value of the Report Output field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send through NaviDocs" then
                                if not IsNaviDocsEnabled() then begin
                                    Pdf2NavOutputMethod := Pdf2NavOutputMethod::"Send now";
                                    Message(NaviDocsDisabled);
                                    RequestOptionsPage.Update();
                                end;

                            ShowNaviDocsOption := Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send through NaviDocs";
                        end;
                    }
                    group("NaviDocs options")
                    {
                        Visible = ShowNaviDocsOption;
                        field("Delay sending until"; NaviDocsDelayUntil)
                        {

                            Caption = 'Delay sending until';
                            ToolTip = 'Specifies the value of the NaviDocsDelayUntil field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }

        trigger OnClosePage()
        begin
            if (StartDate <> 0D) and (EndDate <> 0D) then
                Customer.SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
        end;

        trigger OnOpenPage()
        begin
            InitRequestPageDataInternal();
            if not IsNaviDocsEnabled() then
                Pdf2NavOutputMethod := Pdf2NavOutputMethod::"Send now";
            ShowNaviDocsOption := Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send through NaviDocs";
        end;
    }

    trigger OnInitReport()
    begin
        LogInteractionEnable := true;
    end;

    trigger OnPreReport()
    var
        StatementEMail: Report "NPR Statement E-Mail";
        OutStr: OutStream;
    begin
        StatementEMail.SetTableView(Customer);
        CurrReport.UseRequestPage(false);
        RequestPageParameters := StatementEMail.RunRequestPage();
        if RequestPageParameters = '' then
            CurrReport.Quit();
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(RequestPageParameters);
    end;

    var
        SegManagement: Codeunit SegManagement;
        TempBlob: Codeunit "Temp Blob";
        PeriodLength: DateFormula;
        IncludeAgingBand: Boolean;
        isInitialized: Boolean;
        LogInteraction: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        PrintAllHavingBal: Boolean;
        PrintAllHavingEntry: Boolean;
        PrintEntriesDue: Boolean;
        PrintReversedEntries: Boolean;
        PrintUnappliedEntries: Boolean;
        [InDataSet]
        ShowNaviDocsOption: Boolean;
        EndDate: Date;
        StartDate: Date;
        NaviDocsDelayUntil: DateTime;
        Counter: Integer;
        NaviDocsDisabled: Label 'NaviDocs is''t Enabled.';
        AttachmentDescription: Label 'Report parameters';
        Txt001: Label 'Statement sent to %1 customers.';
        DateChoice: Option "Due Date","Posting Date";
        Pdf2NavOutputMethod: Option "Send now","Send through NaviDocs";
        RequestPageParameters: Text;

    procedure InitRequestPageDataInternal()
    begin
        if isInitialized then
            exit;

        isInitialized := true;

        if (not PrintAllHavingEntry) and (not PrintAllHavingBal) then
            PrintAllHavingBal := true;

        LogInteraction := SegManagement.FindInteractTmplCode(7) <> '';
        LogInteractionEnable := LogInteraction;

        if Format(PeriodLength) = '' then
            Evaluate(PeriodLength, '<1M+CM>');
    end;

    local procedure AddtoNaviDocs(var RecRef: RecordRef; ReportId: Integer; SendToEmail: Text; DelayUntil: DateTime)
    var
        TempNaviDocsEntryAttachment: Record "NPR NaviDocs Entry Attachment" temporary;
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
        RecRefBlob: RecordRef;
    begin
        TempNaviDocsEntryAttachment."Data Type" := 'Report PARAM';

        RecRefBlob.GetTable(TempNaviDocsEntryAttachment);
        TempBlob.ToRecordRef(RecRefBlob, TempNaviDocsEntryAttachment.FieldNo(Data));
        RecRefBlob.SetTable(TempNaviDocsEntryAttachment);

        TempNaviDocsEntryAttachment.Description := AttachmentDescription;
        TempNaviDocsEntryAttachment."File Extension" := 'xml';
        TempNaviDocsEntryAttachment."Internal Type" := TempNaviDocsEntryAttachment."Internal Type"::"Report Parameters";
        TempNaviDocsEntryAttachment.Insert();
        NaviDocsManagement.AddDocumentEntryWithAttachments(RecRef, NaviDocsManagement.HandlingTypeMailCode(), ReportId, SendToEmail, '', DelayUntil, TempNaviDocsEntryAttachment);
    end;

    local procedure GetCustomReportSelectionEmail(CustomerNo: Code[20]; ReportID: Integer): Text
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        CustomReportSelection.SetRange(Usage, CustomReportSelection.Usage::"C.Statement");
        CustomReportSelection.SetRange("Source Type", 18);
        CustomReportSelection.SetRange("Source No.", CustomerNo);
        CustomReportSelection.SetRange("Report ID", ReportID);
        if CustomReportSelection.FindFirst() then
            exit(CustomReportSelection."Send To Email");
        CustomReportSelection.SetRange("Report ID", 0);
        if CustomReportSelection.FindFirst() then
            exit(CustomReportSelection."Send To Email");
        exit('');
    end;

    local procedure FindNextEmptyFilterGroup(var RecordRef: RecordRef): Integer
    var
        FilterGroupUsed: Integer;
        StartingGroup: Integer;
    begin
        StartingGroup := RecordRef.FilterGroup;
        FilterGroupUsed := StartingGroup;

        if FilterGroupUsed < 10 then
            FilterGroupUsed := 10;

        RecordRef.FilterGroup(FilterGroupUsed);
        if RecordRef.HasFilter() then
            repeat
                FilterGroupUsed += 1;
                RecordRef.FilterGroup(FilterGroupUsed);
            until not RecordRef.HasFilter();

        RecordRef.FilterGroup(StartingGroup);

        exit(FilterGroupUsed);
    end;

    local procedure SetNextGroupFilter(var RecordRef: RecordRef; var FieldRef: FieldRef; "Filter": Text): Integer
    var
        NextGroup: Integer;
    begin
        NextGroup := FindNextEmptyFilterGroup(RecordRef);
        SetGroupFilter(RecordRef, FieldRef, Filter, NextGroup);
        exit(NextGroup);
    end;

    local procedure SetGroupFilter(var RecordRef: RecordRef; var FieldRef: FieldRef; "Filter": Text; GroupNumber: Integer)
    var
        StartFilterGroup: Integer;
    begin
        StartFilterGroup := RecordRef.FilterGroup;
        RecordRef.FilterGroup(GroupNumber);
        FieldRef.SetFilter(Filter);
        RecordRef.FilterGroup(StartFilterGroup);
    end;

    local procedure IsNaviDocsEnabled(): Boolean
    var
        NaviDocsSetup: Record "NPR NaviDocs Setup";
    begin
        exit(NaviDocsSetup.Get() and NaviDocsSetup."Enable NaviDocs");
    end;
}

