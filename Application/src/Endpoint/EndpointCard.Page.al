page 6014675 "NPR Endpoint Card"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160801  CASE 234602 Added Query fields
    // NPR5.41/TS  /20180105 CASE 300893 Changed Queries to Query
    // NPR5.42/BR/20170511  CASE 267459 Removed Field "Send when Max. Requests"

    Caption = 'Endpoint Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Endpoint";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Active field';
                }
                field("Max. Requests per Batch"; "Max. Requests per Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Requests per Batch field';
                }
                field("Wait to Send"; "Wait to Send")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Wait to Send field';
                }
                field("Delete Obsolete Requests"; "Delete Obsolete Requests")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Obsolete Requests field';
                }
                field("Delete Sent Requests After"; "Delete Sent Requests After")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Sent Requests After field';
                }
            }
            group(Changes)
            {
                field("Trigger on Modify"; "Trigger on Modify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify field';
                }
                field("Trigger on Insert"; "Trigger on Insert")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insert field';
                }
                field("Trigger on Delete"; "Trigger on Delete")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete field';
                }
                field("Trigger on Rename"; "Trigger on Rename")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rename field';
                }
            }
            group(Queries)
            {
                field("Query Name"; "Query Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Query Name field';
                }
                field("Max. Requests per Query"; "Max. Requests per Query")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Requests per Query field';
                }
                field("Allow Query from Database"; "Allow Query from Database")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Query from Database field';
                }
                field("Allow Query from Company Name"; "Allow Query from Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Query from Company Name field';
                }
                field("Allow Query from User ID"; "Allow Query from User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Query from User ID field';
                }
            }
            part(Control6150625; "NPR Endpoint Filters")
            {
                SubPageLink = "Endpoint Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Requests)
            {
                Caption = 'Requests';
                Image = XMLFile;
                RunObject = Page "NPR Endpoint Request List";
                RunPageLink = "Endpoint Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Requests action';
            }
            action("Request Batches")
            {
                Caption = 'Request Batches';
                Image = XMLFileGroup;
                RunObject = Page "NPR Endpoint Req. Batch List";
                RunPageLink = "Endpoint Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Request Batches action';
            }
            action("Query")
            {
                Caption = 'Query';
                Image = Questionnaire;
                RunObject = Page "NPR Endpoint Query List";
                RunPageLink = "Endpoint Code" = FIELD(Code);
                RunPageView = SORTING("Endpoint Code", "No.")
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Query action';
            }
        }
        area(processing)
        {
            action("Send all records as modify")
            {
                Caption = 'Send All Records As Modify';
                Image = BulletList;
                ApplicationArea = All;
                ToolTip = 'Executes the Send All Records As Modify action';

                trigger OnAction()
                begin
                    EndpointManagement.CreateModifyRequests(Rec);
                end;
            }
        }
    }

    var
        EndpointManagement: Codeunit "NPR Endpoint Management";
}

