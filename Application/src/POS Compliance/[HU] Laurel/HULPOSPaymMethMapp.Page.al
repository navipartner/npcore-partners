page 6184914 "NPR HU L POS Paym. Meth. Mapp."
{
    ApplicationArea = NPRHULaurelFiscal;
    Caption = 'HU Laurel POS Payment Method Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR HU L POS Paym. Meth. Mapp.";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field.';
                }
                field("Payment Fiscal Type"; Rec."Payment Fiscal Type")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Payment Fiscal Type field.';
                }
                field("Payment Fiscal Subtype"; Rec."Payment Fiscal Subtype")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Payment Fiscal Subtype field.';
                }
                field("Payment Currency Type"; Rec."Payment Currency Type")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Payment Currency Type field.';
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
                Caption = 'Init POS Payment Methods';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize HU L POS Payment Method Mapping with non existing POS Payment Methods.';

                trigger OnAction()
                var
                    HULPOSPaymMethMapp: Record "NPR HU L POS Paym. Meth. Mapp.";
                    POSPaymentMethod: Record "NPR POS Payment Method";
                begin
                    if not POSPaymentMethod.FindSet() then
                        exit;

                    repeat
                        if not HULPOSPaymMethMapp.Get(POSPaymentMethod.Code) then begin
                            HULPOSPaymMethMapp.Init();
                            HULPOSPaymMethMapp."POS Payment Method Code" := POSPaymentMethod.Code;
                            HULPOSPaymMethMapp.Insert();
                        end;
                    until POSPaymentMethod.Next() = 0;
                end;
            }
        }
    }
}