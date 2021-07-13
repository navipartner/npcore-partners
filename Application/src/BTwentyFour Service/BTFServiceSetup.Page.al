page 6059920 "NPR BTF Service Setup"
{
    AdditionalSearchTerms = 'btwentyfour omnichannel,b24';
    PageType = List;

    UsageCategory = Administration;
    SourceTable = "NPR BTF Service Setup";
    Editable = false;
    CardPageId = "NPR BTF Service Setup Card";
    Caption = 'BTwentyFour Service Setup';
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Rec.Code)
                {

                    ToolTip = 'Specifies the service code. Unique, arbitrary, alpha-numeric, value (e.g. BTwentyFour API version).';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the service name.';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies if the service is enabled. To be able to consume all resources, service has to be enabled.';
                    ApplicationArea = NPRRetail;
                }

                field(Environment; Rec.Environment)
                {

                    ToolTip = 'Specifies environment, sandbox or production.';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'View or edit BTwentyFour API service endpoints.';
                Image = LinkWeb;
                Caption = 'Service Endpoints';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.ShowEndPoints(Rec.Code);
                end;
            }
            action(Errors)
            {

                ToolTip = 'View BTwentyFour API service endpoints error log entries.';
                Image = ErrorLog;
                Caption = 'Error Log';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ServiceAPI: Codeunit "NPR BTF Service API";
                begin
                    ServiceAPI.ShowErrorLogEntries(Rec.Code, '');
                end;
            }
            Action(JobQueueEntries)
            {

                ToolTip = 'View list of job queue entries, enabled by BTwentyFour service.';
                Image = JobLines;
                Caption = 'Show Jobs';
                ApplicationArea = NPRRetail;

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

                Caption = 'Authorization';
                ToolTip = 'Check if user, set under the Username, is authorized to access BTwentyFour API services.';
                Image = AuthorizeCreditCard;
                ApplicationArea = NPRRetail;

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

    trigger OnOpenPage()
    begin
        Rec.OnRegisterService();
    end;
}