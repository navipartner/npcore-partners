page 6151272 "NPR BG SIS POS Paym. Meth. Map"
{
    ApplicationArea = NPRBGSISFiscal;
    Caption = 'BG SIS POS Payment Method Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR BG SIS POS Paym. Meth. Map";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the Payment Method Code field.';
                }
                field("BG Payment Method"; Rec."BG SIS Payment Method")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the BG Payment Method field.';
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
                Caption = 'Init Payment Methods';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize BG SIS POS Payment Method Mapping with non existing POS Payment Methods.';

                trigger OnAction()
                var
                    BGPOSPaymMethMapping: Record "NPR BG SIS POS Paym. Meth. Map";
                    POSPaymentMethod: Record "NPR POS Payment Method";
                begin
                    if POSPaymentMethod.IsEmpty() then
                        exit;

                    POSPaymentMethod.FindSet();

                    repeat
                        if not BGPOSPaymMethMapping.Get(POSPaymentMethod.Code) then begin
                            BGPOSPaymMethMapping.Init();
                            BGPOSPaymMethMapping."POS Payment Method Code" := POSPaymentMethod.Code;
                            BGPOSPaymMethMapping.Insert();
                        end;
                    until POSPaymentMethod.Next() = 0;
                end;
            }
        }
    }
}