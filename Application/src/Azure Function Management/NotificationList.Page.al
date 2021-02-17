page 6151041 "NPR Notification List"
{

    Caption = 'Notification List';
    CardPageID = "NPR Notification Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR AF Notification Hub";

    layout
    {
        area(content)
        {
            repeater(Group)
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
                    AFAPIWebService.SetNotificationCompletedFlag(UserId, gPOSNo, Format(Rec.Id));
                    CurrPage.Update;
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
                    AFAPIWebService.SetNotificationCancelledFlag(UserId, gPOSNo, Format(Rec.Id));
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec."Temp Current Pos Unit No." := gPOSNo;
        Rec.Modify;
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

