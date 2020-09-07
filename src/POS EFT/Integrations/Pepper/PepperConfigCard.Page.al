page 6184490 "NPR Pepper Config. Card"
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
    SourceTable = "NPR Pepper Config.";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                }
                field("Recovery Retry Attempts"; "Recovery Retry Attempts")
                {
                    ApplicationArea = All;
                }
                field(Mode; Mode)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Header and Footer Handling"; "Header and Footer Handling")
                {
                    ApplicationArea = All;
                }
                field(License; HasLicense)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Additional Parameters"; HasAdditionalParameters)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Default POS Timeout (Seconds)"; "Default POS Timeout (Seconds)")
                {
                    ApplicationArea = All;
                }
                field("Show Detailed Error Messages"; "Show Detailed Error Messages")
                {
                    ApplicationArea = All;
                }
                field("Offline mode"; "Offline mode")
                {
                    ApplicationArea = All;
                }
                field("Min. Length Authorisation No."; "Min. Length Authorisation No.")
                {
                    ApplicationArea = All;
                }
                field("Max. Length Authorisation No."; "Max. Length Authorisation No.")
                {
                    ApplicationArea = All;
                }
                field("Customer ID"; "Customer ID")
                {
                    ApplicationArea = All;
                }
                field("License ID"; "License ID")
                {
                    ApplicationArea = All;
                }
            }
            group(Logging)
            {
                field("Logging Target"; "Logging Target")
                {
                    ApplicationArea = All;
                }
                field("Logging Level"; "Logging Level")
                {
                    ApplicationArea = All;
                }
                field("Logging Max. File Size (MB)"; "Logging Max. File Size (MB)")
                {
                    ApplicationArea = All;
                }
                field("Logging Directory"; "Logging Directory")
                {
                    ApplicationArea = All;
                }
                field("Logging Archive Directory"; "Logging Archive Directory")
                {
                    ApplicationArea = All;
                }
                field("Logging Archive Max. Age Days"; "Logging Archive Max. Age Days")
                {
                    ApplicationArea = All;
                }
            }
            group(Files)
            {
                field("Card Type File Full Path"; "Card Type File Full Path")
                {
                    ApplicationArea = All;
                }
                field("License File Full Path"; "License File Full Path")
                {
                    ApplicationArea = All;
                }
            }
            group(Directories)
            {
                field("Ticket Directory"; "Ticket Directory")
                {
                    ApplicationArea = All;
                }
                field("Journal Directory"; "Journal Directory")
                {
                    ApplicationArea = All;
                }
                field("Matchbox Directory"; "Matchbox Directory")
                {
                    ApplicationArea = All;
                }
                field("Messages Directory"; "Messages Directory")
                {
                    ApplicationArea = All;
                }
                field("Persistance Directory"; "Persistance Directory")
                {
                    ApplicationArea = All;
                }
                field("Working Directory"; "Working Directory")
                {
                    ApplicationArea = All;
                }
            }
            group("Transaction Types")
            {
                field(Open; "Transaction Type Open Code")
                {
                    ApplicationArea = All;
                }
                field(Payment; "Transaction Type Payment Code")
                {
                    ApplicationArea = All;
                }
                field(Close; "Transaction Type Close Code")
                {
                    ApplicationArea = All;
                }
                field(Refund; "Transaction Type Refund Code")
                {
                    ApplicationArea = All;
                }
                field(Recover; "Transaction Type Recover Code")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type Auxilary Code"; "Transaction Type Auxilary Code")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type Install Code"; "Transaction Type Install Code")
                {
                    ApplicationArea = All;
                }
            }
            group(Closing)
            {
                field("End of Day on Close"; "End of Day on Close")
                {
                    ApplicationArea = All;
                }
                field("Unload Library on Close"; "Unload Library on Close")
                {
                    ApplicationArea = All;
                }
                field("End of Day Receipt Mandatory"; "End of Day Receipt Mandatory")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR Pepper Instances";
                RunPageLink = "Configuration Code" = FIELD(Code);
                RunPageView = SORTING(ID)
                              ORDER(Ascending);
                ApplicationArea=All;
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
                    ApplicationArea=All;

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
                    ApplicationArea=All;

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
                    ApplicationArea=All;

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
                    ApplicationArea=All;

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
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ShowFile(2);
                    end;
                }
            }
            group("Delete")
            {
                Caption = 'Delete';
                action(DeleteLicense)
                {
                    Caption = 'License';
                    Image = DeleteQtyToHandle;
                    ApplicationArea=All;

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
                    ApplicationArea=All;

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
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ExportFile(0);
                    end;
                }
                action(ExportConfig)
                {
                    Caption = 'Configuration XML';
                    Image = ExportElectronicDocument;
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ExportFile(1);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;
                    ApplicationArea=All;

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
        CalcFields("License File", "Additional Parameters");
        HasLicense := "License File".HasValue;
        HasAdditionalParameters := "Additional Parameters".HasValue;
    end;
}

