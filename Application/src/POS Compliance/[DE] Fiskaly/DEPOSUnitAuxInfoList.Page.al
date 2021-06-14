page 6014427 "NPR DE POS Unit Aux. Info List"
{
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of POS Unit No.';
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of Cash Register Brand';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of Cash Register Model';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of Serial Number for DE Fiskaly';
                }
                field("TSS ID"; Rec."TSS ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of TSS ID for DE Fiskaly';
                }
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of Client ID for DE Fiskaly';
                }
                field("Cash Register Created"; Rec."Cash Register Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of Cash Registe for DE Fiskaly DSFINKV';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create TSS Client ID")
            {
                Caption = 'Create Fiskaly TSS/Client';
                Image = Create;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Creates TSS and Client ID on Fiskaly for DE fiscalization.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    CreateTSSLbl: Label 'TSS ID already exists, this action will create New TSS ID and Client ID. Do you want to continue?';
                begin
                    //Fiskaly recomendation for now is to have TSS and Client 1 to 1.
                    Rec.TestField("Serial Number");
                    if not IsNullGuid(Rec."TSS ID") then
                        if not Confirm(CreateTSSLbl) then
                            exit;
                    DEFiskalyCommunication.CreateTSSClient(Rec);
                    CurrPage.Update();
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
                ApplicationArea = All;
                ToolTip = 'Creates Cash Register on Fiskaly DSFINVK for DE fiscalization.';

                trigger OnAction()
                var
                    DEAuditSetup: Record "NPR DE Audit Setup";
                    GeneralLedgerSetup: Record "General Ledger Setup";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    DEAuditMng: Codeunit "NPR DE Audit Mgt.";
                    RequestJson: JsonObject;
                    ResponseJson: JsonObject;
                    CashRegisterTypeJson: JsonObject;
                    SoftwareJson: JsonObject;
                    AccessToken: Text;
                begin
                    DEAuditSetup.Get();
                    GeneralLedgerSetup.Get();
                    Rec.TestField("Client ID");
                    Rec.TestField("TSS ID");
                    Rec.TestField("Cash Register Brand");
                    Rec.TestField("Cash Register Model");
                    DEAuditSetup.TestField("DSFINVK Api URL");

                    CashRegisterTypeJson.Add('type', 'MASTER');
                    CashRegisterTypeJson.Add('tss_id', Format(Rec."TSS ID", 0, 4));
                    SoftwareJson.Add('brand', 'NP Retail');
                    RequestJson.Add('cash_register_type', CashRegisterTypeJson);
                    RequestJson.Add('software', SoftwareJson);
                    RequestJson.Add('brand', Rec."Cash Register Brand");
                    RequestJson.Add('model', Rec."Cash Register Model");
                    RequestJson.Add('base_currency_code', GeneralLedgerSetup."LCY Code");

                    if not DEAuditMng.GetJwtToken(AccessToken) then
                        Error(GetLastErrorText());

                    if not DEFiskalyCommunication.SendDSFINVK(RequestJson, ResponseJson, DEAuditSetup, 'PUT', '/cash_registers/' + Format(Rec."Client ID", 0, 4), AccessToken) then
                        Error(GetLastErrorText());

                    Rec."Cash Register Created" := true;
                    CurrPage.Update();
                end;
            }
        }
    }
}