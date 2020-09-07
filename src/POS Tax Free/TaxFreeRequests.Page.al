page 6014645 "NPR Tax Free Requests"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free Requests';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free Request";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Handler ID"; "Handler ID")
                {
                    ApplicationArea = All;
                }
                field("Date Start"; "Date Start")
                {
                    ApplicationArea = All;
                }
                field("Time Start"; "Time Start")
                {
                    ApplicationArea = All;
                }
                field("Date End"; "Date End")
                {
                    ApplicationArea = All;
                }
                field("Time End"; "Time End")
                {
                    ApplicationArea = All;
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                }
                field("Request Type"; "Request Type")
                {
                    ApplicationArea = All;
                }
                field("Error Code"; "Error Code")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; "Error Message")
                {
                    ApplicationArea = All;
                }
                field(Success; Success)
                {
                    ApplicationArea = All;
                }
                field("Request.HASVALUE"; Request.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Request Stored';
                }
                field("Response.HASVALUE"; Response.HasValue)
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;

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
                ApplicationArea=All;

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

