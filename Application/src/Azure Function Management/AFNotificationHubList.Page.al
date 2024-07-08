page 6151573 "NPR AF Notification Hub List"
{
    Extensible = False;

    Caption = 'AF Notification Hub List';
    CardPageID = "NPR AF Notification Hub Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR AF Notification Hub";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Rec.Id)
                {

                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Title; Rec.Title)
                {

                    ToolTip = 'Specifies the value of the Title field';
                    ApplicationArea = NPRRetail;
                }
                field(Body; Rec.Body)
                {

                    ToolTip = 'Specifies the value of the Body field';
                    ApplicationArea = NPRRetail;
                }
                field(Platform; Rec.Platform)
                {

                    ToolTip = 'Specifies the value of the Platform field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Color"; Rec."Notification Color")
                {

                    ToolTip = 'Specifies the value of the Notification Color field';
                    ApplicationArea = NPRRetail;
                }
                field("From POS Unit No."; Rec."From POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the From POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("To POS Unit No."; Rec."To POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the To POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Type"; Rec."Action Type")
                {

                    ToolTip = 'Specifies the value of the Action Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Value"; Rec."Action Value")
                {

                    ToolTip = 'Specifies the value of the Action Value field';
                    ApplicationArea = NPRRetail;
                }
                field(Created; Rec.Created)
                {

                    ToolTip = 'Specifies the value of the Created field';
                    ApplicationArea = NPRRetail;
                }
                field("Created By"; Rec."Created By")
                {

                    ToolTip = 'Specifies the value of the Created By field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Delivered to Hub"; Rec."Notification Delivered to Hub")
                {

                    ToolTip = 'Specifies the value of the Notification Delivered to Hub field';
                    ApplicationArea = NPRRetail;
                }
                field(Handled; Rec.Handled)
                {

                    ToolTip = 'Specifies the value of the Handled field';
                    ApplicationArea = NPRRetail;
                }
                field("Handled By"; Rec."Handled By")
                {

                    ToolTip = 'Specifies the value of the Handled By field';
                    ApplicationArea = NPRRetail;
                }
                field("Handled POS Unit No."; Rec."Handled POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the Handled POS Unit No. field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Re-Send Messages action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    AFAPINotificationHub: Codeunit "NPR AF API - Notification Hub";
                begin
                    AFAPINotificationHub.ReSendPushNotification(Rec);
                end;
            }
        }
    }
}

