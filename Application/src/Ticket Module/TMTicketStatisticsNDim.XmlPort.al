xmlport 6060110 "NPR TM Ticket Statistics N-Dim"
{
    // TM1.39/NPKNAV/20190125  CASE 341335 Transport TM1.39 - 25 January 2019
    // TM1.40/TSA/20190328  CASE 344088 Transport TM1.40 - 28 March 2019

    Caption = 'Ticket Statistics N-Dim';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(TicketStatistics)
        {
            tableelement(tmpstatisticsrequest; "NPR TM Ticket Access Stats")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(FromDate; TmpStatisticsRequest."Admission Date")
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
                fieldelement(UntilDate; TmpStatisticsRequest."Admission Date")
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
                textelement(Statistics)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(ticketstatisticsresponse; "NPR TM Ticket Access Stats")
                    {
                        XmlName = 'Fact';
                        UseTemporary = true;
                        fieldelement(AdmissionDate; TicketStatisticsResponse."Admission Date")
                        {
                        }
                        fieldelement(AdmissionHour; TicketStatisticsResponse."Admission Hour")
                        {
                        }
                        textelement(Ticket)
                        {
                            fieldattribute(Code; TicketStatisticsResponse."Item No.")
                            {
                            }
                        }
                        textelement(TicketVariant)
                        {
                            fieldattribute(Code; TicketStatisticsResponse."Variant Code")
                            {
                            }
                        }
                        textelement(Admission)
                        {
                            fieldattribute(Code; TicketStatisticsResponse."Admission Code")
                            {
                            }
                        }
                        textelement(TicketType)
                        {
                            fieldattribute(Code; TicketStatisticsResponse."Ticket Type")
                            {
                            }
                        }
                        textelement(Metrics)
                        {
                            fieldattribute(AdmissionCount; TicketStatisticsResponse."Admission Count")
                            {
                            }
                            fieldattribute(AdmissionCountReversed; TicketStatisticsResponse."Admission Count (Neg)")
                            {
                            }
                            fieldattribute(ReentryCount; TicketStatisticsResponse."Admission Count (Re-Entry)")
                            {
                            }
                            fieldattribute(SalesCount; TicketStatisticsResponse."Generated Count (Pos)")
                            {
                            }
                            fieldattribute(SalesCountReversed; TicketStatisticsResponse."Generated Count (Neg)")
                            {
                            }
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

    procedure GetRequest(var FromDate: Date; var UntilDate: Date)
    begin
        FromDate := RequestFromDate;
        UntilDate := RequestUntilDate;
        StartTime := Time;
    end;

    procedure SetResponse(var TmpTicketAccessStatistics: Record "NPR TM Ticket Access Stats" temporary)
    var
        StatisticsNotFoundLbl: Label 'No statistics found for daterange %1..%2';
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;
    begin
        ResponseStatus := 'ERROR';
        ResponseMessage := StrSubstNo(StatisticsNotFoundLbl, Format(RequestFromDate, 0, 9), Format(RequestUntilDate, 0, 9));
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));

        TmpTicketAccessStatistics.Reset();
        if (TmpTicketAccessStatistics.FindSet()) then begin
            ResponseStatus := 'OK';
            ResponseMessage := '';

            repeat
                TicketStatisticsResponse.TransferFields(TmpTicketAccessStatistics, true);
                if (TicketStatisticsResponse."Variant Code" = '<BLANK>') then
                    TicketStatisticsResponse."Variant Code" := '';

                TicketStatisticsResponse.Insert();

            until (TmpTicketAccessStatistics.Next() = 0);
        end;
    end;
}

