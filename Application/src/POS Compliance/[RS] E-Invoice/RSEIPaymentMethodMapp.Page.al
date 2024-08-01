page 6184572 "NPR RS EI Payment Method Mapp."
{
    Caption = 'RS E-Invoice Payment Method Mapping';
    ApplicationArea = NPRRSEInvoice;
    UsageCategory = Administration;
    PageType = List;
    SourceTable = "NPR RS EI Payment Method Mapp.";
    Extensible = false;
    AdditionalSearchTerms = 'Serbia E-Invoice Payment Method Mapping,RS E Invoice Document Payment Method Mapping';

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ToolTip = 'Specifies the value of the Payment Method Code field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("RS EI Payment Means"; Rec."RS EI Payment Means")
                {
                    ToolTip = 'Specifies the value of the RS Payment Means field.';
                    ApplicationArea = NPRRSEInvoice;
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
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize RS E-Invoice Payment Method Mapping with non existing Payment Methods';
                ApplicationArea = NPRRSEInvoice;

                trigger OnAction()
                var
                    RSEIPaymentMethodMapping: Record "NPR RS EI Payment Method Mapp.";
                    PaymentMethod: Record "Payment Method";
                begin
                    if PaymentMethod.IsEmpty() then
                        exit;
                    PaymentMethod.FindSet();
                    repeat
                        if not RSEIPaymentMethodMapping.Get(PaymentMethod.Code) then begin
                            RSEIPaymentMethodMapping.Init();
                            RSEIPaymentMethodMapping."Payment Method Code" := PaymentMethod.Code;
                            RSEIPaymentMethodMapping.Insert();
                        end;
                    until PaymentMethod.Next() = 0;
                end;
            }
        }
    }
}