page 6150640 "NPR POS Info Card"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.51/ALPO/20190826 CASE 364558 Define inheritable pos info codes (will be copied from Sales POS header to new lines)
    // NPR5.51/ALPO/20190912 CASE 368351 Apply red color to POS sale lines only for selected POS info codes

    Caption = 'POS Info Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message field';
                }
                field("Once per Transaction"; Rec."Once per Transaction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Once per Transaction field';
                }
                field("Copy from Header"; Rec."Copy from Header")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Copy from Header field';
                }
                field("Available in Front-End"; Rec."Available in Front-End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Available in Front-End field';
                }
                field("Set POS Sale Line Color to Red"; Rec."Set POS Sale Line Color to Red")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Set POS Sale Line Color to Red field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Input Mandatory"; Rec."Input Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Input Mandatory field';
                }
                field("Input Type"; Rec."Input Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Input Type field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
            }
            part("POS Info Subform"; "NPR POS Info Subform")
            {
                Caption = 'POS Info Subform';
                SubPageLink = Code = FIELD(Code);
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Field Mapping action';

                trigger OnAction()
                var
                    POSInfoLookupFieldSetup: Page "NPR POS Info Look. Field Setup";
                begin
                    if (Rec."Input Type" <> Rec."Input Type"::Table) or (Rec."Table No." = 0) then
                        Error(ErrorText001, Format(Rec."Input Type"::Table), Rec.FieldCaption("Table No."));

                    POSInfoLookupFieldSetup.SetPOSInfo(Rec);
                    POSInfoLookupFieldSetup.RunModal();
                end;
            }
        }
    }

    var
        ErrorText001: Label 'You can only setup fieldmapping if input type is %1 and %2 is not empty.';
}

