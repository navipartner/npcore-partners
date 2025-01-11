page 6184910 "NPR DE Establishments"
{
    ApplicationArea = NPRDEFiscal;
    Caption = 'DE Establishments';
    CardPageId = "NPR DE Establishment";
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR DE Establishment";
    UsageCategory = Administration;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the POS store code to identify this DE Fiskaly establishment.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the text that describes this DE Fiskaly establishment.';
                }
                field("Connection Parameter Set Code"; Rec."Connection Parameter Set Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the connection parameter set to which this DE Fiskaly establishment is assigned.';
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies whether the establishment is created at Fiskaly.';
                }
                field(Decommissioned; Rec.Decommissioned)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies whether the establishment is decommissioned at Fiskaly.';
                }
                field("Decommissioning Date"; Rec."Decommissioning Date")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the date when establishment is decommissioned at Fiskaly.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(DETSSClients)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'DE TSS Clients';
                Image = SetupList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR DE POS Unit Aux. Info List";
                ToolTip = 'Opens DE TSS Clients page.';
            }
            action(DETSubmissions)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'DE Submissions';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR DE Submissions";
                ToolTip = 'Opens DE Submissions page.';
            }
        }
        area(Processing)
        {
            action(RetrieveEstablishments)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Refresh Establishments';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copies information about the available establishments from Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.RetrieveEstablishments();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
