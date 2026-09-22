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
                    Page.Run(Page::"NPR Spfy Store Card", SpfyStore);
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
                ToolTip = 'Tries to create the Business Central document again, from the order details that were downloaded from Shopify earlier. Use this after correcting something in Business Central, such as a missing item, currency or posting setup. All log entries of the same Shopify document are processed together, because a closed entry cannot complete while its open counterpart is still pending.';
                ApplicationArea = NPRShopifyEcommerce;
                Image = Process;
                trigger OnAction()
                begin
                    ProcessSelectedEntries();
                end;
            }
            action(GetOrderFromShopify)
            {
                Caption = 'Get Order from Shopify';
                ToolTip = 'Throws away the order details downloaded from Shopify earlier, so the order is downloaded again the next time the document is processed. Use this when the order itself was changed in Shopify after it was imported. Entries that are already processed are left alone - their document exists and nothing would re-read the order - and entries that had run out of retries are given a fresh start.';
                ApplicationArea = NPRShopifyEcommerce;
                Image = Refresh;
                Enabled = _EntryCanBeDownloadedAgain;
                trigger OnAction()
                begin
                    GetSelectedOrdersFromShopify();
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
            actionref(GetOrderFromShopify_Promoted; GetOrderFromShopify) { }
#endif
        }
#endif
    }

#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    var
        _EntryCanBeDownloadedAgain: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        _EntryCanBeDownloadedAgain := Rec."Processing Status" <> Rec."Processing Status"::Processed;
    end;

    local procedure GetSelectedOrdersFromShopify()
    var
        EntriesToDiscard: Record "NPR Spfy Event Log Entry";
        SelectedEntries: Record "NPR Spfy Event Log Entry";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        DiscardedCount: Integer;
        NothingToDownloadMsg: Label 'Nothing to download again: every entry in the selection is already processed.';
        OrderWillBeDownloadedMsg: Label '%1 entries will download their order from Shopify again. Please process the documents.', Comment = '%1 = number of entries';
    begin
        CurrPage.SetSelectionFilter(SelectedEntries);
        SpfyEventLogMgt.ExpandSelectionToSiblings(SelectedEntries, EntriesToDiscard);
        EntriesToDiscard.SetFilter("Processing Status", '<>%1', EntriesToDiscard."Processing Status"::Processed);
        DiscardedCount := SpfyEventLogMgt.DiscardStoredOrderData(EntriesToDiscard);
        if DiscardedCount = 0 then
            Message(NothingToDownloadMsg)
        else
            Message(OrderWillBeDownloadedMsg, DiscardedCount);
        if Rec.Get(Rec."Entry No.") then;
        CurrPage.Update(false);
    end;

    local procedure ProcessSelectedEntries()
    var
        EntriesToProcess: Record "NPR Spfy Event Log Entry";
        SelectedEntries: Record "NPR Spfy Event Log Entry";
        SpfyAPIOrderProcessor: Codeunit "NPR Spfy Event Log DocProcessr";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        PostponedCount: Integer;
        OperationFinishedErrMsg: Label 'Operation completed with Errors.';
        OperationFinishedSuccessMsg: Label 'Operation completed.';
        OperationPostponedMsg: Label 'Operation completed, but %1 of the selected entries could not be imported yet and were postponed. They are waiting for related processing to finish and will be picked up again automatically.', Comment = '%1 = number of postponed entries';
    begin
        CurrPage.SetSelectionFilter(SelectedEntries);
        SpfyEventLogMgt.ExpandSelectionToSiblings(SelectedEntries, EntriesToProcess);

        case true of
            not SpfyAPIOrderProcessor.ProcessLogEntries(EntriesToProcess, PostponedCount):
                Message(OperationFinishedErrMsg);
            PostponedCount > 0:
                Message(OperationPostponedMsg, PostponedCount);
            else
                Message(OperationFinishedSuccessMsg);
        end;

        if Rec.Get(Rec."Entry No.") then;
        CurrPage.Update(false);
    end;
#endif
}
#endif