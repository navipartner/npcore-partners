page 6151041 "NPR Notification List"
{

    Caption = 'Notification List';
    CardPageID = "NPR Notification Card";
    Editable = false;
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
                    AFAPIWebService.SetNotificationCompletedFlag(UserId, gPOSNo, Format(Rec.Id));
                    CurrPage.Update();
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
                    AFAPIWebService.SetNotificationCancelledFlag(UserId, gPOSNo, Format(Rec.Id));
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec."Temp Current Pos Unit No." := gPOSNo;
        Rec.Modify();
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange(Cancelled, 0DT);
        Rec.SetRange(Completed, 0DT);
        Rec.SetRange("Notification Delivered to Hub", true);
        Rec.FilterGroup(0);
    end;

    var
        AFAPIWebService: Codeunit "NPR AF API WebService";
        gPOSNo: Code[10];

    procedure SetRegister(PosNo: Code[10])
    begin
        gPOSNo := PosNo;
    end;
}

