page 6151333 "NPR O365 Activities Ext"
{
    Caption = 'Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Activities Cue";

    layout
    {
        area(content)
        {
            cuegroup(Control54)
            {
                CueGroupLayout = Wide;
                ShowCaption = false;
                field("Sales This Month"; "NPR Sales This Month ILE")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of sales in the current month.';

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesThisMonth;
                    end;
                }


            }

            cuegroup(SalesThisMonthLastYear)
            {
                CuegroupLayout = wide;
                ShowCaption = false;
                field("Sales This Month Last Year"; "NPR Sales CM Last Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of sales in the current month of last year.';

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesThisMonthLastYear;
                    end;
                }

            }

        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshData)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Refresh Data';
                Image = Refresh;
                ToolTip = 'Refreshes the data needed to make complex calculations.';

                trigger OnAction()
                begin
                    "Last Date/Time Modified" := 0DT;
                    Modify;

                    CODEUNIT.Run(CODEUNIT::"Activities Mgt.");
                    CurrPage.Update(false);
                end;
            }
            action("Set Up Cues")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CueAndKPIs.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetActivityGroupVisibility;
    end;



    trigger OnOpenPage()
    var
        CRMConnectionSetup: Record "CRM Connection Setup";
        IntegrationSynchJobErrors: Record "Integration Synch. Job Errors";
        OCRServiceMgt: Codeunit "OCR Service Mgt.";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        NewRecord: Boolean;
        ActivitiesMgt: Codeunit "NPR Activities Mgt.";
        HeadlineMan: Codeunit "NPR NP Retail Headline Mgt.";
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
            Commit;
            NewRecord := true;
        end;

        SETFILTER("User ID Filter", USERID);

        // PrepareOnLoadDialog;

        /*
         IF PageNotifier.IsAvailable THEN BEGIN
             PageNotifier := PageNotifier.Create;
             PageNotifier.NotifyPageReady;
         END;
         */


        ShowAwaitingIncomingDoc := OCRServiceMgt.OcrServiceIsEnable;
        ShowIntercompanyActivities := false;
        ShowDocumentsPendingDocExchService := false;
        ShowProductVideosActivities := ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Phone;
        ShowIntelligentCloud := not EnvironmentInformation.IsSaaS();
        IntegrationSynchJobErrors.SetDataIntegrationUIElementsVisible(ShowDataIntegrationCues);
        ShowD365SIntegrationCues := CRMConnectionSetup.IsEnabled;
        ShowIntegrationErrorsCue := ShowDataIntegrationCues and (not ShowD365SIntegrationCues);
        RoleCenterNotificationMgt.ShowNotifications;
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent;

        CODEUNIT.Run(CODEUNIT::"NPR Activities Mgt.");

    end;

    trigger OnInit()
    begin
        CODEUNIT.Run(CODEUNIT::"NPR Activities Mgt.");

    end;


    var
        ActivitiesMgt: Codeunit "NPR Activities Mgt.";
        CueAndKPIs: Codeunit "Cues And KPIs";
        O365GettingStartedMgt: Codeunit "O365 Getting Started Mgt.";
        ClientTypeManagement: Codeunit "Client Type Management";
        EnvironmentInformation: Codeunit "Environment Information";
        UserTaskManagement: Codeunit "User Task Management";



        HasCamera: Boolean;
        ShowDocumentsPendingDocExchService: Boolean;
        ShowAwaitingIncomingDoc: Boolean;
        ShowIntercompanyActivities: Boolean;
        ShowProductVideosActivities: Boolean;
        ShowIntelligentCloud: Boolean;
        TileGettingStartedVisible: Boolean;
        ReplayGettingStartedVisible: Boolean;
        HideNpsDialog: Boolean;
        WhatIsNewTourVisible: Boolean;
        ShowD365SIntegrationCues: Boolean;
        ShowDataIntegrationCues: Boolean;
        ShowIntegrationErrorsCue: Boolean;


    local procedure SetActivityGroupVisibility()
    var
        DocExchServiceSetup: Record "Doc. Exch. Service Setup";
        CompanyInformation: Record "Company Information";
    begin
        if DocExchServiceSetup.Get then
            ShowDocumentsPendingDocExchService := DocExchServiceSetup.Enabled;

        if CompanyInformation.Get then
            ShowIntercompanyActivities :=
              (CompanyInformation."IC Partner Code" <> '') and (("IC Inbox Transactions" <> 0) or ("IC Outbox Transactions" <> 0));
    end;

    local procedure StartWhatIsNewTour(hasTourCompleted: Boolean)
    var
        O365UserTours: Record "User Tours";
        TourID: Integer;
    begin
        TourID := O365GettingStartedMgt.GetWhatIsNewTourID;

        if O365UserTours.AlreadyCompleted(TourID) then
            exit;


        if WhatIsNewTourVisible then begin
            O365UserTours.MarkAsCompleted(TourID);
            WhatIsNewTourVisible := false;
        end;
    end;


    procedure DrillDownSalesThisMonthLastYear()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange(ItemLedgerEntry."Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetFilter("Posting Date", '%1..%2', CALCDATE('<-CM-1Y>', TODAY), CALCDATE('<CM-1Y>', TODAY));
        PAGE.Run(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;


    procedure DrillDownSalesThisMonth()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange(ItemLedgerEntry."Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', Today), Today);
        PAGE.Run(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;

}

