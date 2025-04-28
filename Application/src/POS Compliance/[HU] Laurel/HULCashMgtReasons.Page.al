page 6184953 "NPR HU L Cash Mgt. Reasons"
{
    ApplicationArea = NPRHULaurelFiscal;
    UsageCategory = Administration;
    Caption = 'HU Laurel Cash Mgt Reasons';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR HU L Cash Mgt. Reason";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field("Cash Mgt Reason"; Rec."Cash Mgt Reason")
                {
                    ApplicationArea = NPRHULaurelFiscal;
                    ToolTip = 'Specifies the value of the Cash Mgt. Reason field.';
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
                Caption = 'Init Cash Mgt. Reasons';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Initialize HU L Cash Management Reasons with currently available reasons.';

                trigger OnAction()
                begin
                    Rec.InitCashMgtReasons();
                end;
            }
        }
    }
}