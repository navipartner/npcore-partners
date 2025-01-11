page 6184911 "NPR DE Establishment"
{
    Caption = 'DE Establishment';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Extensible = false;
    PageType = Card;
    SourceTable = "NPR DE Establishment";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
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
                    ShowMandatory = true;
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
                    Enabled = Rec.Created and not Rec.Decommissioned;
                    ToolTip = 'Specifies the date when establishment is decommissioned at Fiskaly.';
                }
            }
            group(Address)
            {
                Caption = 'Address';
                field(Street; Rec.Street)
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the street of the establishment.';
                }
                field("House Number"; Rec."House Number")
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the house number of the establishment.';
                }
                field("House Number Suffix"; Rec."House Number Suffix")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the house number suffix of the establishment.';
                }
                field(Town; Rec.Town)
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the town of the establishment.';
                }
                field("ZIP Code"; Rec."ZIP Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the ZIP code of the establishment.';
                }
                field("Additional Address"; Rec."Additional Address")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the additional address information of the establishment.';
                }
            }
            group(Miscellaneous)
            {
                Caption = 'Miscellaneous';

                field(Designation; Rec.Designation)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the designation of the establishment (place of business).';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the remarks about the establishment.';
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
            action(CreateEstablishment)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create / Update';
                Image = AddToHome;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the establishment at Fiskaly or updates the existing one.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.UpsertEstablishment(Rec, false);
                    CurrPage.Update(false);
                end;
            }
            action(DecommissionEstablishment)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Decommission';
                Enabled = Rec.Created and not Rec.Decommissioned;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Decommissiones the establishment at Fiskaly as of the specified date.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.DecommissionEstablishment(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveEstablishment)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Retrieve';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest information about the establishment from Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.RetrieveEstablishment(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CreateSubmission)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create Submission';
                Image = SendElectronicDocument;
                Enabled = Rec.Created and not Rec.Decommissioned;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Creates the submission for this establishment at Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.CreateSubmission(Rec."POS Store Code");
                end;
            }
        }
    }
}
