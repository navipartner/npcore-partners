page 6184523 "NPR NPRE Notification Setup"
{
    Extensible = False;
    Caption = 'Restaurant Notification Setup';
    PageType = Worksheet;
    SourceTable = "NPR NPRE Notification Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Notification Trigger"; Rec."Notification Trigger")
                {
                    ToolTip = 'Specifies the notification trigger for which this notification setup line is used.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant for which this notification setup line will be used. Leave the field blank if you want the setup line to be used for all restaurants.';
                    ApplicationArea = NPRRetail;
                }
                field("Production Restaurant Code"; Rec."Production Restaurant Code")
                {
                    ToolTip = 'Specifies the production restaurant for which this notification setup line will be used. Leave the field blank if you want the setup line to be used regardless of the production restaurant.';
                    ApplicationArea = NPRRetail;
                }
                field("Kitchen Station"; Rec."Kitchen Station")
                {
                    ToolTip = 'Specifies the kitchen station for which this notification setup line will be used. Leave the field blank if you want the setup line to be used regardless of the kitchen station.';
                    ApplicationArea = NPRRetail;
                }
                field(Recipient; Rec.Recipient)
                {
                    ToolTip = 'Specifies the type of recipient for the notifications.';
                    ApplicationArea = NPRRetail;
                }
                field("User ID (Recipient)"; Rec."User ID (Recipient)")
                {
                    ToolTip = 'Specifies the notification recipient user ID. Only applicable if you have selected "Specific User" as the "Recipient".';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Notification"; Rec."E-Mail Notification")
                {
                    ToolTip = 'Specifies whether to send email notifications.';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Notif. Template"; Rec."E-Mail Notif. Template")
                {
                    ToolTip = 'Specifies the template for email notifications.';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Notification"; Rec."Sms Notification")
                {
                    ToolTip = 'Specifies whether to send text message (SMS) notifications.';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Notif. Template"; Rec."Sms Notif. Template")
                {
                    ToolTip = 'Specifies the template for text message (SMS) notifications.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the unique number of the notification setup entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                    Editable = false;
                }
            }
        }
    }
}
