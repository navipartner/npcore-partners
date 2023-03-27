pageextension 6014443 "NPR Sales Return Order" extends "Sales Return Order"
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
                    InventorySetup: Record "Inventory Setup";
                    ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
                    RecRef: RecordRef;
                begin
                    if not InventorySetup.Get() then
                        exit;

                    RecRef.GetTable(Rec);
                    ScannerImportMgt.ImportFromScanner(InventorySetup."NPR Scanner Provider", Enum::"NPR Scanner Import"::SALES, RecRef);
                end;
            }
        }
    }
}