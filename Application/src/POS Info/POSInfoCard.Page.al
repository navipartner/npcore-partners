page 6150640 "NPR POS Info Card"
{
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Message"; Rec.Message)
                {

                    ToolTip = 'Specifies the value of the Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Once per Transaction"; Rec."Once per Transaction")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Once per Transaction field';

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
                        ToolTip = 'Specifies the value of the Copy from Header field';
                    }
                    field("Set POS Sale Line Color to Red"; Rec."Set POS Sale Line Color to Red")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Set POS Sale Line Color to Red field';
                    }
                }
                field("Available in Front-End"; Rec."Available in Front-End")
                {

                    ToolTip = 'Specifies the value of the Available in Front-End field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
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
                        ToolTip = 'Specifies the value of the Input Mandatory field';
                    }
                    field("Input Type"; Rec."Input Type")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Input Type field';

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
                            ToolTip = 'Specifies the value of the Table No. field';
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
