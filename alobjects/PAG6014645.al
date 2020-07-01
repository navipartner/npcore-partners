page 6014645 "Tax Free Requests"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Requests';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Tax Free Request";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; "POS Unit No.")
                {
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                }
                field("User ID"; "User ID")
                {
                }
                field("Handler ID"; "Handler ID")
                {
                }
                field("Date Start"; "Date Start")
                {
                }
                field("Time Start"; "Time Start")
                {
                }
                field("Date End"; "Date End")
                {
                }
                field("Time End"; "Time End")
                {
                }
                field(Mode; Mode)
                {
                }
                field("Request Type"; "Request Type")
                {
                }
                field("Error Code"; "Error Code")
                {
                }
                field("Error Message"; "Error Message")
                {
                }
                field(Success; Success)
                {
                }
                field("Request.HASVALUE"; Request.HasValue)
                {
                    Caption = 'Request Stored';
                }
                field("Response.HASVALUE"; Response.HasValue)
                {
                    Caption = 'Response Stored';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Download Request")
            {
                Caption = 'Download Request';
                Image = CreateXMLFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    InStream: InStream;
                    Filename: Variant;
                begin
                    if not Request.HasValue then
                        exit;
                    CalcFields(Request);
                    TempBLOB.FromRecord(Rec, FieldNo(Request));
                    TempBlob.CreateInStream(InStream);
                    Filename := 'Request';
                    DownloadFromStream(InStream, 'Download', '', 'All Files (*.*)|*.*', Filename);
                end;
            }
            action("Download Response")
            {
                Caption = 'Download Response';
                Image = CreateXMLFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    InStream: InStream;
                    Filename: Variant;
                begin
                    if not Response.HasValue then
                        exit;
                    CalcFields(Response);
                    TempBlob.FromRecord(Rec, FieldNo(Response));
                    TempBlob.CreateInStream(InStream);
                    Filename := 'Response';
                    DownloadFromStream(InStream, 'Download', '', 'All Files (*.*)|*.*', Filename);
                end;
            }
        }
    }
}

