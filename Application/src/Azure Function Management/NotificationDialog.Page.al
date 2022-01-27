page 6151040 "NPR Notification Dialog"
{
    Extensible = False;
    Caption = 'Notification Dialog';
    PageType = StandardDialog;
    UsageCategory = None;
    layout
    {
        area(content)
        {
            field(TitleTxt; TitleTxt)
            {

                Caption = 'Title';
                ToolTip = 'Specifies the value of the Title field';
                ApplicationArea = NPRRetail;
            }
            field(MessageTxt; MessageTxt)
            {

                Caption = 'Message';
                ToolTip = 'Specifies the value of the Message field';
                ApplicationArea = NPRRetail;
            }
            group(Options)
            {
                Caption = 'Options';
                Description = 'Options';
                field(NotificationColor; NotificationColor)
                {

                    Caption = 'Notification Color';
                    OptionCaption = 'Red,Green,Blue,Yellow,Dark';
                    ToolTip = 'Specifies the value of the Notification Color field';
                    ApplicationArea = NPRRetail;
                }
                field(ActionType; ActionType)
                {

                    Caption = 'Action Type';
                    OptionCaption = 'Message,Phone Call,Facetime Video,Facetime Audio';
                    ToolTip = 'Specifies the value of the Action Type field';
                    ApplicationArea = NPRRetail;
                }
                field(ActionValue; ActionValue)
                {

                    Caption = 'Action Value';
                    ToolTip = 'Specifies the value of the Action Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnInit()
    begin
        NotificationColor := NotificationColor::Blue;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then
            OKOnPush();
    end;

    var
        TitleTxt: Text[30];
        MessageTxt: Text[250];
        Text001: Label 'You must add a title';
        NotificationColor: Option Red,Green,Blue,Yellow,Dark;
        ActionType: Option Message,"Phone Call","Facetime Video","Facetime Audio";
        ActionValue: Text[100];
        gPOSNo: Code[10];

    local procedure OKOnPush()
    var
        AFNotificationHub: Record "NPR AF Notification Hub";
    begin
        if TitleTxt = '' then
            Error(Text001);

        AFNotificationHub.Init();
        AFNotificationHub.Title := TitleTxt;
        AFNotificationHub.Body := MessageTxt;
        AFNotificationHub."Notification Color" := NotificationColor;
        AFNotificationHub."Action Type" := ActionType;
        AFNotificationHub."Action Value" := ActionValue;
        AFNotificationHub."From POS Unit No." := gPOSNo;
        AFNotificationHub.Insert(true);
    end;

    procedure SetRegister("POS Unit No.": Code[10])
    begin
        gPOSNo := "POS Unit No.";
    end;
}

