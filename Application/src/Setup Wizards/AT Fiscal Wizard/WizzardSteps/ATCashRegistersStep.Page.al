page 6184686 "NPR AT Cash Registers Step"
{
    Caption = 'AT Cash Registers';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR AT Cash Register";
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
                    ToolTip = 'Specifies the POS unit number to identify this AT cash register.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the text that describes this AT cash register.';
                }
                field("AT SCU Code"; Rec."AT SCU Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the AT Fiskaly signature creation unit to which this AT Fiskaly cash register is assigned.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the state of this AT Fiskaly cash register.';
                }
                field("Serial Number"; Rec."Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique serial number of this AT Fiskaly cash register. Corresponds to the "Kassenidentifikationsnummer" in the context of RKSV.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when it is created at Fiskaly.';
                }
                field("Registered At"; Rec."Registered At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when it is registered at Fiskaly.';
                }
                field("Initialized At"; Rec."Initialized At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when it is initialized at Fiskaly.';
                }
                field("Initialization Receipt Id"; Rec."Initialization Receipt Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the identifier of initialization receipt at Fiskaly.';
                }
                field("Decommissioned At"; Rec."Decommissioned At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when it is decommissioned at Fiskaly.';
                }
                field("Decommission Receipt Id"; Rec."Decommission Receipt Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the identifier of decommission receipt at Fiskaly.';
                }
                field("Outage At"; Rec."Outage At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when it is reported as outage at Fiskaly.';
                }
                field("Defect At"; Rec."Defect At")
                {
                    ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
                ApplicationArea = NPRRetail;
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
            action(ListCashRegisters)
            {
                ApplicationArea = NPRRetail;
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
        }
    }
}
