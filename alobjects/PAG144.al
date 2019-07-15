pageextension 50085 pageextension50085 extends "Posted Sales Credit Memos" 
{
    // NPR5.29/JC/20161205 CASE 259025 Added PDF2NAV Action group
    // NPR5.33/BR /20170323  CASE 266527 Added Doc. Exchange Actions
    // NPR5.42/THRO/20180518 CASE 308179 Removed code from Action SendAsPdf and EmailLog
    actions
    {
        addafter("&Credit Memo")
        {
            group("Doc. Exch. Framework")
            {
                Caption = 'Doc. Exch. Framework';
                action(Export)
                {
                    Caption = 'Export';
                    Image = ExportFile;
                }
                action(UpdateStatus)
                {
                    Caption = 'Update Status';
                    Image = ChangeStatus;
                }
            }
        }
        addafter(ActivityLog)
        {
            group(PDF2NAV)
            {
                Caption = 'PDF2NAV';
                action(EmailLog)
                {
                    Caption = 'E-mail Log';
                    Image = Email;
                }
                action(SendAsPDF)
                {
                    Caption = 'Send as PDF';
                    Image = SendEmailPDF;
                }
            }
        }
    }
}

