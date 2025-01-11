page 6184913 "NPR DE TSS Client"
{
    Caption = 'DE Fiskaly TSS Client';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Extensible = False;
    PageType = Card;
    SourceTable = "NPR DE POS Unit Aux. Info";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            Group(General)
            {
                Caption = 'General';

                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS Unit this Fiskaly client is created for.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the POS unit cash register serial number.';
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
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
            Group(AdditionalData)
            {
                Caption = 'Additional Data';

                field("Additional Data Created"; Rec."Additional Data Created")
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Created';
                    ToolTip = 'Specifies whether the client''s additional data is created at Fiskaly.';
                }
                field("Additional Data Decommissioned"; Rec."Additional Data Decommissioned")
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Decommissioned';
                    ToolTip = 'Specifies whether the client''s additional data is decommissioned at Fiskaly.';
                }
                field("Acquisition Date"; Rec."Acquisition Date")
                {
                    ApplicationArea = NPRDEFiscal;
                    Enabled = not Rec."Additional Data Created";
                    ShowMandatory = true;
                    ToolTip = 'Specifies the date when client is acquisitioned at Fiskaly.';
                }
                field("Commissioning Date"; Rec."Commissioning Date")
                {
                    ApplicationArea = NPRDEFiscal;
                    Enabled = not Rec."Additional Data Created";
                    ShowMandatory = true;
                    ToolTip = 'Specifies the date when client is commissioned at Fiskaly.';
                }
                field("Decommissioning Date"; Rec."Decommissioning Date")
                {
                    ApplicationArea = NPRDEFiscal;
                    Enabled = Rec."Additional Data Created" and not Rec."Additional Data Decommissioned";
                    ToolTip = 'Specifies the date when client is decommissioned at Fiskaly.';
                }
                field("Decommissioning Reason"; Rec."Decommissioning Reason")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the reason why client is decommissioned at Fiskaly.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the POS store (establishment) to which this client is assigned to.';
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the client (POS unit cash register) brand (manufacturer).';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the client (POS unit cash register) model.';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the remarks about the client.';
                }
                field(Software; Rec.Software)
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the software of the client.';
                }
                field("Software Version"; Rec."Software Version")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the software version of the client.';
                }
                field("Client Type"; Rec."Client Type")
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the type of the client.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create Client")
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create';
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
                Caption = 'Deregister';
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
            action(UpsertClientAdditionalData)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create / Update Additional Data';
                Image = Info;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the additional data for client at Fiskaly or updates the existing one.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.UpsertClientAdditionalData(Rec, false);
                    CurrPage.Update(false);
                end;
            }
            action(DecommissionClientAdditionalData)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Decommission Additional Data';
                Enabled = Rec."Additional Data Created" and not Rec."Additional Data Decommissioned";
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Decommissiones the client''s additional data at Fiskaly as of the specified date.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.DecommissionClientAdditionalData(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveClientAdditionalData)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Retrieve Additional Data';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the client''s additional data from Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.RetrieveClientAdditionalData(Rec);
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetDefaultValues();
    end;

    local procedure SetDefaultValues()
    var
        CashRegisterModelLbl: Label 'NaviPartner', Locked = true;
        CashRegisterBrandLbl: Label 'NaviPartner', Locked = true;
        SoftwareLbl: Label 'NP Retail', Locked = true;
    begin
        if Rec."Cash Register Brand" = '' then
            Rec."Cash Register Brand" := CashRegisterBrandLbl;

        if Rec."Cash Register Model" = '' then
            Rec."Cash Register Model" := CashRegisterModelLbl;

        if Rec.Software = '' then
            Rec.Software := SoftwareLbl;
    end;
}
