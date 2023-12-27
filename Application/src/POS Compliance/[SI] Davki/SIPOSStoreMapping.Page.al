page 6151297 "NPR SI POS Store Mapping"
{
    ApplicationArea = NPRSIFiscal;
    Caption = 'SI POS Store Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR SI POS Store Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(POSStoreMappingLines)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS Unit Code.';
                }
                field(Registered; Rec.Registered)
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies if the related POS Unit is Registered.';
                }
                field("Cadastral Number"; Rec."Cadastral Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Cadastral Number of the related registered POS Unit.';
                }
                field("Building Number"; Rec."Building Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Building Number of the related registered POS Unit.';
                }
                field("Building Section Number"; Rec."Building Section Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Building Section Number of the related registered POS Unit.';
                }
                field("Validity Date"; Rec."Validity Date")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Validity Date of the registration.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Register)
            {
                Caption = 'Register POS Store';
                Promoted = true;
                PromotedOnly = true;
                Image = Registered;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = NPRSIFiscal;
                ToolTip = 'Executes the Register POS Store action.';
                trigger OnAction()
                var
                    SITaxCommunicationMgt: Codeunit "NPR SI Tax Communication Mgt.";
                begin
                    SITaxCommunicationMgt.RegisterPOSStore(Rec);
                end;
            }
        }
    }
}