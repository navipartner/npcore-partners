page 6184720 "NPR ES Return Reason Mapping"
{
    ApplicationArea = NPRESFiscal;
    Caption = 'ES Return Reason Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR ES Return Reason Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Repeater)
            {
                field("Return Reason Code"; Rec."Return Reason Code")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the Return Reason Code.';
                }
                field("ES Return Reason"; Rec."ES Return Reason")
                {
                    ApplicationArea = NPRESFiscal;
                    ToolTip = 'Specifies the Return Reason that is possible to use in Spain.';
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
                ApplicationArea = NPRESFiscal;
                Caption = 'Init Return Reasons';
                Enabled = ReturnReasonExists;
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize ES Return Reason Mapping with non existing Return Reasons.';

                trigger OnAction()
                var
                    ESReturnReasonMapping: Record "NPR ES Return Reason Mapping";
                    ReturnReason: Record "Return Reason";
                begin
                    ReturnReason.FindSet();

                    repeat
                        if not ESReturnReasonMapping.Get(ReturnReason.Code) then begin
                            ESReturnReasonMapping.Init();
                            ESReturnReasonMapping."Return Reason Code" := ReturnReason.Code;
                            ESReturnReasonMapping.Insert();
                        end;
                    until ReturnReason.Next() = 0;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        ReturnReason: Record "Return Reason";
    begin
        ReturnReasonExists := not ReturnReason.IsEmpty();
    end;

    var
        ReturnReasonExists: Boolean;
}