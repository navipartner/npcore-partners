page 6059998 "NPR Scanner Service Log Card"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Scanner Service Log Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Id field';
                }
                field("Request Start"; "Request Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Start field';
                }
                field("Request End"; "Request End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request End field';
                }
                field("Request Function"; "Request Function")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request Function field';
                }
                field("Internal Request"; "Internal Request")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Internal Request field';
                }
                field("Internal Log No."; "Internal Log No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Internal Log No. field';
                }
                field("Current User"; "Current User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current User field';
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
                    ToolTip = 'Specifies the value of the RequestData field';
                }
                field(ResponseData; ResponseData)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the ResponseData field';
                }
            }
            group("XML Debug")
            {
                Caption = 'XML Debug';
                Visible = false;
                field("Debug Request Data"; "Debug Request Data")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Debug Request Data field';
                }
                field(ResponseDataDebug; ResponseDataDebug)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the ResponseDataDebug field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Run Request action';

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

