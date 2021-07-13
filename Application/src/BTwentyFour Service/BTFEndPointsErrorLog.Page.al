page 6059923 "NPR BTF EndPoints Error Log"
{
    UsageCategory = None;
    PageType = List;
    SourceTable = "NPR BTF EndPoint Error Log";
    SourceTableView = sorting("Entry No.") order(descending);
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

                    ToolTip = 'Specifies entry number. Unique value for each endpoint error log entry.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Sent on Date"; Rec."Sent on Date")
                {

                    ToolTip = 'Specifies date and time when web request is sent.';
                    ApplicationArea = NPRRetail;
                }
                field("Response Note"; Rec."Response Note")
                {

                    ToolTip = 'Specifies error description.';
                    ApplicationArea = NPRRetail;
                }
                field("Response File Name"; Rec."Response File Name")
                {

                    ToolTip = 'Specifies response file name. File contain. Detailed description of the error. To see file, run an action Show Details';
                    ApplicationArea = NPRRetail;
                }
                field("Service Code"; Rec."Service Code")
                {

                    ToolTip = 'Specifies the service code. Unique, arbitrary, alpha-numeric, value (e.g. BTwentyFour API version) assigned to Service Setup entry.';
                    ApplicationArea = NPRRetail;
                }
                field("EndPoint ID"; Rec."EndPoint ID")
                {

                    ToolTip = 'Specifies the endpoint id. Unique, arbitrary, alpha-numeric, value assigned to each BTwentyFour service endpoint entry.';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec."EndPoint Enabled")
                {

                    ToolTip = 'Specifies if the endpoint is enabled. To be able to consume resources, service endpoint has to be enabled.';
                    ApplicationArea = NPRRetail;
                }
                field("Service Method Name"; Rec."Service Method Name")
                {

                    ToolTip = 'Specifies API service method name';
                    ApplicationArea = NPRRetail;
                }
                field("Service URL"; Rec."Service URL")
                {

                    ToolTip = 'Specifies the base API path of the BTwentyFour service. The base path used for sending web requests to BTwentyFour Omnichannel.';
                    ApplicationArea = NPRRetail;
                }
                field(Path; Rec.Path)
                {

                    ToolTip = 'Specifies API service path from which resource is consumed.';
                    ApplicationArea = NPRRetail;
                }
                field("EndPoint-Key"; Rec."EndPoint-Key")
                {

                    ToolTip = 'Specifies the service endpoint key obtained with API credentials. EndPoint-Key is not mandatory for all endpoints.';
                    ApplicationArea = NPRRetail;
                }
                field(Environment; Rec.Environment)
                {

                    ToolTip = 'Specifies environment, sandbox or production.';
                    ApplicationArea = NPRRetail;
                }
                field("Subscription-Key"; Rec."Subscription-Key")
                {

                    ToolTip = 'Specifies service subscription key.';
                    ApplicationArea = NPRRetail;
                }
                field("API Username"; Rec."API Username")
                {

                    ToolTip = 'Specifies API username.';
                    ApplicationArea = NPRRetail;
                }
                field("API Password"; Rec."API Password")
                {

                    ToolTip = 'Specifies API password.';
                    ApplicationArea = NPRRetail;
                }
                field(Portal; Rec.Portal)
                {

                    ToolTip = 'Specifies portal number, only required for production environment.';
                    ApplicationArea = NPRRetail;
                }
                field("Sent by User ID"; Rec."Sent by User ID")
                {

                    ToolTip = 'Specifies who sent web request. Job could initiate web request so in that case user id won''t be populated. For those cases, check out an action Initiate from Record.';
                    ApplicationArea = NPRRetail;
                }
                field("Initiatied From Rec. ID"; Format(Rec."Initiatied From Rec. ID"))
                {

                    Caption = 'Initiatied From Rec. ID';
                    ToolTip = 'Specifies record id of the entry which initiated sending web request. If entry is still available, then, to view the details of that entry, run an action Initiate from Record.';
                    ApplicationArea = NPRRetail;
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

                Caption = 'Initiate from Record';
                ToolTip = 'View which entry initiate web request sending.';
                Image = ViewDetails;
                ApplicationArea = NPRRetail;

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

                Caption = 'Show Details';
                ToolTip = 'Download response content.';
                Image = Export;
                ApplicationArea = NPRRetail;

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
