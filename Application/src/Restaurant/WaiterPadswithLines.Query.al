query 6014465 "NPR Waiter Pads with Lines"
{
    Access = Internal;
    Caption = 'Waiter Pads with Lines';

    elements
    {
        dataitem(WaiterPad; "NPR NPRE Waiter Pad")
        {
            column(WaiterPadNo; "No.") { }
            column(Closed; Closed) { }
            dataitem(WaiterPadLine; "NPR NPRE Waiter Pad Line")
            {
                DataItemLink = "Waiter Pad No." = WaiterPad."No.";
                SqlJoinType = InnerJoin;
                column(Type; "Line Type") { }
                column(No; "No.") { }
            }
        }
    }
}