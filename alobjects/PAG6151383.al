page 6151383 "CS Stock-Take Rfid Card"
{
    // NPR5.50/JAKUBV/20190603  CASE 344466 Transport NPR5.50 - 3 June 2019

    Caption = 'CS Stock-Take Rfid Card';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "CS Stock-Take Handling Rfid";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Id;Id)
                {
                }
                field("Request Function";"Request Function")
                {
                }
                field("Batch Id";"Batch Id")
                {
                }
                field("Batch No.";"Batch No.")
                {
                }
                field("Device Id";"Device Id")
                {
                }
                field(Tags;Tags)
                {
                }
                field("Stock-Take Config Code";"Stock-Take Config Code")
                {
                }
                field("Worksheet Name";"Worksheet Name")
                {
                }
                field("Batch Posting";"Batch Posting")
                {
                }
                field(Handled;Handled)
                {
                }
                field(Created;Created)
                {
                }
                field("Created By";"Created By")
                {
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Posting Started";"Posting Started")
                {
                }
                field("Posting Ended";"Posting Ended")
                {
                }
                field("Posting Error";"Posting Error")
                {
                }
                field("Posting Error Detail";"Posting Error Detail")
                {
                }
            }
            group(Data)
            {
                Caption = 'Data';
                field(RequestData;RequestData)
                {
                    MultiLine = true;
                    ShowCaption = false;
                }
                field(ResponseData;ResponseData)
                {
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Post Batch")
            {
                Caption = 'Post Batch';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CSUIStockTakeHandlingRfid: Codeunit "CS UI Stock-Take Handling Rfid";
                begin
                    CSUIStockTakeHandlingRfid.Run(Rec);
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
        IStream: InStream;
        OStream: OutStream;
        ResponseData: Text;
        DCHelperFunctions: Codeunit "CS Helper Functions";
}

