page 6184764 "NPR ES Signers Step"
{
    Caption = 'ES Signers';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR ES Signer";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a code to identify this ES Fiskaly signer.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a text that describes this ES Fiskaly signer.';
                }
                field("ES Organization Code"; Rec."ES Organization Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies a ES Fiskaly organization to which this ES Fiskaly signer is assigned.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the state of this ES Fiskaly signer.';
                }
                field("Certificate Serial Number"; Rec."Certificate Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the serial number of the certificate for this ES Fiskaly signer.';
                }
                field("Certificate Expires At"; Rec."Certificate Expires At")
                {
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
            action(RetrieveSigner)
            {
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
    }
}
