pageextension 6014471 pageextension6014471 extends Bins 
{
    // NPR5.29/MMV /20161216 CASE 253966 Added label action through print buffer.
    // NPR5.30/TJ  /20170202 CASE 262533 Removed action Invert selection and code from action PrintLabel
    //                                   Also removed code and variables related to label printing and moved to a subscriber
    actions
    {
        addafter("&Contents")
        {
            action(PrintLabel)
            {
                Caption = 'Print Label';
                Image = BarCode;
            }
        }
    }
}

