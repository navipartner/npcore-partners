page 6151041 "NPR Notification List"
{
    // NPR5.38/NPKNAV/20180126  CASE 269792-01 Transport NPR5.38 - 26 January 2018

    Caption = 'Notification List';
    CardPageID = "NPR Notification Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR AF Notification Hub";

    layout
    {
        area(content)
        {
            repeater(Group)
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
                ApplicationArea = All;
                ToolTip = 'Executes the Complete action';

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCompletedFlag(UserId, gRegisterNo, Format(Id));
                    CurrPage.Update;
                end;
            }
            action(Cancel)
            {
                Caption = 'Cancel';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Cancel action';

                trigger OnAction()
                begin
                    AFAPIWebService.SetNotificationCancelledFlag(UserId, gRegisterNo, Format(Id));
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        "Temp Current Register" := gRegisterNo;
        Modify;
    end;

    trigger OnOpenPage()
    begin
        FilterGroup(2);
        SetRange(Cancelled, 0DT);
        SetRange(Completed, 0DT);
        SetRange("Notification Delivered to Hub", true);
        FilterGroup(0);
    end;

    var
        AFAPIWebService: Codeunit "NPR AF API WebService";
        gRegisterNo: Code[10];

    procedure SetRegister(RegisterNo: Code[10])
    begin
        gRegisterNo := RegisterNo;
    end;
}

