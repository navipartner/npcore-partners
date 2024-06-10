page 6184596 "NPR AT Cash Registers"
{
    ApplicationArea = NPRATFiscal;
    Caption = 'AT Cash Registers';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR AT Cash Register";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the POS unit number to identify this AT cash register.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the text that describes this AT cash register.';
                }
                field("AT SCU Code"; Rec."AT SCU Code")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the AT Fiskaly signature creation unit to which this AT Fiskaly cash register is assigned.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the state of this AT Fiskaly cash register.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the unique serial number of this AT Fiskaly cash register. Corresponds to the "Kassenidentifikationsnummer" in the context of RKSV.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when it is created at Fiskaly.';
                }
                field("Registered At"; Rec."Registered At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when it is registered at Fiskaly.';
                }
                field("Initialized At"; Rec."Initialized At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when it is initialized at Fiskaly.';
                }
                field("Initialization Receipt Id"; Rec."Initialization Receipt Id")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the identifier of initialization receipt at Fiskaly.';
                }
                field("Decommissioned At"; Rec."Decommissioned At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when it is decommissioned at Fiskaly.';
                }
                field("Decommission Receipt Id"; Rec."Decommission Receipt Id")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the identifier of decommission receipt at Fiskaly.';
                }
                field("Outage At"; Rec."Outage At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when it is reported as outage at Fiskaly.';
                }
                field("Defect At"; Rec."Defect At")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the date and time when it is marked as defective at Fiskaly.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateCashRegister)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Create';
                Image = ElectronicRegister;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the cash register at Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.CreateCashRegister(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveCashRegister)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Retrieve';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the cash register from Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.RetrieveCashRegister(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RegisterCashRegister)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Register';
                Image = Registered;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Registers the cash register at Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.UpdateCashRegister(Rec, Enum::"NPR AT Cash Register State"::REGISTERED);
                    CurrPage.Update(false);
                end;
            }
            action(InitializeCashRegister)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Initialize';
                Image = Continue;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Initializes the cash register at Fiskaly in order to be able to use it for fiscalizing the receipts.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.UpdateCashRegister(Rec, Enum::"NPR AT Cash Register State"::INITIALIZED);
                    CurrPage.Update(false);
                end;
            }
            action(OutageCashRegister)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Report Outage';
                Image = Warning;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Reports the outage of cash register at Fiskaly when it is temporarily not usable. It has to be done at most 48 hours after the defect was detected.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.UpdateCashRegister(Rec, Enum::"NPR AT Cash Register State"::OUTAGE);
                    CurrPage.Update(false);
                end;
            }
            action(DecommissionCashRegister)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Decommission';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Decommissiones the cash register at Fiskaly once it has eventually reached its end-of-life.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.UpdateCashRegister(Rec, Enum::"NPR AT Cash Register State"::DECOMMISSIONED);
                    CurrPage.Update(false);
                end;
            }
            action(DefectiveCashRegister)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Mark as Defective';
                Image = Error;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Marks the cash register as defective at Fiskaly due to non-repairable defect.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.UpdateCashRegister(Rec, Enum::"NPR AT Cash Register State"::DEFECTIVE);
                    CurrPage.Update(false);
                end;
            }
            action(ListCashRegisters)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Refresh Cash Registers';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copies information about the available cash registers from Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    ATFiskalyCommunication.ListCashRegisters();
                    CurrPage.Update(false);
                end;
            }
            action(ListOtherControlReceipts)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Import Other Control Receipts';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Imports information about the other control receipts related to this cash register from Fiskaly into POS audit log.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    ATFiskalyCommunication.ListCashRegisterReceipts(Rec, Enum::"NPR AT Audit Entry Type"::"Control Transaction", ATFiskalyCommunication.GetListOtherCashRegisterControlReceiptsQueryParameters());
                end;
            }
            action(ExportCashRegister)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Export Cash Register';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Exports the electronic journal (DEP7) for cash register from Fiskaly into the file.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    ATFiskalyCommunication.ExportCashRegister(Rec, ATFiskalyCommunication.GetExportCashRegisterQueryParameters());
                end;
            }
            action(CreateControlReceipt)
            {
                ApplicationArea = NPRATFiscal;
                Caption = 'Create Control Receipt';
                Image = PreviewChecks;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the control receipt at Fiskaly and imports information about it into POS audit log.';

                trigger OnAction()
                var
                    ATAuditMgt: Codeunit "NPR AT Audit Mgt.";
                begin
                    ATAuditMgt.CreateControlReceipt(Rec);
                end;
            }
        }
    }
}
