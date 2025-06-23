page 6184494 "NPR Pepper Terminal List"
{
    Extensible = False;
    Caption = 'Pepper Terminal List';
    ContextSensitiveHelpPage = 'docs/retail/eft/how-to/pepper_terminal/';
    CardPageID = "NPR Pepper Terminal Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Pepper Terminal";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique code of the Pepper Terminal';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the Pepper Terminal';
                    ApplicationArea = NPRRetail;
                }
                field("Terminal Type Code"; Rec."Terminal Type Code")
                {

                    ToolTip = 'Specifies the code of the Terminal Type';
                    ApplicationArea = NPRRetail;
                }
                field("Instance ID"; Rec."Instance ID")
                {

                    ToolTip = 'Specifies the ID of the instance';
                    ApplicationArea = NPRRetail;
                }
                field("Configuration Code"; Rec."Configuration Code")
                {

                    ToolTip = 'Specifies the code of the configuration';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the number of the POS unit';
                    ApplicationArea = NPRRetail;
                }
                field("License ID"; Rec."License ID")
                {

                    ToolTip = 'Specifies the ID of the license';
                    ApplicationArea = NPRRetail;
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

                    ToolTip = 'Imports the license file for the Pepper Terminal ';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UploadFile(0);
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Import';
                    Image = Import;

                    ToolTip = 'Imports additional parameters for the Pepper Terminal ';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Displays the license details for the Pepper Terminal';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowFile(0);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additonal Parameters';
                    Image = ElectronicDoc;

                    ToolTip = 'Shows additional parameters for the Pepper Terminal';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Deletes the license associated with the Pepper Terminal.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ClearFile(0);
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Export';
                    Image = DeleteXML;

                    ToolTip = 'Removes additional parameters for the Pepper Terminal';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Exports the license details for the Pepper Terminal';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(0);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;

                    ToolTip = 'Exports additional parameters for the Pepper Terminal';
                    ApplicationArea = NPRRetail;

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

                ToolTip = 'Shows the transaction requests associated with the Pepper Terminal ';
                ApplicationArea = NPRRetail;
            }
        }
    }
}