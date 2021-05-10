page 6059922 "NPR BTF Service Setup Card"
{
    UsageCategory = None;
    PageType = Card;
    SourceTable = "NPR BTF Service Setup";
    Caption = 'Service Setup Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service code. Unique, arbitrary, alpha-numeric, value (e.g. BTwentyFour API version).';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service name.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the service is enabled. To be able to consume all resources, service has to be enabled.';
                }
            }
            group(APIDetails)
            {
                Caption = 'API Details';
                field("Service URL"; Rec."Service URL")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the base API path of the BTwentyFour service. The base path used for sending web requests to BTwentyFour Omnichannel.';
                    ExtendedDatatype = URL;
                }
                field("About API"; Rec."About API")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the About API URL.';
                    ExtendedDatatype = URL;
                }

                field(Environment; Rec.Environment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies environment, sandbox or production.';
                }
                field("Subscription-Key"; Rec."Subscription-Key")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies service subscription key.';
                }
                field(Username; Rec.Username)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies API username.';
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies API password.';
                }
                field(Portal; Rec.Portal)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies portal number, only required for production environment.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Endpoints)
            {
                ApplicationArea = All;
                ToolTip = 'View or edit BTwentyFour API service endpoints.';
                Image = LinkWeb;
                Caption = 'Service Endpoints';

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.ShowEndPoints(Rec.Code);
                end;
            }
            action(Errors)
            {
                ApplicationArea = All;
                ToolTip = 'View BTwentyFour API service endpoints error log entries.';
                Image = ErrorLog;
                Caption = 'Error Log';

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.ShowErrorLogEntries(Rec.Code, '');
                end;
            }
            Action(JobQueueEntries)
            {
                ApplicationArea = All;
                ToolTip = 'View list of job queue entries, enabled by BTwentyFour service.';
                Image = JobLines;
                Caption = 'Show Jobs';
                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    Rec.TestField(Enabled);
                    ServiceAPI.ShowJobQueueEntries();
                end;
            }
        }
        area(Processing)
        {
            action(Authorization)
            {
                ApplicationArea = Advanced;
                Caption = 'Authorization';
                ToolTip = 'Check if user, set under the Username, is authorized to access BTwentyFour API services.';
                Image = AuthorizeCreditCard;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                    Response: Codeunit "Temp Blob";
                    ServiceEndPoint: Record "NPR BTF Service EndPoint";
                begin
                    Rec.TestField("Authroization EndPoint ID");
                    ServiceEndPoint.Get(Rec.Code, Rec."Authroization EndPoint ID");
                    ServiceAPI.ImportContentOnline(ServiceEndPoint, Response);
                end;
            }
        }
    }
}
