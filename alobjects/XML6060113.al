xmlport 6060113 "TM Admission Capacity Check"
{
    // TM1.24/TSA /20170824 CASE 287582 First Version
    // TM1.37/TSA /20180926 CASE 327324 Refactored to use "Event Arrival From Time"
    // #334163/JDH /20181108 CASE 334163 Adding missing Captions
    // TM1.39/NPKNAV/20190125  CASE 343941 Transport TM1.39 - 25 January 2019
    // TM1.41/TSA /20190411 CASE 351846 Fixed the "event arrival from time" bug
    // TM1.41/TSA/20190527  CASE 353981 Transport TM1.41 - 27 May 2019

    Caption = 'TM Admission Capacity Check';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(admission_capacity)
        {
            textelement(request)
            {
                MaxOccurs = Once;
                tableelement(tmpadmscheduleentryrequest;"TM Admission Schedule Entry")
                {
                    XmlName = 'admission_schedule_entry';
                    UseTemporary = true;
                    fieldattribute(external_entry_no;TmpAdmScheduleEntryRequest."External Schedule Entry No.")
                    {
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
                tableelement(tmpadmscheduleentryresponse;"TM Admission Schedule Entry")
                {
                    XmlName = 'admission_schedule_entry';
                    UseTemporary = true;
                    fieldattribute(external_entry_no;TmpAdmScheduleEntryResponse."External Schedule Entry No.")
                    {
                    }
                    textattribute(responsestatus)
                    {
                        XmlName = 'status';

                        trigger OnBeforePassVariable()
                        begin
                            ResponseStatus := Format((CapacityStatusCode = 1), 0, 9);
                        end;
                    }
                    textattribute(responseremaining)
                    {
                        XmlName = 'remaining';

                        trigger OnBeforePassVariable()
                        begin
                            ResponseRemaining := Format(RemainingCapacity, 0, 9);
                        end;
                    }
                    textattribute(responsemessage)
                    {
                        XmlName = 'message';

                        trigger OnBeforePassVariable()
                        begin
                            case CapacityStatusCode of
                               1: ResponseMessage := 'Ok.';
                              -1: ResponseMessage := 'Capacity exceeded.';
                              -2: ResponseMessage := 'The schedule does not allow admissions at this time.';
                              -3: ResponseMessage := 'Unexpected problem with capacity calculation, invalid parameters?';
                              -4: ResponseMessage := 'The external schedule id is invalid or all schedules have been cancelled.';
                              -5: ResponseMessage := 'The admission schedule indicated that admission is closed.';
                              else
                                ResponseMessage := StrSubstNo ('Capacity Status Code %1 does not have a dedicated message yet.', CapacityStatusCode);
                            end;
                        end;
                    }
                    textattribute(priceoption)
                    {
                        XmlName = 'price_option';
                    }
                    textattribute(amount)
                    {
                        XmlName = 'price_amount';
                    }
                    textattribute(percentage)
                    {
                        XmlName = 'price_percentage';
                    }
                    textattribute(includesvat)
                    {
                        XmlName = 'includes_vat';
                    }

                    trigger OnAfterGetRecord()
                    var
                        MaxCapacity: Integer;
                        CapacityControl: Option;
                        Admission: Record "TM Admission";
                        TicketManagement: Codeunit "TM Ticket Management";
                        AdmissionScheduleLines: Record "TM Admission Schedule Lines";
                    begin
                        with TmpAdmScheduleEntryResponse do begin

                          RemainingCapacity := 0;
                          CapacityStatusCode := 1;

                          if ("Admission Code" = '') then
                            CapacityStatusCode := -4;

                          if ("Schedule Code" = '') then
                            CapacityStatusCode := -4;

                            if ("Entry No." < 1) then
                            CapacityStatusCode := -4;

                          if (CapacityStatusCode <> 1 ) then
                            exit;

                          if (TicketManagement.GetMaxCapacity ("Admission Code", "Schedule Code", "Entry No.", MaxCapacity, CapacityControl)) then begin
                            CalcFields ("Open Reservations", "Open Admitted", "Initial Entry");

                            case CapacityControl of
                              Admission."Capacity Control"::ADMITTED :
                                begin
                                  RemainingCapacity := MaxCapacity - "Open Admitted" - "Open Reservations";
                                  SetCapacityStatusCode ();
                                end;

                              Admission."Capacity Control"::FULL :
                                begin
                                  RemainingCapacity :=  MaxCapacity - "Open Admitted" - "Open Reservations";
                                  SetCapacityStatusCode ();
                                end;

                              Admission."Capacity Control"::NONE :
                                begin
                                  RemainingCapacity :=  -1;
                                  CapacityStatusCode := 1;
                                end;

                              Admission."Capacity Control"::SALES :
                                begin
                                  RemainingCapacity := MaxCapacity - "Initial Entry";
                                  SetCapacityStatusCode ();
                                end;
                            end;
                            //-TM1.37 [327324]
                            //    IF ("Admission Start Date" = TODAY) THEN BEGIN
                            //      IF ("Bookable Passed Start (Secs)" = 0) AND ("Admission End Time"  < TIME) THEN BEGIN
                            //        RemainingCapacity := 0;
                            //        CapacityStatusCode := -2
                            //      END;
                            //      IF ("Bookable Passed Start (Secs)" <> 0) AND (("Admission Start Time" + "Bookable Passed Start (Secs)"*1000) < TIME) THEN BEGIN
                            //        RemainingCapacity := 0;
                            //        CapacityStatusCode := -2
                            //      END;
                            //    END;

                            if ("Admission Start Date" = Today) then begin
                              if (("Event Arrival From Time" = 0T) and ("Admission End Time" < Time)) then begin
                                RemainingCapacity := 0;
                                CapacityStatusCode := -2;
                              end;
                              //-TM1.41 [351846]
                              // IF ("Event Arrival From Time" <> 0T) AND (("Event Arrival From Time" < TIME)) THEN BEGIN
                              //   RemainingCapacity := 0;
                              //  CapacityStatusCode := -2;
                              // END;
                              if ("Event Arrival From Time" <> 0T) and ((Time < "Event Arrival From Time")) then begin
                                RemainingCapacity := 0;
                                CapacityStatusCode := -2;
                              end;
                              if ("Event Arrival Until Time" <> 0T) and ((Time > "Event Arrival Until Time")) then begin
                                RemainingCapacity := 0;
                                CapacityStatusCode := -2;
                              end;
                              //+TM1.41 [351846]

                            end;
                            //+TM1.37 [327324]

                            if ("Admission Start Date" < Today) then begin
                              RemainingCapacity := 0;
                              CapacityStatusCode := -2;
                            end;

                            if ("Admission Is" = "Admission Is"::CLOSED) then begin
                              RemainingCapacity := 0;
                              CapacityStatusCode := -5;
                            end;

                          end else begin
                            RemainingCapacity := 0;
                            CapacityStatusCode := -3;
                          end;

                          //-TM1.41 [353981]
                          PriceOption := '';
                          Amount := '';
                          Percentage := '';
                          IncludesVAT := '';
                          if (AdmissionScheduleLines.Get ("Admission Code", "Schedule Code")) then begin
                            if (AdmissionScheduleLines."Price Scope" in [AdmissionScheduleLines."Price Scope"::API, AdmissionScheduleLines."Price Scope"::API_POS_M2]) then begin
                              case AdmissionScheduleLines."Pricing Option" of
                                AdmissionScheduleLines."Pricing Option"::NA : PriceOption := '';
                                AdmissionScheduleLines."Pricing Option"::FIXED : PriceOption := 'fixed_amount';
                                AdmissionScheduleLines."Pricing Option"::RELATIVE : PriceOption := 'relative_amount';
                                AdmissionScheduleLines."Pricing Option"::PERCENT : PriceOption := 'percentage'
                              end;
                              Amount := Format (AdmissionScheduleLines.Amount, 0, 9);
                              Percentage := Format (AdmissionScheduleLines.Percentage, 0, 9);
                              IncludesVAT := Format (AdmissionScheduleLines."Amount Includes VAT", 0, 9);
                            end;
                          end;
                          //+TM1.41 [353981]

                        end;
                    end;
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
        RequestEntryNo: Integer;
        RemainingCapacity: Integer;
        CapacityStatusCode: Integer;

    procedure AddResponse()
    begin
        if (not TmpAdmScheduleEntryRequest.FindSet ()) then
          exit;

        repeat
          TmpAdmScheduleEntryResponse.TransferFields (TmpAdmScheduleEntryRequest, true);
          GetEntry (TmpAdmScheduleEntryResponse);
          TmpAdmScheduleEntryResponse.Insert ();

        until (TmpAdmScheduleEntryRequest.Next () = 0);
    end;

    local procedure GetEntry(var TmpAdmissionScheduleEntry: Record "TM Admission Schedule Entry" temporary)
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
    begin
        if (TmpAdmissionScheduleEntry."External Schedule Entry No." < 1) then
          exit;

        AdmissionScheduleEntry.SetFilter ("External Schedule Entry No.", '=%1', TmpAdmissionScheduleEntry."External Schedule Entry No.");
        AdmissionScheduleEntry.SetFilter (Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindFirst ()) then
          exit;

        TmpAdmissionScheduleEntry.TransferFields (AdmissionScheduleEntry, true);
    end;

    local procedure SetCapacityStatusCode()
    begin
        CapacityStatusCode := 1;
        if (RemainingCapacity < 1) then begin
          RemainingCapacity := 0;
          CapacityStatusCode := -1;
        end;
    end;
}

