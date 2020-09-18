page 6151394 "NPR CS Counting Schedule"
{
    // NPR5.53/JAKUBV/20200121  CASE 377467 Transport NPR5.53 - 21 January 2020

    Caption = 'CS Counting Schedule';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR CS Counting schedule";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store"; "POS Store")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Job Queue Created"; "Job Queue Created")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Last Executed"; "Last Executed")
                {
                    ApplicationArea = All;
                }
                field("Earliest Start Date/Time"; "Earliest Start Date/Time")
                {
                    ApplicationArea = All;
                }
                field("Expiration Date/Time"; "Expiration Date/Time")
                {
                    ApplicationArea = All;
                }
                field("Recurring Job"; "Recurring Job")
                {
                    ApplicationArea = All;
                }
                field("Run on Mondays"; "Run on Mondays")
                {
                    ApplicationArea = All;
                }
                field("Run on Tuesdays"; "Run on Tuesdays")
                {
                    ApplicationArea = All;
                }
                field("Run on Wednesdays"; "Run on Wednesdays")
                {
                    ApplicationArea = All;
                }
                field("Run on Thursdays"; "Run on Thursdays")
                {
                    ApplicationArea = All;
                }
                field("Run on Fridays"; "Run on Fridays")
                {
                    ApplicationArea = All;
                }
                field("Run on Saturdays"; "Run on Saturdays")
                {
                    ApplicationArea = All;
                }
                field("Run on Sundays"; "Run on Sundays")
                {
                    ApplicationArea = All;
                }
                field("No. of Minutes between Runs"; "No. of Minutes between Runs")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Schedule Conting")
            {
                Caption = 'Schedule Conting';
                Image = Planning;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CSCountingscheduleCreate: Codeunit "NPR CS Count.Schedule: Create";
                begin
                    CSCountingscheduleCreate.Run(Rec);
                end;
            }
            action("Store Countings")
            {
                Caption = 'Store Countings';
                Image = LedgerEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    POSStore: Record "NPR POS Store";
                    CSStockTakesList: Page "NPR CS Stock-Takes List";
                    CSStockTakes: Record "NPR CS Stock-Takes";
                begin
                    POSStore.Get("POS Store");
                    CSStockTakes.SetFilter(Location, POSStore."Location Code");
                    CSStockTakesList.SetTableView(CSStockTakes);
                    CSStockTakesList.Run;
                end;
            }
            action("Job Queue Entry")
            {
                Caption = 'Job Queue Entry';
                Image = Job;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Job Queue Entry Card";
                RunPageLink = ID = FIELD("Job Queue Entry ID");
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        "Job Queue Created" := not IsNullGuid("Job Queue Entry ID");
    end;
}

