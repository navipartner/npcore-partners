page 6184711 "NPR ES POS Audit Log Aux. Info"
{
    ApplicationArea = NPRESFiscal;
    Caption = 'ES POS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR ES POS Audit Log Aux. Info";
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
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the Audit Entry Type.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the Audit Entry No.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRESFiscal;
                    BlankZero = true;
                    ToolTip = 'Specifies the POS Entry No. related to this record.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                        POSEntryList: Page "NPR POS Entry List";
                    begin
                        if Rec."Audit Entry Type" <> Rec."Audit Entry Type"::"POS Entry" then
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
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the Entry Date.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the POS store code from which the related record was created.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the POS unit number from which the related record was created.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the Source Document No.';
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ApplicationArea = NPRESFiscal;
                    BlankZero = true;
                    ToolTip = 'Specifies the total amount including taxes for the transaction.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the salesperson who created this record.';
                }
                field("ES Organization Code"; Rec."ES Organization Code")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the ES Fiskaly organization for which related record is created.';
                }
                field("ES Signer Code"; Rec."ES Signer Code")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the ES Fiskaly signer for which related record is created.';
                }
                field("ES Signer Id"; Rec."ES Signer Id")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the Id of ES Fiskaly signer for which related record is created.';
                }
                field("ES Client Id"; Rec."ES Client Id")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the Id of ES Fiskaly client for which related record is created.';
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the type of the invoice.';
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the number of the invoice.';
                }
                field("Invoice State"; Rec."Invoice State")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the state of invoice at Fiskaly.';
                }
                field("Issued At"; Rec."Issued At")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the date and time when the invoice is issued at Fiskaly.';
                }
                field("Validation URL"; Rec."Validation URL")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the validation url that is pre-defined url schema which points to the tax authority server in order to valdiate the corresponding invoice.';
                    Visible = false;
                }
                field("Invoice Registration State"; Rec."Invoice Registration State")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the registration state of invoice at Fiskaly.';
                }
                field("Invoice Cancellation State"; Rec."Invoice Cancellation State")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the cancellation state of invoice at Fiskaly.';
                }
                field("Invoice Validation Status"; Rec."Invoice Validation Status")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the validation status of invoice at Fiskaly.';
                }
                field("Invoice Validation Description"; Rec."Invoice Validation Description")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the validation description of invoice at Fiskaly.';
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the identifier of the invoice at Fiskaly.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateInvoice)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Create';
                Enabled = CreateInvoiceEnabled;
                Image = Signature;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the invoice at Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.CreateInvoice(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveInvoice)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Retrieve';
                Enabled = RetrieveInvoiceEnabled;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the invoice from Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.RetrieveInvoice(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(UpdateInvoiceMetadata)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Update Metadata';
                Image = UpdateXML;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Updates the metadata of the invoice at Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    ESFiskalyCommunication.UpdateInvoiceMetadata(Rec);
                end;
            }
            action(CancelInvoice)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Cancel';
                Enabled = Rec."Invoice State" = Rec."Invoice State"::ISSUED;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Cancels the invoice at Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.CancelInvoice(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CreateInvoiceEnabled := (Rec."Invoice No." = '') and (Rec."Invoice State" = Rec."Invoice State"::" ");
        RetrieveInvoiceEnabled := Rec."Invoice No." <> '';
    end;

    var
        CreateInvoiceEnabled: Boolean;
        RetrieveInvoiceEnabled: Boolean;
}
