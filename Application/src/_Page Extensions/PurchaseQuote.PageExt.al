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