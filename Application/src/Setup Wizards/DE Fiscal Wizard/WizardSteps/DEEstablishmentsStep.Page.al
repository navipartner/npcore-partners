page 6184939 "NPR DE Establishments Step"
{
    Caption = 'DE Establishments';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR DE Establishment";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Repeater)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the POS store code to identify this DE Fiskaly establishment.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the text that describes this DE Fiskaly establishment.';
                }
                field("Connection Parameter Set Code"; Rec."Connection Parameter Set Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the connection parameter set to which this DE Fiskaly establishment is assigned.';
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the establishment is created at Fiskaly.';
                }
                field(Decommissioned; Rec.Decommissioned)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the establishment is decommissioned at Fiskaly.';
                }
                field("Decommissioning Date"; Rec."Decommissioning Date")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = Rec.Created and not Rec.Decommissioned;
                    ToolTip = 'Specifies the date when establishment is decommissioned at Fiskaly.';
                }
                field(Street; Rec.Street)
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the street of the establishment.';
                }
                field("House Number"; Rec."House Number")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the house number of the establishment.';
                }
                field("House Number Suffix"; Rec."House Number Suffix")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the house number suffix of the establishment.';
                }
                field(Town; Rec.Town)
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the town of the establishment.';
                }
                field("ZIP Code"; Rec."ZIP Code")
                {
                    ApplicationArea = NPRRetail;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the ZIP code of the establishment.';
                }
                field("Additional Address"; Rec."Additional Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the additional address information of the establishment.';
                }
                field(Designation; Rec.Designation)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the designation of the establishment (place of business).';
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the remarks about the establishment.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateEstablishment)
            {
                ApplicationArea = NPRRetail;
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
            action(RetrieveEstablishment)
            {
                ApplicationArea = NPRRetail;
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
        }
    }
}
