page 6059826 "NPR Trx Email Setup Card"
{
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Provider field';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default field';
                }
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client ID field';
                }
                field("API Key"; Rec."API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Key field';
                }
                field("API URL"; Rec."API URL")
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
                ApplicationArea = All;
                Caption = 'Test Connection';
                Image = Link;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
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

