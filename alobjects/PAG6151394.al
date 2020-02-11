page 6151394 "CS Counting Schedule"
{
    // NPR5.53/JAKUBV/20200121  CASE 377467 Transport NPR5.53 - 21 January 2020

    Caption = 'CS Counting Schedule';
    PageType = List;
    SourceTable = "CS Counting schedule";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store";"POS Store")
                {
                }
                field(Name;Name)
                {
                }
                field("Job Queue Created";"Job Queue Created")
                {
                }
                field(Status;Status)
                {
                }
                field("Last Executed";"Last Executed")
                {
                }
                field("Earliest Start Date/Time";"Earliest Start Date/Time")
                {
                }
                field("Expiration Date/Time";"Expiration Date/Time")
                {
                }
                field("Recurring Job";"Recurring Job")
                {
                }
                field("Run on Mondays";"Run on Mondays")
                {
                }
                field("Run on Tuesdays";"Run on Tuesdays")
                {
                }
                field("Run on Wednesdays";"Run on Wednesdays")
                {
                }
                field("Run on Thursdays";"Run on Thursdays")
                {
                }
                field("Run on Fridays";"Run on Fridays")
                {
                }
                field("Run on Saturdays";"Run on Saturdays")
                {
                }
                field("Run on Sundays";"Run on Sundays")
                {
                }
                field("No. of Minutes between Runs";"No. of Minutes between Runs")
                {
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

                trigger OnAction()
                var
                    CSCountingscheduleCreate: Codeunit "CS Counting schedule - Create";
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

                trigger OnAction()
                var
                    POSStore: Record "POS Store";
                    CSStockTakesList: Page "CS Stock-Takes List";
                    CSStockTakes: Record "CS Stock-Takes";
                begin
                    POSStore.Get("POS Store");
                    CSStockTakes.SetFilter(Location,POSStore."Location Code");
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
                RunPageLink = ID=FIELD("Job Queue Entry ID");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        "Job Queue Created" := not IsNullGuid("Job Queue Entry ID");
    end;
}

