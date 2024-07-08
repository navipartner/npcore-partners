page 6150855 "NPR RS Payment Method Mapping"
{
    ApplicationArea = NPRRSFiscal;
    Caption = 'RS Payment Method Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/serbia/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR RS Payment Method Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the Payment Method Code for which mapping is set.';
                }
                field("RS Payment Method"; Rec."RS Payment Method")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the RS Payment Method Mapping.';
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
                ToolTip = 'Initialize RS Payment Method Mapping with non existing Payment Methods';
                trigger OnAction()
                var
                    RSPaymentMethodMapping: Record "NPR RS Payment Method Mapping";
                    PaymentMethod: Record "Payment Method";
                begin
                    if PaymentMethod.IsEmpty() then
                        exit;
                    PaymentMethod.FindSet();
                    repeat
                        if not RSPaymentMethodMapping.Get(PaymentMethod.Code) then begin
                            RSPaymentMethodMapping.Init();
                            RSPaymentMethodMapping."Payment Method Code" := PaymentMethod.Code;
                            RSPaymentMethodMapping."RS Payment Method" := RSPaymentMethodMapping."RS Payment Method"::Other;
                            RSPaymentMethodMapping.Insert();
                        end;
                    until PaymentMethod.Next() = 0;
                end;
            }
        }
    }
}