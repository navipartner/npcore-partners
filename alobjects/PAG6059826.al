page 6059826 "Transaction Email Setup Card"
{
    // NPR5.55/THRO/20200511 CASE 343266 Object created

    Caption = 'Transaction Email Setup Card';
    PageType = Card;
    SourceTable = "Transactional Email Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Provider;Provider)
                {
                }
                field(Default;Default)
                {
                }
                field("Client ID";"Client ID")
                {
                }
                field("API Key";"API Key")
                {
                }
                field("API URL";"API URL")
                {
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

                trigger OnAction()
                var
                    TransactionalEmailMgt: Codeunit "Transactional Email Mgt.";
                begin
                    TransactionalEmailMgt.CheckConnection(Rec);
                end;
            }
        }
    }
}

