xmlport 6151530 "NPR Collector Req. Web Imp."
{
    Caption = 'Collector Request Web Import';
    DefaultNamespace = 'urn:microsoft-dynamics-schemas/codeunit/endpointquery_services';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

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
                tableelement("Nc Collector Request"; "NPR Nc Collector Request")
                {
                    MinOccurs = Zero;
                    XmlName = 'collectorrequest';
                    UseTemporary = true;
                    fieldelement(no; "Nc Collector Request"."No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(name; "Nc Collector Request".Name)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(tableno; "Nc Collector Request"."Table No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(senderdatabasename; "Nc Collector Request"."Database Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(sendercompanyname; "Nc Collector Request"."Company Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(senderuserid; "Nc Collector Request"."User ID")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(onlynewandmodified; "Nc Collector Request"."Only New and Modified Records")
                    {
                        MinOccurs = Zero;
                    }
                    tableelement("Nc Collector Request Filter"; "NPR Nc Collector Req. Filter")
                    {
                        LinkFields = "Nc Collector Request No." = FIELD("No.");
                        LinkTable = "Nc Collector Request";
                        MinOccurs = Zero;
                        XmlName = 'endpointqueryfilter';
                        UseTemporary = true;
                        fieldelement(tableno; "Nc Collector Request Filter"."Table No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(fieldno; "Nc Collector Request Filter"."Field No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(filtertext; "Nc Collector Request Filter"."Filter Text")
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

    trigger OnPreXmlPort()
    begin
    end;


    [Obsolete('Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.', 'BC 20 - Task Queue deprecating starting from 28/06/2022')]
    internal procedure GetMessageID(): Text[50]
    begin
        exit(messageid);
    end;

    [Obsolete('Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.', 'BC 20 - Task Queue deprecating starting from 28/06/2022')]
    internal procedure SetCollectorRequestResult(ParReturnValue: Text)
    begin
        ReturnValue := ParReturnValue;
    end;
}

