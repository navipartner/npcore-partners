pageextension 6014450 "NPR Purchase Quote" extends "Purchase Quote"
{
    actions
    {
        addafter("Archive Document")
        {
            action("NPR ImportFromScanner")
            {
                Caption = 'Import from scanner';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Import from scanner action';

                trigger OnAction()
                var
                    ImportfromScannerFilePO: XMLport "NPR Import from ScannerFilePO";
                begin
                    ImportfromScannerFilePO.SelectTable(Rec);
                    ImportfromScannerFilePO.SetTableView(Rec);
                    ImportfromScannerFilePO.Run();
                end;
            }
        }
    }
}