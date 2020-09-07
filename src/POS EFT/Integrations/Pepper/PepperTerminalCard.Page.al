page 6184493 "NPR Pepper Terminal Card"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160509  CASE 231481 Added field Fixed Currency Code
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID, License File, License Action
    // NPR5.27/BR/20161025  CASE 255131 Added field Close Automatically
    // NPR5.29/BR/20161221  CASE 261673 Added Nets requirement for signature confirmation

    Caption = 'Pepper Terminal Card';
    PageType = Card;
    SourceTable = "NPR Pepper Terminal";

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
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Instance ID"; "Instance ID")
                {
                    ApplicationArea = All;
                }
                field("Configuration Code"; "Configuration Code")
                {
                    ApplicationArea = All;
                }
                field(Language; Language)
                {
                    ApplicationArea = All;
                }
                field("Pepper Receipt Encoding"; "Pepper Receipt Encoding")
                {
                    ApplicationArea = All;
                }
                field("NAV Receipt Encoding"; "NAV Receipt Encoding")
                {
                    ApplicationArea = All;
                }
                field("Com Port"; "Com Port")
                {
                    ApplicationArea = All;
                }
                field("IP Address"; "IP Address")
                {
                    ApplicationArea = All;
                }
                field("Terminal Type Code"; "Terminal Type Code")
                {
                    ApplicationArea = All;
                }
                field("Receipt Format"; "Receipt Format")
                {
                    ApplicationArea = All;
                }
                field("Fixed Currency Code"; "Fixed Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Open Automatically"; "Open Automatically")
                {
                    ApplicationArea = All;
                }
                field("Close Automatically"; "Close Automatically")
                {
                    ApplicationArea = All;
                }
                field("Cancel at Wrong Signature"; "Cancel at Wrong Signature")
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
            }
            group(Matchbox)
            {
                field("Matchbox Files"; "Matchbox Files")
                {
                    ApplicationArea = All;
                }
                field("Matchbox Company ID"; "Matchbox Company ID")
                {
                    ApplicationArea = All;
                }
                field("Matchbox Shop ID"; "Matchbox Shop ID")
                {
                    ApplicationArea = All;
                }
                field("Matchbox POS ID"; "Matchbox POS ID")
                {
                    ApplicationArea = All;
                }
                field("Matchbox File Name"; "Matchbox File Name")
                {
                    ApplicationArea = All;
                }
            }
            group("Print Files")
            {
                field("Print File Open"; "Print File Open")
                {
                    ApplicationArea = All;
                }
                field("Print File Close"; "Print File Close")
                {
                    ApplicationArea = All;
                }
                field("Print File Transaction"; "Print File Transaction")
                {
                    ApplicationArea = All;
                }
                field("Print File CC Transaction"; "Print File CC Transaction")
                {
                    ApplicationArea = All;
                }
                field("Print File Difference"; "Print File Difference")
                {
                    ApplicationArea = All;
                }
                field("Print File End of Day"; "Print File End of Day")
                {
                    ApplicationArea = All;
                }
                field("Print File Journal"; "Print File Journal")
                {
                    ApplicationArea = All;
                }
                field("Print File Initialisation"; "Print File Initialisation")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Import)
            {
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
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = ElectronicDoc;
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ShowFile(1);
                    end;
                }
            }
            group("Delete")
            {
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
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;
                    ApplicationArea=All;

                    trigger OnAction()
                    begin
                        ExportFile(1);
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Transaction Requests")
            {
                Caption = 'Transaction Requests';
                Image = Transactions;
                RunObject = Page "NPR EFT Transaction Requests";
                RunPageLink = "Pepper Terminal Code" = FIELD(Code);
                RunPageView = SORTING("Entry No.")
                              ORDER(Ascending);
                ApplicationArea=All;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateBLOBCheck;
    end;

    var
        HasAdditionalParameters: Boolean;
        HasLicense: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        //-NPR5.25 [231481]
        //CALCFIELDS("Additional Parameters File");
        CalcFields("Additional Parameters File", "License File");
        HasLicense := "License File".HasValue;
        //+NPR5.25 [231481]
        HasAdditionalParameters := "Additional Parameters File".HasValue;
    end;
}

