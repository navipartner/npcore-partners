page 6184638 "NPR AT POS Audit Log Aux. Info"
{
    ApplicationArea = NPRATFiscal;
    Caption = 'AT POS Audit Log Aux. Info';
    ContextSensitiveHelpPage = 'docs/fiscalization/austria/how-to/setup/';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR AT POS Audit Log Aux. Info";
    SourceTableView = sorting("Audit Entry No.") order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Audit Entry Type"; Rec."Audit Entry Type")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the Audit Entry Type.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the Audit Entry No.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRATFiscal;
                    BlankZero = true;
                    ToolTip = 'Specifies the POS Entry No. related to this record.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                        POSEntryList: Page "NPR POS Entry List";
                    begin
                        if not (Rec."Audit Entry Type" in [Rec."Audit Entry Type"::"POS Entry"]) then
                            exit;

                        POSEntry.FilterGroup(2);
                        POSEntry.SetRange("Entry No.", Rec."POS Entry No.");
                        POSEntry.FilterGroup(0);
                        POSEntryList.SetTableView(POSEntry);
                        POSEntryList.Run();
                    end;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the Entry Date.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the POS store code from which the related record was created.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the POS unit number from which the related record was created.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the Source Document No.';
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ApplicationArea = NPRATFiscal;
                    BlankZero = true;
                    ToolTip = 'Specifies the total amount including taxes for the transaction.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the salesperson who created this record.';
                }
                field("AT Organization Code"; Rec."AT Organization Code")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the AT Fiskaly organization for which related record is created.';
                }
                field("AT SCU Code"; Rec."AT SCU Code")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the AT Fiskaly signature creation unit for which related record is created.';
                }
                field("AT SCU Id"; Rec."AT SCU Id")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the Id of AT Fiskaly signature creation unit for which related record is created.';
                }
                field("AT Cash Register Id"; Rec."AT Cash Register Id")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the Id of AT Fiskaly cash register for which related record is created.';
                }
                field("AT Cash Register Serial Number"; Rec."AT Cash Register Serial Number")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the serial number of AT Fiskaly cash register for which related record is created.';
                }
                field("Receipt Type"; Rec."Receipt Type")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the type of the receipt.';
                }
                field("Receipt Number"; Rec."Receipt Number")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the number of the receipt.';
                }
                field(Signed; Rec."Signed")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies whether the receipt is signed at Fiskaly.';
                }
                field("Signed At"; Rec."Signed At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when the receipt is signed at Fiskaly.';
                }
                field(Hints; Rec.Hints)
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the hints about the receipt signing status and/or type.';
                }
                field("FON Receipt Validation Status"; Rec."FON Receipt Validation Status")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the validation status of the receipt at FinanzOnline.';
                }
                field("Validated At"; Rec."Validated At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when the receipt is validated at FinanzOnline.';
                }
                field("Receipt Printed"; Rec."Receipt Printed")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies whether the receipt is already printed or not.';
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the identifier of the receipt at Fiskaly.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SignReceipt)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Sign';
                Enabled = SignReceiptEnabled;
                Image = Signature;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Signs the receipt at Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.SignReceipt(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveReceipt)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Retrieve';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the receipt from Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.RetrieveReceipt(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(UpdateReceiptMetadata)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Update Metadata';
                Image = UpdateXML;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Updates the metadata of the receipt at Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    ATFiskalyCommunication.UpdateReceiptMetadata(Rec);
                end;
            }
            action(PrintReceipt)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Print Receipt';
                Image = PrintVoucher;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Prints the receipt.';

                trigger OnAction()
                var
                    ATFiscalThermalPrint: Codeunit "NPR AT Fiscal Thermal Print";
                begin
                    ATFiscalThermalPrint.PrintReceipt(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SignReceiptEnabled := not Rec.Signed;
    end;

    var
        SignReceiptEnabled: Boolean;
}
