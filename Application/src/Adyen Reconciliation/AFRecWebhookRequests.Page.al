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
    SourceTableView = sorting(ID) order(descending);

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
                field("Adyen Webhook Entry No."; Rec."Adyen Webhook Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Adyen Webhook Entry No.';
                }
            }
        }
        area(factboxes)
        {
            part(ReportData; "NPR Adyen WH Report Factbox")
            {
                ApplicationArea = NPRRetail;
                Editable = false;
                SubPageLink = ID = field(ID);
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Show Adyen Webhook Entry")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show Adyen Webhook Entry';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Log;
                ToolTip = 'Running this action will show Adyen Webhook Entry.';

                trigger OnAction()
                var
                    Entry: Record "NPR Adyen Webhook";
                begin
                    Entry.FilterGroup(0);
                    Entry.SetRange("Entry No.", Rec."Adyen Webhook Entry No.");
                    Entry.FilterGroup(2);
                    Page.Run(Page::"NPR Adyen Webhooks", Entry);
                end;
            }
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
                        InvalidFileType: Label 'Invalid File Type.\The file you attempted to make a Reconciliation Document from is not a valid format. The file must be in .CSV format.\\Please update your Report Generation configurations in Adyen Customer Area.';
                        WebhookRequest: Record "NPR AF Rec. Webhook Request";
                    begin
                        WebhookRequest := Rec;
                        if WebhookRequest."Report Name" = '' then
                            Error(InvalidReportName);
                        if not WebhookRequest."Report Name".Contains('.csv') then
                            Error(InvalidFileType);
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
                action("Import Report by Name")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Import Report by Name';
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Import;
                    ToolTip = 'Running this action will try to import a Report by it''s name.';

                    trigger OnAction()
                    var
                        AdyenSimulateWebhookRequest: Report "NPR Adyen Simulate Webhook Req";
                        ReportName: Text[100];
                        InvalidFileType: Label 'Invalid File Type.\The file you attempted to upload is not a valid format. Please upload a file in .CSV format.';
                    begin
                        ReportName := AdyenSimulateWebhookRequest.RequestReportName();
                        if ReportName = '' then
                            Error(InvalidReportName);
                        if not ReportName.Contains('.csv') then
                            Error(InvalidFileType);
                        if ReportName <> '' then
                            _AdyenManagement.EmulateWebhookRequest(ReportName);
                    end;
                }
            }
            action(Refresh)
            {
                Caption = 'Refresh';
                ApplicationArea = NPRRetail;
                Image = Refresh;
                ToolTip = 'Running this action will Refresh the page.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    RefreshingLbl: Label 'Refreshing...';
                    Window: Dialog;
                begin
                    Window.Open(RefreshingLbl);
                    CurrPage.Update();
                    Window.Close();
                end;
            }
        }
    }

    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
        InvalidReportName: Label 'Report name is blank.';
}
