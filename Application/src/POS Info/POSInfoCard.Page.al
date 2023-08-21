page 6150640 "NPR POS Info Card"
{
    Caption = 'POS Info Card';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/pos_info_setup/';
    Extensible = False;
    PageType = Card;
    SourceTable = "NPR POS Info";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a unique code for the POS info entity.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Describes the POS info entity, and provides more information about its purpose.';
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Provide a message which will be displayed on the POS. If you wish the salesperson to be able to provide a message themselves, leave this field blank.';
                }
                field("Once per Transaction"; Rec."Once per Transaction")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Indicates whether the POS info is set to be used per a line or per a whole transaction. If active, the POS info entity will be applied per a whole transaction.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                        UpdateControls();
                        CurrPage.Update(false);
                    end;
                }
                group(OnlyIfNotOncePerTransaction)
                {
                    ShowCaption = false;
                    Visible = not Rec."Once per Transaction";

                    field("Copy from Header"; Rec."Copy from Header")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'If active, and if the POS Info Code is applied to the POS Sale Header, this code will be inherited by all new sales lines.';
                    }
                    field("Set POS Sale Line Color to Red"; Rec."Set POS Sale Line Color to Red")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'If active, and if the POS Info Code is applied to a POS Sales Line, the line will be marked in red color.';
                    }
                }
                field("Available in Front-End"; Rec."Available in Front-End")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'If active, the POS info codes can be identified and made available in the front end via a data source extension. Those POS info codes can be displayed on a POS menu button, as well as on the sales view status bar and the caption box.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies how the POS info code is used. The following options are available: Request Data - the data needs to be selected from an existing set or input manually and recorded in the POS Info POS Entry List; Write Default Message - a predefined message from the Message field is displayed on the POS when information on a customer or an item is retrieved; Show Message - a predefined message from the Message field is displayed on the POS when a customer or an item is retrieved.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                        UpdateControls();
                        CurrPage.Update(false);
                    end;
                }
                group(AdditionalFieldsForTypeRequestData)
                {
                    ShowCaption = false;
                    Visible = IsOfTypeRequestData;

                    field("Input Mandatory"; Rec."Input Mandatory")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'If active, the salesperson will be required to provide a POS Info Code if they press the POS menu button.';
                    }
                    field("Input Type"; Rec."Input Type")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Select which type of input a salesperson needs to provide. You can choose between text, subcode (a list created in POS Info SubCodes) or table (a set of values provided in Business Central).';

                        trigger OnValidate()
                        begin
                            CurrPage.SaveRecord();
                            UpdateControls();
                            CurrPage.Update(false);
                        end;
                    }
                    group(AdditionalFieldsFOrInputTypeTable)
                    {
                        ShowCaption = false;
                        Visible = IsInputTypeTable;

                        field("Table No."; Rec."Table No.")
                        {
                            ApplicationArea = NPRRetail;
                            ToolTip = 'Specifies the number of the table in which users provide their own list of codes and values.';
                        }
                    }
                }
            }
            part("POS Info Subform"; "NPR POS Info Subform")
            {
                ApplicationArea = NPRRetail;
                Caption = 'POS Info SubCodes';
                SubPageLink = Code = FIELD(Code);
                Visible = IsInputTypeSubcode;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Field Mapping")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Field Mapping';
                Image = "Action";

                ToolTip = 'Executes the Field Mapping action';

                trigger OnAction()
                var
                    POSInfoLookupFieldSetup: Page "NPR POS Info Look. Field Setup";
                begin
                    Rec.TestField("Input Type", Rec."Input Type"::Table);
                    Rec.TestField("Table No.");
                    POSInfoLookupFieldSetup.SetPOSInfo(Rec);
                    POSInfoLookupFieldSetup.RunModal();
                end;
            }
        }
    }

    var
        IsInputTypeSubcode: Boolean;
        IsInputTypeTable: Boolean;
        IsOfTypeRequestData: Boolean;

    local procedure UpdateControls()
    begin
        IsInputTypeSubcode := Rec."Input Type" = Rec."Input Type"::SubCode;
        IsInputTypeTable := Rec."Input Type" = Rec."Input Type"::Table;
        IsOfTypeRequestData := Rec.Type = Rec.Type::"Request Data";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;
}
