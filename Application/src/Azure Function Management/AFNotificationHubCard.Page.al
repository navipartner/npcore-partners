page 6151574 "NPR AF Notification Hub Card"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017

    Caption = 'AF Notification Hub Card';
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                field(Platform; Platform)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Platform field';
                }
                field("Notification Color"; "Notification Color")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Color field';
                }
                field("From Register No."; "From Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Register No. field';
                }
                field("To Register No."; "To Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Register No. field';
                }
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Type field';
                }
                field("Action Value"; "Action Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Value field';
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created field';
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created By field';
                }
                field("Notification Delivered to Hub"; "Notification Delivered to Hub")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Delivered to Hub field';
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
            group(Data)
            {
                Caption = 'Data';
                field(Request; RequestData)
                {
                    ApplicationArea = All;
                    Caption = 'Request';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Request field';
                }
                field(Response; ResponseData)
                {
                    ApplicationArea = All;
                    Caption = 'Response';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Response field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Re-Send Messages")
            {
                Caption = 'Re-Send Messages';
                Image = "Action";
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Re-Send Messages action';

                trigger OnAction()
                var
                    AFAPINotificationHub: Codeunit "NPR AF API - Notification Hub";
                begin
                    AFAPINotificationHub.ReSendPushNotification(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("Request Data", "Response Data");

        if not "Request Data".HasValue then
            RequestData := ''
        else begin
            "Request Data".CreateInStream(IStream);
            IStream.Read(RequestData, MaxStrLen(RequestData));
        end;

        if not "Response Data".HasValue then
            ResponseData := ''
        else begin
            "Response Data".CreateInStream(IStream);
            IStream.Read(ResponseData, MaxStrLen(RequestData));
        end;
    end;

    var
        RequestData: Text;
        ResponseData: Text;
        IStream: InStream;
}

