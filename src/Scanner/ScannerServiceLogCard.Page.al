page 6059998 "NPR Scanner Service Log Card"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Scanner Service Log Card';
    PageType = Card;
    SourceTable = "NPR Scanner Service Log";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Id; Id)
                {
                    ApplicationArea = All;
                }
                field("Request Start"; "Request Start")
                {
                    ApplicationArea = All;
                }
                field("Request End"; "Request End")
                {
                    ApplicationArea = All;
                }
                field("Request Function"; "Request Function")
                {
                    ApplicationArea = All;
                }
                field("Internal Request"; "Internal Request")
                {
                    ApplicationArea = All;
                }
                field("Internal Log No."; "Internal Log No.")
                {
                    ApplicationArea = All;
                }
                field("Current User"; "Current User")
                {
                    ApplicationArea = All;
                }
            }
            group(XML)
            {
                Caption = 'XML';
                field(RequestData; RequestData)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                }
                field(ResponseData; ResponseData)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
            group("XML Debug")
            {
                Caption = 'XML Debug';
                Visible = false;
                field("Debug Request Data"; "Debug Request Data")
                {
                    ApplicationArea = All;
                }
                field(ResponseDataDebug; ResponseDataDebug)
                {
                    ApplicationArea = All;
                    Editable = false;
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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("<Action1161035010>")
                {
                    Caption = 'Run Request';
                    Image = Return;

                    trigger OnAction()
                    begin
                        if "Debug Request Data" <> '' then
                            ResponseDataDebug := DWFunctions.InternalRequest("Debug Request Data", true, Id)
                        else
                            ResponseDataDebug := DWFunctions.InternalRequest(RequestData, true, Id);
                    end;
                }
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
        DWFunctions: Codeunit "NPR Scanner Service Func.";
        ResponseDataDebug: Text;
}

