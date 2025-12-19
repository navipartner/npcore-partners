#if not BC17
page 6184903 "NPR Spfy Event Log Entries"
{
    Extensible = false;
    Caption = 'Shopify Event Log Entries';
    PageType = List;
    SourceTable = "NPR Spfy Event Log Entry";
    UsageCategory = Lists;
    Editable = false;
    ApplicationArea = NPRShopify;
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
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the Document Type.';
                    ApplicationArea = NPRShopifyEcommerce;
                }
                field("Document Name"; Rec."Document Name")
                {
                    ToolTip = 'Specifies the Document Name assigned in Shopify.';
                    ApplicationArea = NPRShopifyEcommerce;
                }
#endif
                field("Registered At"; Rec.SystemCreatedAt)
                {
                    Caption = 'Registered At';
                    ToolTip = 'Specifies the date and time the event was registered in Business Central.';
                    ApplicationArea = NPRShopify;
                }
                field("Event Date-Time"; Rec."Event Date-Time")
                {
                    ToolTip = 'Specifies the date and time of the event in Shopify.';
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
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                field("Processing Status"; Rec."Processing Status")
                {
                    ToolTip = 'Specifies the Processing Status of Event Log Entry.';
                    ApplicationArea = NPRShopifyEcommerce;
                }
                field("Document Status"; Rec."Document Status")
                {
                    ToolTip = 'Specified whether the document is open, closed, or cancelled in Shopify.';
                    ApplicationArea = NPRShopifyEcommerce;
                }
                field("Last Error Message"; Rec."Last Error Message")
                {
                    ToolTip = 'Specifies the last error message that occurred during processing.';
                    ApplicationArea = NPRShopifyEcommerce;
                }
#endif
            }
        }
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        area(factboxes)
        {
            part(LogEntryFactBox; "NPR Spfy Event Log FactBox")
            {
                Caption = 'Processing Information';
                ApplicationArea = NPRShopifyEcommerce;
                SubPageLink = "Entry No." = field("Entry No.");
                UpdatePropagation = Both;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = NPRShopifyEcommerce;
            }
        }
#endif
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
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
            action(Store)
            {
                Caption = 'Shopify Store';
                ToolTip = 'Show related Shopify Store.';
                ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                Image = Navigate;
                trigger OnAction()
                var
                    SpfyStore: Record "NPR Spfy Store";
                begin
                    SpfyStore.SetRange(Code, Rec."Store Code");
                    Page.Run(0, SpfyStore);
                end;
            }
#endif
        }
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        area(Processing)
        {
            action(ProcessLogEntries)
            {
                Caption = 'Process Document';
                ToolTip = 'Processes Shopify event log entries with error status, attempting to create or update the corresponding Business Central documents based on the information in the log entries.';
                ApplicationArea = NPRShopifyEcommerce;
                Image = Process;
                trigger OnAction()
                var
                    SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
                    SpfyAPIOrderProcessor: Codeunit "NPR Spfy Event Log DocProcessr";
                    OperationFinishedErrMsg: Label 'Operation completed with Errors.';
                    OperationFinishedSuccessMsg: Label 'Operation completed.';
                begin
                    CurrPage.SetSelectionFilter(SpfyEventLogEntry);
                    if SpfyAPIOrderProcessor.ProcessLogEntries(SpfyEventLogEntry) then
                        Message(OperationFinishedSuccessMsg)
                    else
                        Message(OperationFinishedErrMsg);
                    CurrPage.Update(false);
                end;
            }
            action(ResetRetryCount)
            {
                Caption = 'Reset Retry Count';
                ToolTip = 'Reset Retry Count to zero.';
                ApplicationArea = NPRShopifyEcommerce;
                Image = Restore;
                trigger OnAction()
                var
                    SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
                    SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
                    OperationFinishedSuccessMsg: Label 'Operation completed successfully.';
                begin
                    CurrPage.SetSelectionFilter(SpfyEventLogEntry);
                    SpfyEventLogEntry.Setfilter("Process Retry Count", '>=%1', SpfyIntegrationMgt.GetMaxDocRetryCount());
                    SpfyEventLogEntry.ModifyAll("Process Retry Count", 0);
                    Message(OperationFinishedSuccessMsg);
                    CurrPage.Update(false);
                end;
            }
        }
#endif
#if not (BC18 or BC19 or BC20)
        area(Promoted)
        {
            actionref(RelatedEntries_Promoted; RelatedEntries) { }
#if not BC21 and not BC22
            actionref(ProcessLogEntries_Promoted; ProcessLogEntries) { }
#endif
        }
#endif
    }
}
#endif