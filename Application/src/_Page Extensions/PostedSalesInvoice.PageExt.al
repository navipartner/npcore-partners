pageextension 6014405 "NPR Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {

                ToolTip = 'Specifies the Sell-to Customer Name 2 that will appear on the new sales document.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Payment Method Code")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {

                ToolTip = 'Specifies the sum of Payment Lines attached to the Posted Sales Invoice.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {

                ToolTip = 'Specifies the additional name of the customer that you shipped the items on the invoice to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {

                ToolTip = 'Specifies the additinal name of the customer that the invoice was sent to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Cancelled)
        {
            field("NPR RS Audit Entry"; RSAuxSalesInvHeader."NPR RS Audit Entry")
            {
                Caption = 'RS Audit Entry';
                ApplicationArea = NPRRSFiscal;
                ToolTip = 'Specifies the value of the RS Audit Entry field.';
                Editable = false;
            }
        }
        addafter(Closed)
        {
            field("NPR Sales Channel"; Rec."NPR Sales Channel")
            {
                ToolTip = 'Specifies the value of the Sales Channel field';
                Visible = false;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
        }
    }
    actions
    {
        addafter(AttachAsPDF)
        {
            action("NPR SendSMS")
            {
                Caption = 'Send SMS';
                Image = SendConfirmation;

                ToolTip = 'Specifies whether a notification SMS should be sent to a responsible person. The messages are sent using SMS templates.';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    SMSMgt: Codeunit "NPR SMS Management";
                begin
                    SMSMgt.EditAndSendSMS(Rec);
                end;
            }
        }
        addlast(processing)
        {
            action("NPR NPRUpdateFromCustomer")
            {
                Caption = 'Update OIOUBL fields from Customer';
                ToolTip = 'Transfer OIOUBL fields from Customer to Document';
                ApplicationArea = NPRRetail;
                Image = DocumentEdit;
                Ellipsis = true;
                Visible = OIOUBLInstalled;

                trigger OnAction()
                var
                    UpdateDocument: Codeunit "NPR OIOUBL Update Document";
                begin
                    UpdateDocument.SalesInvoiceSetOIOUBLFieldsFromCustomer(Rec);
                    CurrPage.Update(false);
                end;
            }

        }
    }
    var
        RSAuxSalesInvHeader: Record "NPR RS Aux Sales Inv. Header";
        OIOUBLInstalled: Boolean;

    trigger OnOpenPage()
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
    begin
        OIOUBLInstalled := OIOUBLSetup.IsOIOUBLInstalled();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        RSAuxSalesInvHeader.ReadRSAuxSalesInvHeaderFields(Rec);
    end;

}