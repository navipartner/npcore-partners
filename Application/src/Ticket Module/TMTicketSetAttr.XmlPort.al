xmlport 6060121 "NPR TM Ticket Set Attr."
{
    Caption = 'TM Ticket Set Attributes';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;

    schema
    {
        textelement(tickets)
        {
            tableelement(tmpticketreservationrequest; "NPR TM Ticket Reservation Req.")
            {
                MaxOccurs = Once;
                XmlName = 'setattributes';
                UseTemporary = true;
                fieldattribute(token; TmpTicketReservationRequest."Session Token ID")
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
                    tableelement(tmpattributevalueset; "NPR Attribute Value Set")
                    {
                        XmlName = 'attribute';
                        UseTemporary = true;
                        fieldattribute(admission_code; TmpTicketReservationRequest."Admission Code")
                        {
                            Occurrence = Optional;

                            trigger OnBeforePassField()
                            begin
                                // To get the read back correct, since the there is no relation maintained for the different levels
                                TmpTicketReservationRequest."Admission Code" := AdmissionCodeArray[TmpAttributeValueSet."Attribute Set ID"];
                            end;

                            trigger OnAfterAssignField()
                            begin
                                // To get the read back correct, since the there is no relation maintained for the different levels
                                AdmissionCodeArray[EntryNo + 1] := TmpTicketReservationRequest."Admission Code";
                            end;
                        }
                        fieldattribute(attribute_code; TmpAttributeValueSet."Attribute Code")
                        {
                        }
                        fieldattribute(attribute_value; TmpAttributeValueSet."Text Value")
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
        ReservationID: Text[100];
        AdmissionCodeArray: array[100] of Code[20];

    procedure GetToken(): Text[100]
    begin
        exit(ReservationID);
    end;

    procedure SetResult(SuccessIn: Boolean; DocumentID: Text[100]; ResponseMessageIn: Text)
    begin
        success := Format(SuccessIn, 0, 9);
        if (not SuccessIn) then
            ResponseMessage := ResponseMessageIn;
    end;

    procedure GetResponseMessage(var ResponseMessageOut: Text)
    begin
        ResponseMessageOut := ResponseMessage;
    end;
}

