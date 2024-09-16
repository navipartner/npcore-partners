page 6014427 "NPR DE POS Unit Aux. Info List"
{
    Extensible = False;
    Caption = 'DE Fiskaly POS Unit Setup';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    PageType = List;
    SourceTable = "NPR DE POS Unit Aux. Info";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ToolTip = 'Specifies the POS Unit this Fiskaly client is created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS unit cash register brand.';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS unit cash register model.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ToolTip = 'Specifies the POS unit cash register serial number.';
                    ApplicationArea = NPRRetail;
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ToolTip = 'Specifies the Technical Security System (TSS) the Fiskaly client is linked to.';
                    ApplicationArea = NPRRetail;
                }
                field("Client ID"; Rec.SystemId)
                {
                    ToolTip = 'Specifies the Fiskaly client ID.';
                    ApplicationArea = NPRRetail;
                }
                field("Fiskaly Client Created at"; Rec."Fiskaly Client Created at")
                {
                    ToolTip = 'Specifies the date/time the client was created at Fiskaly.';
                    ApplicationArea = NPRRetail;
                }
                field("Fiskaly Client State"; Rec."Fiskaly Client State")
                {
                    ToolTip = 'Specifies last known state of the Fiskaly client.';
                    ApplicationArea = NPRRetail;
                }
                field("Cash Register Created"; Rec."Cash Register Created")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of Cash Registe for DE Fiskaly DSFINKV';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshClientList)
            {
                Caption = 'Refresh Client List';
                ToolTip = 'Copies information about all existing clients from Fiskaly to BC.';
                Image = LinkWeb;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    DETSS: Record "NPR DE TSS";
                    PosUnitAuxDE: Record "NPR DE POS Unit Aux. Info";
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
                        DEFiskalyCommunication.GetTSSClientList(DETSS, PosUnitAuxDE);
                    until DETSS.Next() = 0;
                    Window.Close();
                    CurrPage.Update(false);
                end;
            }
            action("Create Client")
            {
                Caption = 'Create Fiskaly Client';
                Image = InsertFromCheckJournal;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Creates Client ID on Fiskaly for DE fiscalization.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    DETSS: Record "NPR DE TSS";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    TSSNotSyncedQst: Label 'It looks that assigned TSS hasn''t been created at Fiskaly yet. If you continue, it will be created automatically.\Are you sure you want to continue?';
                begin
                    Rec.TestField("Serial Number");
                    Rec.TestField("TSS Code");
                    DETSS.Get(Rec."TSS Code");
                    if DETSS."Fiskaly TSS Created at" = 0DT then
                        if not Confirm(TSSNotSyncedQst, false) then
                            exit;

                    DEFiskalyCommunication.CreateClient(Rec);
                    CurrPage.Update(false);
                end;
            }
            action("Create Cash Register")
            {
                Caption = 'Create DSFINVK Cash Register';
                Image = Create;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRRetail;
                ToolTip = 'Creates Cash Register on Fiskaly DSFINVK for DE fiscalization.';
                Visible = false;

                trigger OnAction()
                var
                    ConnectionParameters: Record "NPR DE Audit Setup";
                    DETSS: Record "NPR DE TSS";
                    GeneralLedgerSetup: Record "General Ledger Setup";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    RequestJson: JsonObject;
                    ResponseJson: JsonToken;
                    CashRegisterTypeJson: JsonObject;
                    SoftwareJson: JsonObject;
                begin
                    GeneralLedgerSetup.Get();
                    Rec.TestField(SystemId);
                    Rec.TestField("TSS Code");
                    DETSS.Get(Rec."TSS Code");
                    DETSS.TestField("Fiskaly TSS Created at");
                    ConnectionParameters.GetSetup(DETSS);
                    Rec.TestField("Cash Register Brand");
                    Rec.TestField("Cash Register Model");

                    CashRegisterTypeJson.Add('type', 'MASTER');
                    CashRegisterTypeJson.Add('tss_id', Format(DETSS.SystemId, 0, 4));
                    SoftwareJson.Add('brand', 'NP Retail');
                    RequestJson.Add('cash_register_type', CashRegisterTypeJson);
                    RequestJson.Add('software', SoftwareJson);
                    RequestJson.Add('brand', Rec."Cash Register Brand");
                    RequestJson.Add('model', Rec."Cash Register Model");
                    RequestJson.Add('base_currency_code', GeneralLedgerSetup."LCY Code");
                    
                    if not DEFiskalyCommunication.SendRequest_DSFinV_K(RequestJson, ResponseJson, ConnectionParameters, 'PUT', StrSubstNo('/cash_registers/%1', Format(Rec.SystemId, 0, 4))) then
                        Error(GetLastErrorText());

                    Rec."Cash Register Created" := true;
                    CurrPage.Update();
                end;
            }
        }
        area(Navigation)
        {
            action(PaymentMappings)
            {
                Caption = 'Payment Method Mapping';
                ToolTip = 'Map Fiskaly payment types to POS payment methods.';
                Image = CoupledCurrency;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = page "NPR Payment Method Mapper";
                ApplicationArea = NPRRetail;
            }
            action(VATMappings)
            {
                Caption = 'VAT Posting Setup Mapping';
                ToolTip = 'Map Fiskaly VAT rate types to VAT business and product prosting group combinations.';
                Image = VATPostingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = page "NPR VAT Prod Post Group Mapper";
                ApplicationArea = NPRRetail;
            }
            action(DEAuditLog)
            {
                Caption = 'DE POS Audit Log';
                ToolTip = 'View transactions recorded in DE POS audit log with their sync. statuses.';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = page "NPR DE POS Audit Log Aux. Info";
                ApplicationArea = NPRRetail;
            }
        }
    }
}
