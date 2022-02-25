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
                    ScannerImport: XmlPort "NPR Scanner Import";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    ScannerImport.ScannerImportFactory(Enum::"NPR Scanner Import"::PURCHASE, RecRef);
                    ScannerImport.Run();
                end;
            }
        }
    }
}