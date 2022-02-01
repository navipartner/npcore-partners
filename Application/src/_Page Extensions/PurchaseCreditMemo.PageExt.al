pageextension 6014456 "NPR Purchase Credit Memo" extends "Purchase Credit Memo"
{
    actions
    {
        addfirst("F&unctions")
        {
            action("NPR Import From Scanner File")
            {
                Caption = 'Import From Scanner File';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Start importing the file from the scanner.';
                ApplicationArea = NPRRetail;

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