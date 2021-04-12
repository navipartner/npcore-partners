pageextension 6014416 "NPR Posted Sales Invoices" extends "Posted Sales Invoices"
{
    layout
    {

        addafter("Shipment Date")
        {
            field("NPR Bill-to E-mail"; Rec."NPR Bill-to E-mail")
            {
                ApplicationArea = All;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Bill-to E-mail field';
            }
            field("NPR Magento Coupon"; Rec."NPR Magento Coupon")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = false;
                ToolTip = 'Specifies the value of the NPR Magento Coupon field';
            }

        }
    }
    actions
    {
        addafter(Navigate)
        {
            group("NPR PDF2NAV")
            {
                Caption = 'PDF2NAV';
                action("NPR EmailLog")
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                    ApplicationArea = All;
                    ToolTip = 'Executes the E-mail Log action';
                }
                action("NPR SendSelectedAsPDF")
                {
                    Caption = 'Send Selected as PDF';
                    Image = SendEmailPDF;
                    ToolTip = 'Send Selected as PDF';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
                        SalesInvHeader: Record "Sales Invoice Header";
                    begin
                        CurrPage.SetSelectionFilter(SalesInvHeader);
                        if SalesInvHeader.FindSet() then
                            repeat
                                EmailDocMgt.SendReport(SalesInvHeader, true);
                            until SalesInvHeader.Next() = 0;
                        CurrPage.Update(false);
                    end;
                }
            }
            group("NPR Doc. Exch. Framework")
            {
                Caption = 'Doc. Exch. Framework';
                action("NPR Export")
                {
                    Caption = 'Export';
                    Image = ExportFile;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Export action';
                }
                action("NPR UpdateStatus")
                {
                    Caption = 'Update Status';
                    Image = ChangeStatus;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Update Status action';
                }
            }
        }
    }
}