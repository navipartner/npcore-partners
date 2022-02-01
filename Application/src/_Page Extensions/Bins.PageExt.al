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

                ToolTip = 'Allow customers to print BIN labels.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ReportSelectionRetail: Record "NPR Report Selection Retail";
                    LabelLibrary: Codeunit "NPR Label Library";
                begin
                    LabelLibrary.PrintLabel(Rec, ReportSelectionRetail."Report Type"::"Bin Label");
                end;
            }
        }
    }
}