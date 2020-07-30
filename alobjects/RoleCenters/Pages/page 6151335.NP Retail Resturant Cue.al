page 6151335 "NP Retail Resturant Cue"
{
    Caption = 'Resturant Cue';
    PageType = CardPart;
    SourceTable = "NP Retail Resturant Cue";

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

                    trigger OnDrillDown()
                    begin
                        DrilldownGrossTurnover();
                    end;

                }

                field("Amount per guest"; "Amount per guest")
                {

                    trigger OnDrillDown()
                    begin
                        DrilldownGrossTurnover();

                    end;
                }

                field("Revenue per seat hour"; "Revenue per seat hour")
                {

                    trigger OnDrillDown()
                    begin
                        DrilldownGrossTurnover();
                    end;

                }

                field("Table turnover"; "Table turnover")
                {

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

                    trigger OnDrillDown()
                    begin
                        DrilldownDownOccuipedtable;
                    end;

                }
                field("Total free tables"; "Total free tables")
                {

                    trigger OnDrillDown()
                    begin
                        DrilldownDownFreetable();
                    end;
                }
                field("Inhouse guests"; "Inhouse guests")
                {
                    trigger OnDrillDown()
                    begin
                        DrilldownDownInhouseguests();

                    end;
                }
                field("Available seats"; "Available seats")
                {
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

                }
                field(Transactions; Transactions)
                {
                    trigger OnDrillDown()
                    begin
                        DrilldownTransaction();
                    end;
                }
                field("No-Shows"; "No-Shows")
                {

                }
                field("Canceled reservations"; "Canceled reservations")
                {
                    Caption = 'Cancelled reservations';

                }

            }
        }
    }


    trigger OnOpenPage()
    var
        UpdateCues: Codeunit "NP Retail Update Cues";
    begin
        UpdateCues.Run();
    end;


    [Scope('Personalization')]
    procedure DrilldownGrossTurnover()
    var
        POSEntry: Record "POS Entry";
    begin
        //POSEntry.SetRange("Posting Date", Today);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetFilter("POS Unit No.", '2'); // for demo user only
        //need to add the filter for resturant
        Page.run(Page::"POS Entries", POSEntry);
    end;

    [Scope('Personalization')]
    procedure DrilldownAmountPerGuest()
    var
        POSEntry: Record "POS Entry";
    begin
        //POSEntry.SetRange("Posting Date", Today);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        POSEntry.SetFilter("POS Unit No.", '2'); // for demo user only
        //need to add the filter for resturant
        Page.run(Page::"POS Entries", POSEntry);
    end;



    [Scope('Personalization')]
    procedure DrilldownDownOccuipedtable()
    var
        seating: Record "NPRE Seating";

    begin
        //seating.SetFilter("Multiple Waiter Pad FF", '>%1', 0);
        seating.SetRange(Status, 'INUSE');
        Page.run(page::"NPRE Seating List", seating);
    end;

    [Scope('Personalization')]
    procedure DrilldownDownFreetable()
    var
        seating: Record "NPRE Seating";

    begin
        //seating.SetFilter("Multiple Waiter Pad FF", '<>%1', 0);
        seating.SetRange(Status, 'READY');
        Page.run(page::"NPRE Seating List", seating);
    end;

    [Scope('Personalization')]
    procedure DrilldownDownInhouseguests()
    var
        seating: Record "NPRE Seating";
    begin
        //seating.SetFilter("Multiple Waiter Pad FF", '<>%1', 0);
        seating.SetRange(Status, 'INUSE');
        Page.run(page::"NPRE Seating List", seating);
    end;

    [Scope('Personalization')]
    procedure DrilldownDownAvailableseats()
    var
        seating: Record "NPRE Seating";

    begin
        //seating.SetFilter("Multiple Waiter Pad FF", '<>%1', 0);
        seating.SetRange(Status, 'READY');
        Page.run(page::"NPRE Seating List", seating);
    end;

    [Scope('Personalization')]
    procedure DrilldownTransaction()
    var
        POSEntry: Record "POS Entry";
    begin
        POSEntry.SetRange("Posting Date", Today);
        POSEntry.SetFilter("Entry Type", '=%1', POSEntry."Entry Type"::"Direct Sale");
        //need to add the filter for resturant

        Page.run(Page::"POS Entries", POSEntry);
    end;

}