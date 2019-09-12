page 6014516 "I-Comm"
{
    // //-NPR4.001.000,Offline - NPE
    //   Added field default dialog path to tab smtp
    // 
    // NPR4.16/JDH/20151103 CASE 226333 removed reference to the old Mail module
    // NPR5.23/BHR/20160426 CASE 222711 Add fields  170, 171 for TDC
    // NPR5.23/LS  /20160513 CASE 226819 Added fields 172..177, Added Publisher function GetPhoneLookupCU, Added OnLookup code on field "Number Info Codeunit ID"
    // NPR5.23/TS/20160613 CASE 244162 Removed fields 47,67,70,71,77,94.
    // NPR5.26/THRO/20160908 CASE 244114 Added SMS Provider - used in SMS Module to determin which provider to send through
    // NPR5.27/TJ/20160928 CASE 248981 Removed fields 9, 10, 12, 13, 16, 17, 35, 46, 51, 55, 57, 58, 59, 63, 64, 65, 76, 78, 79, 80, 81, 82, 84, 89, 92, 93, 95,
    //                                 96, 97, 98, 99, 100, 101, 102, 110, 121, 122, 123 and groups Local Directories, Dataports, GUID, PDF Upload, Invoice
    // NPR5.27/LS  /20161027 CASE 251264 Added new groups "Config. Template" and "PhoneNoLookup" in tab "Name and Numbers"
    // NPR5.47/TS  /20181022 CASE 307097 Removed field  4,7,11,24,74,75,83,85. Fields names are referenced in case
    // NPR5.51/THRO/20190710 CASE 360944 Added SMS Endpoint

    Caption = 'I-Comm Setup';
    SourceTable = "I-Comm";

    layout
    {
        area(content)
        {
            group(Mail)
            {
                Caption = 'Mail';
                group(SMTP)
                {
                    Caption = 'SMTP';
                    field("Local E-Mail Address";"Local E-Mail Address")
                    {
                    }
                    field("Local SMTP Pickup Library";"Local SMTP Pickup Library")
                    {
                    }
                }
            }
            group(SMS)
            {
                Caption = 'SMS';
                field("SMS-Address Postfix";"SMS-Address Postfix")
                {
                }
                field("E-Club Sender";"E-Club Sender")
                {
                }
                field("Tailor Message";"Tailor Message")
                {
                }
                field("Rental Message";"Rental Message")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Reg. Turnover Mobile No.";"Reg. Turnover Mobile No.")
                {
                }
                field("Register Turnover Mobile 2";"Register Turnover Mobile 2")
                {
                }
                field("Register Turnover Mobile 3";"Register Turnover Mobile 3")
                {
                }
                field("SMS Type";"SMS Type")
                {
                }
                group(Control6014407)
                {
                    ShowCaption = false;
                    Visible = ("SMS Type" = "SMS Type"::Endpoint);
                    field("SMS Endpoint";"SMS Endpoint")
                    {
                    }
                }
                field("SMS Provider";"SMS Provider")
                {
                }
            }
            group("Name and Numbers")
            {
                Caption = 'Name and Numbers';
                group(PhoneNoLookup)
                {
                    Caption = 'Phone No. Lookup';
                    field("Use Auto. Cust. Lookup";"Use Auto. Cust. Lookup")
                    {
                    }
                    field("Tunnel URL Address";"Tunnel URL Address")
                    {
                    }
                    field("Number Info Codeunit ID";"Number Info Codeunit ID")
                    {
                        LookupPageID = "All Objects with Caption";

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            TempAllObjWithCaption: Record AllObjWithCaption temporary;
                        begin
                            //-NPR5.23 [226819]
                            GetPhoneLookupCU(TempAllObjWithCaption);
                            if PAGE.RunModal(PAGE::"All Objects with Caption",TempAllObjWithCaption) = ACTION::LookupOK then begin
                              "Number Info Codeunit ID" := TempAllObjWithCaption."Object ID";
                              "Number Info Codeunit Name" := TempAllObjWithCaption."Object Name";
                            end;
                            //+NPR5.23 [226819]
                        end;
                    }
                    field("Number Info Codeunit Name";"Number Info Codeunit Name")
                    {
                        Editable = false;
                    }
                }
                group(ConfigTemplate)
                {
                    Caption = 'Config. Template';
                    field("Config. Template (Customer)";"Config. Template (Customer)")
                    {
                    }
                    field("Config Request (Customer)";"Config Request (Customer)")
                    {
                    }
                    field("Config. Template (Vendor)";"Config. Template (Vendor)")
                    {
                    }
                    field("Config Request (Vendor)";"Config Request (Vendor)")
                    {
                    }
                    field("Config. Template (Contact)";"Config. Template (Contact)")
                    {
                    }
                    field("Config Request (Contact)";"Config Request (Contact)")
                    {
                    }
                }
            }
            group(NAS)
            {
                Caption = 'NAS';
                group(Control6150683)
                {
                    ShowCaption = false;
                    field("NAS - Enabled";"NAS - Enabled")
                    {
                    }
                    field("NAS - Administrator CRM";"NAS - Administrator CRM")
                    {
                    }
                }
            }
            group("External Data")
            {
                Caption = 'External Data';
                group("Document Clearing")
                {
                    Caption = 'Document Clearing';
                    field("Company - Clearing";"Company - Clearing")
                    {
                    }
                    field("Clearing - SQL";"Clearing - SQL")
                    {
                    }
                }
            }
            group("Virtual PDF")
            {
                Caption = 'Virtual PDF';
                field("VirtualPDF Name";"VirtualPDF Name")
                {
                }
                field("Turnover - Email Addresses";"Turnover - Email Addresses")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("Phone no. groups")
                {
                    Caption = 'Phone no. groups';
                    Image = Calls;
                    RunObject = Page "Tax Free Voucher";
                }
            }
        }
    }

    var
        "I-Comm": Codeunit "I-Comm";
        msgConfigFilePDFAppCreate: Label 'Config File successfully created for PDF Application.';
        errConfigFilePDFAppCreate: Label 'Error creating Config File for PDF Application.';
        TextPhoneLook: Label 'Please select appropriate Phone Lookup codeunit ';

    [IntegrationEvent(TRUE, FALSE)]
    procedure GetPhoneLookupCU(var tmpAllObjWithCaption: Record AllObjWithCaption temporary)
    begin
        //NPR5.23 [226819]
    end;
}

