page 6151574 "NPR AF Notification Hub Card"
{
    Extensible = False;

    Caption = 'AF Notification Hub Card';
    DelayedInsert = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    UsageCategory = None;
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
                field(Platform; Rec.Platform)
                {

                    ToolTip = 'Specifies the value of the Platform field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Color"; Rec."Notification Color")
                {

                    ToolTip = 'Specifies the value of the Notification Color field';
                    ApplicationArea = NPRRetail;
                }
                field("From POS Unit No."; Rec."From POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the From POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("To POS Unit No."; Rec."To POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the To POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Type"; Rec."Action Type")
                {

                    ToolTip = 'Specifies the value of the Action Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Value"; Rec."Action Value")
                {

                    ToolTip = 'Specifies the value of the Action Value field';
                    ApplicationArea = NPRRetail;
                }
                field(Created; Rec.Created)
                {

                    ToolTip = 'Specifies the value of the Created field';
                    ApplicationArea = NPRRetail;
                }
                field("Created By"; Rec."Created By")
                {

                    ToolTip = 'Specifies the value of the Created By field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Delivered to Hub"; Rec."Notification Delivered to Hub")
                {

                    ToolTip = 'Specifies the value of the Notification Delivered to Hub field';
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
                field("Handled Pos Unit No."; Rec."Handled Pos Unit No.")
                {

                    ToolTip = 'Specifies the value of the Handled Pos Unit No. field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Data)
            {
                Caption = 'Data';
                field(Request; RequestData)
                {

                    Caption = 'Request';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Request field';
                    ApplicationArea = NPRRetail;
                }
                field(Response; ResponseData)
                {

                    Caption = 'Response';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Response field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Re-Send Messages action';
                ApplicationArea = NPRRetail;

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
        Rec.CalcFields("Request Data", "Response Data");

        if not Rec."Request Data".HasValue() then
            RequestData := ''
        else begin
            Rec."Request Data".CreateInStream(IStream);
            IStream.Read(RequestData, MaxStrLen(RequestData));
        end;

        if not Rec."Response Data".HasValue() then
            ResponseData := ''
        else begin
            Rec."Response Data".CreateInStream(IStream);
            IStream.Read(ResponseData, MaxStrLen(RequestData));
        end;
    end;

    var
        RequestData: Text;
        ResponseData: Text;
        IStream: InStream;
}

