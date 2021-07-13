pageextension 6014416 "NPR Posted Sales Invoices" extends "Posted Sales Invoices"
{
    layout
    {
        addafter("Shipment Date")
        {
            field("NPR Magento Coupon"; Rec."NPR Magento Coupon")
            {

                Editable = false;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Magento Coupon field';
                ApplicationArea = NPRRetail;
            }
        }
    }
    actions
    {
        addafter(Navigate)
        {
            group("NPR Doc. Exch. Framework")
            {
                Caption = 'Doc. Exch. Framework';
                action("NPR Export")
                {
                    Caption = 'Export';
                    Image = ExportFile;

                    ToolTip = 'Executes the Export action';
                    ApplicationArea = NPRRetail;
                }
                action("NPR UpdateStatus")
                {
                    Caption = 'Update Status';
                    Image = ChangeStatus;

                    ToolTip = 'Executes the Update Status action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}