query 6150661 "NPR NPRE Seating - W/Pad Link"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'NPRE Seating - W/Pad Link';

    elements
    {
        dataitem(Seating; "NPR NPRE Seating")
        {
            column(SeatingLocation; "Seating Location")
            {
            }

            dataitem(SeatingWPLink; "NPR NPRE Seat.: WaiterPadLink")
            {
                DataItemLink = "Seating Code" = Seating.Code;
                SqlJoinType = InnerJoin;

                column(SeatingClosed; Closed)
                {
                }

                dataitem(WaiterPad; "NPR NPRE Waiter Pad")
                {
                    DataItemLink = "No." = SeatingWPLink."Waiter Pad No.";
                    SqlJoinType = InnerJoin;

                    column(WaiterPadClosed; Closed)
                    {
                    }

                    column(NumberOfGuests; "Number of Guests")
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }
}
