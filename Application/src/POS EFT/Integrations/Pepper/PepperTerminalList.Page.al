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
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Terminal Type Code"; Rec."Terminal Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Terminal Type Code field';
                }
                field("Instance ID"; Rec."Instance ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Instance ID field';
                }
                field("Configuration Code"; Rec."Configuration Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Configuration Code field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("License ID"; Rec."License ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License ID field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        Rec.UploadFile(0);
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Import';
                    Image = Import;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Import action';

                    trigger OnAction()
                    begin
                        Rec.UploadFile(1);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show action';

                    trigger OnAction()
                    begin
                        Rec.ShowFile(0);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additonal Parameters';
                    Image = ElectronicDoc;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additonal Parameters action';

                    trigger OnAction()
                    begin
                        Rec.ShowFile(1);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional parameters action';

                    trigger OnAction()
                    begin
                        Rec.ClearFile(0);
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Export';
                    Image = DeleteXML;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Export action';

                    trigger OnAction()
                    begin
                        Rec.ClearFile(1);
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the License action';

                    trigger OnAction()
                    begin
                        Rec.ExportFile(0);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Additional Parameters action';

                    trigger OnAction()
                    begin
                        Rec.ExportFile(1);
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
                ApplicationArea = All;
                ToolTip = 'Executes the Transaction Requests action';
            }
        }
    }
}

