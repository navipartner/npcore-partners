page 6014516 "NPR I-Comm"
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

    UsageCategory = None;
    Caption = 'I-Comm Setup';
    SourceTable = "NPR I-Comm";

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
                    field("Local E-Mail Address"; "Local E-Mail Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Local E-Mail Adress field';
                    }
                    field("Local SMTP Pickup Library"; "Local SMTP Pickup Library")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Local SMTP ''Pickup'' library field';
                    }
                }
            }
            group(SMS)
            {
                Caption = 'SMS';
                field("SMS-Address Postfix"; "SMS-Address Postfix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS-Address Postfix field';
                }
                field("E-Club Sender"; "E-Club Sender")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Club Sender field';
                }
                field("Tailor Message"; "Tailor Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tailor Message field';
                }
                field("Rental Message"; "Rental Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rental Message field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Reg. Turnover Mobile No."; "Reg. Turnover Mobile No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Reg. Turnover Mobile No. field';
                }
                field("Register Turnover Mobile 2"; "Register Turnover Mobile 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register Turnover Mobile 2 field';
                }
                field("Register Turnover Mobile 3"; "Register Turnover Mobile 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register Turnover Mobile 3 field';
                }
                field("SMS Type"; "SMS Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sms type field';
                }
                group(Control6014407)
                {
                    ShowCaption = false;
                    Visible = ("SMS Type" = "SMS Type"::Endpoint);
                    field("SMS Endpoint"; "SMS Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the SMS Endpoint field';
                    }
                }
                field("SMS Provider"; "SMS Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SMS Provider field';
                }
            }
            group("Name and Numbers")
            {
                Caption = 'Name and Numbers';
                group(PhoneNoLookup)
                {
                    Caption = 'Phone No. Lookup';
                    field("Use Auto. Cust. Lookup"; "Use Auto. Cust. Lookup")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enable Number Info Lookup field';
                    }
                    field("Tunnel URL Address"; "Tunnel URL Address")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Tunnel URL Address field';
                    }
                    field("Number Info Codeunit ID"; "Number Info Codeunit ID")
                    {
                        ApplicationArea = All;
                        LookupPageID = "All Objects with Caption";
                        ToolTip = 'Specifies the value of the Number Info Codeunit ID field';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            TempAllObjWithCaption: Record AllObjWithCaption temporary;
                        begin
                            //-NPR5.23 [226819]
                            GetPhoneLookupCU(TempAllObjWithCaption);
                            if PAGE.RunModal(PAGE::"All Objects with Caption", TempAllObjWithCaption) = ACTION::LookupOK then begin
                                "Number Info Codeunit ID" := TempAllObjWithCaption."Object ID";
                                "Number Info Codeunit Name" := TempAllObjWithCaption."Object Name";
                            end;
                            //+NPR5.23 [226819]
                        end;
                    }
                    field("Number Info Codeunit Name"; "Number Info Codeunit Name")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the value of the Number Info Codeunit Name field';
                    }
                }
                group(ConfigTemplate)
                {
                    Caption = 'Config. Template';
                    field("Config. Template (Customer)"; "Config. Template (Customer)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Config. Template (Customer) field';
                    }
                    field("Config Request (Customer)"; "Config Request (Customer)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Config Request (Customer) field';
                    }
                    field("Config. Template (Vendor)"; "Config. Template (Vendor)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Config. Template (Vendor) field';
                    }
                    field("Config Request (Vendor)"; "Config Request (Vendor)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Config Request (Vendor) field';
                    }
                    field("Config. Template (Contact)"; "Config. Template (Contact)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Config. Template (Contact) field';
                    }
                    field("Config Request (Contact)"; "Config Request (Contact)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Config Request (Contact) field';
                    }
                }
            }
            group(NAS)
            {
                Caption = 'NAS';
                group(Control6150683)
                {
                    ShowCaption = false;
                    field("NAS - Enabled"; "NAS - Enabled")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NAS - Enabled field';
                    }
                    field("NAS - Administrator CRM"; "NAS - Administrator CRM")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the NAS - Administrator CRM field';
                    }
                }
            }
            group("External Data")
            {
                Caption = 'External Data';
                group("Document Clearing")
                {
                    Caption = 'Document Clearing';
                    field("Company - Clearing"; "Company - Clearing")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Company field';
                    }
                    field("Clearing - SQL"; "Clearing - SQL")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Clearing through SQL field';
                    }
                }
            }
            group("Virtual PDF")
            {
                Caption = 'Virtual PDF';
                field("VirtualPDF Name"; "VirtualPDF Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VirtualPDF Name field';
                }
                field("Turnover - Email Addresses"; "Turnover - Email Addresses")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnover - Email Addresses field';
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
                    RunObject = Page "NPR Tax Free Voucher";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Phone no. groups action';
                }
            }
        }
    }

    var
        msgConfigFilePDFAppCreate: Label 'Config File successfully created for PDF Application.';
        errConfigFilePDFAppCreate: Label 'Error creating Config File for PDF Application.';
        TextPhoneLook: Label 'Please select appropriate Phone Lookup codeunit ';

    [IntegrationEvent(TRUE, FALSE)]
    procedure GetPhoneLookupCU(var tmpAllObjWithCaption: Record AllObjWithCaption temporary)
    begin
        //NPR5.23 [226819]
    end;
}

