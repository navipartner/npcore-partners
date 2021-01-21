page 6059826 "NPR Trx Email Setup Card"
{
    // NPR5.55/THRO/20200511 CASE 343266 Object created

    UsageCategory = None;
    Caption = 'Transaction Email Setup Card';
    PageType = Card;
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
                    ToolTip = 'Specifies the value of the Provider field';
                }
                field(Default; Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default field';
                }
                field("Client ID"; "Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client ID field';
                }
                field("API Key"; "API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Key field';
                }
                field("API URL"; "API URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API URL field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Test Connection action';

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

