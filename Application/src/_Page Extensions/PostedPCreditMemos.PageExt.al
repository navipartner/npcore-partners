pageextension 6014419 "NPR Posted P.Credit Memos" extends "Posted Purchase Credit Memos"
{
    actions
    {
        addafter("&Navigate")
        {
            action("NPR Show Imported File")
            {
                Caption = 'Show Imported File';
                Image = DocInBrowser;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Imported File action';

                trigger OnAction()
                var
                    NcImportListPg: Page "NPR Nc Import List";
                begin
                    NcImportListPg.ShowFormattedDocByDocNo(Rec."Vendor Cr. Memo No.");
                end;
            }
        }
    }
}