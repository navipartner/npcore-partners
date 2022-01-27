page 6059820 "NPR Trx Email Setup"
{
    Extensible = False;
    Caption = 'Transactional Email Setup';
    CardPageID = "NPR Trx Email Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Trx Email Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("<API Key>"; Rec."API URL")
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

