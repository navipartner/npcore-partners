page 6014495 "NPR Replication Setup Card"
{

    Caption = 'Replication API Setup Card';
    Extensible = true;
    PageType = Card;
    SourceTable = "NPR Replication Service Setup";
    UsageCategory = None;
    ContextSensitiveHelpPage = 'retail/replication/howto/replicationhowto.html';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("API Version"; Rec."API Version")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Setup Code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Setup Name.';
                }
                field("Service URL"; Rec."Service URL")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies the Service Base Url. Ex: https://DNSName:PortNo/bc/api';
                }

                field("External Database"; Rec."External Database")
                {
                    ApplicationArea = NPRRetail;
                    Tooltip = 'Specifies if the company from which we want to import data is in the current database or in an external database.';
                    trigger OnValidate()
                    begin
                        IsExternalDB := Rec."External Database";
                        CurrPage.Update();
                    end;
                }
                group("Local DB Company")
                {
                    Caption = 'Local Database Company';
                    Visible = Not IsExternalDB;
                    field(FromCompany; Rec.FromCompany)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'From Company Name';
                        Tooltip = 'Specifies the From Company Name. A company from the local database can be selected';
                    }

                    field(FromCompanyID; Rec.FromCompanyID)
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'From Company Id';
                        Tooltip = 'Specifies the Id of the local database company.';
                    }

                    field("From Company Tenant"; Rec."From Company Tenant")
                    {
                        ApplicationArea = NPRRetail;
                        Tooltip = 'Specifies the From Company Tenant.';
                    }
                }

                group("External DB Company")
                {
                    Caption = 'External Database Company';
                    Visible = IsExternalDB;

                    field("From Company Name - External"; Rec."From Company Name - External")
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'From Company Name';
                        Tooltip = 'Specifies the From Company Name. A web request is sent and a company from the external database can be selected.';
                        trigger OnAssistEdit()
                        begin
                            Rec.FillExternalCompany();
                        end;
                    }
                    field("From Company Id - External"; Rec."From Company id - External")
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'From Company Id';
                        Tooltip = 'Specifies the Id of the external database company.';
                    }
                    field("From Company Tenant 2"; Rec."From Company Tenant")
                    {
                        ApplicationArea = NPRRetail;
                        Tooltip = 'Specifies the From Company Tenant.';
                    }
                }

                field("Error Notify Email Address"; Rec."Error Notify Email Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Error Notification Email Address';
                }
                group(Authorization)
                {
                    Caption = 'Authorization';
                    field(AuthType; Rec.AuthType)
                    {
                        ApplicationArea = NPRRetail;
                        Tooltip = 'Specifies the Authorization Type.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update();
                        end;
                    }
                    group(BasicAuth)
                    {
                        ShowCaption = false;
                        Visible = IsBasicAuthVisible;
                        field(UserName; Rec.UserName)
                        {
                            ApplicationArea = NPRRetail;
                            Tooltip = 'Specifies the UserName for Basic Authentication.';
                        }
                        field(Password; pw)
                        {
                            ApplicationArea = NPRRetail;
                            Caption = 'Password';
                            Tooltip = 'Specifies the Password for Basic Authentication.';
                            trigger OnValidate()
                            begin
                                if pw <> '' Then
                                    WebServiceAuthHelper.SetApiPassword(pw, Rec."API Password Key")
                                Else begin
                                    if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
                                        WebServiceAuthHelper.RemoveApiPassword(Rec."API Password Key");
                                end;
                            end;
                        }
                    }

                    group(OAuth2)
                    {
                        ShowCaption = false;
                        Visible = IsOAuth2Visible;

                        field("OAuth2 Setup Code"; Rec."OAuth2 Setup Code")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                        }
                    }

                }

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Setup is Enabled. If Disabled system will not execute import for the endpoints related to this Setup.';
                }

            }

            group("Job Queue Setup")
            {
                Caption = 'Job Queue Setup';
                field(JobQueueStartTime; Rec.JobQueueStartTime)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Starting Time';
                    ToolTip = 'Specifies Job Queue Starting Time.';


                }
                field(JobQueueEndTime; Rec.JobQueueEndTime)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Ending Time';
                    ToolTip = 'Specifies Job Queue Ending Time.';
                }
                field(JobQueueMinutesBetweenRun; Rec.JobQueueMinutesBetweenRun)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'No. Of Minutes Between Runs';
                    ToolTip = 'Specifies the minutes between the Job Queue runs.';
                }

                field(JobQueueProcessImportList; Rec.JobQueueProcessImportList)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Add process_import_list param';
                    ToolTip = 'Specifies if the Job Queue will contain the process_import_list parameter.';
                    Visible = false; //temporary hidden as is dangerous to handle chuncks in parallel, so this needs to always be true
                }
            }
            part(Endpoints; "NPR Replication Endpoints")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Endpoints';
                SubPageLink = "Service Code" = field("API Version");
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(CopyEndPoints)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Copy Endpoints';
                Image = CopyGLtoCostBudget;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Copy Endpoints from another Setup so you don''t have to enter manually everything.';
                trigger OnAction()
                begin
                    Rec.CopyEndpointsFromAnotherVersion();
                end;
            }

            action("Run")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Run Import';
                Image = ExecuteBatch;
                ToolTip = 'Run import manually.';

                trigger OnAction()
                var
                    TempJobQueueEntry: Record "Job Queue Entry" temporary;
                    ImportListProcessingCU: Codeunit "NPR Nc Import List Processing";
                    ProcessImportListLbl: Label 'process_import_list', Locked = true;
                    ImportTypeParameterLbl: Label 'import_type', locked = true;

                    StartTime: DateTime;
                    EndTime: DateTime;
                    StrSubStNoText: Label '%1=%2,%3';
                begin
                    StartTime := CurrentDateTime;

                    Rec.TestField(Enabled);
                    TempJobQueueEntry.Init();
                    TempJobQueueEntry."Record ID to Process" := Rec.RecordId;
                    TempJobQueueEntry."Parameter String" := StrSubstNo(StrSubStNoText,
                                        ImportTypeParameterLbl, Rec."API Version",
                                        ProcessImportListLbl);
                    ImportListProcessingCU.Run(TempJobQueueEntry);

                    EndTime := CurrentDateTime;
                    Message('Executed in %1', EndTime - StartTime);
                end;
            }

            action(TestConnection)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Test Connection';
                Image = TestDatabase;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Test connection to the setup database.';


                trigger OnAction()
                begin
                    Rec.TestConnection();
                end;
            }
        }
        area(Navigation)
        {
            Action(JobQueueEntries)
            {
                ApplicationArea = NPRRetail;
                Image = JobLines;
                Caption = 'Show Jobs';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Check existing Job Queue Entries related to this Replication Setup.';

                trigger OnAction()
                var
                    ReplicationAPI: Codeunit "NPR Replication API";
                begin
                    Rec.TestField(Enabled);
                    ReplicationAPI.ShowJobQueueEntries(Rec);
                end;
            }

            action(Errors)
            {
                ApplicationArea = NPRRetail;
                Image = ErrorLog;
                Caption = 'Error Log';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'View error log entries related to this Replication Setup.';

                trigger OnAction()
                var
                    ReplicationAPI: Codeunit "NPR Replication API";
                begin
                    ReplicationAPI.ShowErrorLogEntries(Rec."API Version", '');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
        IsExternalDB := Rec."External Database";
    end;

    trigger OnAfterGetRecord()
    begin
        pw := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            pw := '***';
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
        IsExternalDB := Rec."External Database";
    end;

    var
        [InDataSet]
        pw: Text[200];

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible, IsExternalDB : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
}
