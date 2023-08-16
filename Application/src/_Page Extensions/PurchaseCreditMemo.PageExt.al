pageextension 6014456 "NPR Purchase Credit Memo" extends "Purchase Credit Memo"
{
    layout
    {
        addlast(General)
        {
            field("NPR Prepayment"; RSPurchaseHeader."Prepayment")
            {
                ApplicationArea = NPRRSLocal;
                Caption = 'Prepayment';
                ToolTip = 'Specifies the value of the Prepayment field.';
                trigger OnValidate()
                begin
                    RSPurchaseHeader.Validate(Prepayment);
                    RSPurchaseHeader.Save();
                end;
            }
        }
    }
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
                    InventorySetup: Record "Inventory Setup";
                    ScannerImportMgt: Codeunit "NPR Scanner Import Mgt.";
                    RecRef: RecordRef;
                begin
                    if not InventorySetup.Get() then
                        exit;

                    RecRef.GetTable(Rec);
                    ScannerImportMgt.ImportFromScanner(InventorySetup."NPR Scanner Provider", Enum::"NPR Scanner Import"::PURCHASE, RecRef);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RSPurchaseHeader.Read(Rec.SystemId);
    end;

    var
        RSPurchaseHeader: Record "NPR RS Purchase Header";
}