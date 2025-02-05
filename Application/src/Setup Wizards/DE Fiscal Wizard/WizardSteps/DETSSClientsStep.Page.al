page 6184946 "NPR DE TSS Clients Step"
{
    Caption = 'DE TSS Clients';
    Extensible = False;
    PageType = List;
    SourceTable = "NPR DE POS Unit Aux. Info";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Repeater)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS Unit this Fiskaly client is created for.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the POS unit cash register serial number.';
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the Technical Security System (TSS) the Fiskaly client is linked to.';
                }
                field("Client ID"; Rec.SystemId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Fiskaly client ID.';
                }
                field("Fiskaly Client Created at"; Rec."Fiskaly Client Created at")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date/time the client was created at Fiskaly.';
                }
                field("Fiskaly Client State"; Rec."Fiskaly Client State")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies last known state of the Fiskaly client.';
                }
                field("Cash Register Created"; Rec."Cash Register Created")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the cash register is created for DE Fiskaly DSFINKV.';
                }

                field("Additional Data Created"; Rec."Additional Data Created")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the client''s additional data is created at Fiskaly.';
                }
                field("Additional Data Decommissioned"; Rec."Additional Data Decommissioned")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the client''s additional data is decommissioned at Fiskaly.';
                }
                field("Acquisition Date"; Rec."Acquisition Date")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = not Rec."Additional Data Created";
                    ShowMandatory = true;
                    ToolTip = 'Specifies the date when client is acquisitioned at Fiskaly.';
                }
                field("Commissioning Date"; Rec."Commissioning Date")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = not Rec."Additional Data Created";
                    ShowMandatory = true;
                    ToolTip = 'Specifies the date when client is commissioned at Fiskaly.';
                }
                field("Decommissioning Date"; Rec."Decommissioning Date")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec."Additional Data Created" and not Rec."Additional Data Decommissioned";
                    ToolTip = 'Specifies the date when client is decommissioned at Fiskaly.';
                }
                field("Decommissioning Reason"; Rec."Decommissioning Reason")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the reason why client is decommissioned at Fiskaly.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the POS store (establishment) to which this client is assigned to.';
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the client (POS unit cash register) brand (manufacturer).';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the client (POS unit cash register) model.';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the remarks about the client.';
                }
                field(Software; Rec.Software)
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the software of the client.';
                }
                field("Software Version"; Rec."Software Version")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the software version of the client.';
                }
                field("Client Type"; Rec."Client Type")
                {
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
            action(UpsertClientAdditionalData)
            {
                ApplicationArea = NPRRetail;
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
            action(RetrieveClientAdditionalData)
            {
                ApplicationArea = NPRRetail;
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
