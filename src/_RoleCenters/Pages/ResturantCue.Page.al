page 6151335 "NPR Resturant Cue"
{
    Caption = 'Resturant Cue';
    PageType = CardPart;
    SourceTable = "NPR Resturant Cue";

    layout
    {

        area(content)
        {
            cuegroup(Control6150623)
            {

                Caption = 'Resturant';
                ShowCaption = true;

                field("Gross turnover"; "Gross turnover")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrilldownGrossTurnover();
                    end;

                }

                field("Amount per guest"; "Amount per guest")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrilldownGrossTurnover();

                    end;
                }

                field("Revenue per seat hour"; "Revenue per seat hour")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrilldownGrossTurnover();
                    end;

                }

                field("Table turnover"; "Table turnover")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrilldownGrossTurnover();
                    end;

                }
            }

            cuegroup(Status)
            {
                Caption = 'Status';
                field("Occupied Tables"; "Occupied table")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrilldownDownOccuipedtable;
                    end;

                }
                field("Total free tables"; "Total free tables")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrilldownDownFreetable();
                    end;
                }
                field("Inhouse guests"; "Inhouse guests")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        DrilldownDownInhouseguests();

                    end;
                }
                field("Available seats"; "Available seats")
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        DrilldownDownAvailableseats();
                    end;

                }
            }
            cuegroup(DaySummary)
            {
                Caption = 'Day Summary';
                field("Total guests"; "Total guests")
                {
                    ApplicationArea = All;

                }
                field(Transactions; Transactions)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        DrilldownTransaction();
                    end;
                }
                field("No-Shows"; "No-Shows")
                {
                    ApplicationArea = All;

                }
                field("Canceled reservations"; "Canceled reservations")
                {
                    ApplicationArea = All;
                    Caption = 'Cancelled reservations';

                }

            }
        }
    }


    trigger OnOpenPage()
    var
        UpdateCues: Codeunit "NPR Update Cues";
    begin
        UpdateCues.Run();
    end;


    procedure DrilldownGrossTurnover()
    var
        POSEntry: Record "NPR POS Entry";
    begin
        //POSEntry.SetRange("Posting Date", Today);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetFilter("POS Unit No.", '2'); // for demo user only
        //need to add the filter for resturant
        Page.run(Page::"NPR POS Entries", POSEntry);
    end;

    procedure DrilldownAmountPerGuest()
    var
        POSEntry: Record "NPR POS Entry";
    begin
        //POSEntry.SetRange("Posting Date", Today);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetFilter("POS Unit No.", '2'); // for demo user only
        //need to add the filter for resturant
        Page.run(Page::"NPR POS Entries", POSEntry);
    end;



    procedure DrilldownDownOccuipedtable()
    var
        seating: Record "NPR NPRE Seating";

    begin
        //seating.SetFilter("Multiple Waiter Pad FF", '>%1', 0);
        seating.SetRange(Status, 'INUSE');
        Page.run(page::"NPR NPRE Seating List", seating);
    end;

    procedure DrilldownDownFreetable()
    var
        seating: Record "NPR NPRE Seating";

    begin
        //seating.SetFilter("Multiple Waiter Pad FF", '<>%1', 0);
        seating.SetRange(Status, 'READY');
        Page.run(page::"NPR NPRE Seating List", seating);
    end;

    procedure DrilldownDownInhouseguests()
    var
        seating: Record "NPR NPRE Seating";
    begin
        //seating.SetFilter("Multiple Waiter Pad FF", '<>%1', 0);
        seating.SetRange(Status, 'INUSE');
        Page.run(page::"NPR NPRE Seating List", seating);
    end;

    procedure DrilldownDownAvailableseats()
    var
        seating: Record "NPR NPRE Seating";

    begin
        //seating.SetFilter("Multiple Waiter Pad FF", '<>%1', 0);
        seating.SetRange(Status, 'READY');
        Page.run(page::"NPR NPRE Seating List", seating);
    end;

    procedure DrilldownTransaction()
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Posting Date", Today);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        //need to add the filter for resturant

        Page.run(Page::"NPR POS Entries", POSEntry);
    end;

}