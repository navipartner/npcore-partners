#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248188 "NPR Ecom Sales Document"
{
    PageType = Document;
    UsageCategory = None;
    SourceTable = "NPR Ecom Sales Header";
    Caption = 'Ecommerce Sales Document';
    InsertAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;
    DataCaptionExpression = Format(Rec."Document Type") + ' ' + Rec."External No.";
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."External No.")
                {
                    ApplicationArea = NPRRetail;
                    Importance = Promoted;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                group(OrderVisibilityGroup)
                {
                    ShowCaption = false;
                    Visible = Rec."Document Type" = Rec."Document Type"::Order;
                    field("Currency Exchange Rate"; Rec."Currency Exchange Rate")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Currency Exchange Rate field.';
                    }
                    field("External Document No."; Rec."External Document No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the External Document No. field.';
                    }
                    field("Your Reference"; Rec."Your Reference")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Your Reference field.';
                    }
                }
                field("Location Code."; Rec."Location Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("Price Excl. VAT"; Rec."Price Excl. VAT")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Price Excl. VAT field.';
                }
            }
            group(sellToCustomer)
            {
                Caption = 'Sell-to Customer';
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    Caption = 'Customer No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Sell-to Name"; Rec."Sell-to Name")
                {
                    Caption = 'Name';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Sell-to Address"; Rec."Sell-to Address")
                {
                    Caption = 'Address';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Address field.';
                }
                field("Sell-to Address 2"; Rec."Sell-to Address 2")
                {
                    Caption = 'Address 2';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Address 2 field.';
                }
                field("Sell-to Post Code"; Rec."Sell-to Post Code")
                {
                    Caption = 'Post Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Post Code field.';
                }
                field("Sell-to Country Code"; Rec."Sell-to Country Code")
                {
                    Caption = 'Country Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Country Code field.';
                }
                field("Sell-to County"; Rec."Sell-to County")
                {
                    Caption = 'County';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the County field.';
                }
                field("Sell-to City"; Rec."Sell-to City")
                {
                    Caption = 'City';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the City field.';
                }
                field("Sell-to Contact"; Rec."Sell-to Contact")
                {
                    Caption = 'Contact';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Contact field.';
                }
                field("Sell-to Email"; Rec."Sell-to Email")
                {
                    Caption = 'Email';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Email field.';
                }
                group(SellToInvoiceEmailVisibilityGroup)
                {
                    ShowCaption = false;
                    Visible = Rec."Document Type" = Rec."Document Type"::Order;
                    field("Sell-to Invoice Email"; Rec."Sell-to Invoice Email")
                    {
                        Caption = 'Invoice Email';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Invoice Email field.';
                    }
                }
                field("Sell-to Phone No."; Rec."Sell-to Phone No.")
                {
                    Caption = 'Phone No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Phone No. field.';
                }
                field("Sell-to VAT Registration No."; Rec."Sell-to VAT Registration No.")
                {
                    Caption = 'VAT Registration No.';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the VAT Registration No. field.';
                }
                group(CustomerTypeVisibilityGroup)
                {
                    ShowCaption = false;
                    Visible = ShowCustomerTypeField;
                    field("Sell-to Customer Type"; Rec."Sell-to Customer Type")
                    {
                        Caption = 'Type';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Type field.';
                    }
                }
                group(CustomerTemplatesVisibilityGroup)
                {
                    ShowCaption = false;
                    Visible = ShowCustomerTemplateFields;
                    field("Customer Template"; Rec."Customer Template")
                    {
                        Caption = 'Customer Template';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Customer Template field.';
                    }

                    field("Configuration Template"; Rec."Configuration Template")
                    {
                        Caption = 'Configuration Template';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Configuration Template field.';
                    }
                }
                field("Sell-to EAN"; Rec."Sell-to EAN")
                {
                    Caption = 'EAN';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the EAN field.';
                }

            }
            group(ShipToCustomer)
            {
                Caption = 'Ship-to Customer';
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    Caption = 'Name';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    Caption = 'Address';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Address field.';
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    Caption = 'Address 2';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Address 2 field.';
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    Caption = 'Post Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ship-to Post Code field.';
                }
                field("Ship-to Country Code"; Rec."Ship-to Country Code")
                {
                    Caption = 'Country Code';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ship-to Country Code field.';
                }
                field("Ship-to County"; Rec."Ship-to County")
                {
                    Caption = 'County';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ship-to County field.';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    Caption = 'City';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ship-to City field.';
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    Caption = 'Contact';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ship-to Contact field.';
                }
            }
            Group(Shipment)
            {
                Caption = 'Shipment';
                group(ShipmentMethod)
                {
                    Caption = 'Shipment Method';
                    field("Shipment Method Code"; Rec."Shipment Method Code")
                    {
                        Caption = 'Shipment Method Code';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Shipment Method Code field.';
                    }
                    field("Shipment Service"; Rec."Shipment Service")
                    {
                        Caption = 'Shipment Service';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Shipment Service field.';
                    }
                }
            }
            part(SalesLines; "NPR Ecom Sales Doc Sub")
            {
                ApplicationArea = NPRRetail;
                SubPageLink = "External Document No." = field("External No."), "Document Type" = field("Document Type");
                UpdatePropagation = Both;
            }
            part(PaymentLines; "NPR Ecom Sales Doc Pmt Sub")
            {
                ApplicationArea = NPRRetail;
                SubPageLink = "External Document No." = field("External No."), "Document Type" = field("Document Type");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part(IncEcomDocFactBox; "NPR Ecom Doc FactBox")
            {
                Caption = 'Processing Information';
                ApplicationArea = NPRRetail;
                SubPageLink = "External No." = field("External No."), "Document Type" = field("Document Type");
                UpdatePropagation = Both;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CaptureVirtualItems)
            {
                Caption = 'Capture Virtual Items';
                ToolTip = 'Capture Virtual Items';
                ApplicationArea = NPRRetail;
                Image = Payment;
                trigger OnAction()
                var
                    EcomSaleDocCaptureProcess: Codeunit "NPR EcomSaleDocCaptureProcess";
                    ConfirmManagement: Codeunit "Confirm Management";
                    ConfirmVirtualItemCaptureLbl: Label 'Are you sure you want to capture the virtual item?';
                begin
                    if not ConfirmManagement.GetResponseOrDefault(ConfirmVirtualItemCaptureLbl, true) then
                        exit;
                    EcomSaleDocCaptureProcess.SetUpdateRetryCount(false);
                    EcomSaleDocCaptureProcess.SetShowError(true);
                    EcomSaleDocCaptureProcess.Run(Rec);
                end;
            }
            action(Process)
            {
                Caption = 'Process';
                ToolTip = 'Process the selected entry';
                ApplicationArea = NPRRetail;
                Image = NextRecord;
                trigger OnAction()
                var
                    EcomSalesDocConfirm: Codeunit "NPR Ecom Sales Doc Confirm";
                begin
                    EcomSalesDocConfirm.SetShowError(true);
                    EcomSalesDocConfirm.SetUpdateRetryCount(false);
                    EcomSalesDocConfirm.Run(Rec);
                end;
            }
        }

        area(Navigation)
        {
            action(RelatedSalesDocuments)
            {
                Caption = 'Related Sales Documents';
                ToolTip = 'Open related sales documents';
                ApplicationArea = NPRRetail;
                Image = RelatedInformation;
                trigger OnAction()
                var
                    EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                begin
                    EcomSalesDocUtils.OpenRelatedSalesDocumentsFromEcomDoc(Rec);
                end;
            }
            action("Retail Vouchers")
            {
                Caption = 'Vouchers';
                Image = Certificate;
                ToolTip = 'View linked vouchers';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EcomCreateVchrProcess: Codeunit "NPR EcomCreateVchrProcess";
                begin
                    EcomCreateVchrProcess.ShowRelatedVouchersAction(Rec);
                end;
            }
        }

        area(Promoted)
        {
            group(Home)
            {
                actionref(Process_Promoted; Process) { }
                actionref(CaptureVirtualItems_Promoted; CaptureVirtualItems) { }
                actionref(Sales_Documents; RelatedSalesDocuments) { }

            }
        }
    }
    var
        EcomSalesDocImplV2: Codeunit "NPR Ecom Sales Doc Impl V2";
        ShowCustomerTypeField: Boolean;
        ShowCustomerTemplateFields: Boolean;


    trigger OnOpenPage()
    begin
        HandleCustomerTypeAndTemplatesVisiblityFields();

    end;

    trigger OnAfterGetRecord()
    begin
        HandleCustomerTypeAndTemplatesVisiblityFields();
    end;

    local procedure HandleCustomerTypeAndTemplatesVisiblityFields(): Boolean
    begin
        if Rec."API Version Date" = EcomSalesDocImplV2.GetApiVersion() then begin
            ShowCustomerTypeField := false;
            ShowCustomerTemplateFields := true;
        end else begin
            ShowCustomerTypeField := true;
            ShowCustomerTemplateFields := false;
        end;
    end;
}
#endIf