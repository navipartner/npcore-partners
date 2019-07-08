page 6151373 "CS Communication Log Card"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018

    Caption = 'CS Communication Log Card';
    Editable = false;
    PageType = Card;
    SourceTable = "CS Communication Log";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Id;Id)
                {
                }
                field("Request Start";"Request Start")
                {
                }
                field("Request End";"Request End")
                {
                }
                field("Request Function";"Request Function")
                {
                }
                field("Internal Request";"Internal Request")
                {
                }
                field("Internal Log No.";"Internal Log No.")
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
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("<Action1161035010>")
                {
                    Caption = 'Run Request';
                    Image = Evaluate;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        CSHelperFunctions: Codeunit "CS Helper Functions";
                    begin
                        CSHelperFunctions.InternalRequest(RequestData,true,Id);
                    end;
                }
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

