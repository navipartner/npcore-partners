page 6059820 "NPR Trx Email Setup"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Changed to List

    Caption = 'Transactional Email Setup';
    CardPageID = "NPR Trx Email Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Trx Email Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("<API Key>"; "API URL")
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

