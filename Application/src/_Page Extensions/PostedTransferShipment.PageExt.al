pageextension 6014465 "NPR Posted Transfer Shipment" extends "Posted Transfer Shipment"
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

                ToolTip = 'Display the Retail Journal Print page where different labels can be printed.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LabelManagement: Codeunit "NPR Label Management";
                begin
                    LabelManagement.ChooseLabel(Rec);
                end;
            }
        }
    }

}