pageextension 6014419 "NPR Posted P.Credit Memos" extends "Posted Purchase Credit Memos"
{
    // NPR5.55/CLVA/20200610 CASE Added Action "Show Imported File"
    actions
    {
        addafter("&Navigate")
        {
            action("NPR Show Imported File")
            {
                Caption = 'Show Imported File';
                Image = DocInBrowser;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Show Imported File action';

                trigger OnAction()
                var
                    NcImportListPg: Page "NPR Nc Import List";
                begin
                    //-366790 [366790]
                    NcImportListPg.ShowFormattedDocByDocNo("Vendor Cr. Memo No.");
                    //+366790 [366790]
                end;
            }
        }
    }
}

