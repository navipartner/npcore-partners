page 6184519 "NPR AF Rec. Webhook Requests"
{
    Extensible = false;

    UsageCategory = History;
    ApplicationArea = NPRRetail;
    Caption = 'Adyen Reconciliation Webhook Requests';
    PromotedActionCategories = 'New,Process,Report,Create Reconciliation Document';
    PageType = List;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    SourceTable = "NPR AF Rec. Webhook Request";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Request ID.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Request Creation Date.';
                }
                field("Report Type"; Rec."Report Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Report Type.';
                }
                field("Report Name"; Rec."Report Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Report Name.';
                }
                field("Status Code"; Rec."Status Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Request Status Code.';
                }
                field("Status Description"; Rec."Status Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Request Status Description.';
                }
                field(Live; Rec.Live)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Request is initiated in Live.';
                }
                field("Report Download URL"; Rec."Report Download URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Report Download URL.';
                }
                field("PSP Reference"; Rec."PSP Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the PSP Reference.';
                }
            }
        }
        area(factboxes)
        {
            part(ARRequestData; "NPR Adyen WH Request Factbox")
            {
                ApplicationArea = NPRRetail;
                Editable = false;
                SubPageLink = ID = field("ID");
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Show Logs")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show Logs';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Log;
                ToolTip = 'Running this action will show Logs.';

                trigger OnAction()
                var
                    Logs: Record "NPR Adyen Reconciliation Log";
                begin
                    Logs.FilterGroup(0);
                    Logs.SetRange("Webhook Request ID", Rec.ID);
                    Logs.SetCurrentKey(ID);
                    Logs.Ascending(false);
                    Logs.FilterGroup(2);
                    Page.Run(Page::"NPR Adyen Reconciliation Logs", Logs);
                end;
            }
        }
        area(Processing)
        {
            action("Import Report by Name")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Import Report by Name';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Import;
                ToolTip = 'Running this action will try to import a Report by it''s name.';

                trigger OnAction()
                var
                    AdyenSimulateWebhookRequest: Report "NPR Adyen Simulate Webhook Req";
                    ReportName: Text[100];
                    EmptyNameError01: Label 'Please specify a Report Name!';
                begin
                    ReportName := AdyenSimulateWebhookRequest.RequestReportName();
                    if ReportName <> '' then
                        _AdyenManagement.SimulateWebhookRequest(ReportName)
                    else
                        Error(EmptyNameError01);
                end;
            }
            group("Create Reconciliation Document")
            {
                Caption = 'Create Reconciliation Document';

                action("From Request")
                {
                    ApplicationArea = NPRRetail;
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Caption = 'From Request';
                    ToolTip = 'Running this action will try to create a Reconciliation Document from the current Webhook Request Data.';

                    trigger OnAction()
                    var
                        WebhookRequest: Record "NPR AF Rec. Webhook Request";
                    begin
                        WebhookRequest := Rec;
                        _AdyenManagement.CreateDocumentFromWebhookRequest(WebhookRequest);
                    end;
                }
                action("From File")
                {
                    ApplicationArea = NPRRetail;
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Caption = 'From File';
                    ToolTip = 'Running this action will try to create a Reconciliation Document from the File.';

                    trigger OnAction()
                    begin
                        _AdyenManagement.CreateDocumentFromFile();
                    end;
                }
            }
        }
    }

    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
}
