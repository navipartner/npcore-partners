page 6151573 "AF Notification Hub List"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017

    Caption = 'AF Notification Hub List';
    CardPageID = "AF Notification Hub Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "AF Notification Hub";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id;Id)
                {
                }
                field(Title;Title)
                {
                }
                field(Body;Body)
                {
                }
                field(Platform;Platform)
                {
                }
                field("Notification Color";"Notification Color")
                {
                }
                field("From Register No.";"From Register No.")
                {
                }
                field("To Register No.";"To Register No.")
                {
                }
                field("Action Type";"Action Type")
                {
                }
                field("Action Value";"Action Value")
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
                field("Notification Delivered to Hub";"Notification Delivered to Hub")
                {
                }
                field(Handled;Handled)
                {
                }
                field("Handled By";"Handled By")
                {
                }
                field("Handled Register";"Handled Register")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Re-Send Messages")
            {
                Caption = 'Re-Send Messages';
                Image = "Action";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AFAPINotificationHub: Codeunit "AF API - Notification Hub";
                begin
                    AFAPINotificationHub.ReSendPushNotification(Rec);
                end;
            }
        }
    }
}

