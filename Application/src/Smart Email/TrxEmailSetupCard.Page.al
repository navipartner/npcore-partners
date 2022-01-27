page 6059826 "NPR Trx Email Setup Card"
{
    Extensible = False;
    Caption = 'Transaction Email Setup Card';
    PageType = Card;
    SourceTable = "NPR Trx Email Setup";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(General)
            {
                field(Provider; Rec.Provider)
                {

                    ToolTip = 'Specifies the value of the Provider field';
                    ApplicationArea = NPRRetail;
                }
                field(Default; Rec.Default)
                {

                    ToolTip = 'Specifies the value of the Default field';
                    ApplicationArea = NPRRetail;
                }
                field("Client ID"; Rec."Client ID")
                {

                    ToolTip = 'Specifies the value of the Client ID field';
                    ApplicationArea = NPRRetail;
                }
                field("API Key"; Rec."API Key")
                {

                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = NPRRetail;
                }
                field("API URL"; Rec."API URL")
                {

                    ToolTip = 'Specifies the value of the API URL field';
                    ApplicationArea = NPRRetail;
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
                ToolTip = 'Executes the Test Connection action';
                ApplicationArea = NPRRetail;

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

