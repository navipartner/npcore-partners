report 6060137 "NPR MM Membership Batch Renew"
{
    Caption = 'Membership Batch Renew';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset
    {
        dataitem(ReportMembership; "NPR MM Membership")
        {
            RequestFilterFields = "External Membership No.", "Company Name", "Customer No.", "Issued Date", "Auto-Renew", "Remaining Points";
            dataitem(ReportMembershipRole; "NPR MM Membership Role")
            {
                DataItemLink = "Membership Entry No." = FIELD("Entry No.");
                PrintOnlyIfDetail = true;
                RequestFilterFields = "GDPR Approval";
                dataitem(ReportMember; "NPR MM Member")
                {
                    DataItemLink = "Entry No." = FIELD("Member Entry No.");
                    PrintOnlyIfDetail = true;
                    RequestFilterFields = "External Member No.", "First Name", "Last Name", "Post Code Code", City, "Country Code", Gender, Birthday, "Entry No.";

                    trigger OnPreDataItem()
                    begin
                        CurrReport.Break();
                    end;
                }

                trigger OnPreDataItem()
                begin
                    CurrReport.Break();
                end;
            }

            trigger OnPreDataItem()
            var
                MemberInfoCapture: Record "NPR MM Member Info Capture";
                MembershipAlterationJnlPage: Page "NPR MM Members. Alteration Jnl";
                Window: Dialog;
                ExistingCount: Integer;
                ProgressIndex: Integer;
                ProgressMax: Integer;
                LogMessage: Text;
                AlreadyExistQst: Label 'There are already %1 entries in the alteration journal, do you want to keep them?', Comment = '%1 = Number of entries';
            begin

                if (MembershipCode = '') then
                    exit;

                if (RenewUsingItem = '') then
                    exit;

                if (ValidOnDate = 0D) then
                    exit;

                if (GuiAllowed) then
                    Window.Open(PROGRESSLbl);

                ReportMembership.SetFilter("Membership Code", '=%1', MembershipCode);
                if (ReportMembership.FindSet()) then begin
                    ProgressMax := ReportMembership.Count();

                    MemberInfoCapture.SetFilter("Source Type", '=%1', MemberInfoCapture."Source Type"::ALTERATION_JNL);
                    MemberInfoCapture.SetFilter("Document No.", '=%1', UserId);
                    ExistingCount := MemberInfoCapture.Count();
                    if (ExistingCount > 0) then
                        if (not Confirm(AlreadyExistQst, true, ExistingCount)) then
                            MemberInfoCapture.DeleteAll();

                    repeat
                        if (DoRenew(ReportMembership, LogMessage)) then begin
                            AddToJournal(ReportMembership);
                        end else
                            if (ShowVerbose) then begin
                                LogToJournal(ReportMembership, LogMessage);
                            end;

                        if (GuiAllowed) then
                            Window.Update(1, Round(ProgressIndex / ProgressMax * 9999, 1));

                        ProgressIndex += 1;

                    until (ReportMembership.Next() = 0);

                    if (GuiAllowed) then
                        Window.Close();

                    if (LaunchAltJnlPage) then begin
                        MembershipAlterationJnlPage.SetTableView(MemberInfoCapture);
                        MembershipAlterationJnlPage.Run();
                    end;

                end;

                exit;
            end;
        }
    }

    requestpage
    {
        Caption = 'Membership Mass Renew';
        DeleteAllowed = false;
        InsertAllowed = false;
        ModifyAllowed = false;
        ShowFilter = false;

        layout
        {
            area(content)
            {
                field("Membership Code"; MembershipCode)
                {
                    Caption = 'Membership Code';
                    ShowMandatory = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MembershipSetup: Record "NPR MM Membership Setup";
                        MembershipSetupPage: Page "NPR MM Membership Setup";
                        PageAction: Action;
                    begin
                        MembershipSetupPage.Editable(false);
                        MembershipSetupPage.LookupMode(true);
                        MembershipSetupPage.SetTableView(MembershipSetup);
                        PageAction := MembershipSetupPage.RunModal();
                        if (PageAction <> ACTION::LookupOK) then
                            exit(false);

                        MembershipSetupPage.GetRecord(MembershipSetup);
                        MembershipCode := MembershipSetup.Code;
                        Text := MembershipCode;
                        exit(true);
                    end;
                }
                field("Valid On Date"; ValidOnDate)
                {
                    Caption = 'Active On Date';
                    ShowMandatory = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active On Date field';
                }
                field("Type Of Active"; TypeOfActive)
                {
                    Caption = 'Active Type';
                    OptionCaption = 'Active,Last Period';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active Type field';
                }
                field("Renew Using Item"; RenewUsingItem)
                {
                    Caption = 'Renew Using Item';
                    ShowMandatory = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Renew Using Item field';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
                        MembershipAlterationPage: Page "NPR MM Membership Alter.";
                        PageAction: Action;
                    begin
                        MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', MembershipAlterationSetup."Alteration Type"::RENEW);
                        MembershipAlterationSetup.SetFilter("From Membership Code", '=%1', MembershipCode);
                        MembershipAlterationPage.Editable(false);
                        MembershipAlterationPage.LookupMode(true);
                        MembershipAlterationPage.SetTableView(MembershipAlterationSetup);
                        PageAction := MembershipAlterationPage.RunModal();
                        if (PageAction <> ACTION::LookupOK) then
                            exit(false);

                        MembershipAlterationPage.GetRecord(MembershipAlterationSetup);
                        RenewUsingItem := MembershipAlterationSetup."Sales Item No.";
                        RenewDescription := MembershipAlterationSetup.Description;
                        Text := RenewUsingItem;

                        exit(true);
                    end;
                }
                field(Verbose; ShowVerbose)
                {
                    Caption = 'Verbose';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Verbose field';
                }
            }
        }

    }


    trigger OnInitReport()
    begin
        LaunchAltJnlPage := true;
    end;

    var
        LaunchAltJnlPage: Boolean;
        ShowVerbose: Boolean;
        MembershipCode: Code[20];
        RenewUsingItem: Code[20];
        ValidOnDate: Date;
        PROGRESSLbl: Label 'Working: @1@@@@@@@@@@@@@@@@@@';
        TypeOfActive: Option ACTIVE,LAST_PERIOD;
        RenewDescription: Text;

    local procedure DoRenew(Membership: Record "NPR MM Membership"; var ReasonText: Text): Boolean
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        FromDate: Date;
        UntilDate: Date;
        NotActiveLbl: Label 'Not active for date %1', Comment = '%1 = Valid on Date';
        DateIsNotInsideMembershipsLbl: Label 'Date %1 is not inside memberships last timeframe.', Comment = '%1 = Date';
        MembershipLbl: Label 'Membership role filter: %1', Comment = '%1 = Membership filter';
    begin
        ReasonText := '';

        if (not MembershipManagement.GetMembershipValidDate(Membership."Entry No.", ValidOnDate, FromDate, UntilDate)) then begin
            ReasonText := StrSubstNo(NotActiveLbl, ValidOnDate);
            exit(false);
        end;

        if (TypeOfActive = TypeOfActive::LAST_PERIOD) then begin
            if (MembershipManagement.GetMembershipValidDate(Membership."Entry No.", CalcDate('<+1D>', UntilDate), FromDate, UntilDate)) then begin
                ReasonText := StrSubstNo(DateIsNotInsideMembershipsLbl, ValidOnDate);
                exit(false);
            end;
        end;

        MembershipRole.CopyFilters(ReportMembershipRole);
        MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        if (not MembershipRole.FindSet()) then begin
            ReasonText := StrSubstNo(MembershipLbl, MembershipRole.GetFilters());
            exit(false);
        end;

        repeat
            Member.CopyFilters(ReportMember);
            Member.SetFilter("Entry No.", '=%1', MembershipRole."Member Entry No.");
            if (not Member.IsEmpty()) then
                exit(true);
        until (MembershipRole.Next() = 0);

        ReasonText := StrSubstNo(MembershipLbl, Member.GetFilters());
        exit(false);
    end;

    local procedure AddToJournal(Membership: Record "NPR MM Membership")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::ALTERATION_JNL;
        MemberInfoCapture."Document No." := UserId;
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
        MemberInfoCapture."Membership Code" := Membership."Membership Code";
        MemberInfoCapture."Item No." := RenewUsingItem;
        MemberInfoCapture.Description := RenewDescription;
        MemberInfoCapture."Document Date" := Today();
        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::REGISTERED;
        MemberInfoCapture.Insert();
    end;

    local procedure LogToJournal(Membership: Record "NPR MM Membership"; Reason: Text)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ExcludedLbl: Label 'Excluded [%1].', Comment = '%1 = Reason';
    begin

        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::ALTERATION_JNL;
        MemberInfoCapture."Document No." := UserId;
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
        MemberInfoCapture."Membership Code" := Membership."Membership Code";
        MemberInfoCapture."Document Date" := Today();
        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::FAILED;
        MemberInfoCapture."Response Message" := StrSubstNo(ExcludedLbl, CopyStr(Reason, 1, MaxStrLen(MemberInfoCapture."Response Message") - 20));

        MemberInfoCapture.Insert();
    end;

    procedure LaunchAlterationJnlPage(LaunchPage: Boolean): Boolean
    begin
        LaunchAltJnlPage := LaunchPage;
    end;
}

