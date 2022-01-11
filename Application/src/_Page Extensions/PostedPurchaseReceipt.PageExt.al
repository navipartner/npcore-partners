pageextension 6014409 "NPR Posted Purchase Receipt" extends "Posted Purchase Receipt"
{
    actions
    {
        addafter("&Navigate")
        {
            action("NPR RetailPrint")
            {
                Caption = 'Retail Print';
                Ellipsis = true;
                Image = BinContent;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the Retail Print action';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    LabelLibrary: Codeunit "NPR Label Library";
                begin
                    LabelLibrary.ChooseLabel(Rec);
                end;
            }
        }
    }
}