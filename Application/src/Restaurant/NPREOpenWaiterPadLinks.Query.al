query 6014441 "NPR NPRE Open W/Pad Links"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'NPRE Open Waiter Pad Links';

    // Every open seating/waiter pad link the POS restaurant view needs, with the pad fields it paints from, in one read.
    //
    // The join through Seating Location is what lets the view ask for one restaurant's links rather than the whole
    // company's, which is the narrowing the restaurant view wants in a multi-restaurant setup. Reading the pad columns
    // here is what removes the lookup per open pad that a link-only read would still owe.

    elements
    {
        dataitem(SeatingLocation; "NPR NPRE Seating Location")
        {
            filter(RestaurantCode; "Restaurant Code")
            {
            }

            dataitem(Seating; "NPR NPRE Seating")
            {
                DataItemLink = "Seating Location" = SeatingLocation.Code;
                SqlJoinType = InnerJoin;

                dataitem(SeatingWaiterPadLink; "NPR NPRE Seat.: WaiterPadLink")
                {
                    DataItemLink = "Seating Code" = Seating.Code;
                    DataItemTableFilter = Closed = const(false);
                    SqlJoinType = InnerJoin;

                    column(SeatingCode; "Seating Code")
                    {
                    }
                    column(WaiterPadNo; "Waiter Pad No.")
                    {
                    }

                    // Inner join on purpose: a link whose pad no longer exists contributes nothing either way, because
                    // every caller starts by looking the pad up and skips when it is not there.
                    dataitem(WaiterPad; "NPR NPRE Waiter Pad")
                    {
                        DataItemLink = "No." = SeatingWaiterPadLink."Waiter Pad No.";
                        SqlJoinType = InnerJoin;

                        column(PadStatus; Status)
                        {
                        }
                        column(PadServingStepCode; "Serving Step Code")
                        {
                        }
                        column(PadClosed; Closed)
                        {
                        }
                    }
                }
            }
        }
    }
}
