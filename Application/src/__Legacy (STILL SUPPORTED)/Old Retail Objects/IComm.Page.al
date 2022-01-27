page 6014516 "NPR I-Comm"
{
    Extensible = False;
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
                    field("Local E-Mail Address"; Rec."Local E-Mail Address")
                    {

                        ToolTip = 'Specifies the value of the Local E-Mail Adress field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Local SMTP Pickup Library"; Rec."Local SMTP Pickup Library")
                    {

                        ToolTip = 'Specifies the value of the Local SMTP ''Pickup'' library field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(SMS)
            {
                Caption = 'SMS';
                field("SMS-Address Postfix"; Rec."SMS-Address Postfix")
                {

                    ToolTip = 'Specifies the value of the SMS-Address Postfix field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Club Sender"; Rec."E-Club Sender")
                {

                    ToolTip = 'Specifies the value of the E-Club Sender field';
                    ApplicationArea = NPRRetail;
                }
                field("Tailor Message"; Rec."Tailor Message")
                {

                    ToolTip = 'Specifies the value of the Tailor Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Rental Message"; Rec."Rental Message")
                {

                    ToolTip = 'Specifies the value of the Rental Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reg. Turnover Mobile No."; Rec."Reg. Turnover Mobile No.")
                {

                    ToolTip = 'Specifies the value of the Cash Reg. Turnover Mobile No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Register Turnover Mobile 2"; Rec."Register Turnover Mobile 2")
                {

                    ToolTip = 'Specifies the value of the Cash Register Turnover Mobile 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Register Turnover Mobile 3"; Rec."Register Turnover Mobile 3")
                {

                    ToolTip = 'Specifies the value of the Cash Register Turnover Mobile 3 field';
                    ApplicationArea = NPRRetail;
                }
                field("SMS Type"; Rec."SMS Type")
                {

                    ToolTip = 'Specifies the value of the Sms type field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6014407)
                {
                    ShowCaption = false;
                    Visible = (Rec."SMS Type" = Rec."SMS Type"::Endpoint);
                    field("SMS Endpoint"; Rec."SMS Endpoint")
                    {

                        ToolTip = 'Specifies the value of the SMS Endpoint field';
                        ApplicationArea = NPRRetail;
                    }
                }
                field("SMS Provider"; Rec."SMS Provider")
                {

                    ToolTip = 'Specifies the value of the SMS Provider field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Name and Numbers")
            {
                Caption = 'Name and Numbers';
                group(PhoneNoLookup)
                {
                    Caption = 'Phone No. Lookup';
                    field("Use Auto. Cust. Lookup"; Rec."Use Auto. Cust. Lookup")
                    {

                        ToolTip = 'Specifies the value of the Enable Number Info Lookup field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Tunnel URL Address"; Rec."Tunnel URL Address")
                    {

                        ToolTip = 'Specifies the value of the Tunnel URL Address field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Number Info Codeunit ID"; Rec."Number Info Codeunit ID")
                    {

                        LookupPageID = "All Objects with Caption";
                        ToolTip = 'Specifies the value of the Number Info Codeunit ID field';
                        ApplicationArea = NPRRetail;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            TempAllObjWithCaption: Record AllObjWithCaption temporary;
                        begin
                            //-NPR5.23 [226819]
                            GetPhoneLookupCU(TempAllObjWithCaption);
                            if PAGE.RunModal(PAGE::"All Objects with Caption", TempAllObjWithCaption) = ACTION::LookupOK then begin
                                Rec."Number Info Codeunit ID" := TempAllObjWithCaption."Object ID";
                                Rec."Number Info Codeunit Name" := TempAllObjWithCaption."Object Name";
                            end;
                            //+NPR5.23 [226819]
                        end;
                    }
                    field("Number Info Codeunit Name"; Rec."Number Info Codeunit Name")
                    {

                        Editable = false;
                        ToolTip = 'Specifies the value of the Number Info Codeunit Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(NAS)
            {
                Caption = 'NAS';
                group(Control6150683)
                {
                    ShowCaption = false;
                    field("NAS - Enabled"; Rec."NAS - Enabled")
                    {

                        ToolTip = 'Specifies the value of the NAS - Enabled field';
                        ApplicationArea = NPRRetail;
                    }
                    field("NAS - Administrator CRM"; Rec."NAS - Administrator CRM")
                    {

                        ToolTip = 'Specifies the value of the NAS - Administrator CRM field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("External Data")
            {
                Caption = 'External Data';
                group("Document Clearing")
                {
                    Caption = 'Document Clearing';
                    field("Clearing - SQL"; Rec."Clearing - SQL")
                    {

                        ToolTip = 'Specifies the value of the Clearing through SQL field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Virtual PDF")
            {
                Caption = 'Virtual PDF';
                field("Turnover - Email Addresses"; Rec."Turnover - Email Addresses")
                {

                    ToolTip = 'Specifies the value of the Turnover - Email Addresses field';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the Phone no. groups action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }


    [IntegrationEvent(TRUE, FALSE)]
    procedure GetPhoneLookupCU(var tmpAllObjWithCaption: Record AllObjWithCaption temporary)
    begin
        //NPR5.23 [226819]
    end;
}

