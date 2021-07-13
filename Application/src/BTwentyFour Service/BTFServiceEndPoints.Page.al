page 6059921 "NPR BTF Service EndPoints"
{
    UsageCategory = None;
    PageType = List;
    SourceTable = "NPR BTF Service EndPoint";
    Caption = 'BTwentyFour Service EndPoints';
    DataCaptionFields = "Service Code";
    Editable = false;
    CardPageId = "NPR BTF Service Endpoint";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("EndPoint ID"; Rec."EndPoint ID")
                {

                    ToolTip = 'Specifies the endpoint id. Unique, arbitrary, alpha-numeric, value assigned to each BTwentyFour service endpoint.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the service endpoint.';
                    ApplicationArea = NPRRetail;
                }
                field("Next EndPoint ID"; Rec."Next EndPoint ID")
                {

                    ToolTip = 'Specifies the next endpoint id. Unique, arbitrary, alpha-numeric, value assigned to BTwentyFour service endpoint and run after primary EndPoint ID.';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies if the endpoint is enabled. To be able to consume resources, service endpoint has to be enabled.Additionally, automatic sending of web requests will be enabled. For details, refer to action Show Jobs.';
                    ApplicationArea = NPRRetail;
                }
                field("EndPoint-Key"; Rec."EndPoint-Key")
                {

                    ToolTip = 'Specifies the service endpoint key obtained with API credentials. EndPoint-Key is not mandatory for all endpoints.';
                    ApplicationArea = NPRRetail;
                }
                field(Accept; Rec.Accept)
                {

                    ToolTip = 'Specifies response format (e.g. response could be in json or xml format). Change value and check response by running an action Send Request.';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'View BTwentyFour API service endpoint error log entries.';
                Image = ErrorLog;
                Caption = 'Error Log';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.ShowErrorLogEntries(Rec."Service Code", Rec."EndPoint ID");
                end;
            }
            Action(JobQueueEntries)
            {

                ToolTip = 'View list of job queue entries, enabled by BTwentyFour service endpoint.';
                Image = JobLines;
                Caption = 'Show Jobs';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    Rec.TestField(Enabled);
                    ServiceAPI.ShowJobQueueEntries(Rec.RecordId());
                end;
            }
        }
        area(Processing)
        {

            action(DownloadedContent)
            {

                ToolTip = 'Send request and download result for selected service endpoint. Web request will be prepared based on values prepared in Service Setup combined with values from selected service endpoint (path, endpoint-key...).';
                Caption = 'Download Content';
                Image = Web;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                    Response: Codeunit "Temp Blob";
                begin
                    ServiceAPI.ImportContentOnline(Rec, Response);
                end;
            }
            action(ProcessDownloadedContent)
            {

                ToolTip = 'Send request, download result and process downloaded content for selected service endpoint. Web request will be prepared based on values prepared in Service Setup combined with values from selected service endpoint (path, endpoint-key...).';
                Caption = 'Process Downloaded Content';
                Image = Web;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                    Response: Codeunit "Temp Blob";
                begin
                    if ServiceAPI.ImportContentOnline(Rec, Response) then
                        ServiceAPI.ProcessContent(Response, Rec);
                end;
            }
            action(ProcessContentOffline)
            {

                ToolTip = 'Select file and process content for selected service endpoint. File will be imported and web request which indicates that the content has been processed won''t be sent since this is offline mode.';
                Caption = 'Process Content Offline';
                Image = Import;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                    Response: Codeunit "Temp Blob";
                begin
                    ServiceAPI.ImportContentOffline(Rec, Response);
                    ServiceAPI.ProcessContentOffline(Response, Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.OnRegisterServiceEndPoint();
    end;
}
