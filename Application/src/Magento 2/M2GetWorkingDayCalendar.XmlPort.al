xmlport 6151137 "NPR M2 Get WorkingDay Calendar"
{
    Caption = 'Get WorkingDay Calendar';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(GetCalendar)
        {
            tableelement(periodrequest; "Entry No. Amount Buffer")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                fieldelement(PeriodStart; PeriodRequest."Start Date")
                {
                }
                fieldelement(PeriodEnd; PeriodRequest."End Date")
                {
                }
                textelement(customernumber)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'CustomerNumber';
                }

                trigger OnBeforeInsertRecord()
                begin
                    PeriodRequest."Entry No." := 1;
                end;
            }
            textelement(Response)
            {
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                    }
                }
                textelement(Calendar)
                {
                    textattribute(BaseCalendarCode)
                    {
                    }
                    tableelement(periodresponse; Date)
                    {
                        XmlName = 'Entry';
                        fieldattribute(Date; PeriodResponse."Period Start")
                        {
                        }
                        fieldattribute(Day; PeriodResponse."Period Name")
                        {
                        }
                        textattribute(WeekNumber)
                        {
                        }
                        textattribute(WorkingDay)
                        {
                        }
                        textattribute(Description)
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            CalendarMgmt: Codeunit "Calendar Management";
                            CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
                        begin
                            CustomizedCalendarChangeTemp."Base Calendar Code" := BaseCalendarCode;
                            CustomizedCalendarChangeTemp."Date" := PeriodResponse."Period Start";
                            CustomizedCalendarChangeTemp.Description := Description;
                            CustomizedCalendarChangeTemp.Insert();

                            CalendarMgmt.CheckDateStatus(CustomizedCalendarChangeTemp);
                            WorkingDay := Format(not CustomizedCalendarChangeTemp.Nonworking, 0, 9);
                            WeekNumber := Format(Date2DWY(PeriodResponse."Period Start", 2), 0, 9);
                        end;
                    }
                }
            }
        }
    }

    procedure PrepareResponse()
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
    begin

        PeriodRequest.FindFirst();
        if (PeriodRequest."Start Date" = 0D) then
            PeriodRequest."Start Date" := Today();

        if (PeriodRequest."End Date" = 0D) then
            PeriodRequest."End Date" := CalcDate('<CM>', Today);

        PeriodResponse.SetFilter("Period Type", '=%1', PeriodResponse."Period Type"::Date);
        PeriodResponse.SetFilter("Period Start", '%1..%2', PeriodRequest."Start Date", PeriodRequest."End Date");

        if (Customer.Get(CustomerNumber)) then
            BaseCalendarCode := Customer."Base Calendar Code";

        if (BaseCalendarCode = '') then begin
            CompanyInformation.Get();
            BaseCalendarCode := CompanyInformation."Base Calendar Code";
        end;

        ResponseCode := 'OK';
        ResponseMessage := '';
    end;
}