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

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Handler ID Enum"; Rec."Handler ID Enum")
                {

                    ToolTip = 'Specifies the value of the Handler ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Date Start"; Rec."Date Start")
                {

                    ToolTip = 'Specifies the value of the Date Start field';
                    ApplicationArea = NPRRetail;
                }
                field("Time Start"; Rec."Time Start")
                {

                    ToolTip = 'Specifies the value of the Time Start field';
                    ApplicationArea = NPRRetail;
                }
                field("Date End"; Rec."Date End")
                {

                    ToolTip = 'Specifies the value of the Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Time End"; Rec."Time End")
                {

                    ToolTip = 'Specifies the value of the Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Mode; Rec.Mode)
                {

                    ToolTip = 'Specifies the value of the Mode field';
                    ApplicationArea = NPRRetail;
                }
                field("Request Type"; Rec."Request Type")
                {

                    ToolTip = 'Specifies the value of the Request Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Error Code"; Rec."Error Code")
                {

                    ToolTip = 'Specifies the value of the Error Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Error Message"; Rec."Error Message")
                {

                    ToolTip = 'Specifies the value of the Error Message field';
                    ApplicationArea = NPRRetail;
                }
                field(Success; Rec.Success)
                {

                    ToolTip = 'Specifies the value of the Success field';
                    ApplicationArea = NPRRetail;
                }
                field("Request Stored"; Rec.Request.HasValue)
                {

                    Caption = 'Request Stored';
                    ToolTip = 'Specifies the value of the Request Stored field';
                    ApplicationArea = NPRRetail;
                }
                field("Response Stored"; Rec.Response.HasValue)
                {

                    Caption = 'Response Stored';
                    ToolTip = 'Specifies the value of the Response Stored field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Download Request action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Download Response action';
                ApplicationArea = NPRRetail;

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

