pageextension 6014405 "NPR Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {

                ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Payment Method Code")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {

                ToolTip = 'Specifies the value of the NPR Magento Payment Amount field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {

                ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {

                ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                ApplicationArea = NPRRetail;
            }
        }
    }
    actions
    {
        addafter(ActivityLog)
        {
            action("NPR Consignor Label")
            {
                Caption = 'Consignor Label';

                ToolTip = 'Executes the Consignor Label action';
                Image = Print;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ConsignorEntry: Record "NPR Consignor Entry";
                begin
                    ConsignorEntry.InsertFromPostedInvoiceHeader(Rec."No.");
                end;
            }
        }
    }
}