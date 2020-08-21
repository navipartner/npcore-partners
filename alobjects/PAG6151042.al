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
            action(Complete)
            {
                Caption = 'Complete';
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCancelledFlag(UserId, "Temp Current Register", Format(Id));
                    CurrPage.Close;
                end;
            }
        }
    }

    var
        AFAPIWebService: Codeunit "AF API WebService";
}

