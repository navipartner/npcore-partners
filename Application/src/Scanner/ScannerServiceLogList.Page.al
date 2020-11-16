page 6059997 "NPR Scanner Service Log List"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Scanner Service Log List';
    CardPageID = "NPR Scanner Service Log Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Scanner Service Log";
    SourceTableView = SORTING("Request Start")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
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
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("Request Data");
        if not "Request Data".HasValue then
            RequestData := ''
        else begin
            "Request Data".CreateInStream(IStream);
            IStream.Read(RequestData, MaxStrLen(RequestData));
        end;
    end;

    var
        RequestData: Text;
        IStream: InStream;
        OStream: OutStream;
}

