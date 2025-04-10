page 6059891 "NPR DE Connection Param. Sets"
{
    Extensible = False;
    Caption = 'DE Connection Parameter Sets';
    CardPageId = "NPR DE Audit Setup";
    PageType = List;
    SourceTable = "NPR DE Audit Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRDEFiscal;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Primary Key"; Rec."Primary Key")
                {
                    ToolTip = 'Specifies a code to identify this set of DE Fiskaly connection parameters.';
                    ApplicationArea = NPRDEFiscal;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the set of DE Fiskaly connection parameters.';
                    ApplicationArea = NPRDEFiscal;
                }
                field("Taxpayer Created"; Rec."Taxpayer Created")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies whether the taxpayer is created at Fiskaly.';
                }
            }
        }
        area(factboxes)
        {
            systempart(LinksFactBox; Links)
            {
                ApplicationArea = NPRDEFiscal;
                Visible = false;
            }
            systempart(NotesFactBox; Notes)
            {
                ApplicationArea = NPRDEFiscal;
                Visible = false;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(DEEstablishments)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'DE Establishments';
                Image = Home;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR DE Establishments";
                ToolTip = 'Opens DE Establishments page.';
            }
        }
    }
}
