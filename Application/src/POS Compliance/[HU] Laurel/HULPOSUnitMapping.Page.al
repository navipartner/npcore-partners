page 6185013 "NPR HU L POS Unit Mapping"
{
    ApplicationArea = NPRHULaurelFiscal;
    Caption = 'HU Laurel POS Unit Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR HU L POS Unit Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the number of the POS unit.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("POS Unit Name");
                    end;
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the name of the POS unit.';
                }
                field("Laurel License"; Rec."Laurel License")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Laurel Licence field.';
                }
                field("POS FCU Day Status"; Rec."POS FCU Day Status")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the POS FCU Day Status field.';
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
                ApplicationArea = NPRHULaurelFiscal;
                Caption = 'Init POS Units';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize HU L POS Unit Mapping with non existing POS Units.';

                trigger OnAction()
                var
                    HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
                    POSUnit: Record "NPR POS Unit";
                begin
                    if not POSUnit.FindSet() then
                        exit;

                    repeat
                        if not HULPOSUnitMapping.Get(POSUnit."No.") then begin
                            HULPOSUnitMapping.Init();
                            HULPOSUnitMapping."POS Unit No." := POSUnit."No.";
                            HULPOSUnitMapping.Insert();
                        end;
                    until POSUnit.Next() = 0;
                end;
            }
            action("Show Totals")
            {
                ApplicationArea = NPRHULaurelFiscal;
                Caption = 'Show FCU Totals';
                Image = TotalValueInsured;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Displays Fiscal Control Unit last checked totals.';

                trigger OnAction()
                begin
                    if Rec."POS FCU Daily Totals".HasValue() then
                        Message(Rec.GetDailyTotalsText());
                end;
            }
        }
    }
}