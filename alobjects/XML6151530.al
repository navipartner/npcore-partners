xmlport 6151530 "Collector Request Web Import"
{
    // NC2.01/BR  /20160912  CASE 250447 NaviConnect: Object created
    // NC2.08/BR  /20171123  CASE 297355 Deleted unused variables

    Caption = 'Collector Request Web Import';
    DefaultNamespace = 'urn:microsoft-dynamics-schemas/codeunit/endpointquery_services';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(collectorrequests)
        {
            textelement(insertcollectorrequest)
            {
                textattribute(messageid)
                {
                    Occurrence = Optional;
                }
                tableelement("Nc Collector Request";"Nc Collector Request")
                {
                    MinOccurs = Zero;
                    XmlName = 'collectorrequest';
                    UseTemporary = true;
                    fieldelement(no;"Nc Collector Request"."No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(name;"Nc Collector Request".Name)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(tableno;"Nc Collector Request"."Table No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(senderdatabasename;"Nc Collector Request"."Database Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(sendercompanyname;"Nc Collector Request"."Company Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(senderuserid;"Nc Collector Request"."User ID")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(onlynewandmodified;"Nc Collector Request"."Only New and Modified Records")
                    {
                        MinOccurs = Zero;
                    }
                    tableelement("Nc Collector Request Filter";"Nc Collector Request Filter")
                    {
                        LinkFields = "Nc Collector Request No."=FIELD("No.");
                        LinkTable = "Nc Collector Request";
                        MinOccurs = Zero;
                        XmlName = 'endpointqueryfilter';
                        UseTemporary = true;
                        fieldelement(tableno;"Nc Collector Request Filter"."Table No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(fieldno;"Nc Collector Request Filter"."Field No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(filtertext;"Nc Collector Request Filter"."Filter Text")
                        {
                            MinOccurs = Zero;
                        }
                    }
                }
            }
            tableelement(Integer;Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'return';
                SourceTableView = SORTING(Number) ORDER(Ascending) WHERE(Number=CONST(1));
                textelement(ReturnValue)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
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

    trigger OnPreXmlPort()
    begin
        TempLineNo := 0;
    end;

    var
        TempLineNo: Integer;

    procedure GetMessageID(): Text[50]
    begin
        exit (messageid);
    end;

    procedure GetSummary(): Text[30]
    begin
        //EXIT (STRSUBSTNO ('%1-%2', Testfile, QtySum));
        exit('Testfile');
    end;

    procedure SetCollectorRequestResult(ParReturnValue: Text)
    begin
        //tmpTicketReservationResponse.DELETEALL ();
        //TicketReservationResponse.SETFILTER ("Session Token ID", '=%1', DocumentID);
        //TicketReservationResponse.FINDLAST ();

        //tmpTicketReservationResponse.TRANSFERFIELDS (TicketReservationResponse, TRUE);
        //tmpTicketReservationResponse.INSERT ();
        //tmpTicketReservationResponse.RESET ();
        //COMMIT;

        ReturnValue := ParReturnValue;
    end;

    local procedure FindBooleanOptionValue(InputText: Text): Integer
    begin
        case UpperCase(InputText) of
          'TRUE','YES','1' :  exit(1);
          'FALSE','NO','0' :  exit(0);
          else
            exit(3);
        end;
    end;
}

