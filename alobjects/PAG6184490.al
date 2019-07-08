page 6184490 "Pepper Configuration Card"
{
    // NPR5.22\BR\20160316  CASE 231481 Object Created
    // NPR5.22\BR\20160412  CASE 231481 Added Export Buttons
    // NPR5.22\BR\20160412  CASE 231481 Added fields "End of Day on Close", "Unload Library on Close", "End of Day Receipt Mandatory"
    // NPR5.22\BR\20160413  CASE 231481 Added fields Offline Mode
    // NPR5.25\BR\20160504  CASE 231481 Added Transaction Type Install
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID
    // NPR5.34/BR/20170320  CASE 268697 Added fields Min. Length Authorisation No. and Max. Length Authorisation No.

    Caption = 'Pepper Configuration Card';
    PageType = Card;
    SourceTable = "Pepper Configuration";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(Version;Version)
                {
                }
                field("Recovery Retry Attempts";"Recovery Retry Attempts")
                {
                }
                field(Mode;Mode)
                {

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Header and Footer Handling";"Header and Footer Handling")
                {
                }
                field(License;HasLicense)
                {
                    Editable = false;
                }
                field("Additional Parameters";HasAdditionalParameters)
                {
                    Editable = false;
                }
                field("Default POS Timeout (Seconds)";"Default POS Timeout (Seconds)")
                {
                }
                field("Show Detailed Error Messages";"Show Detailed Error Messages")
                {
                }
                field("Offline mode";"Offline mode")
                {
                }
                field("Min. Length Authorisation No.";"Min. Length Authorisation No.")
                {
                }
                field("Max. Length Authorisation No.";"Max. Length Authorisation No.")
                {
                }
                field("Customer ID";"Customer ID")
                {
                }
                field("License ID";"License ID")
                {
                }
            }
            group(Logging)
            {
                field("Logging Target";"Logging Target")
                {
                }
                field("Logging Level";"Logging Level")
                {
                }
                field("Logging Max. File Size (MB)";"Logging Max. File Size (MB)")
                {
                }
                field("Logging Directory";"Logging Directory")
                {
                }
                field("Logging Archive Directory";"Logging Archive Directory")
                {
                }
                field("Logging Archive Max. Age Days";"Logging Archive Max. Age Days")
                {
                }
            }
            group(Files)
            {
                field("Card Type File Full Path";"Card Type File Full Path")
                {
                }
                field("License File Full Path";"License File Full Path")
                {
                }
            }
            group(Directories)
            {
                field("Ticket Directory";"Ticket Directory")
                {
                }
                field("Journal Directory";"Journal Directory")
                {
                }
                field("Matchbox Directory";"Matchbox Directory")
                {
                }
                field("Messages Directory";"Messages Directory")
                {
                }
                field("Persistance Directory";"Persistance Directory")
                {
                }
                field("Working Directory";"Working Directory")
                {
                }
            }
            group("Transaction Types")
            {
                field(Open;"Transaction Type Open Code")
                {
                }
                field(Payment;"Transaction Type Payment Code")
                {
                }
                field(Close;"Transaction Type Close Code")
                {
                }
                field(Refund;"Transaction Type Refund Code")
                {
                }
                field(Recover;"Transaction Type Recover Code")
                {
                }
                field("Transaction Type Auxilary Code";"Transaction Type Auxilary Code")
                {
                }
                field("Transaction Type Install Code";"Transaction Type Install Code")
                {
                }
            }
            group(Closing)
            {
                field("End of Day on Close";"End of Day on Close")
                {
                }
                field("Unload Library on Close";"Unload Library on Close")
                {
                }
                field("End of Day Receipt Mandatory";"End of Day Receipt Mandatory")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Instances)
            {
                Caption = 'Instances';
                Image = Server;
                RunObject = Page "Pepper Instances";
                RunPageLink = "Configuration Code"=FIELD(Code);
                RunPageView = SORTING(ID)
                              ORDER(Ascending);
            }
        }
        area(processing)
        {
            group(Import)
            {
                Caption = 'Import';
                action(ImportLicense)
                {
                    Caption = 'License';
                    Image = ImportCodes;

                    trigger OnAction()
                    begin
                        UploadFile(0);
                        UpdateBLOBCheck;
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = Import;

                    trigger OnAction()
                    begin
                        UploadFile(1);
                        UpdateBLOBCheck;
                    end;
                }
            }
            group(Show)
            {
                Caption = 'Show';
                action(ShowLicense)
                {
                    Caption = 'License';
                    Image = ElectronicNumber;

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck;
                        ShowFile(0);
                    end;
                }
                action(ShowConfigXML)
                {
                    Caption = 'Configuration XML';
                    Image = CreateXMLFile;

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck;
                        ShowFile(1);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = ElectronicDoc;

                    trigger OnAction()
                    begin
                        ShowFile(2);
                    end;
                }
            }
            group(Delete)
            {
                Caption = 'Delete';
                action(DeleteLicense)
                {
                    Caption = 'License';
                    Image = DeleteQtyToHandle;

                    trigger OnAction()
                    begin
                        ClearFile(0);
                        UpdateBLOBCheck;
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Additional parameters';
                    Image = DeleteXML;

                    trigger OnAction()
                    begin
                        ClearFile(1);
                        UpdateBLOBCheck;
                    end;
                }
            }
            group(Export)
            {
                Caption = 'Export';
                action(ExportLicense)
                {
                    Caption = 'License';
                    Image = Export;

                    trigger OnAction()
                    begin
                        ExportFile(0);
                    end;
                }
                action(ExportConfig)
                {
                    Caption = 'Configuration XML';
                    Image = ExportElectronicDocument;

                    trigger OnAction()
                    begin
                        ExportFile(1);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;

                    trigger OnAction()
                    begin
                        ExportFile(2);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateBLOBCheck;
    end;

    var
        HasLicense: Boolean;
        HasAdditionalParameters: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        CalcFields("License File","Additional Parameters");
        HasLicense := "License File".HasValue;
        HasAdditionalParameters := "Additional Parameters".HasValue;
    end;
}

