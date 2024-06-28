page 6184665 "NPR Adyen Webhooks"
{
    Extensible = false;

    UsageCategory = History;
    ApplicationArea = NPRRetail;
    Caption = 'Adyen Webhook Requests';
    PageType = List;
    Editable = false;
    SourceTable = "NPR Adyen Webhook";
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Created Date"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Entry Creation Date and Time.';
                }
                field("Event Date"; Rec."Event Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Event Date and Time.';
                }
                field("Processed Date"; Rec."Processed Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Processed Date and Time.';
                }
                field("Event Code"; Rec."Event Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Event Code.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Status of the Webhook Request.';
                }
                field("Merchant Account Name"; Rec."Merchant Account Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Merchant Account Name.';
                }
                field(Success; Rec.Success)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Event was successful.';
                }
                field("PSP Reference"; Rec."PSP Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Event''s PSP Reference.';
                }
                field(Live; Rec.Live)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the Event was initiated by a Live environment.';
                }
                field("Webhook Has Data"; _WebhookHasData)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Webhook has Data';
                    ToolTip = 'Speficies if the Webhook has Data.';
                }
                field("Webhook Reference"; Rec."Webhook Reference")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Reference ID.';
                }
            }
        }
        area(factboxes)
        {
            part(AdyenRequestData; "NPR Adyen WH Request Factbox")
            {
                ApplicationArea = NPRRetail;
                Editable = false;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Cancel)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Cancel';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Cancel;
                ToolTip = 'Running this action will set the Status to ''Cancel''.';

                trigger OnAction()
                var
                    AdyenWebhook: Record "NPR Adyen Webhook";
                    ConfirmCancelationLbl: Label 'This will cancel the selected Webhook/Webhooks further processing.\\Do you wish to proceed?';
                begin
                    CurrPage.SetSelectionFilter(AdyenWebhook);
                    AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
                    if AdyenWebhook.IsEmpty() then
                        exit;
                    if not Confirm(ConfirmCancelationLbl) then
                        exit;
                    AdyenWebhook.ModifyAll(Status, AdyenWebhook.Status::Canceled);
                    CurrPage.Update(false);
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
                    Logs: Record "NPR Adyen Webhook Log";
                begin
                    Logs.FilterGroup(2);
                    Logs.SetRange("Webhook Request Entry No.", Rec."Entry No.");
                    Logs.FilterGroup(0);
                    Page.Run(Page::"NPR Adyen Webhook Logs", Logs);
                end;
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

    trigger OnAfterGetRecord()
    begin
        _WebhookHasData := Rec."Webhook Data".HasValue();
    end;

    var
        _WebhookHasData: Boolean;
}
