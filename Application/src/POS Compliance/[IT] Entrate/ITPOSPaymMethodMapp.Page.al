page 6151319 "NPR IT POS Paym. Method Mapp."
{
    ApplicationArea = NPRITFiscal;
    Caption = 'IT POS Payment Method Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/italy/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR IT POS Paym. Method Mapp.";
    SourceTableView = sorting("POS Unit No.") order(ascending);
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the POS Unit No. for which the mapping is related to.';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the Payment Method Code selected from the related POS Payment Method list.';
                }
                field("CRO Payment Method"; Rec."IT Payment Method")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the applicable Payment Method related to the Fiscal Printer.';
                }
                field("IT Payment Method Index"; Rec."IT Payment Method Index")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the IT Payment Method Index that is set in Fiscal Printer.';
                }
                field("IT Payment Method Description"; Rec."IT Payment Method Description")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the Payment Method Description that is being pulled from the Fiscal Printer based on the set Payment Method Index. The description field will be filled after the Fiscal Printer is set.';
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
                Caption = 'Init Payment Methods';
                ApplicationArea = NPRITFiscal;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize IT POS Payment Method Mapping for each POS Unit with non existing POS Payment Methods that are supported by RT Printer.';

                trigger OnAction()
                begin
                    Rec.InitITPOSPaymentMethods();
                end;
            }
        }
    }
}