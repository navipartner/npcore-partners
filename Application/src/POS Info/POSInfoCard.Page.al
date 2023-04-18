page 6150640 "NPR POS Info Card"
{
    Extensible = False;
    Caption = 'POS Info Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Info";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of "POS Info".';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a Short Description for the POS Info code.';
                    ApplicationArea = NPRRetail;
                }
                field("Message"; Rec.Message)
                {
                    ToolTip = 'Specifies the message that you want to be displayed on POS.';
                    ApplicationArea = NPRRetail;
                }
                field("Once per Transaction"; Rec."Once per Transaction")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the POS Info code is set to be used per lines or per whole transaction (ticket). If activated, the POS Info will be applied for the whole transaction.';

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
                    ToolTip = 'If active, the POS Info Codes can be identified and available in the front end via a data source extension. Those POS Info Codes can be displayed on POS Menu Button, as well as on the Sales View Status bar and the Caption Box.';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies how the POS Info Code is used. Show Message - a predefined message from the Message field is displayed on the POS on calling a customer or Item as information pertaining to that customer/item. Request Data - data needs to be selected from a set or inserted manually, and recorded in the POS Info POS Entry List. Write Default Message - a predefined message from the Message field is selected and recorded in the POS Info POS Entry List.';
                    ApplicationArea = NPRRetail;

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
                        ToolTip = 'Specifies that the POS Info Code is imperative. There will be an error if user tries to close the Numpad, list of values or Message Windows on the POS without entering or selecting data.';
                    }
                    field("Input Type"; Rec."Input Type")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'If Request Data is the selected method, you need to specify in this field what kind of data you will get. Text - manually input text, where the Message field is left BLANK. SubCode - choose from a list created in the POS Info SubCodes. Table - choose from a set of values from a Business Central.';

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
                Caption = 'POS Info SubCodes';
                SubPageLink = Code = FIELD(Code);
                ApplicationArea = NPRRetail;
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
                Caption = 'Field Mapping';
                Image = "Action";

                ToolTip = 'Executes the Field Mapping action';
                ApplicationArea = NPRRetail;

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
