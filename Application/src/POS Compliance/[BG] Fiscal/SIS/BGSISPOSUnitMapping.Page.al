page 6151281 "NPR BG SIS POS Unit Mapping"
{
    ApplicationArea = NPRBGSISFiscal;
    Caption = 'BG SIS POS Unit Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/bulgaria/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR BG SIS POS Unit Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the number of the POS unit.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("POS Unit Name");
                    end;
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the name of the POS unit.';
                }
                field("Fiscal Printer IP Address"; Rec."Fiscal Printer IP Address")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the IP address of the fiscal printer related to this POS unit.';
                }
                field("Printer Model"; Rec."Printer Model")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the model of the fiscal printer related to this POS unit.';
                }
                field("Fiscal Printer Device No."; Rec."Fiscal Printer Device No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the device number of the fiscal printer related to this POS unit.';
                }
                field("Fiscal Printer Memory No."; Rec."Fiscal Printer Memory No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the memory number of the fiscal printer related to this POS unit.';
                }
                field("Extended Receipt Invoice No."; Rec."Extended Receipt Invoice No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the No Serie of the Extended Receipt Invoice No. field.';
                }
                field("Extended Receipt Cr. Memo No."; Rec."Extended Receipt Cr. Memo No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the No Serie of the Extended Receipt Cr. Memo No. field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Init")
            {
                ApplicationArea = NPRBGSISFiscal;
                Caption = 'Init POS Units';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize BG SIS POS Unit Mapping with non existing POS Units.';

                trigger OnAction()
                var
                    BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
                    POSUnit: Record "NPR POS Unit";
                begin
                    if POSUnit.IsEmpty() then
                        exit;

                    POSUnit.FindSet();

                    repeat
                        if not BGSISPOSUnitMapping.Get(POSUnit."No.") then begin
                            BGSISPOSUnitMapping.Init();
                            BGSISPOSUnitMapping."POS Unit No." := POSUnit."No.";
                            BGSISPOSUnitMapping.Insert();
                        end;
                    until POSUnit.Next() = 0;
                end;
            }
        }
    }
}