xmlport 6184490 "NPR Pepper Config. XML v3"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created

    Caption = 'Pepper Configuration XML v3';
    Direction = Export;
    Encoding = UTF8;
    FileName = 'C:\Temp\TestConfig.xml';
    UseRequestPage = false;

    schema
    {
        textelement(PepperConfig)
        {
            textattribute(Version)
            {

                trigger OnBeforePassVariable()
                begin
                    Version := '3';
                end;
            }
            textattribute("xmlns:xsi")
            {

                trigger OnBeforePassVariable()
                begin
                    "xmlns:xsi" := 'http://www.w3.org/2001/XMLSchema-instance';
                end;
            }
            textattribute("xsi:noNameSpaceSchemaLocation")
            {

                trigger OnBeforePassVariable()
                begin
                    "xsi:noNameSpaceSchemaLocation" := 'http://www.treibauf.ch/schemata/PepperConfigVersion3.xsd';
                end;
            }
            tableelement("Pepper Instance"; "NPR Pepper Instance")
            {
                XmlName = 'Instance';
                textattribute(id)
                {

                    trigger OnBeforePassVariable()
                    begin
                        PepperConfiguration.Get("Pepper Instance"."Configuration Code");
                        id := Format("Pepper Instance".ID);
                    end;
                }
                textelement(logging)
                {
                    XmlName = 'Logging';
                    textelement(loggingtarget)
                    {
                        XmlName = 'Target';

                        trigger OnBeforePassVariable()
                        begin
                            LoggingTarget := Format(PepperConfiguration."Logging Target");
                        end;
                    }
                    textelement(logginglevel)
                    {
                        XmlName = 'Level';

                        trigger OnBeforePassVariable()
                        begin
                            LoggingLevel := Format(PepperConfiguration."Logging Level");
                        end;
                    }
                    textelement(loggingmaxfilesizeinmb)
                    {
                        XmlName = 'MaxFileSizeInMB';

                        trigger OnBeforePassVariable()
                        begin
                            LoggingMaxFileSizeInMB := Format(PepperConfiguration."Logging Max. File Size (MB)");
                        end;
                    }
                    textelement(loggingusesinglefile)
                    {
                        XmlName = 'UseSingleFile';

                        trigger OnBeforePassVariable()
                        begin
                            LoggingUseSingleFile := 'true';
                        end;
                    }
                    textelement(loggingdirectory)
                    {
                        XmlName = 'Directory';

                        trigger OnBeforePassVariable()
                        begin
                            LoggingDirectory := PepperConfiguration."Logging Directory";
                        end;
                    }
                    textelement(Archive)
                    {
                        textelement(loggingarchivedirectory)
                        {
                            XmlName = 'Directory';

                            trigger OnBeforePassVariable()
                            begin
                                LoggingArchiveDirectory := PepperConfiguration."Logging Archive Directory";
                            end;
                        }
                        textelement(loggingarchivemaxagedays)
                        {
                            XmlName = 'MaxAgeInDays';

                            trigger OnBeforePassVariable()
                            begin
                                LoggingArchiveMaxAgeDays := Format(PepperConfiguration."Logging Archive Max. Age Days");
                            end;
                        }
                    }
                }
                textelement(CardTypes)
                {
                    textelement(cardtypesfile)
                    {
                        XmlName = 'File';

                        trigger OnBeforePassVariable()
                        begin
                            CardTypesFile := PepperConfiguration."Card Type File Full Path";
                        end;
                    }
                }
                textelement(Ticket)
                {
                    textelement(ticketdirectory)
                    {
                        XmlName = 'Directory';

                        trigger OnBeforePassVariable()
                        begin
                            TicketDirectory := PepperConfiguration."Ticket Directory";
                        end;
                    }
                }
                textelement(Journal)
                {
                    textelement(journaldirectory)
                    {
                        XmlName = 'Directory';

                        trigger OnBeforePassVariable()
                        begin
                            JournalDirectory := PepperConfiguration."Journal Directory";
                        end;
                    }
                }
                textelement(Matchbox)
                {
                    textelement(matchboxdirectory)
                    {
                        XmlName = 'Directory';

                        trigger OnBeforePassVariable()
                        begin
                            MatchboxDirectory := PepperConfiguration."Matchbox Directory";
                        end;
                    }
                }
                textelement(Messages)
                {
                    textelement(messagesdirectory)
                    {
                        XmlName = 'Directory';

                        trigger OnBeforePassVariable()
                        begin
                            MessagesDirectory := PepperConfiguration."Messages Directory";
                        end;
                    }
                }
                textelement(Persistence)
                {
                    textelement(persistencedirectory)
                    {
                        XmlName = 'Directory';

                        trigger OnBeforePassVariable()
                        begin
                            PersistenceDirectory := PepperConfiguration."Persistance Directory";
                        end;
                    }
                }
                textelement(Working)
                {
                    textelement(workingdirectory)
                    {
                        XmlName = 'Directory';

                        trigger OnBeforePassVariable()
                        begin
                            WorkingDirectory := PepperConfiguration."Working Directory";
                        end;
                    }
                }
                textelement(Operation)
                {
                    textelement(NewIO)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            NewIO := 'true';
                        end;
                    }
                    textelement(DeprecatedXMLOutput)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            DeprecatedXMLOutput := 'false';
                        end;
                    }
                }
                textelement(License)
                {
                    textelement(licensefile)
                    {
                        XmlName = 'File';

                        trigger OnBeforePassVariable()
                        begin
                            LicenseFile := PepperConfiguration."License File Full Path";
                        end;
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'Pepper Configuration XML v3';

        layout
        {
        }

        actions
        {
        }
    }

    var
        PepperConfiguration: Record "NPR Pepper Config.";
}

