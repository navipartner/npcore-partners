page 6014675 "NPR Endpoint Card"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160801  CASE 234602 Added Query fields
    // NPR5.41/TS  /20180105 CASE 300893 Changed Queries to Query
    // NPR5.42/BR/20170511  CASE 267459 Removed Field "Send when Max. Requests"

    Caption = 'Endpoint Card';
    PageType = Card;
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
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field(Active; Active)
                {
                    ApplicationArea = All;
                }
                field("Max. Requests per Batch"; "Max. Requests per Batch")
                {
                    ApplicationArea = All;
                }
                field("Wait to Send"; "Wait to Send")
                {
                    ApplicationArea = All;
                }
                field("Delete Obsolete Requests"; "Delete Obsolete Requests")
                {
                    ApplicationArea = All;
                }
                field("Delete Sent Requests After"; "Delete Sent Requests After")
                {
                    ApplicationArea = All;
                }
            }
            group(Changes)
            {
                field("Trigger on Modify"; "Trigger on Modify")
                {
                    ApplicationArea = All;
                }
                field("Trigger on Insert"; "Trigger on Insert")
                {
                    ApplicationArea = All;
                }
                field("Trigger on Delete"; "Trigger on Delete")
                {
                    ApplicationArea = All;
                }
                field("Trigger on Rename"; "Trigger on Rename")
                {
                    ApplicationArea = All;
                }
            }
            group(Queries)
            {
                field("Query Name"; "Query Name")
                {
                    ApplicationArea = All;
                }
                field("Max. Requests per Query"; "Max. Requests per Query")
                {
                    ApplicationArea = All;
                }
                field("Allow Query from Database"; "Allow Query from Database")
                {
                    ApplicationArea = All;
                }
                field("Allow Query from Company Name"; "Allow Query from Company Name")
                {
                    ApplicationArea = All;
                }
                field("Allow Query from User ID"; "Allow Query from User ID")
                {
                    ApplicationArea = All;
                }
            }
            part(Control6150625; "NPR Endpoint Filters")
            {
                SubPageLink = "Endpoint Code" = FIELD(Code);
                ApplicationArea=All;
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
                ApplicationArea=All;
            }
            action("Request Batches")
            {
                Caption = 'Request Batches';
                Image = XMLFileGroup;
                RunObject = Page "NPR Endpoint Req. Batch List";
                RunPageLink = "Endpoint Code" = FIELD(Code);
                ApplicationArea=All;
            }
            action("Query")
            {
                Caption = 'Query';
                Image = Questionnaire;
                RunObject = Page "NPR Endpoint Query List";
                RunPageLink = "Endpoint Code" = FIELD(Code);
                RunPageView = SORTING("Endpoint Code", "No.")
                              ORDER(Ascending);
                ApplicationArea=All;
            }
        }
        area(processing)
        {
            action("Send all records as modify")
            {
                Caption = 'Send All Records As Modify';
                Image = BulletList;
                ApplicationArea=All;

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

