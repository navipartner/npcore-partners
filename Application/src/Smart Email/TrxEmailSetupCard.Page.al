page 6059826 "NPR Trx Email Setup Card"
{
    // NPR5.55/THRO/20200511 CASE 343266 Object created

    Caption = 'Transaction Email Setup Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Trx Email Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Provider; Provider)
                {
                    ApplicationArea = All;
                }
                field(Default; Default)
                {
                    ApplicationArea = All;
                }
                field("Client ID"; "Client ID")
                {
                    ApplicationArea = All;
                }
                field("API Key"; "API Key")
                {
                    ApplicationArea = All;
                }
                field("API URL"; "API URL")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(CheckConnection)
            {
                Caption = 'Test Connection';
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    TransactionalEmailMgt: Codeunit "NPR Transactional Email Mgt.";
                begin
                    TransactionalEmailMgt.CheckConnection(Rec);
                end;
            }
        }
    }
}

