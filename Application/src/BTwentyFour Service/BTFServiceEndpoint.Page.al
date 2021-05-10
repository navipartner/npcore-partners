page 6059924 "NPR BTF Service Endpoint"
{
    UsageCategory = None;
    PageType = Card;
    SourceTable = "NPR BTF Service EndPoint";
    Caption = 'BTwentyFour Service EndPoint';
    DelayedInsert = true;
    DataCaptionFields = "Service Code";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("EndPoint Method"; Rec."EndPoint Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the endpoint method.';
                }
                field("Next EndPoint ID"; Rec."Next EndPoint ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the next endpoint id. Unique, arbitrary, alpha-numeric, value assigned to BTwentyFour service endpoint and run after primary EndPoint ID.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the endpoint is enabled. To be able to consume resources, service endpoint has to be enabled. Additionally, automatic sending of web requests will be enabled. For details, refer to action Show Jobs.';
                }
                field("Sequence Order"; Rec."Sequence Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the sequence order.';
                }
            }
            group(APIDetails)
            {
                Caption = 'API Details';

                field("BTF Service Method"; Rec."Service Method Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service method name.';
                }
                field(Path; Rec.Path)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the API resource path.';
                }
                field("EndPoint-Key"; Rec."EndPoint-Key")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the endpoint key.';
                }
                field(Accept; Rec.Accept)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the type of content returned by service endpoint.';
                }
                field("Content-Type"; Rec."Content-Type")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the type of content which will be sent to the service endpoint.';
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
                    ServiceAPI.ShowErrorLogEntries(Rec."Service Code", Rec."EndPoint ID");
                end;
            }
            Action(JobQueueEntries)
            {
                ApplicationArea = All;
                ToolTip = 'View list of job queue entries, enabled by BTwentyFour service endpoint.';
                Image = JobLines;
                Caption = 'Show Jobs';

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
                ApplicationArea = Advanced;
                ToolTip = 'Send request and download result for selected service endpoint. Web request will be prepared based on values prepared in Service Setup combined with values from selected service endpoint (path, endpoint-key...).';
                Caption = 'Download Content';
                Image = Web;

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
                ApplicationArea = Advanced;
                ToolTip = 'Send request, download result and process downloaded content for selected service endpoint. Web request will be prepared based on values prepared in Service Setup combined with values from selected service endpoint (path, endpoint-key...).';
                Caption = 'Process Downloaded Content';
                Image = Web;

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
                ApplicationArea = Advanced;
                ToolTip = 'Select file and process content for selected service endpoint. File will be imported and web request which indicates that the content has been processed won''t be sent since this is offline mode.';
                Caption = 'Process Content Offline';
                Image = Import;

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
}