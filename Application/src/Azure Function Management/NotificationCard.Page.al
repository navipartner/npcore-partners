page 6151042 "NPR Notification Card"
{
    // NPR5.38/NPKNAV/20180126  CASE 269792-01 Transport NPR5.38 - 26 January 2018

    UsageCategory = None;
    Caption = 'Notification Card';
    Editable = false;
    SourceTable = "NPR AF Notification Hub";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Title; Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Title field';
                }
                field(Body; Body)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Body field';
                }
                field(Handled; Handled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled field';
                }
                field("Handled By"; "Handled By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled By field';
                }
                field("Handled Register"; "Handled Register")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled Register field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Complete)
            {
                Caption = 'Complete';
                Image = Close;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Complete action';

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCompletedFlag(UserId, "Temp Current Register", Format(Id));
                    CurrPage.Close;
                end;
            }
            action(Cancel)
            {
                Caption = 'Cancel';
                Image = Cancel;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Cancel action';

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCancelledFlag(UserId, "Temp Current Register", Format(Id));
                    CurrPage.Close;
                end;
            }
        }
    }

    var
        AFAPIWebService: Codeunit "NPR AF API WebService";
}

