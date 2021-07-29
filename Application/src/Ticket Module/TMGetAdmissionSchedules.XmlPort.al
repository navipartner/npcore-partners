xmlport 6014400 "NPR TM Get Admission Schedules"
{
    Caption = 'Admission Schedules';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(admission_schedule)
        {
            textelement(request)
            {
                MaxOccurs = Once;
                tableelement(tmpadmscheduleentryrequest; "NPR TM Admis. Schedule Entry")
                {
                    XmlName = 'admission_schedule_entry';
                    UseTemporary = true;
                    fieldattribute(admission_code; TmpAdmScheduleEntryRequest."Admission Code")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(from_date; TmpAdmScheduleEntryRequest."Admission Start Date")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(until_date; TmpAdmScheduleEntryRequest."Admission End Date")
                    {
                        Occurrence = Optional;
                    }
                    trigger OnBeforeInsertRecord()
                    begin
                        RequestEntryNo += 1;
                        TmpAdmScheduleEntryRequest."Entry No." := RequestEntryNo;
                    end;
                }
            }
            textelement(reponse)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                tableelement(TmpAdmScheduleEntryResponse; "NPR TM Admis. Schedule Entry")
                {
                    XmlName = 'admission_schedule_entry';
                    UseTemporary = true;
                    fieldattribute(admission_code; TmpAdmScheduleEntryResponse."Admission Code")
                    {
                    }
                    fieldattribute(schedule_code; TmpAdmScheduleEntryResponse."Schedule Code")
                    {
                    }
                    fieldattribute(external_entry_no; TmpAdmScheduleEntryResponse."External Schedule Entry No.")
                    {
                    }
                    textattribute(VisibleOnWeb)
                    {
                        XmlName = 'visible_on_web';

                        trigger OnBeforePassVariable()
                        begin
                            case TmpAdmScheduleEntryResponse."Visibility On Web" of
                                TmpAdmScheduleEntryResponse."Visibility On Web"::HIDDEN:
                                    VisibleOnWeb := 'hidden';
                                TmpAdmScheduleEntryResponse."Visibility On Web"::VISIBLE:
                                    VisibleOnWeb := 'visible';
                            end;
                        end;
                    }

                    fieldattribute(start_date; TmpAdmScheduleEntryResponse."Admission Start Date")
                    {
                    }
                    fieldattribute(start_time; TmpAdmScheduleEntryResponse."Admission Start Time")
                    {
                    }
                    fieldattribute(end_date; TmpAdmScheduleEntryResponse."Admission End Date")
                    {
                    }
                    fieldattribute(end_time; TmpAdmScheduleEntryResponse."Admission End Time")
                    {
                    }
                    textattribute(allocationby)
                    {
                        XmlName = 'allocation_by';

                        trigger OnBeforePassVariable()
                        begin

                            case TmpAdmScheduleEntryResponse."Allocation By" of
                                TmpAdmScheduleEntryResponse."Allocation By"::CAPACITY:
                                    AllocationBy := 'capacity';
                                TmpAdmScheduleEntryResponse."Allocation By"::WAITINGLIST:
                                    AllocationBy := 'waitinglist';
                            end;
                        end;
                    }

                    fieldattribute(event_arrival_from_time; TmpAdmScheduleEntryResponse."Event Arrival From Time")
                    {
                    }
                    fieldattribute(event_arrival_until_time; TmpAdmScheduleEntryResponse."Event Arrival Until Time")
                    {
                    }
                    fieldattribute(sales_from_date; TmpAdmScheduleEntryResponse."Sales From Date")
                    {
                    }
                    fieldattribute(sales_from_time; TmpAdmScheduleEntryResponse."Sales From Time")
                    {
                    }
                    fieldattribute(sales_until_date; TmpAdmScheduleEntryResponse."Sales Until Date")
                    {
                    }
                    fieldattribute(sales_until_time; TmpAdmScheduleEntryResponse."Sales Until Time")
                    {
                    }
                }
            }
        }
    }

    var
        RequestEntryNo: Integer;

    procedure CreateResponse()
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (not TmpAdmScheduleEntryRequest.FindSet()) then
            exit;

        repeat
            if (TmpAdmScheduleEntryRequest."Admission Start Date" = 0D) then
                TmpAdmScheduleEntryRequest."Admission Start Date" := TODAY;

            if (TmpAdmScheduleEntryRequest."Admission End Date" = 0D) then
                TmpAdmScheduleEntryRequest."Admission End Date" := TODAY;

            if (TmpAdmScheduleEntryRequest."Admission End Date" < TmpAdmScheduleEntryRequest."Admission Start Date") then
                TmpAdmScheduleEntryRequest."Admission End Date" := TmpAdmScheduleEntryRequest."Admission Start Date";

            if (TmpAdmScheduleEntryRequest."Admission Code" <> '') then begin
                AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TmpAdmScheduleEntryRequest."Admission Code");
                AdmissionScheduleEntry.SetFilter("Admission Start Date", '%1..%2', TmpAdmScheduleEntryRequest."Admission Start Date", TmpAdmScheduleEntryRequest."Admission End Date");
                AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                if (AdmissionScheduleEntry.FindSet()) then begin
                    repeat
                        TmpAdmScheduleEntryResponse.TransferFields(AdmissionScheduleEntry, true);
                        if (not TmpAdmScheduleEntryResponse.Insert()) then
                            ;
                    until (AdmissionScheduleEntry.Next() = 0);
                end;
            end;

        until (TmpAdmScheduleEntryRequest.Next() = 0);

        TmpAdmScheduleEntryResponse.FindFirst();
    end;
}