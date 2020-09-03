page 6184494 "NPR Pepper Terminal List"
{
    // NPR5.20\BR\20160316  CASE 231481 Object Created
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID, License File, License Action
    // NPR5.29/BR/20161230  CASE 262269 Fix some ENU Captions, Added field License ID

    Caption = 'Pepper Terminal List';
    CardPageID = "NPR Pepper Terminal Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Terminal";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Terminal Type Code"; "Terminal Type Code")
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
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("License ID"; "License ID")
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
                Caption = 'Import';
                action(ImportLicense)
                {
                    Caption = 'License';
                    Image = ImportCodes;

                    trigger OnAction()
                    begin
                        UploadFile(0);
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Import';
                    Image = Import;

                    trigger OnAction()
                    begin
                        UploadFile(1);
                    end;
                }
            }
            group(Show)
            {
                Caption = 'Additonal Parameters';
                action(ShowLicense)
                {
                    Caption = 'Show';
                    Image = ElectronicNumber;

                    trigger OnAction()
                    begin
                        ShowFile(0);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additonal Parameters';
                    Image = ElectronicDoc;

                    trigger OnAction()
                    begin
                        ShowFile(1);
                    end;
                }
            }
            group("Delete")
            {
                Caption = 'Delete';
                action(DeleteLicense)
                {
                    Caption = 'Additional parameters';
                    Image = DeleteQtyToHandle;

                    trigger OnAction()
                    begin
                        ClearFile(0);
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Export';
                    Image = DeleteXML;

                    trigger OnAction()
                    begin
                        ClearFile(1);
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
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;

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
            }
        }
    }
}

