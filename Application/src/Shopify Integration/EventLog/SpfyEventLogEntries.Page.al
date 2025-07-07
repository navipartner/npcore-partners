#if not BC17
page 6184903 "NPR Spfy Event Log Entries"
{
    Extensible = false;
    Caption = 'Shopify Event Log Entries';
    PageType = List;
    SourceTable = "NPR Spfy Event Log Entry";
    UsageCategory = None;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Editable = false;

                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies a unique entry number, assigned by the system to this record according to an automatically maintained number series.';
                    ApplicationArea = NPRShopify;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the event.';
                    ApplicationArea = NPRShopify;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the Shopify store code the event is registered for.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify ID"; Rec."Shopify ID")
                {
                    ToolTip = 'Specifies the unique identifier for the event in Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field("Event Date-Time"; Rec."Event Date-Time")
                {
                    ToolTip = 'Specifies the date and time of the event in Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Registered at';
                    ToolTip = 'Specifies the date and time the event was registered in Business Central.';
                    ApplicationArea = NPRShopify;
                }
                field("Amount (PCY)"; Rec."Amount (PCY)")
                {
                    ToolTip = 'Specifies the amount in the presentment currency.';
                    ApplicationArea = NPRShopify;
                }
                field("Presentment Currency Code"; Rec."Presentment Currency Code")
                {
                    ToolTip = 'Specifies the presentment currency code.';
                    ApplicationArea = NPRShopify;
                }
                field("Amount (SCY)"; Rec."Amount (SCY)")
                {
                    ToolTip = 'Specifies the amount in the store currency.';
                    ApplicationArea = NPRShopify;
                }
                field("Store Currency Code"; Rec."Store Currency Code")
                {
                    ToolTip = 'Specifies the store currency code.';
                    ApplicationArea = NPRShopify;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in the local currency.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(RelatedEntries)
            {
                Caption = 'Related Entries...';
                ToolTip = 'Show related Business Central documents for the current Shopify event log entry.';
                ApplicationArea = NPRShopify;
                Image = Navigate;
#if BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif
                trigger OnAction()
                begin
                    Rec.ShowRelatedEntities();
                end;
            }
        }
#if not (BC18 or BC19 or BC20)
        area(Promoted)
        {
            actionref(RelatedEntries_Promoted; RelatedEntries) { }
        }
#endif
    }
}
#endif