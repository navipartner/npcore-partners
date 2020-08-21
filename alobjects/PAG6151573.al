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
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field(Title; Title)
                {
                    ApplicationArea = All;
                }
                field(Body; Body)
                {
                    ApplicationArea = All;
                }
                field(Platform; Platform)
                {
                    ApplicationArea = All;
                }
                field("Notification Color"; "Notification Color")
                {
                    ApplicationArea = All;
                }
                field("From Register No."; "From Register No.")
                {
                    ApplicationArea = All;
                }
                field("To Register No."; "To Register No.")
                {
                    ApplicationArea = All;
                }
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;
                }
                field("Action Value"; "Action Value")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field("Notification Delivered to Hub"; "Notification Delivered to Hub")
                {
                    ApplicationArea = All;
                }
                field(Handled; Handled)
                {
                    ApplicationArea = All;
                }
                field("Handled By"; "Handled By")
                {
                    ApplicationArea = All;
                }
                field("Handled Register"; "Handled Register")
                {
                    ApplicationArea = All;
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

