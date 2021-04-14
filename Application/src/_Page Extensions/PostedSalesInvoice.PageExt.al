pageextension 6014405 "NPR Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Sell-to Customer Name 2 field';
            }
        }
        addafter("Payment Method Code")
        {
            field("NPR Magento Payment Amount"; Rec."NPR Magento Payment Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Magento Payment Amount field';
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Ship-to Name 2 field';
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Bill-to Name 2 field';
            }
        }
    }
    actions
    {
        addafter(ActivityLog)
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
                action("NPR SendAsPDF")
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Send as PDF action';
                }
            }
            group("NPR DocExchFramework")
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
            action("NPR Consignor Label")
            {
                Caption = 'Consignor Label';
                ApplicationArea = All;
                ToolTip = 'Executes the Consignor Label action';
                Image = Print;

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