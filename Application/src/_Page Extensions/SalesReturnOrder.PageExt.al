pageextension 6014443 "NPR Sales Return Order" extends "Sales Return Order"
{
    layout
    {
        addafter(Status)
        {
            field("NPR Group Code"; Rec."NPR Group Code")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
            field("NPR PR POS Trans. Scheduled For Post"; Rec."NPR POS Trans. Sch. For Post")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies if there are POS entries scheduled for posting';
                Visible = AsyncEnabled;
                trigger OnDrillDown()
                var
                    POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
                begin
                    POSAsyncPostingMgt.ScheduledTransFromPOSOnDrillDown(Rec);
                end;
            }
            field("NPR Sales Channel"; Rec."NPR Sales Channel")
            {
                ToolTip = 'Specifies the value of the Sales Channel field';
                Visible = false;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            field("NPR Posting No."; Rec."Posting No.")
            {
                ApplicationArea = NPRRetail;
                Importance = Additional;
                Visible = false;
                ToolTip = 'Specifies the value of the Posting No. field.';
            }
        }

        addlast("Invoice Details")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the sum of Payment Lines attached to the Sales Return Order';
            }
        }
    }

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
        addlast(navigation)
        {
            group("NPR PayByLink")
            {
                Caption = 'Pay by Link';
                Image = Payment;
                action("NPR Payment Lines")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Payment Lines';
                    Image = PaymentHistory;
                    ToolTip = 'View Pay by Link Payment Lines';

                    trigger OnAction()
                    begin
                        Rec.OpenMagentPaymentLines();
                    end;
                }
            }
        }
    }
    var
        AsyncEnabled: Boolean;

    trigger OnOpenPage()
    var
        POSAsyncPostingMgt: Codeunit "NPR POS Async. Posting Mgt.";
    begin
        AsyncEnabled := POSAsyncPostingMgt.SetVisibility();
    end;
}