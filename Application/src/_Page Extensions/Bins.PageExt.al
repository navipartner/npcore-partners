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
                    LabelLibrary: Codeunit "NPR Label Library";
                begin
                    LabelLibrary.PrintLabel(Rec, "NPR Report Selection Type"::"Bin Label".AsInteger());
                end;
            }
        }
    }
}