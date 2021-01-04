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
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Handler ID"; "Handler ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handler ID field';
                }
                field("Date Start"; "Date Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Start field';
                }
                field("Time Start"; "Time Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Start field';
                }
                field("Date End"; "Date End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Time End"; "Time End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time field';
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';
                }
                field("Request Type"; "Request Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Type field';
                }
                field("Error Code"; "Error Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Code field';
                }
                field("Error Message"; "Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Message field';
                }
                field(Success; Success)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Success field';
                }
                field("Request.HASVALUE"; Request.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Request Stored';
                    ToolTip = 'Specifies the value of the Request Stored field';
                }
                field("Response.HASVALUE"; Response.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Response Stored';
                    ToolTip = 'Specifies the value of the Response Stored field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Download Request action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Download Response action';

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

