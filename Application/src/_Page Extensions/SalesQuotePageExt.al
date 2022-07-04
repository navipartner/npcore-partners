pageextension 6014404 "NPR Sales Quote" extends "Sales Quote"
{
    actions
    {
        addafter(Print)
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
    }
}
