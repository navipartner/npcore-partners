page 6184519 "NPR AF Rec. Webhook Requests"
{
    Extensible = false;
    UsageCategory = History;
    ApplicationArea = NPRRetail;
    Caption = 'NP Pay Reconciliation Reports';
    PromotedActionCategories = 'New,Process,Report,Create Reconciliation Document';
    PageType = List;
    RefreshOnActivate = true;
    Editable = false;
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
                field("Creation Date"; Rec.SystemCreatedAt)
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
                    ToolTip = 'Specifies the NP Pay Webhook Entry No.';
                }
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
                Caption = 'Show NP Pay Webhook Entry';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Log;
                ToolTip = 'Running this action will show NP Pay Webhook Entry.';

                trigger OnAction()
                var
                    Entry: Record "NPR Adyen Webhook";
                begin
                    Entry.FilterGroup(2);
                    Entry.SetRange("Entry No.", Rec."Adyen Webhook Entry No.");
                    Entry.FilterGroup(0);
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
                begin
                    _AdyenManagement.OpenReconciliationLogs(Rec);
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
                        InvalidFileType: Label 'Invalid File Type.\The file you attempted to make a Reconciliation Document from is not a valid format. The file must be in .XLSX format.\\Please update your Report Generation configurations in NP Pay Customer Area.';
                        WebhookRequest: Record "NPR AF Rec. Webhook Request";
                    begin
                        WebhookRequest := Rec;
                        if WebhookRequest."Report Name" = '' then
                            Error(InvalidReportName);
                        if not WebhookRequest."Report Name".Contains('.xlsx') then
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
                        MerchantAccount: Text[80];
                        Live: Boolean;
                        InvalidFileType: Label 'Invalid File Type.\The file you attempted to upload is not a valid format. Please upload a file in .XLSX format.';
                        InvalidMerchantAccount: Label 'Merchant Account is blank.';
                        ReportDetails: Text;
                        WebhookRequest: Record "NPR AF Rec. Webhook Request";
                    begin
                        ReportDetails := AdyenSimulateWebhookRequest.RequestReportName();
                        if ReportDetails <> '' then begin
                            ReportName := CopyStr(ReportDetails.Split('|').Get(1), 1, 100);
                            MerchantAccount := CopyStr(ReportDetails.Split('|').Get(2), 1, 80);
                            if Evaluate(Live, ReportDetails.Split('|').Get(3)) then;
                        end;
                        if ReportName = '' then
                            Error(InvalidReportName);
                        if not ReportName.Contains('.xlsx') then
                            Error(InvalidFileType);
                        if MerchantAccount = '' then
                            Error(InvalidMerchantAccount);
                        if (ReportName <> '') and (MerchantAccount <> '') then begin
                            _AdyenManagement.EmulateWebhookRequest(ReportName, MerchantAccount, Live, WebhookRequest);
                            _AdyenManagement.CreateDocumentFromWebhookRequest(WebhookRequest);
                        end;

                        CurrPage.Update(false);
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
                    CurrPage.Update(false);
                    Window.Close();
                end;
            }
        }
    }

    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
        InvalidReportName: Label 'Report name is blank.';
}
