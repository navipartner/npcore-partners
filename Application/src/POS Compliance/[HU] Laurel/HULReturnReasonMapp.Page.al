page 6184966 "NPR HU L Return Reason Mapp."
{
    ApplicationArea = NPRHULaurelFiscal;
    Caption = 'HU Laurel Return Reason Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR HU L Return Reason Mapp.";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Return Reason Code"; Rec."Return Reason Code")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the Return Reason Code.';
                }
                field("HU L Return Reason Code"; Rec."HU L Return Reason Code")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the Return Reason that is possible to use in Hungary.';
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
                Caption = 'Init Return Reasons';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize HU L Return Reason Mapping with non existing Return Reasons.';

                trigger OnAction()
                var
                    HULReturnReasonMapp: Record "NPR HU L Return Reason Mapp.";
                    ReturnReason: Record "Return Reason";
                begin
                    if not ReturnReason.FindSet() then
                        exit;
                    repeat
                        if not HULReturnReasonMapp.Get(ReturnReason.Code) then begin
                            HULReturnReasonMapp.Init();
                            HULReturnReasonMapp."Return Reason Code" := ReturnReason.Code;
                            HULReturnReasonMapp.Insert();
                        end;
                    until ReturnReason.Next() = 0;
                end;
            }
        }
    }
}