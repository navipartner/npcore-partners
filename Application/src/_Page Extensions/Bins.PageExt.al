pageextension 6014478 "NPR Bins" extends Bins
{
    actions
    {
        addafter("&Contents")
        {
            action("NPR PrintLabel")
            {
                Caption = 'Print Label';
                Image = BarCode;
                ApplicationArea = All;
                ToolTip = 'Executes the Print Label action';
            }
        }
    }
}