page 6151042 "NPR Notification Card"
{
    Extensible = False;
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
                field("Handled Register"; Rec."Handled Pos Unit No.")
                {

                    ToolTip = 'Specifies the value of the Handled Pos Unit No. field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Complete action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCompletedFlag(CopyStr(UserId, 1, 50), Rec."Temp Current Pos Unit No.", Format(Rec.Id));
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

                ToolTip = 'Executes the Cancel action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCancelledFlag(CopyStr(UserId, 1, 50), Rec."Temp Current Pos Unit No.", Format(Rec.Id));
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        AFAPIWebService: Codeunit "NPR AF API WebService";
}

