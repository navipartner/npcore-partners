report 6014550 "NPR Statement E-Mail"
{
    // PN1.00/MH/20140730  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Report is a wrapper for the Standard Report 116 Statement and is used for sending e-mails using PDF2NAV.
    // NPR4.16/TTH/20151005  CASE  222376 PDF2NAV Changes.
    // PN1.08/TR/20151209  CASE 226704 Date filter fields created, such that the report mimics report 116.
    // PN1.08/MHA/20151214 CASE 228859 SendSmtpMessage() changed to always get smtp setup from E-mail Setup
    // NPR5.38/THRO/20171114 CASE 271591 removed save to file
    // NPR5.42/THRO/20180516 CASE 314622 only send mail is statement report generates output
    // NPR5.43/THRO/20180614 CASE 316218 Using this report for parameters but sending reports set up in Report Selections
    //                                   Added option to send through NaviDocs
    //                                   Cleanup in old code
    // 
    // NPR5.44/THRO/20180716 CASE 316218 Disabling Send Through NaviDocs if NaviDocs isn't enabled
    //                                   Setting Date Filter to StartDate..EndDate for use in report 6014545
    // NPR5.53/ZESO/20191213 CASE 382223 Correct bug on Email address being used.

    Caption = 'Statement - Paper/E-Mail';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    UseRequestPage = false;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING("No.") WHERE("NPR Document Processing" = FILTER(Email | PrintAndEmail));
            RequestFilterFields = "No.", "Search Name", "Print Statements", "Currency Filter";

            trigger OnAfterGetRecord()
            var
                EmailTemplateHeader: Record "NPR E-mail Template Header";
                ReportSelections: Record "Report Selections";
                EmailAttachmentTemp: Record "NPR E-mail Attachment" temporary;
                EmailMgt: Codeunit "NPR E-mail Management";
                RecRef: RecordRef;
                Filename: Text[50];
                OStream: OutStream;
                FldRef: FieldRef;
                FilterGroupNo: Integer;
                ReportGenerated: Boolean;
                SendToEmail: Text[250];
            begin
                RecRef.GetTable(Customer);
                //-NPR5.43 [316218]
                ReportGenerated := false;
                ReportSelections.SetRange(Usage, ReportSelections.Usage::"C.Statement");
                ReportSelections.SetFilter("Report ID", '<>0');
                if ReportSelections.FindSet then
                    repeat
                        if Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send now" then
                            //-NPR5.43 [316218]
                            if EmailMgt.GetEmailTemplateHeader(RecRef, EmailTemplateHeader) then begin
                                Filename := EmailMgt.GetFilename(EmailTemplateHeader, RecRef);
                                //-NPR5.43 [316218]
                                //Statement.SetSettings(PrintEntriesDue,PrintAllHavingEntry,PrintAllHavingBal,PrintReversedEntries,
                                //  PrintUnappliedEntries,IncludeAgingBand,PeriodLength,DateChoice,LogInteraction,StartDate,EndDate);
                                //Statement.SETTABLEVIEW(Customer2);
                                //+NPR5.43 [316218]

                                EmailAttachmentTemp.DeleteAll;
                                EmailAttachmentTemp.Init;
                                EmailAttachmentTemp.Description := Filename;
                                EmailAttachmentTemp."Attached File".CreateOutStream(OStream);
                                //-NPR5.43 [316218]
                                //IF Statement.SAVEAS('',REPORTFORMAT::Pdf,OStream) THEN
                                FldRef := RecRef.Field(1);
                                FilterGroupNo := SetNextGroupFilter(RecRef, FldRef, Customer."No.");
                                ReportGenerated := REPORT.SaveAs(ReportSelections."Report ID", RequestPageParameters, REPORTFORMAT::Pdf, OStream, RecRef);
                                SetGroupFilter(RecRef, FldRef, '', FilterGroupNo);
                                if ReportGenerated then
                                    ReportGenerated := EmailAttachmentTemp."Attached File".HasValue;
                                if ReportGenerated then begin
                                    ReportGenerated := false;
                                    SendToEmail := GetCustomReportSelectionEmail(Customer."No.", ReportSelections."Report ID");
                                    if SendToEmail = '' then
                                        SendToEmail := Customer."E-Mail";
                                    //+NPR5.43 [316218]

                                    EmailAttachmentTemp.Insert;
                                    //-NPR5.53 [382223]
                                    //IF EmailMgt.SetupEmailTemplate(RecRef,Customer."E-Mail",TRUE,EmailTemplateHeader) = '' THEN
                                    if EmailMgt.SetupEmailTemplate(RecRef, SendToEmail, true, EmailTemplateHeader) = '' then
                                        //+NPR5.53 [382223]
                                        if EmailMgt.CreateSmtpMessageFromEmailTemplate(EmailTemplateHeader, RecRef, DATABASE::Customer) = '' then begin
                                            if EmailMgt.AddAttachmentToSmtpMessage(EmailAttachmentTemp) then begin
                                                EmailMgt.SendSmtpMessage(RecRef, true);
                                                ReportGenerated := true;
                                            end;
                                        end;
                                end;
                            end;

                        //-NPR5.43 [316218]
                        if Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send through NaviDocs" then begin
                            SendToEmail := GetCustomReportSelectionEmail(Customer."No.", ReportSelections."Report ID");
                            if SendToEmail = '' then
                                SendToEmail := Customer."E-Mail";
                            AddtoNaviDocs(RecRef, ReportSelections."Report ID", SendToEmail, NaviDocsDelayUntil);
                            ReportGenerated := true;
                        end;
                    until ReportSelections.Next = 0;
                if ReportGenerated then
                    Counter += 1;
                //-NPR5.43 [316218]
                RecRef.Close;
            end;

            trigger OnPostDataItem()
            begin
                Message(StrSubstNo(Txt001, Format(Counter)));
            end;

            trigger OnPreDataItem()
            var
                RecRef: RecordRef;
                RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
            begin
                Counter := 0;
                //-NPR5.43 [316218]
                RecRef.Open(18);
                RequestPageParametersHelper.ConvertParametersToFilters(RecRef, TempBlob);
                Customer.SetView(RecRef.GetView);
                Evaluate(Pdf2NavOutputMethod, RequestPageParametersHelper.GetRequestPageOptionValue('Pdf2NavOutputMethod', RequestPageParameters));
                Evaluate(NaviDocsDelayUntil, RequestPageParametersHelper.GetRequestPageOptionValue('NaviDocsDelayUntil', RequestPageParameters), 9);
                //+NPR5.43 [316218]
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
                        ApplicationArea=All;
                    }
                    field(IncludeAllCustomerswithLE; PrintAllHavingEntry)
                    {
                        Caption = 'Include All Customers with Ledger Entries';
                        MultiLine = true;
                        ApplicationArea=All;

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
                        ApplicationArea=All;

                        trigger OnValidate()
                        begin
                            if not PrintAllHavingBal then
                                PrintAllHavingEntry := true;
                        end;
                    }
                    field(IncludeReversedEntries; PrintReversedEntries)
                    {
                        Caption = 'Include Reversed Entries';
                        ApplicationArea=All;
                    }
                    field(IncludeUnappliedEntries; PrintUnappliedEntries)
                    {
                        Caption = 'Include Unapplied Entries';
                        ApplicationArea=All;
                    }
                    field(IncludeAgingBand; IncludeAgingBand)
                    {
                        Caption = 'Include Aging Band';
                        ApplicationArea=All;
                    }
                    field(AgingBandPeriodLengt; PeriodLength)
                    {
                        Caption = 'Aging Band Period Length';
                        ApplicationArea=All;
                    }
                    field(AgingBandby; DateChoice)
                    {
                        Caption = 'Aging Band by';
                        OptionCaption = 'Due Date,Posting Date';
                        ApplicationArea=All;
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ApplicationArea=All;
                    }
                    field(StartDate; StartDate)
                    {
                        Caption = 'Start Date';
                        ApplicationArea=All;
                    }
                    field(EndDate; EndDate)
                    {
                        Caption = 'End Date';
                        ApplicationArea=All;
                    }
                }
                group("Output Options")
                {
                    Caption = 'Output Options';
                    field(ReportOutput; Pdf2NavOutputMethod)
                    {
                        Caption = 'Report Output';
                        OptionCaption = 'Send now,Send through NaviDocs';
                        ApplicationArea=All;

                        trigger OnValidate()
                        begin
                            //-NPR5.44 [316218]
                            if Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send through NaviDocs" then
                                if not IsNaviDocsEnabled then begin
                                    Pdf2NavOutputMethod := Pdf2NavOutputMethod::"Send now";
                                    Message(NaviDocsDisabled);
                                    RequestOptionsPage.Update;
                                end;
                            //+NPR5.44 [316218]

                            //-NPR5.43 [316218]
                            ShowNaviDocsOption := Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send through NaviDocs";
                            //+NPR5.43 [316218]
                        end;
                    }
                    group("NaviDocs options")
                    {
                        Visible = ShowNaviDocsOption;
                        field("Delay sending until"; NaviDocsDelayUntil)
                        {
                            ApplicationArea=All;
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnClosePage()
        begin
            //-NPR5.44 [316218]
            if (StartDate <> 0D) and (EndDate <> 0D) then
                Customer.SetFilter("Date Filter", '%1..%2', StartDate, EndDate);
            //+NPR5.44 [316218]
        end;

        trigger OnOpenPage()
        begin
            InitRequestPageDataInternal;
            //-NPR5.44 [316218]
            if not IsNaviDocsEnabled then
                Pdf2NavOutputMethod := Pdf2NavOutputMethod::"Send now";
            //+NPR5.44 [316218]
            //-NPR5.43 [316218]
            ShowNaviDocsOption := Pdf2NavOutputMethod = Pdf2NavOutputMethod::"Send through NaviDocs";
            //+NPR5.43 [316218]
        end;
    }

    labels
    {
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
        //-PN1.08
        //IF NaviDocsSetup.GET THEN ;
        //+PN1.08
        //-NPR5.43 [316218]
        StatementEMail.SetTableView(Customer);
        CurrReport.UseRequestPage(false);
        RequestPageParameters := StatementEMail.RunRequestPage();
        if RequestPageParameters = '' then
            CurrReport.Quit;
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(RequestPageParameters);
        //+NPR5.43 [316218]
    end;

    var
        PrintAllHavingEntry: Boolean;
        PrintAllHavingBal: Boolean;
        PrintEntriesDue: Boolean;
        PrintUnappliedEntries: Boolean;
        PrintReversedEntries: Boolean;
        LogInteraction: Boolean;
        PeriodLength: DateFormula;
        DateChoice: Option "Due Date","Posting Date";
        SegManagement: Codeunit SegManagement;
        IncludeAgingBand: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        isInitialized: Boolean;
        Counter: Integer;
        Txt001: Label 'Statement sent to %1 customers.';
        "-- PN71.1.08": Integer;
        StartDate: Date;
        EndDate: Date;
        RequestPageParameters: Text;
        TempBlob: Codeunit "Temp Blob";
        Pdf2NavOutputMethod: Option "Send now","Send through NaviDocs";
        NaviDocsDelayUntil: DateTime;
        [InDataSet]
        ShowNaviDocsOption: Boolean;
        NaviDocsDisabled: Label 'NaviDocs is''t Enabled.';
        AttachmentDescription: Label 'Report parameters';

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
        //-NPR5.43 [316218]
        TempNaviDocsEntryAttachment."Data Type" := 'Report PARAM';

        RecRefBlob.GetTable(TempNaviDocsEntryAttachment);
        TempBlob.ToRecordRef(RecRefBlob, TempNaviDocsEntryAttachment.FieldNo(Data));
        RecRefBlob.SetTable(TempNaviDocsEntryAttachment);

        TempNaviDocsEntryAttachment.Description := AttachmentDescription;
        TempNaviDocsEntryAttachment."File Extension" := 'xml';
        TempNaviDocsEntryAttachment."Internal Type" := TempNaviDocsEntryAttachment."Internal Type"::"Report Parameters";
        TempNaviDocsEntryAttachment.Insert;
        NaviDocsManagement.AddDocumentEntryWithAttachments(RecRef, NaviDocsManagement.HandlingTypeMailCode, ReportId, SendToEmail, '', DelayUntil, TempNaviDocsEntryAttachment);
        //+NPR5.43 [316218]
    end;

    local procedure GetCustomReportSelectionEmail(CustomerNo: Code[20]; ReportID: Integer): Text
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        //-NPR5.43 [316218]
        CustomReportSelection.SetRange(Usage, CustomReportSelection.Usage::"C.Statement");
        CustomReportSelection.SetRange("Source Type", 18);
        CustomReportSelection.SetRange("Source No.", CustomerNo);
        CustomReportSelection.SetRange("Report ID", ReportID);
        if CustomReportSelection.FindFirst then
            exit(CustomReportSelection."Send To Email");
        CustomReportSelection.SetRange("Report ID", 0);
        if CustomReportSelection.FindFirst then
            exit(CustomReportSelection."Send To Email");
        exit('');
        //+NPR5.43 [316218]
    end;

    local procedure FindNextEmptyFilterGroup(var RecordRef: RecordRef): Integer
    var
        FilterGroupUsed: Integer;
        StartingGroup: Integer;
    begin
        //-NPR5.43 [316218]
        StartingGroup := RecordRef.FilterGroup;
        FilterGroupUsed := StartingGroup;

        if FilterGroupUsed < 10 then
            FilterGroupUsed := 10;

        RecordRef.FilterGroup(FilterGroupUsed);
        if RecordRef.HasFilter then
            repeat
                FilterGroupUsed += 1;
                RecordRef.FilterGroup(FilterGroupUsed);
            until not RecordRef.HasFilter;

        RecordRef.FilterGroup(StartingGroup);

        exit(FilterGroupUsed);
        //+NPR5.43 [316218]
    end;

    local procedure SetNextGroupFilter(var RecordRef: RecordRef; var FieldRef: FieldRef; "Filter": Text): Integer
    var
        NextGroup: Integer;
    begin
        //-NPR5.43 [316218]
        NextGroup := FindNextEmptyFilterGroup(RecordRef);
        SetGroupFilter(RecordRef, FieldRef, Filter, NextGroup);
        exit(NextGroup);
        //+NPR5.43 [316218]
    end;

    local procedure SetGroupFilter(var RecordRef: RecordRef; var FieldRef: FieldRef; "Filter": Text; GroupNumber: Integer)
    var
        StartFilterGroup: Integer;
    begin
        //-NPR5.43 [316218]
        StartFilterGroup := RecordRef.FilterGroup;
        RecordRef.FilterGroup(GroupNumber);
        FieldRef.SetFilter(Filter);
        RecordRef.FilterGroup(StartFilterGroup);
        //+NPR5.43 [316218]
    end;

    local procedure IsNaviDocsEnabled(): Boolean
    var
        NaviDocsSetup: Record "NPR NaviDocs Setup";
    begin
        //-NPR5.44 [316218]
        exit(NaviDocsSetup.Get and NaviDocsSetup."Enable NaviDocs");
        //+NPR5.44 [316218]
    end;
}

