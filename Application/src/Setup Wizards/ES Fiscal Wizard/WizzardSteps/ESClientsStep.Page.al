page 6184765 "NPR ES Clients Step"
{
    Caption = 'ES Clients';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR ES Client";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS unit number to identify this ES Client.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the text that describes this ES Client.';
                }
                field("ES Organization Code"; Rec."ES Organization Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies a ES Fiskaly organization to which this ES Fiskaly client is assigned.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the state of this ES Fiskaly client.';
                }
                field("ES Signer Code"; Rec."ES Signer Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ES Fiskaly signer to which this ES Fiskaly client is assigned.';
                }
                field("ES Signer Id"; Rec."ES Signer Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Id of ES Fiskaly signer to which this ES Fiskaly client is assigned.';
                }
                field("Invoice No. Series"; Rec."Invoice No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to invoices.';
                }
                field("Complete Invoice No. Series"; Rec."Complete Invoice No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to complete invoices.';
                }
                field("Correction Invoice No. Series"; Rec."Correction Invoice No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the number series that will be used to assign numbers to correction invoices.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateClient)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Create';
                Enabled = Rec.State = Rec.State::" ";
                Image = ElectronicRegister;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the client at Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.CreateClient(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveClient)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Retrieve';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the client from Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ESFiskalyCommunication.RetrieveClient(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ListClients)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Refresh Clients';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copies information about the available clients from Fiskaly.';

                trigger OnAction()
                var
                    ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
                begin
                    ESFiskalyCommunication.ListClients();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
