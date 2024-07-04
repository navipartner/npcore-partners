page 6184633 "NPR AT POS Payment Method Map"
{
    ApplicationArea = NPRATFiscal;
    Caption = 'AT POS Payment Method Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/austria/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR AT POS Payment Method Map";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the POS Payment Method.';
                }
                field("AT Payment Type"; Rec."AT Payment Type")
                {
                    ApplicationArea = NPRATFiscal;
                    ToolTip = 'Specifies the Payment Type that is possible to use in Austria.';
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
                ApplicationArea = NPRATFiscal;
                Caption = 'Init Payment Methods';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize AT POS Payment Method Mapping with non existing POS Payment Methods.';

                trigger OnAction()
                var
                    ATPOSPaymentMethodMap: Record "NPR AT POS Payment Method Map";
                    POSPaymentMethod: Record "NPR POS Payment Method";
                begin
                    if POSPaymentMethod.IsEmpty() then
                        exit;

                    POSPaymentMethod.FindSet();

                    repeat
                        if not ATPOSPaymentMethodMap.Get(POSPaymentMethod.Code) then begin
                            ATPOSPaymentMethodMap.Init();
                            ATPOSPaymentMethodMap."POS Payment Method Code" := POSPaymentMethod.Code;
                            ATPOSPaymentMethodMap.Insert();
                        end;
                    until POSPaymentMethod.Next() = 0;
                end;
            }
        }
    }
}