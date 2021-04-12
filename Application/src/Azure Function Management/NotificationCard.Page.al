page 6151042 "NPR Notification Card"
{
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
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Title field';
                }
                field(Body; Rec.Body)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Body field';
                }
                field(Handled; Rec.Handled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled field';
                }
                field("Handled By"; Rec."Handled By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled By field';
                }
                field("Handled Register"; Rec."Handled Pos Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled Pos Unit No. field';
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
                    AFAPIWebService.SetNotificationCompletedFlag(UserId, Rec."Temp Current Pos Unit No.", Format(Rec.Id));
                    CurrPage.Close();
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
                    AFAPIWebService.SetNotificationCancelledFlag(UserId, Rec."Temp Current Pos Unit No.", Format(Rec.Id));
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        AFAPIWebService: Codeunit "NPR AF API WebService";
}

