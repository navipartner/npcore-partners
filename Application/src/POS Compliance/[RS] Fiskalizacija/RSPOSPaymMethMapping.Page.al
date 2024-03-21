page 6150856 "NPR RS POS Paym. Meth. Mapping"
{
    ApplicationArea = NPRRSFiscal;
    Caption = 'RS POS Payment Method Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/serbia/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR RS POS Paym. Meth. Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(POSPaymentMethodMappingLines)
            {
                field("Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Payment Method Code field.';
                }
                field("RS Payment Method"; Rec."RS Payment Method")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the RS Payment Method field.';
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
                ApplicationArea = NPRRSFiscal;
                Caption = 'Init Payment Methods';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize RS POS Payment Method Mapping with non existing POS Payment Methods';
                trigger OnAction()
                var
                    POSPaymentMethod: Record "NPR POS Payment Method";
                    RSPOSPaymMethMapping: Record "NPR RS POS Paym. Meth. Mapping";
                begin
                    if POSPaymentMethod.IsEmpty() then
                        exit;
                    POSPaymentMethod.FindSet();
                    repeat
                        if not RSPOSPaymMethMapping.Get(POSPaymentMethod.Code) then begin
                            RSPOSPaymMethMapping.Init();
                            RSPOSPaymMethMapping."POS Payment Method Code" := POSPaymentMethod.Code;
                            RSPOSPaymMethMapping."RS Payment Method" := RSPOSPaymMethMapping."RS Payment Method"::Other;
                            RSPOSPaymMethMapping.Insert();
                        end;
                    until POSPaymentMethod.Next() = 0;
                end;
            }
        }
    }
}