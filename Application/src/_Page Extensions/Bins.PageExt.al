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
                    ReportSelectionRetail: Enum "NPR Report Selection Type";
                    LabelLibrary: Codeunit "NPR Label Library";
                begin
                    LabelLibrary.PrintLabel(Rec, ReportSelectionRetail::"Bin Label");
                end;
            }
        }
    }
}