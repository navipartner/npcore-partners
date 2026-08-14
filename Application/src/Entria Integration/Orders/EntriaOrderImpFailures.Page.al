#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248222 "NPR Entria Order Imp. Failures"
{
    Caption = 'Entria Order Import Failures';
    PageType = List;
    SourceTable = "NPR Entria Order Imp. Failure";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Editable = false;
    InsertAllowed = false;
    Extensible = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the Entria store the failed order belongs to.';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number of the order that failed to import, if one was assigned.';
                    ApplicationArea = NPRRetail;
                }
                field("Display No."; Rec."Display No.")
                {
                    ToolTip = 'Specifies the Entria display_id of the order that failed to import.';
                    ApplicationArea = NPRRetail;
                }
                field("Order Id"; Rec."Order Id")
                {
                    ToolTip = 'Specifies the Entria order id used to identify and re-fetch the order.';
                    ApplicationArea = NPRRetail;
                }
                field("Order Updated At"; Rec."Order Updated At")
                {
                    ToolTip = 'Specifies the order''s updated_at value from Entria at the time of the failed import.';
                    ApplicationArea = NPRRetail;
                }
                field("Last Error"; Rec."Last Error")
                {
                    ToolTip = 'Specifies the last error encountered while importing this order.';
                    ApplicationArea = NPRRetail;
                }
                field("Retry Count"; Rec."Retry Count")
                {
                    ToolTip = 'Specifies how many times the import of this order has been retried.';
                    ApplicationArea = NPRRetail;
                }
                field("Next Retry At"; Rec."Next Retry At")
                {
                    ToolTip = 'Specifies when this order will be retried next.';
                    ApplicationArea = NPRRetail;
                }
                field(Suppressed; Rec.Suppressed)
                {
                    ToolTip = 'Specifies whether automatic retries for this order have been stopped.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MarkForImport)
            {
                Caption = 'Mark for Import';
                ToolTip = 'Resets the retry budget and marks the order for the import job.';
                ApplicationArea = NPRRetail;
                Image = Restore;

                trigger OnAction()
                begin
                    Rec."Retry Count" := 0;
                    Rec."Next Retry At" := CurrentDateTime();
                    Rec.Suppressed := false;
                    Rec.Modify(true);
                end;
            }
            action(Suppress)
            {
                Caption = 'Suppress';
                ToolTip = 'Stops automatic retries for this order.';
                ApplicationArea = NPRRetail;
                Image = Cancel;
                Visible = not Rec.Suppressed;

                trigger OnAction()
                begin
                    Rec.Suppressed := true;
                    Rec.Modify(true);
                end;
            }
            action(Unsuppress)
            {
                Caption = 'Unsuppress';
                ToolTip = 'Re-enables automatic retries for this order.';
                ApplicationArea = NPRRetail;
                Image = ReOpen;
                Visible = Rec.Suppressed;

                trigger OnAction()
                begin
                    Rec.Suppressed := false;
                    Rec.Modify(true);
                end;
            }
        }
    }
}
#endif
