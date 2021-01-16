page 6151340 "NPR SO Processor Act"
{
    Caption = 'Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "Sales Cue";

    layout
    {
        area(content)
        {
            cuegroup("For Release")
            {
                Caption = 'For Release';
                CueGroupLayout = Wide;
                field("NPRC Sales This Month"; "NPR Sales This Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of sales in the current month.';
                    Caption = 'Sales This Month';

                    trigger OnDrillDown()
                    begin
                        DrillDownSalesThisMonth;
                    end;
                }
                field("NPRC Sales This Month Lst Year"; "NPR Sales This Month Lst Year")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sum of sales in the current month of last year.';
                    Caption = 'Sales This Month Last Year';

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

    trigger OnAfterGetCurrRecord()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        RoleCenterNotificationMgt.HideEvaluationNotificationAfterStartingTrial;
    end;



    trigger OnOpenPage()
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;

        SetRespCenterFilter;
        SetRange("Date Filter", 0D, WorkDate - 1);
        SetFilter("Date Filter2", '>=%1', WorkDate);
        SetFilter("User ID Filter", UserId);
        SetFilter("NPR Date Filter Lst Year", '%1..%2', CalcDate('<-CM-1Y>', Today), CalcDate('<CM-1Y>', Today));
        SetFilter("NPR Date Filter", '%1..%2', CalcDate('<-CM>', Today), Today);
        RoleCenterNotificationMgt.ShowNotifications;
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent;

    end;

    var
        CueAndKPIs: Codeunit "Cues And KPIs";
        UserTaskManagement: Codeunit "User Task Management";
        ShowDocumentsPendingDodExchService: Boolean;




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

