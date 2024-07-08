page 6184685 "NPR AT SCUs Step"
{
    Caption = 'AT Signature Creation Units';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR AT SCU";
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
                    ToolTip = 'Specifies a code to identify this AT Fiskaly signature creation unit.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a text that describes this AT Fiskaly signature creation unit.';
                }
                field("AT Organization Code"; Rec."AT Organization Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a AT Fiskaly organization to which this AT Fiskaly signature creation unit is assigned.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the state of this AT Fiskaly signature creation unit.';
                }
                field("Certificate Serial Number"; Rec."Certificate Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique serial number (in hexadecimal representation) of this AT Fiskaly signature creation unit.';
                }
                field("Pending At"; Rec."Pending At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when pending state is assigned at Fiskaly.';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when it is created at Fiskaly.';
                }
                field("Initialized At"; Rec."Initialized At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when it is initialized at Fiskaly.';
                }
                field("Decommissioned At"; Rec."Decommissioned At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when it is decommissioned at Fiskaly.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateSCU)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Create';
                Image = ElectronicRegister;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the signature creation unit at Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.CreateSCU(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveSCU)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Retrieve';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the signature creation unit from Fiskaly.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.RetrieveSCU(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(InitializeSCU)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Initialize';
                Image = Continue;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Initializes the signature creation unit at Fiskaly in order to be able to use it for signing receipts.';

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    ATFiskalyCommunication.UpdateSCU(Rec, Enum::"NPR AT SCU State"::INITIALIZED);
                    CurrPage.Update(false);
                end;
            }
            action(ListSCUs)
            {
                Caption = 'Refresh Signature Creation Units';
                ToolTip = 'Copies information about the available Signature Creation Units (SCUs) from Fiskaly.';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
                begin
                    ATFiskalyCommunication.ListSCUs();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
