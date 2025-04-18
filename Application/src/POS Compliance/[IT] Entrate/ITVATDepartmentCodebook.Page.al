page 6151331 "NPR IT VAT Department Codebook"
{
    Caption = 'IT VAT Department Codebook';
    ContextSensitiveHelpPage = 'docs/fiscalization/italy/how-to/setup/';
    Extensible = false;
    PageType = List;
    ApplicationArea = NPRITFiscal;
    UsageCategory = Administration;
    SourceTable = "NPR IT VAT Department Codebook";
    SourceTableView = sorting("POS Unit No.") order(ascending);

    layout
    {
        area(Content)
        {
            repeater(ListOfDepartments)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the POS Unit Code this VAT codes are related to.';
                }
                field("IT Printer VAT Department"; Rec."IT Printer VAT Department")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the Printer VAT Department pulled out from Fiscal Printer.';
                }
                field("IT Printer VAT %"; Rec."IT Printer VAT %")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the Printer VAT % related to the selected VAT Department.';
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
                Caption = 'Init POS Units and Departments';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize IT VAT Department Codebook with non existing POS Units and Department values.';

                trigger OnAction()
                var
                    POSUnit: Record "NPR POS Unit";
                begin
                    if not POSUnit.FindSet() then
                        exit;
                    repeat
                        Rec.InitVATDepartmentsForPOSUnit(POSUnit);
                    until POSUnit.Next() = 0;
                end;
            }
        }
    }
}