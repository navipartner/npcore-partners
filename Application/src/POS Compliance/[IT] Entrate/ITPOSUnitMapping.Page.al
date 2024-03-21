page 6151317 "NPR IT POS Unit Mapping"
{
    ApplicationArea = NPRITFiscal;
    Caption = 'IT POS Unit Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/italy/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR IT POS Unit Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the number of the POS unit.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("POS Unit Name");
                    end;
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the name of the POS unit.';
                }
                field("Fiscal Printer IP Address"; Rec."Fiscal Printer IP Address")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the IP address of the fiscal printer related to this POS unit.';
                }
                field("Fiscal Printer RT Type"; Rec."Fiscal Printer RT Type")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Fiscal Printer RT Type field.';
                }
                field("Fiscal Printer Serial No."; Rec."Fiscal Printer Serial No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the device number of the fiscal printer related to this POS unit.';
                }
                field("Fiscal Printer Password"; Rec."Fiscal Printer Password")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Fiscal Printer Password field.';
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
                ApplicationArea = NPRITFiscal;
                Caption = 'Init POS Units';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize IT POS Unit Mapping with non existing POS Units.';

                trigger OnAction()
                var
                    ITPOSUnitMapping: Record "NPR IT POS Unit Mapping";
                    POSUnit: Record "NPR POS Unit";
                begin
                    if not POSUnit.FindFirst() then
                        exit;

                    repeat
                        if not ITPOSUnitMapping.Get(POSUnit."No.") then begin
                            ITPOSUnitMapping.Init();
                            ITPOSUnitMapping."POS Unit No." := POSUnit."No.";
                            ITPOSUnitMapping.Insert();
                        end;
                    until POSUnit.Next() = 0;
                end;
            }
            action("Import Logo")
            {
                Caption = 'Import Logo';
                Image = Picture;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Import an image file to use as a logo.';
                ApplicationArea = NPRITFiscal;

                trigger OnAction()
                begin
                    Rec.ImportFPLogo();
                end;
            }

            action("Export Logo")
            {
                Caption = 'Export Logo';
                Image = ExportToDo;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Export the selected line as a bitmap image file (.bmp).';
                ApplicationArea = NPRITFiscal;

                trigger OnAction()
                begin
                    Rec.ExportFPLogo();
                end;
            }
        }
    }
}