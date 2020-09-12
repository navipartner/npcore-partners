page 6151383 "NPR CS Stock-Take Rfid Card"
{
    // NPR5.50/JAKUBV/20190603  CASE 344466 Transport NPR5.50 - 3 June 2019

    Caption = 'CS Stock-Take Rfid Card';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "NPR CS Stock-Take Handl. Rfid";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("Request Function"; "Request Function")
                {
                    ApplicationArea = All;
                }
                field("Batch Id"; "Batch Id")
                {
                    ApplicationArea = All;
                }
                field("Batch No."; "Batch No.")
                {
                    ApplicationArea = All;
                }
                field("Device Id"; "Device Id")
                {
                    ApplicationArea = All;
                }
                field(Tags; Tags)
                {
                    ApplicationArea = All;
                }
                field("Stock-Take Config Code"; "Stock-Take Config Code")
                {
                    ApplicationArea = All;
                }
                field("Worksheet Name"; "Worksheet Name")
                {
                    ApplicationArea = All;
                }
                field("Batch Posting"; "Batch Posting")
                {
                    ApplicationArea = All;
                }
                field(Handled; Handled)
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
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Posting Started"; "Posting Started")
                {
                    ApplicationArea = All;
                }
                field("Posting Ended"; "Posting Ended")
                {
                    ApplicationArea = All;
                }
                field("Posting Error"; "Posting Error")
                {
                    ApplicationArea = All;
                }
                field("Posting Error Detail"; "Posting Error Detail")
                {
                    ApplicationArea = All;
                }
            }
            group(Data)
            {
                Caption = 'Data';
                field(RequestData; RequestData)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                }
                field(ResponseData; ResponseData)
                {
                    ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    CSUIStockTakeHandlingRfid: Codeunit "NPR CS UI StockTake Hand. Rfid";
                begin
                    CSUIStockTakeHandlingRfid.Run(Rec);
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
        IStream: InStream;
        OStream: OutStream;
        ResponseData: Text;
        DCHelperFunctions: Codeunit "NPR CS Helper Functions";
}

