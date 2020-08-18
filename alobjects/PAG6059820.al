page 6059820 "Transactional Email Setup"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Changed to List

    Caption = 'Transactional Email Setup';
    CardPageID = "Transaction Email Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "Transactional Email Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("<API Key>";"API URL")
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

