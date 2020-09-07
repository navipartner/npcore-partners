page 6151373 "NPR CS Comm. Log Card"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Communication Log Card';
    Editable = false;
    PageType = Card;
    SourceTable = "NPR CS Comm. Log";

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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("<Action1161035010>")
                {
                    Caption = 'Run Request';
                    Image = Evaluate;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea=All;

                    trigger OnAction()
                    var
                        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
                    begin
                        CSHelperFunctions.InternalRequest(RequestData, true, Id);
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
        DCHelperFunctions: Codeunit "NPR CS Helper Functions";
}

