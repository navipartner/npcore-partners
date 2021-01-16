page 6059923 "NPR BTF EndPoints Error Log"
{
    UsageCategory = None;
    PageType = List;
    SourceTable = "NPR BTF EndPoint Error Log";
    Caption = 'BTwentyFour EndPoints Error Log';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies entry number. Unique value for each endpoint error log entry.';
                }
                field("Response Note"; Rec."Response Note")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies error description.';
                }
                field("Response File Name"; Rec."Response File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies response file name. File contain. Detailed description of the error. To see file, run an action Show Details';
                }
                field("Service Code"; Rec."Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service code. Unique, arbitrary, alpha-numeric, value (e.g. BTwentyFour API version) assigned to Service Setup entry.';
                }
                field("EndPoint ID"; Rec."EndPoint ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the endpoint id. Unique, arbitrary, alpha-numeric, value assigned to each BTwentyFour service endpoint entry.';
                }
                field(Enabled; Rec."EndPoint Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the endpoint is enabled. To be able to consume resources, service endpoint has to be enabled.';
                }
                field("Service Method Name"; Rec."Service Method Name")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies API service method name';
                }
                field("Service URL"; Rec."Service URL")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the base API path of the BTwentyFour service. The base path used for sending web requests to BTwentyFour Omnichannel.';
                }
                field(Path; Rec.Path)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies API service path from which resource is consumed.';
                }
                field("EndPoint-Key"; Rec."EndPoint-Key")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the service endpoint key obtained with API credentials. EndPoint-Key is not mandatory for all endpoints.';
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
                field("API Username"; Rec."API Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies API username.';
                }
                field("API Password"; Rec."API Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies API password.';
                }
                field(Portal; Rec.Portal)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies portal number, only required for production environment.';
                }
                field("Sent on Date"; Rec."Sent on Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies date and time when web request is sent.';
                }
                field("Sent by User ID"; Rec."Sent by User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who sent web request. Job could initiate web request so in that case user id won''t be populated. For those cases, check out an action Initiate from Record.';
                }
                field("Initiatied From Rec. ID"; Format(Rec."Initiatied From Rec. ID"))
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies record id of the entry which initiated sending web request. If entry is still available, then, to view the details of that entry, run an action Initiate from Record.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(InitiateFromRec)
            {
                ApplicationArea = All;
                Caption = 'Initiate from Record';
                ToolTip = 'View which entry initiate web request sending.';
                Image = ViewDetails;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.ShowWhoInitiateWebReqSending(Rec);
                end;
            }
        }
        area(Processing)
        {
            action(Export)
            {
                ApplicationArea = Advanced;
                Caption = 'Show Details';
                ToolTip = 'Download response content.';
                Image = Export;

                trigger OnAction();
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.DownloadErrorLogResponse(Rec);
                end;
            }
        }
    }
}
