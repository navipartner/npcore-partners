page 6014427 "NPR DE POS Unit Aux. Info List"
{
    ApplicationArea = NPRDEFiscal;
    Caption = 'DE Fiskaly TSS Clients';
    CardPageId = "NPR DE TSS Client";
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Editable = false;
    Extensible = False;
    PageType = List;
    SourceTable = "NPR DE POS Unit Aux. Info";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS Unit this Fiskaly client is created for.';
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS unit cash register brand (manufacturer).';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS unit cash register model.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS unit cash register serial number.';
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the Technical Security System (TSS) the Fiskaly client is linked to.';
                }
                field("Client ID"; Rec.SystemId)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the Fiskaly client ID.';
                }
                field("Fiskaly Client Created at"; Rec."Fiskaly Client Created at")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the date/time the client was created at Fiskaly.';
                }
                field("Fiskaly Client State"; Rec."Fiskaly Client State")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies last known state of the Fiskaly client.';
                }
                field("Cash Register Created"; Rec."Cash Register Created")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies whether the cash register is created for DE Fiskaly DSFINKV.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PaymentMappings)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Payment Method Mapping';
                Image = CoupledCurrency;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "NPR Payment Method Mapper";
                ToolTip = 'Map Fiskaly payment types to POS payment methods.';
            }
            action(VATMappings)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'VAT Posting Setup Mapping';
                Image = VATPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "NPR VAT Prod Post Group Mapper";
                ToolTip = 'Map Fiskaly VAT rate types to VAT business and product prosting group combinations.';
            }
            action(DEAuditLog)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'DE POS Audit Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "NPR DE POS Audit Log Aux. Info";
                ToolTip = 'View transactions recorded in DE POS audit log with their sync. statuses.';
            }
        }
        area(Processing)
        {
            action(RefreshClientList)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Refresh Client List';
                Image = LinkWeb;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Copies information about all existing clients from Fiskaly to BC.';

                trigger OnAction()
                var
                    DETSS: Record "NPR DE TSS";
                    DETSSClient: Record "NPR DE POS Unit Aux. Info";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    Window: Dialog;
                    NoSyncedTssErr: Label 'No TSS has been synched to Fiskaly.';
                    WorkingLbl: Label 'Retrieving data from Fiskaly...';
                begin
                    DETSS.SetFilter("Fiskaly TSS Created at", '<>%1', 0DT);
                    if not DETSS.FindSet() then
                        Error(NoSyncedTssErr);
                    Window.Open(WorkingLbl);
                    repeat
                        DEFiskalyCommunication.GetTSSClientList(DETSS, DETSSClient);
                    until DETSS.Next() = 0;
                    Window.Close();
                    CurrPage.Update(false);
                end;
            }
            action("Create Client")
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create Fiskaly Client';
                Image = InsertFromCheckJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Creates Client ID on Fiskaly for DE fiscalization.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.CreateClient(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DeregisterClient)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Deregister Fiskaly Client';
                Image = VoidCheck;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Deregisters previously created client at Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    ConfirmDeregisterQst: Label 'The operation cannot be undone. Are you sure you want to deregister Fiskaly client for POS unit No. %1?', Comment = '%1 - POS Unit No.';
                begin
                    Rec.TestField("Fiskaly Client State", Rec."Fiskaly Client State"::REGISTERED);
                    if not Confirm(ConfirmDeregisterQst, false, Rec."POS Unit No.") then
                        exit;

                    DEFiskalyCommunication.UpdateTSSClient_State(Rec, Rec."Fiskaly Client State"::DEREGISTERED);
                    CurrPage.Update(false);
                end;
            }
            action("Create Cash Register")
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create DSFINVK Cash Register';
                Image = Create;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Creates Cash Register on Fiskaly DSFINVK for DE fiscalization or updates the existing one.';
                Visible = false;

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.UpsertCashRegister(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
