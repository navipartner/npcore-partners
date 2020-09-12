page 6151574 "NPR AF Notification Hub Card"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017

    Caption = 'AF Notification Hub Card';
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
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
                }
                field(Title; Title)
                {
                    ApplicationArea = All;
                }
                field(Body; Body)
                {
                    ApplicationArea = All;
                }
                field(Platform; Platform)
                {
                    ApplicationArea = All;
                }
                field("Notification Color"; "Notification Color")
                {
                    ApplicationArea = All;
                }
                field("From Register No."; "From Register No.")
                {
                    ApplicationArea = All;
                }
                field("To Register No."; "To Register No.")
                {
                    ApplicationArea = All;
                }
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;
                }
                field("Action Value"; "Action Value")
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                }
                field("Notification Delivered to Hub"; "Notification Delivered to Hub")
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
            group(Data)
            {
                Caption = 'Data';
                field(Request; RequestData)
                {
                    ApplicationArea = All;
                    Caption = 'Request';
                    Editable = false;
                    MultiLine = true;
                }
                field(Response; ResponseData)
                {
                    ApplicationArea = All;
                    Caption = 'Response';
                    Editable = false;
                    MultiLine = true;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

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

