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
                    LabelManagement: Codeunit "NPR Label Management";
                begin
                    LabelManagement.PrintLabel(Rec, "NPR Report Selection Type"::"Bin Label".AsInteger());
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
                    LabelManagement: Codeunit "NPR Label Management";
                    RecRef: RecordRef;
                begin
                    SetSelectionFilter(Rec);
                    RecRef.GetTable(Rec);
                    if RecRef.FindSet() then
                        repeat
                            LabelManagement.ToggleLine(RecRef);
                        until RecRef.Next() = 0;
                    LabelManagement.PrintSelection("NPR Report Selection Type"::"Bin Label".AsInteger());
                    Rec.MarkedOnly(false);
                end;
            }
        }
    }
}