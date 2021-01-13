page 6059921 "NPR BTF Service EndPoints"
{
    PageType = List;
    SourceTable = "NPR BTF Service EndPoint";
    Caption = 'BTwentyFour Service EndPoints';
    DelayedInsert = true;
    DataCaptionFields = "Service Code";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("EndPoint ID"; Rec."EndPoint ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the endpoint id. Unique, arbitrary, alpha-numeric, value assigned to each BTwentyFour service endpoint.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the service endpoint.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the endpoint is enabled. To be able to consume resources, service endpoint has to be enabled.';
                }
                field("EndPoint-Key"; Rec."EndPoint-Key")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the service endpoint key obtained with API credentials. EndPoint-Key is not mandatory for all endpoints.';
                }
                field(Accept; Rec.Accept)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies response format (e.g. response could be in json or xml format). Change value and check response by running an action Send Request.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Errors)
            {
                ApplicationArea = All;
                ToolTip = 'View BTwentyFour API service endpoint error log entries.';
                Image = ErrorLog;
                Caption = 'Error Log';

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.ShowErrorLogEntries(Rec);
                end;
            }
        }
        area(Processing)
        {

            action(SendRequest)
            {
                ApplicationArea = Advanced;
                ToolTip = 'Send request and download result for selected service endpoint. Web request will be prepared based on values prepared in Service Setup combined with values from selected service endpoint (path, endpoint-key...).';
                Caption = 'Send Request';
                Image = Web;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.SendRequestAndDownloadResult(Rec);
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        Rec.OnRegisterServiceEndPoint();
    end;
}