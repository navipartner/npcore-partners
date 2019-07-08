xmlport 6060121 "TM Ticket Set Attributes"
{
    // TM1.23/TSA /20170724 CASE 284752 Initial Version
    // #334163/JDH /20181108 CASE 334163 Adding missing Captions
    // TM1.39/NPKNAV/20190125  CASE 343941 Transport TM1.39 - 25 January 2019

    Caption = 'TM Ticket Set Attributes';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(tickets)
        {
            tableelement(tmpticketreservationrequest;"TM Ticket Reservation Request")
            {
                MaxOccurs = Once;
                XmlName = 'set_attributes';
                UseTemporary = true;
                fieldattribute(token;TmpTicketReservationRequest."Session Token ID")
                {

                    trigger OnAfterAssignField()
                    begin
                        if (ReservationID = '') then
                          ReservationID := TmpTicketReservationRequest."Session Token ID";
                    end;
                }
                textelement(attributes)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tmpattributevalueset;"NPR Attribute Value Set")
                    {
                        XmlName = 'attribute';
                        UseTemporary = true;
                        fieldattribute(admission_code;TmpTicketReservationRequest."Admission Code")
                        {
                            Occurrence = Optional;

                            trigger OnBeforePassField()
                            begin
                                // To get the read back correct, since the there is no relation maintained for the different levels
                                TmpTicketReservationRequest."Admission Code" := AdmissionCodeArray [TmpAttributeValueSet."Attribute Set ID"];
                            end;

                            trigger OnAfterAssignField()
                            begin
                                // To get the read back correct, since the there is no relation maintained for the different levels
                                AdmissionCodeArray[EntryNo + 1] := TmpTicketReservationRequest."Admission Code";
                            end;
                        }
                        fieldattribute(attribute_code;TmpAttributeValueSet."Attribute Code")
                        {
                        }
                        fieldattribute(attribute_value;TmpAttributeValueSet."Text Value")
                        {
                        }

                        trigger OnBeforeInsertRecord()
                        begin
                            EntryNo += 1;
                            TmpAttributeValueSet."Attribute Set ID" := EntryNo;
                        end;
                    }
                }
            }
            textelement(set_attribute_result)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(success)
                {
                }
                textelement(responsemessage)
                {
                    XmlName = 'message';
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
        EntryNo: Integer;
        ReservationID: Text[50];
        AdmissionCodeArray: array [100] of Code[20];

    procedure GetToken(): Text[50]
    begin
        exit (ReservationID);
    end;

    procedure SetResult(SuccessIn: Boolean;DocumentID: Text[50];ResponseMessageIn: Text)
    begin
        success := Format (SuccessIn, 0, 9);
        if (not SuccessIn) then
          ResponseMessage := ResponseMessageIn;
    end;
}

