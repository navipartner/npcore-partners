page 6014475 "NPR Retail Price Log Entries"
{
    // NPR5.40/MHA /20180316  CASE 304031 Object created

    Caption = 'Retail Price Log Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Retail Price Log Entry";
    SourceTableView = SORTING("Date and Time");
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Date and Time"; Rec."Date and Time")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Date and Time field';
                }
                field("Date"; Rec.Date)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date field';
                }
                field("Time"; Rec.Time)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Change Log Entry No."; Rec."Change Log Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Change Log Entry No. field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Caption field';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Caption field';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Old Value"; Rec."Old Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Old Value field';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Value field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update Price Log")
            {
                AccessByPermission = TableData "Change Log Entry" = R;
                Caption = 'Update Price Log';
                Image = RefreshLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Update Price Log action';

                trigger OnAction()
                var
                    RetailPriceLogMgt: Codeunit "NPR Retail Price Log Mgt.";
                begin
                    RetailPriceLogMgt.UpdatePriceLog();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

