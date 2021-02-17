page 6151574 "NPR AF Notification Hub Card"
{

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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Id field';
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Title field';
                }
                field(Body; Rec.Body)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Body field';
                }
                field(Platform; Rec.Platform)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Platform field';
                }
                field("Notification Color"; Rec."Notification Color")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Color field';
                }
                field("From POS Unit No."; Rec."From POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From POS Unit No. field';
                }
                field("To POS Unit No."; Rec."To POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To POS Unit No. field';
                }
                field("Action Type"; Rec."Action Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Type field';
                }
                field("Action Value"; Rec."Action Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Value field';
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created field';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created By field';
                }
                field("Notification Delivered to Hub"; Rec."Notification Delivered to Hub")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Delivered to Hub field';
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
                field("Handled Pos Unit No."; Rec."Handled Pos Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handled Pos Unit No. field';
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
        Rec.CalcFields("Request Data", "Response Data");

        if not Rec."Request Data".HasValue then
            RequestData := ''
        else begin
            Rec."Request Data".CreateInStream(IStream);
            IStream.Read(RequestData, MaxStrLen(RequestData));
        end;

        if not Rec."Response Data".HasValue then
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

