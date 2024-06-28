page 6184536 "NPR Adyen Reconciliation Logs"
{
    ApplicationArea = NPRRetail;
    UsageCategory = History;
    AdditionalSearchTerms = 'adyen logs,adyen reconciliaiton logs,reconciliation logs';
    Caption = 'Adyen Reconciliation Logs';
    RefreshOnActivate = true;
    PageType = List;
    SourceTable = "NPR Adyen Reconciliation Log";
    SourceTableView = sorting(ID) order(descending);
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Log ID.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Log Creation Date.';
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Log Type.';
                }
                field(Success; Rec.Success)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the log entry was successful.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Log Description.';
                }
                field("Webhook Request ID"; Rec."Webhook Request ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the related Webhook Request ID.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
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
            action("Show Description")
            {
                Caption = 'Show Description';
                ApplicationArea = NPRRetail;
                Image = ErrorLog;
                ToolTip = 'Running this action will Show the full Description of the current Log Entry.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    if Rec.Description <> '' then
                        Message(Rec.Description);
                end;
            }
            action("Show Valid Report Scheme")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show valid Report Scheme';
                Image = LinkWeb;
                ToolTip = 'Running this action will open Open Valid Report Scheme Picture.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    AdyenGenericSetup: Record "NPR Adyen Setup";
                    ReportSchemeURL: Label 'https://docs.navipartner.com/docs/', Locked = true; // TODO
                begin
                    if AdyenGenericSetup.Get() then
                        Hyperlink(ReportSchemeURL);
                end;
            }
        }
    }
}
