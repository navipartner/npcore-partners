page 6059920 "NPR BTF Service Setup"
{
    AdditionalSearchTerms = 'btwentyfour omnichannel,b24';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NPR BTF Service Setup";
    Editable = false;
    CardPageId = "NPR BTF Service Setup Card";
    Caption = 'BTwentyFour Service Setup';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
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

                field(Environment; Rec.Environment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies environment, sandbox or production.';
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
                    ServiceEndPoint: Record "NPR BTF Service Endpoint";
                begin
                    ServiceEndPoint.SetRange("Service Code", Rec.Code);
                    Page.Run(0, ServiceEndPoint);
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
                    ServiceAPI.ShowErrorLogEntries(Rec.Code);
                end;
            }
            Action(JobQueueEntries)
            {
                ApplicationArea = All;
                ToolTip = 'View list of job queue entries, enabled by BTwentyFour service.';
                Image = JobLines;
                Caption = 'Show Jobs';
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
                    ServiceEndPoint: Record "NPR BTF Service EndPoint";
                begin
                    Rec.TestField("Authroization EndPoint ID");
                    ServiceEndPoint.Get(Rec.Code, Rec."Authroization EndPoint ID");
                    ServiceAPI.SendRequestAndDownloadResult(ServiceEndPoint);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.OnRegisterService();
    end;
}