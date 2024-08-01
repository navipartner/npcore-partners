pageextension 6014425 "NPR Customer Card" extends "Customer Card"
{
    layout
    {
#if not BC17
        addafter("No.")
        {
            field("NPR Spfy Customer ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
            {
                Caption = 'Shopify Customer ID';
                Editable = false;
                Visible = ShopifyIntegrationIsEnabled;
                AssistEdit = true;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify ID assigned to the customer.';

                trigger OnAssistEdit()
                var
                    ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                begin
                    CurrPage.SaveRecord();
                    Commit();

                    Clear(ChangeShopifyID);
                    ChangeShopifyID.SetOptions(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                    ChangeShopifyID.RunModal();

                    CurrPage.Update(false);
                end;
            }
        }
#endif
        addafter(AdjProfitPct)
        {
            field("NPR To Anonymize On"; Rec."NPR To Anonymize On")
            {

                Editable = ToAnonymizeEditable;
                ToolTip = 'Schedule the date on which the customer will be anonymized.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Anonymized"; Rec."NPR Anonymized")
            {

                ToolTip = 'Display if customer information has been Anonymized.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Anonymized Date"; Rec."NPR Anonymized Date")
            {

                ToolTip = 'Specifies the date on which customer information has been anonymized.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Address & Contact")
        {
            group("NPR Magento")
            {
                Caption = 'Magento';
                field("NPR Magento Display Group"; Rec."NPR Magento Display Group")
                {

                    ToolTip = 'Specifies how the item on the Magento webstore will be grouped and displayed.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Store Code"; Rec."NPR Magento Store Code")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'View of the Magento store codes on webstore e.g Default,DK, EN.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Shipping Group"; Rec."NPR Magento Shipping Group")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the shipping configuration group e.g GLS, Free shipping.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Magento Payment Group"; Rec."NPR Magento Payment Group")
                {

                    Visible = (MagentoVersion >= 2);
                    ToolTip = 'Specifies the payment method for the item.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        addlast(Invoicing)
        {
            group("NPR LotteryCode")
            {
                Caption = 'IT Lottery Information';

                field("NPR IT Customer Lottery Code"; ITAuxCustomer."NPR IT Customer Lottery Code")
                {
                    Caption = 'IT Lottery Code';
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the IT Lottery Code field.';
                    trigger OnValidate()
                    begin
                        ITAuxCustomer.Validate("NPR IT Customer Lottery Code");
                        ITAuxCustomer.SaveITAuxCustomerFields();
                    end;
                }
            }
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
            group("NPR RS E-Invoicing")
            {
                Caption = 'RS E-Invoicing';

                field("NPR RS E-Invoice Customer"; RSEIAuxCustomer."NPR RS E-Invoice Customer")
                {
                    Caption = 'E-Invoice Customer';
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the E-Invoice Customer field.';
                    trigger OnValidate()
                    begin
                        RSEIAuxCustomer.SaveRSEIAuxCustomerFields();
                    end;
                }
                field("NPR RS EI CIR Customer"; RSEIAuxCustomer."NPR RS EI CIR Customer")
                {
                    Caption = 'RS EI CIR Customer';
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the CIR Customer field.';
                    trigger OnValidate()
                    begin
                        RSEIAuxCustomer.SaveRSEIAuxCustomerFields();
                    end;
                }
                field("NPR RS EI JMBG"; RSEIAuxCustomer."NPR RS EI JMBG")
                {
                    Caption = 'RS EI JMBG';
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the JMBG field.';
                    Numeric = true;
                    trigger OnValidate()
                    var
                        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
                    begin
                        RSEInvoiceMgt.CheckJMBGFormatValidity(RSEIAuxCustomer."NPR RS EI JMBG");
                        RSEIAuxCustomer.SaveRSEIAuxCustomerFields();
                    end;
                }
                field("NPR RS EI JBKJS Code"; RSEIAuxCustomer."NPR RS EI JBKJS Code")
                {
                    Caption = 'RS EI JBKJS Code';
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the JBKJS Code field.';
                    Numeric = true;
                    trigger OnValidate()
                    var
                        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
                    begin
                        RSEInvoiceMgt.CheckJKBJSFormatValidity(RSEIAuxCustomer."NPR RS EI JBKJS Code");
                        RSEIAuxCustomer.SaveRSEIAuxCustomerFields();
                    end;
                }
            }
#endif
        }
        moveafter("VAT Registration No."; "Tax Liable")
        moveafter("VAT Registration No."; "Tax Area Code")
        modify(TotalSales2)
        {
            Caption = 'Sales ERP - Fiscal Year';
        }
        addafter(TotalSales2)
        {
            field("NPR Total Sales POS"; CustPOSSalesLCY)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Sales POS - Fiscal Year';
                ToolTip = 'Specifies your total POS sales turnover with the customer in the current fiscal year. It is calculated from amounts excluding VAT on all finished POS sales.';
                AutoFormatType = 1;
                Style = Strong;
                StyleExpr = true;
                Editable = false;
            }
            field("NPR Total Sales"; CustPOSSalesLCY + CustSalesLCY)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Total Sales - Fiscal Year';
                ToolTip = 'Specifies the sum of your POS and backoffice (ERP) sales turnover with the customer in the current fiscal year.';
                AutoFormatType = 1;
                Style = Strong;
                StyleExpr = true;
                Editable = false;
            }
        }

    }
    actions
    {
        addlast(History)
        {
            action("NPR Item Ledger Entries")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Item Ledger Entries';
                Image = ItemLedger;
                RunObject = Page "Item Ledger Entries";
                RunPageLink = "Source Type" = const(Customer),
                                "Source No." = field("No.");
                ToolTip = 'View item ledger entries for this customer.';
            }
        }
        addfirst(Navigation)
        {
            group("NPR Retail")
            {
                Caption = 'Retail';

                action("NPR AlternativeNo")
                {
                    Caption = 'Alternative No.';
                    Image = "Action";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    ToolTip = 'Executes the Alternative No. action';
                    ApplicationArea = NPRRetail;
                }
                action("NPR PrintShippingLabel")
                {
                    Caption = 'Shipping Label';
                    Image = PrintCheck;

                    ToolTip = 'Creates a Shipping label with all necessary information included.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Customer: Record Customer;
                        LabelManagement: Codeunit "NPR Label Management";
                        RecRef: RecordRef;
                    begin
                        Customer := Rec;
                        Customer.SetRecFilter();
                        RecRef.GetTable(Customer);
                        LabelManagement.PrintCustomShippingLabel(RecRef, '');
                    end;
                }
            }
        }
        addafter(CustomerReportSelections)
        {
            action("NPR POS Info")
            {
                Caption = 'POS Info';
                Image = Info;
                RunObject = Page "NPR POS Info Links";
                RunPageLink = "Table ID" = CONST(18),
                              "Primary Key" = FIELD("No.");

                ToolTip = 'View the POS Info list which includes POS Info Code, POS Info Description and When To Use.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Item &Tracking Entries")
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;

                ToolTip = 'View the POS Entries list which includes Entry Date, Document No, Starting Time, Ending Time, etc.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSEntryListFromCustomer(Rec);
                end;
            }
        }
        addafter(Documents)
        {
            group("NPR SMS")
            {
                Caption = 'SMS';
                action("NPR SendSMS")
                {
                    Caption = 'Send SMS';
                    Image = SendConfirmation;

                    ToolTip = 'Sends SMS message to the customer.';
                    ApplicationArea = NPRRetail;
                    trigger OnAction()
                    var
                        SMSMgt: Codeunit "NPR SMS Management";
                    begin
                        SMSMgt.EditAndSendSMS(Rec);
                    end;
                }
            }
        }
        addafter(PaymentRegistration)
        {
            action("NPR Customer Anonymization")
            {
                Caption = 'Customer Anonymization';
                Ellipsis = true;
                Image = AbsenceCategory;

                ToolTip = 'Executes the Anonymization action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    GDPRManagement: Codeunit "NPR NP GDPR Management";
                begin
                    Rec.TestField("NPR Anonymized", false);
                    if (GDPRManagement.DoAnonymization(Rec."No.", ReasonText)) then
                        if (not Confirm(Text000, false)) then
                            Error('');

                    Message(ReasonText);
                end;
            }
        }
    }

    var
        UserSetup: Record "User Setup";
        CustPOSSalesLCY: Decimal;
        CustSalesLCY: Decimal;
        MagentoVersion: Decimal;
        ReasonText: Text;
        Text000: Label 'All Customer Information wil be lost! Do you want to continue?';
        ToAnonymizeEditable: Boolean;
        ITAuxCustomer: Record "NPR IT Aux Customer";
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxCustomer: Record "NPR RS EI Aux Customer";
#endif
#if not BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyIntegrationIsEnabled: Boolean;
#endif

    trigger OnAfterGetCurrRecord()
    var
        Customer: Record Customer;
        CustomerMgt: Codeunit "Customer Mgt.";
    begin
        Customer.Copy(Rec);
        Customer.SetFilter("Date Filter", CustomerMgt.GetCurrentYearFilter());
        Customer.CalcFields("Sales (LCY)", "NPR Total Sales POS");
        CustSalesLCY := Customer."Sales (LCY)";
        CustPOSSalesLCY := Customer."NPR Total Sales POS";

        ITAuxCustomer.ReadITAuxCustomerFields(Rec);
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        RSEIAuxCustomer.ReadRSEIAuxCustomerFields(Rec);
#endif
    end;

    trigger OnOpenPage()
#if not BC17
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
#endif
    begin
#if not BC17
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders");
#endif
        SetMagentoVersion();
        ToAnonymizeEditable := UserSetup.Get(UserId) and UserSetup."NPR Anonymize Customers";
    end;

    local procedure SetMagentoVersion()
    var
        MagentoSetup: Record "NPR Magento Setup";
    begin
        if not MagentoSetup.Get() then
            exit;

        case MagentoSetup."Magento Version" of
            MagentoSetup."Magento Version"::"1":
                MagentoVersion := 1;
            MagentoSetup."Magento Version"::"2":
                MagentoVersion := 2;
        end;
    end;
}