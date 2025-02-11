page 6184700 "NPR ES Organization List"
{
    ApplicationArea = NPRESFiscal;
    Caption = 'ES Organizations';
    CardPageId = "NPR ES Organization Card";
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR ES Organization";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the code to identify this ES Fiskaly organization.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the text that describes this ES Fiskaly organization.';
                }
                field("Taxpayer Territory"; Rec."Taxpayer Territory")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the taxpayer territory of this ES Fiskaly organization. This value can be changed only until other resources are created. As of that moment a new ES Fiskaly organization should be created if changing its value is required.';
                }
                field("Taxpayer Type"; Rec."Taxpayer Type")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the type of taxpayer.';
                }
                field("Taxpayer Created"; Rec."Taxpayer Created")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies whether the taxpayer is created at Fiskaly for this ES Fiskaly organization.';
                }
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies whether the record is disabled due to taxpayer information change.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ESSigners)
            {
                ApplicationArea = NPRESFiscal;
                Caption = 'ES Signers';
                Image = SetupList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = page "NPR ES Signers";
                ToolTip = 'Opens ES Signers page.';
            }
        }
    }
}
