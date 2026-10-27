page 6184903 "NPR Spfy Event Log Entries"
{
    Extensible = false;
    Caption = 'Shopify Event Log Entries';
    PageType = List;
    SourceTable = "NPR Spfy Event Log Entry";
    UsageCategory = Lists;
    Editable = false;
    ApplicationArea = NPRShopify;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                FreezeColumn = "Document Name";
                Editable = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies a unique entry number, assigned by the system to this record according to an automatically maintained number series.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
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
                field("Event Date-Time"; Rec."Event Date-Time")
                {
                    ToolTip = 'Specifies the date and time of the event in Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field("Document Status"; Rec."Document Status")
                {
                    ToolTip = 'Specifies whether the document is open, closed, or cancelled in Shopify.';
                    ApplicationArea = NPRShopifyEcommerce;
                    StyleExpr = _DocStatusStyle;
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ToolTip = 'Specifies the Processing Status of Event Log Entry.';
                    ApplicationArea = NPRShopifyEcommerce;
                    StyleExpr = _ProcStatusStyle;
                }
                field("Shopify ID"; Rec."Shopify ID")
                {
                    ToolTip = 'Specifies the unique identifier for the event in Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the Shopify store code the event is registered for.';
                    ApplicationArea = NPRShopify;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the event.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Last Error Message"; Rec."Last Error Message")
                {
                    ToolTip = 'Specifies the last error message that occurred during processing.';
                    ApplicationArea = NPRShopifyEcommerce;
                    StyleExpr = _ErrorStyle;
                    Width = 40;
                    Visible = false;
                }
                field("Process Retry Count"; Rec."Process Retry Count")
                {
                    ToolTip = 'Specifies how many times processing of this entry has been retried.';
                    ApplicationArea = NPRShopifyEcommerce;
                    StyleExpr = _ProcStatusStyle;
                    Visible = false;
                }
                field("Bucket Id"; Rec."Bucket Id")
                {
                    ToolTip = 'Specifies the bucket identifier assigned when the event log entry is created. It is used by Job Queues to group and process entries.';
                    ApplicationArea = NPRShopifyEcommerce;
                    Visible = false;
                }
                field("Registered At"; Rec.SystemCreatedAt)
                {
                    Caption = 'Registered At';
                    ToolTip = 'Specifies the date and time the event was registered in Business Central.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Amount (PCY)"; Rec."Amount (PCY)")
                {
                    ToolTip = 'Specifies the amount in the presentment currency.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Presentment Currency Code"; Rec."Presentment Currency Code")
                {
                    ToolTip = 'Specifies the Presentment currency code.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Amount (SCY)"; Rec."Amount (SCY)")
                {
                    ToolTip = 'Specifies the amount in the store currency.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Store Currency Code"; Rec."Store Currency Code")
                {
                    ToolTip = 'Specifies the store currency code.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ToolTip = 'Specifies the amount in the local currency.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(LogEntryFactBox; "NPR Spfy Event Log FactBox")
            {
                Caption = 'Details';
                ApplicationArea = NPRShopifyEcommerce;
                SubPageLink = "Entry No." = field("Entry No.");
                UpdatePropagation = Both;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = NPRShopifyEcommerce;
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
                trigger OnAction()
                begin
                    Rec.ShowRelatedEntities();
                end;
            }
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
            action(ShowOrderData)
            {
                Caption = 'Order Data';
                ToolTip = 'Show the order details that were downloaded from Shopify for this entry.';
                ApplicationArea = NPRShopifyEcommerce;
                Image = XMLFile;
                trigger OnAction()
                begin
                    ShowDownloadedOrderData();
                end;
            }
            action(OrderHistory)
            {
                Caption = 'Order History';
                ToolTip = 'Show all event log entries of the same Shopify document, including cancelled ones, newest first.';
                ApplicationArea = NPRShopifyEcommerce;
                Image = History;
                trigger OnAction()
                var
                    SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
                begin
                    SpfyEventLogMgt.ShowOrderHistory(Rec);
                end;
            }
        }
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
                ToolTip = 'Sets the retry counter back to zero for the selected entries that have used up all their automatic processing attempts, so the job queue tries to process them again. Entries that still have retries left are not changed. This does not process the entries right away - use Process Document for that.';
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
        area(Promoted)
        {
            actionref(ProcessLogEntries_Promoted; ProcessLogEntries) { }
            group(Category_Category9)
            {
                Caption = 'Process';
                ShowAs = Standard;

                actionref(GetOrderFromShopify_Promoted; GetOrderFromShopify) { }
            }
            group(Category_Errors)
            {
                Caption = 'Errors';

                actionref(ResetRetryCount_Promoted; ResetRetryCount) { }
            }
            group(Category_Navigate)
            {
                Caption = 'Navigate';
                ShowAs = Standard;

                actionref(RelatedEntries_Promoted; RelatedEntries) { }
                actionref(Store_Promoted; Store) { }
                actionref(ShowOrderData_Promoted; ShowOrderData) { }
                actionref(OrderHistory_Promoted; OrderHistory) { }
            }
        }
    }

    views
    {
        view(ErrorsFirst)
        {
            Caption = 'Errors';
            Filters = where("Processing Status" = const(Error));
            OrderBy = descending("Entry No.");
        }
        view(NotProcessed)
        {
            Caption = 'Not processed';
            Filters = where("Processing Status" = filter(<> Processed));
            OrderBy = descending("Entry No.");
        }
        view(Postponed)
        {
            Caption = 'Postponed';
            Filters = where("Processing Status" = const(Postponed));
            OrderBy = descending("Entry No.");
        }
    }

    var
        _EntryCanBeDownloadedAgain: Boolean;
        _DocStatusStyle: Text;
        _ErrorStyle: Text;
        _ProcStatusStyle: Text;

    trigger OnAfterGetCurrRecord()
    begin
        _EntryCanBeDownloadedAgain := Rec."Processing Status" <> Rec."Processing Status"::Processed;
    end;

    trigger OnAfterGetRecord()
    var
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        _ProcStatusStyle := SpfyEventLogMgt.GetLogEntryStatusStyle(Rec);

        if Rec."Processing Status" in [Rec."Processing Status"::Error, Rec."Processing Status"::Postponed] then
            _ErrorStyle := 'Attention'
        else
            _ErrorStyle := 'Standard';


        if Rec."Document Status" = Rec."Document Status"::Open then
            _DocStatusStyle := 'Standard'
        else
            _DocStatusStyle := 'Subordinate';
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
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        CurrPage.SetSelectionFilter(SelectedEntries);
        SpfyEventLogMgt.ExpandSelectionToSiblings(SelectedEntries, EntriesToProcess);
        SpfyEventLogMgt.ProcessAndReport(EntriesToProcess);

        if Rec.Get(Rec."Entry No.") then;
        CurrPage.Update(false);
    end;

    local procedure ShowDownloadedOrderData()
    var
        SpfyOrderDataViewer: Page "NPR Spfy Order Data Viewer";
        OrderDataNotDownloadedMsg: Label 'The order details have not been downloaded from Shopify yet.';
    begin
        Rec.CalcFields("Order Data");
        if not Rec."Order Data".HasValue() then begin
            Message(OrderDataNotDownloadedMsg);
            exit;
        end;
        SpfyOrderDataViewer.SetRecord(Rec);
        SpfyOrderDataViewer.RunModal();
    end;
}
