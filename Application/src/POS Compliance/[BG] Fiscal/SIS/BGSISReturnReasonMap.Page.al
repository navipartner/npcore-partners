page 6151288 "NPR BG SIS Return Reason Map"
{
    ApplicationArea = NPRBGSISFiscal;
    Caption = 'BG SIS Return Reason Mapping';
    ContextSensitiveHelpPage = 'docs/fiscalization/bulgaria/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR BG SIS Return Reason Map";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Return Reason Code"; Rec."Return Reason Code")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Return Reason Code.';
                }
                field("BG SIS Return Reason"; Rec."BG SIS Return Reason")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Return Reason that is possible to use in Bulgaria.';
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
                Caption = 'Init Return Reasons';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize BG SIS Return Reason Mapping with non existing Return Reasons.';

                trigger OnAction()
                var
                    BGSISReturnReasonMap: Record "NPR BG SIS Return Reason Map";
                    ReturnReason: Record "Return Reason";
                begin
                    if ReturnReason.IsEmpty() then
                        exit;

                    ReturnReason.FindSet();

                    repeat
                        if not BGSISReturnReasonMap.Get(ReturnReason.Code) then begin
                            BGSISReturnReasonMap.Init();
                            BGSISReturnReasonMap."Return Reason Code" := ReturnReason.Code;
                            BGSISReturnReasonMap.Insert();
                        end;
                    until ReturnReason.Next() = 0;
                end;
            }
        }
    }
}