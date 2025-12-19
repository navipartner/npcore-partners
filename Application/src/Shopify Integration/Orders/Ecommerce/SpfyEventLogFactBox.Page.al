#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185129 "NPR Spfy Event Log FactBox"
{
    Extensible = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR Spfy Event Log Entry";
    Caption = 'Shopify Event Log Factbox';
    RefreshOnActivate = true;
    layout
    {
        area(Content)
        {
            group(processingInformation)
            {
                ShowCaption = false;
                group(General)
                {
                    Caption = 'General';

                    field("Document Name"; Rec."Document Name")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the document name as provided by Shopify.';
                    }
                    field("Event Date"; DT2Date(Rec."Event Date-Time"))
                    {
                        Caption = 'Event Date';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the date when event was created.';
                    }
                    field("Document Status"; Rec."Document Status")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies whether the document is currently open, closed, or cancelled in Shopify.';
                    }
                    field("Closed Date"; DT2Date(Rec."Closed Date-Time"))
                    {
                        Caption = 'Closed Date';
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the date when the document has been closed in Shopify.';
                    }
                    field("Cancelled Date"; Rec."Cancelled Date")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the date when the document has been cancelled in Shopify.';
                    }

                }
                group("Error")
                {
                    Caption = 'Error';
                    field(Status; Rec."Processing Status")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the value of the Processing Status field.';
                        StyleExpr = _CreationStatusStyleText;
                    }
                    field("Bucket Id"; Rec."Bucket Id")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the bucket identifier assigned when the event log entry is created. It is used by Job Queues to group and process entries.';
                    }
                    field("Max Retry Limit Reached"; _MaxRetryLimitReached)
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies whether the maximum retry limit specified in Shopify Integration Setup has been reached.';
                        StyleExpr = _MaxRetryStyleText;
                        Caption = 'Max Retry Limit Reached';
                    }
                    field("Error Date"; Rec."Last Error Date")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        StyleExpr = _ErrorInformationStyleText;
                        ToolTip = 'Specifies the date when the last error message occurred.';
                    }
                    field("Last Error Message"; Rec."Last Error Message")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the last error message that occurred during processing.';
                        StyleExpr = _ErrorInformationStyleText;
                        trigger OnDrillDown()
                        begin
                            Message(Rec."Last Error Message");
                        end;
                    }

                }
                group(Ecommerce)

                {
                    Caption = 'Ecommerce Document Status';
                    field("External No."; _ExternalNo)
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        Caption = 'External No.';
                        ToolTip = 'Specifies the Ecommerce document number created from log.';
                        trigger OnDrillDown()
                        begin
                            SpfyEcomSalesDocPrcssr.EcomStatusOnDrillDown(Rec);
                        end;
                    }
                    field("Capture Processing Status"; Rec."Capture Processing Status")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the value of the Capture Processing Status in Ecommerce Document.';
                        trigger OnDrillDown()
                        begin
                            SpfyEcomSalesDocPrcssr.EcomStatusOnDrillDown(Rec);
                        end;
                    }
                    field("Virtual Items Process Status"; Rec."Virtual Items Process Status")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the value of the Virtual Items Processing Status field in Ecommerce Document.';
                        trigger OnDrillDown()
                        begin
                            SpfyEcomSalesDocPrcssr.EcomStatusOnDrillDown(Rec);
                        end;
                    }
                    field("Creation Status"; Rec."Creation Status")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the value of the Creation Status in Ecommerce Document.';
                        trigger OnDrillDown()
                        begin
                            SpfyEcomSalesDocPrcssr.EcomStatusOnDrillDown(Rec);
                        end;
                    }
                    field("Posting Status"; Rec."Posting Status")
                    {
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies the value of the Posting Status in Ecommerce Document.';
                        trigger OnDrillDown()
                        begin
                            SpfyEcomSalesDocPrcssr.EcomStatusOnDrillDown(Rec);
                        end;
                    }
                    field("Has Processing Errors"; _EcommerceErrorExist)
                    {
                        Caption = 'Has Processing Errors';
                        ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                        ToolTip = 'Specifies if there are error message from the Ecommerce processing flow.';
                        StyleExpr = _EcommerceErrorTexStyleText;
                        trigger OnDrillDown()
                        begin
                            if _EcommerceErrorExist then
                                Message(_EcommerceErrorText);
                        end;
                    }
                }
            }

            group(JsonViewer)
            {
                Caption = 'Order Data Viewer';
                field("Has Order Data"; _HasOrderData)
                {
                    Caption = 'Has Order Data';
                    ApplicationArea = NPRShopify, NPRShopifyEcommerce;
                    ToolTip = 'Opens the order JSON preview.';
                    trigger OnDrillDown()
                    var
                        SpfyOrderDataViewer: Page "NPR Spfy Order Data Viewer";
                    begin
                        if not _HasOrderData then
                            exit;
                        SpfyOrderDataViewer.SetRecord(Rec);
                        SpfyOrderDataViewer.RunModal();
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Order Data");
        _HasOrderData := Rec."Order Data".HasValue;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("Capture Processing Status", "Virtual Items Process Status", "Creation Status", "Posting Status");
        _MaxRetryLimitReached := SpfyAPIOrderLogMgt.MaxRetryLimitReached(Rec);
        GetInfoFromEcomHeader(Rec, _ExternalNo, _EcommerceErrorText);
        _EcommerceErrorExist := _EcommerceErrorText <> '';
        GetStyles(_CreationStatusStyleText, _ErrorInformationStyleText, _MaxRetryStyleText, _EcommerceErrorTexStyleText);
    end;

    local procedure GetInfoFromEcomHeader(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var ExternalNo: Text; var ErrorText: Text)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        Clear(ExternalNo);
        Clear(ErrorText);
        if not SpfyEcomSalesDocPrcssr.GetCreatedEcommerceDoc(SpfyEventLogEntry, EcomSalesHeader) then
            exit;

        ExternalNo := SpfyEventLogEntry."Shopify ID";
        ErrorText := SpfyEcomSalesDocPrcssr.GetEcommerceDocumentError(EcomSalesHeader)
    end;


    local procedure GetStyles(var CreationStatusStyleText: Text; var ErrorInformationStyleText: Text; var MaxRetryStyle: text; var EcommerceErrorTexStyleText: Text)
    var
    begin
        CreationStatusStyleText := SpfyAPIOrderLogMgt.GetLogEntryStatusStyle(Rec);
        ErrorInformationStyleText := SpfyAPIOrderLogMgt.GetLogEntryErrorInformationStyle(Rec);
        MaxRetryStyle := SpfyAPIOrderLogMgt.GetMaxRetryStyleText(Rec);
        EcommerceErrorTexStyleText := SpfyAPIOrderLogMgt.GetEcommerceErrorStyleText(_EcommerceErrorText);
    end;

    var
        SpfyAPIOrderLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        _CreationStatusStyleText: Text;
        _ErrorInformationStyleText: Text;
        _EcommerceErrorExist: Boolean;
        _ExternalNo: Text;
        _EcommerceErrorText: Text;
        _EcommerceErrorTexStyleText: Text;
        _MaxRetryStyleText: Text;
        _MaxRetryLimitReached: Boolean;
        _HasOrderData: Boolean;
}
#endIf