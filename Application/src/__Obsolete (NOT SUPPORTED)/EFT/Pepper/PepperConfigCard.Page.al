page 6184490 "NPR Pepper Config. Card"
{
    Extensible = False;
    // NPR5.22\BR\20160316  CASE 231481 Object Created
    // NPR5.22\BR\20160412  CASE 231481 Added Export Buttons
    // NPR5.22\BR\20160412  CASE 231481 Added fields "End of Day on Close", "Unload Library on Close", "End of Day Receipt Mandatory"
    // NPR5.22\BR\20160413  CASE 231481 Added fields Offline Mode
    // NPR5.25\BR\20160504  CASE 231481 Added Transaction Type Install
    // NPR5.25/BR/20160608  CASE 231481 Added fields Customer ID, License ID
    // NPR5.34/BR/20170320  CASE 268697 Added fields Min. Length Authorisation No. and Max. Length Authorisation No.

    Caption = 'Pepper Configuration Card';
    PageType = Card;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    SourceTable = "NPR Pepper Config.";


    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique identifier for this Pepper Configuration, that helps distinguish between different configurations.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies a user-friendly description or a name for this Pepper Configuration, making it easier to identify its purpose.';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Indicates the version number of this Pepper Configuration, helping track changes and updates.';
                    ApplicationArea = NPRRetail;
                }
                field("Recovery Retry Attempts"; Rec."Recovery Retry Attempts")
                {

                    ToolTip = 'Specifies the number of retry attempts the system should make when attempting to recover from an issue.';
                    ApplicationArea = NPRRetail;
                }
                field(Mode; Rec.Mode)
                {

                    ToolTip = 'Specifies the current operational mode of the Pepper Configuration, such as "Online" or "Offline.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Header and Footer Handling"; Rec."Header and Footer Handling")
                {

                    ToolTip = 'Specifies how this configuration manages header and footer information in documents and receipts.';
                    ApplicationArea = NPRRetail;
                }
                field(License; HasLicense)
                {

                    Caption = 'License';
                    Editable = false;
                    ToolTip = 'Indicates whether a valid license is associated with this Pepper Configuration.';
                    ApplicationArea = NPRRetail;
                }
                field("Additional Parameters"; HasAdditionalParameters)
                {

                    Caption = 'Additional Parameters';
                    Editable = false;
                    ToolTip = 'Indicates whether additional configuration parameters are defined for this configuration.';
                    ApplicationArea = NPRRetail;
                }
                field("Default POS Timeout (Seconds)"; Rec."Default POS Timeout (Seconds)")
                {

                    ToolTip = 'Specifies the default time limit (in seconds) for POS operations.';
                    ApplicationArea = NPRRetail;
                }
                field("Show Detailed Error Messages"; Rec."Show Detailed Error Messages")
                {

                    ToolTip = 'Display detailed error messages to aid in troubleshooting.';
                    ApplicationArea = NPRRetail;
                }
                field("Offline mode"; Rec."Offline mode")
                {

                    ToolTip = 'Choose whether the Pepper Configuration is set to operate in an offline mode. This option is useful for remote or disconnected environments.';
                    ApplicationArea = NPRRetail;
                }
                field("Min. Length Authorisation No."; Rec."Min. Length Authorisation No.")
                {

                    ToolTip = 'Specifies the minimum length required for authorization numbers, enhancing security.';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Length Authorisation No."; Rec."Max. Length Authorisation No.")
                {

                    ToolTip = 'Specifies the customer or the client associated to this Pepper Configuration.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer ID"; Rec."Customer ID")
                {

                    ToolTip = 'Specifies the ID of the license associated with this Pepper Configuration.';
                    ApplicationArea = NPRRetail;
                }
                field("License ID"; Rec."License ID")
                {

                    ToolTip = 'Specifies the ID of the license associated with this Pepper Configuration.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Logging)
            {
                field("Logging Target"; Rec."Logging Target")
                {

                    ToolTip = 'Specifies the destination where log information is recorded, such as a file or a database.';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Level"; Rec."Logging Level")
                {

                    ToolTip = 'Choose how detailed the logged information is.';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Max. File Size (MB)"; Rec."Logging Max. File Size (MB)")
                {

                    ToolTip = 'Specifies the maximum size (in megabytes) of individual log files.';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Directory"; Rec."Logging Directory")
                {

                    ToolTip = 'Specifies the path to the directory in which the log files are stored.';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Archive Directory"; Rec."Logging Archive Directory")
                {

                    ToolTip = 'Specifies the directory in which the archived log files are stored for historical reference.';
                    ApplicationArea = NPRRetail;
                }
                field("Logging Archive Max. Age Days"; Rec."Logging Archive Max. Age Days")
                {

                    ToolTip = 'Specifies the maximum number of days the files remain in the log before they are archived or deleted.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Files)
            {
                field("Card Type File Full Path"; Rec."Card Type File Full Path")
                {

                    ToolTip = 'Specifies the full file path to the card type file, including its directory and file name.';
                    ApplicationArea = NPRRetail;
                }
                field("License File Full Path"; Rec."License File Full Path")
                {

                    ToolTip = 'Specifies the full file path to the license file, providing easy access.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Directories)
            {
                field("Ticket Directory"; Rec."Ticket Directory")
                {

                    ToolTip = 'Specifies the location of the directory used for storing ticket-related files.';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Directory"; Rec."Journal Directory")
                {

                    ToolTip = 'Specifies the directory for storing journal-related files.';
                    ApplicationArea = NPRRetail;
                }
                field("Matchbox Directory"; Rec."Matchbox Directory")
                {

                    ToolTip = 'Specifies the path to the directory for Matchbox configuration files.';
                    ApplicationArea = NPRRetail;
                }
                field("Messages Directory"; Rec."Messages Directory")
                {

                    ToolTip = 'Specifies the path to the directory used for storing message-related files.';
                    ApplicationArea = NPRRetail;
                }
                field("Persistance Directory"; Rec."Persistance Directory")
                {

                    ToolTip = 'Specifies the path to the directory used for storing persistence-related files.';
                    ApplicationArea = NPRRetail;
                }
                field("Working Directory"; Rec."Working Directory")
                {

                    ToolTip = 'Specifies the working directory for this Pepper Configuration, which is the location in which it operates.';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Transaction Types")
            {
                field(Open; Rec."Transaction Type Open Code")
                {

                    ToolTip = 'Assign a code used for the open transaction type, used in transaction processing.';
                    ApplicationArea = NPRRetail;
                }
                field(Payment; Rec."Transaction Type Payment Code")
                {

                    ToolTip = 'Assign a code for the payment transaction type, facilitating the payment processing.';
                    ApplicationArea = NPRRetail;
                }
                field(Close; Rec."Transaction Type Close Code")
                {

                    ToolTip = 'Assign a code for the close transaction type, used when closing transactions.';
                    ApplicationArea = NPRRetail;
                }
                field(Refund; Rec."Transaction Type Refund Code")
                {

                    ToolTip = 'Assign a code for the refund transaction type, applicable for refunds.';
                    ApplicationArea = NPRRetail;
                }
                field(Recover; Rec."Transaction Type Recover Code")
                {

                    ToolTip = 'Assign a code for the recover transaction type, used during recovery processes.';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Type Auxilary Code"; Rec."Transaction Type Auxilary Code")
                {

                    ToolTip = 'Assign a code for auxiliary transaction types, enhancing the transaction management.';
                    ApplicationArea = NPRRetail;
                }
                field("Transaction Type Install Code"; Rec."Transaction Type Install Code")
                {

                    ToolTip = 'Assign a code for the install transaction type, used in the installation processes.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Closing)
            {
                field("End of Day on Close"; Rec."End of Day on Close")
                {

                    ToolTip = 'Choose whether the end-of-day process is triggered automatically when the POS is closed.';
                    ApplicationArea = NPRRetail;
                }
                field("Unload Library on Close"; Rec."Unload Library on Close")
                {

                    ToolTip = 'Choose whether the library associated with this configuration is unloaded when the POS is closed.';
                    ApplicationArea = NPRRetail;
                }
                field("End of Day Receipt Mandatory"; Rec."End of Day Receipt Mandatory")
                {

                    ToolTip = 'Choose whether it is mandatory to generate an end-of-day receipt when the POS is closed.';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Instances action';
                ApplicationArea = NPRRetail;
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

                    ToolTip = 'Executes the License action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UploadFile(0);
                        UpdateBLOBCheck();
                    end;
                }
                action(ImportAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = Import;

                    ToolTip = 'Executes the Additional Parameters action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.UploadFile(1);
                        UpdateBLOBCheck();
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

                    ToolTip = 'Executes the License action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck();
                        Rec.ShowFile(0);
                    end;
                }
                action(ShowConfigXML)
                {
                    Caption = 'Configuration XML';
                    Image = CreateXMLFile;

                    ToolTip = 'Executes the Configuration XML action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        UpdateBLOBCheck();
                        Rec.ShowFile(1);
                    end;
                }
                action(ShowAdditionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = ElectronicDoc;

                    ToolTip = 'Executes the Additional Parameters action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowFile(2);
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

                    ToolTip = 'Executes the License action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ClearFile(0);
                        UpdateBLOBCheck();
                    end;
                }
                action("DeleteAdditional Parameters")
                {
                    Caption = 'Additional parameters';
                    Image = DeleteXML;

                    ToolTip = 'Executes the Additional parameters action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ClearFile(1);
                        UpdateBLOBCheck();
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

                    ToolTip = 'Executes the License action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(0);
                    end;
                }
                action(ExportConfig)
                {
                    Caption = 'Configuration XML';
                    Image = ExportElectronicDocument;

                    ToolTip = 'Executes the Configuration XML action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(1);
                    end;
                }
                action(ExportAddtionalParameters)
                {
                    Caption = 'Additional Parameters';
                    Image = TransmitElectronicDoc;

                    ToolTip = 'Executes the Additional Parameters action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ExportFile(2);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateBLOBCheck();
    end;

    var
        HasLicense: Boolean;
        HasAdditionalParameters: Boolean;

    local procedure UpdateBLOBCheck()
    begin
        Rec.CalcFields("License File", "Additional Parameters");
        HasLicense := Rec."License File".HasValue();
        HasAdditionalParameters := Rec."Additional Parameters".HasValue();
    end;
}

