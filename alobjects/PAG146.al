pageextension 6014418 pageextension6014418 extends "Posted Purchase Invoices" 
{
    // NPR5.55/CLVA/20200610 CASE Added Action "Show Imported File"
    actions
    {
        addafter(Correct)
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
                    NcImportListPg.ShowFormattedDocByDocNo("Vendor Invoice No.");
                    //+366790 [366790]
                end;
            }
        }
    }
}

