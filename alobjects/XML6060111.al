xmlport 6060111 "TM Ticket Statistics 2-Dim"
{
    // TM1.39/NPKNAV/20190125  CASE 341335 Transport TM1.39 - 25 January 2019
    // TM1.40/TSA/20190328  CASE 344088 Transport TM1.40 - 28 March 2019

    Caption = 'Ticket Statistics 2-Dim';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(TicketStatistics)
        {
            tableelement(tmpstatisticsrequest;"TM Ticket Access Statistics")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(FromDate;TmpStatisticsRequest."Admission Date")
                {

                    trigger OnBeforePassField()
                    begin
                        TmpStatisticsRequest."Admission Date" := RequestFromDate;
                    end;

                    trigger OnAfterAssignField()
                    begin
                        RequestFromDate := TmpStatisticsRequest."Admission Date";
                    end;
                }
                fieldelement(UntilDate;TmpStatisticsRequest."Admission Date")
                {

                    trigger OnBeforePassField()
                    begin
                        TmpStatisticsRequest."Admission Date" := RequestUntilDate;
                    end;

                    trigger OnAfterAssignField()
                    begin
                        RequestUntilDate := TmpStatisticsRequest."Admission Date";
                    end;
                }
                textelement(DimensionCode1)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(DimensionCode2)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    textelement(ResponseStatus)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ExecutionTime)
                    {
                        MaxOccurs = Once;
                    }
                }
                tableelement(tmpfactlinesresponse;"TM Ticket Access Fact")
                {
                    XmlName = 'Dimension1';
                    SourceTableView = SORTING("Fact Name","Fact Code");
                    UseTemporary = true;
                    fieldattribute(Value;TmpFactLinesResponse."Fact Code")
                    {
                    }
                    fieldattribute(Description;TmpFactLinesResponse.Description)
                    {
                    }
                    tableelement(tmpticketstatisticsresponse;"TM Ticket Access Statistics")
                    {
                        LinkFields = "Item No."=FIELD("Fact Code");
                        LinkTable = TmpFactLinesResponse;
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'Dimension2';
                        UseTemporary = true;
                        fieldattribute(Value;TmpTicketStatisticsResponse."Admission Code")
                        {
                        }
                        textattribute(dim2description)
                        {
                            XmlName = 'Description';

                            trigger OnBeforePassVariable()
                            begin
                                Dim2Description := '';
                                TmpFactDimension2.SetFilter ("Fact Code", '=%1', TmpTicketStatisticsResponse."Admission Code");
                                if (TmpFactDimension2.FindFirst ()) then
                                  Dim2Description := TmpFactDimension2.Description;
                            end;
                        }
                        fieldattribute(AdmissionCount;TmpTicketStatisticsResponse."Admission Count")
                        {
                        }
                        fieldattribute(AdmissionCountReversed;TmpTicketStatisticsResponse."Admission Count (Neg)")
                        {
                        }
                        fieldattribute(ReentryCount;TmpTicketStatisticsResponse."Admission Count (Re-Entry)")
                        {
                        }
                        fieldattribute(SalesCount;TmpTicketStatisticsResponse."Generated Count (Pos)")
                        {
                        }
                        fieldattribute(SalesCountReversed;TmpTicketStatisticsResponse."Generated Count (Neg)")
                        {
                        }
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        RequestUntilDate: Date;
        RequestFromDate: Date;
        StartTime: Time;
        TmpFactDimension2: Record "TM Ticket Access Fact" temporary;

    procedure GetRequest(var FromDate: Date;var UntilDate: Date;var Dim1: Text;var Dim2: Text)
    begin
        FromDate := RequestFromDate;
        UntilDate := RequestUntilDate;
        Dim1 := DimensionCode1;
        Dim2 := DimensionCode2;

        StartTime := Time;
    end;

    procedure SetResponse(var TmpFactLines: Record "TM Ticket Access Fact" temporary;var TmpFactCols: Record "TM Ticket Access Fact" temporary;var TmpStatisticsIn: Record "TM Ticket Access Statistics" temporary)
    begin

        SetErrorResponse (StrSubstNo ('No statistics found for daterange %1..%2', Format (RequestFromDate, 0,9) , Format (RequestUntilDate, 0, 9)));

        // Transfer fact lines
        TmpFactLines.Reset();
        if (not TmpFactLines.FindSet ()) then
          exit;

        repeat
          TmpFactLinesResponse.TransferFields (TmpFactLines, true);
          TmpFactLinesResponse.Insert ();
        until (TmpFactLines.Next () = 0);

        // Transfer fact cols
        TmpFactCols.Reset();
        if (not TmpFactCols.FindSet ()) then
          exit;

        repeat
          TmpFactDimension2.TransferFields (TmpFactCols, true);
          TmpFactDimension2.Insert ();
        until (TmpFactCols.Next () = 0);

        // Transfer data
        TmpStatisticsIn.Reset();
        if (not TmpStatisticsIn.FindSet ()) then
          exit;

        repeat
          TmpTicketStatisticsResponse.TransferFields (TmpStatisticsIn, true);

          if (TmpTicketStatisticsResponse."Variant Code" = '<BLANK>') then
            TmpTicketStatisticsResponse."Variant Code" := '';

          TmpTicketStatisticsResponse.Insert ();

        until (TmpStatisticsIn.Next () = 0);

        ResponseStatus := 'OK';
        ResponseMessage := '';
    end;

    procedure SetErrorResponse(ReasonText: Text)
    begin

        ResponseStatus := 'ERROR';
        ResponseMessage := ReasonText;
        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
    end;
}

