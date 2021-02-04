page 6059968 "NPR MPOS App Setup Card"
{
    Caption = 'MPOS App Setup Card';
    SourceTable = "NPR MPOS App Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Enable; Enable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Web Service Is Published"; "Web Service Is Published")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Is Published field';
                }
            }
            group(Admission)
            {
                Caption = 'Admission';
                field("Ticket Admission Web Url"; "Ticket Admission Web Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Admission Web Url field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Publish Webservice")
            {
                Caption = 'Publish Webservice';
                Image = Setup;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Codeunit "NPR MPOS Webservice";
                ApplicationArea = All;
                ToolTip = 'Executes the Publish Webservice action';

                trigger OnAction()
                begin
                    CODEUNIT.Run(6059965);
                    if WebService.Get(WebService."Object Type"::Codeunit, 'mpos_service') then begin
                        "Receipt Web API" := GetUrl(CLIENTTYPE::SOAP);
                    end;
                end;
            }
            action("Create QR Codes")
            {
                Caption = 'Create QR Codes';
                Image = Add;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "NPR MPOS QR Code List";
                ApplicationArea = All;
                ToolTip = 'Executes the Create QR Codes action';
            }
            action("EOD Receipts")
            {
                Caption = 'EOD Receipts';
                Image = List;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "NPR MPOS EOD Receipts";
                ApplicationArea = All;
                ToolTip = 'Executes the EOD Receipts action';
            }
        }
    }

    var
        WebService: Record "Web Service";
}

