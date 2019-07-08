page 6151042 "Notification Card"
{
    // NPR5.38/NPKNAV/20180126  CASE 269792-01 Transport NPR5.38 - 26 January 2018

    Caption = 'Notification Card';
    Editable = false;
    SourceTable = "AF Notification Hub";

    layout
    {
        area(content)
        {
            group(General)
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
            action(Complete)
            {
                Caption = 'Complete';
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCompletedFlag(UserId,"Temp Current Register",Format(Id));
                    CurrPage.Close;
                end;
            }
            action(Cancel)
            {
                Caption = 'Cancel';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCancelledFlag(UserId,"Temp Current Register",Format(Id));
                    CurrPage.Close;
                end;
            }
        }
    }

    var
        AFAPIWebService: Codeunit "AF API WebService";
}

