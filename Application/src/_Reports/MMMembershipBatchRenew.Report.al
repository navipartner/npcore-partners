report 6060137 "NPR MM Membership Batch Renew"
{
    // MM1.43/TSA /20200327 CASE 398329 Initial Version

    Caption = 'Membership Batch Renew';
    ProcessingOnly = true;

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
                        CurrReport.Break;
                    end;
                }

                trigger OnPreDataItem()
                begin
                    CurrReport.Break;
                end;
            }

            trigger OnPreDataItem()
            var
                MemberInfoCapture: Record "NPR MM Member Info Capture";
                MembershipAlterationJnlPage: Page "NPR MM Members. Alteration Jnl";
                LogMessage: Text;
                ExistingCount: Integer;
                ProgressMax: Integer;
                ProgressIndex: Integer;
                Window: Dialog;
            begin

                if (MembershipCode = '') then
                    exit;

                if (RenewUsingItem = '') then
                    exit;

                if (ValidOnDate = 0D) then
                    exit;

                if (GuiAllowed) then
                    Window.Open(PROGRESS);

                ReportMembership.SetFilter("Membership Code", '=%1', MembershipCode);
                if (ReportMembership.FindSet()) then begin
                    ProgressMax := ReportMembership.Count();

                    MemberInfoCapture.SetFilter("Source Type", '=%1', MemberInfoCapture."Source Type"::ALTERATION_JNL);
                    MemberInfoCapture.SetFilter("Document No.", '=%1', UserId);
                    ExistingCount := MemberInfoCapture.Count();
                    if (ExistingCount > 0) then
                        if (not Confirm('There are already %1 entries in the alteration journal, do you want to keep them?', true, ExistingCount)) then
                            MemberInfoCapture.DeleteAll();

                    repeat
                        if (DoRenew(ReportMembership, RenewUsingItem, LogMessage)) then begin
                            AddToJournal(ReportMembership);
                        end else
                            if (Verbose) then begin
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
                field(MembershipCode; MembershipCode)
                {
                    Caption = 'Membership Code';
                    ShowMandatory = true;
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MembershipSetup: Record "NPR MM Membership Setup";
                        PageAction: Action;
                        MembershipSetupPage: Page "NPR MM Membership Setup";
                    begin

                        MembershipSetup.Reset();

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
                field(ValidOnDate; ValidOnDate)
                {
                    Caption = 'Active On Date';
                    ShowMandatory = true;
                    ApplicationArea = All;
                }
                field(TypeOfActive; TypeOfActive)
                {
                    Caption = 'Active Type';
                    OptionCaption = 'Active,Last Period';
                    ApplicationArea = All;
                }
                field(RenewUsingItem; RenewUsingItem)
                {
                    Caption = 'Renew Using Item';
                    ShowMandatory = true;
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
                        MembershipAlterationPage: Page "NPR MM Membership Alter.";
                        PageAction: Action;
                    begin

                        MembershipAlterationSetup.Reset();
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
                field(Verbose; Verbose)
                {
                    Caption = 'Verbose';
                    ApplicationArea = All;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        LaunchAltJnlPage := true;
    end;

    var
        MembershipCode: Code[20];
        ValidOnDate: Date;
        RenewUsingItem: Code[20];
        RenewDescription: Text;
        TypeOfActive: Option ACTIVE,LAST_PERIOD;
        Verbose: Boolean;
        PROGRESS: Label 'Working: @1@@@@@@@@@@@@@@@@@@';
        LaunchAltJnlPage: Boolean;

    local procedure DoRenew(Membership: Record "NPR MM Membership"; RenewUsingItem: Code[20]; var ReasonText: Text): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        FromDate: Date;
        UntilDate: Date;
    begin

        ReasonText := '';

        if (not MembershipManagement.GetMembershipValidDate(Membership."Entry No.", ValidOnDate, FromDate, UntilDate)) then begin
            ReasonText := StrSubstNo('Not active for date %1', ValidOnDate);
            exit(false);
        end;

        if (TypeOfActive = TypeOfActive::LAST_PERIOD) then begin
            if (MembershipManagement.GetMembershipValidDate(Membership."Entry No.", CalcDate('<+1D>', UntilDate), FromDate, UntilDate)) then begin
                ReasonText := StrSubstNo('Date %1 is not inside memberships last timeframe.', ValidOnDate);
                exit(false);
            end;
        end;

        MembershipRole.CopyFilters(ReportMembershipRole);
        MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        if (not MembershipRole.FindSet()) then begin
            ReasonText := StrSubstNo('Membership role filter: %1', MembershipRole.GetFilters());
            exit(false);
        end;

        repeat
            Member.CopyFilters(ReportMember);
            Member.SetFilter("Entry No.", '=%1', MembershipRole."Member Entry No.");
            if (not Member.IsEmpty()) then
                exit(true);
        until (MembershipRole.Next() = 0);

        ReasonText := StrSubstNo('Member role filter: %1', Member.GetFilters());
        exit(false);
    end;

    local procedure AddToJournal(Membership: Record "NPR MM Membership")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        FromDate: Date;
        UntilDate: Date;
    begin

        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::ALTERATION_JNL;
        MemberInfoCapture."Document No." := UserId;

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
        MemberInfoCapture."Membership Code" := Membership."Membership Code";

        MemberInfoCapture."Item No." := RenewUsingItem;
        MemberInfoCapture.Description := RenewDescription;
        MemberInfoCapture."Document Date" := Today;

        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::REGISTERED;
        MemberInfoCapture.Insert();
    end;

    local procedure LogToJournal(Membership: Record "NPR MM Membership"; Reason: Text)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::ALTERATION_JNL;
        MemberInfoCapture."Document No." := UserId;

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
        MemberInfoCapture."Membership Code" := Membership."Membership Code";

        MemberInfoCapture."Document Date" := Today;

        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::FAILED;
        MemberInfoCapture."Response Message" := StrSubstNo('Excluded [%1].', CopyStr(Reason, 1, MaxStrLen(MemberInfoCapture."Response Message") - 20));

        MemberInfoCapture.Insert();
    end;

    local procedure ProcessJournal()
    begin
    end;

    procedure LaunchAlterationJnlPage(LaunchPage: Boolean): Boolean
    begin
        LaunchAltJnlPage := LaunchPage;
    end;
}

