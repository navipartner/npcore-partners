page 6014427 "NPR DE POS Unit Aux. Info List"
{
    Extensible = False;
    Caption = 'NPR DE POS Unit Aux. Info List';
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
                    ToolTip = 'Specifies the value of POS Unit No.';
                    ApplicationArea = NPRRetail;
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of Cash Register Brand';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of Cash Register Model';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ToolTip = 'Specifies the value of Serial Number for DE Fiskaly';
                    ApplicationArea = NPRRetail;
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ToolTip = 'Specifies the Technical Security System (TSS) the entry is related to at Fiskaly.';
                    ApplicationArea = NPRRetail;
                }
                field("Client ID"; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of Client ID for DE Fiskaly';
                    ApplicationArea = NPRRetail;
                }
                field("Fiskaly Client Created at"; Rec."Fiskaly Client Created at")
                {
                    ToolTip = 'Specifies the date/time the Client was created at Fiskaly.';
                    ApplicationArea = NPRRetail;
                }
                field("Fiskaly Client State"; Rec."Fiskaly Client State")
                {
                    ToolTip = 'Specifies last known state of the Client at Fiskaly.';
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
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DETSS.FindSet();
                    repeat
                        DEFiskalyCommunication.GetTSSClientList(DETSS);
                    until DETSS.Next() = 0;
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
                    DEAuditSetup: Record "NPR DE Audit Setup";
                    DETSS: Record "NPR DE TSS";
                    GeneralLedgerSetup: Record "General Ledger Setup";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    RequestJson: JsonObject;
                    ResponseJson: JsonToken;
                    CashRegisterTypeJson: JsonObject;
                    SoftwareJson: JsonObject;
                begin
                    DEAuditSetup.Get();
                    GeneralLedgerSetup.Get();
                    Rec.TestField(SystemId);
                    Rec.TestField("TSS Code");
                    DETSS.Get(Rec."TSS Code");
                    DETSS.TestField("Fiskaly TSS Created at");
                    Rec.TestField("Cash Register Brand");
                    Rec.TestField("Cash Register Model");
                    //DEAuditSetup.TestField("DSFINVK Api URL");

                    CashRegisterTypeJson.Add('type', 'MASTER');
                    CashRegisterTypeJson.Add('tss_id', Format(DETSS.SystemId, 0, 4));
                    SoftwareJson.Add('brand', 'NP Retail');
                    RequestJson.Add('cash_register_type', CashRegisterTypeJson);
                    RequestJson.Add('software', SoftwareJson);
                    RequestJson.Add('brand', Rec."Cash Register Brand");
                    RequestJson.Add('model', Rec."Cash Register Model");
                    RequestJson.Add('base_currency_code', GeneralLedgerSetup."LCY Code");

                    if not DEFiskalyCommunication.SendRequest_signDE_V2(RequestJson, ResponseJson, 'PUT', StrSubstNo('/cash_registers/%1', Format(Rec.SystemId, 0, 4)), DEFiskalyCommunication.GetJwtToken()) then
                        Error(GetLastErrorText());

                    Rec."Cash Register Created" := true;
                    CurrPage.Update();
                end;
            }
        }
    }
}
