xmlport 6014674 "NPR Endpoint Query Web Import"
{
    // NPR5.22\BR\20160323  CASE 182391 Object Created
    // NPR5.25\BR\20160429  CASE 237658 Lowercased all tags (conform NPXML export). Changed attributes to elements
    // NPR5.25\BR \20160704 CASE 246088 Added many extra fileds from the Item Table
    // NPR5.48/JDH /20181108 CASE 334163 Adding missing Captions

    Caption = 'Endpoint Query Web Import';
    DefaultNamespace = 'urn:microsoft-dynamics-schemas/codeunit/endpointquery_services';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(endpointqueries)
        {
            textelement(insertendpointquery)
            {
                textattribute(messageid)
                {
                    Occurrence = Optional;
                }
                tableelement("Endpoint Query"; "NPR Endpoint Query")
                {
                    MinOccurs = Zero;
                    XmlName = 'endpointquery';
                    UseTemporary = true;
                    fieldelement(no; "Endpoint Query"."External No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(name; "Endpoint Query".Name)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(tableno; "Endpoint Query"."Table No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(senderdatabasename; "Endpoint Query"."Database Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(sendercompanyname; "Endpoint Query"."Company Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(senderuserid; "Endpoint Query"."User ID")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(onlynewandmodified; "Endpoint Query"."Only New and Modified Records")
                    {
                        MinOccurs = Zero;
                    }
                    tableelement("Endpoint Query Filter"; "NPR Endpoint Query Filter")
                    {
                        LinkFields = "Endpoint Query No." = FIELD("No.");
                        LinkTable = "Endpoint Query";
                        MinOccurs = Zero;
                        XmlName = 'endpointqueryfilter';
                        UseTemporary = true;
                        fieldelement(tableno; "Endpoint Query Filter"."Table No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(fieldno; "Endpoint Query Filter"."Field No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(filtertext; "Endpoint Query Filter"."Filter Text")
                        {
                            MinOccurs = Zero;
                        }
                    }
                }
            }
            tableelement(Integer; Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'return';
                SourceTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
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
    end;


    procedure GetMessageID(): Text[50]
    begin
        exit(messageid);
    end;

    procedure GetSummary(): Text[30]
    begin
        //EXIT (STRSUBSTNO ('%1-%2', Testfile, QtySum));
        exit('Testfile');
    end;

    procedure SetEndpointQueryResult(ParReturnValue: Text)
    begin
        //tmpTicketReservationResponse.DELETEALL ();
        //TicketReservationResponse.SETFILTER ("Session Token ID", '=%1', DocumentID);
        //TicketReservationResponse.FindLast() ();

        //tmpTicketReservationResponse.TRANSFERFIELDS (TicketReservationResponse, TRUE);
        //tmpTicketReservationResponse.INSERT ();
        //tmpTicketReservationResponse.RESET ();
        //Commit();

        ReturnValue := ParReturnValue;
    end;
}

