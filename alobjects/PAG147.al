pageextension 6014419 pageextension6014419 extends "Posted Purchase Credit Memos" 
{
    // NPR5.55/CLVA/20200610 CASE Added Action "Show Imported File"
    actions
    {
        addafter("&Navigate")
        {
            action("Show Imported File")
            {
                Caption = 'Show Imported File';
                Image = DocInBrowser;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    NcImportListPg: Page "Nc Import List";
                begin
                    //-366790 [366790]
                    NcImportListPg.ShowFormattedDocByDocNo("Vendor Cr. Memo No.");
                    //+366790 [366790]
                end;
            }
        }
    }
}

