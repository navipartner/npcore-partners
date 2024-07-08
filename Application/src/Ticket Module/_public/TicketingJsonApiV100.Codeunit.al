codeunit 6151003 "NPR TicketingJsonApiV100"
{
    procedure GetTicketAdmissionBom(ItemNo: Code[20]; VariantCode: code[10]) JArray: JsonArray
    begin
        exit(GetTicketAdmissionBomData(ItemNo, VariantCode));
    end;

    procedure GetAdmission(AdmissionCode: Code[20]) JObject: JsonObject
    begin
        exit(GetAdmissionData(AdmissionCode));
    end;

    procedure GetAdmissionScheduleEntry(AdmissionCode: Code[20]) JArray: JsonArray
    begin
        exit(GetAdmissionScheduleEntryData(AdmissionCode));
    end;

    local procedure GetTicketAdmissionBomData(ItemNo: Code[20]; VariantCode: code[10]) JArray: JsonArray
    var
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        JObject: JsonObject;
    begin
        TicketBOM.SetRange("Item No.", ItemNo);
        TicketBOM.SetRange("Variant Code", VariantCode);
        if TicketBOM.FindSet() then begin
            repeat
                Clear(JObject);
                JObject.Add('admissionCode', TicketBOM."Admission Code");
                JObject.Add('quantity', TicketBOM.Quantity);
                JObject.Add('description', TicketBOM.Description);
                JObject.Add('admissionDescription', TicketBOM."Admission Description");
                JArray.Add(JObject);
            until TicketBOM.Next() = 0;

            exit(JArray);
        end
    end;

    local procedure GetAdmissionData(AdmissionCode: Code[20]) JObject: JsonObject
    var
        Admission: Record "NPR TM Admission";
    begin
        if not Admission.Get(AdmissionCode) then
            exit;

        JObject.Add('admissionCode', Admission."Admission Code");
        JObject.Add('type', Format(Admission.Type));
        JObject.Add('defaultSchedule', Format(Admission."Default Schedule"));
        JObject.Add('scheduleRequired', Admission."Default Schedule" = Admission."Default Schedule"::SCHEDULE_ENTRY);
        JObject.Add('description', Admission.Description);
    end;

    local procedure GetAdmissionScheduleEntryData(AdmissionCode: Code[20]) JArray: JsonArray
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        JObject: JsonObject;
    begin
        AdmissionScheduleEntry.SetAutoCalcFields("Initial Entry");
        AdmissionScheduleEntry.SetRange("Admission Code", AdmissionCode);
        AdmissionScheduleEntry.SetRange(Cancelled, false);
        if AdmissionScheduleEntry.FindSet() then begin
            repeat
                Clear(JObject);
                JObject.Add('externalScheduleEntryNo', AdmissionScheduleEntry."External Schedule Entry No.");
                JObject.Add('startDateTime', format(CreateDateTime(AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time"), 0, 9));
                JObject.Add('endDateTime', Format(CreateDateTime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time"), 0, 9));
                JObject.Add('salesFromDateTime', Format(CreateDateTime(AdmissionScheduleEntry."Sales From Date", AdmissionScheduleEntry."Sales From Time"), 0, 9));
                JObject.Add('salesToDateTime', Format(CreateDateTime(AdmissionScheduleEntry."Sales Until Date", AdmissionScheduleEntry."Sales Until Time"), 0, 9));
                JObject.Add('maxCapacityPerSchEntry', AdmissionScheduleEntry."Max Capacity Per Sch. Entry");
                JObject.Add('initialEntry', AdmissionScheduleEntry."Initial Entry");
                JArray.Add(JObject);
            until AdmissionScheduleEntry.Next() = 0;

            exit(JArray);
        end;
    end;
}
