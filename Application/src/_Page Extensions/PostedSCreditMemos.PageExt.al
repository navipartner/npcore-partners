pageextension 6014417 "NPR Posted S.Credit Memos" extends "Posted Sales Credit Memos"
{
    layout
    {
        addafter(Paid)
        {
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
    }
}