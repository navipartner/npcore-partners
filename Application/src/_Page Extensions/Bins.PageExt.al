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

            action("NPR PrintLabel Selection")
            {
                Caption = 'Print Labels (Selection)';
                Image = BarCode;
                ToolTip = 'Allow customers to print selected BIN labels.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LabelLibrary: Codeunit "NPR Label Library";
                    RecRef: RecordRef;
                begin
                    SetSelectionFilter(Rec);
                    RecRef.GetTable(Rec);
                    if RecRef.FindSet() then
                        repeat
                            LabelLibrary.ToggleLine(RecRef);
                        until RecRef.Next() = 0;
                    LabelLibrary.PrintSelection("NPR Report Selection Type"::"Bin Label".AsInteger());
                    Rec.MarkedOnly(false);
                end;
            }
        }
    }
}