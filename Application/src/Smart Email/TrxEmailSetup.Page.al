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
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("<API Key>"; "API URL")
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

