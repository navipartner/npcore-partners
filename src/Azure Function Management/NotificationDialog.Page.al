page 6151040 "NPR Notification Dialog"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017

    Caption = 'Notification Dialog';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(TitleTxt; TitleTxt)
            {
                ApplicationArea = All;
                Caption = 'Title';
            }
            field(MessageTxt; MessageTxt)
            {
                ApplicationArea = All;
                Caption = 'Message';
            }
            group(Options)
            {
                Caption = 'Options';
                Description = 'Options';
                field(NotificationColor; NotificationColor)
                {
                    ApplicationArea = All;
                    Caption = 'Notification Color';
                }
                field(ActionType; ActionType)
                {
                    ApplicationArea = All;
                    Caption = 'Action Type';
                }
                field(ActionValue; ActionValue)
                {
                    ApplicationArea = All;
                    Caption = 'Action Value';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        NotificationColor := NotificationColor::Blue;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then
            OKOnPush;
    end;

    var
        TitleTxt: Text[30];
        MessageTxt: Text[250];
        Text001: Label 'You must add a title';
        NotificationColor: Option Red,Green,Blue,Yellow,Dark;
        ToRegisterNo: Code[10];
        ActionType: Option Message,"Phone Call","Facetime Video","Facetime Audio";
        ActionValue: Text[100];
        gRegisterNo: Code[10];

    local procedure OKOnPush()
    var
        AFNotificationHub: Record "NPR AF Notification Hub";
    begin
        if TitleTxt = '' then
            Error(Text001);

        AFNotificationHub.Init;
        AFNotificationHub.Title := TitleTxt;
        AFNotificationHub.Body := MessageTxt;
        AFNotificationHub."Notification Color" := NotificationColor;
        AFNotificationHub."Action Type" := ActionType;
        AFNotificationHub."Action Value" := ActionValue;
        AFNotificationHub."From Register No." := gRegisterNo;
        AFNotificationHub.Insert(true);
    end;

    procedure SetRegister("Register No.": Code[10])
    begin
        gRegisterNo := "Register No.";
    end;
}

