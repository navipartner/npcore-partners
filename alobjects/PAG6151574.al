page 6151574 "AF Notification Hub Card"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017

    Caption = 'AF Notification Hub Card';
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "AF Notification Hub";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Id;Id)
                {
                }
                field(Title;Title)
                {
                }
                field(Body;Body)
                {
                }
                field(Platform;Platform)
                {
                }
                field("Notification Color";"Notification Color")
                {
                }
                field("From Register No.";"From Register No.")
                {
                }
                field("To Register No.";"To Register No.")
                {
                }
                field("Action Type";"Action Type")
                {
                }
                field("Action Value";"Action Value")
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
                field("Notification Delivered to Hub";"Notification Delivered to Hub")
                {
                }
                field(Handled;Handled)
                {
                }
                field("Handled By";"Handled By")
                {
                }
                field("Handled Register";"Handled Register")
                {
                }
            }
            group(Data)
            {
                Caption = 'Data';
                field(Request;RequestData)
                {
                    Caption = 'Request';
                    Editable = false;
                    MultiLine = true;
                }
                field(Response;ResponseData)
                {
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

                trigger OnAction()
                var
                    AFAPINotificationHub: Codeunit "AF API - Notification Hub";
                begin
                    AFAPINotificationHub.ReSendPushNotification(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("Request Data","Response Data");

        if not "Request Data".HasValue then
          RequestData := ''
        else begin
          "Request Data".CreateInStream(IStream);
          IStream.Read(RequestData,MaxStrLen(RequestData));
        end;

        if not "Response Data".HasValue then
          ResponseData := ''
        else begin
          "Response Data".CreateInStream(IStream);
          IStream.Read(ResponseData,MaxStrLen(RequestData));
        end;
    end;

    var
        RequestData: Text;
        ResponseData: Text;
        IStream: InStream;
}

