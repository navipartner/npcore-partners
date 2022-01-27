page 6014675 "NPR Endpoint Card"
{
    Extensible = False;
    // NPR5.23\BR\20160518  CASE 237658 Object created
    // NPR5.25\BR\20160801  CASE 234602 Added Query fields
    // NPR5.41/TS  /20180105 CASE 300893 Changed Queries to Query
    // NPR5.42/BR/20170511  CASE 267459 Removed Field "Send when Max. Requests"

    Caption = 'Endpoint Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR Endpoint";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Requests per Batch"; Rec."Max. Requests per Batch")
                {

                    ToolTip = 'Specifies the value of the Max. Requests per Batch field';
                    ApplicationArea = NPRRetail;
                }
                field("Wait to Send"; Rec."Wait to Send")
                {

                    ToolTip = 'Specifies the value of the Wait to Send field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Obsolete Requests"; Rec."Delete Obsolete Requests")
                {

                    ToolTip = 'Specifies the value of the Delete Obsolete Requests field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Sent Requests After"; Rec."Delete Sent Requests After")
                {

                    ToolTip = 'Specifies the value of the Delete Sent Requests After field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Changes)
            {
                field("Trigger on Modify"; Rec."Trigger on Modify")
                {

                    ToolTip = 'Specifies the value of the Modify field';
                    ApplicationArea = NPRRetail;
                }
                field("Trigger on Insert"; Rec."Trigger on Insert")
                {

                    ToolTip = 'Specifies the value of the Insert field';
                    ApplicationArea = NPRRetail;
                }
                field("Trigger on Delete"; Rec."Trigger on Delete")
                {

                    ToolTip = 'Specifies the value of the Delete field';
                    ApplicationArea = NPRRetail;
                }
                field("Trigger on Rename"; Rec."Trigger on Rename")
                {

                    ToolTip = 'Specifies the value of the Rename field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Queries)
            {
                field("Query Name"; Rec."Query Name")
                {

                    ToolTip = 'Specifies the value of the Query Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Requests per Query"; Rec."Max. Requests per Query")
                {

                    ToolTip = 'Specifies the value of the Max. Requests per Query field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Query from Database"; Rec."Allow Query from Database")
                {

                    ToolTip = 'Specifies the value of the Allow Query from Database field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Query from Company Name"; Rec."Allow Query from Company Name")
                {

                    ToolTip = 'Specifies the value of the Allow Query from Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Query from User ID"; Rec."Allow Query from User ID")
                {

                    ToolTip = 'Specifies the value of the Allow Query from User ID field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6150625; "NPR Endpoint Filters")
            {
                SubPageLink = "Endpoint Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Requests action';
                ApplicationArea = NPRRetail;
            }
            action("Request Batches")
            {
                Caption = 'Request Batches';
                Image = XMLFileGroup;
                RunObject = Page "NPR Endpoint Req. Batch List";
                RunPageLink = "Endpoint Code" = FIELD(Code);

                ToolTip = 'Executes the Request Batches action';
                ApplicationArea = NPRRetail;
            }
            action("Query")
            {
                Caption = 'Query';
                Image = Questionnaire;
                RunObject = Page "NPR Endpoint Query List";
                RunPageLink = "Endpoint Code" = FIELD(Code);
                RunPageView = SORTING("Endpoint Code", "No.")
                              ORDER(Ascending);

                ToolTip = 'Executes the Query action';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {
            action("Send all records as modify")
            {
                Caption = 'Send All Records As Modify';
                Image = BulletList;

                ToolTip = 'Executes the Send All Records As Modify action';
                ApplicationArea = NPRRetail;

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

