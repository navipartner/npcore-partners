page 6184703 "NPR ES Signers"
{
    ApplicationArea = NPRESFiscal;
    Caption = 'ES Signers';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR ES Signer";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies a code to identify this ES Fiskaly signer.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies a text that describes this ES Fiskaly signer.';
                }
                field("ES Organization Code"; Rec."ES Organization Code")
                {
                    ApplicationArea = NPRESFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies a ES Fiskaly organization to which this ES Fiskaly signer is assigned.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the state of this ES Fiskaly signer.';
                }
                field("Certificate Serial Number"; Rec."Certificate Serial Number")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the serial number of the certificate for this ES Fiskaly signer.';
                }
                field("Certificate Expires At"; Rec."Certificate Expires At")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the date and time when the certificate is expiring.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateSigner)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Create';
                Enabled = Rec.State = Rec.State::" ";
                Image = ElectronicRegister;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the signer at Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.CreateSigner(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DisableSigner)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Disable';
                Enabled = Rec.State = Rec.State::ENABLED;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Disables the signer at Fiskaly once you no longer want to use Fiskaly system.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.UpdateSigner(Rec, Enum::"NPR ES Signer State"::DISABLED);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveSigner)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Retrieve';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the signer from Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.RetrieveSigner(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ListSigners)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'Refresh Signers';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copies information about the available signers from Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    ESFiskalyCommunication.ListSigners();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(ESClients)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'ES Clients';
                Image = SetupList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR ES Clients";
                ToolTip = 'Opens ES Clients page.';
            }
        }
    }
}
