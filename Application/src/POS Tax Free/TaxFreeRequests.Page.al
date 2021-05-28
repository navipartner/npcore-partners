page 6014645 "NPR Tax Free Requests"
{

    Caption = 'Tax Free Requests';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Tax Free Request";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Handler ID Enum"; Rec."Handler ID Enum")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handler ID field';
                }
                field("Date Start"; Rec."Date Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Start field';
                }
                field("Time Start"; Rec."Time Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Start field';
                }
                field("Date End"; Rec."Date End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Time End"; Rec."Time End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time field';
                }
                field(Mode; Rec.Mode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mode field';
                }
                field("Request Type"; Rec."Request Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Type field';
                }
                field("Error Code"; Rec."Error Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Code field';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Message field';
                }
                field(Success; Rec.Success)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Success field';
                }
                field("Request.HASVALUE"; Rec.Request.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Request Stored';
                    ToolTip = 'Specifies the value of the Request Stored field';
                }
                field("Response.HASVALUE"; Rec.Response.HasValue)
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
                PromotedOnly = true;
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
                    if not Rec.Request.HasValue() then
                        exit;
                    Rec.CalcFields(Request);
                    TempBLOB.FromRecord(Rec, Rec.FieldNo(Request));
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
                PromotedOnly = true;
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
                    if not Rec.Response.HasValue() then
                        exit;
                    Rec.CalcFields(Response);
                    TempBlob.FromRecord(Rec, Rec.FieldNo(Response));
                    TempBlob.CreateInStream(InStream);
                    Filename := 'Response';
                    DownloadFromStream(InStream, 'Download', '', 'All Files (*.*)|*.*', Filename);
                end;
            }
        }
    }
}

