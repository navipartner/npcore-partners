page 6150968 "NPR DK POS Paym. Meth. Mapping"
{
    ApplicationArea = NPRDKFiscal;
    Caption = 'DK POS Payment Method Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/denmark/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR DK POS Paym. Meth. Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the POS Payment Method.';
                }
                field("SAF-T Payment Type"; Rec."SAF-T Payment Type")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the means of payment that the POS Payment Method is reported as in the SAF-T Cash Register file.';
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
                ApplicationArea = NPRDKFiscal;
                Caption = 'Init Payment Methods';
                Image = Start;
                ToolTip = 'Initialize DK POS Payment Method Mapping with non existing POS Payment Methods.';

                trigger OnAction()
                var
                    DKPOSPaymMethMapping: Record "NPR DK POS Paym. Meth. Mapping";
                    POSPaymentMethod: Record "NPR POS Payment Method";
                begin
                    if not POSPaymentMethod.FindSet() then
                        exit;

                    repeat
                        if not DKPOSPaymMethMapping.Get(POSPaymentMethod.Code) then begin
                            DKPOSPaymMethMapping.Init();
                            DKPOSPaymMethMapping."POS Payment Method Code" := POSPaymentMethod.Code;
                            DKPOSPaymMethMapping.Insert();
                        end;
                    until POSPaymentMethod.Next() = 0;
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Init_Promoted; Init)
                {
                }
            }
        }
    }
}
