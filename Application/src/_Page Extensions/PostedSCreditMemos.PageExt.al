pageextension 6014417 "NPR Posted S.Credit Memos" extends "Posted Sales Credit Memos"
{
    // NPR5.29/JC/20161205 CASE 259025 Added PDF2NAV Action group
    // NPR5.33/BR /20170323  CASE 266527 Added Doc. Exchange Actions
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog

    layout
    {
        addafter(Paid)
        {
            field("NPR Magento Coupon"; "NPR Magento Coupon")
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
        addafter("&Credit Memo")
        {
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
        }
    }
}

