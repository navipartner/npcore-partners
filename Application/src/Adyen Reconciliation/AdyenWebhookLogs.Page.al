page 6184669 "NPR Adyen Webhook Logs"
{
    ApplicationArea = NPRRetail;
    UsageCategory = History;
    AdditionalSearchTerms = 'adyen logs,adyen webhook logs,webhook logs';
    Caption = 'Adyen Webhook Logs';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR Adyen Webhook Log";
    SourceTableView = sorting("Entry No.") order(descending);
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Entry No.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Creation Date.';
                }
                field(Type; Rec.Type)
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
                    ToolTip = 'Specifies the Error Description.';
                }
                field("Webhook Request Entry No."; Rec."Webhook Request Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Webhook Request Entry No. that the current Log applies to.';
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
        }
    }
}
